# 第一轮判断与下一轮内容修订

日期：2026-09-27。以下判断由本轮助手阅读真实结果得出，属于作者审阅；不是独立读者盲评，不填造人工评分。[全部真实输出](RESULTS.md)与 `runs/` 原始请求／响应可核对。

本轮共 80 次 reading 实验、123 次实际 JEV Choice 调用；包含 16 次预期的边界无匹配和 1 次仅原文消融中的普通题无匹配。种子资产共 129 条：Oracle 12、Stone 名词 24／碑文 25／递进 36、Jester 32，每条都有隐性语义说明。这是首版可运行语料，不是最终规模。

## 已经得到的证据

- 原型使用 `jev-1.13.0`，没有缓存、采样重抽或后续润色。首批四个普通问题在五种形式上全部正常结束；Oracle 每题独立请求三次，分别始终选择 begin、perfect、release、rest，四题没有塌缩成一个万能回答。
- Oracle 补充覆盖其余六个语义方向，并测试三条同义改写、三条跨情境迁移题。三条改写都选择了对应原题同一个 ID；三条迁移题也落在题集允许的语义方向。每条仅请求一次，不能用来宣称重复稳定率。
- 四道关键事实对照题也跑了 Oracle、Stone 碑文、Stone 递进与 Jester。明确存在真实问题时，完整编码版本没有继续鼓励直接开始；已经表达后反复催促与从未表达的需求，也得到不同方向的回应。
- 四道边界题 × 四种形式，共 16 次 reading，均在第一步以 `no_match` 结束，没有输出片段。题型是无限重复指令、保证未来事件、忽视正在发生的危险、无意义输入。这只证明这四题的行为，不能推广为普遍的防注入或危机识别能力。
- 本地 21 项测试覆盖重复选择、ABAB/ABCABC 路径、同文不同 ID、语义族重复、无合法结尾、超时、非法分布／模型／ID、无匹配、完成后不追加 END 等边界。运行时严格有步数与字数预算；重复返回被拒绝，不通过无限重试修复。

## 编码消融最值得保留的一组

输入：短篇故事已经写完，但暴露朋友未经同意的私密经历，是否今天就分享？

| 角色 | 完整语义说明 | 仅原文（保留相同 ID 和结构） |
| --- | --- | --- |
| Oracle | Attend to the crack before asking the bridge to carry more. | Notice whose permission you are still waiting for. |
| Jester | The warning light / is not auditioning for the role of decoration. | no_match |

完整编码明确区分“多余的认可”和“必要的同意”。删去这些说明后，Oracle 的选择可能把需要解决的同意问题说成无谓等待，属于应避免的内容方向。Jester 的 no-match 是安全的无匹配，不应为了完成率而强迫它给一句话。

消融只比较四道对照题，每条件各一次；这是值得回归的一条证据，不能据此估算总体收益。完整和仅原文版本的模型、catalogHash、提示、初始候选顺序和问题保持相同。`semanticCodes` 本来不发送给模型；此实验测试的是自然语言说明的增量作用，而非符号标签的神奇效果。下一轮应重复该差异，并分别删去 `avoidWhen`、`contrast`，判断哪部分必要。

## Stone：真实样例与取舍

| 困惑 | 碑文版 | 递进版 |
| --- | --- | --- |
| 总在准备，不开始 | The threshold / cannot take the first step. | Before the crossing. / The weight shifts. / A first mark. |
| 作品反复打磨，不愿展示 | The polished surface / still bears a trace. | Beneath the polish. / A rough edge catches light. / A visible seam. |
| 反复催促对方回复 | The rope / does not soften under force. | At the tightened knot. / The tension eases. / Room between the strands. |
| 耗竭却不敢休息 | The empty basin / cannot pour from emptiness. | At the empty basin. / The pressure settles. / Space to fill again. |

碑文版的联系更容易读出，两次请求也更少。但有些句子像常规格言，休息题还出现“empty / emptiness”的语义重复。不是循环错误，却削弱了表达质量。

递进版更像 Stone 自己的观看方式，尤其创作题在同一个表面意象里形成了连贯场景。问题是目前仍可能拼出物理关系不清的场景，例如空盆与压力消退之间的连接。下一轮应给 context/change/trace 加场景兼容标签，保留跨语义组合，同时限制物理意象乱跳。

**作者的暂时倾向是继续打磨递进版，同时保留碑文版供用户比较；尚不决定最终形式。** 这与试验前优先碑文的假设不同，是阅读实际输出后的调整。

名词基线的第三项有时偏离主题，但不能简单宣称“名词形式不行”：初版每个语义方向只写了两个名词，却要求选三个，这是明确的候选覆盖混杂因素。例如“开始”题的第三项选到了 polished surface。下一轮先为每类补足第三个有区别的意象，再进行公平比较。

## Jester：已经可读，组合空间还不充分

真实输出包括：

- Your backup plan / has become your only plan.
- Your first draft / has hired its eraser as a critic.
- Their silence / is not accepting interviews.
- Your exhaustion / has filed for leave on your behalf.
- Your imaginary audience / has sold you a ticket to your own life.

这些句子具备可辨认的转折：退路取代行动、橡皮变评委、沉默拒绝采访、疲惫代请假、观众控制参与资格。没有靠无关怪词制造荒诞。

但本轮完整编码下的八道普通题全部走两步路径，没有一次采用三步路径。这可能说明两步片段已足够，也可能是词库中完整尾句过强、三步分支描述太弱。不能把“结构上支持三步”说成“模型已验证三步效果”。扩库优先给同一困惑写两到三个不同、同样可读的关系，而不是给每个 setup 机械补一个专属结尾。

## 下一轮优先级

1. 先与用户审阅这组真实样例的气质，决定 Stone 更偏碑文、场景递进，还是保留两类结构。
2. 修订 Stone 的同义重复、场景兼容，补公平的名词基线；加强 Jester 的多种关系与三步路径。每次修改内容升版，保留 seed1 原始结果。
3. Oracle 扩充相近但需要不同回应的候选，再测同题至少十次；当前每语义方向一条主候选，稳定性测试比较容易，不能外推到 40–60 条库。
4. 用独立读者盲评和新问题验证相关性、可读性与角色区别。对照语义标签只能帮助定位错误，不能替代读者理解。

完整语料未定稿，生产后端与 iOS 未接入。本轮已经提供可复现的语言实验基础和真实比较材料。
