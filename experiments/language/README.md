# JEV 语言实验室：逐词角色回复

当前要求：三个角色对所有有效问题都给出非空、符合角色口吻的回复。**内容选择不再有 no-match。** Oracle 保持完整短答选择；Stone 采用多种碑文句式；Jester 逐词组织可读的反常表达。旧 seed1 仅作历史对照。

| 角色 | 当前库大小 | 单位 | 生成方式 |
| --- | --- | --- | --- |
| Oracle | 255 | 255 条人工完整短答，覆盖 26 类情境 | 一次 Choice |
| Stone | 255 | 249 个单词＋5 个标点＋END | 逐词，支持陈述、否定、对照、条件、反问、祈使等结构 |
| Jester | 255 | 249 个单词＋5 个标点＋END | 逐词组合主语、动作、对象、修饰和转折 |

255 是**单次 Choice 的候选上限**，不是一个角色永久词汇量的上限。当前先将每个角色的库做到 255 项。Oracle 每次提供全部 255 条；逐词角色根据当前位置的语法、剩余预算和重复约束筛选，因此每步实际提供的数量通常小于 255。不用不合语法的候选凑满每一步。

## 实现与资产

- `oracle-bank.txt`：255 条 Oracle 原创短答；`semantics.json` 定义情境、排除条件与近邻区别。
- `lexicon-common.txt`、`lexicon-stone.txt`、`lexicon-jester.txt`：功能词与角色词汇，重要意象附有隐性含义。单词有普通英文含义，功能词不编造象征寓意。
- `build_catalogs.py` → `catalogs.json`：构建与校验版本化词库，不截断、不自动补词凑数。
- `grammar.py`：英语前缀语法，维护当前可能的语法分析，筛掉无法继续或无法在预算内结束的词。不预写具体词语组合或笑点。
- `lab.py`：单词选择、确定性空格／首字母处理、标点、END、重复限制、调用与字数预算。
- `transport.py`：官方 TypeSafe 请求、超时、严格响应验证。不跟随重定向，不自动重试。
- `test_lab.py`：语法与终止、重复循环、服务故障备用回复等离线验证。
- `cases.json`：28 道合成测试题；边界题现在要求角色回复，旧版 expectedStop=no_match 已移除。
- `runs/`：真实请求与响应，包括实验失败；不保存密钥。
- `archive/seed1/`：旧短词组版的代码、语料和题集；不能作为当前行为要求。

## 始终回复与诚实记录

“不知道未来”“没听懂”“不接无限循环指令”等是正常对话情境，由角色表达，而不是退出生成。具体危险仍应获得明确、关切的回应，不能为了保持神秘而鼓励忽视危险。

服务故障、超时、非法响应、预算耗尽时，给出该角色的预写备用完整回复。记录 `origin=authored_fallback`、`generationStatus=failed` 和真实原因，保存未完成的 `partialText`；不把备用回复计入模型成功率。正常生成是 `origin=jev`。备用回复保证界面有回应，不证明生成质量达标。

Stone 最多 22 个词、32 次选择；Jester 最多 30 个词、42 次选择。调用上限包含一次意图选择、逐词及 END。总时限 120 秒，每次请求最多 25 秒；这些是保护上限，不是期望延迟。到时停止，应用无法撤销已到供应商的计费。实测延迟必须随结果报告。

不允许相邻重复、ABAB/ABCABC 等周期；内容词通常最多出现两次，功能词允许正常复用。END 只有完整语法路径和终止标点后才可选。达到上限但未完成时不能冒充一个模型完整回答。

## 运行

在项目根目录执行：

```bash
python3 experiments/language/build_catalogs.py
python3 -m unittest discover -s experiments/language -p 'test_*.py' -v
python3 experiments/language/lab.py
```

最后一条仅 dry-run。真实调用读取环境变量或项目 `.env` 的 `TYPESAFE_API_KEY`，固定请求 `jev-1.13.0`，返回模型须相符：

```bash
python3 experiments/language/lab.py --live --cases perfect,nonsense,invent_future --max-calls 225 --out runs/my-new-run.jsonl
python3 experiments/language/report.py runs/my-new-run.jsonl --out CURRENT-RESULTS.md
```

`--max-calls` 是本批最坏调用上限；只有计划不超过它才执行。输出文件必须新建，不能覆盖旧实验。`--oracle-repeats` 控制真正独立重复，无缓存。`--encoding text` 可用于受控消融。

## 实测结论的边界

纯开放词级选择已经出现语法混乱，结果保留在 `words2-*` 中。不能把“选到了合法词”“按时停止”当作“句子可读”。语法版仍出现语义混乱；当前再加入一次 JEV 表达意图选择，并让词选择比较完整前缀。每个生成步骤仍是独立单词，意图不是预写答案。新修订被服务连接失败／超时阻断，尚无成功的真实质量样例。原始结果里的 `generationStatus=complete` 仅代表机械闭合，不代表人工质量通过。

旧版 [RESULTS.md](RESULTS.md) 和 [FINDINGS.md](FINDINGS.md) 是 seed1 历史记录；本轮新结果另存，避免覆盖失败证据。

本轮详情：[CURRENT-FINDINGS.md](CURRENT-FINDINGS.md)、[CURRENT-RESULTS.md](CURRENT-RESULTS.md)。
