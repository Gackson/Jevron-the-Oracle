"""Coverage and transport checks, not claims of model prose quality."""
import json, unittest
from pathlib import Path
import lab
from image_relations import load

B = json.loads((Path(__file__).parent/'catalogs.json').read_text())

class ImageRelationsTests(unittest.TestCase):
    def test_every_chinese_fool_and_stela_image_has_individual_relations(self):
        for role,entries in load('zh').items():
            cat=B['localizations']['zh-Hans']['catalogs'][role]
            images=[c for c in cat['candidates'] if c['semanticCodes']==['image']]
            self.assertEqual({c['text'] for c in images},set(entries))
            self.assertEqual(len({c['meaning'] for c in images}),len(images))
            self.assertEqual(len({tuple(c['useWhen']) for c in images}),len(images))
            for c in images:
                self.assertTrue(c['avoidWhen'])
                self.assertNotIn('意象或概念：',c['meaning'])

    def test_relations_reach_real_candidate_payload_without_becoming_tokens(self):
        for locale,catalogs in [('en',B['catalogs']),('zh',B['localizations']['zh-Hans']['catalogs'])]:
            for role,entries in load(locale).items():
                cat=catalogs[role]
                payload=lab.payload_for(cat,'Q',[],cat['candidates'])
                criteria=payload['questions']['nextFragment']['criteria']
                for word,entry in entries.items():
                    self.assertEqual(criteria[word]['meaning'],entry['meaning'])
                    self.assertEqual(criteria[word]['useWhen'],entry['useWhen'])
                self.assertEqual(len(criteria),255)
                self.assertNotIn('potato',cat['instructions'])

    def test_literal_hazards_and_consent_are_not_comic_characters(self):
        fool=load('zh')['fool']
        for word in ['危险','帮助','安全','同意']:
            self.assertTrue(any(s in ' '.join(fool[word]['useWhen']) for s in ['直接','停止','不嘲笑']))
        # Removing a mascot bias must not remove legitimate user-requested words.
        for role,words in [('fool',['土豆','鹅','橡皮鸭']),('stone',['石','水','路','井','苔痕'])]:
            ids={c['id'] for c in lab.options(B['localizations']['zh-Hans']['catalogs'][role],[])}
            self.assertTrue(set(words)<=ids)
