"""Local/HTTPS JEV conversation API. No dependencies or question/answer access logs."""
import argparse
from collections import OrderedDict
import copy
import hashlib
import hmac
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import ipaddress
import json
import os
from pathlib import Path
import ssl
import threading
import time
import uuid

from experiments.language import lab

ROOT = Path(__file__).resolve().parents[1]
MAX_BODY = 65536
MAX_HISTORY = 6
MAX_HISTORY_SCALARS = 12000


class APIError(Exception):
    def __init__(self, code, status=400):
        self.code, self.status = code, status


def text(value, limit, *, strip=True):
    if not isinstance(value, str) or any(0xD800 <= ord(c) <= 0xDFFF for c in value):
        raise APIError('invalid_input')
    value = value.strip() if strip else value
    if not value.strip() or len(value) > limit:
        raise APIError('invalid_input')
    return value


def validate_request(body):
    if not isinstance(body, dict) or set(body) - {'requestId','characterId','question','locale','history'}:
        raise APIError('invalid_input')
    request_id = body.get('requestId')
    try:
        if not isinstance(request_id, str) or str(uuid.UUID(request_id)) != request_id.lower():
            raise ValueError()
    except (ValueError, TypeError, AttributeError):
        raise APIError('invalid_request_id') from None
    character = body.get('characterId')
    if character not in ('oracle','stone','jester','fool'):
        raise APIError('unknown_character')
    if body.get('locale') not in ('en','zh-Hans'):
        raise APIError('unsupported_locale')
    question = text(body.get('question'), 500)
    history = body.get('history', [])
    if not isinstance(history, list) or len(history) > MAX_HISTORY:
        raise APIError('invalid_history')
    clean = []
    for turn in history:
        if not isinstance(turn, dict) or set(turn) != {'question','answer'}:
            raise APIError('invalid_history')
        clean.append(dict(question=text(turn['question'], 500), answer=text(turn['answer'], 1500)))
    if sum(len(t['question'])+len(t['answer']) for t in clean) > MAX_HISTORY_SCALARS:
        raise APIError('invalid_history')
    return dict(requestId=request_id, characterId=character, question=question, locale=body['locale'], history=clean)


def configured_key():
    value = os.environ.get('TYPESAFE_API_KEY', '')
    if not value:
        env = ROOT / '.env'
        if env.exists():
            for line in env.read_text().splitlines():
                if line.startswith('TYPESAFE_API_KEY='):
                    value = line.split('=',1)[1].strip().strip('\"\'')
    return value


class ConversationService:
    """Immutable startup catalog, bounded in-memory deduplication, explicit reply origins."""
    def __init__(self, *, call=None, key=None, deadline=120, concurrency=2, cache_size=128, ttl=600):
        self.bundle = json.loads((ROOT/'experiments/language/catalogs.json').read_text())
        lab.validate_catalogs(self.bundle)
        self.key = configured_key() if key is None else key
        self.call = call if call is not None else lambda p,t: lab.http_call(self.key,p,t)
        self.ready = call is not None or bool(self.key)
        self.deadline = deadline
        self.capacity = threading.BoundedSemaphore(concurrency)
        self.lock = threading.Lock()
        self.entries = OrderedDict()
        self.cache_size, self.ttl = cache_size, ttl

    def fallback(self, req, reason):
        cat = self.catalog(req)
        return dict(requestId=req['requestId'], characterId=req['characterId'], catalogVersion=cat['catalogVersion'],
            status='complete', stopReason='fallback_complete', origin='authored_fallback', generationStatus='failed',
            generationStopReason=reason, segments=[dict(candidateId=req['characterId']+'.service_fallback',text=cat['fallback'])],
            metrics=dict(calls=0,latencyMs=0))

    def catalog(self, req):
        catalogs=self.bundle['catalogs'] if req['locale']=='en' else self.bundle['localizations'][req['locale']]['catalogs']
        return catalogs[req['characterId']]

    def generate(self, req):
        if not self.ready:
            return self.fallback(req,'provider_not_configured')
        if not self.capacity.acquire(blocking=False):
            return self.fallback(req,'server_busy')
        try:
            result = lab.reading(self.catalog(req), req['question'], self.call,
                                 deadline=self.deadline, history=req['history'])
            is_generated = result['origin'] == 'jev'
            # One rendered segment preserves punctuation under the existing iOS space-join contract.
            return dict(requestId=req['requestId'], characterId=req['characterId'], catalogVersion=result['catalogVersion'],
                status='complete', stopReason='rule_complete' if is_generated else 'fallback_complete',
                origin=result['origin'], generationStatus=result['generationStatus'], generationStopReason=result['stopReason'],
                segments=[dict(candidateId=(req['characterId']+'.composed' if is_generated else req['characterId']+'.service_fallback'),text=result['text'])],
                selectedCandidateIds=[s['candidateId'] for s in result['segments']],
                metrics=dict(calls=result['calls'],latencyMs=result['latencyMs']))
        except Exception:
            # Do not leak provider exceptions, URLs, keys, input or trace data into HTTP responses.
            return self.fallback(req,'generation_error')
        finally:
            self.capacity.release()

    def reading(self, body):
        req = validate_request(body)
        identity = req['requestId'].lower()
        fingerprint = hashlib.sha256(json.dumps({k:v for k,v in req.items() if k!='requestId'},sort_keys=True).encode()).hexdigest()
        now = time.monotonic()
        with self.lock:
            for key in list(self.entries):
                entry = self.entries[key]
                if entry['event'].is_set() and now-entry['created'] > self.ttl:
                    del self.entries[key]
            entry = self.entries.get(identity)
            if entry:
                if entry['fingerprint'] != fingerprint:
                    raise APIError('request_id_conflict',409)
                owner = False
            else:
                while len(self.entries) >= self.cache_size:
                    completed = next((k for k,v in self.entries.items() if v['event'].is_set()),None)
                    if completed is None:
                        return self.fallback(req,'server_busy')
                    del self.entries[completed]
                entry = dict(fingerprint=fingerprint,event=threading.Event(),created=now,response=None)
                self.entries[identity] = entry
                owner = True
        if owner:
            try:
                entry['response'] = self.generate(req)
            except Exception:
                entry['response'] = self.fallback(req,'generation_error')
            finally:
                entry['event'].set()
        elif not entry['event'].wait(timeout=self.deadline+2):
            return self.fallback(req,'deadline')
        result = copy.deepcopy(entry['response'])
        result['requestId'] = req['requestId']
        return result


class ConversationHTTPServer(ThreadingHTTPServer):
    daemon_threads = True
    def __init__(self, address, service, *, access_token=''):
        self.service, self.access_token = service, access_token
        super().__init__(address, Handler)
    def get_request(self):
        connection, address = super().get_request()
        connection.settimeout(10)
        return connection, address


class Handler(BaseHTTPRequestHandler):
    server_version = 'JEV'
    def log_message(self, *_):
        pass  # Do not persist question/history or arbitrary user-controlled request lines.

    def send_json(self, status, value):
        data = json.dumps(value,ensure_ascii=False).encode()
        try:
            self.send_response(status)
            self.send_header('Content-Type','application/json; charset=utf-8')
            self.send_header('Content-Length',str(len(data)))
            self.send_header('Cache-Control','no-store')
            self.send_header('X-Content-Type-Options','nosniff')
            self.end_headers()
            self.wfile.write(data)
        except (BrokenPipeError, ConnectionResetError, TimeoutError):
            pass

    def authorized(self):
        token = self.server.access_token
        return not token or hmac.compare_digest(self.headers.get('Authorization',''), 'Bearer '+token)

    def do_GET(self):
        if self.path != '/health':
            return self.send_json(404,{'error':{'code':'not_found','retryable':False}})
        self.send_json(200,dict(status='ok',providerConfigured=self.server.service.ready,
                               catalogVersion=self.server.service.bundle['catalogVersion']))

    def do_POST(self):
        request_id = None
        try:
            if self.path != '/v2/readings':raise APIError('not_found',404)
            if not self.authorized():raise APIError('unauthorized',401)
            if self.headers.get('Transfer-Encoding'):raise APIError('invalid_input')
            lengths = self.headers.get_all('Content-Length',[])
            if len(lengths)!=1 or not lengths[0].isdigit():raise APIError('length_required',411)
            length = int(lengths[0])
            if not 0<length<=MAX_BODY:raise APIError('request_too_large',413)
            if self.headers.get_content_type()!='application/json':raise APIError('unsupported_media_type',415)
            raw = self.rfile.read(length)
            if len(raw)!=length:raise APIError('invalid_input')
            body = json.loads(raw.decode('utf-8'))
            if isinstance(body,dict) and isinstance(body.get('requestId'),str):
                try:request_id=str(uuid.UUID(body['requestId']))
                except ValueError:pass
            self.send_json(200,self.server.service.reading(body))
        except APIError as e:
            self.send_json(e.status,dict(requestId=request_id,error=dict(code=e.code,retryable=False)))
        except (ValueError,UnicodeError,TimeoutError):
            self.send_json(400,dict(requestId=request_id,error=dict(code='invalid_input',retryable=False)))


def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('--host',default='127.0.0.1');parser.add_argument('--port',type=int,default=8443)
    parser.add_argument('--tls-cert');parser.add_argument('--tls-key')
    parser.add_argument('--deadline',type=float,default=120)
    args=parser.parse_args()
    if not 1<=args.deadline<=120:parser.error('deadline must be between 1 and 120 seconds')
    token=os.environ.get('JEV_SERVICE_TOKEN','')
    try:local=ipaddress.ip_address(args.host).is_loopback
    except ValueError:local=args.host=='localhost'
    if not local and not token:parser.error('Non-loopback binding requires JEV_SERVICE_TOKEN')
    if bool(args.tls_cert)!=bool(args.tls_key):parser.error('Both TLS certificate and key are required')
    server=ConversationHTTPServer((args.host,args.port),ConversationService(deadline=args.deadline),access_token=token)
    scheme='http'
    if args.tls_cert:
        context=ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
        context.minimum_version=ssl.TLSVersion.TLSv1_2
        context.load_cert_chain(args.tls_cert,args.tls_key)
        server.socket=context.wrap_socket(server.socket,server_side=True);scheme='https'
    print(f'JEV conversation service: {scheme}://{args.host}:{server.server_port}; provider configured={server.service.ready}',flush=True)
    try:server.serve_forever()
    except KeyboardInterrupt:pass
    finally:server.server_close()

if __name__=='__main__':main()
