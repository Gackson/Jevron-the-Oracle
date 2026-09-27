# 设计与 2.5D 分层图片执行计划

本文件只规划，没有生成图片、制作 App 或安装软件。依据用户最新决定，采用类似 iOS 立体照片观感的**分层图片视差**，替代旧提案的真正 3D 角色路线。英文名确定为 **Oracle / Stone / Jester**；英文界面；神秘、诗意、像一句私人启示。演示设备是用户自己的 iPhone，具体型号待执行时记录。所有时间和性能参数均为目标，尚未实测。

P0 分层目标：每角色至少背景、角色两层，前景可选；自然需要前景时优先三层。明确 fallback：每角色一张精美图片做很轻的整体位移，这是浅视差，不声称具有真正图层纵深。这里不依赖任何未经验证的系统自动空间照片 API；iOS 工程自行合成图层，资产不包含深度估计或隐藏面重建能力。

共享字段与目录以 [CONTRACTS.md](../CONTRACTS.md) 和 [EXECUTION-PLAN.md](../../EXECUTION-PLAN.md) 为准。本文件不另建 manifest schema。

## 1. Visual direction

一扇通向微缩神龛的窗。偏暖白字、深色背景、大面积留白；人物与物件呈现可信的摄影或雕塑质感。三位使用同一画幅、相近主体占比和视点，区别来自轮廓、场景与光线。避免科幻仪表盘、游戏卡牌边框、密集符号与大量发光粒子。

| 角色 | 主体与情绪 | 背景／前景的自然分层 | 英文语言规则 |
| --- | --- | --- | --- |
| Oracle | Matrix Oracle 的温暖日常先知感：从容的年长女性、围裙、坐姿、小桌和一碟饼干；按用户指定电影形象参考，允许风格化，并以批准母图保持形象一致 | 暗而温暖的室内背景；人物、椅子作为中层；较低的小桌或桌沿作前层。桌上的道具和桌子同层，避免漂浮 | A complete thought, with room for yours. |
| Stone | Monolith 参考的黑色竖碑，沉默、古老、严肃；边缘与面必须从背景中可辨 | 简洁阴影空间为背景；石碑为中层；低矮地面／台阶作前层，不添加人脸或符文 | Three nouns. The connection is yours. |
| Jester | 不对称戏剧面具优先，略歪的笑和眉眼，骨白／暗红／炭黑，荒诞而不可预测 | 暗舞台为背景；完整面具为中层；底部少量布幕或台沿为前层，不遮主表情 | A strange turn. An unexpected connection. |

三位名称和语言规则显示在固定文字层，不写进图片。主舞台约占可用高度 40–45%；下方留独立回应区和输入区。键盘弹出时收缩舞台，保证编辑和提交可见；大字号时允许内容滚动，不压缩文字。正文使用系统字体，回应可用系统 serif；初始正文约 17 pt、回应 26–32 pt，支持 Dynamic Type。控件热区至少 44×44 pt，常用间距 8/12/16/24 pt。

颜色语义候选：canvas `#101311`、surface `#1B201D`、primaryText `#ECE6D9`、secondaryText `#B9B6AA`、oracleAccent `#C49B68`、stoneAccent `#A9BCC7`、jesterAccent `#AE5D60`。执行时验证最终对比度，这些不是已测合格值。一个状态只有一个主操作；`What weighs on your mind?` 是持久输入标签，语音录制为 `Speak your question`／`Stop listening`，编辑确认后才 `Offer your question`。

## 2. 母图与一致图层制作

本轮已经阅读 imagegen skill，仅用于制定以下未来步骤；不在现在生成。未来默认使用内建 image_gen，一次一张素材或一次明确编辑；不要求 API key，不自行切换 CLI，不安装抠图软件。Imagegen 输出是二维位图，即使图像看起来像雕塑，也不是可旋转的三维模型。

1. **先做每角色母图**：同一竖画幅，优先约 1536×2048 px 的交付目标（工具实际输出尺寸需读取确认，不假定提示词保证精确像素）。主体完整、镜头固定、构图保守；四周有足够延展空间。先完成 Stone 验证简单轮廓分层，再依统一构图与色彩生成 Oracle 和 Jester；参考图只约束共同质感，不复制参考角色。
2. **母图选定即冻结构图**：记录版本、画布宽高、主体框和接地线。保存 `master-v1.png`，不覆盖已有版本。母图即单图 fallback，不等待分层才能交付 iOS。
3. **从母图编辑提取角色**：传同一母图，要求只保留指定角色及与其固定相连的部件，背景真实透明，保留原来的画布、像素位置、比例、轮廓、姿态、光线和投影归属。不要把角色重新居中、放大或另画姿势。Oracle 人物与椅子同层；Stone 只碑体；Jester 完整面具。
4. **从同一母图编辑补全背景**：移除中层与前景，并补全被遮挡的墙面／地面／舞台；包括主体背后未曾可见的位置。背景应为不透明完整图，不保留人物残影或桌子旧投影。背景不是原图挖空，倾斜时不能露出洞。
5. **从同一母图提取前景**：只保留小桌／台沿／低台阶等选定元素，真实透明背景，同一画布同一位置；如果前景藏住了角色下半部，中层要补齐将因相对移动而显露的边缘。补不齐就减小差动幅度或取消该前景，不反复扩画。
6. **验收零位叠合和极限偏移**：生成编辑不能保证像素级对齐。必须肉眼叠合检查，必要时只做一项修正编辑；不把生成成功等同于资产可用。两轮仍无法保持几何一致就冻结单图 fallback，不浪费下午。

执行时要先用 view_image 查看本地编辑目标，再调用 image_gen 引用该路径；每次明确目标图和参考图。生成结果通常先保存到工具返回的默认位置；取选中的实际输出复制到工程工作区，再写 manifest，不能只引用默认生成目录。透明图必须检查真实 alpha 通道而非棋盘格画在图上；保留 alpha，不以纯黑背景假装透明。后续任何图片编辑仍使用 image_gen，除非用户另外授权工具。

### 每角色 20–40 分钟 fallback

| 角色 | 优先投入 | 超时或质量失败时 |
| --- | --- | --- |
| Oracle | 母图的人物姿态、温暖感和干净轮廓优先；不单独动画头、手或嘴 | 用选定母图，只做轻位移；不强行抠细碎发丝、手指和桌腿。20–40 分钟仍有明显重绘错位就停止分层 |
| Stone | 简单碑体最容易提取，优先作为首个分层链路验收样本 | 降为背景 + 石碑两层；仍露边时回单图。不能另画不同角度的碑体冒充同一图层 |
| Jester | 一张完整、边缘清楚的面具；不要细绳、蕾丝、烟雾边缘 | 去掉前景只做背景 + 面具；保留面具不对称性，最多一次角色编辑修正；最终保留母图 |

计时不保证生成服务一定在该时间内返回；前 60–90 分钟内未形成可用背景与主体两层，就把已验收母图交付集成，剩余可用时间仅修最明显问题。背景与主体是分层最低验收，前景可选；单图降级必须在 sourceStatus 中明确。

## 3. 资源、对齐与预算契约

Design Agent 独占 `assets/<characterId>/**` 和 manifest；iOS Agent 独占合成器与运动服务。共享契约由 root 维护；iOS 工程配置和资源打包由 C 独占，root 协调验收。素材 Agent 不改 Swift、相机或项目配置。

| 计划路径 | 内容 |
| --- | --- |
| `assets/<characterId>/master-v1.png` | 完整母图，保留作 fallback 与核对来源 |
| 同目录 `background-v1.png` | 完整不透明背景，含被遮挡区域补全 |
| 同目录 `subject-v1.png` | 与母图同画布的透明角色 |
| 同目录 `foreground-v1.png` | 与母图同画布的透明前景；没有可用前景则 manifest 不引用它 |
| `assets/<characterId>/manifest.json` | 严格采用共享 camelCase 字段：schemaVersion、characterId、canvas、layers、motion、sourceStatus；不另建 mode 或额外 schema |
| `assets/<characterId>/README.md` | 最终提示词、参考母图、编辑顺序、版本、alpha／色域／主体框／anchor、选择理由、零位及极限检查、未通过项；检查信息留在此文件，不自行扩展 manifest |

manifest 示例（契约字段，示例文件须真实存在；使用版本文件名时相应改 file）：

```json
{
  "schemaVersion": 1,
  "characterId": "stone",
  "canvas": {"width": 1536, "height": 2048},
  "layers": [
    {"id": "background", "file": "background-v1.png", "depth": 0.15},
    {"id": "subject", "file": "subject-v1.png", "depth": 0.55},
    {"id": "foreground", "file": "foreground-v1.png", "depth": 1.0}
  ],
  "motion": {"maxTiltDegrees": 10, "maxOffsetPoints": 12, "overscanScale": 1.12},
  "sourceStatus": "layered"
}
```

没有前景则删掉 foreground 项；两层仍标 layered。单图使用 sourceStatus=flat_fallback，layers 只引用现有的完整母图，如 `{ "id": "background", "file": "master-v1.png", "depth": 0.15 }`。图片缺失时 C 可临时用 SwiftUI 色彩／渐变背景保证布局可调试；这不是最终角色素材，不能标 layered 已通过，也不把不存在的图片写进 manifest。如采用程序背景加角色剪影作为额外降级，由 Lead／C 明确资源表达和未完成项，不偷偷扩充 manifest 的层类型。

对齐契约：每角色所有层画布宽高完全相同，方向一致，sRGB；原点左上，归一化 x/y 从 0 到 1，统一 anchor `(0.5,0.5)`。不对透明层逐张 trim 透明边框，不让不同层独立 aspectFill；全部通过同一个画布到舞台的缩放／裁切变换。按 background → subject → foreground 绘制。坐标与文字层完全分开。

建议画面安全区：主体重要轮廓在画布 x≈0.15–0.85、y≈0.12–0.85 内；四周保留约 10–12% 可裁切／延展空间。显示容器内统一 overscan 起点约 1.12 倍，再依据最极限偏移验算，不能靠固定倍数保证所有长宽比。最外侧每层留白覆盖量应大于该层最大位移、裁切变化与边缘修正的和。

遮挡契约：相邻层差动位移如果最大 8 px，则被遮挡区域至少补出该范围并额外留约 8–16 px 缓冲（素材像素尺度，最终以舞台缩放后对应换算）。黑背景和窄轮廓不能作为不修边的理由。投影跟随投影所属物体或烘焙在其紧邻层，避免石碑动而投影停在旧位置；无法分离的接地场景用更小差动。

预算目标：每层约 1536×2048、透明层 PNG；单张 RGBA 解码缓冲约 12 MiB；单角色两层约 24 MiB、三层约 36 MiB，另保留母图则三层合计约 48 MiB，尚未包含系统／GPU 副本。一次只常驻当前角色完整图层，下一角色可预解码但不要同时展开三位全部图片。最终九层压缩包目标 ≤20 MB，超过则优化输出尺寸／内容复杂度，不损伤透明边缘。用户 iPhone 上目标平滑 60 fps；运动样本约 30 Hz，更新不使整屏文本重排。以上是预算，不是测量结论。

素材验收：零位叠合不出现双影；alpha 在深浅底都无白边／黑边；四个方向和对角线极限倾斜无露底、裁头、穿帮；background 无主体残影；前景不遮住核心表情；不同手机舞台比例下共同裁切一致；单图 fallback 能独立显示；最终文件实际在 workspace，manifest 路径都可读。README 中没有测过的检查写 `unchecked`，不标 `passed`；不新增同名 manifest 字段。

## 4. 状态与固定文字

状态采用共享契约的 `idle → listening → editing → thinking → revealing → result`，任何阶段可进入可恢复 error；键盘跳过 listening。图片只响应状态。P0 接口一次返回完整 JSON，不流式传输；逐行淡入只是返回后的展示，不能称为模型实时输出。UI 过渡约 150–250 ms，立即有反馈；不能让揭晓动画额外延长模型返回等待，不用打字机逐字延迟完整答案。

| 状态 | 图片表现 | 固定文字／控件 |
| --- | --- | --- |
| idle | 三位都以设备视差为主；不额外加入不断漂浮的人物循环 | 名称、规则、输入；初始无全屏开场动画 |
| listening | 可有一次极轻亮度／缩放反馈；Oracle 不做假口型，Stone 不晃动 | 仅录音已开始才显示 `Listening…` 和 `Stop listening`；停止后可编辑转写 |
| editing | 舞台保持当前静态姿态，避免分散编辑注意力 | 转写可改；明确提交后才请求模型 |
| thinking | 保持场景，弱小进度标记；Jester 可轻偏斜一次后保持 | `Listening for an echo…`，阻止重复提交；不显示虚假百分比 |
| revealing | 完整响应到达后 Oracle 一段展示、Stone 三行、Jester 按 segments 分行；停止可选额外动作 | 可用 ≤150 ms 淡入；完成依据 response.status；不让片段逐行展示增加额外等待 |
| result | 保持低幅视差，不另做庆祝动画 | 完整回应可读；下一次提问是明确操作 |
| error | 停止额外动作，场景保持，不闪红屏 | 显示具体错误和 `Try again`；返回 status=incomplete 且含片段则 `The echo was interrupted.`，不伪装完整神谕 |

语音不可用：`Speech recognition is unavailable. You can type your question.`；连接失败：`We couldn’t receive an answer. Try again.`。输入、按钮、状态和回应始终在固定 SwiftUI 层，不随着手机移动。新状态覆盖旧动画，从当前值平滑转到目标；离开页面或后台停止传感器和循环。减少动态效果时关闭视差与淡入，直接更新状态和文本。

## 5. Core Motion 视差契约

iOS Agent 实现合成器和 Core Motion；Design Agent 只交付视觉幅度建议。进入场景记录基准姿态，后续使用相对姿态，映射当前界面方向；忽略长期累计 yaw，只取可控的 pitch/roll 小角度。相对姿态可参考 Apple [CMAttitude.multiply(byInverseOf:)](https://developer.apple.com/documentation/coremotion/cmattitude/multiply(byinverseof:))；轴方向和手感必须在用户 iPhone 上验证。

统一初始参数严格采用共享契约：`maxTiltDegrees=10`、`maxOffsetPoints=12`、`overscanScale=1.12`；背景／主体／可选前景 depth 分别为 `0.15 / 0.55 / 1.0`。设备相对倾斜达到 ±10° 时归一化并夹紧到 [-1,1]；每层偏移 = 公共偏移 × depth，因此单轴初始最大位移分别是 1.8 / 6.6 / 12 pt。四个方向和对角线都验证，不另设一套纵向幅度。P0 只平移，不强制旋转、网格扭曲或深度图。

约 0.4° 死区和约 0.12–0.18 s、基于 dt 的低通可作为 iOS 实现的手感建议；传感器细节由 C 统一。所有偏移服从真实素材覆盖范围。专业判断：12 pt 在短舞台或接地物体上可能显得过强，1.12 外扩也不保证所有长宽比都能遮边；若极限验收失败，由 A 报告安全范围给 Lead／C，再统一更新该角色 manifest 的 motion，不能在本文件私设另一套默认值。优先降低整体 maxOffsetPoints，避免破坏 depth 比例；必要时增大 overscan 并重新检查裁头。

单图 fallback 仍使用同一 motion 契约，以唯一完整母图层的低 depth（例如 0.15）获得轻位移，不另造 mode 或旋转参数。sourceStatus 必须是 flat_fallback。切换角色／前后台恢复重新校准，避免跳变；初版锁定竖屏可简化映射。

读取系统 Reduce Motion，另提供关闭动态效果；关闭或运动不可用时保持静态图，不影响完整问答。无需额外手势替代才能使用产品，横向手势优先留给角色切换。VoiceOver 只读角色简述，不将三张图片当成三个内容项。

## 6. 可并行工作、依赖与四小时取舍

| 负责人 | 独占文件／范围 | 可立即并行与依赖 |
| --- | --- | --- |
| Design／素材 Agent | `assets/<characterId>/**`，其中含 manifest 和提示词记录 | 母图 → 角色提取／补全背景／前景提取 → 对齐检查；每角色母图一完成就交付，不等三层齐备 |
| iOS Agent | ios/、Xcode 工程配置与资源打包、合成器、Core Motion、SwiftUI、语音；路径按共享契约 | 先用普通图片验证三层容器和固定 UI；消费 manifest，不改源图；不依赖分层成功才能集成 |
| 内容／服务 Agent | 三位候选词库与真实请求事件 | 与图像独立：完整 JSON 中的 Oracle 一段、Stone 三名词、Jester 短语以及 complete／incomplete／error |
| root 集成负责人 | 共享契约、跨 Agent 协调、最终验收协调；工程配置与资源打包由 C 独占 | 冻结画布／路径／sourceStatus 字段，协调素材版本和演示冻结点 |

前 10 分钟确定图层契约，前 30 分钟应交出首张可显示母图并验证 iPhone 容器。0:30–1:30 集中完成三位母图和首位三层样本；1:30–2:30 补剩余层、接入真实状态；2:30 后不再重构视觉方向；最后一小时优先修露底、键盘、错误与真机流畅性。按实际生成速度调整，任何素材未到位时合成器可使用明确占位图，不能当最终成果汇报。

必须保留：三个角色的可辨视觉和英文语言规则、真实问答与失败、语音到编辑确认流程及文字退路、固定可读文字、限幅／平滑／动态关闭、每角色独立可用的母图。P0 两层分层目标遇阻允许明确单图降级；所有降级都记录在 manifest 和演示说明。

依次可砍：额外人物动作、复杂前景、烟雾粒子、动态光、各状态专属图片、声音／触觉、Echoes／追问／分享。三层去掉可选前景后两层仍属 layered；退回单图才标 flat_fallback；不能把二维旋转称作已交付真正三维模型或系统原生空间照片。

## 7. 未来素材提示词（现在不执行）

共享母图框架：

> Use case: stylized-concept. Asset type: a portrait scene image for a native iPhone parallax shrine, not a UI mockup. Subject: [character brief below]. Quiet, mysterious, poetic, personal; tactile sculptural or photographic detail, restrained dark scene. Complete subject within the center safe area, generous extendable space around all edges, simple backdrop, one unobtrusive low foreground element. Keep the viewpoint and visual scale consistent with the supplied style reference. No words, labels, logos, watermarks, interface elements, split panels, checkerboard, particle clouds, or fine transparent hair crossing the frame. The result is one coherent complete scene.

角色补充：

- **Oracle**：A calm older woman in a simple apron, seated beside a small table with a plate of cookies, everyday warmth and quiet knowing, warm side light, relaxed hands, welcoming expression; use the user-specified Matrix Oracle character reference, allowing a stylized treatment while maintaining the approved master image identity. 桌子低且不遮脸，人物与椅子边缘明确。
- **Stone**：A severe upright black monolith, rectangular and undecorated, readable edges and planes in restrained cool rim light, silent dark space, a low stone ledge in the foreground. 不使用漂浮碎石、符文或宇宙星云。
- **Jester**：A complete asymmetrical theatrical mask, subtly mismatched brows and a crooked smile, bone ivory, muted dark red and charcoal, dark stage, a low fold of fabric near the bottom. 保留完整轮廓，不做 Joker 人物妆容或细碎挂饰。

角色提取编辑：

> Use case: background-extraction. Input image 1 is the edit target, the approved master. Keep only [exact subject and attached elements] and remove every other object to genuine transparency. Preserve the exact canvas dimensions, original pixel placement, scale, pose, silhouette, facial identity, colors and lighting. Do not recenter, crop, redraw or enlarge the subject. Preserve real alpha; do not paint a checkerboard or a solid background. Restore only the small hidden edge needed for [specified parallax reveal], without changing visible features.

背景补全编辑：

> Use case: precise-object-edit. Input image 1 is the approved master. Remove [subject and foreground elements] and their residual shadows. Fill the hidden regions with a continuous plausible continuation of this same backdrop and ground. Keep all unaffected areas, canvas dimensions, perspective, light and colors unchanged. Produce a complete opaque clean background with no cutout holes, no subject ghosting, no new objects and no text.

前景提取编辑：

> Use case: background-extraction. From the same approved master, keep only [precise low foreground element and attached props] on genuine transparency, at the exact original pixel location and size on the full original canvas. Preserve its silhouette, texture, lighting and attached shadow; no other objects, no recentering, no crop, no checkerboard.

Imagegen 编辑保持一致性是目标而非工具保证。若输出尺寸或位置变化，重新核对、做一次定向修正或降级，不把提示词约束当作已验收事实。

## 8. 可直接分派的执行提示

**素材 Agent**

> 阅读 docs/workstreams/design-assets.md 和 imagegen skill。只拥有 assets/<characterId>/**。现在按计划生成 Oracle、Stone、Jester 三位母图，选定后通过同图编辑派生背景、透明角色、透明前景；至少背景与主体两层、前景可选，每角色最多两轮修正，20–40 分钟背景与主体仍无法合格分层就保留单图 fallback。先交母图再补图层，不等全套才通知集成。工具输出选中后复制进工作区，逐项记录实际尺寸、alpha、相同画布、极限安全位移与验收状态到 README；manifest 只用共享 schema 的 sourceStatus 等字段。不要改 Swift、工程文件或合成器，不装软件，不把二维结果称为真正 3D。交付提示词、manifest 和已检查／未检查列表。

**iOS Agent**

> 消费 docs/workstreams/design-assets.md 的分层契约和 assets/<characterId>/manifest.json。你拥有原生合成器、Core Motion 和固定文本 UI；不修改源图片。先在用户 iPhone 上验证同画布统一缩放裁切、按层序绘制和轻微差动位移，再接实际资产。使用相对姿态、平滑、限幅和重新校准；文字和输入保持屏幕固定；Reduce Motion／运动不可用保持静态。按 sourceStatus 支持 layered（至少两层，前景可选）与 flat_fallback（单图），不依赖未经验证的系统空间照片 API。检查透明边、所有倾斜极限、键盘、大字号、前后台及失败恢复，报告设备、实测表现和降级项。

## 9. 本工作流采用的 skills

- [design-foundations](/Users/bytedance/.codex/skills/design-foundations/SKILL.md)：用于单一主操作、有限配色、层级、固定文本、持久标签与具体错误恢复；将 Web 原则转为原生设计。
- [animations](/Users/bytedance/.codex/skills/animations/SKILL.md)：用于短且可中断的状态反馈、低幅 transform、减少动态效果，以及避免动画拖延真实回答。
- [imagegen](/Users/bytedance/.codex/skills/.system/imagegen/SKILL.md)：用于未来内建生成／编辑、母图与编辑目标角色区分、保留构图、真实透明背景、检查后再复制到项目及非破坏版本管理。本轮只读取和规划，没有生成素材。

遵守只规划、不安装软件和独占文件边界，本轮没有执行技能环境同步／更新步骤。性能、画布尺寸与动作幅度是待验证的工作契约，不能作为已实现报告。
