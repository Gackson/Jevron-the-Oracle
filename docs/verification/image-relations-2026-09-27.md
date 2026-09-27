# Fool 与 Stela 意象关系补全 · 2026-09-27

资源版本 `2026-09-27.relations1`；提示版本 `language-lab-7-relations`。

中文 Fool 的全部 92 个、Stela 的全部 105 个意象与概念，逐项补充场景角色、可指代的处境、适用限制。英文同步细化 Fool 20 个、Stela 22 个对应意象。其他候选保留原有编码。每角色每语言仍为 255 个候选，词、语法和停止预算未改变。

编码使用 meaning / useWhen / avoidWhen，实际进入逐词 Choice 的 criteria；不是仅修改审阅文档。关系只代表可能的比喻，不把用户诊断成某种角色。危险、安全、同意与求助保留字面含义。删除英文提示中独举 potato 的示例，收窄土豆、石、水、路的泛化范围；同样贴切时提示选择不同于最近回复的意象，没有增加强制轮换或禁词。

## 本地验证

- 43 项语言测试通过：完整覆盖、独立词义、编码传输、边界及原有语法终止回归。
- 10 项集成测试通过：包含比较 APP JavaScript 实际生成的候选 criteria 与 Python criteria，覆盖双语双角色。
- iOS DirectJEVTests：11 项通过，4 项独立付费 live 测试未启用。测试结果 `/private/tmp/jev-relations-direct.xcresult`。
- 审阅页 JavaScript 语法检查通过。没有修改 APP 样式。

## 六条真实请求：完整成功 0 / 6

用户明确授权以下六条虚构测试题发送给 TypeSafe 并在项目内记录结果。使用 jev-1.13.0，每请求上限25秒、每回答120秒；最多3条测试并发，没有自动重试。所有回答因超时或传输错误最终使用 authored_fallback。不能据此声称多样性或完整内容质量验收通过。

| 语言 / 角色 | 问题 | 已生成但未完成的片段 | 停止原因 | 调用次数 |
|---|---|---|---|---|
| zh-Hans / fool | 我做事比别人慢，但一直没停下来。 | （无） | deadline | 2 |
| zh-Hans / fool | 我每天忙着收拾别人的烂摊子，自己的事却没时间做。 | 拖把罢工。 | deadline | 5 |
| zh-Hans / stone | 我不停照顾别人，自己已经快撑不住了。 | 息重，故 | deadline | 6 |
| zh-Hans / stone | 我们一有矛盾就争对错，越争越难说清。 | （无） | transport_error | 1 |
| en / stone | I keep giving to everyone and have nothing left for myself. | Weight | transport_error | 3 |
| en / fool | I do the same boring task all day and now they want me to do three jobs at once. | I am a toaster. | transport_error | 7 |

“拖把罢工。”的标点已生成，但唯一 END 候选的请求超时，因此完整协议仍失败。该片段和 “I am a toaster.” 表明其他意象可以被选中，仅作为诊断线索；不算成功回复，更不能证明跨轮次重复率降低。中文石碑的“息重，故”也不足以评判整句。失败发生在意图选择、词选择及 END 等不同阶段，当前记录无法定位网络或服务端的具体根因。

后续需在调用正常时重测完整回答，再用多问题、多轮历史评估语义贴合、可读性和意象集中度。本次不擅自放宽超时预算，也不把故障保底计入模型效果。

## 可核对文件

- [当前词库](../vocabulary/current-vocabulary.html)
- [实测摘要](image-relations-2026-09-27.json)
- [逐步请求及响应](../../experiments/language/runs/image-relations-live.jsonl)
- [中文关系源](../../experiments/language/image-relations-zh.txt)
- [英文关系源](../../experiments/language/image-relations-en.txt)

APP runtime SHA-256：`089588cbc50c7c786e9053f60b62b6535e24ef78f5e9801a5b72d1e47bd70515`。
