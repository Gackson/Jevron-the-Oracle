# 中文回答模式与石碑语气 · 2026-09-27

资源版本：`2026-09-27.zh1-stela`；提示版本：`language-lab-6-zh-stela`。

## 使用方式

Settings → Reply language · 回答语言 → 简体中文。可随时切回 English，设置在本机保存，重启后仍保留。切换影响之后的回答，历史记录保持原文。打开设置会取消未完成请求，避免旧请求混入新状态。

这是回答语言选项，不是整套界面的中文翻译。语音识别跟随选择使用 zh-CN / en-US，但真实麦克风识别仍需系统授权与系统识别服务。

## 词库与生成

两种语言各有四个独立的255项词库：Oracle 为255条完整短答，Stela/Jester/Fool 为249个词、5个标点和END。中文 Oracle 与英文 Oracle 的意图分类一一对齐；逐词角色使用中文语法，不先生成英文再逐词翻译。每次模型选择仍携带当前问题、历史、意图、候选语义与已生成前缀。

- 石碑英文加入 hath、doth、abideth、beareth、waxeth、waneth、speaketh、knoweth，并通过词性与语法控制形态一致。这是可读的古雅英语风味，不是严格复原历史 Old English。
- 中文石碑以若、则、之、犹等文言结构配合山、石、水、川等物象；不允许把整条铭文缩成孤立命令，名词可作“山之影”式组合，形容词直接修饰名词。开、合兼具及物和不及物用法。
- Jester 的反问更偏向提问者自己的理由；Fool 用日常物件和错位动作形成小场景。
- 中文按词选择、按字浮现，最终文本不插入英语词间空格；中文标点附在前字，避免换行后孤立悬挂。
- 120秒总时限、25秒单请求时限、词数/步骤/重复上限继续生效。无 no_match 分支，故障有明确标注来源的中文角色保底。

词库入口：[双语 HTML](../vocabulary/current-vocabulary.html)、[中文完整表](../vocabulary/chinese-vocabulary.md)。每种语言各1020候选，合计2040。

## 实际生成与修订记录

以下均为真实 Jev 输出，不是 UI 示例回复。

| 轮次 | 角色 / 语言 | 问题 | 实际输出 / 结果 |
|---|---|---|---|
| 首轮 Python | Oracle / 中文 | 我该和女朋友分手吗？ | 说说每条路，会让你放下什么。 |
| 首轮 Python | Stela / 中文 | 我总是不敢开始，该怎么办？ | 试行。 |
| 首轮 Python | Jester / 中文 | Should I leave my girl? | 理由为什么离开她？ |
| 首轮 Python | Fool / 中文 | 作业太无聊了，给我一点好玩的想法。 | 作业把橡皮吃掉。 |
| 英文 Python | Stela / 英文 | Why am I afraid to begin? | 首词请求超时；角色保底，非模型生成成功 |
| iOS 四角色 | Oracle / 中文 | 我该和女朋友分手吗？ | 告诉我，你希望每种答案替你守住什么。 |
| iOS 四角色 | Stela / 中文 | 我总是不敢开始，该怎么办？ | 试行。 |
| iOS 四角色 | Jester / 中文 | 我该和女朋友分手吗？ | 为什么你想要分手？ |
| iOS 四角色 | Fool / 中文 | 作业太无聊了，给我一点好玩的想法。 | 作业跳舞。 |
| iOS 四角色附加 | Stela / 英文 | What remains after a relationship ends? | Stone abideth. The stone beareth memory. |
| iOS 石碑修订 | Stela / 中文 | 我总是不敢开始，该怎么办？ | 若步行，则路开明之路。 |
| iOS 石碑修订 | Stela / 英文 | What remains after a relationship ends? | What is the rest? |
| 最终 iOS 石碑 | Stela / 中文 | 我总是不敢开始，该怎么办？ | 若步行，则路开。 |
| 最终 iOS 石碑 | Stela / 英文 | What remains after a relationship ends? | Stone abideth after time. |

首轮“理由为什么离开她？”主语不自然，已将这类反问约束到人物代词。石碑“试行。”缺少碑文物象，因此去掉独立命令式；之后“路开明之路”暴露了开字被当作仅及物动词的问题，已允许“路开”自然闭合，并禁止同条铭文重复内容词。所有失败或不理想样本保留，不把完成生成等同于语言质量通过。

四角色加英文石碑的 iOS 真实调用测试整体用时16.868秒；第二次中英文石碑回归整体用时10.073秒。每条输出的具体延迟未单独记录。Python逐步日志保存在 `experiments/language/runs/chinese-first-live.jsonl` 与 `stela-archaic-live.jsonl`。

## 自动验证

- Python语言测试：40项通过，包含中文词库数量、Oracle意图对齐、英文古雅词形、中文逐词组句、短句收尾、中文石碑开合用法、失败保底和120条随机语法路径。
- 集成测试：9项通过，包含两个语言下全部角色的JavaScript/Python候选集一致性、中文 API 路由和保底。
- iOS单元测试：31项通过、5项需显式启用的真实调用测试跳过。测试语言传递、保留已有记录、流式前缀、中文排版分段、双语词库与古雅动词、失败分类、取消与语音提交生命周期。
- UI测试：中文选择、发送显示、石碑预览、重启保留语言通过。测试曾因入场动画未结束就点击设置而失败；改为等待控件启用后通过，未修改入口动效。
- 已查看中文 Oracle 与石碑 UI 截图：文字没有多余空格，标点附着、居中显示正常。截图内容明确标记为 Sample reply，仅用于显示测试，不作为模型质量证据。
- HTML词库审阅页通过脚本语法与8个完整词库的数据检查；可选择语言。没有对 file 页面执行浏览器自动操作。

测试使用独立的 JEV Conversation API 模拟器，没有占用样式任务的 iPhone Air。真实密钥仅由测试进程临时读取，临时权限600配置在结束时删除；未写入APP资源或源码。

## 限制

中文模式已接通，但这是首版语言设计。小样本不能证明所有情境下的自然度、幽默或文言质量。尤其 Fool 的回答仍可能过短，石碑的比喻与问题之间也需更多质量评测。没有声称生成文本是古籍原句，也没有声称完整实现历史古英语。

最终中英文石碑直连测试用时7.315秒，二者均 `origin=jev`。已核对最终打包 runtime 与仓库资源逐字节一致。上述输出是小样本，英文古雅程度与中文自然度尚不保证对所有问题一致。

结果包：`/private/tmp/jev-zh-closure-tests.xcresult`、`/private/tmp/jev-zh-ui-tests2.xcresult`、`/private/tmp/jev-zh-live-ios.xcresult`、`/private/tmp/jev-stela-closure-live.xcresult`。汇总见 [JSON记录](chinese-stela-live-2026-09-27.json)。
