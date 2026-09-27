/* Bundled, offline composition rules. Only candidate selection uses the network. */
var JEV = (function () {
  var cfg, cat, selected, req, intent, calls, planPending, grammar;
  var punct = new Set(['.', ',', '?', ';', ':']), final = new Set(['.', '?']);
  function initialize(json, requestJSON) {
    cfg = JSON.parse(json); req = JSON.parse(requestJSON);
    var locale=req.locale || 'en';
    var catalogs=locale==='en' ? cfg.catalogs : (cfg.localizations[locale] || {}).catalogs;
    if(!catalogs) throw Error('unsupported_locale');
    cat = catalogs[req.characterId];
    if (!cat || cat.candidates.length !== 255) throw Error('invalid_catalog');
    punct=new Set(cat.candidates.filter(function(c) {return c.kind==='punctuation';}).map(function(c) {return c.text;}));
    final=new Set(cat.locale==='zh-Hans' ? ['。','？'] : ['.','?']);
    selected = []; intent = null; calls = 0; planPending = cat.mode === 'word_sequence';
    grammar = cat.mode === 'word_sequence' ? makeGrammar(cat) : null;
  }
  function render(items) {
    if(cat.locale==='zh-Hans') return items.filter(function(c) {return c.kind!=='end';}).map(function(c) {return c.text;}).join('');
    var out = '';
    items.forEach(function(c) {
      if (c.kind === 'end') return;
      if (c.kind === 'punctuation') out = out.trimEnd() + c.text;
      else { var t = c.text; if (!out || /[.?]$/.test(out)) t = t[0].toUpperCase() + t.slice(1); out += (out ? ' ' : '') + t; }
    }); return out;
  }
  function makeGrammar(c) {
    var rules = Object.assign({}, cfg.rules, c.grammarOverrides || {}), words = new Set(c.grammarWords), cats = c.grammarCategories, minimum = {};
    Object.keys(rules).forEach(function(s) { minimum[s] = 999; });
    function cost(s) { return rules[s] ? minimum[s] : s[0] === '<' ? ((cats[s.slice(1,-1)] || []).length ? 1 : 999) : words.has(s) || punct.has(s) ? 1 : 999; }
    function sum(stack) { return stack.reduce(function(v,s) { return v + cost(s); },0); }
    for (var i=0;i<30;i++) {
      var changed=false;
      Object.keys(rules).forEach(function(s) { var n=Math.min.apply(null,rules[s].map(sum)); if(n<minimum[s]) { minimum[s]=n; changed=true; } });
      if(!changed) break;
    }
    function matches(s,t) { return s[0] === '<' ? (cats[s.slice(1,-1)] || []).indexOf(t)>=0 : s===t; }
    function expand(states,remaining) {
      var todo=states.slice(), seen=new Set(), out=[];
      while(todo.length) {
        var stack=todo.pop(), key=JSON.stringify(stack);
        if(seen.has(key) || sum(stack)>remaining) continue;
        seen.add(key);
        if(!stack.length || !rules[stack[0]]) { out.push(stack); continue; }
        rules[stack[0]].forEach(function(rhs) { todo.push(rhs.concat(stack.slice(1))); });
      } return out;
    }
    return {
      states: function(tokens,budget) {
        var states=[['S']];
        tokens.forEach(function(t,i) { states=expand(states,budget-i).filter(function(s) { return s.length && matches(s[0],t); }).map(function(s) { return s.slice(1); }); });
        return expand(states,budget-tokens.length);
      },
      accepts: function(states,t,remaining) { return states.some(function(s) { return s.length && matches(s[0],t) && sum(s.slice(1))<=remaining-1; }); }
    };
  }
  function cycle(texts) {
    for(var n=1;n<=4;n++) if(texts.length>=2*n && JSON.stringify(texts.slice(-n))===JSON.stringify(texts.slice(-2*n,-n))) return true;
    return false;
  }
  function options() {
    var max=cat.maxSelections-(cat.mode==='word_sequence'?1:0);
    if(selected.length>=max || (selected.length && selected[selected.length-1].terminal)) return [];
    if(cat.mode==='whole_reply') return selected.length ? [] : cat.candidates;
    var texts=selected.map(function(c) { return c.text; }), states=grammar.states(texts,max-1);
    var count=selected.filter(function(c) { return c.kind==='word'; }).length;
    var last=texts[texts.length-1], end=states.some(function(s) { return !s.length; }) && final.has(last);
    var sentences=texts.filter(function(t) { return final.has(t); }).length;
    var canPunct=texts.length && !punct.has(last), remaining=max-selected.length;
    var opposites=['open closed','empty full','old new','big small','quiet loud','real imaginary','rough smooth','heavy light'];
    return cat.candidates.filter(function(c) {
      var t=c.text;
      if(c.kind==='end') return end;
      if(!grammar.accepts(states,t,remaining-1)) return false;
      if(end && (sentences>=(cat.maxSentences || 2) || count>=cat.maxWords || remaining<=2)) return false;
      if((remaining<=2 || count>=cat.maxWords) && !(final.has(t) && canPunct)) return false;
      if(c.kind==='punctuation') { if(!canPunct) return false; }
      else {
        if(count+1>cat.maxWords) return false;
        if(texts.filter(function(x) { return x===t; }).length >= ((cat.functionWords || cfg.functionWords).indexOf(t)>=0 ? 4:(cat.contentRepeatLimit || 2))) return false;
      }
      if((last==='a' || last==='an') && c.kind==='word' && (last==='an') !== /^[aeiou]/i.test(t)) return false;
      if(opposites.some(function(pair) { var a=pair.split(' ');return (a[0]===last && a[1]===t)||(a[1]===last && a[0]===t); })) return false;
      return !cycle(texts.concat([t]));
    });
  }
  function next() {
    if(selected.length && selected[selected.length-1].terminal) return {done:true,text:render(selected),catalogVersion:cat.catalogVersion,calls:calls};
    if(calls>=cat.maxSelections) throw Error('step_limit');
    var state, criteria={}, instructions;
    if(planPending) { state={question:req.question,history:req.history};criteria=cfg.semantics;instructions=cfg.intentPrompt; }
    else {
      var available=options();if(!available.length) throw Error('composition_error');
      available.forEach(function(c) {
        var v={text:c.text}; if(cat.mode==='word_sequence') v.resultingPrefix=render(selected.concat([c]));
        ['meaning','useWhen','avoidWhen','contrast'].forEach(function(k) { if(c[k]!==undefined) v[k]=c[k]; });
        if(c.kind==='end') v.meaning='Finish the already complete reply; add no text.';
        criteria[c.id]=v;
      });
      state={question:req.question,history:req.history,reply_so_far:render(selected),selected:selected.map(function(c) { return {id:c.id,text:c.text}; }),step:selected.length+1,
        remainingSelections:cat.maxSelections-(cat.mode==='word_sequence'?1:0)-selected.length,communicativeIntent:intent};
      instructions=cat.prompt;
    }
    return {done:false,payload:{model:cfg.model,state:state,questions:{nextFragment:{type:'choice',instructions:instructions,criteria:criteria}}}};
  }
  function accept(raw) {
    var p=next().payload, r, keys=Object.keys(p.questions.nextFragment.criteria);
    try { r=JSON.parse(raw); } catch (_) { throw Error('invalid_model_output'); }
    function probability(x) { return typeof x==='number' && Number.isFinite(x) && x>=0 && x<=1; }
    if(!r || typeof r!=='object' || r.model!==p.model || !r.answers || Object.keys(r.answers).join()!=='nextFragment') throw Error('invalid_model_output');
    var a=r.answers.nextFragment, ps=a && a.probabilities;
    if(!a || typeof a!=='object' || a.type!=='choice' || !ps || Object.keys(ps).length!==keys.length || !keys.every(function(k) { return probability(ps[k]); }) || !probability(a.confidence)) throw Error('invalid_model_output');
    var total=keys.reduce(function(n,k) { return n+ps[k]; },0), maximum=Math.max.apply(null,keys.map(function(k) { return ps[k]; }));
    if(Math.abs(total-1)>.02 || keys.indexOf(a.choice)<0 || ps[a.choice]<maximum-1e-8) throw Error('invalid_model_output');
    calls++;
    if(planPending) { intent=Object.assign({code:a.choice},cfg.semantics[a.choice]);planPending=false; }
    else selected.push(cat.candidates.find(function(c) { return c.id===a.choice; }));
  }
  return {initialize:initialize,next:function() { return JSON.stringify(next()); },accept:accept,
    snapshot:function() { return render(selected); },
    // Deterministic rule parity checks; no network or credentials.
    candidateIDs:function(texts) { selected=texts.map(function(t) { var c=cat.candidates.find(function(c) {return c.text===t;});if(!c) throw Error('unknown_word');return c; });return options().map(function(c) {return c.id;}); }};
})();
