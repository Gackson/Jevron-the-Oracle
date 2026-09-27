"""Small English prefix grammar: lexical choices remain Jev's, never canned replies."""
from functools import lru_cache
from pathlib import Path
ROOT=Path(__file__).resolve().parent

# Alternatives are grammatical constructions, not meaning-specific sentence templates.
RULES={
 'S':[('C','.'),('C',';','C','.'),('C',',','but','C','.'),('if','C',',','C','.'),
      ('if','C',',','Q','?'),('Q','?'),('IMP','.'),('C','.','C','.')],
 'C':[('NP','VPS'),('you','VPB'),('we','VPB'),('they','VPB'),('I','VPI')],
 'NP':[('<DET>','ADJS','<N>'),('ADJS','<MASS>'),('<PRONSG>',)],
 'OBJ':[('NP',),('you',),('it',),('yours',)],
 'ADJS':[(),('<ADJ>',),('<ADJ>','<ADJ>')],
 'VPS':[('<V3I>','TAIL'),('<V3T>','OBJ','TAIL'),('is','PRED','TAIL'),('is','not','PRED','TAIL'),
        ('has','OBJ','TAIL'),('has','hired','OBJ','TAIL'),('<MODAL>','BASE'),('does','not','BASE')],
 'VPB':[('BASE',),('are','PRED','TAIL'),('are','not','PRED','TAIL'),('have','OBJ','TAIL'),('<MODAL>','BASE'),('do','not','BASE')],
 'VPI':[('BASE',),('am','PRED','TAIL'),('am','not','PRED','TAIL'),('have','OBJ','TAIL'),('<MODAL>','BASE'),('do','not','BASE')],
 'BASE':[('keep','OBJ','<ADJ>','TAIL'),('<VBI>','TAIL'),('<VBT>','OBJ','TAIL'),('be','PRED','TAIL')],
 'PRED':[('<ADJ>',),('NP',),('PP',),('waiting','PP')],
 'TAIL':[(),('<ADV>',),('PP',),('<ADV>','PP'),('to','BASE'),('because','C'),('while','C')],
 'PP':[('<PREP>','OBJ'),('between','OBJ','and','OBJ')],
 'Q':[('why','does','NP','BASE'),('why','do','you','BASE'),('why','is','NP','PRED'),
      ('what','does','NP','BASE'),('who','VPS'),('what','is','NP'),('<MODAL>','NP','BASE')],
 'IMP':[('<VBI>','TAIL'),('<VBT>','OBJ','TAIL'),('let','OBJ','<VBI>','TAIL')],
}
FIXED={
 'DET':'a an the your my our their its this that another every one no some',
 'PRONSG':'it this that',
 'MODAL':'can could may might must will would should',
 'PREP':'of to from for with without in on at by through before after under over into',
 'ADV':'here there now still already again together away perhaps enough',
 'V3I':'waits returns changes looks learns laughs remains moves crosses opens closes breaks bends settles falls rises flows grows wears fades leaves reaches turns stays speaks',
 'V3T':'hires wears owns sells buys asks knows thinks calls keeps holds opens closes hides counts pays charges signs files appoints refuses needs wants makes takes gives bears carries finds',
 'VBI':'stop start try ask wait know look seek step leave listen begin move change remain',
 'VBT':'own hire stop start try ask know keep make take give seek share repair leave hold carry say mean',
 'MASS':'fear doubt permission consent warning danger help safety silence applause time energy work rest life truth hope stone water tide sea shore soil ice mist sky wind storm light shadow night dawn day sand dust clay iron weight pressure tension space room sound voice memory absence change safety smoke fire ash snow rain metal ore',
}


# Additional ordinary constructions give function words real, reachable jobs.
RULES['S'] += [('C',':','C','.'),('C',',','and','C','.'),('C',',','or','C','.'),
               ('C',',','yet','C','.'),('C',',','so','C','.'),
               ('although','C',',','C','.'),('when','C',',','C','.'),('as','C',',','C','.'),
               ('yes',',','C','.'),('no',',','C','.'),('then',',','C','.')]
RULES['C'] += [('these','VPB'),('those','VPB'),('both','VPB')]
RULES['VPS'] += [('was','PRED','TAIL'),('was','not','PRED','TAIL'),('had','OBJ','TAIL'),
                 ('has','been','PRED','TAIL'),('is','being','<ADJ>','TAIL'),
                 ('becomes','PRED','TAIL'),('says','C'),('<MODAL>','not','BASE'),
                 ('<PREVERB>','<V3I>','TAIL'),('<PREVERB>','<V3T>','OBJ','TAIL')]
RULES['VPB'] += [('were','PRED','TAIL'),('were','not','PRED','TAIL'),('had','OBJ','TAIL'),
                 ('have','been','PRED','TAIL'),('<MODAL>','not','BASE'),('did','not','BASE')]
RULES['VPI'] += [('was','PRED','TAIL'),('had','OBJ','TAIL'),('have','been','PRED','TAIL'),
                 ('<MODAL>','not','BASE'),('did','not','BASE')]
RULES['PRED'] += [('more','<ADJ>','than','OBJ'),('less','<ADJ>','than','OBJ'),('too','<ADJ>')]
RULES['Q'] += [('how','does','NP','BASE'),('where','does','NP','BASE'),('when','does','NP','BASE'),
              ('why','did','NP','BASE')]
RULES['OBJ'] += [('itself',)]
RULES['Q'] += [('what','do','you','<VBT>','TAIL'),('what','<MODAL>','you','<VBT>','TAIL'),
               ('<MODAL>','you','BASE'),('do','you','BASE')]

FIXED['PREVERB']='never only even just'
FIXED['ADV']+=' out'


def vocabulary(cat):
    if cat.get('locale')=='zh-Hans':
        return set(cat['grammarWords']),{k:set(v) for k,v in cat['grammarCategories'].items()}
    words={c['text'] for c in cat['candidates'] if c['kind']=='word'}
    cats={k:set(v.split())&words for k,v in FIXED.items()}
    cats['N']=set();cats['ADJ']=set()
    for file in ['lexicon-'+cat['characterId']+'.txt']:
        group=None
        for line in (ROOT/file).read_text().splitlines():
            if line.startswith('['):group=line[1:-1];continue
            text=line.split('|')[0]
            if group=='image':cats['N'].add(text)
            if group=='quality':cats['ADJ'].add(text)
    if cat['characterId']=='stone':
        cats['V3I'].update({'abideth','waxeth','waneth','speaketh'} & words)
        cats['V3T'].update({'beareth','knoweth'} & words)
    if cat['characterId']=='jester':
        cats['VBT'].update({'want','need','trust','choose','feel'} & words)
        cats['VBI'].update({'stay'} & words)
        cats['MASS'].update({'love','hurt','respect','honesty'} & words)
    if cat['characterId']=='fool':
        extra={
          'V3T':'juggles audits polishes marinates inflates borrows delivers misplaces rehearses salutes interviews promotes starts helps',
          'V3I':'negotiates apologizes sneezes waddles tapdances',
          'VBT':'wear juggle audit polish marinate inflate borrow deliver misplace rehearse salute interview promote help',
          'VBI':'negotiate apologize sneeze waddle tapdance',
          'MASS':'jelly pudding confetti lunch homework consent',
        }
        for name,values in extra.items():cats[name].update(set(values.split())&words)
    cats['MASS'] &= cats['N']
    # Rules unavailable in this character's actual vocabulary have infinite minimum cost.
    return words,cats


class PrefixGrammar:
    def __init__(self,cat):
        self.words,self.cats=vocabulary(cat)
        self.rules={**RULES,**cat.get('grammarOverrides',{})}
        self.minimum={s:999 for s in self.rules}
        for _ in range(30):
            changed=False
            for s,alternatives in self.rules.items():
                cost=min(sum(self.cost(x) for x in rhs) for rhs in alternatives)
                if cost<self.minimum[s]:self.minimum[s]=cost;changed=True
            if not changed:break

    def cost(self,s):
        if s in self.rules:return self.minimum[s]
        if s.startswith('<'):return 1 if self.cats.get(s[1:-1]) else 999
        return 1 if s in self.words or s in {'.',',','?',';',':','。','，','？','；','：'} else 999

    def matches(self,s,t):
        return t in self.cats.get(s[1:-1],set()) if s.startswith('<') else s==t

    def expand(self,states,remaining):
        todo=list(states);seen=set();out=set()
        while todo:
            stack=todo.pop()
            if stack in seen or sum(self.cost(s) for s in stack)>remaining:continue
            seen.add(stack)
            if not stack or stack[0] not in self.rules:out.add(stack);continue
            todo.extend(tuple(rhs)+stack[1:] for rhs in self.rules[stack[0]])
        return out

    def states(self,tokens,budget):
        states={('S',)}
        for i,t in enumerate(tokens):
            states={s[1:] for s in self.expand(states,budget-i) if s and self.matches(s[0],t)}
        return self.expand(states,budget-len(tokens))

    def accepts_next(self,states,text,remaining):
        return any(s and self.matches(s[0],text) and sum(self.cost(x) for x in s[1:])<=remaining-1 for s in states)
