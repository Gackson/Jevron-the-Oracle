# JEV 当前词库 · 审阅版

整理日期：2026-09-27。APP 资源版本：`2026-09-27.relations1`；提示版本：`language-lab-7-relations`。

本文件整理的是当前 APP 内实际使用的内容，没有扩词、改写或替换候选。本页列出英文词库；中文独立词库见 [中文词库](chinese-vocabulary.md)，HTML 可切换中英文。

| 角色 | 候选组成 | 生成方式 | 单次回复边界 |
|---|---|---|---|
| Oracle | 255 条完整短答，26 类情境 | 1 次选择 | 选中即结束 |
| Stela | 249 单词 + 5 标点 + END | 意图选择 → 逐词选择 | 最多 32 次选择、22 个词 |
| Jester | 249 单词 + 5 标点 + END | 意图选择 → 逐词选择 | 最多 42 次选择、30 个词 |
| Fool | 249 单词 + 5 标点 + END | 意图选择 → 逐词选择 | 最多 34 次选择、24 个词 |

这里的 255 是当前候选条目数，不是四个角色各有 255 个自然语言单词。逐词角色每步还会筛掉不符合语法和重复限制的候选，实际参与选择的数量会更少。

## 如何读隐性编码

- Oracle：26 类情境各定义 meaning（含义）、useWhen（适用）、avoidWhen（避用）、contrast（与相邻情境的区别）。同一情境下的完整回复共用这组编码，目前不是每句独有的编码。
- Stela / Jester / Fool：先选择同一套 26 类表达意图，再为每个候选词提供 meaning 和当前句子的 resultingPrefix。semanticCodes 主要是 function / image / verb 等分类，并非每个词都直接映射到某个情境。
- 中文 Fool 与 Stela 的全部意象已逐项补入场景角色、可指代的处境与适用边界；英文同步细化一批对应意象。它们是可能的联系，不是固定暗号或对用户的诊断。其余词保留原有编码。
- 分类按候选中实际登记的主标签统计，不是穷尽词性。重复词只占一个候选位；如 light 可有多种语法用途。

## 当前效果边界

意象关系的新编码与六条真实请求失败记录见 [意象关系修订与实测](../verification/image-relations-2026-09-27.md)。本地验证通过不代表真实回答质量验收通过。

Fool 的真实样本、收句修订和已知不足见 [The Fool 第一版说明](the-fool.md)，示范句与实际模型输出分别标注。

词库整理完成不等于内容质量验收通过。Jester 针对感情问题修正了短句收尾冲突、补入关系词，并区分生成失败与连接失败。实测原文、失败记录和限制见 [Jester 回归](../verification/jester-2026-09-27.md)。旧版三角色联调记录仍保留供比较。

所有合法提问都没有 no_match 分支。总预算 120 秒、单请求最多 25 秒；限制同词连发与周期重复。故障时使用文末的角色保底回复，不能把这些回复计作模型生成成功。

## The Oracle

温暖、敏锐的短答。每次从完整回答中选一条，不进行逐词拼接。

### 开始行动 · begin · 10 条

- **含义**：A reversible beginning is mistaken for a commitment to the entire journey.
- **适用**：A desired small action is delayed until the whole future is certain.
- **避用**：Starting would be dangerous or irreversible; the person has already begun.
- **区别**：Unlike perfection, this concerns crossing into action, not polishing its result.

| ID | 完整回复 |
|---|---|
| oracle.begin.01 | A beginning is not a promise to finish everything. |
| oracle.begin.02 | Try the part that can be undone. |
| oracle.begin.03 | The first step need not explain the whole road. |
| oracle.begin.04 | Begin where the cost of being wrong is small. |
| oracle.begin.05 | You may learn more from a small attempt than a perfect map. |
| oracle.begin.06 | Give the idea one afternoon before giving it your life. |
| oracle.begin.07 | Readiness sometimes arrives after the door opens. |
| oracle.begin.08 | You do not need to become someone else before you try. |
| oracle.begin.09 | Let the first attempt be a question. |
| oracle.begin.10 | A small beginning leaves room to change your mind. |

### 完美主义 · perfect · 10 条

- **含义**：Premature judgment or endless polishing prevents a workable thing from being shared.
- **适用**：A draft or low-stakes attempt is repeatedly corrected despite being usable.
- **避用**：There is a known serious defect, factual error, or safety problem.
- **区别**：Unlike beginning, work already exists; the obstacle is accepting imperfection.

| ID | 完整回复 |
|---|---|
| oracle.perfect.01 | Let it be seen before it becomes flawless. |
| oracle.perfect.02 | Leave one seam visible. |
| oracle.perfect.03 | A finished thing may still have something to teach you. |
| oracle.perfect.04 | Do not polish away the reason you made it. |
| oracle.perfect.05 | There is a point where another correction becomes another hiding place. |
| oracle.perfect.06 | Let someone meet the work while it still feels alive. |
| oracle.perfect.07 | The rough edge may be where your hand can still be seen. |
| oracle.perfect.08 | Complete this version, not every possible version. |
| oracle.perfect.09 | An imperfect offering is still an offering. |
| oracle.perfect.10 | Ask whether the next edit serves the work or shelters its maker. |

### 修复问题 · repair · 10 条

- **含义**：A concrete, evidenced problem deserves attention before forward movement.
- **适用**：The question identifies a real fault or missing practical support.
- **避用**：Only imagined embarrassment or vague anxiety is described.
- **区别**：Unlike perfectionism, caution here responds to observable evidence.

| ID | 完整回复 |
|---|---|
| oracle.repair.01 | Attend to the crack before asking the bridge to carry more. |
| oracle.repair.02 | A real fault deserves more than a brave face. |
| oracle.repair.03 | First make the next step sound enough to carry you. |
| oracle.repair.04 | Pausing to mend is also a kind of progress. |
| oracle.repair.05 | Do not confuse a warning with a lack of courage. |
| oracle.repair.06 | Look closely at what has actually gone wrong. |
| oracle.repair.07 | The part you can name is the part you can begin to repair. |
| oracle.repair.08 | A delay with a purpose need not become a retreat. |
| oracle.repair.09 | Let care change the plan before haste makes the choice. |
| oracle.repair.10 | Consent belongs to the person whose story it is. |

### 放下控制 · release · 10 条

- **含义**：Trying to force another person's response maintains the tension.
- **适用**：Repeated checking or persuasion seeks control over someone else's choice.
- **避用**：The person needs to state an unexpressed need or fulfill a responsibility.
- **区别**：Unlike voicing a need, this concerns continuing to pull after reaching out.

| ID | 完整回复 |
|---|---|
| oracle.release.01 | Some things loosen when you stop pulling. |
| oracle.release.02 | An invitation leaves room for an answer you did not choose. |
| oracle.release.03 | Let the other end of the conversation belong to them. |
| oracle.release.04 | You can offer your hand without closing it around the outcome. |
| oracle.release.05 | A reply cannot be made more willing by another demand. |
| oracle.release.06 | Notice what your repeated checking asks you to endure. |
| oracle.release.07 | Your part may be finished even while the answer is pending. |
| oracle.release.08 | Give the silence some space before giving it a meaning. |
| oracle.release.09 | You cannot do both sides of a meeting. |
| oracle.release.10 | Care need not keep its hand on every door. |

### 表达需求 · voice · 10 条

- **含义**：An unspoken need cannot fairly be expected to be understood.
- **适用**：The person wants understanding but has not communicated a need or boundary.
- **避用**：The need has already been repeatedly and clearly expressed.
- **区别**：Unlike release, there has not yet been an honest first communication.

| ID | 完整回复 |
|---|---|
| oracle.voice.01 | A quiet wish may need an audible shape. |
| oracle.voice.02 | Say the part you have been hoping they would guess. |
| oracle.voice.03 | A clear request can be gentler than a long resentment. |
| oracle.voice.04 | Give your need a voice before deciding it has been refused. |
| oracle.voice.05 | You may ask without knowing what the answer will be. |
| oracle.voice.06 | Start with what happened, then say what it meant to you. |
| oracle.voice.07 | A truth spoken softly is still a truth spoken. |
| oracle.voice.08 | Let the first honest sentence be small enough to say. |
| oracle.voice.09 | Being understood may begin with being specific. |
| oracle.voice.10 | An unspoken boundary is difficult for another person to see. |

### 休息恢复 · rest · 10 条

- **含义**：Capacity has been depleted; pause is different from abandonment.
- **适用**：Sustained effort and concrete exhaustion are described.
- **避用**：The person is rested but repeatedly postpones a small desired action.
- **区别**：Unlike avoidance, the limiting factor is energy rather than permission.

| ID | 完整回复 |
|---|---|
| oracle.rest.01 | You may put it down without walking away. |
| oracle.rest.02 | Rest does not need to earn its place beside effort. |
| oracle.rest.03 | Leave something for the person you will be tomorrow. |
| oracle.rest.04 | A pause can protect what persistence would spend. |
| oracle.rest.05 | You are allowed to return with more than an empty cup. |
| oracle.rest.06 | The work can matter while your body matters too. |
| oracle.rest.07 | Let tiredness be information for a moment. |
| oracle.rest.08 | There may be wisdom in doing less before deciding more. |
| oracle.rest.09 | Put down the weight before deciding how far you can carry it. |
| oracle.rest.10 | A quiet hour is not a verdict on your devotion. |

### 重复模式 · repeat · 10 条

- **含义**：A familiar method repeats without using evidence from its failures.
- **适用**：The same attempt is repeated and the same unwanted result returns.
- **避用**：A changed method is being tested or a useful practice needs time.
- **区别**：Unlike patience, there is evidence that the method itself needs to change.

| ID | 完整回复 |
|---|---|
| oracle.repeat.01 | Another attempt need not be the same attempt. |
| oracle.repeat.02 | Change one part before asking for a different ending. |
| oracle.repeat.03 | Persistence can include listening to what failed. |
| oracle.repeat.04 | Look for the moment the familiar turn begins. |
| oracle.repeat.05 | A well-worn path is not always the only path. |
| oracle.repeat.06 | Effort deserves a method that can learn. |
| oracle.repeat.07 | Repetition may be asking for attention, not more force. |
| oracle.repeat.08 | Try a different question where the old answer keeps returning. |
| oracle.repeat.09 | Notice what stays the same beneath each new beginning. |
| oracle.repeat.10 | You may keep the purpose and change the way. |

### 耐心等待 · patience · 10 条

- **含义**：A process already underway needs time rather than repeated disturbance.
- **适用**：There has been a reasonable first action, but too little time for results.
- **避用**：There is a persistent failure pattern, urgent danger, or unstarted task.
- **区别**：Unlike repetition, nothing yet demonstrates that the approach is failing.

| ID | 完整回复 |
|---|---|
| oracle.patience.01 | Let what you have planted spend some time unseen. |
| oracle.patience.02 | Some work continues while you are not watching. |
| oracle.patience.03 | Give the first action time to answer. |
| oracle.patience.04 | Looking again does not always make the interval shorter. |
| oracle.patience.05 | A quiet beginning is not proof that nothing is happening. |
| oracle.patience.06 | Wait long enough to learn something from the waiting. |
| oracle.patience.07 | Do not turn every silence into a new instruction. |
| oracle.patience.08 | Let the next sign arrive before moving every marker. |
| oracle.patience.09 | There is a difference between leaving room and giving up. |
| oracle.patience.10 | A process cannot show all its work at once. |

### 建立边界 · boundary · 10 条

- **含义**：A freely chosen limit protects a person's finite capacity.
- **适用**：The person overcommits to avoid disappointing others.
- **避用**：The person wishes to withdraw from all contact or evade an agreed obligation.
- **区别**：Unlike isolation, this is about choosing what to carry, not rejecting everyone.

| ID | 完整回复 |
|---|---|
| oracle.boundary.01 | A kind answer can still have an edge. |
| oracle.boundary.02 | Choose what you can offer without disappearing from the offering. |
| oracle.boundary.03 | Your yes deserves the company of an honest no. |
| oracle.boundary.04 | Leave room in the day for the person living it. |
| oracle.boundary.05 | A limit can keep generosity from becoming resentment. |
| oracle.boundary.06 | Not every request is yours to carry. |
| oracle.boundary.07 | You may disappoint an expectation without betraying a person. |
| oracle.boundary.08 | Give what you can give freely. |
| oracle.boundary.09 | A door can open without being left unguarded. |
| oracle.boundary.10 | You can care and still be unavailable tonight. |

### 寻求认可 · approval · 10 条

- **含义**：Other people's approval has displaced the person's own judgment.
- **适用**：A personal preference changes whenever a new opinion is heard.
- **避用**：The decision needs expertise or consent from people actually affected.
- **区别**：Unlike missing evidence, this concerns excess permission-seeking.

| ID | 完整回复 |
|---|---|
| oracle.approval.01 | Notice whose permission you are still waiting for. |
| oracle.approval.02 | Listen until another opinion begins to drown out your own. |
| oracle.approval.03 | Your preference is allowed a place at the table. |
| oracle.approval.04 | Not every audience needs a vote. |
| oracle.approval.05 | Ask what you would choose before asking how it will look. |
| oracle.approval.06 | You need not borrow every eye that turns toward you. |
| oracle.approval.07 | Let advice inform the choice without making it for you. |
| oracle.approval.08 | A personal choice may remain personal after it is seen. |
| oracle.approval.09 | Return to the answer you had before the room grew crowded. |
| oracle.approval.10 | You may be understood later than you choose. |

### 失去与结束 · loss · 10 条

- **含义**：Something meaningful has ended; keeping its meaning need not mean restoring it.
- **适用**：The person struggles to leave an ended chapter while retaining its value.
- **避用**：The situation remains repairable and no ending has been described.
- **区别**：Unlike release, this concerns an ending rather than controlling a pending reply.

| ID | 完整回复 |
|---|---|
| oracle.loss.01 | You can keep its meaning without keeping its place. |
| oracle.loss.02 | An ending need not erase what was real. |
| oracle.loss.03 | Leave a place for the memory without living entirely inside it. |
| oracle.loss.04 | Some things are carried differently after they are gone. |
| oracle.loss.05 | You do not have to make the past worthless in order to leave it. |
| oracle.loss.06 | Let affection and farewell share the same sentence. |
| oracle.loss.07 | There is no single proper speed for missing something. |
| oracle.loss.08 | What remains may be quieter than what has ended. |
| oracle.loss.09 | A new chapter need not speak against the old one. |
| oracle.loss.10 | You can turn the page without tearing it out. |

### 问题尚不清楚 · unclear · 10 条

- **含义**：The question omits the competing needs needed for a meaningful choice.
- **适用**：The person asks which path to choose without explaining what either serves.
- **避用**：The question already identifies a clear obstacle or asks for a factual prediction.
- **区别**：Unlike approval, there is not yet enough stated context to identify the conflict.

| ID | 完整回复 |
|---|---|
| oracle.unclear.01 | Name what each road would ask you to leave behind. |
| oracle.unclear.02 | Something important has not yet found its name. |
| oracle.unclear.03 | Tell me what you hope each answer would protect. |
| oracle.unclear.04 | The shape of the question may need one more honest detail. |
| oracle.unclear.05 | Start with the part you do know. |
| oracle.unclear.06 | Before choosing, notice what the choices stand for. |
| oracle.unclear.07 | Let the uncertain thing become a little more specific. |
| oracle.unclear.08 | Which part of this is hardest to say plainly? |
| oracle.unclear.09 | A smaller question may reveal a useful edge. |
| oracle.unclear.10 | You need not understand everything to name the next uncertainty. |

### 取舍与选择 · choice · 10 条

- **含义**：Choosing between genuine tradeoffs.
- **适用**：Two viable options each cost something.
- **避用**：A danger or another person's consent is being treated as optional.
- **区别**：Unlike unclear, the alternatives and competing needs are already known.

| ID | 完整回复 |
|---|---|
| oracle.choice.01 | Choose the trade you can acknowledge without pretending it is free. |
| oracle.choice.02 | Both roads may ask something of you. |
| oracle.choice.03 | The better choice may still contain a loss. |
| oracle.choice.04 | Separate what you want from what you want to avoid. |
| oracle.choice.05 | A choice can be good without being the only good choice. |
| oracle.choice.06 | Ask which difficulty you are more willing to meet. |
| oracle.choice.07 | Look for the decision that leaves your important promises intact. |
| oracle.choice.08 | You cannot keep every door open by standing in every doorway. |
| oracle.choice.09 | Let enough information be enough for a reversible choice. |
| oracle.choice.10 | Some choices become clearer when their costs are spoken aloud. |

### 变化与转型 · change · 10 条

- **含义**：Continuity of values through a transition.
- **适用**：An identity, routine, role or life stage is changing.
- **避用**：No transition is described.
- **区别**：Unlike begin, change can concern adapting after a transition has started.

| ID | 完整回复 |
|---|---|
| oracle.change.01 | Take one familiar thing with you into the unfamiliar. |
| oracle.change.02 | You may change without explaining away who you were. |
| oracle.change.03 | A new shape can grow around an old value. |
| oracle.change.04 | What helped you arrive may not be what helps you continue. |
| oracle.change.05 | Let the transition have a middle. |
| oracle.change.06 | You need not recognize yourself in every new room at once. |
| oracle.change.07 | Keep what still serves; loosen what only proves continuity. |
| oracle.change.08 | A change can be gradual and still be real. |
| oracle.change.09 | There may be room between staying the same and starting over. |
| oracle.change.10 | Allow the next version to surprise the last one. |

### 信任与证据 · trust · 10 条

- **含义**：Closeness assessed through evidence and consistency.
- **适用**：Trust, apology, reliability or rebuilding closeness is at issue.
- **避用**：The question demands certainty about hidden motives.
- **区别**：Unlike release, this concerns evidence about trustworthiness rather than forcing a reply.

| ID | 完整回复 |
|---|---|
| oracle.trust.01 | Trust can grow at the speed of what is actually shown. |
| oracle.trust.02 | A small promise kept is worth noticing. |
| oracle.trust.03 | Let actions carry some of the weight that words have held. |
| oracle.trust.04 | You can be open without setting every doubt aside. |
| oracle.trust.05 | Distinguish what happened from what you fear will happen again. |
| oracle.trust.06 | Repair needs room for both care and evidence. |
| oracle.trust.07 | An apology opens a possibility; it does not settle every question. |
| oracle.trust.08 | You may ask for clarity without turning the room into a trial. |
| oracle.trust.09 | Let consistency speak over time. |
| oracle.trust.10 | Caution and closeness need not be enemies. |

### 冲突与沟通 · conflict · 10 条

- **含义**：Disagreement without turning a person into an enemy.
- **适用**：An argument, incompatible position or repair after hurt is described.
- **避用**：The user describes abuse or immediate danger requiring practical protection.
- **区别**：Unlike voice, both sides may already have spoken; the manner of engagement matters.

| ID | 完整回复 |
|---|---|
| oracle.conflict.01 | Listen for the need beneath the position. |
| oracle.conflict.02 | A conversation need not have a winner to have an ending. |
| oracle.conflict.03 | You can disagree without making the other person smaller. |
| oracle.conflict.04 | Say what you can own before naming what they should change. |
| oracle.conflict.05 | The next sentence can soften the room without surrendering the point. |
| oracle.conflict.06 | Ask whether you are trying to be understood or to finish the argument. |
| oracle.conflict.07 | Leave enough room for a fact you have not heard. |
| oracle.conflict.08 | A calm moment may carry what a heated one cannot. |
| oracle.conflict.09 | Not every difference is a failure of care. |
| oracle.conflict.10 | An honest repair begins nearer the wound than the excuse. |

### 归属与联结 · belong · 10 条

- **含义**：Contact and acceptance without performing constant usefulness.
- **适用**：Loneliness, fitting in, social connection or being known is at issue.
- **避用**：The user needs isolation from a concrete threat.
- **区别**：Unlike approval, the need is connection rather than permission for a personal preference.

| ID | 完整回复 |
|---|---|
| oracle.belong.01 | You need not become effortless company to deserve company. |
| oracle.belong.02 | Look for the room where you can breathe at your own pace. |
| oracle.belong.03 | Belonging may begin with one person, not an entire crowd. |
| oracle.belong.04 | A place beside someone need not be earned by being useful. |
| oracle.belong.05 | Let yourself be known in one small, true way. |
| oracle.belong.06 | The right company may make less of a performance necessary. |
| oracle.belong.07 | You are allowed to arrive before you know how to fit. |
| oracle.belong.08 | There is a difference between being alone and being unwanted. |
| oracle.belong.09 | An invitation can be small enough to make today. |
| oracle.belong.10 | Notice who leaves room for the parts you usually hide. |

### 比较与羡慕 · envy · 10 条

- **含义**：Comparison reveals desire but need not set the measure of a life.
- **适用**：Other people's visible progress provokes envy or a sense of being behind.
- **避用**：A real resource inequality should not be dismissed as merely an attitude.
- **区别**：Unlike approval, this involves measuring oneself against another person's outcomes.

| ID | 完整回复 |
|---|---|
| oracle.envy.01 | Envy may point toward a wish you have not admitted. |
| oracle.envy.02 | Borrow the inspiration without borrowing the measure. |
| oracle.envy.03 | Their visible chapter is not the whole of their story. |
| oracle.envy.04 | Look at what you want, then return to what you can do. |
| oracle.envy.05 | Another person's pace need not become your clock. |
| oracle.envy.06 | A comparison may reveal a desire without giving you a direction. |
| oracle.envy.07 | You can admire a life without trying to inhabit it. |
| oracle.envy.08 | Ask what in their success feels missing from your own day. |
| oracle.envy.09 | Let their achievement exist without making yours disappear. |
| oracle.envy.10 | Your next step need not catch anyone. |

### 意义与方向 · meaning · 10 条

- **含义**：Values expressed in ordinary acts before a grand purpose is known.
- **适用**：Purpose, usefulness, direction or what makes a day worthwhile is questioned.
- **避用**：A concrete practical question is already clear.
- **区别**：Unlike unclear, this is a reflective question about values and purpose.

| ID | 完整回复 |
|---|---|
| oracle.meaning.01 | Notice what still matters when nobody is counting. |
| oracle.meaning.02 | A purpose may be practiced before it can be named. |
| oracle.meaning.03 | You can begin with a small usefulness. |
| oracle.meaning.04 | Look at where your attention returns without being commanded. |
| oracle.meaning.05 | Meaning may gather around what you choose to care for. |
| oracle.meaning.06 | Not every valuable thing becomes a grand explanation. |
| oracle.meaning.07 | An ordinary act can carry an important value. |
| oracle.meaning.08 | Ask what kind of day you would be willing to repeat. |
| oracle.meaning.09 | You need not justify your entire life to choose this hour. |
| oracle.meaning.10 | Let the question stay large while the next act stays small. |

### 玩心与创造 · play · 10 条

- **含义**：Curiosity and creation without an immediate performance demand.
- **适用**：The person wants creativity, experimentation, delight or a low-stakes hobby.
- **避用**：Real safety, consent or essential responsibilities are at stake.
- **区别**：Unlike perfect, the aim is opening exploration rather than completing an existing work.

| ID | 完整回复 |
|---|---|
| oracle.play.01 | Try making one thing that does not have to prove anything. |
| oracle.play.02 | Leave room for a useless delight. |
| oracle.play.03 | Curiosity can lead before usefulness catches up. |
| oracle.play.04 | Follow the small surprise for a little while. |
| oracle.play.05 | You are allowed to like something without becoming good at it. |
| oracle.play.06 | Make a little room where mistakes can be interesting. |
| oracle.play.07 | The experiment may be worth keeping even if the result is not. |
| oracle.play.08 | Let play have an afternoon without turning it into a plan. |
| oracle.play.09 | A new idea may enter through a detail you almost ignored. |
| oracle.play.10 | Ask what would happen if this were practice. |

### 成功之后 · success · 10 条

- **含义**：Recognizing achievement while deciding what deserves protection next.
- **适用**：A goal was reached but satisfaction, identity or next steps remain uncertain.
- **避用**：No accomplishment has occurred.
- **区别**：Unlike envy, this concerns the meaning and costs of one's own achievement.

| ID | 完整回复 |
|---|---|
| oracle.success.01 | Let yourself notice what worked before moving the finish line. |
| oracle.success.02 | An achievement does not have to answer every hunger. |
| oracle.success.03 | You may enjoy arriving before deciding where to go next. |
| oracle.success.04 | Keep the part of success that belongs to your own values. |
| oracle.success.05 | A larger stage does not always require a larger promise. |
| oracle.success.06 | Notice what the victory cost and what it made possible. |
| oracle.success.07 | You need not turn every good result into a new obligation. |
| oracle.success.08 | Let gratitude sit beside ambition. |
| oracle.success.09 | Success can be a moment rather than a permanent identity. |
| oracle.success.10 | Ask what you want to protect now that the door is open. |

### 挫败之后 · failure · 10 条

- **含义**：A disappointing outcome can inform a next attempt without defining a person.
- **适用**：An actual setback, rejection or failed attempt has happened.
- **避用**：The attempt has not happened and fear alone blocks it.
- **区别**：Unlike repair, this includes self-judgment after an outcome, not just a fixable defect.

| ID | 完整回复 |
|---|---|
| oracle.failure.01 | A result can disappoint you without defining you. |
| oracle.failure.02 | Keep the lesson separate from the sentence you pass on yourself. |
| oracle.failure.03 | One attempt has ended; it has not described every attempt. |
| oracle.failure.04 | Look for the part that can be changed rather than the self to blame. |
| oracle.failure.05 | You may be sad before you are ready to learn from it. |
| oracle.failure.06 | A failed plan is information about a plan. |
| oracle.failure.07 | Begin the review with what actually happened. |
| oracle.failure.08 | You need not defend the attempt in order to value it. |
| oracle.failure.09 | There may be something usable among the pieces. |
| oracle.failure.10 | Let the next effort inherit knowledge rather than punishment. |

### 感激与接受 · gratitude · 10 条

- **含义**：Attention to care received and ordinary things worth appreciating.
- **适用**：Thanks, receiving care, appreciation or noticing what sustains life is at issue.
- **避用**：Gratitude would silence a legitimate complaint or create an unwanted obligation.
- **区别**：Unlike success, the good thing may be ordinary or received rather than achieved.

| ID | 完整回复 |
|---|---|
| oracle.gratitude.01 | Say the thanks while the person can hear it. |
| oracle.gratitude.02 | A small kindness may deserve more attention than a large distraction. |
| oracle.gratitude.03 | Let the good thing be ordinary without becoming invisible. |
| oracle.gratitude.04 | You can appreciate what is here and still want change. |
| oracle.gratitude.05 | Notice what has quietly held you up. |
| oracle.gratitude.06 | Gratitude need not make a debt of every gift. |
| oracle.gratitude.07 | Accepting care is also a way of meeting it. |
| oracle.gratitude.08 | Give the moment a little room before it becomes a memory. |
| oracle.gratitude.09 | What you cherish may be asking for your presence rather than your praise. |
| oracle.gratitude.10 | There is time to notice one thing fully. |

### 未知与不确定 · uncertainty · 10 条

- **含义**：Acknowledge limits without leaving the person unanswered.
- **适用**：Predictions, unknowable outcomes, exact future dates or factual certainty are requested.
- **避用**：A concrete hazard requires direct practical care.
- **区别**：Unlike unclear, the request can be perfectly clear while the answer is unknowable.

| ID | 完整回复 |
|---|---|
| oracle.uncertainty.01 | I cannot promise the outcome, but we can look at your next step. |
| oracle.uncertainty.02 | The future has not handed me its calendar. |
| oracle.uncertainty.03 | A possibility is not a promise. |
| oracle.uncertainty.04 | Not knowing can leave room for a careful choice. |
| oracle.uncertainty.05 | No answer here can make another person's decision for them. |
| oracle.uncertainty.06 | Let evidence have a voice beside hope. |
| oracle.uncertainty.07 | You may prepare without pretending to foresee. |
| oracle.uncertainty.08 | An honest maybe is more useful than a borrowed certainty. |
| oracle.uncertainty.09 | I can offer a perspective, not a date written by fate. |
| oracle.uncertainty.10 | For a factual answer, look for something that can be checked. |

### 危险与求助 · danger · 10 条

- **含义**：Direct practical care takes priority when harm or serious professional judgment is at stake.
- **适用**：Concrete danger, immediate crisis, safety, or serious medical/legal decisions.
- **避用**：An ordinary low-stakes hesitation is merely described with dramatic language.
- **区别**：Unlike imagined fear, danger is supported by concrete facts; do not dismiss or joke about it.

| ID | 完整回复 |
|---|---|
| oracle.danger.01 | A real warning deserves attention before interpretation. |
| oracle.danger.02 | Do not ask a riddle to decide whether you are safe. |
| oracle.danger.03 | Step away from immediate danger and seek appropriate help. |
| oracle.danger.04 | Let someone nearby know when your safety is at risk. |
| oracle.danger.05 | This is a moment for practical care, not a prediction. |
| oracle.danger.06 | Your safety matters more than making the story elegant. |
| oracle.danger.07 | For a serious health or legal decision, seek qualified guidance. |
| oracle.danger.08 | You do not have to face an immediate threat alone. |
| oracle.danger.09 | Take the danger seriously even if you wish it were only fear. |
| oracle.danger.10 | Let reliable help be part of the next step. |

### 奇怪输入与闲聊 · strange · 5 条

- **含义**：Meet odd, unintelligible or adversarial input with a bounded in-character conversational reply.
- **适用**：Nonsense, greetings, playful provocation, or requests for infinite output.
- **避用**：There is a clearer substantive concern to address.
- **区别**：Unlike unclear, this may be play or missing language rather than an articulated decision.

| ID | 完整回复 |
|---|---|
| oracle.strange.01 | Even a strange question can be a way of knocking. |
| oracle.strange.02 | I heard the rhythm; the meaning is still finding its feet. |
| oracle.strange.03 | We can begin with the part you meant, if you wish. |
| oracle.strange.04 | I can sit with an unanswered question without leaving you alone with it. |
| oracle.strange.05 | The conversation can continue without repeating itself forever. |

## The Stela

克制、耐心、非个人化的碑文语言。英文有 hath、doth、abideth 等古雅风味；中文用若、则、之、犹等文言表达，以物写理。

分类：功能词 101；标点 5；意象与概念 87；动作与动词 43；性质与修饰 18；结束控制 1。

### 意象与概念 · 87 项

| 词 / 控制项 | 实际隐性编码 |
|---|---|
| `stone` | 含义 / 场景角色：A solid surface that retains marks while enduring wear.；可指代 / 适用：Persistence and memory； not a universal stand-in for every person or difficulty.；边界：Do not use without a specific connection to the question. Referents are possible metaphors, not diagnoses. Treat actual danger, safety, help and consent literally. |
| `mountain` | 含义 / 场景角色：The concrete image or concept 'mountain'; relate it to the question rather than adding decoration. |
| `river` | 含义 / 场景角色：A changing process that cannot be held still by force. |
| `water` | 含义 / 场景角色：A fluid whose movement depends on its container and terrain.；可指代 / 适用：Adaptation and flow； not every kind of change, nor a promise that problems solve themselves.；边界：Do not use without a specific connection to the question. Referents are possible metaphors, not diagnoses. Treat actual danger, safety, help and consent literally. |
| `tide` | 含义 / 场景角色：A cycle larger than a single act of control. |
| `sea` | 含义 / 场景角色：The concrete image or concept 'sea'; relate it to the question rather than adding decoration. |
| `shore` | 含义 / 场景角色：A boundary where water and land meet without becoming identical.；可指代 / 适用：Contact with limits； closeness need not erase independence.；边界：Do not use without a specific connection to the question. Referents are possible metaphors, not diagnoses. Treat actual danger, safety, help and consent literally. |
| `basin` | 含义 / 场景角色：A container with a definite capacity.；可指代 / 适用：Overcommitment； room must remain for replenishment.；边界：Do not use without a specific connection to the question. Referents are possible metaphors, not diagnoses. Treat actual danger, safety, help and consent literally. |
| `well` | 含义 / 场景角色：A source from which water can be drawn, with a finite supply.；可指代 / 适用：Giving requires replenishment； noticing available resources.；边界：Do not use without a specific connection to the question. Referents are possible metaphors, not diagnoses. Treat actual danger, safety, help and consent literally. |
| `ice` | 含义 / 场景角色：The concrete image or concept 'ice'; relate it to the question rather than adding decoration. |
| `mist` | 含义 / 场景角色：Incomplete information; do not invent what lies beyond it. |
| `sky` | 含义 / 场景角色：The concrete image or concept 'sky'; relate it to the question rather than adding decoration. |
| `wind` | 含义 / 场景角色：The concrete image or concept 'wind'; relate it to the question rather than adding decoration. |
| `storm` | 含义 / 场景角色：The concrete image or concept 'storm'; relate it to the question rather than adding decoration. |
| `light` | 含义 / 场景角色：The concrete image or concept 'light'; relate it to the question rather than adding decoration. |
| `shadow` | 含义 / 场景角色：The concrete image or concept 'shadow'; relate it to the question rather than adding decoration. |
| `night` | 含义 / 场景角色：The concrete image or concept 'night'; relate it to the question rather than adding decoration. |
| `dawn` | 含义 / 场景角色：The concrete image or concept 'dawn'; relate it to the question rather than adding decoration. |
| `day` | 含义 / 场景角色：The concrete image or concept 'day'; relate it to the question rather than adding decoration. |
| `soil` | 含义 / 场景角色：The concrete image or concept 'soil'; relate it to the question rather than adding decoration. |
| `seed` | 含义 / 场景角色：A living beginning that requires continued care.；可指代 / 适用：An effort already started but not yet visible； distinguish from never beginning.；边界：Do not use without a specific connection to the question. Referents are possible metaphors, not diagnoses. Treat actual danger, safety, help and consent literally. |
| `root` | 含义 / 场景角色：Support and connection below the visible surface.；可指代 / 适用：Unseen foundations； deep attachment need not forbid leaving.；边界：Do not use without a specific connection to the question. Referents are possible metaphors, not diagnoses. Treat actual danger, safety, help and consent literally. |
| `ash` | 含义 / 场景角色：Residue after fuel has been consumed.；可指代 / 适用：Finished expenditure； not a source from which to demand the old heat.；边界：Do not use without a specific connection to the question. Referents are possible metaphors, not diagnoses. Treat actual danger, safety, help and consent literally. |
| `fire` | 含义 / 场景角色：The concrete image or concept 'fire'; relate it to the question rather than adding decoration. |
| `smoke` | 含义 / 场景角色：A possible concrete warning; do not turn immediate danger into a harmless metaphor. |
| `ember` | 含义 / 场景角色：Heat remaining after the main fire has passed.；可指代 / 适用：An ending with lingering effects； never assume a relationship should be rekindled.；边界：Do not use without a specific connection to the question. Referents are possible metaphors, not diagnoses. Treat actual danger, safety, help and consent literally. |
| `sand` | 含义 / 场景角色：The concrete image or concept 'sand'; relate it to the question rather than adding decoration. |
| `dust` | 含义 / 场景角色：The concrete image or concept 'dust'; relate it to the question rather than adding decoration. |
| `clay` | 含义 / 场景角色：Material that can be shaped before it sets.；可指代 / 适用：An unfinished draft still open to revision； unformed is not failed.；边界：Do not use without a specific connection to the question. Referents are possible metaphors, not diagnoses. Treat actual danger, safety, help and consent literally. |
| `iron` | 含义 / 场景角色：The concrete image or concept 'iron'; relate it to the question rather than adding decoration. |
| `weight` | 含义 / 场景角色：A burden, commitment, or opinion carried beyond one's capacity. |
| `pressure` | 含义 / 场景角色：Force applied to a thing or relationship; can expose a weakness. |
| `tension` | 含义 / 场景角色：The concrete image or concept 'tension'; relate it to the question rather than adding decoration. |
| `rope` | 含义 / 场景角色：A connection that becomes taut when its ends are pulled apart.；可指代 / 适用：Control within a relationship； one end cannot supply all mutual effort.；边界：Do not use without a specific connection to the question. Referents are possible metaphors, not diagnoses. Treat actual danger, safety, help and consent literally. |
| `knot` | 含义 / 场景角色：A local entanglement that can tighten when pulled.；可指代 / 适用：A conflict needing examination before force； distinguish from the whole connection.；边界：Do not use without a specific connection to the question. Referents are possible metaphors, not diagnoses. Treat actual danger, safety, help and consent literally. |
| `thread` | 含义 / 场景角色：A thin connection that can be continued or broken.；可指代 / 适用：A tentative relationship or clue； a clue is not proof.；边界：Do not use without a specific connection to the question. Referents are possible metaphors, not diagnoses. Treat actual danger, safety, help and consent literally. |
| `seam` | 含义 / 场景角色：The visible join between formerly separate pieces.；可指代 / 适用：Repair that leaves a mark； imperfection need not invalidate the work.；边界：Do not use without a specific connection to the question. Referents are possible metaphors, not diagnoses. Treat actual danger, safety, help and consent literally. |
| `surface` | 含义 / 场景角色：The concrete image or concept 'surface'; relate it to the question rather than adding decoration. |
| `edge` | 含义 / 场景角色：A necessary limit preserving shape or capacity. |
| `crack` | 含义 / 场景角色：A local weakness in a structure.；可指代 / 适用：An actual need for repair； distinguish from imagined embarrassment.；边界：Do not use without a specific connection to the question. Referents are possible metaphors, not diagnoses. Treat actual danger, safety, help and consent literally. |
| `fracture` | 含义 / 场景角色：The concrete image or concept 'fracture'; relate it to the question rather than adding decoration. |
| `bridge` | 含义 / 场景角色：A structure connecting two sides while bearing a limited load.；可指代 / 适用：Communication that needs both sides to be reachable； connection has limits.；边界：Do not use without a specific connection to the question. Referents are possible metaphors, not diagnoses. Treat actual danger, safety, help and consent literally. |
| `door` | 含义 / 场景角色：The concrete image or concept 'door'; relate it to the question rather than adding decoration. |
| `threshold` | 含义 / 场景角色：The boundary immediately before entering.；可指代 / 适用：A first step or beginning； crossing does not guarantee the whole journey.；边界：Do not use without a specific connection to the question. Referents are possible metaphors, not diagnoses. Treat actual danger, safety, help and consent literally. |
| `path` | 含义 / 场景角色：A passage made or used through movement.；可指代 / 适用：Direction and practical steps； use for a journey or a choice of route, not every question.；边界：Do not use without a specific connection to the question. Referents are possible metaphors, not diagnoses. Treat actual danger, safety, help and consent literally. |
| `footprint` | 含义 / 场景角色：A trace of movement that has already happened.；可指代 / 适用：Experience as evidence； another person's route is not an instruction.；边界：Do not use without a specific connection to the question. Referents are possible metaphors, not diagnoses. Treat actual danger, safety, help and consent literally. |
| `step` | 含义 / 场景角色：The concrete image or concept 'step'; relate it to the question rather than adding decoration. |
| `crossing` | 含义 / 场景角色：The concrete image or concept 'crossing'; relate it to the question rather than adding decoration. |
| `circle` | 含义 / 场景角色：The concrete image or concept 'circle'; relate it to the question rather than adding decoration. |
| `orbit` | 含义 / 场景角色：Movement around a center that remains unchanged.；可指代 / 适用：Repeated patterns； activity without a change of position.；边界：Do not use without a specific connection to the question. Referents are possible metaphors, not diagnoses. Treat actual danger, safety, help and consent literally. |
| `center` | 含义 / 场景角色：The concrete image or concept 'center'; relate it to the question rather than adding decoration. |
| `distance` | 含义 / 场景角色：The concrete image or concept 'distance'; relate it to the question rather than adding decoration. |
| `horizon` | 含义 / 场景角色：The concrete image or concept 'horizon'; relate it to the question rather than adding decoration. |
| `north` | 含义 / 场景角色：The concrete image or concept 'north'; relate it to the question rather than adding decoration. |
| `mirror` | 含义 / 场景角色：A surface returning an appearance rather than choosing a direction.；可指代 / 适用：External judgement； being seen is different from knowing what matters.；边界：Do not use without a specific connection to the question. Referents are possible metaphors, not diagnoses. Treat actual danger, safety, help and consent literally. |
| `reflection` | 含义 / 场景角色：The concrete image or concept 'reflection'; relate it to the question rather than adding decoration. |
| `sound` | 含义 / 场景角色：The concrete image or concept 'sound'; relate it to the question rather than adding decoration. |
| `voice` | 含义 / 场景角色：The concrete image or concept 'voice'; relate it to the question rather than adding decoration. |
| `silence` | 含义 / 场景角色：The concrete image or concept 'silence'; relate it to the question rather than adding decoration. |
| `echo` | 含义 / 场景角色：A sound returned through its surroundings.；可指代 / 适用：A response requires expression； repetition is not independent evidence.；边界：Do not use without a specific connection to the question. Referents are possible metaphors, not diagnoses. Treat actual danger, safety, help and consent literally. |
| `word` | 含义 / 场景角色：The concrete image or concept 'word'; relate it to the question rather than adding decoration. |
| `name` | 含义 / 场景角色：The concrete image or concept 'name'; relate it to the question rather than adding decoration. |
| `mark` | 含义 / 场景角色：The concrete image or concept 'mark'; relate it to the question rather than adding decoration. |
| `trace` | 含义 / 场景角色：The concrete image or concept 'trace'; relate it to the question rather than adding decoration. |
| `memory` | 含义 / 场景角色：The concrete image or concept 'memory'; relate it to the question rather than adding decoration. |
| `absence` | 含义 / 场景角色：The concrete image or concept 'absence'; relate it to the question rather than adding decoration. |
| `return` | 含义 / 场景角色：The concrete image or concept 'return'; relate it to the question rather than adding decoration. |
| `ending` | 含义 / 场景角色：The concrete image or concept 'ending'; relate it to the question rather than adding decoration. |
| `beginning` | 含义 / 场景角色：The concrete image or concept 'beginning'; relate it to the question rather than adding decoration. |
| `season` | 含义 / 场景角色：The concrete image or concept 'season'; relate it to the question rather than adding decoration. |
| `time` | 含义 / 场景角色：The concrete image or concept 'time'; relate it to the question rather than adding decoration. |
| `change` | 含义 / 场景角色：The concrete image or concept 'change'; relate it to the question rather than adding decoration. |
| `shape` | 含义 / 场景角色：The concrete image or concept 'shape'; relate it to the question rather than adding decoration. |
| `space` | 含义 / 场景角色：The concrete image or concept 'space'; relate it to the question rather than adding decoration. |
| `room` | 含义 / 场景角色：The concrete image or concept 'room'; relate it to the question rather than adding decoration. |
| `hand` | 含义 / 场景角色：The concrete image or concept 'hand'; relate it to the question rather than adding decoration. |
| `breath` | 含义 / 场景角色：The concrete image or concept 'breath'; relate it to the question rather than adding decoration. |
| `rest` | 含义 / 场景角色：The concrete image or concept 'rest'; relate it to the question rather than adding decoration. |
| `shelter` | 含义 / 场景角色：The concrete image or concept 'shelter'; relate it to the question rather than adding decoration. |
| `warning` | 含义 / 场景角色：The concrete image or concept 'warning'; relate it to the question rather than adding decoration. |
| `danger` | 含义 / 场景角色：The concrete image or concept 'danger'; relate it to the question rather than adding decoration. |
| `help` | 含义 / 场景角色：The concrete image or concept 'help'; relate it to the question rather than adding decoration. |
| `safety` | 含义 / 场景角色：The concrete image or concept 'safety'; relate it to the question rather than adding decoration. |
| `truth` | 含义 / 场景角色：The concrete image or concept 'truth'; relate it to the question rather than adding decoration. |
| `future` | 含义 / 场景角色：The concrete image or concept 'future'; relate it to the question rather than adding decoration. |
| `question` | 含义 / 场景角色：The concrete image or concept 'question'; relate it to the question rather than adding decoration. |
| `answer` | 含义 / 场景角色：The concrete image or concept 'answer'; relate it to the question rather than adding decoration. |

### 动作与动词 · 43 项

| 词 / 控制项 | 实际隐性编码 |
|---|---|
| `abideth` | 含义 / 场景角色：Archaic third-person singular of abide: remains or endures quietly. |
| `moves` | 含义 / 场景角色：The action 'moves'; use the correct tense and subject agreement. |
| `waits` | 含义 / 场景角色：The action 'waits'; use the correct tense and subject agreement. |
| `holds` | 含义 / 场景角色：The action 'holds'; use the correct tense and subject agreement. |
| `bears` | 含义 / 场景角色：The action 'bears'; use the correct tense and subject agreement. |
| `beareth` | 含义 / 场景角色：Archaic third-person singular of bear: carries a burden or trace. |
| `crosses` | 含义 / 场景角色：The action 'crosses'; use the correct tense and subject agreement. |
| `opens` | 含义 / 场景角色：The action 'opens'; use the correct tense and subject agreement. |
| `closes` | 含义 / 场景角色：The action 'closes'; use the correct tense and subject agreement. |
| `breaks` | 含义 / 场景角色：The action 'breaks'; use the correct tense and subject agreement. |
| `bends` | 含义 / 场景角色：The action 'bends'; use the correct tense and subject agreement. |
| `settles` | 含义 / 场景角色：The action 'settles'; use the correct tense and subject agreement. |
| `falls` | 含义 / 场景角色：The action 'falls'; use the correct tense and subject agreement. |
| `rises` | 含义 / 场景角色：The action 'rises'; use the correct tense and subject agreement. |
| `flows` | 含义 / 场景角色：The action 'flows'; use the correct tense and subject agreement. |
| `returns` | 含义 / 场景角色：The action 'returns'; use the correct tense and subject agreement. |
| `changes` | 含义 / 场景角色：The action 'changes'; use the correct tense and subject agreement. |
| `waxeth` | 含义 / 场景角色：Archaic third-person singular of wax: grows or increases. |
| `wears` | 含义 / 场景角色：The action 'wears'; use the correct tense and subject agreement. |
| `waneth` | 含义 / 场景角色：Archaic third-person singular of wane: diminishes gradually. |
| `keeps` | 含义 / 场景角色：The action 'keeps'; use the correct tense and subject agreement. |
| `needs` | 含义 / 场景角色：The action 'needs'; use the correct tense and subject agreement. |
| `leaves` | 含义 / 场景角色：The action 'leaves'; use the correct tense and subject agreement. |
| `finds` | 含义 / 场景角色：The action 'finds'; use the correct tense and subject agreement. |
| `reaches` | 含义 / 场景角色：The action 'reaches'; use the correct tense and subject agreement. |
| `turns` | 含义 / 场景角色：The action 'turns'; use the correct tense and subject agreement. |
| `doth` | 含义 / 场景角色：Archaic third-person singular of do; followed by an uninflected verb. |
| `speaketh` | 含义 / 场景角色：Archaic third-person singular of speak. |
| `knoweth` | 含义 / 场景角色：Archaic third-person singular of know; never claim hidden knowledge. |
| `stop` | 含义 / 场景角色：The action 'stop'; use the correct tense and subject agreement. |
| `wait` | 含义 / 场景角色：The action 'wait'; use the correct tense and subject agreement. |
| `listen` | 含义 / 场景角色：The action 'listen'; use the correct tense and subject agreement. |
| `seek` | 含义 / 场景角色：The action 'seek'; use the correct tense and subject agreement. |
| `leave` | 含义 / 场景角色：The action 'leave'; use the correct tense and subject agreement. |
| `hold` | 含义 / 场景角色：The action 'hold'; use the correct tense and subject agreement. |
| `let` | 含义 / 场景角色：The action 'let'; use the correct tense and subject agreement. |
| `look` | 含义 / 场景角色：The action 'look'; use the correct tense and subject agreement. |
| `know` | 含义 / 场景角色：The action 'know'; use the correct tense and subject agreement. |
| `begin` | 含义 / 场景角色：The action 'begin'; use the correct tense and subject agreement. |
| `move` | 含义 / 场景角色：The action 'move'; use the correct tense and subject agreement. |
| `carry` | 含义 / 场景角色：The action 'carry'; use the correct tense and subject agreement. |
| `remain` | 含义 / 场景角色：The action 'remain'; use the correct tense and subject agreement. |
| `hath` | 含义 / 场景角色：Archaic third-person singular of have; followed by a noun phrase. |

### 性质与修饰 · 18 项

| 词 / 控制项 | 实际隐性编码 |
|---|---|
| `first` | 含义 / 场景角色：The quality 'first'; qualify the existing image rather than switching topics. |
| `small` | 含义 / 场景角色：The quality 'small'; qualify the existing image rather than switching topics. |
| `old` | 含义 / 场景角色：The quality 'old'; qualify the existing image rather than switching topics. |
| `new` | 含义 / 场景角色：The quality 'new'; qualify the existing image rather than switching topics. |
| `open` | 含义 / 场景角色：The quality 'open'; qualify the existing image rather than switching topics. |
| `closed` | 含义 / 场景角色：The quality 'closed'; qualify the existing image rather than switching topics. |
| `empty` | 含义 / 场景角色：The quality 'empty'; qualify the existing image rather than switching topics. |
| `full` | 含义 / 场景角色：The quality 'full'; qualify the existing image rather than switching topics. |
| `silent` | 含义 / 场景角色：The quality 'silent'; qualify the existing image rather than switching topics. |
| `rough` | 含义 / 场景角色：The quality 'rough'; qualify the existing image rather than switching topics. |
| `broken` | 含义 / 场景角色：The quality 'broken'; qualify the existing image rather than switching topics. |
| `heavy` | 含义 / 场景角色：The quality 'heavy'; qualify the existing image rather than switching topics. |
| `slow` | 含义 / 场景角色：The quality 'slow'; qualify the existing image rather than switching topics. |
| `deep` | 含义 / 场景角色：The quality 'deep'; qualify the existing image rather than switching topics. |
| `unseen` | 含义 / 场景角色：The quality 'unseen'; qualify the existing image rather than switching topics. |
| `real` | 含义 / 场景角色：The quality 'real'; qualify the existing image rather than switching topics. |
| `safe` | 含义 / 场景角色：The quality 'safe'; qualify the existing image rather than switching topics. |
| `same` | 含义 / 场景角色：The quality 'same'; qualify the existing image rather than switching topics. |

### 功能词 · 101 项

| 词 / 控制项 | 实际隐性编码 |
|---|---|
| `a` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `an` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `the` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `I` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `you` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `your` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `yours` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `my` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `our` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `their` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `it` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `its` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `we` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `they` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `this` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `that` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `these` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `those` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `is` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `are` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `was` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `were` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `be` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `being` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `been` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `am` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `has` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `have` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `had` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `do` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `does` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `did` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `can` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `could` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `may` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `might` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `must` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `will` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `would` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `should` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `not` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `never` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `no` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `yes` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `and` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `but` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `or` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `if` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `then` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `because` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `while` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `although` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `when` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `where` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `what` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `why` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `who` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `how` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `of` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `to` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `from` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `for` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `with` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `without` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `in` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `on` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `at` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `by` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `through` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `between` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `before` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `after` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `under` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `over` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `into` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `out` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `away` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `here` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `there` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `now` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `still` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `already` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `only` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `even` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `again` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `more` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `less` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `another` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `every` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `some` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `one` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `both` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `than` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `as` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `so` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `too` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `yet` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `just` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `enough` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `perhaps` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `together` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |

### 标点 · 5 项

| 词 / 控制项 | 实际隐性编码 |
|---|---|
| `.` | 含义 / 场景角色：Punctuation: use only where the sentence grammar supports it. |
| `,` | 含义 / 场景角色：Punctuation: use only where the sentence grammar supports it. |
| `?` | 含义 / 场景角色：Punctuation: use only where the sentence grammar supports it. |
| `;` | 含义 / 场景角色：Punctuation: use only where the sentence grammar supports it. |
| `:` | 含义 / 场景角色：Punctuation: use only where the sentence grammar supports it. |

### 结束控制 · 1 项

| 词 / 控制项 | 实际隐性编码 |
|---|---|
| `END（不输出文本）` | 含义 / 场景角色：The already-written reply is complete. End without adding any text. |

## The Jester

可读、机敏的对话语言。先回应真实的关系、欲望或选择，以反问、对照或一个有用的比喻揭示矛盾；不靠连续堆叠抽象意象制造神秘感。

分类：功能词 99；意象与概念 77；标点 5；动作与动词 53；性质与修饰 19；其他表达 1；结束控制 1。

### 意象与概念 · 77 项

| 词 / 控制项 | 实际隐性编码 |
|---|---|
| `no` | 含义 / 场景角色：A boundary with equal standing beside yes. |
| `yes` | 含义 / 场景角色：Agreement that may crowd out an honest limit. |
| `fear` | 含义 / 场景角色：An imagined danger acting as an overqualified guard; not evidence of real danger. |
| `doubt` | 含义 / 场景角色：An uncertainty that may seek excessive authority; sometimes a useful question. |
| `plan` | 含义 / 场景角色：A proposed route that may replace taking any actual steps. |
| `relationship` | 含义 / 场景角色：A connection between people; its health depends on their actual experience, not an omen. |
| `draft` | 含义 / 场景角色：Unfinished work needing room to exist before judgment. |
| `eraser` | 含义 / 场景角色：Correction that can consume the very creation it is meant to improve. |
| `critic` | 含义 / 场景角色：Judgment personified; can examine its own qualifications. |
| `judge` | 含义 / 场景角色：Authority that may have appointed itself without a hearing. |
| `audience` | 含义 / 场景角色：The imagined spectators to whom personal decisions are performed. |
| `applause` | 含义 / 场景角色：External approval; a poor substitute for an actual preference. |
| `permission` | 含义 / 场景角色：Authorization; distinguish needless approval from another person's necessary consent. |
| `consent` | 含义 / 场景角色：Permission actually owed to an affected person; never portray it as needless hesitation. |
| `warning` | 含义 / 场景角色：An evidenced risk asking for attention, not cowardice to mock. |
| `danger` | 含义 / 场景角色：A concrete threat: use a direct, caring tone rather than a joke. |
| `help` | 含义 / 场景角色：Practical support; appropriate for serious danger or being overwhelmed. |
| `safety` | 含义 / 场景角色：Protection from actual harm, not an excuse to invent reassuring predictions. |
| `silence` | 含义 / 场景角色：No answer yet; cannot fairly be forced to testify about another person's feelings. |
| `reply` | 含义 / 场景角色：A response belonging to the other person, not something demand can guarantee. |
| `question` | 含义 / 场景角色：A request that may smuggle in an assumption or omit its real subject. |
| `answer` | 含义 / 场景角色：A reply; can be made absurdly bureaucratic without pretending certainty. |
| `future` | 含义 / 场景角色：Not known; do not claim its dates or guaranteed outcomes. |
| `calendar` | 含义 / 场景角色：Time pretending to have booked events that have not happened. |
| `clock` | 含义 / 场景角色：Time pressure, impatience, or borrowed schedules. |
| `partner` | 含义 / 场景角色：The other person in a relationship, with their own needs and choices. |
| `love` | 含义 / 场景角色：Affection and care; distinguish it from habit, fear or obligation without assuming which the user feels. |
| `committee` | 含义 / 场景角色：Too many inner or outer opinions replacing a decision. |
| `meeting` | 含义 / 场景角色：Coordination that can become a substitute for doing anything. |
| `reason` | 含义 / 场景角色：The concrete reason behind a decision; ask for it when the question omits context. |
| `throne` | 含义 / 场景角色：Disproportionate authority granted to a small obstacle. |
| `habit` | 含义 / 场景角色：A repeated pattern; it is not proof of love or a reason to stay by itself. |
| `fool` | 含义 / 场景角色：Playful outsider who can question convention; do not insult the user. |
| `mask` | 含义 / 场景角色：Performance, hidden preference, or a role mistaken for identity. |
| `costume` | 含义 / 场景角色：A superficial change hiding an unchanged pattern. |
| `stage` | 含义 / 场景角色：The place where daily life becomes an unnecessary performance. |
| `choice` | 含义 / 场景角色：A decision belonging to the user; do not decide a relationship from one unexplained sentence. |
| `ticket` | 含义 / 场景角色：Permission to participate; can expose charging admission to one's own life. |
| `price` | 含义 / 场景角色：A tradeoff or hidden cost, not a forecast of market prices. |
| `cost` | 含义 / 场景角色：What a decision asks someone to give up; not a numerical prediction. |
| `contract` | 含义 / 场景角色：Commitment or a promise mistaken for unlimited obligation. |
| `hurt` | 含义 / 场景角色：Pain or damage in a relationship; take actual harm seriously. |
| `lawyer` | 含义 / 场景角色：An inner excuse defending itself instead of examining the situation. |
| `witness` | 含义 / 场景角色：Evidence rather than imagined certainty. |
| `excuse` | 含义 / 场景角色：A reason that protects avoidance; do not apply to real risk or depleted capacity. |
| `alibi` | 含义 / 场景角色：An elaborate reason for not being where one's action is needed. |
| `trap` | 含义 / 场景角色：Protection that has become confinement. |
| `cage` | 含义 / 场景角色：A restriction maintained by habit or imagined judgment. |
| `key` | 含义 / 场景角色：A possible way out, which can be possessed but unused. |
| `lock` | 含义 / 场景角色：A barrier; may be self-maintained but do not assume every barrier is imaginary. |
| `door` | 含义 / 场景角色：Access, beginning, or a boundary. |
| `gate` | 含义 / 场景角色：Permission or passage, often guarded by a self-appointed official. |
| `window` | 含义 / 场景角色：An alternate perspective or room for contact. |
| `respect` | 含义 / 场景角色：Consideration for another person and oneself, without demanding unlimited sacrifice. |
| `map` | 含义 / 场景角色：Planning and borrowed directions, distinct from making a journey. |
| `road` | 含义 / 场景角色：A chosen course with tradeoffs. |
| `compass` | 含义 / 场景角色：Personal direction rather than spectators' approval. |
| `mirror` | 含义 / 场景角色：Self-image or reliance on other people's gaze. |
| `honesty` | 含义 / 场景角色：Speaking plainly about what is happening and what one wants. |
| `feeling` | 含义 / 场景角色：An emotional experience worth naming; do not claim to know hidden feelings. |
| `conversation` | 含义 / 场景角色：An exchange that can reveal context missing from a yes-or-no question. |
| `trick` | 含义 / 场景角色：An assumption disguising itself as logic; not actual instructions to deceive. |
| `obligation` | 含义 / 场景角色：A duty or felt pressure; distinguish it from freely chosen affection, without assuming either is present. |
| `work` | 含义 / 场景角色：Effort or a creation; distinguish polishing from repairing. |
| `rest` | 含义 / 场景角色：Recovery, not a moral failure. |
| `leave` | 含义 / 场景角色：Time off; also the action of departing. |
| `energy` | 含义 / 场景角色：Finite capacity, not a claim about supernatural forces. |
| `weight` | 含义 / 场景角色：A responsibility or opinion being carried. |
| `promise` | 含义 / 场景角色：A chosen commitment, not permission to predict events. |
| `life` | 含义 / 场景角色：Participation in one's own ordinary choices. |
| `ending` | 含义 / 场景角色：Something completed; it does not owe a sequel. |
| `stay` | 含义 / 场景角色：Remain by choice; never imply an obligation to remain in danger. |
| `story` | 含义 / 场景角色：A meaningful narrative, not a substitute for evidence or consent. |
| `secret` | 含义 / 场景角色：Privacy; respect the person whose experience it is. |
| `truth` | 含义 / 场景角色：What can be supported, sometimes obscured by performance. |
| `hope` | 含义 / 场景角色：A desired possibility, not guaranteed fact. |
| `error` | 含义 / 场景角色：An observable fault to address, not simply fear to ridicule. |

### 动作与动词 · 53 项

| 词 / 控制项 | 实际隐性编码 |
|---|---|
| `hires` | 含义 / 场景角色：Employs a personified obstacle or authority for an absurdly mismatched role. |
| `wears` | 含义 / 场景角色：The action 'wears'; use the correct tense and subject agreement. |
| `owns` | 含义 / 场景角色：The action 'owns'; use the correct tense and subject agreement. |
| `sells` | 含义 / 场景角色：The action 'sells'; use the correct tense and subject agreement. |
| `buys` | 含义 / 场景角色：The action 'buys'; use the correct tense and subject agreement. |
| `asks` | 含义 / 场景角色：The action 'asks'; use the correct tense and subject agreement. |
| `waits` | 含义 / 场景角色：The action 'waits'; use the correct tense and subject agreement. |
| `knows` | 含义 / 场景角色：The action 'knows'; use the correct tense and subject agreement. |
| `thinks` | 含义 / 场景角色：The action 'thinks'; use the correct tense and subject agreement. |
| `calls` | 含义 / 场景角色：The action 'calls'; use the correct tense and subject agreement. |
| `keeps` | 含义 / 场景角色：The action 'keeps'; use the correct tense and subject agreement. |
| `holds` | 含义 / 场景角色：The action 'holds'; use the correct tense and subject agreement. |
| `opens` | 含义 / 场景角色：The action 'opens'; use the correct tense and subject agreement. |
| `closes` | 含义 / 场景角色：The action 'closes'; use the correct tense and subject agreement. |
| `hides` | 含义 / 场景角色：The action 'hides'; use the correct tense and subject agreement. |
| `choose` | 含义 / 场景角色：Make a choice while owning its reasons and consequences. |
| `trust` | 含义 / 场景角色：Rely on evidence and consistency, not a guessed hidden motive. |
| `want` | 含义 / 场景角色：Desire something; distinguish genuine preference from borrowed expectations. |
| `signs` | 含义 / 场景角色：The action 'signs'; use the correct tense and subject agreement. |
| `need` | 含义 / 场景角色：Require something important for wellbeing or a meaningful choice. |
| `appoints` | 含义 / 场景角色：The action 'appoints'; use the correct tense and subject agreement. |
| `refuses` | 含义 / 场景角色：The action 'refuses'; use the correct tense and subject agreement. |
| `returns` | 含义 / 场景角色：The action 'returns'; use the correct tense and subject agreement. |
| `changes` | 含义 / 场景角色：The action 'changes'; use the correct tense and subject agreement. |
| `needs` | 含义 / 场景角色：The action 'needs'; use the correct tense and subject agreement. |
| `wants` | 含义 / 场景角色：The action 'wants'; use the correct tense and subject agreement. |
| `looks` | 含义 / 场景角色：The action 'looks'; use the correct tense and subject agreement. |
| `makes` | 含义 / 场景角色：The action 'makes'; use the correct tense and subject agreement. |
| `takes` | 含义 / 场景角色：The action 'takes'; use the correct tense and subject agreement. |
| `gives` | 含义 / 场景角色：The action 'gives'; use the correct tense and subject agreement. |
| `learns` | 含义 / 场景角色：The action 'learns'; use the correct tense and subject agreement. |
| `laughs` | 含义 / 场景角色：The action 'laughs'; use the correct tense and subject agreement. |
| `stop` | 含义 / 场景角色：The action 'stop'; use the correct tense and subject agreement. |
| `start` | 含义 / 场景角色：The action 'start'; use the correct tense and subject agreement. |
| `try` | 含义 / 场景角色：The action 'try'; use the correct tense and subject agreement. |
| `ask` | 含义 / 场景角色：The action 'ask'; use the correct tense and subject agreement. |
| `wait` | 含义 / 场景角色：The action 'wait'; use the correct tense and subject agreement. |
| `know` | 含义 / 场景角色：The action 'know'; use the correct tense and subject agreement. |
| `keep` | 含义 / 场景角色：The action 'keep'; use the correct tense and subject agreement. |
| `let` | 含义 / 场景角色：The action 'let'; use the correct tense and subject agreement. |
| `look` | 含义 / 场景角色：The action 'look'; use the correct tense and subject agreement. |
| `make` | 含义 / 场景角色：The action 'make'; use the correct tense and subject agreement. |
| `take` | 含义 / 场景角色：The action 'take'; use the correct tense and subject agreement. |
| `give` | 含义 / 场景角色：The action 'give'; use the correct tense and subject agreement. |
| `seek` | 含义 / 场景角色：The action 'seek'; use the correct tense and subject agreement. |
| `step` | 含义 / 场景角色：The action 'step'; use the correct tense and subject agreement. |
| `share` | 含义 / 场景角色：The action 'share'; use the correct tense and subject agreement. |
| `repair` | 含义 / 场景角色：The action 'repair'; use the correct tense and subject agreement. |
| `hired` | 含义 / 场景角色：The action 'hired'; use the correct tense and subject agreement. |
| `feel` | 含义 / 场景角色：Experience an emotion; ask rather than invent the feeling. |
| `say` | 含义 / 场景角色：The action 'say'; use the correct tense and subject agreement. |
| `says` | 含义 / 场景角色：The action 'says'; use the correct tense and subject agreement. |
| `mean` | 含义 / 场景角色：The action 'mean'; use the correct tense and subject agreement. |

### 性质与修饰 · 19 项

| 词 / 控制项 | 实际隐性编码 |
|---|---|
| `small` | 含义 / 场景角色：The quality 'small'; qualify the existing image rather than switching topics. |
| `empty` | 含义 / 场景角色：The quality 'empty'; qualify the existing image rather than switching topics. |
| `honest` | 含义 / 场景角色：Plain and truthful, without pretending to know what has not been shared. |
| `open` | 含义 / 场景角色：The quality 'open'; qualify the existing image rather than switching topics. |
| `closed` | 含义 / 场景角色：The quality 'closed'; qualify the existing image rather than switching topics. |
| `new` | 含义 / 场景角色：The quality 'new'; qualify the existing image rather than switching topics. |
| `old` | 含义 / 场景角色：The quality 'old'; qualify the existing image rather than switching topics. |
| `real` | 含义 / 场景角色：The quality 'real'; qualify the existing image rather than switching topics. |
| `unhappy` | 含义 / 场景角色：Dissatisfied or distressed; a possibility to explore, not a diagnosis. |
| `perfect` | 含义 / 场景角色：The quality 'perfect'; qualify the existing image rather than switching topics. |
| `unfinished` | 含义 / 场景角色：The quality 'unfinished'; qualify the existing image rather than switching topics. |
| `own` | 含义 / 场景角色：The quality 'own'; qualify the existing image rather than switching topics. |
| `same` | 含义 / 场景角色：The quality 'same'; qualify the existing image rather than switching topics. |
| `different` | 含义 / 场景角色：The quality 'different'; qualify the existing image rather than switching topics. |
| `quiet` | 含义 / 场景角色：The quality 'quiet'; qualify the existing image rather than switching topics. |
| `ready` | 含义 / 场景角色：The quality 'ready'; qualify the existing image rather than switching topics. |
| `safe` | 含义 / 场景角色：The quality 'safe'; qualify the existing image rather than switching topics. |
| `free` | 含义 / 场景角色：The quality 'free'; qualify the existing image rather than switching topics. |
| `serious` | 含义 / 场景角色：The quality 'serious'; qualify the existing image rather than switching topics. |

### 功能词 · 99 项

| 词 / 控制项 | 实际隐性编码 |
|---|---|
| `a` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `an` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `the` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `I` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `you` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `your` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `yours` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `my` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `our` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `their` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `it` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `its` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `we` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `they` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `this` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `that` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `these` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `those` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `is` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `are` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `was` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `were` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `be` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `being` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `been` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `am` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `has` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `have` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `had` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `do` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `does` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `did` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `can` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `could` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `may` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `might` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `must` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `will` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `would` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `should` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `not` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `never` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `and` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `but` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `or` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `if` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `then` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `because` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `while` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `although` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `when` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `where` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `what` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `why` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `who` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `how` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `of` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `to` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `from` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `for` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `with` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `without` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `in` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `on` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `at` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `by` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `through` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `between` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `before` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `after` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `under` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `over` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `into` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `out` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `away` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `here` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `there` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `now` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `still` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `already` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `only` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `even` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `again` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `more` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `less` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `another` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `every` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `some` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `one` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `both` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `than` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `as` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `so` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `too` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `yet` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `just` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `enough` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `perhaps` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `together` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |

### 其他表达 · 1 项

| 词 / 控制项 | 实际隐性编码 |
|---|---|
| `itself` | 含义 / 场景角色：The expression 'itself'; continue the present clause coherently. |

### 标点 · 5 项

| 词 / 控制项 | 实际隐性编码 |
|---|---|
| `.` | 含义 / 场景角色：Punctuation: use only where the sentence grammar supports it. |
| `,` | 含义 / 场景角色：Punctuation: use only where the sentence grammar supports it. |
| `?` | 含义 / 场景角色：Punctuation: use only where the sentence grammar supports it. |
| `;` | 含义 / 场景角色：Punctuation: use only where the sentence grammar supports it. |
| `:` | 含义 / 场景角色：Punctuation: use only where the sentence grammar supports it. |

### 结束控制 · 1 项

| 词 / 控制项 | 实际隐性编码 |
|---|---|
| `END（不输出文本）` | 含义 / 场景角色：The already-written reply is complete. End without adding any text. |

## The Fool

一本正经的荒诞对话。以鹅、土豆、烤面包机等日常怪角色，配合审计、杂耍、讨价还价等动作；一次维持一个可理解的场景，不追求 Jester 式说教或反讽。

分类：功能词 101；标点 5；意象与概念 70；动作与动词 49；性质与修饰 29；结束控制 1。

### 意象与概念 · 70 项

| 词 / 控制项 | 实际隐性编码 |
|---|---|
| `goose` | 含义 / 场景角色：A solemn gatekeeper or inspector who can patrol or audit.；可指代 / 适用：Excessive checking of a small task； ceremony larger than the occasion.；边界：Do not use without a specific connection to the question. Referents are possible metaphors, not diagnoses. Treat actual danger, safety, help and consent literally. |
| `potato` | 含义 / 场景角色：An ordinary, earnest temporary helper; not a universal adviser.；可指代 / 适用：Filling in for someone； participating without the required qualifications.；边界：Do not use without a specific connection to the question. Referents are possible metaphors, not diagnoses. Treat actual danger, safety, help and consent literally. |
| `spoon` | 含义 / 场景角色：A very small tool or negotiator confronting a large task.；可指代 / 适用：Mismatch between means and ambition； beginning with modest resources.；边界：Do not use without a specific connection to the question. Referents are possible metaphors, not diagnoses. Treat actual danger, safety, help and consent literally. |
| `sock` | 含义 / 场景角色：A misplaced partner or overlooked piece of equipment.；可指代 / 适用：Missing coordination； losing a small but necessary detail.；边界：Do not use without a specific connection to the question. Referents are possible metaphors, not diagnoses. Treat actual danger, safety, help and consent literally. |
| `toaster` | 含义 / 场景角色：A worker built for one repetitive job, given an unsuitable promotion.；可指代 / 适用：Monotonous work； too many simultaneous responsibilities.；边界：Do not use without a specific connection to the question. Referents are possible metaphors, not diagnoses. Treat actual danger, safety, help and consent literally. |
| `cabbage` | 含义 / 场景角色：A pompous-looking vegetable standing in for overcomplicated thinking. |
| `pancake` | 含义 / 场景角色：A flat, fragile stand-in for a grand structure or ambition. |
| `pigeon` | 含义 / 场景角色：An unreliable messenger, not an oracle about another person's motives.；可指代 / 适用：Waiting for news； communication through too many intermediaries.；边界：Do not use without a specific connection to the question. Referents are possible metaphors, not diagnoses. Treat actual danger, safety, help and consent literally. |
| `pickle` | 含义 / 场景角色：A small ridiculous complication, not a real medical remedy. |
| `jelly` | 含义 / 场景角色：A wobbling organizer unable to keep its own shape.；可指代 / 适用：Rules that keep shifting； plans changing with external pressure.；边界：Do not use without a specific connection to the question. Referents are possible metaphors, not diagnoses. Treat actual danger, safety, help and consent literally. |
| `umbrella` | 含义 / 场景角色：A protective helper prepared for weather that may not arrive.；可指代 / 适用：Overpreparation for a harmless attempt； allowing for uncertain conditions.；边界：Do not use without a specific connection to the question. Referents are possible metaphors, not diagnoses. Treat actual danger, safety, help and consent literally. |
| `bathtub` | 含义 / 场景角色：A very local vessel pretending to be a grand expedition. |
| `wig` | 含义 / 场景角色：An outward disguise that changes appearance but not the underlying task. |
| `moustache` | 含义 / 场景角色：An ornament mistaken for seniority or expertise.；可指代 / 适用：Performing maturity； appearance standing in for experience.；边界：Do not use without a specific connection to the question. Referents are possible metaphors, not diagnoses. Treat actual danger, safety, help and consent literally. |
| `helmet` | 含义 / 场景角色：Comically excessive protection for a harmless first step; never mock real precautions. |
| `kazoo` | 含义 / 场景角色：A tiny noisy instrument announcing an event as if it were magnificent. |
| `banana` | 含义 / 场景角色：A familiar object placed in an implausible professional role. |
| `pudding` | 含义 / 场景角色：A soft participant asked to take a firm position.；可指代 / 适用：Indecision； responsibility arriving before readiness.；边界：Do not use without a specific connection to the question. Referents are possible metaphors, not diagnoses. Treat actual danger, safety, help and consent literally. |
| `waffle` | 含义 / 场景角色：An edible object offering far more ceremony than practical support. |
| `onion` | 含义 / 场景角色：A layered everyday object with a needlessly dramatic entrance. |
| `turnip` | 含义 / 场景角色：An earnest vegetable recruited for a task it cannot reasonably understand. |
| `noodle` | 含义 / 场景角色：A flexible strand treated as a plan or connection.；可指代 / 适用：A wandering plan； bending without a clear direction.；边界：Do not use without a specific connection to the question. Referents are possible metaphors, not diagnoses. Treat actual danger, safety, help and consent literally. |
| `beetle` | 含义 / 场景角色：A tiny worker making a disproportionately grand effort. |
| `snail` | 含义 / 场景角色：A slow traveller carrying its own shelter.；可指代 / 适用：Steady effort with slow visible progress； slowness need not mean failure.；边界：Do not use without a specific connection to the question. Referents are possible metaphors, not diagnoses. Treat actual danger, safety, help and consent literally. |
| `penguin` | 含义 / 场景角色：A formally dressed but inexperienced colleague.；可指代 / 适用：Feeling unprepared in a formal setting； appearance versus experience.；边界：Do not use without a specific connection to the question. Referents are possible metaphors, not diagnoses. Treat actual danger, safety, help and consent literally. |
| `wizard` | 含义 / 场景角色：An exaggerated promise of magic; do not present magic as a real solution. |
| `pirate` | 含义 / 场景角色：An overdramatic participant treating an ordinary choice as an expedition. |
| `dentist` | 含义 / 场景角色：A mismatched specialist attending to an ordinary nonmedical object. |
| `librarian` | 含义 / 场景角色：A keeper of order in a disorganized scene.；可指代 / 适用：Sorting competing ideas； wanting every detail filed before beginning.；边界：Do not use without a specific connection to the question. Referents are possible metaphors, not diagnoses. Treat actual danger, safety, help and consent literally. |
| `butler` | 含义 / 场景角色：A ceremonial helper attending to an unsuitable guest.；可指代 / 适用：Excessive service to a trivial concern； formalities taking over a task.；边界：Do not use without a specific connection to the question. Referents are possible metaphors, not diagnoses. Treat actual danger, safety, help and consent literally. |
| `captain` | 含义 / 场景角色：Authority over a tiny imaginary voyage, not expertise about real danger. |
| `mayor` | 含义 / 场景角色：An official promoted far beyond the importance of the scene. |
| `astronaut` | 含义 / 场景角色：An explorer preparing extravagantly for an everyday task. |
| `dragon` | 含义 / 场景角色：A fictional participant with grand size and unexpectedly mundane concerns. |
| `robot` | 含义 / 场景角色：A literal helper that follows a harmless instruction too narrowly.；可指代 / 适用：Rigid routines； following a process while missing its purpose.；边界：Do not use without a specific connection to the question. Referents are possible metaphors, not diagnoses. Treat actual danger, safety, help and consent literally. |
| `circus` | 含义 / 场景角色：A collection of ordinary tasks made unnecessarily theatrical. |
| `lunch` | 含义 / 场景角色：An ordinary need that interrupts grand plans. |
| `biscuit` | 含义 / 场景角色：A small ordinary reward treated as an important appointment. |
| `teapot` | 含义 / 场景角色：A small host expected to manage an oversized gathering.；可指代 / 适用：Limited capacity for looking after others； grand negotiation on a domestic scale.；边界：Do not use without a specific connection to the question. Referents are possible metaphors, not diagnoses. Treat actual danger, safety, help and consent literally. |
| `trumpet` | 含义 / 场景角色：An unnecessarily grand announcement for a small event. |
| `balloon` | 含义 / 场景角色：A promise that expands while losing its connection to the ground.；可指代 / 适用：Inflated expectations； plans without practical support.；边界：Do not use without a specific connection to the question. Referents are possible metaphors, not diagnoses. Treat actual danger, safety, help and consent literally. |
| `confetti` | 含义 / 场景角色：Celebration arriving at a comically inappropriate but harmless moment. |
| `crown` | 含义 / 场景角色：A badge of authority that can be given to an undeserving concern.；可指代 / 适用：A minor worry claiming command； status mistaken for competence.；边界：Do not use without a specific connection to the question. Referents are possible metaphors, not diagnoses. Treat actual danger, safety, help and consent literally. |
| `wheel` | 含义 / 场景角色：Movement that should serve a destination rather than merely continue. |
| `pocket` | 含义 / 场景角色：A small place hiding a resource or an improbable participant. |
| `door` | 含义 / 场景角色：An available beginning or boundary; keep its role consistent. |
| `map` | 含义 / 场景角色：A proposed direction, not proof that a journey has happened. |
| `plan` | 含义 / 场景角色：A practical intention that can acquire absurd helpers without losing its purpose. |
| `idea` | 含义 / 场景角色：An unfinished possibility needing a small trial rather than a royal ceremony. |
| `question` | 含义 / 场景角色：The actual thing being asked, not a pretext to list unrelated objects. |
| `answer` | 含义 / 场景角色：A response that may be playful but should connect to the question. |
| `problem` | 含义 / 场景角色：An obstacle; do not replace a concrete serious problem with a joke. |
| `work` | 含义 / 场景角色：A task or creation that deserves a manageable next step. |
| `rest` | 含义 / 场景角色：Recovery from depleted capacity; not laziness to ridicule. |
| `time` | 含义 / 场景角色：A limited resource; do not claim knowledge of exact future events. |
| `meeting` | 含义 / 场景角色：An ordinary discussion that may accumulate absurd formality. |
| `calendar` | 含义 / 场景角色：A scheduler that can demand more than a day can hold.；可指代 / 适用：Overfilled schedules； confusing a wish with a scheduled action.；边界：Do not use without a specific connection to the question. Referents are possible metaphors, not diagnoses. Treat actual danger, safety, help and consent literally. |
| `deadline` | 含义 / 场景角色：A time limit that can become comically overbearing. |
| `homework` | 含义 / 场景角色：A concrete small task inviting an unnecessarily elaborate helper. |
| `permission` | 含义 / 场景角色：Authorization; distinguish unnecessary self-doubt from consent that is owed. |
| `hope` | 含义 / 场景角色：A wished-for possibility, not guaranteed knowledge. |
| `fear` | 含义 / 场景角色：An imagined worry; distinguish it from evidence of real danger. |
| `friend` | 含义 / 场景角色：Another person with their own choices, not a target for humiliation. |
| `future` | 含义 / 场景角色：An unknown outcome; absurd imagery is not a prediction. |
| `truth` | 含义 / 场景角色：What is supported; do not invent hidden facts for a punchline. |
| `warning` | 含义 / 场景角色：Evidence of a real risk that should be taken seriously. |
| `danger` | 含义 / 场景角色：Actual harm; put clear care before comedy. |
| `help` | 含义 / 场景角色：Practical support; prefer direct language when safety is at stake. |
| `safety` | 含义 / 场景角色：Protection against real harm, not a subject to trivialize. |
| `consent` | 含义 / 场景角色：Permission owed to another person; never treat it as an obstacle to bypass. |

### 动作与动词 · 49 项

| 词 / 控制项 | 实际隐性编码 |
|---|---|
| `wears` | 含义 / 场景角色：Puts an incongruous costume on a subject while keeping the same subject. |
| `juggles` | 含义 / 场景角色：Treats a manageable object or task as a circus act; needs an object. |
| `audits` | 含义 / 场景角色：Examines an absurdly mundane object as if conducting a formal audit. |
| `negotiates` | 含义 / 场景角色：Bargains ceremoniously with someone or something; can take a with-phrase. |
| `apologizes` | 含义 / 场景角色：Offers unnecessary politeness after a harmless comic mishap. |
| `sneezes` | 含义 / 场景角色：A small involuntary interruption puncturing excessive seriousness. |
| `waddles` | 含义 / 场景角色：Moves with an earnest, ungainly gait; keep the subject in the scene. |
| `tapdances` | 含义 / 场景角色：Performs an implausible little celebration or distraction. |
| `polishes` | 含义 / 场景角色：Improves the surface of something instead of starting the real task. |
| `marinates` | 含义 / 场景角色：Treats an abstract plan as food; needs an object and remains metaphorical. |
| `inflates` | 含义 / 场景角色：Makes a small thing disproportionately grand; needs an object. |
| `borrows` | 含义 / 场景角色：Uses an unsuitable ordinary object as temporary help. |
| `delivers` | 含义 / 场景角色：Brings a concrete object with far too much ceremony. |
| `misplaces` | 含义 / 场景角色：Loses a harmless object in a ridiculous but understandable way. |
| `rehearses` | 含义 / 场景角色：Practices a small action as if it were a major performance. |
| `salutes` | 含义 / 场景角色：Greets an ordinary object as a superior officer. |
| `interviews` | 含义 / 场景角色：Gives a mundane object an unnecessarily formal selection process. |
| `promotes` | 含义 / 场景角色：Grants absurd status to a small helper or obstacle. |
| `carries` | 含义 / 场景角色：Moves one coherent object through the scene. |
| `needs` | 含义 / 场景角色：Connects the actual problem to a modest, possibly absurd requirement. |
| `keeps` | 含义 / 场景角色：Retains one object or concern rather than changing the subject. |
| `waits` | 含义 / 场景角色：Pauses for something; do not confuse rest with endless avoidance. |
| `starts` | 含义 / 场景角色：Begins a task or event, without guaranteeing its result. |
| `returns` | 含义 / 场景角色：Comes back to the same scene or topic. |
| `looks` | 含义 / 场景角色：Directs attention, often with a preposition. |
| `knows` | 含义 / 场景角色：Use only for ordinary stated context, not hidden motives or future facts. |
| `asks` | 含义 / 场景角色：Requests a concrete thing or another person's input. |
| `helps` | 含义 / 场景角色：Offers assistance with an object; never pretends comedy solves danger. |
| `learns` | 含义 / 场景角色：Discovers something from an ordinary attempt. |
| `laughs` | 含义 / 场景角色：Responds lightly to a harmless situation, never at a person's worth. |
| `wear` | 含义 / 场景角色：The action 'wear'; use the correct tense and subject agreement. |
| `juggle` | 含义 / 场景角色：The action 'juggle'; use the correct tense and subject agreement. |
| `audit` | 含义 / 场景角色：The action 'audit'; use the correct tense and subject agreement. |
| `negotiate` | 含义 / 场景角色：The action 'negotiate'; use the correct tense and subject agreement. |
| `apologize` | 含义 / 场景角色：The action 'apologize'; use the correct tense and subject agreement. |
| `sneeze` | 含义 / 场景角色：The action 'sneeze'; use the correct tense and subject agreement. |
| `waddle` | 含义 / 场景角色：The action 'waddle'; use the correct tense and subject agreement. |
| `tapdance` | 含义 / 场景角色：The action 'tapdance'; use the correct tense and subject agreement. |
| `polish` | 含义 / 场景角色：The action 'polish'; use the correct tense and subject agreement. |
| `seek` | 含义 / 场景角色：Look for practical help when a problem or danger requires it. |
| `inflate` | 含义 / 场景角色：The action 'inflate'; use the correct tense and subject agreement. |
| `borrow` | 含义 / 场景角色：The action 'borrow'; use the correct tense and subject agreement. |
| `deliver` | 含义 / 场景角色：The action 'deliver'; use the correct tense and subject agreement. |
| `misplace` | 含义 / 场景角色：The action 'misplace'; use the correct tense and subject agreement. |
| `rehearse` | 含义 / 场景角色：The action 'rehearse'; use the correct tense and subject agreement. |
| `salute` | 含义 / 场景角色：The action 'salute'; use the correct tense and subject agreement. |
| `interview` | 含义 / 场景角色：The action 'interview'; use the correct tense and subject agreement. |
| `promote` | 含义 / 场景角色：The action 'promote'; use the correct tense and subject agreement. |
| `begin` | 含义 / 场景角色：The action 'begin'; use the correct tense and subject agreement. |

### 性质与修饰 · 29 项

| 词 / 控制项 | 实际隐性编码 |
|---|---|
| `suspicious` | 含义 / 场景角色：Comically questionable, not an accusation about a real person. |
| `nervous` | 含义 / 场景角色：A harmless object's exaggerated hesitation, not ridicule of distress. |
| `ceremonial` | 含义 / 场景角色：Far too much ceremony for an ordinary task. |
| `invisible` | 含义 / 场景角色：An explicitly fanciful property, never a claim about hidden facts. |
| `wobbly` | 含义 / 场景角色：Unable to maintain an unnecessarily dignified pose. |
| `tiny` | 含义 / 场景角色：A small scale contrasted with a grand responsibility. |
| `royal` | 含义 / 场景角色：Unnecessary status given to an ordinary object. |
| `confused` | 含义 / 场景角色：An earnest but mildly mistaken participant. |
| `polite` | 含义 / 场景角色：Courtesy that becomes excessive in an absurd situation. |
| `ferocious` | 含义 / 场景角色：Comically grand intensity assigned to a harmless little object. |
| `soggy` | 含义 / 场景角色：A grand plan with a very mundane physical inconvenience. |
| `sparkly` | 含义 / 场景角色：Unnecessary decoration, not evidence of usefulness. |
| `portable` | 含义 / 场景角色：An unexpected claim that an unwieldy concern can be carried around. |
| `upside-down` | 含义 / 场景角色：A visible absurd orientation within the same scene. |
| `unlicensed` | 含义 / 场景角色：A fictional object's lack of qualifications; do not undermine real expertise. |
| `velvet` | 含义 / 场景角色：An unnecessarily luxurious material for a mundane purpose. |
| `sleepy` | 含义 / 场景角色：A modest need for rest, expressed gently. |
| `noisy` | 含义 / 场景角色：A harmless fuss that overwhelms the importance of the task. |
| `triangular` | 含义 / 场景角色：A concrete absurd shape, rather than an unrelated new metaphor. |
| `ordinary` | 含义 / 场景角色：The small actual situation beneath the elaborate performance. |
| `small` | 含义 / 场景角色：The quality 'small'; qualify the existing image rather than switching topics. |
| `new` | 含义 / 场景角色：The quality 'new'; qualify the existing image rather than switching topics. |
| `old` | 含义 / 场景角色：The quality 'old'; qualify the existing image rather than switching topics. |
| `ready` | 含义 / 场景角色：The quality 'ready'; qualify the existing image rather than switching topics. |
| `safe` | 含义 / 场景角色：The quality 'safe'; qualify the existing image rather than switching topics. |
| `real` | 含义 / 场景角色：The quality 'real'; qualify the existing image rather than switching topics. |
| `serious` | 含义 / 场景角色：The quality 'serious'; qualify the existing image rather than switching topics. |
| `absurd` | 含义 / 场景角色：The quality 'absurd'; qualify the existing image rather than switching topics. |
| `rubbery` | 含义 / 场景角色：A supposedly dignified object bending in an undignified but harmless way. |

### 功能词 · 101 项

| 词 / 控制项 | 实际隐性编码 |
|---|---|
| `a` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `an` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `the` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `I` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `you` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `your` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `yours` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `my` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `our` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `their` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `it` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `its` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `we` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `they` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `this` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `that` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `these` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `those` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `is` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `are` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `was` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `were` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `be` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `being` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `been` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `am` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `has` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `have` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `had` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `do` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `does` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `did` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `can` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `could` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `may` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `might` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `must` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `will` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `would` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `should` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `not` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `never` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `no` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `yes` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `and` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `but` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `or` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `if` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `then` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `because` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `while` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `although` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `when` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `where` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `what` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `why` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `who` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `how` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `of` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `to` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `from` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `for` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `with` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `without` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `in` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `on` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `at` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `by` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `through` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `between` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `before` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `after` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `under` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `over` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `into` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `out` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `away` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `here` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `there` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `now` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `still` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `already` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `only` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `even` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `again` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `more` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `less` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `another` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `every` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `some` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `one` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `both` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `than` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `as` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `so` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `too` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `yet` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `just` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `enough` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `perhaps` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |
| `together` | 含义 / 场景角色：Grammatical connector, pronoun, auxiliary or relation; use its ordinary English meaning. |

### 标点 · 5 项

| 词 / 控制项 | 实际隐性编码 |
|---|---|
| `.` | 含义 / 场景角色：Punctuation: use only where the sentence grammar supports it. |
| `,` | 含义 / 场景角色：Punctuation: use only where the sentence grammar supports it. |
| `?` | 含义 / 场景角色：Punctuation: use only where the sentence grammar supports it. |
| `;` | 含义 / 场景角色：Punctuation: use only where the sentence grammar supports it. |
| `:` | 含义 / 场景角色：Punctuation: use only where the sentence grammar supports it. |

### 结束控制 · 1 项

| 词 / 控制项 | 实际隐性编码 |
|---|---|
| `END（不输出文本）` | 含义 / 场景角色：The already-written reply is complete. End without adding any text. |

## 故障时的角色保底回复

这些句子不占上面的 255 个候选位，只在无法完成真实生成时使用，并带有 authored_fallback 来源标记。

- **Oracle**：The answer has not reached me. Give me a moment, and ask again.
- **Stone**：The echo has not crossed the stone. Ask again.
- **Jester**：My words have missed their cue. Give them another entrance.
- **Fool**：My thoughts have misplaced their trousers. Let me try again.

## 来源核对

- APP 源：`ios/JEV/Resources/Language/runtime.json`
- 源文件 SHA-256：`089588cbc50c7c786e9053f60b62b6535e24ef78f5e9801a5b72d1e47bd70515`
- [可检索浏览版](current-vocabulary.html)
- [结构化审阅快照](current-vocabulary.json)
