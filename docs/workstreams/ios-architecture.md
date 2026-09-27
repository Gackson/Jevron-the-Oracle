# iOS 原生执行计划

实施更新（2026-09-27）：首版 SwiftUI 工程已创建在 `ios/`，运行方式见 `ios/README.md`。全屏场景、门帘视频接入、输入/语音、逐词显现、连续会话与历史已进入代码；会话 API 采用 `docs/IOS-CONVERSATION-API.md` 的 v2 客户端草案，尚待服务端。下文是早期规划记录，遇到范围/接口差异以最新体验文档和代码状态为准，不能把旧版“只规划”描述理解为当前工程状态。

状态：仅规划与只读核验，2026-09-27。未创建 Xcode 工程、安装 App、调用 JEV、读取密钥或部署服务。本文由 C 原生工作流拥有，冲突以 `EXECUTION-PLAN.md` 与 `docs/CONTRACTS.md` 为准；`contracts/` 是未来生成代码/schema目录，不取代文档合同。

## 当前决定与事实边界

最新用户决定优先于旧提案：使用类似立体照片的**分层图片视差**，不是实际 3D 模型。三位角色为 Oracle / Stone / Jester；App 仅英文。用户自己的 iPhone 是目标演示设备。语音先转成可编辑文字，再由用户确认提交；始终有文字输入。

| 类型 | 结论 |
| --- | --- |
| 本机已验证 | `xcodebuild -version`：Xcode 26.0，build 17A324；`xcrun --sdk iphoneos --show-sdk-version`：26.0 |
| 先前已验证 | `xcode-select -p` 指向 `/Applications/Xcode-26.0.app/Contents/Developer` |
| 本次验证受限 | `xcrun simctl list devices available -j` 返回 CoreSimulatorService 连接失败、日志写入 Operation not permitted；不能据此声称没装模拟器/runtime |
| 本次验证受限 | `xcrun devicectl list devices --timeout 10` 超时；脱敏输出无法确认连接设备数量，不能声称没有 iPhone |
| 未验证 | 用户 iPhone 型号、系统版本、USB/无线配对、信任、Developer Mode、Xcode 对该系统的设备支持、开发团队与签名、可用 provisioning profile |
| 未验证 | 真机英文语音可用性、离线识别、运动传感器、图片分层质量、内存/帧率、后端真机可达性、JEV 质量与时延 |
| 实施建议 | SwiftUI + Observation + Core Motion + Speech/AVFAudio；最低 iOS **17.0**。这是为 Observation 简化状态所有权的工程选择，不代表视差需要 iOS 17 |

SwiftUI 的 Observation 支持从 iOS 17 开始，适合使用 `@Observable`、`@State` 和 `@Bindable`。[Apple Observation 迁移文档](https://developer.apple.com/documentation/swiftui/migrating-from-the-observable-object-protocol-to-the-observable-macro)

本次读过主 Agent 核验的 [SwiftUI Expert Skill](https://github.com/AvdLee/SwiftUI-Agent-Skill/blob/b24e68a965dc4b5bd2cc41dc60c094a26a9379ce/skills/swiftui-expert-skill/SKILL.md)，以及 state-management、performance-patterns、相关 latest-apis 条目。采用其状态所有权、细粒度刷新、任务取消原则；不照搬其中 SDK 27 条目，不加入 Liquid Glass。当前本机 SDK 为 26，实际编译 availability 为准。技能并未全局安装。

## 最早关口：在用户 iPhone 上启动

实施的前20分钟就验证以下链路，不能留到美术完成后：

1. 用户手机连接 Mac，解锁并信任；在 Xcode 看到目标设备和系统版本，确认本机 Xcode 支持。若手机系统比工具链可支持范围更新，先解决工具链或换兼容设备；不要在计划阶段声称可运行。
2. 用户选择现有 Apple 开发团队，唯一 bundle identifier，Automatic Signing。检查签名错误；不要输出证书私钥、设备唯一标识、完整团队资料。
3. 需要时由用户在手机启用 Developer Mode、重启并确认。此项需设备本人操作，不能静默替用户完成。[Apple Developer Mode](https://developer.apple.com/documentation/xcode/enabling-developer-mode-on-a-device/)
4. 创建最小 shell 并 Build & Run，手机打开 App。此时即记录构建、安装、启动三项结果。
5. 确认一个文本问题可到达测试代理；麦克风和 Speech 权限只在用户点击语音时请求；确认倾斜驱动测试层。

签名与设备运行需要正确的开发账号/团队和 provisioning 配置；Xcode 支持自动签名，但本机账号状态未知。[Apple capabilities 与签名配置](https://developer.apple.com/documentation/xcode/adding-capabilities-to-your-app)

仅成功编译或模拟器显示不算用户iPhone演示通过。若20分钟仍卡在设备/签名，立即报告阻碍并继续独立的文字链路、美术与后端工作；模拟器是辅助，不替代真机验收。公开分发、TestFlight、App Store不属于四小时目标。

## 分层图片舞台与资产合同

唯一渲染入口：`ios/JEV/Presentation/ParallaxScene.swift`。SwiftUI `ZStack` 叠加 background / subject / foreground，以 `offset` 产生深度差。固定镜框裁切，文字、按钮、输入框独立于移动层，始终保持稳定。

不引入 RealityKit、ARKit、USDZ、深度模型、摄像头权限。也不假设能调用系统锁屏照片自动生成的空间效果；本方案由提供好的分层图片与 Core Motion 自己实现。

资产交付严格按 [共享契约](../CONTRACTS.md)，不另建字段；以下参数是合同初始值，由真机验收后统一更新：

| 字段/资产 | 约定 |
| --- | --- |
| `characterId` / `schemaVersion` | `oracle` / `stone` / `jester`；schemaVersion=1 |
| `canvas` | 母图1536×2048；实际生成尺寸验收后确认；各层同宽高、原点、未裁切画布 |
| `background` | 不透明，包含补全的被人物遮住区域，避免人物移动露洞 |
| `subject` / `foreground` | PNG 透明层；保持完整原画布，不能每层独立紧裁，否则定位错位 |
| 每层 manifest | `id`、`file`、`depth`；file为background.png等文件名，数组顺序即后到前 |
| 方向语义 | 正 tilt.x 表示画面向右；`depth` 非负，前景大于主体大于背景；角色差异只能通过 manifest 配置 |
| 初值 | background深度0.15、subject 0.55、foreground 1；motion.maxTiltDegrees=10、maxOffsetPoints=12、overscanScale=1.12；单位为SwiftUI points，不是舞台比例 |
| 兜底 | sourceStatus=layered或flat_fallback；前景可选，无文件则移除该层；静态完整图交付按合同记录 |
| 可访问性 | `accessibilityLabel` 描述画面；图层本身合并为一项，层不分别朗读 |

compositor 统一计算容器 aspect-fill 比例和裁切，不让各层分别 `.scaledToFill()` 到不同边界。背景预留超出可见边界的 overscan；画布外扩量要覆盖双向最大 offset。用 manifest 的 safe area 指导关键角色面部/物件避开裁切与结果文字。

设计在assets/<characterId>/交付图片、manifest和来源README；C独占资源导入、parser、compositor和运动算法。设计不可另造SwiftUI渲染器。切神仅换配置与缓存图片，不重建传感器。初版只缓存当前神与必要相邻神；1536×2048 RGBA每层约12 MiB、三层36 MiB、三神108 MiB，仅原始像素预算，实际峰值需真机测量，不能用PNG文件大小代表运行内存。

## Core Motion：校准、平滑、生命周期

设备姿态通过单个 `CMMotionManager` 取得。使用 `.xArbitraryZVertical`，先检查硬件与 reference frame 可用性；不需要地理北向。Apple 将该参考系用于相对起始姿态的变化测量。[Apple 设备运动数据](https://developer.apple.com/documentation/coremotion/getting-processed-device-motion-data)

以下是体验参数建议，不是 Apple 限制：

- 进入可见舞台、恢复前台、切换设备方向或点击 Recenter 时，取稳定起始姿态作为中位。第一份有效样本之前输出零位移。
- 以基准四元数的相对旋转计算 pitch/roll，并映射到当前界面方向；不要直接用跨 ±π 的 Euler 相减。初版锁定竖屏以缩小验证范围。
- 将用户倾斜约 ±10° 归一化并限幅到 `[-1,1]`；公共偏移乘12 points，每层再乘depth。忽略约0.3°微噪声；不将yaw映射为持续漂移。
- 请求 30 Hz 起步；使用基于真实 `dt` 的低通 `a = 1 - exp(-dt / tau)`，建议 `tau = 0.12–0.18 s`，输出 `previous + a * (target - previous)`。视觉调参归原生与设计共同验收。
- 超时/无效/非有限样本丢弃；暂停后回到中位，不跳到上一会话的极限角度。高频处理不放在主 operation queue，只把最终二维值送入主 actor。[Apple 更新队列说明](https://developer.apple.com/documentation/coremotion/cmmotionmanager/startdevicemotionupdates%28using%3Ato%3Awithhandler%3A%29)
- 原生只创建一个 motion manager；舞台不可见、App 进入后台或用户关闭动态效果时停止更新。Apple 明确建议不需要数据时停止服务。[Apple CMMotionManager](https://developer.apple.com/documentation/coremotion/cmmotionmanager)
- `accessibilityReduceMotion` 或用户关闭动态效果时固定为零位移，取消自动漂浮等装饰动作。拖动替代应限制在舞台，并与横向切神手势分区；Reduce Motion 下允许静态观看，不强制拖动。

高频姿态由局部 `MotionController` 持有，仅 `ParallaxScene` 读取二维 offset；`ShrineView`、问题编辑和回应列表不订阅整个运动对象。避免每帧解码图片、读取 JSON 或写文件。没有运动硬件时显示静态图，拖动是可选替代。

## 语音输入与权限

最低 iOS 17 采用 `SFSpeechRecognizer(locale: en_US)` + `SFSpeechAudioBufferRecognitionRequest` + `AVAudioEngine`。不为 MVP 强制 iOS 26 的新语音管线。英语支持仍需按真机 locale 和 runtime 检查，初始化成功不等于服务可用；检查 `isAvailable`。[Apple SFSpeechRecognizer](https://developer.apple.com/documentation/speech/sfspeechrecognizer)

Info.plist 包含两个用途说明，并只在点击 Speak 后申请：

- `NSMicrophoneUsageDescription`：`Use the microphone to turn your spoken question into text.`
- `NSSpeechRecognitionUsageDescription`：`Transcribe your question so you can review it before sending.`

Speech 请求 `SFSpeechRecognizer.requestAuthorization`，麦克风使用 iOS 17+ 的 `AVAudioApplication.requestRecordPermission`；不能把这两项授权当成同一个状态。[Apple Speech 权限](https://developer.apple.com/documentation/speech/asking-permission-to-use-speech-recognition)、[Apple AVAudioApplication](https://developer.apple.com/documentation/avfaudio/avaudioapplication)

流程：编辑 → 请求权限 → 录音并显示临时文字 → 停止 → 最终文字或当前部分文字 → 可编辑 → 用户点击 Offer。录音回调不得自动发 JEV 请求。识别期间暂停手动编辑，或明确结束识别后再编辑，避免后到的 partial 覆盖用户输入。

如果 `supportsOnDeviceRecognition == true`，可设置 `requiresOnDeviceRecognition = true` 并实测；false 时本方案允许 Apple 在线识别，并在输入旁用简短英文说明 `Speech recognition may use Apple’s servers.`。不能宣传所有 iPhone 都离线，不能把该属性检查等同于已验证离线成功。[Apple 本机识别条件](https://developer.apple.com/documentation/speech/sfspeechrecognizer/supportsondevicerecognition)

录音最多 30 秒是产品预算，用户可提前停止。权限拒绝、restricted、识别不可用、音频 interruption、无输入、耳机路由改变、App 后台均结束录音并保留已有文字；提供 `Type instead`。麦克风 tap 只安装一次，所有结束路径都移除 tap、停止 engine、endAudio 或取消 recognition task、释放 audio session。录音本身不落盘。

停止后给最终识别一个短等待窗口（建议最多1–2秒）；超时用现有文本进入编辑，递增录音session ID，忽略迟到回调。最终提交以Offer时快照为准。长度按共享合同：去首尾空白后最多500个Unicode scalar，Swift用unicodeScalars.count、Python用len，拒绝surrogate；UI与服务端一致执行。

## 状态机、取消与旧结果隔离

共享UI状态采用idle→listening→editing→thinking→revealing→result；下表是内部细分，recording/generating/complete分别映射listening/thinking/result，不另建外部协议。推荐一个 `@MainActor @Observable` 的 `ReadingSession`，由根View的 `@State private` 持有；只读值或需要编辑时用 `@Bindable`。识别task、请求task和音频引擎是私有生命周期资源。

| 状态 | 可用动作 | 下一状态 |
| --- | --- | --- |
| `editing(draft)` | 切神、编辑、Speak、Offer | `authorizing` / `recording` / `generating` |
| `authorizing` | 取消 | `recording` 或带提示的 `editing` |
| `recording(sessionID, partial)` | Stop、Cancel | `finalizingSpeech` / `editing` |
| `finalizingSpeech` | 取消等待 | `editing`，文字可改，不自动提交 |
| `generating(runID, selectionSnapshot, pieces)` | Cancel；切神先取消 | `complete` / `failed` / `editing` |
| `complete(reading)` | 新问题、切神；P1 Keep echo | `editing` |
| `failed(runID, partial, error)` | 编辑、明确 Retry | `editing` / 新 `generating` |

实现规则：

1. Offer 同步检查非空、长度和当前状态；同一主 actor turn 内先切到 generating，再启动 task，阻止双击重复发送。
2. 捕获不可变的characterId、question、locale=en、runID；catalogVersion由服务端固定后响应，客户端不预先捕获未知版本。任务只更新同一runID且仍在generating的会话。
3. 切神、再次生成、取消或后台时取消 Swift Task / URLSession task，并递增 session/run ID；返回之前和每次 await 后都检查取消及 ID。Speech 回调另有 speechSessionID，不能复用生成 ID。
4. 本地取消不保证远端已经停止或不会计费。服务端观察断开并停止后续 Choice；已开始的上游请求按能力 best effort 取消。
5. 只在收到完整 JSON、`status == complete` 且本地规则校验通过后进入 complete。超时、解码失败或 `status == incomplete` 都进入 failed；若返回有效 partial 可保留，但不能显示为完整神谕。
6. 每个片段使用稳定的 `(runID,index)` 身份。客户端检查JSON格式、requestId/characterId匹配、版本字段存在和片段数量；服务端校验候选ID allowlist与原文。App直接显示响应text，不复制完整词库映射。逐行显现是展示动画，不是实时token流。

不要只依赖 `.task` 随视图消失取消：SwiftUI 可能保留页面身份，且 callback 型 Speech 工作需要显式清理。高频运动任务的生命周期独立于生成任务；后台时都清理。

## 后端与词库合同

最终字段以 [docs/CONTRACTS.md](../CONTRACTS.md) 为准。服务端权威词库、稳定ID、完整/未完成状态、requestId隔离。P0完整JSON，流式协议留待P1。

单次 `POST /v1/readings`，请求只含requestId、characterId、question、locale="en"。版本由服务器选择且一次运行中固定。客户端不提供版本、模型key、候选列表、已有选择或prompt。服务器负责Choice调用和候选校验。

客户端使用 `URLSession.data(for:)` 接收一次完整 JSON。响应字段为：

| 字段 | 含义 |
| --- | --- |
| `requestId` / `characterId` / `catalogVersion` | 前两项须与提交快照一致；版本由服务端返回，客户端校验格式并保留追溯 |
| `status` | `complete` 或 `incomplete`；HTTP成功本身不代表神谕完整 |
| `segments` | 有序 `{candidateId, text}` 数组，text 是词库原文；语义描述不发给 UI |
| `stopReason` | 由主合同枚举，区分合法终止与未完成 |

非2xx使用 `{requestId,error:{code,retryable}}`，不输出内部堆栈或秘密。有有效片段但异常停止时status=incomplete，stopReason=composition_error|deadline|no_match，UI明确未完成、P0不保存。无可展示片段时非2xx。__no_match__为后端控制候选，占255上限，不是展示词；已有片段返回incomplete/no_match，否则非2xx/no_match，提示补充或改写，不自动重试同一输入。等待thinking，返回后才展示，不声称实时流式选择。

Oracle正好1次Choice完整短答；Stone正好3次，每次看到已有内容并排除重复ID。Jester从setup开始按nextSlots转移，合法terminal=true结束，共2–4次选择；第4次只给可合法终止候选，无额外END请求。合法完成返回complete/rule_complete。客户端不靠动画虚构实时选择。

终止与标点/换行按共享合同；原生直接按segments展示text，不补句、翻译或复制完整词库；候选ID allowlist与原文/版本固定校验属于服务端。内部语义说明不发UI。

P0不做透明重试或重复提交，明确Retry产生新requestId。requestId仅用于关联与前端隔离，不承诺跨实例计费幂等，不引入数据库；总时限由首次实测后Lead锁定。日志仅requestId、候选ID、版本、延迟、状态，不存原始问题。

密钥仅存在服务端环境变量，不放 App bundle、xcconfig、Info.plist、Assets 或源码。iPhone 的 `localhost` 是手机自身；开发代理必须有手机可达地址。HTTPS 测试 URL 最省真机 ATS 配置；若使用 Mac 局域网服务，需另验证本地网络权限、ATS 最小例外和同网连通性，不使用全局允许不安全网络。当前尚未部署或选定服务地址。

## 文件所有权与四个 Agent 槽

路径是未来执行建议，当前只写本文。根 Agent 冻结合同后再创建代码。四槽配置为：主 Agent（集成+后端）、设计、语言、原生。不开第五个后台 Agent；后端工作由主 Agent 拥有，或某工作流完成后明确移交其槽位。

| Owner | 未来独占路径 | 边界 |
| --- | --- | --- |
| Lead | `server/**`、`contracts/**`、`tests/integration/**`、根文档 | 后端、协议、集成验收；不并发修改C的iOS工程 |
| C原生 | 整个 `ios/**`、`tests/ios/**`、本文 | .xcodeproj、App、Networking、Domain、权限/签名、资源导入、Presentation/ParallaxScene.swift、motion、speech、session，全由C独占 |
| A设计 | `assets/**`、设计工作流文档 | 每角色母图、图层、manifest与来源README；不改compositor |
| B语言 | `content/**`、`tests/content/**`、语言工作流文档 | 词库、语义、组合图、评估集；不改代理 |

Lead冻结文档合同和样例；C自行创建Swift DTO/ReadingClient/可控fixture与session/UI。fixture只用于Preview/联调并标识，不冒充实时结果。A在assets交付，C导入、登记并独占工程、Info.plist和签名设置；B在content交付，Lead加载服务器。设备阻碍由Lead协调用户，不把工程所有权拆回Lead。

## 四小时关键路径与验收

| 时间 | 主 Agent / 后端 | 原生 | 设计与语言 | Gate |
| --- | --- | --- | --- | --- |
| 0–20 min | 合同冻结、Oracle小样接口 | 工程/DTO/fixture、用户手机OS/签名/安装、权限配置 | 坐标manifest、种子词库 | 手机打开App；接口样例确定 |
| 20–60 min | JEV Oracle真实一次选择 | ReadingClient/JSON decoder、文字主流程、motion占位层 | Stone图层、另两神母图、语义 | iPhone文字→真实Oracle回应 |
| 60–120 min | Stone/Jester顺序选择、错误和终止 | 三神切换、资源导入、视差、speech编辑确认 | 三神资产/词库首版 | 三神接通，文字与语音可用 |
| 120–180 min | 小样/时延/异常验证 | 权限拒绝、取消/迟到结果、网络、Reduce Motion | 修接缝双影与语言问题 | 脚本连续通过 |
| 180–240 min | 集成验收、冻结范围、排练 | 真机性能/布局/输入回归 | 只修实测问题 | 三神各一次和失败恢复，用户可亲自操作 |

优先测试复杂逻辑而非静态UI：C用可控client验证双击只发一次、A迟到不覆盖B、取消后响应无效、incomplete不是complete、非2xx/坏JSON正确处理。Lead测Oracle=1、Stone=3、Jester边界、非法ID和版本固定；C负责客户端与state reducer/session测试，Lead负责后端/集成测试。不写与SwiftUI排版一一对应的脆弱测试。

真机手工必须覆盖：首次权限同意与拒绝、录音中停止/后台、转写后编辑、耳机/电话中断至少一种、键盘不挡 Offer、文字上限、网络断开、连续切神与重试、Reduce Motion、倾斜不露边、切神图层对齐、静态图 fallback。

P1 Echoes 本地保存只在这些通过后加入，可用本机 JSON；没有账户、云数据库、同步或分享系统要求。默认不保存原始问题。

## 超时后的明确降级

- 图片分层未按时交付：使用每神 flattened preview，静态舞台；若只有两层则 manifest 显式声明，不伪装完整三层。
- 视差接缝/性能不稳：降低最大 offset、30 Hz、仅当前神解码，或完全静态图；主流程仍可使用。
- 语音不可用：保留文本输入；语音失败不能阻止提问。离线语音失败不自动承诺离线修复。
- 后端结果延迟过长：保留明确 thinking/取消，测量各次 Choice 耗时并缩小候选或优化服务；不通过伪造结果掩盖延迟。P0 完整 JSON 是已选择方案，流式体验留待 P1。
- 组合质量/延迟差：先让 Oracle 真调用成为稳定演示主线，Stone/Jester 用清楚标为之前真实结果的记录辅助，不冒充实时完成。
- 真机安装受阻：记录具体签名/系统/连接错误；模拟器可供工作验证，但“用户 iPhone 演示”仍未完成。

## 可复制的未来执行提示

### 原生执行 Agent

> 按EXECUTION-PLAN.md和docs/CONTRACTS.md实现，冲突以两者为准。你独占整个ios/、tests/ios/和本文，包括.xcodeproj/App/Domain/Networking、权限、签名设置、资源导入；不把工程拆给Lead。前20分钟确认用户iPhone系统、签名和安装启动，建议iOS17+、英文UI。创建DTO/ReadingClient/fixture/state machine；请求仅requestId/characterId/question/locale，服务器固定版本后响应，text直接展示，客户端检查格式/数量/角色/请求，无完整词库副本。按assets/<characterId>/manifest导入同画布图层，唯一Presentation/ParallaxScene.swift读取file/depth，源1536×2048、10°/12pt/1.12，前景可选。实现motion校准平滑限幅/后台停止/Reduce Motion、Speech双权限与转写确认、文字fallback。完整JSON status=complete才完成，incomplete/no_match按合同呈现，逐行出现只是展示动画。runID隔离旧结果，Retry新ID，无透明重试；fixture标Preview。验证权限拒绝、双击、取消、迟到结果与真机布局；只改自己文件，合同变更先同步Lead。

### Lead / 后端与集成执行

> 按EXECUTION-PLAN.md和docs/CONTRACTS.md执行。你拥有server/、contracts/、tests/integration/和根文档；C独占ios/，A交付assets/，B交付content/。冻结文档合同和样例，先通Oracle再扩Stone/Jester；版本由服务器固定，按合同返回完整JSON。Oracle1次、Stone3次、Jester按terminal/nextSlots在2–4次内终止，无额外END请求；__no_match__按有效片段有无走incomplete或非2xx。候选ID/原文/组合校验在服务器，语义说明不发UI，密钥仅服务器，不存原始问题、不加数据库、不承诺requestId跨实例计费幂等。协调C解决设备和网络gate，不改C工程；验证真实结果和异常，P0稳定前不扩流式、保存或分享。
