# The Stela 与 The Fool · 第一版

The Stone 的对外名字改为 **The Stela**，强调“刻有文字的立碑”。内部 `stone` 标识保留，原有素材和已保存的角色选择继续可用。

**The Fool** 是第四个独立角色：友善、认真、略显笨拙地说荒诞的话。Jester 用反讽揭示问题；Fool 则让一个普通问题遇见一个不合时宜的物件或动作，不强求每句话都上升为人生寓意。

## 生成机制

参考 [Dumb Chat 的词模式](https://github.com/Gackson/jev-olympics/blob/main/chat_words.py)：固定词表、一次选择一个完整单词、自动空格与标点、明确结束符。没有复用它的原词库或整句答案。

本项目另外保留表达意图与语法过滤，避免随机词堆。The Fool 有 249 个单词、5 个标点、1 个 END：101 个功能词、70 个意象/概念、49 个主标签为动词的词、29 个修饰词。`help` 同时可作名词和动词，去重后只占一个候选位。

| 类型 | 部分实际词条 |
|---|---|
| 名词 | goose, potato, spoon, sock, toaster, cabbage, pancake, pigeon, pickle, jelly, umbrella, bathtub, wig, moustache, kazoo |
| 动词 | juggles, audits, negotiates, apologizes, sneezes, waddles, tapdances, polishes, marinates, inflates, salutes, interviews |
| 形容词 | suspicious, nervous, ceremonial, invisible, wobbly, tiny, royal, confused, polite, soggy, sparkly, rubbery |
| 普通问题与边界 | plan, question, answer, work, rest, deadline, homework, warning, danger, help, safety, consent |

## 用于规则验证的例句

以下是明确指定选择路径的测试句，**不是实际 JEV 输出**：

- Your plan wears a tiny helmet.
- A suspicious goose audits your homework.
- The confused toaster apologizes to your calendar.
- You should seek help.（严重问题保留直接表达能力）

每句话的单词、标点和 END 都逐步选择。不同句式不绑定固定的前半句和后半句。

## 输出与工程边界

- 最多 34 次模型选择（含意图）、24 个单词，Fool 优先只说一个完整句子；总时限 120 秒，单请求最多 25 秒。
- 同词连发、短周期重复、超限输出和不完整结束被限制；没有 no_match 候选。
- 真正的危险、同意和事实判断优先于搞笑，不用荒诞口吻制造确定性。
- 网络或生成失败仍给出标明来源的角色回复，不冒充真实生成：*My thoughts have misplaced their trousers. Let me try again.*
- APP 内已提供第四个角色、独立草稿和会话；专属角色画尚未制作，使用独立开发场景占位。

## 实际 JEV 输出与修订

实测问题：*My homework is boring. Give me a silly way to think about it.*

1. 初始词库 `roles4` 的手机直连输出：**Homework is a potato now to work. It juggles a plan.**（14.670 秒）调用完成，但目的短语牵强、第二句多余，未按理想质量验收。
2. 对 Fool 单独限制为一个完整句子，缩减尾部从句组合；未改变 Stela/Jester 的句法规则。当前 `roles4b` 输出：**Homework is a potato with a plan.**（7.535 秒）`origin=jev`、`generationStatus=complete`，原文可读，荒诞意象保持一致。

更早的 Python 首轮实测在意图选择阶段遇到 `transport_error`，1 次请求后停止；连通性恢复后才做上述手机测试。所有失败和原句都保留，没有把指定选择路径的测试句冒充实际输出。

这是首轮单题改进证据，尚不能证明对广泛问题的幽默感、稳定性或相关性已达标。[验证记录](../verification/fool-stela-2026-09-27.md)

[完整当前词库](current-vocabulary.html) · [英文词条与隐性编码源](../../experiments/language/lexicon-fool.txt)
