import json,html,hashlib
from pathlib import Path
from collections import Counter
root=Path(__file__).resolve().parents[2]
source=root/'ios/JEV/Resources/Language/runtime.json'
b=json.loads(source.read_text())
labels=dict(zip(b['semantics'],['开始行动','完美主义','修复问题','放下控制','表达需求','休息恢复','重复模式','耐心等待','建立边界','寻求认可','失去与结束','问题尚不清楚','取舍与选择','变化与转型','信任与证据','冲突与沟通','归属与联结','比较与羡慕','意义与方向','玩心与创造','成功之后','挫败之后','感激与接受','未知与不确定','危险与求助','奇怪输入与闲聊']))
groups={'function':'功能词','image':'意象与概念','verb':'动作与动词','quality':'性质与修饰','chunk':'其他表达','punctuation':'标点','control':'结束控制'}
notes={
'oracle':'温暖、敏锐的短答。每次从完整回答中选一条，不进行逐词拼接。',
'fool':'一本正经的荒诞对话。以鹅、土豆、烤面包机等日常怪角色，配合审计、杂耍、讨价还价等动作；一次维持一个可理解的场景，不追求 Jester 式说教或反讽。',
'stone':'克制、耐心、非个人化的碑文语言。英文有 hath、doth、abideth 等古雅风味；中文用若、则、之、犹等文言表达，以物写理。',
'jester':'可读、机敏的对话语言。先回应真实的关系、欲望或选择，以反问、对照或一个有用的比喻揭示矛盾；不靠连续堆叠抽象意象制造神秘感。'}
meta={'date':'2026-09-27','version':b['catalogs']['oracle']['catalogVersion'],'model':b['model'],'promptVersion':b['promptVersion'],'source':'ios/JEV/Resources/Language/runtime.json','sha256':hashlib.sha256(source.read_bytes()).hexdigest()}
review={'meta':meta,'labels':labels,'groups':groups,'notes':notes,'semantics':b['semantics'],'catalogs':b['catalogs'],'localizations':b.get('localizations',{})}
# Public content only; omit grammar implementation from the review snapshot.
for c in [c for catalogs in [review['catalogs']]+[v['catalogs'] for v in review['localizations'].values()] for c in catalogs.values()]:
 for field in ['grammarWords','grammarCategories']:c.pop(field,None)
out=root/'docs/vocabulary'
(out/'current-vocabulary.json').write_text(json.dumps(review,ensure_ascii=False,indent=2)+'\n')
md=['# JEV 当前词库 · 审阅版','',f'整理日期：{meta["date"]}。APP 资源版本：`{meta["version"]}`；提示版本：`{meta["promptVersion"]}`。','',
'本文件整理的是当前 APP 内实际使用的内容，没有扩词、改写或替换候选。本页列出英文词库；中文独立词库见 [中文词库](chinese-vocabulary.md)，HTML 可切换中英文。','',
'| 角色 | 候选组成 | 生成方式 | 单次回复边界 |','|---|---|---|---|',
'| Oracle | 255 条完整短答，26 类情境 | 1 次选择 | 选中即结束 |',
'| Stela | 249 单词 + 5 标点 + END | 意图选择 → 逐词选择 | 最多 32 次选择、22 个词 |',
'| Jester | 249 单词 + 5 标点 + END | 意图选择 → 逐词选择 | 最多 42 次选择、30 个词 |',
'| Fool | 249 单词 + 5 标点 + END | 意图选择 → 逐词选择 | 最多 34 次选择、24 个词 |','',
'这里的 255 是当前候选条目数，不是四个角色各有 255 个自然语言单词。逐词角色每步还会筛掉不符合语法和重复限制的候选，实际参与选择的数量会更少。','',
'## 如何读隐性编码','',
'- Oracle：26 类情境各定义 meaning（含义）、useWhen（适用）、avoidWhen（避用）、contrast（与相邻情境的区别）。同一情境下的完整回复共用这组编码，目前不是每句独有的编码。',
'- Stela / Jester / Fool：先选择同一套 26 类表达意图，再为每个候选词提供 meaning 和当前句子的 resultingPrefix。semanticCodes 主要是 function / image / verb 等分类，并非每个词都直接映射到某个情境。',
'- 中文 Fool 与 Stela 的全部意象已逐项补入场景角色、可指代的处境与适用边界；英文同步细化一批对应意象。它们是可能的联系，不是固定暗号或对用户的诊断。其余词保留原有编码。',
'- 分类按候选中实际登记的主标签统计，不是穷尽词性。重复词只占一个候选位；如 light 可有多种语法用途。','',
'## 当前效果边界','', '意象关系的新编码与六条真实请求失败记录见 [意象关系修订与实测](../verification/image-relations-2026-09-27.md)。本地验证通过不代表真实回答质量验收通过。','',
'Fool 的真实样本、收句修订和已知不足见 [The Fool 第一版说明](the-fool.md)，示范句与实际模型输出分别标注。','',
'词库整理完成不等于内容质量验收通过。Jester 针对感情问题修正了短句收尾冲突、补入关系词，并区分生成失败与连接失败。实测原文、失败记录和限制见 [Jester 回归](../verification/jester-2026-09-27.md)。旧版三角色联调记录仍保留供比较。','',
'所有合法提问都没有 no_match 分支。总预算 120 秒、单请求最多 25 秒；限制同词连发与周期重复。故障时使用文末的角色保底回复，不能把这些回复计作模型生成成功。','']
def encoding(c):
 return '；'.join(label+'：'+('；'.join(c[key]) if isinstance(c[key],list) else c[key]) for key,label in [('meaning','含义 / 场景角色'),('useWhen','可指代 / 适用'),('avoidWhen','边界')] if c.get(key))

def clean(s):return str(s).replace('|','\\|').replace('\n',' ')
for role,c in b['catalogs'].items():
 md+=['## '+c.get('displayName',role.capitalize()),'',notes[role],'']
 if role=='oracle':
  for code,semantic in b['semantics'].items():
   rows=[x for x in c['candidates'] if code in x['semanticCodes']]
   md += [f'### {labels[code]} · {code} · {len(rows)} 条','']
   for field,cn in [('meaning','含义'),('useWhen','适用'),('avoidWhen','避用'),('contrast','区别')]:md += [f'- **{cn}**：{semantic[field]}']
   md+=['','| ID | 完整回复 |','|---|---|']
   md += [f'| {x["id"]} | {clean(x["text"])} |' for x in rows]
   md+=['']
 else:
  counts=Counter(x['semanticCodes'][0] for x in c['candidates'])
  md+=['分类：'+'；'.join(f'{groups[k]} {v}' for k,v in counts.items())+'。','']
  for category in ['image','verb','quality','function','chunk','punctuation','control']:
   rows=[x for x in c['candidates'] if category in x['semanticCodes']]
   if not rows:continue
   md += [f'### {groups[category]} · {len(rows)} 项','','| 词 / 控制项 | 实际隐性编码 |','|---|---|']
   md += [f'| `{x["text"] or "END（不输出文本）"}` | {clean(encoding(x))} |' for x in rows]
   md+=['']
md+=['## 故障时的角色保底回复','','这些句子不占上面的 255 个候选位，只在无法完成真实生成时使用，并带有 authored_fallback 来源标记。','']
for role,c in b['catalogs'].items():md += [f'- **{role.capitalize()}**：{c["fallback"]}']
md += ['','## 来源核对','',f'- APP 源：`{meta["source"]}`',f'- 源文件 SHA-256：`{meta["sha256"]}`','- [可检索浏览版](current-vocabulary.html)','- [结构化审阅快照](current-vocabulary.json)','']
(out/'current-vocabulary.md').write_text('\n'.join(md))
page='''<!doctype html><html lang="zh-CN"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>JEV · 当前词库</title>
<style>
:root{font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif;color:#252b28;background:#f5f4ef;line-height:1.6}*{box-sizing:border-box}body{margin:0}main{max-width:1120px;margin:auto;padding:42px 26px 80px}header{border-bottom:1px solid #d7dbd2;padding-bottom:25px}.eyebrow{font-size:12px;letter-spacing:.17em;color:#647368}h1{font-size:38px;line-height:1.2;margin:10px 0 18px;font-weight:600}p{margin:10px 0}.muted{color:#68746d;font-size:14px}.toolbar{position:sticky;top:0;z-index:2;background:#f5f4efee;backdrop-filter:blur(12px);padding:18px 0;border-bottom:1px solid #d7dbd2}.tabs{display:flex;gap:8px;flex-wrap:wrap;margin-bottom:12px}button,input,select{font:inherit}button{cursor:pointer;padding:9px 20px;border:1px solid #c8cec5;border-radius:30px;background:transparent;color:#344438}button[aria-pressed=true]{background:#344d40;color:#fff;border-color:#344d40}.search{display:flex;gap:10px}input,select{border:1px solid #c8cec5;border-radius:8px;padding:11px;background:white;color:#27392c}input{flex:1;min-width:0}select{max-width:40%}.intro{padding:22px 0 8px}.count{font-variant-numeric:tabular-nums;font-size:14px;color:#647368}.section{margin:24px 0 30px}.section h2{font-size:20px;margin:0 0 10px}.semantic{font-size:14px;color:#526358;border-left:2px solid #9cad9d;padding-left:14px;margin:12px 0 16px}.grid{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:10px}.grid.words{grid-template-columns:repeat(4,minmax(0,1fr))}details.card{background:#fff;border:1px solid #e0e4da;border-radius:10px;align-self:start;overflow:hidden}summary{cursor:pointer;padding:14px 16px;list-style:none}summary::-webkit-details-marker{display:none}.text{font-family:Georgia,serif;font-size:19px;line-height:1.5}.words .text{font-size:22px}.id{font-size:11px;display:block;margin-top:6px;color:#7e887e;overflow-wrap:anywhere}.encoding{padding:0 16px 15px;font-size:13px;border-top:1px solid #edf0e8;overflow-wrap:anywhere}.encoding strong{display:block;color:#6b786d;margin-top:10px;font-weight:500}.notice{margin-top:32px;padding:18px 20px;background:#eaf0e7;border-radius:10px;font-size:14px}.notes{padding-top:25px;font-size:14px}a{color:#42694d}code{font-size:12px}.empty{padding:40px;color:#68746d}@media(max-width:760px){main{padding:24px 16px 50px}h1{font-size:30px}.grid{grid-template-columns:1fr}.grid.words{grid-template-columns:repeat(2,minmax(0,1fr))}.search{flex-wrap:wrap}select{max-width:100%}}
</style><main><header><div class="eyebrow">JEV / VOCABULARY REVIEW / 2026.09.27</div><h1>四个角色，一份当前词库</h1><p>按 APP 实际资源整理。英文与简体中文各有独立词库。保留全部候选与实际隐性编码，可切换语言查看。</p><div class="muted">版本 <span id="version"></span> · 每种语言 1020 个角色候选位 · 点开任意条目查看编码</div></header>
<div class="toolbar"><div class="tabs" role="group" aria-label="选择角色"><button data-role="oracle" aria-pressed="true">Oracle · 255 条短答</button><button data-role="stone" aria-pressed="false">Stela · 249 个词</button><button data-role="jester" aria-pressed="false">Jester · 249 个词</button><button data-role="fool" aria-pressed="false">Fool · 249 个词</button></div><div class="search"><select id="language" aria-label="词库语言"><option value="en">English</option><option value="zh-Hans">简体中文</option></select><input id="search" type="search" placeholder="搜索词、句子、编码或中文分类…" aria-label="搜索词库"><select id="category" aria-label="筛选分类"></select></div></div>
<section class="intro"><p id="description"></p><div id="counts" class="count"></div></section><div id="results"></div>
<div class="notice"><strong>保底回复 · 不占候选位</strong><p id="fallback"></p><span class="muted">仅在网络、校验、超时或组句失败时使用，标记 authored_fallback。它不是模型生成成功的证据。</span></div>
<section class="notes"><details><summary>如何理解这份词库与隐性编码</summary><p>Oracle 有 26 类情境：25 类各 10 条，strange 类 5 条。同类回复共用 meaning / useWhen / avoidWhen / contrast，目前不是每句分别定制的编码。</p><p>Stela、Jester 和 Fool 各有 249 个单词、5 个标点和 1 个 END。先选择同一套 26 类表达意图，再逐词选择；每步还结合已经生成的完整前缀，并筛掉不合法的语法接法和重复。每个词的主标签不代表全部词性。</p><p>中文 Fool 与 Stela 的全部意象已补齐场景角色、可指代的处境与适用边界；英文同步细化一批对应意象。指代关系是可能性，不是固定暗号，其余词保留原有编码。容量已用满不代表这些词都已被真实输出使用。Stela 最多 32 次选择、22 个词；Jester 最多 42 次选择、30 个词；Fool 最多 34 次选择、24 个词；总时限 120 秒。</p><p>没有 no_match 控制项。Jester 已修正短句收尾冲突并补入关系词；生成失败、超时与网络失败分别标记。真实输出与限制见 Jester 回归记录。Fool 的样本与收句修订见 The Fool 第一版说明；各角色仍需更广泛的质量评测。</p></details><p><a href="../verification/image-relations-2026-09-27.md">意象关系修订与实测</a> · <a href="../verification/jester-2026-09-27.md">Jester 回归</a> · <a href="the-fool.md">The Fool 第一版说明</a> · <a href="current-vocabulary.md">英文 Markdown</a> · <a href="chinese-vocabulary.md">中文 Markdown</a> · <a href="current-vocabulary.json">结构化快照</a> · <a href="../verification/direct-jev-2026-09-27.md">实测记录</a></p><div class="muted" id="source"></div></section></main>
<script id="data" type="application/json">__DATA__</script><script>
const d=JSON.parse(document.getElementById('data').textContent);let role='oracle',locale='en';function catalogSet(){return locale==='en'?d.catalogs:d.localizations[locale].catalogs}const $=id=>document.getElementById(id);
function el(tag,text,cls){const e=document.createElement(tag);if(text!==undefined)e.textContent=text;if(cls)e.className=cls;return e}
function labels(){return role==='oracle'?d.labels:d.groups}
function categories(){return role==='oracle'?Object.keys(d.semantics):['image','verb','quality','function','chunk','punctuation','control'].filter(k=>catalogSet()[role].candidates.some(c=>c.semanticCodes.includes(k)))}
function reset(){ $('category').replaceChildren(el('option','全部分类'));$('category').firstChild.value='';categories().forEach(k=>{const o=el('option',labels()[k]);o.value=k;$('category').append(o)});render() }
function render(){const cat=catalogSet()[role],q=$('search').value.trim().toLowerCase(),filter=$('category').value;const rows=cat.candidates.filter(c=>(!filter||c.semanticCodes.includes(filter))&&(!q||(JSON.stringify(c)+' '+c.semanticCodes.map(k=>labels()[k]).join(' ')).toLowerCase().includes(q)));$('description').textContent=d.notes[role];$('counts').textContent=`显示 ${rows.length} / ${cat.candidates.length} 项 · ${role==='oracle'?'每次选择一条完整回复':'逐词选择；含 5 个标点和 1 个 END'}`;$('fallback').textContent=cat.fallback;$('results').replaceChildren();
for(const k of categories()){const items=rows.filter(c=>c.semanticCodes.includes(k));if(!items.length)continue;const section=el('section',undefined,'section');section.append(el('h2',`${labels()[k]} · ${items.length}`));if(role==='oracle'){const s=d.semantics[k];section.append(el('div',s.meaning,'semantic'))}const grid=el('div',undefined,'grid'+(role==='oracle'?'':' words'));for(const c of items){const card=el('details',undefined,'card'),sum=el('summary');sum.append(el('span',c.text||'END','text'),el('span',c.id+(c.kind==='end'?' · 不输出文本':''),'id'));const enc=el('div',undefined,'encoding');for(const [field,name] of [['meaning','含义 / 场景角色'],['useWhen','可指代 / 适用'],['avoidWhen','避用'],['contrast','相邻情境区别']])if(c[field]){enc.append(el('strong',name),el('div',Array.isArray(c[field])?c[field].join(' '):c[field]))}enc.append(el('strong','编码标签'),el('code',c.semanticCodes.join(', ')));card.append(sum,enc);grid.append(card)}section.append(grid);$('results').append(section)}if(!rows.length)$('results').append(el('p','没有符合这个检索条件的条目。清空搜索可看完整词库。','empty'))}
document.querySelectorAll('[data-role]').forEach(btn=>btn.addEventListener('click',()=>{role=btn.dataset.role;document.querySelectorAll('[data-role]').forEach(b=>b.setAttribute('aria-pressed',String(b===btn)));reset()}));$('language').addEventListener('change',()=>{locale=$('language').value;reset()});$('search').addEventListener('input',render);$('category').addEventListener('change',render);$('version').textContent=d.meta.version;$('source').textContent='来源：'+d.meta.source+' · 这是审阅快照，不会修改 APP。';reset();
</script></html>'''
(out/'current-vocabulary.html').write_text(page.replace('__DATA__',json.dumps(review,ensure_ascii=False).replace('<','\\u003c')))
print('Created HTML, Markdown and JSON review files.')
print({role:len(c['candidates']) for role,c in review['catalogs'].items()})

zh=['# 中文回答模式 · 词库审阅','',f'资源版本：`{meta["version"]}`。四个角色各255个候选，不是英文回答的运行时翻译。','',
    'Oracle 采用完整短答；其余角色按中文词逐步选择、以中文语法约束闭合。石碑偏文言，Jester 与 Fool 保持现代口语。','',
    '这是词库记录，不是语言质量验收；真实输出与边界见 [中文实测](../verification/chinese-stela-2026-09-27.md)。','']
for role,cat in review['localizations']['zh-Hans']['catalogs'].items():
 zh += ['## '+cat['displayName'],'',cat['instructions'],'','| 词 / 回答 | 编码 |','|---|---|']
 for c in cat['candidates']:zh.append('| '+clean(c['text'] or 'END（结束，不输出文字）')+' | '+clean(encoding(c))+' |')
 zh += ['','备用回复：'+cat['fallback'],'']
(out/'chinese-vocabulary.md').write_text('\n'.join(zh)+'\n')
