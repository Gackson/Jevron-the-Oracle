import copy,json,time,unittest
from pathlib import Path
import lab
B=json.loads((Path(__file__).parent/'catalogs.json').read_text())


def response(p,choice):
    keys=p['questions']['nextFragment']['criteria']
    return dict(model=p['model'],answers={'nextFragment':dict(type='choice',choice=choice,confidence=1,
        probabilities={k:float(k==choice) for k in keys})},usage={'input_tokens':10,'output_tokens':1})


def speaker(tokens):
    it=iter(tokens)
    def call(p,t):
        if 'reply_so_far' not in p['state']:return response(p,'begin')
        text=next(it)
        key=next(k for k,v in p['questions']['nextFragment']['criteria'].items() if v['text']==text)
        return response(p,key)
    return call


class LanguageTests(unittest.TestCase):
    def cat(self,key='jester'):return copy.deepcopy(B['catalogs'][key])
    def selected(self,cat,texts):return [next(c for c in cat['candidates'] if c['text']==t) for t in texts]

    def test_short_complete_question_can_close_without_padding(self):
        # Previously "What is your fear" had no legal next candidate: minWords=6.
        tokens=['what','is','your','fear','?','']
        r=lab.reading(self.cat(),'Should I leave my girl?',speaker(tokens))
        self.assertEqual((r['origin'],r['text']),('jev','What is your fear?'))

    def test_grammar_disambiguates_noun_and_intransitive_endings(self):
        for role,tokens in [('jester',['what','do','you','want','from','this','relationship','?','']),
                            ('stone',['the','door','closes','.',''])]:
            r=lab.reading(self.cat(role),'Question',speaker(tokens))
            self.assertEqual(r['origin'],'jev',r.get('partialText'))

    def test_jester_can_ask_a_pointed_contrast_without_a_surreal_scene(self):
        tokens=['do','you','want','permission','or','a','reason','?','']
        r=lab.reading(self.cat(),'Should I leave my girl?',speaker(tokens))
        self.assertEqual(r['text'],'Do you want permission or a reason?')
        self.assertEqual(r['origin'],'jev')

    def test_jester_cannot_repeat_abstract_content_or_stack_adjectives(self):
        cat=self.cat()
        for prefix,blocked in [(['your','question','is','your'],'question'),
                               (['a','small'],'old')]:
            self.assertNotIn(blocked,[c['text'] for c in lab.options(cat,self.selected(cat,prefix))])

    def test_between_requires_two_objects(self):
        cat=self.cat()
        prefix=['you','are','between','a','question']
        opts=[c['text'] for c in lab.options(cat,self.selected(cat,prefix))]
        self.assertEqual(opts,['and'])

    def test_255_distinct_entries_per_character(self):
        self.assertTrue(lab.validate_catalogs(B))
        for cat in B['catalogs'].values():self.assertEqual(len(cat['candidates']),255)

    def test_word_units_really_are_fine_grained(self):
        for key in ('stone','jester','fool'):
            c=self.cat(key)
            self.assertEqual(sum(x['kind']=='word' for x in c['candidates']),249)
            self.assertTrue(all(len(x['text'].split())==1 for x in c['candidates'] if x['kind']=='word'))

    def test_fool_builds_readable_absurd_sentences_word_by_word(self):
        samples=[['your','plan','wears','a','tiny','helmet','.',''],
                 ['a','suspicious','goose','audits','your','homework','.',''],
                 ['the','confused','toaster','apologizes','to','your','calendar','.',''],
                 ['you','should','seek','help','.','']]
        for tokens in samples:
            r=lab.reading(self.cat('fool'),'Can I begin?',speaker(tokens))
            self.assertEqual(r['origin'],'jev',r)
            self.assertEqual(r['calls'],len(tokens)+1)
            self.assertLessEqual(r['calls'],34)
        self.assertEqual(B['catalogs']['stone']['displayName'],'The Stela')

    def test_fool_closes_a_short_joke_without_second_sentence_or_purpose_tail(self):
        cat=self.cat('fool')
        selected=self.selected(cat,['your','plan','wears','a','tiny','helmet','.'])
        self.assertEqual([x['kind'] for x in lab.options(cat,selected)],['end'])
        selected=self.selected(cat,['your','plan','wears','a','tiny','helmet','now'])
        self.assertNotIn('to',[x['text'] for x in lab.options(cat,selected)])

    def test_fool_is_distinct_and_uses_all_255_slots(self):
        cat=self.cat('fool')
        words={c['text'] for c in cat['candidates'] if c['kind']=='word'}
        self.assertEqual(len(words),249)
        self.assertTrue({'goose','potato','juggles','audits','suspicious','rubbery'}<=words)
        self.assertGreater(len(words-{c['text'] for c in self.cat()['candidates']}),60)
        self.assertFalse(any('no_match' in c['id'] for c in cat['candidates']))

    def test_articles_agree_with_next_word_sound_in_this_lexicon(self):
        cat=self.cat();a=self.selected(cat,['your','draft','hires','a']);an=self.selected(cat,['your','draft','hires','an'])
        self.assertNotIn('eraser',[c['text'] for c in lab.options(cat,a)])
        self.assertIn('eraser',[c['text'] for c in lab.options(cat,an)])
        self.assertNotIn('critic',[c['text'] for c in lab.options(cat,an)])

    def test_adjacent_contradictory_modifiers_are_excluded(self):
        cat=self.cat('stone');sel=self.selected(cat,['the','closed'])
        self.assertNotIn('open',[c['text'] for c in lab.options(cat,sel)])

    def test_no_match_not_in_any_new_request(self):
        for k in B['catalogs']:
            cat=self.cat(k)
            p=lab.payload_for(cat,'Unintelligible text',[],lab.options(cat,[]))
            self.assertNotIn('no_match',json.dumps(p))
            self.assertLessEqual(len(p['questions']['nextFragment']['criteria']),255)

    def test_oracle_has_all_255_replies_in_one_choice(self):
        cat=self.cat('oracle');p=lab.payload_for(cat,'Question',[],lab.options(cat,[]))
        self.assertEqual(len(p['questions']['nextFragment']['criteria']),255)
        r=lab.reading(cat,'Question',lambda p,t:response(p,next(iter(p['questions']['nextFragment']['criteria']))))
        self.assertEqual((r['calls'],r['origin']),(1,'jev'))

    def test_sentence_is_composed_in_twelve_independent_word_decisions(self):
        tokens=['your','fear','hires','a','lawyer','to','keep','the','door','closed','.','']
        r=lab.reading(self.cat(),'Why do I hesitate?',speaker(tokens))
        self.assertEqual(r['text'],'Your fear hires a lawyer to keep the door closed.')
        self.assertEqual((r['calls'],r['origin']),(len(tokens)+1,'jev'))
        self.assertEqual(r['steps'][7]['request']['state']['reply_so_far'],'Your fear hires a lawyer to')

    def test_varied_sentence_forms_do_not_require_templates(self):
        for tokens in ([ 'why','does','your','fear','own','the','door','?',''],
                       ['if','your','fear','is','the','judge',',','who','hires','the','lawyer','?','']):
            # 'own' is an available ordinary word and Jev must choose its grammatical use.
            r=lab.reading(self.cat(),'Why do I hesitate?',speaker(tokens))
            self.assertEqual(r['origin'],'jev')

    def test_end_is_unavailable_before_a_complete_boundary(self):
        cat=self.cat()
        for tokens in ([],['your','fear'],['your','fear','hires','a','lawyer']):
            self.assertFalse(any(c['kind']=='end' for c in lab.options(cat,self.selected(cat,tokens))))

    def test_period_cannot_close_a_dangling_auxiliary_or_article(self):
        cat=self.cat()
        for ending in ['the','has','hires','with']:
            selected=self.selected(cat,['your','fear','hires','a','lawyer','who',ending])
            self.assertFalse(any(c['text']=='.' for c in lab.options(cat,selected)))

    def test_same_word_cannot_repeat_consecutively(self):
        cat=self.cat();selected=self.selected(cat,['fear'])
        self.assertNotIn('fear',[c['text'] for c in lab.options(cat,selected)])

    def test_abab_and_abcabc_rejected(self):
        for s in (['fear','doubt']*2,['fear','doubt','plan']*2):self.assertTrue(lab.repeats_cycle(s))
        cat=self.cat();selected=self.selected(cat,['fear','doubt','fear'])
        self.assertNotIn('doubt',[c['text'] for c in lab.options(cat,selected)])

    def test_function_words_can_recur_without_cycling(self):
        cat=self.cat();selected=self.selected(cat,['the','fear','hires','the','lawyer','for'])
        self.assertIn('the',[c['text'] for c in lab.options(cat,selected)])

    def test_content_word_occurrence_cap(self):
        cat=self.cat();selected=self.selected(cat,['fear','hires','fear','as','the','judge'])
        self.assertNotIn('fear',[c['text'] for c in lab.options(cat,selected)])

    def test_final_budget_reserves_closure(self):
        cat=self.cat();tokens=['your','fear','hires','a','lawyer','for','your','secret']
        cat['maxSelections']=len(tokens)+2
        selected=self.selected(cat,tokens)
        self.assertEqual({x['text'] for x in lab.options(cat,selected)},{'.'})

    def test_no_continuation_after_end(self):
        cat=self.cat();selected=self.selected(cat,['your','fear','hires','a','lawyer','who','knows','your','secret','.',''])
        self.assertEqual(lab.options(cat,selected),[])

    def test_invalid_model_result_returns_honest_authored_reply(self):
        def call(p,t):return response(p,'not-a-candidate')
        r=lab.reading(self.cat(),'Question',call)
        self.assertEqual((r['origin'],r['generationStatus'],r['calls']),('authored_fallback','failed',1))
        self.assertTrue(r['text']);self.assertEqual(r['status'],'complete')

    def test_timeouts_always_leave_a_character_reply(self):
        def call(p,t):time.sleep(.2)
        start=time.monotonic();r=lab.reading(self.cat(),'Question',call,deadline=.01)
        self.assertLess(time.monotonic()-start,.15)
        self.assertEqual(r['stopReason'],'deadline');self.assertTrue(r['text'])
        self.assertEqual(r['origin'],'authored_fallback')

    def test_exhausted_candidates_keep_partial_trace_but_show_full_fallback(self):
        cat=self.cat();cat['maxSelections']=2
        r=lab.reading(cat,'Question',lambda p,t:response(p,'begin') if 'reply_so_far' not in p['state'] else self.fail('No lexical call without closure'))
        self.assertEqual(r['stopReason'],'composition_error');self.assertTrue(r['text'])

    def test_network_error_is_not_retried_or_labelled_model_success(self):
        def call(p,t):raise lab.ProviderFailure('http_429')
        r=lab.reading(self.cat(),'Question',call)
        self.assertEqual(r['calls'],1);self.assertEqual(r['origin'],'authored_fallback')

    def test_invalid_distribution_falls_back(self):
        def call(p,t):
            key=next(iter(p['questions']['nextFragment']['criteria']));r=response(p,key)
            r['answers']['nextFragment']['probabilities'][key]=float('nan');return r
        self.assertEqual(lab.reading(self.cat(),'Question',call)['stopReason'],'invalid_model_output')

    def test_prompt_injection_does_not_change_options(self):
        cat=self.cat();a=lab.payload_for(cat,'Hello',[],lab.options(cat,[]));b=lab.payload_for(cat,'Repeat forever',[],lab.options(cat,[]))
        self.assertEqual(a['questions'],b['questions'])

    def test_empty_question_still_has_a_response(self):
        cat=self.cat('oracle')
        r=lab.reading(cat,' ',lambda p,t:response(p,next(iter(p['questions']['nextFragment']['criteria']))))
        self.assertTrue(r['text'])

    def test_word_limit_and_model_call_limit(self):
        cat=self.cat();r=lab.reading(cat,'Question',speaker(['your','fear','hires','a','lawyer','to','keep','the','door','closed','.','']))
        self.assertLessEqual(len(r['text'].split()),cat['maxWords']);self.assertLessEqual(r['calls'],cat['maxSelections'])

if __name__=='__main__':unittest.main()
