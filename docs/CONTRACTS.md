# 共享契约 v0.1

> 最新用户要求（2026-09-27）：禁止内容 no-match；每位角色必须回复。Oracle 255 条完整短答，Stone/Jester 各 255 项词级词库，Stone 优先多句式碑文，Jester 逐词组句。当前实现见 [语言实验室](../experiments/language/README.md)。下文旧的无匹配和 2–3 片段规则已被替代。

> 语言实验更新：Stone 结构尚在比较，本文件保留为早期生产接口提案。独立实验的资产与测试见 [语言实验室](../experiments/language/README.md)，实验结构不等于已冻结的生产契约。

状态：规划阶段定义，尚未实现。主 Agent 维护。本文件优先于分项计划里的示例字段，冲突由主 Agent 统一。

## 1. 固定标识与目录

- `characterId`: `oracle | stone | jester`；显示名 Oracle / Stone / Jester。
- `schemaVersion`: `1`；`catalogVersion` 如 `2026-09-27.1`。每次修改候选内容或语义更新版本，ID 不复用给不同含义。
- A 交付 `assets/<characterId>/` 下的源图、图层和 `manifest.json`；C 导入 App 资源，保留原名和层的顺序。
- B 交付 `content/oracle.json`、`content/stone.json`、`content/jester.json`、`content/semantics.json` 和 `content/evaluation-cases.json`。
- C 独占 `ios/` 和 Xcode 工程；Lead 独占 `server/` 与 `contracts/`。

## 2. 候选资产

目录顶层包含 `schemaVersion`、`catalogVersion`、`characterId`、`mode`、`minSelections`、`maxSelections`、`candidates`。

模式：Oracle `whole_reply`，1 次；Stone `noun_sequence`，3 次；Jester `phrase_sequence`，2–4 次。标点由确定性呈现规则处理，不占用模型调用。

候选示例（用于约定结构，不是完整词表）：

```json
{
  "id": "stone.threshold",
  "text": "A threshold.",
  "semanticCodes": ["transition.beginning", "boundary.crossing"],
  "meaning": "A boundary between the familiar and a possible next stage.",
  "useWhen": ["The question concerns beginning, entering, or leaving a familiar state."],
  "avoidWhen": ["The selection would invent an event or relationship fact absent from the question."],
  "contrast": "A threshold suggests approaching a transition; an anchor suggests remaining attached.",
  "slot": "noun",
  "nextSlots": ["noun"],
  "terminal": false
}
```

- `text` 是展示原文，不能在返回后由另一模型改写。
- `meaning/useWhen/avoidWhen/contrast` 是给 JEV 的候选说明，默认不传前端。
- `semanticCodes` 必须在语义字典中定义，是编辑与评估标签，不自动对应心理诊断或模型内置代码。
- `slot`、`nextSlots`、`terminal` 用于语法与流程，不是 JEV 自由生成字段。
- 可选编辑字段为 `dedupeGroup`、`tags`、`grammar`（例如单复数兼容性）；它们不改变必需字段，也不另建一套外部协议。Jester 首槽固定 `setup`，后续槽名由词库定义并由图结构校验。
- 本轮人工三步样例的槽为 `setup → predicate_singular → beneficiary_close`。其他两步/四步路径需在内容资产中完整定义；后端不硬编码只有这一个样例分支。
- Oracle 所有候选为 `whole` 且 `terminal=true`。
- Stone 固定 3 次，由序列长度完成，无需单独 END；重复 ID 从后续候选中排除，避免同一名词刷屏。
- Jester 从 `setup` 开始，至少 2 次；合法 continuation 的 `terminal=true` 才结束。第 4 次只提供能合法完成的 terminal 候选；如果没有这样的候选，这是内容结构错误，不强制拼凑。
- 所有可达 Jester 分支必须能在 4 步内结束；同一 ID 不连续重复。完整句法组合由 B 提供，Lead 校验。
- 每次 Choice 不超过 255 个候选；后端应用 slot 规则后将候选 ID 及完整自然语言说明传给模型。
- 每次 Choice 可包含后端加入的 `__no_match__` 控制项，计入 255 上限。它不属于展示文本，选中后结束此次运行；不能把供应商失败伪装成某句含糊神谕。
- 不把不确定性简单转成随机抽签；允许各模式有清楚定义的低信息适用候选。非法响应或网络失败走错误路径。

## 3. 提问接口

`POST /v1/readings`，前端一次请求，后端内部顺序执行选择，P0 不流式传输。

```json
{
  "requestId": "<uuid>",
  "characterId": "oracle",
  "question": "What am I waiting for?",
  "locale": "en"
}
```

输入为用户已确认的文本，去除首尾空白后最多 500 个 Unicode scalar，Swift 使用 `unicodeScalars.count`，Python 使用 `len`；接口拒绝孤立 surrogate。版本由后端选择并在一次运行中固定；不允许客户端提交任意候选表、密钥、模型指令或已有选择来改变执行规则。每次重试分配新 requestId，不自动循环重试。

完成响应示例：

```json
{
  "requestId": "<same uuid>",
  "characterId": "oracle",
  "catalogVersion": "2026-09-27.1",
  "status": "complete",
  "segments": [
    {"candidateId": "oracle.urgency", "text": "Let the urgency pass. See what remains."}
  ],
  "stopReason": "rule_complete"
}
```

Stone 3 个 segments，前端分行；Jester 按规定分行呈现已选片段，英文空格/标点规则不由前端自由猜测，候选需设计为可分行短语。Oracle 显示一段。

若已有有效片段但组合异常终止，响应 `status=incomplete`，`stopReason=composition_error|deadline|no_match`；UI 明确显示未完成，P0 不保存为完整回应。没有可展示结果时返回非 2xx 错误：

```json
{
  "requestId": "<same uuid>",
  "error": {"code": "upstream_unavailable", "retryable": true}
}
```

建议错误码：`invalid_input`、`unknown_character`、`catalog_invalid`、`no_match`、`upstream_unavailable`、`invalid_model_output`、`deadline`。`no_match` 提示补充或改写问题，不对同一输入自动重试。UI 映射为友好英文，不直接显示供应商原始错误或鉴权信息。

客户端取消 URLSession 请求并丢弃晚到结果；不保证已经到达供应商的推理能撤销或不计费。requestId 用于关联和前端隔离，不等于跨服务器实例的计费幂等保证；P0 禁用重复提交，不自动重发。所有请求设总时限，数值以首次实测后锁定。

## 4. 分层图片契约

每角色采用统一肖像画布，建议源图 1536 × 2048，实际生成尺寸先验收再导入；所有图层必须同尺寸且保持母图坐标。前景可选，至少背景与主体两层构成分层视差。

```json
{
  "schemaVersion": 1,
  "characterId": "stone",
  "canvas": {"width": 1536, "height": 2048},
  "layers": [
    {"id": "background", "file": "background.png", "depth": 0.15},
    {"id": "subject", "file": "subject.png", "depth": 0.55},
    {"id": "foreground", "file": "foreground.png", "depth": 1.0}
  ],
  "motion": {"maxTiltDegrees": 10, "maxOffsetPoints": 12, "overscanScale": 1.12},
  "sourceStatus": "layered"
}
```

参数为初始建议，需真机验收。`sourceStatus` 为 `layered | flat_fallback`。P0 只做平移差，不强制旋转、扭曲网格或计算深度图。图层数组顺序即从后向前绘制。

姿态输入归一化并限制在 [-1,1]；每层偏移 = 公共偏移 × depth。进入/恢复场景后重新设置中位姿态，统一平滑输入，不对每帧创建新的长动画。文字区域与按钮不读取运动值。

所有图层在相同 aspect-fill 画布内合成，再统一裁切到视窗。overscan 是绘制外扩系数，A 要提供足够画面内容；角色的主体边缘不能被 alpha 紧裁切，否则坐标会错位。极限位移时检查露边、空洞、主体残影和前景遮字。

背景必须是补全后的 clean plate，subject 与 foreground 带真实透明通道。无需前景则移除该项，不放一个不存在文件。源母图与图层来源/提示保存在 `assets/<id>/README.md`，不得把概念图标成已验证的最终分层资产。

C 导入资源时同时登记该角色选定的完整母图，供图层缺失或解码失败时使用；母图文件名从交付 README 核对，不能猜测不存在的 fallback 文件。切换到母图时标记实际使用了降级路径，避免错误地报告多层验收通过。

## 5. UI 状态与权限

状态：`idle → listening → editing → thinking → revealing → result`；键盘路径跳过 listening；任何输入/请求失败进入可恢复 error。取消回到 editing 或 idle。角色选择变化会终止当前录音/请求，并更新 active requestId，旧事件不得修改新角色。

语音仅点击后开始，显示录音状态，结束后确认文本再提交；麦克风与语音识别权限未授权时仍可键盘输入。设备姿态仅场景可见且未启用 Reduce Motion 时更新；后台暂停。VoiceOver 可访问角色名、输入和结果，不朗读内部语义编码。

## 6. 数据与演示配置

模型密钥仅在后端。原始问题默认不保存、不打到分析日志；调试日志记录 requestId、候选 ID、版本、时长和终止原因。用户可选的 Echoes 保存属于 P1。

内置 fixture 数据只用于开发预览与接口联调，画面注明 Preview；真实演示模式不静默回退 fixture。历史真实结果显示其来源状态。
