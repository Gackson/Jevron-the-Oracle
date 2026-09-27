"""Build v2's three authored 255-entry catalogs; never pad or truncate to fit."""
import json
from pathlib import Path
if __package__: from .grammar import RULES
else: from grammar import RULES
ROOT=Path(__file__).resolve().parent
VERSION='2026-09-27.relations1'


def sections(file):
    group=None
    for line in (ROOT/file).read_text().splitlines():
        if not line:continue
        if line.startswith('['):group=line[1:-1];continue
        text,_,hint=line.partition('|')
        yield group,text,hint


def build():
    semantics=json.loads((ROOT/'semantics.json').read_text())
    cats={}
    rows=[]
    for i,(code,text,_) in enumerate(sections('oracle-bank.txt')):
        s=semantics[code]
        rows.append(dict(id=f'oracle.{code}.{sum(c["semanticCodes"]==[code] for c in rows)+1:02}',text=text,
                         semanticCodes=[code],meaning=s['meaning'],useWhen=[s['useWhen']],avoidWhen=[s['avoidWhen']],
                         contrast=s['contrast'],kind='reply',terminal=True))
    cats['oracle']=dict(characterId='oracle',mode='whole_reply',minWords=1,maxWords=30,maxSelections=1,
        instructions='Be a warm, perceptive Oracle. Always answer. Select the most fitting complete reply, distinguishing the actual situation from adjacent concerns. For unknowable predictions, strange input or concrete danger, choose the appropriate honest in-character response rather than pretending certainty.',
        fallback='The answer has not reached me. Give me a moment, and ask again.',candidates=rows)
    for char in ('stone','jester','fool'):
        seen={}
        for group,text,hint in list(sections('lexicon-common.txt'))+list(sections('lexicon-'+char+'.txt')):
            if text in seen:
                if hint:seen[text].update(meaning=hint,semanticCodes=[group])
                continue
            meaning=hint or {'function':'Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning.',
                             'punctuation':'Punctuation: use only where the sentence grammar supports it.',
                             'image':f'The concrete image or concept {text!r}; relate it to the question rather than adding decoration.',
                             'verb':f'The action {text!r}; use the correct tense and subject agreement.',
                             'quality':f'The quality {text!r}; qualify the existing image rather than switching topics.',
                             'chunk':f'The expression {text!r}; continue the present clause coherently.'}[group]
            seen[text]=dict(id=text,text=text,semanticCodes=[group],meaning=meaning,
                           kind='punctuation' if group=='punctuation' else 'word',terminal=False)
        units=list(seen.values())
        units.append(dict(id='END',text='',semanticCodes=['control'],meaning='The already-written reply is complete. End without adding any text.',kind='end',terminal=True))
        style=("Speak as The Stela: austere, patient, impersonal, physical. Write a short inscription using a varied sentence shape: statement, contrast, conditional, question or imperative as appropriate. Words may form more than one clause. Keep physical imagery coherent. Use a light archaic English inscription register, with hath, doth and third-person forms such as abideth or beareth when grammatically fitting. Preserve clear meaning and subject agreement; do not imitate scholarly Old English or pile up archaisms. Avoid conventional motivational advice and jokes."
               if char=='stone' else
               "Speak as Jester: conversational, incisive, mischievous, readable. Let one surprising reversal expose a specific tension in the question. Assemble an original sentence one word at a time; you are not choosing a prewritten punchline. Use plain conversational language first. A pointed question or contrast can supply the wit; a personified object is optional. If reasons or feelings are missing, ask one pointed question about the person's own reasons instead of inventing a diagnosis or deciding for them. Wit can contrast a genuine choice with habit, or wanting an answer with wanting permission; present these as questions or possibilities, never as assumed facts. Keep references explicit: avoid vague questions built only from it, that, question and reason. Refer to the actual relationship, desire, work or decision. Avoid circular statements, abstract nouns explaining themselves and arbitrary funny objects. Try varied subjects, verbs, objects, questions, conditions or contrasts. Use at most one metaphor, only when it illuminates the situation. Never mock the person's worth or dismiss actual danger.")
        if char=='fool':
            style=('Speak as The Fool: earnest, friendly and delightfully absurd. Answer the actual question in a simple readable English sentence, one whole word at a time, like a tiny conversational word machine. '+
                   'Prefer one short complete sentence. Finish the joke without explaining it or adding a second sentence. Let one unlikely everyday object do one unexpectedly grand or silly action. Do not merely list unrelated funny words. '+
                   'Prefer concrete playful incongruity over a moral lesson, psychological diagnosis, clever insult or Jester-style satire. Keep the same scene and causal thread. '+
                   'For actual danger or serious decisions, drop the joke and give direct, caring language. Do not invent facts or promise outcomes.')
        cats[char]=dict(characterId=char,mode='word_sequence',minWords=4 if char=='stone' else (3 if char=='fool' else 6),
                        maxWords=22 if char=='stone' else (24 if char=='fool' else 30),maxSelections=32 if char=='stone' else (34 if char=='fool' else 42),
                        instructions=style,fallback=('The echo has not crossed the stone. Ask again.' if char=='stone' else
                        'My thoughts have misplaced their trousers. Let me try again.' if char=='fool' else
                        'My words have missed their cue. Give them another entrance.'),candidates=units)
    cats['stone']['grammarOverrides']={'VPS':RULES['VPS']+[['hath','OBJ','TAIL'],['doth','BASE']]}
    cats['jester']['contentRepeatLimit']=1
    cats['jester']['grammarOverrides']={
        'ADJS':[[],['<ADJ>']],
        'Q':RULES['Q']+[
            ['is','NP','PRED'],['is','NP','PRED','or','PRED'],
            ['are','you','PRED'],['are','you','PRED','or','PRED'],
            ['do','you','<VBT>','OBJ','or','OBJ']],
        'TAIL':[[],['<ADV>'],['PP'],['to','BASE']],
    }
    cats['fool']['maxSentences']=1
    cats['fool']['grammarOverrides']={'TAIL':[[],['<ADV>'],['PP']]}
    for k,c in cats.items():
        c['displayName']={'oracle':'The Oracle','stone':'The Stela','jester':'The Jester','fool':'The Fool'}[k]
        c.update(schemaVersion='language-lab-2',catalogVersion=VERSION,variant=k)
        assert len(c['candidates'])==255,(k,len(c['candidates']))
        assert len({x['text'] for x in c['candidates']})==255
    b=dict(schemaVersion='language-lab-2',catalogVersion=VERSION,semantics=semantics,catalogs=cats)
    if __package__: from .chinese import build as build_chinese
    else: from chinese import build as build_chinese
    b['localizations']={'zh-Hans':build_chinese(cats,semantics)}
    if __package__: from .image_relations import apply as apply_relations
    else: from image_relations import apply as apply_relations
    apply_relations(b)
    (ROOT/'catalogs.json').write_text(json.dumps(b,ensure_ascii=False,indent=2)+'\n')
    print({k:len(c['candidates']) for k,c in cats.items()})
    return b

if __name__=='__main__':build()
