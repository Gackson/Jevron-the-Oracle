"""Authoring source for experimental catalogs. Run explicitly to rebuild JSON."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent
VERSION = "2026-09-27.seed1"

# Shared codes are editorial indexes; every choice also gets natural-language meaning.
SEMANTICS = {
    "begin": ("A reversible beginning is mistaken for a commitment to the entire journey.",
              "A desired small action is delayed until the whole future is certain.",
              "Starting would be dangerous or irreversible; the person has already begun.",
              "Unlike perfection, this concerns crossing into action, not polishing its result."),
    "perfect": ("Premature judgment or endless polishing prevents a workable thing from being shared.",
                "A draft or low-stakes attempt is repeatedly corrected despite being usable.",
                "There is a known serious defect, factual error, or safety problem.",
                "Unlike beginning, work already exists; the obstacle is accepting imperfection."),
    "repair": ("A concrete, evidenced problem deserves attention before forward movement.",
               "The question identifies a real fault or missing practical support.",
               "Only imagined embarrassment or vague anxiety is described.",
               "Unlike perfectionism, caution here responds to observable evidence."),
    "release": ("Trying to force another person's response maintains the tension.",
                "Repeated checking or persuasion seeks control over someone else's choice.",
                "The person needs to state an unexpressed need or fulfill a responsibility.",
                "Unlike voicing a need, this concerns continuing to pull after reaching out."),
    "voice": ("An unspoken need cannot fairly be expected to be understood.",
              "The person wants understanding but has not communicated a need or boundary.",
              "The need has already been repeatedly and clearly expressed.",
              "Unlike release, there has not yet been an honest first communication."),
    "rest": ("Capacity has been depleted; pause is different from abandonment.",
             "Sustained effort and concrete exhaustion are described.",
             "The person is rested but repeatedly postpones a small desired action.",
             "Unlike avoidance, the limiting factor is energy rather than permission."),
    "repeat": ("A familiar method repeats without using evidence from its failures.",
               "The same attempt is repeated and the same unwanted result returns.",
               "A changed method is being tested or a useful practice needs time.",
               "Unlike patience, there is evidence that the method itself needs to change."),
    "patience": ("A process already underway needs time rather than repeated disturbance.",
                 "There has been a reasonable first action, but too little time for results.",
                 "There is a persistent failure pattern, urgent danger, or unstarted task.",
                 "Unlike repetition, nothing yet demonstrates that the approach is failing."),
    "boundary": ("A freely chosen limit protects a person's finite capacity.",
                 "The person overcommits to avoid disappointing others.",
                 "The person wishes to withdraw from all contact or evade an agreed obligation.",
                 "Unlike isolation, this is about choosing what to carry, not rejecting everyone."),
    "approval": ("Other people's approval has displaced the person's own judgment.",
                 "A personal preference changes whenever a new opinion is heard.",
                 "The decision needs expertise or consent from people actually affected.",
                 "Unlike missing evidence, this concerns excess permission-seeking."),
    "loss": ("Something meaningful has ended; keeping its meaning need not mean restoring it.",
             "The person struggles to leave an ended chapter while retaining its value.",
             "The situation remains repairable and no ending has been described.",
             "Unlike release, this concerns an ending rather than controlling a pending reply."),
    "unclear": ("The question omits the competing needs needed for a meaningful choice.",
                "The person asks which path to choose without explaining what either serves.",
                "The question already identifies a clear obstacle or asks for a factual prediction.",
                "Unlike approval, there is not yet enough stated context to identify the conflict."),
}


def candidate(id_, text, code, slot, next_slots=(), *, meaning=None, group=None,
              accepts=(), subject_type=None):
    base, use, avoid, contrast = SEMANTICS[code]
    return dict(id=id_, text=text, semanticCodes=[code], meaning=meaning or base,
                useWhen=[use], avoidWhen=[avoid], contrast=contrast, slot=slot,
                nextSlots=list(next_slots), terminal=not next_slots,
                dedupeGroup=group or id_, grammar=dict(accepts=list(accepts), subjectType=subject_type))


def build():
    catalogs = {}

    def catalog(key, character, mode, minimum, maximum, candidates, instructions):
        catalogs[key] = dict(schemaVersion="language-lab-1", catalogVersion=VERSION,
                             characterId=character, variant=key, mode=mode,
                             minSelections=minimum, maxSelections=maximum,
                             startSlot=candidates[0]["slot"], maxWords=32,
                             instructions=instructions, candidates=candidates)

    oracle_rows = [
        ("begin", "A beginning is not a promise to finish everything."),
        ("perfect", "Let it be seen before it becomes flawless."),
        ("repair", "Attend to the crack before asking the bridge to carry more."),
        ("release", "Some things loosen when you stop pulling."),
        ("voice", "A quiet wish may need an audible shape."),
        ("rest", "You may put it down without walking away."),
        ("repeat", "Another attempt need not be the same attempt."),
        ("patience", "Let what you have planted spend some time unseen."),
        ("boundary", "A kind answer can still have an edge."),
        ("approval", "Notice whose permission you are still waiting for."),
        ("loss", "You can keep its meaning without keeping its place."),
        ("unclear", "Name what each road would ask you to leave behind."),
    ]
    catalog("oracle", "oracle", "whole_reply", 1, 1,
            [candidate("oracle."+c, t, c, "whole") for c,t in oracle_rows],
            "Choose one warm, understated complete reply addressing the specific tension, not merely the topic.")

    noun_rows = [
        ("threshold", "A threshold.", "begin"), ("footprint", "A first footprint.", "begin"),
        ("polish", "A polished surface.", "perfect"), ("eraser", "An eraser.", "perfect"),
        ("crack", "A fracture.", "repair"), ("support", "A support.", "repair"),
        ("rope", "A taut rope.", "release"), ("slack", "A slackened knot.", "release"),
        ("echo", "An unheard echo.", "voice"), ("opening", "An opening.", "voice"),
        ("basin", "An empty basin.", "rest"), ("shelter", "A shelter.", "rest"),
        ("orbit", "An orbit.", "repeat"), ("groove", "A deepening groove.", "repeat"),
        ("seed", "A buried seed.", "patience"), ("season", "A season.", "patience"),
        ("shore", "A shoreline.", "boundary"), ("weight", "A borrowed weight.", "boundary"),
        ("mirror", "A borrowed mirror.", "approval"), ("compass", "A compass.", "approval"),
        ("sediment", "A layer of sediment.", "loss"), ("absence", "An absence.", "loss"),
        ("fork", "A fork in the path.", "unclear"), ("mist", "A bank of mist.", "unclear"),
    ]
    nouns = [candidate("stone.noun."+i,t,c,"noun",["noun"]) for i,t,c in noun_rows]
    catalog("stone_nouns", "stone", "fixed_sequence", 3, 3, nouns,
            "Choose a solemn material image connected to the question. Add a distinct aspect to earlier images; do not merely list synonyms.")

    # S1: physical subject classes constrain predicates; meaning remains a model judgment.
    heads = [
        ("threshold","The threshold","begin","place"),
        ("surface","The polished surface","perfect","surface"),
        ("crack","The crack","repair","mark"),
        ("rope","The rope","release","bond"),
        ("echo","The echo","voice","signal"),
        ("basin","The empty basin","rest","vessel"),
        ("orbit","The orbit","repeat","path"),
        ("seed","The buried seed","patience","living"),
        ("shore","The shoreline","boundary","place"),
        ("mirror","The borrowed mirror","approval","surface"),
        ("sediment","The sediment","loss","mark"),
        ("fork","The fork in the path","unclear","place"),
    ]
    stone = [candidate("stone.head."+i,t,c,"image",["relation"],subject_type=typ) for i,t,c,typ in heads]
    ends = [
        ("still","does not move.","begin",["place","surface","mark","vessel"],"The object remains; waiting alone does not make a crossing or decision happen."),
        ("step","cannot take the first step.","begin",["place","path","surface"],"An external object cannot perform the person's own small beginning."),
        ("trace","still bears a trace.","perfect",["surface","place","vessel"],"A trace of making survives polishing; imperfection need not erase worth."),
        ("deeper","runs beneath the surface.","repair",["mark","path","bond"],"A visible fault or pattern has depth; it should not be dismissed as mere appearance."),
        ("force","does not soften under force.","release",["bond","place","surface"],"More pressure does not necessarily remove resistance or produce consent."),
        ("sound","requires a first sound.","voice",["signal","vessel","place"],"A response needs an initial expression; silence alone cannot communicate a wish."),
        ("empty","cannot pour from emptiness.","rest",["vessel","living"],"A depleted source cannot keep giving; replenishment precedes further effort."),
        ("center","still circles the same center.","repeat",["path","signal","bond"],"Motion can return to the same unresolved pattern rather than change it."),
        ("unseen","changes out of sight.","patience",["living","mark","place"],"A process may develop without immediate visible proof; do not claim a future outcome."),
        ("edge","holds an edge.","boundary",["place","surface","vessel","mark"],"A form is maintained by a limit; holding a boundary need not mean hostility."),
        ("north","cannot choose your north.","approval",["surface","path","place","signal"],"An external reflection or route cannot determine an inner direction."),
        ("remains","remains after the water.","loss",["mark","place","vessel"],"A trace can remain after the conditions that formed it have passed."),
        ("unnamed","has two unnamed sides.","unclear",["place","surface","bond"],"The competing sides of a choice are not yet articulated."),
    ]
    stone += [candidate("stone.relation."+i,t,c,"relation",meaning=m,accepts=a) for i,t,c,a,m in ends]
    catalog("stone_inscription", "stone", "phrase_sequence", 2, 2, stone,
            "Form a cold, spare inscription: one physical image and one meaningful relation. No jokes or direct advice. The relation must address the question and make sense for the selected image.")

    contexts = [
        ("begin","Before the crossing."), ("perfect","Beneath the polish."),
        ("repair","Along the fracture."), ("release","At the tightened knot."),
        ("voice","Within the silence."), ("rest","At the empty basin."),
        ("repeat","Along the worn path."), ("patience","Beneath the soil."),
        ("boundary","At the shoreline."), ("approval","Before the borrowed mirror."),
        ("loss","After the water."), ("unclear","Between two paths."),
    ]
    shifts = [
        ("begin","The weight shifts."), ("perfect","A rough edge catches light."),
        ("repair","Pressure finds the weakness."), ("release","The tension eases."),
        ("voice","A first sound travels."), ("rest","The pressure settles."),
        ("repeat","The groove deepens."), ("patience","Something moves unseen."),
        ("boundary","The edge holds."), ("approval","The reflection changes."),
        ("loss","The current passes."), ("unclear","The paths diverge."),
    ]
    traces = [
        ("begin","A first mark."), ("perfect","A visible seam."),
        ("repair","A place needing support."), ("release","Room between the strands."),
        ("voice","A ripple beyond the source."), ("rest","Space to fill again."),
        ("repeat","The same ground."), ("patience","No sign above ground."),
        ("boundary","A shape preserved."), ("approval","The center remains unchosen."),
        ("loss","A trace in the stone."), ("unclear","Two different distances."),
    ]
    sequence = [candidate("stone.context."+c,t,c,"context",["change"]) for c,t in contexts]
    sequence += [candidate("stone.change."+c,t,c,"change",["trace"]) for c,t in shifts]
    sequence += [candidate("stone.trace."+c,t,c,"trace") for c,t in traces]
    catalog("stone_progression", "stone", "phrase_sequence", 3, 3, sequence,
            "Form three connected images: a situation, a change, and a trace. Stay inside one physical scene or clearly connected metaphor; do not create three unrelated poetic lines or predict actual events.")

    setups = [
        ("backup","Your backup plan","begin","plan"),
        ("draft","Your first draft","perfect","work"),
        ("warning","The warning light","repair","signal"),
        ("silence","Their silence","release","signal"),
        ("wish","Your unspoken wish","voice","message"),
        ("exhaustion","Your exhaustion","rest","feeling"),
        ("routine","Your routine","repeat","plan"),
        ("seed","Your seed","patience","living"),
        ("yes","Your yes","boundary","message"),
        ("audience","Your imaginary audience","approval","authority"),
        ("ending","The ending","loss","event"),
        ("question","Your question","unclear","message"),
    ]
    jester = [candidate("jester.setup."+i,t,c,"setup",["close","appoint","permission"],subject_type=typ) for i,t,c,typ in setups]
    closes = [
        ("only","has become your only plan.","begin",["plan"],"A supposed fallback has quietly replaced taking the main action."),
        ("eraser","has hired its eraser as a critic.","perfect",["work","message"],"Premature criticism removes the thing it claims to improve."),
        ("alarm","is not auditioning for the role of decoration.","repair",["signal"],"A real warning should not be dismissed as ornamental; caution is justified."),
        ("interview","is not accepting interviews.","release",["signal","event"],"Repeated questioning cannot force an answer from another person's silence or an ending."),
        ("whisper","has mistaken a whisper for a press release.","voice",["message"],"A private or unspoken need has been treated as if everybody already heard it."),
        ("leave","has filed for leave on your behalf.","rest",["feeling","work"],"Exhaustion acts like an employee asking for the rest the person will not request."),
        ("costume","has changed costumes, not direction.","repeat",["plan","authority"],"Superficial novelty conceals the same repeated method."),
        ("review","has declined its daily performance review.","patience",["living","work"],"A process still developing is being inspected as if it owes immediate results."),
        ("no","has been speaking without consulting your no.","boundary",["message","authority"],"Habitual agreement excludes a legitimate competing boundary."),
        ("tickets","has sold you a ticket to your own life.","approval",["authority"],"Imagined observers have claimed ownership of participation in one's own choices."),
        ("sequel","does not owe you a sequel.","loss",["event","work"],"An ending can have value without being required to continue."),
        ("question","has arrived before its own subject.","unclear",["message","plan"],"A request for an answer lacks the underlying needs that would make it meaningful."),
    ]
    jester += [candidate("jester.close."+i,t,c,"close",meaning=m,accepts=a) for i,t,c,a,m in closes]
    jester.append(candidate("jester.appoint", "has appointed itself", "approval", "appoint", ["office"],
                            meaning="An obstacle or imagined authority awards itself power it has not earned.",
                            accepts=["authority","plan","message","feeling"]))
    jester.append(candidate("jester.permission", "is waiting for permission", "begin", "permission", ["permission_source"],
                            meaning="The selected thing is waiting for approval from an absurd or inappropriate source.",
                            accepts=["work","plan","message"]))
    jester += [
        candidate("jester.office.judge","judge of the first attempt.","perfect","office"),
        candidate("jester.office.gate","keeper of an open gate.","begin","office"),
        candidate("jester.office.everyone","spokesperson for everyone.","approval","office"),
        candidate("jester.source.eraser","from its own eraser.","perfect","permission_source",accepts=["work","message"]),
        candidate("jester.source.audience","from an audience that has not arrived.","approval","permission_source"),
        candidate("jester.source.backup","from its own backup plan.","begin","permission_source",accepts=["work","message"]),
    ]
    catalog("jester", "jester", "phrase_sequence", 2, 3, jester,
            "Create one readable absurd reversal tied to the user's actual tension. Mock an unhelpful arrangement, not the person's worth. Preserve one central metaphor; surprise must have a discernible reason. Do not trivialize real danger or grief.")

    result = dict(schemaVersion="language-lab-1", catalogVersion=VERSION,
                  semantics={k:dict(meaning=v[0],useWhen=v[1],avoidWhen=v[2],contrast=v[3]) for k,v in SEMANTICS.items()},
                  catalogs=catalogs)
    (ROOT/"catalogs.json").write_text(json.dumps(result,ensure_ascii=False,indent=2)+"\n")
    return result


if __name__ == "__main__":
    result=build()
    print({k:len(v["candidates"]) for k,v in result["catalogs"].items()})
