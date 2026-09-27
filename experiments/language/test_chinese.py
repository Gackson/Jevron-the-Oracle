import copy, json, random, unittest
from pathlib import Path
import lab
from test_lab import speaker

B = json.loads((Path(__file__).parent/'catalogs.json').read_text())
ZH = B['localizations']['zh-Hans']['catalogs']

class ChineseTests(unittest.TestCase):
    def test_full_independent_chinese_vocabularies_and_oracle_intent_alignment(self):
        self.assertTrue(lab.validate_catalogs(B))
        for role,cat in ZH.items():
            self.assertEqual(len(cat['candidates']),255)
            self.assertFalse(any('no_match' in c['id'] for c in cat['candidates']))
            self.assertTrue(all(c.get('locale')=='zh-Hans' for c in cat['candidates']))
            if role!='oracle':self.assertEqual(sum(c['kind']=='word' for c in cat['candidates']),249)
        self.assertEqual([c['semanticCodes'] for c in ZH['oracle']['candidates']],
                         [c['semanticCodes'] for c in B['catalogs']['oracle']['candidates']])

    def test_word_by_word_chinese_is_compact_and_readable(self):
        samples={
          'stone':(['石','犹','存','，','而','水','流','。',''],'石犹存，而水流。'),
          'jester':(['你','为什么','需要','许可','？',''],'你为什么需要许可？'),
          'fool':(['可疑','的','鹅','审计','你','的','作业','。',''],'可疑的鹅审计你的作业。'),
        }
        for role,(tokens,expected) in samples.items():
            r=lab.reading(ZH[role],'Should I begin?',speaker(tokens))
            self.assertEqual(r['origin'],'jev',r)
            self.assertEqual(r['text'],expected)
            self.assertEqual(r['calls'],len(tokens)+1)
            self.assertLessEqual(r['calls'],ZH[role]['maxSelections'])
            instructions=r['steps'][1]['request']['questions']['nextFragment']['instructions']
            self.assertIn('中文',instructions)
            self.assertNotIn('Use normal English grammar',instructions)

    def test_jester_why_question_uses_person_instead_of_abstract_reason_as_subject(self):
        cat=ZH['jester'];selected=[next(c for c in cat['candidates'] if c['text']=='理由')]
        self.assertNotIn('为什么',[c['text'] for c in lab.options(cat,selected)])

    def test_classical_open_can_close_without_forcing_an_object(self):
        tokens=['若','步','行','，','则','路','开','。','']
        r=lab.reading(ZH['stone'],'我总是不敢开始，该怎么办？',speaker(tokens))
        self.assertEqual(r['origin'],'jev')
        self.assertEqual(r['text'],'若步行，则路开。')

    def test_stela_cannot_reduce_inscription_to_a_bare_command(self):
        options={c['text'] for c in lab.options(ZH['stone'],[])}
        self.assertNotIn('试',options)
        self.assertIn('石',options)
        self.assertIn('若',options)

    def test_classical_and_archaic_forms_follow_grammar(self):
        for words in [['stone','abideth','.',''],['water','beareth','the','stone','.',''],
                      ['the','stone','hath','a','trace','.',''],['the','stone','doth','hold','a','trace','.','']]:
            r=lab.reading(B['catalogs']['stone'],'What remains?',speaker(words))
            self.assertEqual(r['origin'],'jev',r)
        r=lab.reading(ZH['stone'],'会怎样？',speaker(['若','水','流','，','则','石','存','。','']))
        self.assertEqual(r['text'],'若水流，则石存。')

    def test_chinese_failure_stays_in_character_and_is_not_model_success(self):
        for cat in ZH.values():
            def fail(p,t):raise lab.ProviderFailure('http_429')
            r=lab.reading(cat,'你好',fail)
            self.assertEqual(r['origin'],'authored_fallback')
            self.assertEqual(r['text'],cat['fallback'])
            self.assertNotIn(' ',r['text'])

    def test_chinese_legal_walks_terminate_without_dead_ends(self):
        rng=random.Random(928)
        for role in ('stone','jester','fool'):
            cat=copy.deepcopy(ZH[role]);cat['maxSelections']-=1
            for _ in range(40):
                selected=[]
                for _ in range(cat['maxSelections']):
                    options=lab.options(cat,selected)
                    self.assertTrue(options,(role,lab.render(selected)))
                    selected.append(rng.choice(options))
                    if selected[-1]['terminal']:break
                self.assertTrue(selected[-1]['terminal'],lab.render(selected))

if __name__=='__main__':unittest.main()
