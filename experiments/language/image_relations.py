"""Authored image affordances: contextual possibilities, never fixed diagnoses.

Reuse the candidate semantics contract so the same encodings reach the Python
lab, the mobile choice request and the vocabulary review.
"""
from pathlib import Path

ROOT = Path(__file__).resolve().parent


def load(locale):
    result = {}; role = None
    for line in (ROOT / f'image-relations-{locale}.txt').read_text().splitlines():
        if not line or line.startswith('#'): continue
        if line.startswith('['):
            role = line[1:-1]; result[role] = {}; continue
        word, meaning, uses = line.split('|')
        if word in result[role]: raise ValueError(f'Duplicate image: {word}')
        result[role][word] = dict(meaning=meaning, useWhen=uses.split('；' if locale == 'zh' else ';'))
    return result


def apply(bundle):
    for locale, catalogs in [('en', bundle['catalogs']), ('zh', bundle['localizations']['zh-Hans']['catalogs'])]:
        for role, entries in load(locale).items():
            cat = catalogs[role]
            images = {c['text']: c for c in cat['candidates'] if c['semanticCodes'] == ['image']}
            if not entries.keys() <= images.keys():
                raise ValueError(f'Unknown {locale}/{role} images: {entries.keys() - images.keys()}')
            if locale == 'zh' and entries.keys() != images.keys():
                raise ValueError(f'Missing {role} relationships: {images.keys() - entries.keys()}')
            for word, encoding in entries.items():
                images[word].update(encoding)
                images[word]['avoidWhen'] = [
                    '与问题没有具体联系时不用；指代是可选比喻，不是对用户或他人的诊断。现实危险、安全、求助和同意按字面回应。'
                    if locale == 'zh' else
                    'Do not use without a specific connection to the question. Referents are possible metaphors, not diagnoses. Treat actual danger, safety, help and consent literally.'
                ]
            cat['instructions'] += (
                ' 候选的含义与适用关系只提供可能的指代，不是固定人物设定或已知事实。按问题选有具体联系的物象，不用万能意象套用一切；同样贴切时尝试不同于最近回复的意象。一个场景内保持关系连贯，不为换词而换词。'
                if locale == 'zh' else
                ' Candidate meanings and useWhen relations offer possible referents, not fixed identities or known facts. Select an image with a specific connection to the question, not a universal mascot. When equally fitting, prefer a different image from recent replies. Keep one coherent scene; novelty alone is not a reason to change images.'
            )
