# JEV 图片与开门视频制作说明

2026-09-27。用于 iPhone Air 原生应用。本文是可复制的生成提示词与交付规范，本轮不生成最终图片或视频。提示词按 imagegen 的场景、主体、构图、光线、约束格式整理。

## 交付清单与顺序

先确定 Oracle 房间及打开门帘的尾帧，再从该尾帧编辑出闭合首帧，最后用同一房间制作 Oracle 对话母图。两个独立文生图不能保证视频首尾空间一致。

| 优先级 | 文件名 | 用途 |
| --- | --- | --- |
| 1 | `entrance-open.png` | 开门视频尾帧：门帘分开，Oracle 房间可见 |
| 2 | `entrance-closed.png` | 从尾帧编辑出的首帧，同时作为首页静态背景 |
| 3 | `entrance.mp4` | 用户以两帧生成的开门视频 |
| 4 | `oracle-master.png` | Oracle 对话完整场景，尽量直接复用尾帧构图 |
| 5 | `stone-master.png` | Stone 对话完整场景 |
| 6 | `jester-master.png` | Jester 对话完整场景 |
| 7 | `<id>-background.png`、`<id>-subject.png` | 三位角色的补全背景和透明主体，用于真正的层间视差 |
| 可选 | `<id>-foreground.png` | 与背景主体同画布的透明前景，仅在自然需要时制作 |

`<id>` 为 `oracle`、`stone`、`jester`。将获选文件放入 `ios/JEV/Resources/Media/` 后重新运行 `xcodegen generate` 并构建。不要用棋盘格图片冒充透明通道。没有图层时程序使用完整母图；没有母图时明确显示素材待接入的开发预览。

## 所有图片的共同规范

- 全屏竖图，建议目标比例约 9:19.5，建议约 1440×3120，最终按工具实际尺寸记录。所有同场景图层和首尾帧必须完全同尺寸。
- 相机水平，固定视点；真实摄影与电影场景质感，细节自然克制。暖灰黑、烟草棕、骨白、极少暗红，避免纯黑吞没细节。
- 主体识别中心在画布中上部。顶部约 12% 给系统状态与角色导航留呼吸；下部约 32% 保持低对比与简洁，承载回应和输入。
- 四周保留可裁切余量，关键面部不靠边。中心清楚，外围轻微光学柔化；不要在源素材中烘焙强烈拉伸、重度虚化、文字光晕，运行时统一处理。
- 无文字、字母、logo、水印、界面、手机外框、拼贴、卡牌边框。无星云、符文、粒子雨、过饱和霓虹。
- 源图保存 sRGB。所有透明层完整保留原画布与原位置，不紧裁主体。不同画幅设备都统一裁切整组图层。

以下每段英文是可独立复制的提示词；编辑任务需附上指定的已批准参考图片。

## A. 打开门帘：尾帧 / Oracle 房间基准

```text
Use case: photorealistic-natural.
Asset type: final frame of a portrait entrance video and full-screen native iPhone app scene, approximately 9:19.5 portrait.
Scene: seen through a modest old doorway into a quiet, intimate kitchen sitting room. A beaded doorway curtain has parted to both sides, leaving a clear central opening. Small amber and dark wooden beads hang on thin, physically plausible strings, gathered along the left and right edges. The beads are ordinary tactile objects, not magical crystals.
Subject: in the room beyond, a calm older woman in a simple apron sits comfortably beside a small table with a plate of cookies. She has the warm, unhurried, quietly knowing presence of the Oracle in The Matrix. Natural face, relaxed hands, lived-in clothing. Keep furniture and props minimal.
Composition: locked eye-level camera outside the doorway, straight verticals, a coherent room with real depth. The woman's face sits in the upper-middle region and remains clearly readable at phone size. Doorframe and parted beads form peripheral foreground depth, not a graphic frame. The central lower third is dark, quiet floor and shadow, reserved for live UI text.
Lighting: restrained warm side light inside the room, dim cooler doorway foreground, soft falloff, rich shadow detail, realistic skin and cloth, subtle photographic grain. Center sharp, periphery only softly defocused.
Constraints: one continuous image, no text or UI, no collage, no theatrical fog, no neon, no runes, no fantastical accessories, no excessive props. Keep generous crop-safe detail around the edges. This image is a locked reference for all subsequent entrance and Oracle scene assets.
```

## B. 闭合门帘：首帧 / 首页背景

将 A 的获选图片作为编辑目标。只改门帘的状态。

```text
Use case: precise-object-edit.
Input image 1: approved open-curtain room image, the edit target.
Asset type: first frame of the same entrance video and static full-screen welcome background.
Primary request: close the existing beaded curtain across the doorway. Let the same amber and dark wooden bead strands hang vertically in a natural dense curtain. Through small gaps, allow only a faint impression of the warm room and seated woman beyond.
Preserve exactly: image dimensions, camera position, lens, perspective, doorway geometry, room, furniture, woman's identity and pose, lighting, exposure, palette and crop. Do not move the camera or redesign anything behind the curtain.
The closed beads occupy the doorway, with a visually quiet dark lower third for live introductory copy. Keep the bead scale and strand material identical to the open-curtain source. Center has tactile detail; outer edges gently soften.
No words, logos, interface, hands, new characters or new props. Output a single full-resolution image with no border.
```

## C. 提供给视频模型的提示词

输入 B 为首帧，A 为尾帧。建议 3–4 秒、竖屏、30 fps、无音轨、H.264 MP4。播放器只播放一次。最终选择以实测转场自然为准。

```text
Create a single continuous 3–4 second shot between the supplied first and last frames. The camera is completely locked: no zoom, dolly, pan, roll, reframing or focus hunting.
Starting with the closed beaded curtain, the strands gently separate from the center and gather to both sides, revealing the quiet room and seated Oracle behind them. Beads stay threaded and preserve their size and material. Each strand moves with a restrained, physically plausible sway and gradually settles.
The room, woman, chair, table and plate remain stationary and geometrically consistent. Preserve facial identity, body proportions, illumination and exposure. No lip movement, gestures, particles, hands opening the curtain, new objects, light flashes or morphing.
Begin exactly on the supplied closed-curtain frame. End exactly on the supplied open-curtain frame, holding the final composition still for the last 0.3–0.5 seconds. No cuts, looping or reverse motion. No audio, captions or watermark.
```

UI 配合：点击 `Enter` 后简介与按钮淡出，视频从相同首帧播放；结束时停在尾帧，再显现对话控件。无视频时使用静态过渡并标明开发状态，不伪称开门动画已交付。减少动态效果时跳过视频直接进入。

## D. Oracle 对话母图

优先直接复制批准的 A 为 `oracle-master.png`，避免转场终点跳变。如果门帘在对话里过于显眼，再从 A 做这一项编辑，并重新检查视频末帧衔接。

```text
Use case: precise-object-edit.
Input image 1: the approved open-curtain Oracle room, edit target.
Asset type: full-screen portrait conversation background.
Keep the exact room, camera, woman's identity and pose, lighting and perspective. Preserve the center of the composition. Only reduce visual distraction in the lower third and outermost foreground: simplify peripheral shadows and keep gathered bead strands at the extreme sides. Do not crop, zoom or move the woman.
The woman remains warm, grounded and quietly knowing. Retain real skin, soft fabric, chair, modest table and cookies. Central details remain sharp. The lower third stays dark and calm for live text.
No text, no UI, no new props, no extra glow, no severe blur or distortion baked into the image.
```

## E. Stone 对话母图

附上 Oracle 获选图仅作质感和暗部参考，不复制房间。

```text
Use case: photorealistic-natural.
Asset type: full-screen native iPhone conversation background, approximately 9:19.5 portrait.
Subject: one severe upright black monolith in an austere, silent stone chamber. Rectangular, undecorated, grounded, physically massive. No face or symbols. A slight angle reveals two planes without exaggerating perspective.
Composition: fixed eye-level camera, monument centered in the upper-middle region, complete readable silhouette. Quiet architecture recedes behind it. A low stone floor extends across the bottom third with restrained shadows and no small objects. The environment fills the entire image, with generous peripheral crop allowance.
Materials: dense dark mineral surface, extremely subtle grain, believable edges and contact shadow. Restrained cool side light separates the monolith from charcoal surroundings. Match the supplied Oracle reference's photographic realism, shadow detail and quiet mood, while using a much simpler scene.
Center clear, periphery softly defocused. Avoid total blackness, shiny science-fiction metal, floating rocks, galaxy backgrounds, fog clouds, engraved runes, neon, text, borders or interface elements.
```

## F. Jester 对话母图

附上 Oracle 获选图作质感参考。

```text
Use case: photorealistic-natural.
Asset type: full-screen native iPhone conversation background, approximately 9:19.5 portrait.
Subject: a single complete asymmetric theatrical mask, held on a discreet dark stand in an intimate shadowed theatrical alcove. One eyebrow subtly raised, a crooked knowing smile. Unsettling wit rather than horror. Bone-ivory painted surface, worn muted oxblood details, charcoal shadows. No recognizable comic-book villain makeup.
Composition: mask occupies the upper-middle region, readable at phone scale, tilted only slightly. Its entire silhouette is intact. The stand and a small amount of heavy dark fabric establish real depth. The bottom third is quiet darkness and soft fabric shadow, reserved for live text. Avoid busy costume ornaments.
Materials and light: tactile ceramic or painted plaster with fine restrained wear, a soft directional light, controlled highlights, natural dark detail. Match the supplied Oracle image's realism and photographic finish without copying its room. Center clear; peripheral scene gently falls out of focus.
No floating magic, horror blood, dangling bells, fine lace, particle clouds, neon, words, logos, graphic frame or UI.
```

## G. 从每张母图导出视差图层

以下均为编辑任务，同一角色只引用同一批准母图。每次只输出一个文件，不让模型重新生成一个相似场景。

### 背景 `<id>-background.png`

```text
Use case: precise-object-edit.
Input image 1: approved character master, edit target.
Remove only [SUBJECT AND ATTACHED OBJECTS] and [OPTIONAL FOREGROUND]. Reconstruct the wall, room and floor that were hidden behind them, matching existing perspective, materials and illumination. Remove their residual silhouettes and object-specific shadows.
Preserve canvas size, camera, pixel alignment, crop and every unaffected area. Output a complete opaque clean background plate, with no holes and no duplicate subject. No text, new props or altered lighting.
```

### 主体 `<id>-subject.png`

```text
Use case: background-extraction.
Input image 1: approved character master, edit target.
Keep only [SUBJECT AND ATTACHED OBJECTS] on a genuinely transparent background. Preserve the original full canvas, exact original position, scale, silhouette, face, pose, lighting and material. Never center, enlarge, tightly crop or redesign the extracted subject. Include natural attached contact shadow only where appropriate, avoiding a rectangular opaque backdrop.
Clean alpha edges with no matte fringe, checkerboard drawing or remaining background. Complete any tiny occluded edges needed for a very small parallax offset, without changing the visible silhouette.
```

替换清单：Oracle 为女人、椅子、小桌与饼干整组，减少桌腿与手部错层；Stone 为石碑及紧邻接地阴影；Jester 为完整面具与固定支架。Oracle 前景可提取门帘，Stone/Jester 第一版无需额外前景。

### 可选前景 `<id>-foreground.png`

```text
Use case: background-extraction.
Input image 1: approved master, edit target.
Keep only [EXACT FOREGROUND ELEMENTS] on genuine transparency. Preserve the full original canvas and exact placement. Keep original color, focus and lighting. Remove all background and subject pixels. Do not redraw, crop or reposition the elements. No checkerboard or solid-color substitute for alpha.
```

## 验收

1. 首尾帧叠合时，除门帘外房间、人物、镜头不漂移；尾帧与 Oracle 母图能自然接续。
2. 视频串珠始终连在绳上，无熔化、穿帮、人物变脸；结束帧稳定，无黑帧。
3. 字幕区、输入区无高亮道具争抢注意力；重要脸部在不同手机裁切中保留。
4. 图层同尺寸且有真实 alpha；零位叠合无双影，轻微偏移不露洞、不残留主体。
5. 模糊与拉伸在 App 内调节；静态关闭效果时素材自身也成立。
