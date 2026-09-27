"""Compare actual mobile JavaScript candidate sets against the Python reference."""
import copy,json,pathlib,random,shutil,subprocess,unittest
from experiments.language import lab
ROOT=pathlib.Path(__file__).resolve().parents[2]

class IOSRuleParityTests(unittest.TestCase):
    def test_image_relations_reach_mobile_choice_criteria(self):
        node=shutil.which('node')
        if not node:self.skipTest('Node is required for cross-runtime parity')
        bundle=json.loads((ROOT/'experiments/language/catalogs.json').read_text())
        script="""
const fs=require('fs'),vm=require('vm');
vm.runInThisContext(fs.readFileSync('ios/JEV/Resources/Language/engine.js','utf8'));
const runtime=fs.readFileSync('ios/JEV/Resources/Language/runtime.json','utf8');
const results=[];
for(const locale of ['en','zh-Hans']) for(const role of ['fool','stone']) {
 JEV.initialize(runtime,JSON.stringify({characterId:role,locale,question:'Q',history:[]}));
 const p=JSON.parse(JEV.next()).payload, keys=Object.keys(p.questions.nextFragment.criteria);
 JEV.accept(JSON.stringify({model:p.model,answers:{nextFragment:{type:'choice',choice:'begin',confidence:1,
   probabilities:Object.fromEntries(keys.map(k=>[k,k==='begin'?1:0]))}}}));
 const texts=locale==='en'?['the']:[];
 JEV.candidateIDs(texts);
 results.push({locale,role,texts,criteria:JSON.parse(JEV.next()).payload.questions.nextFragment.criteria});
}
process.stdout.write(JSON.stringify(results));
"""
        result=subprocess.run([node,'-e',script],text=True,capture_output=True,cwd=ROOT,check=True)
        for row in json.loads(result.stdout):
            cats=bundle['catalogs'] if row['locale']=='en' else bundle['localizations'][row['locale']]['catalogs']
            cat=copy.deepcopy(cats[row['role']]);cat['maxSelections']-=1
            selected=[next(c for c in cat['candidates'] if c['text']==t) for t in row['texts']]
            expected=lab.payload_for(cat,'Q',selected,lab.options(cat,selected))['questions']['nextFragment']['criteria']
            self.assertEqual(row['criteria'],expected)
            self.assertGreater(sum('useWhen' in c for c in expected.values()),10)

    def test_generated_runtime_and_mobile_prefix_rules_match_python(self):
        node=shutil.which('node')
        if not node:self.skipTest('Node is required for cross-runtime parity')
        bundle=json.loads((ROOT/'experiments/language/catalogs.json').read_text())
        runtime=json.loads((ROOT/'ios/JEV/Resources/Language/runtime.json').read_text())
        cases=[];rng=random.Random(27)
        sets=[('en',bundle['catalogs'],runtime['catalogs'])]+[(locale,v['catalogs'],runtime['localizations'][locale]['catalogs']) for locale,v in bundle['localizations'].items()]
        for locale,source_set,runtime_set in sets:
          for role,source in source_set.items():
              self.assertEqual(runtime_set[role]['candidates'],source['candidates'])
              self.assertEqual(runtime_set[role]['prompt'],lab.payload_for(source,'',[],[])['questions']['nextFragment']['instructions'])
              cat=copy.deepcopy(source)
              if cat['mode']=='word_sequence':cat['maxSelections']-=1
              for _ in range(12):
                  selected=[]
                  for _ in range(cat['maxSelections']+1):
                      options=lab.options(cat,selected)
                      cases.append(dict(locale=locale,role=role,texts=[c['text'] for c in selected],expected=sorted(c['id'] for c in options)))
                      if not options:break
                      selected.append(rng.choice(options))
        script="""
const fs=require('fs'),vm=require('vm');
vm.runInThisContext(fs.readFileSync('ios/JEV/Resources/Language/engine.js','utf8'));
const runtime=fs.readFileSync('ios/JEV/Resources/Language/runtime.json','utf8');
const cases=JSON.parse(fs.readFileSync(0,'utf8'));
process.stdout.write(JSON.stringify(cases.map(c=>{
 JEV.initialize(runtime,JSON.stringify({characterId:c.role,locale:c.locale,question:'Q',history:[]}));
 return JEV.candidateIDs(c.texts).sort();
})));
"""
        result=subprocess.run([node,'-e',script],input=json.dumps(cases),text=True,capture_output=True,cwd=ROOT,check=True)
        actual=json.loads(result.stdout)
        self.assertGreater(len(cases),100)
        for case,ids in zip(cases,actual):self.assertEqual(ids,case['expected'],case)

if __name__=='__main__':unittest.main()
