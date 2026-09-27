import concurrent.futures
import http.client
import json
import threading
import time
import unittest
import uuid
from server.app import APIError, ConversationService, ConversationHTTPServer, validate_request


def request(role='oracle'):
    return dict(requestId=str(uuid.uuid4()), characterId=role, question='Should I begin?', locale='en', history=[])


def response(p, key):
    choices = p['questions']['nextFragment']['criteria']
    return dict(model=p['model'], answers={'nextFragment': dict(type='choice', choice=key, confidence=1,
        probabilities={k: float(k == key) for k in choices})})


class ConversationAPITests(unittest.TestCase):
    def test_generated_reply_history_and_punctuation_for_all_roles(self):
        sentences = {'stone': ['the','stone','holds','a','small','trace','.',''],
                     'fool': ['your','plan','wears','a','tiny','helmet','.',''],
                     'jester': ['your','fear','hires','a','lawyer','to','keep','the','door','closed','.','']}
        for role in ('oracle','stone','jester','fool'):
            with self.subTest(role=role):
                seen = []
                words = iter(sentences.get(role, []))
                def call(p, timeout):
                    seen.append(p)
                    choices = p['questions']['nextFragment']['criteria']
                    if role == 'oracle': key = next(iter(choices))
                    elif 'reply_so_far' not in p['state']: key = 'begin'
                    else:
                        word = next(words)
                        key = next(k for k,v in choices.items() if v['text'] == word)
                    return response(p,key)
                req = request(role)
                req['history'] = [dict(question='What is holding me back?', answer='An old fear.')]
                result = ConversationService(call=call).reading(req)
                self.assertEqual(result['origin'],'jev',result)
                self.assertEqual(result['generationStatus'],'complete')
                self.assertEqual(len(result['segments']),1)
                self.assertNotIn(' .',result['segments'][0]['text'])
                self.assertTrue(all(p['state']['history']==req['history'] for p in seen))
                self.assertNotIn('steps',result)
                self.assertNotIn('history',result)
                if role == 'jester': self.assertEqual(result['segments'][0]['text'],'Your fear hires a lawyer to keep the door closed.')

    def test_chinese_locale_routes_to_chinese_reply_and_fallback(self):
        req=request();req['locale']='zh-Hans'
        service=ConversationService(call=lambda p,t:response(p,next(iter(p['questions']['nextFragment']['criteria']))))
        reply=service.reading(req)
        self.assertEqual(reply['origin'],'jev')
        self.assertEqual(reply['segments'][0]['text'],'开始，并不等于承诺完成一切。')
        for role in ('oracle','stone','jester','fool'):
            req=request(role);req['locale']='zh-Hans'
            fallback=ConversationService(key='').reading(req)
            self.assertEqual(fallback['origin'],'authored_fallback')
            self.assertTrue(any('\u3400' <= c <= '\u9fff' for c in fallback['segments'][0]['text']))

    def test_unavailable_provider_has_distinct_honest_character_replies(self):
        service = ConversationService(key='')
        replies = [service.reading(request(role)) for role in ('oracle','stone','jester','fool')]
        self.assertEqual(len({r['segments'][0]['text'] for r in replies}),4)
        for r in replies:
            self.assertEqual((r['origin'],r['generationStatus'],r['stopReason']),('authored_fallback','failed','fallback_complete'))
            self.assertNotIn('no_match',json.dumps(r))

    def test_deadline_and_busy_are_bounded_replies(self):
        def slow(p,t): time.sleep(.1)
        service = ConversationService(call=slow,deadline=.01)
        start = time.monotonic()
        self.assertEqual(service.reading(request())['origin'],'authored_fallback')
        self.assertLess(time.monotonic()-start,.09)
        service.capacity.acquire(); service.capacity.acquire()
        self.assertEqual(service.reading(request())['generationStopReason'],'server_busy')
        service.capacity.release(); service.capacity.release()

    def test_duplicate_concurrent_requests_generate_once_and_conflicts_rejected(self):
        calls = []
        def call(p,t):
            calls.append(p); time.sleep(.02)
            return response(p,next(iter(p['questions']['nextFragment']['criteria'])))
        service = ConversationService(call=call)
        req = request()
        with concurrent.futures.ThreadPoolExecutor(4) as pool:
            results = list(pool.map(service.reading,[req]*4))
        self.assertEqual(len(calls),1)
        self.assertTrue(all(r == results[0] for r in results))
        with self.assertRaises(APIError) as ctx: service.reading(dict(req,question='A different question'))
        self.assertEqual(ctx.exception.status,409)

    def test_request_validation_prevents_overrides_and_limits_context(self):
        for change in ({'question':' '},{'question':'x'*501},{'question':'\ud800'}, {'characterId':'other'},
                       {'locale':'zh'},{'requestId':'nope'},{'model':'override'},
                       {'history':[dict(question='Q',answer='A')]*7}, {'history':[dict(question='Q',answer='x'*1501)]}):
            with self.subTest(change=list(change)):
                with self.assertRaises(APIError): validate_request(dict(request(),**change))
        self.assertEqual(len(validate_request(dict(request(),question='é'*500))['question']),500)

    def test_response_cache_is_bounded_and_does_not_keep_raw_questions(self):
        service = ConversationService(key='',cache_size=2)
        for _ in range(5): service.reading(request())
        self.assertEqual(len(service.entries),2)
        self.assertNotIn('Should I begin?',repr(service.entries))

    def test_http_route_auth_and_json_contract(self):
        server = ConversationHTTPServer(('127.0.0.1',0),ConversationService(key=''),access_token='test-service-token')
        thread = threading.Thread(target=server.serve_forever,daemon=True); thread.start()
        try:
            conn = http.client.HTTPConnection('127.0.0.1',server.server_port,timeout=2)
            conn.request('GET','/health'); r=conn.getresponse()
            self.assertEqual(r.status,200); self.assertFalse(json.loads(r.read())['providerConfigured'])
            body = json.dumps(request())
            conn.request('POST','/v2/readings',body,{'Content-Type':'application/json'})
            r=conn.getresponse(); self.assertEqual(r.status,401); r.read()
            conn.request('POST','/v2/readings',body,{'Content-Type':'application/json','Authorization':'Bearer test-service-token'})
            r=conn.getresponse(); self.assertEqual(r.status,200)
            self.assertEqual(r.getheader('Cache-Control'),'no-store')
            self.assertEqual(json.loads(r.read())['origin'],'authored_fallback')
            conn.close()
        finally:
            server.shutdown(); server.server_close(); thread.join()

if __name__ == '__main__': unittest.main()
