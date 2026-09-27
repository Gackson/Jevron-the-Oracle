"""TypeSafe transport and strict response validation shared by the language lab."""
import hashlib,json,math,os,queue,threading
from pathlib import Path
from urllib import error,request
ROOT=Path(__file__).resolve().parent
PROJECT=ROOT.parents[1]

def digest(value):
    return hashlib.sha256(json.dumps(value, sort_keys=True, ensure_ascii=False).encode()).hexdigest()

def validate_answer(response, payload):
    if not isinstance(response,dict) or response.get("model") != payload["model"]:
        raise ValueError("invalid_model_output")
    answers=response.get("answers")
    if not isinstance(answers,dict) or set(answers)!={"nextFragment"}:
        raise ValueError("invalid_model_output")
    a=answers["nextFragment"]
    if not isinstance(a,dict) or a.get("type")!="choice":
        raise ValueError("invalid_model_output")
    ps=a.get("probabilities")
    criteria=payload["questions"]["nextFragment"]["criteria"]
    def prob(x):
        return type(x) in (int,float) and math.isfinite(x) and 0<=x<=1
    if not isinstance(ps,dict) or set(ps)!=set(criteria) or not all(prob(p) for p in ps.values()):
        raise ValueError("invalid_model_output")
    if not prob(a.get("confidence")) or not math.isclose(sum(ps.values()),1,abs_tol=.02):
        raise ValueError("invalid_model_output")
    chosen=a.get("choice")
    if not isinstance(chosen,str) or chosen not in criteria or ps[chosen] < max(ps.values())-1e-8:
        raise ValueError("invalid_model_output")
    return a

class NoRedirect(request.HTTPRedirectHandler):
    def redirect_request(self,*args,**kwargs):
        return None

class ProviderFailure(Exception):
    pass

def http_call(token, payload, timeout):
    req=request.Request("https://api.typesafe.ai/v1/systemone",data=json.dumps(payload).encode(),
                        headers={"Authorization":"Bearer "+token,"Content-Type":"application/json"},method="POST")
    try:
        with request.build_opener(NoRedirect).open(req,timeout=timeout) as response:
            raw=response.read(2_000_001)
            if len(raw)>2_000_000:
                raise ProviderFailure("response_too_large")
            return json.loads(raw)
    except error.HTTPError as e:
        raise ProviderFailure("http_"+str(e.code)) from None
    except (error.URLError,OSError,ValueError):
        raise ProviderFailure("transport_error") from None

def bounded_call(call, payload, timeout):
    """Application deadline; a timed-out in-flight provider operation may still incur cost."""
    result=queue.Queue(maxsize=1)
    def worker():
        try:
            result.put((True,call(payload,timeout)))
        except Exception as e:
            result.put((False,e))
    threading.Thread(target=worker,daemon=True).start()
    try:
        ok,value=result.get(timeout=timeout)
    except queue.Empty:
        raise TimeoutError from None
    if not ok:
        raise value
    return value

def token_from_env():
    token=os.environ.get("TYPESAFE_API_KEY")
    if not token:
        path=PROJECT/".env"
        for line in path.read_text().splitlines():
            if line.startswith("TYPESAFE_API_KEY="):
                token=line.split("=",1)[1].strip().strip("\"'")
    if not token:
        raise SystemExit("TYPESAFE_API_KEY is not configured")
    return token
