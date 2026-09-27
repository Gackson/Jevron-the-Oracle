"""Export public runtime rules for the direct iOS client."""
import json,pathlib,sys
ROOT=pathlib.Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT))
from experiments.language import lab,grammar
bundle=json.loads((ROOT/'experiments/language/catalogs.json').read_text())
lab.validate_catalogs(bundle)
config={'catalogs':bundle['catalogs'],'rules':grammar.RULES,'semantics':json.loads((ROOT/'experiments/language/semantics.json').read_text()),
        'localizations':bundle.get('localizations',{}),'functionWords':sorted(lab.FUNCTION),'dangling':sorted(lab.DANGLING),'model':lab.MODEL,'promptVersion':lab.PROMPT_VERSION}
catalog_sets=[config['catalogs']]+[v['catalogs'] for v in config['localizations'].values()]
for key,cat in [(k,c) for catalogs in catalog_sets for k,c in catalogs.items()]:
 cat['prompt']=lab.payload_for(cat,'',[],[])['questions']['nextFragment']['instructions']
 if key!='oracle':
  words,cats=grammar.vocabulary(cat);cat['grammarWords']=sorted(words);cat['grammarCategories']={k:sorted(v) for k,v in cats.items()}
captured=[]
def capture(p,t):
 captured.append(p);raise lab.ProviderFailure('capture_only')
lab.reading(config['catalogs']['stone'],'',capture)
config['intentPrompt']=captured[0]['questions']['nextFragment']['instructions']
out=ROOT/'ios/JEV/Resources/Language';out.mkdir(parents=True,exist_ok=True)
(out/'runtime.json').write_text(json.dumps(config,ensure_ascii=False,separators=(',',':'))+'\n')
print(f'Exported {sum(len(catalogs) for catalogs in catalog_sets)} 255-entry catalogs and grammar; no credentials are included.')
