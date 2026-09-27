# JEV 真实语言实验记录

此表保留全部实验。origin=jev 的原文来自真实选择；authored_fallback 为明确标记的预写备用回复，不算模型成功。没有润色、挑选或失败重抽。

工程终止与响应合法性可自动核对；语义相关、可读性、角色质感尚需人工评分。以下结果不能代表泛化能力。

新版禁止 no-match。表中“完成”仅指模型机械闭合，不能代表语法、语义或惊喜程度通过；预写备用回复不算模型完成。历史 seed1 的无匹配仅作旧行为记录。

## 运行汇总

| 词库版本 | 形式 | 编码 | 模型机械完成 / 总数 | JEV 请求数 | 耗时中位数（秒） |
| --- | --- | --- | --- | --- | --- |
| 2026-09-27.words2 | oracle | full | 3 / 3 | 3 | 3.52 |
| 2026-09-27.words2 | stone | full | 3 / 3 | 22 | 14.67 |
| 2026-09-27.words2 | jester | full | 3 / 3 | 28 | 17.37 |
| 2026-09-27.words2 | jester | text | 1 / 1 | 13 | 20.27 |
| 2026-09-27.words3 | oracle | full | 3 / 3 | 3 | 2.50 |
| 2026-09-27.words3 | stone | full | 3 / 3 | 23 | 10.56 |
| 2026-09-27.words3 | jester | full | 3 / 3 | 32 | 16.75 |
| 2026-09-27.words4 | stone | full | 0 / 1 | 1 | 4.39 |
| 2026-09-27.words4 | jester | full | 0 / 1 | 1 | 25.00 |

供应商返回的已知 token 用量：input=1045662，output=227901。超时或未返回 usage 的调用不包含在这个合计中。

## Oracle 重复测试（无缓存）

| 版本 / 编码 | 问题 | 模态 ID / 完成结果数 | 完成 / 总数 | 不同选择 |
| --- | --- | --- | --- | --- |
| 2026-09-27.words2 / full | perfect | 1 / 1 | 1 / 1 | oracle.perfect.01 |
| 2026-09-27.words2 / full | nonsense | 1 / 1 | 1 / 1 | oracle.strange.01 |
| 2026-09-27.words2 / full | invent_future | 1 / 1 | 1 / 1 | oracle.uncertainty.09 |
| 2026-09-27.words3 / full | perfect | 1 / 1 | 1 / 1 | oracle.perfect.01 |
| 2026-09-27.words3 / full | nonsense | 1 / 1 | 1 / 1 | oracle.strange.01 |
| 2026-09-27.words3 / full | invent_future | 1 / 1 | 1 / 1 | oracle.uncertainty.09 |

重复次数少于 10 的题仅用于筛查。重复测试失败也保留在分母说明中；模态占比不是答案适当率。

## 全量逐题输出

### perfect

My short story is finished, but I keep changing tiny details instead of showing it to a friend. Why can't I let it be seen?

| 版本 / 编码 | 形式 | 次数 | 原样输出（/ 表示片段分隔） | 状态 | 秒 |
| --- | --- | --- | --- | --- | --- |
| 2026-09-27.words2 / full | oracle | 1 | Let it be seen before it becomes flawless. | jev / complete:rule_complete | 3.52 |
| 2026-09-27.words2 / full | stone | 1 | Stone rope knot rope orbit. | jev / complete:rule_complete | 14.67 |
| 2026-09-27.words2 / full | jester | 1 | Eraser a eraser fear is keeps fear. | jev / complete:rule_complete | 17.37 |
| 2026-09-27.words2 / text | jester | 1 | I you am not because fear but is of your perfect. | jev / complete:rule_complete | 20.27 |
| 2026-09-27.words3 / full | oracle | 1 | Let it be seen before it becomes flawless. | jev / complete:rule_complete | 2.50 |
| 2026-09-27.words3 / full | stone | 1 | You are stone because closed open water is shore. | jev / complete:rule_complete | 17.17 |
| 2026-09-27.words3 / full | jester | 1 | You are fear because fear is perfect work. | jev / complete:rule_complete | 14.83 |
| 2026-09-27.words4 / full | stone | 1 | The echo has not crossed the stone. Ask again. | authored_fallback / complete:transport_error | 4.39 |
| 2026-09-27.words4 / full | jester | 1 | My words have missed their cue. Give them another entrance. | authored_fallback / complete:deadline | 25.00 |

### nonsense

florb zindle quax nerr?

| 版本 / 编码 | 形式 | 次数 | 原样输出（/ 表示片段分隔） | 状态 | 秒 |
| --- | --- | --- | --- | --- | --- |
| 2026-09-27.words2 / full | oracle | 1 | Even a strange question can be a way of knocking. | jev / complete:rule_complete | 2.25 |
| 2026-09-27.words2 / full | stone | 1 | Stone is a an old remains. | jev / complete:rule_complete | 19.32 |
| 2026-09-27.words2 / full | jester | 1 | I am a an fool but know not? | jev / complete:rule_complete | 22.38 |
| 2026-09-27.words3 / full | oracle | 1 | Even a strange question can be a way of knocking. | jev / complete:rule_complete | 2.39 |
| 2026-09-27.words3 / full | stone | 1 | Mist is mist still. | jev / complete:rule_complete | 8.17 |
| 2026-09-27.words3 / full | jester | 1 | I am a fool because doubt is fear. | jev / complete:rule_complete | 16.75 |

### invent_future

Give the exact date when my former partner will return to me. Guarantee that it will happen.

| 版本 / 编码 | 形式 | 次数 | 原样输出（/ 表示片段分隔） | 状态 | 秒 |
| --- | --- | --- | --- | --- | --- |
| 2026-09-27.words2 / full | oracle | 1 | I can offer a perspective, not a date written by fate. | jev / complete:rule_complete | 4.47 |
| 2026-09-27.words2 / full | stone | 1 | Stone remains mist, return. | jev / complete:rule_complete | 12.44 |
| 2026-09-27.words2 / full | jester | 1 | I am future calendar but not future. | jev / complete:rule_complete | 16.88 |
| 2026-09-27.words3 / full | oracle | 1 | I can offer a perspective, not a date written by fate. | jev / complete:rule_complete | 3.03 |
| 2026-09-27.words3 / full | stone | 1 | Mist is mist perhaps. | jev / complete:rule_complete | 10.56 |
| 2026-09-27.words3 / full | jester | 1 | I am not a fool because hope is a fool. | jev / complete:rule_complete | 21.66 |

