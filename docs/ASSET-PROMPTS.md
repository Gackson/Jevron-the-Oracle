# JEV 图片与开门视频制作说明 · V2

## Jester 真人形象（最新修订）

Jester 已改为佩戴骨白／暗红面具的真实成年演员，保留狡黠的歪头、前倾托腮姿态。当前母图为 `assets/jester/master-v3.png`（实际 829×1897，sRGB），运行时同步为 `jester-master.png` 并配套重算连续深度。旧版独立陈列面具不再用于当前场景。实际提示词和验证见 [Jester 素材记录](../assets/jester/README.md)。

## 新增 The Fool（最新补充）

第四位角色已加入：灰紫外套、夸张歪纸冠、睁眼大笑、以白花作话筒的成年漫游者。根据反馈修正为两腿不交叉、两脚落地。当前母图为 `assets/fool/master-v3.png`，运行时使用 `fool-master.png`，配套 `fool-scene.depth`。完整提示词和版本记录见 [The Fool 素材记录](../assets/fool/README.md)。以下早期三角色、分层和视频交付状态为此前阶段记录；当前空间实现以 SPATIAL-V4.md 及 Media/README.txt 为准。

2026-09-27，依据最新视觉反馈修订。本版取代旧版的全暖黄色调、弱景深及“锁定镜头／首尾背景逐像素一致”要求。旧规范与图片归档在 assets/versions/v1/。

## 当前交付

五张图片由内建 image_gen 生成，保存于 assets/versions/v2/ 并接入 ios/JEV/Resources/Media/。提示词记录见 ASSET-GENERATION-V2.md。entrance.mp4 尚未生成。

| 文件 | 用途 |
| --- | --- |
| entrance-closed.png | 门外较远视点；珠帘清晰，Oracle 与室内模糊不可辨 |
| entrance-open.png | 拉开珠帘、走近后的尾帧 |
| oracle-master.png | 直接复用尾帧，避免进入对话时再跳变 |
| stone-master.png | 冷灰蓝绿石室，平静地面与黑色石碑 |
| jester-master.png | 骨白／暗红面具，暗红茄紫布景与冷色暗部 |

## 视觉规范

- 竖图约 9:19.5；以实际输出尺寸为准。同组首尾帧尺寸相同，采用 sRGB 标记。
- 丰富而克制的冷暖层次，避免全画面黄褐滤镜。Oracle 房间偏灰绿、橄榄绿和深绿，肤色自然偏暖，小灯只是局部暖色点缀。
- 强于 V1 的真实光学景深：主体清楚，背景和近处前景明显柔和；复古镜头、温和高光和克制颗粒，避免数字锐化。
- Oracle 的衣服、围裙、桌布为素色；Stone 地面以连续明暗为主，降低裂缝、石粒和矿纹；Jester 减少密集裂纹和布料微纹理。
- 保留安静暗部和裁切余量。无文字、logo、水印、界面、边框、符文、霓虹或粒子。

## 入口镜头

首帧在珠帘外，焦点落在近处珠帘。室内只有模糊的绿色明暗和人影，不能清楚辨认 Oracle 五官。开帘后相机缓慢前进，焦点逐渐转向 Oracle，最后停在更近的对话母图。

首尾构图、透视、人物大小和背景位置可以随相机前进变化；保持人物身份和房间空间逻辑，不要求逐像素一致。

```text
Create a single continuous 4-second cinematic entrance shot using the supplied first and last frames.
First frame: camera outside a closed beaded doorway, focus on nearby beads. The room and seated woman behind are strongly out of focus; her face must not be readable.
0.0–0.5s: hold the quiet closed-curtain view briefly.
0.5–1.7s: bead strands separate gently from the center, gathering to both sides, with restrained physically plausible threaded sway.
1.0–3.5s: the camera smoothly and slowly DOLLIES FORWARD through the opened doorway toward the woman. Real perspective and scale change are intentional; this is not a locked camera or a simple digital zoom. Keep the room's spatial logic coherent. Smoothly rack focus from the near beads to the Oracle's face as we approach; no focus hunting.
3.5–4.0s: settle naturally on the supplied closer Oracle last frame and hold it stable. Near peripheral beads become defocused, the woman becomes readable, the kitchen behind remains softly defocused.
Preserve the same woman's identity, seated hand-to-cheek pose, plain moss dress, plain sage apron and tablecloth, cookies and cup. The woman stays still: no lip movement, gestures or change of expression. Furniture remains stationary in world space; screen position changes from camera motion are expected. No hands pulling the curtain.
Muted olive/celadon green room, forest/cyan-green shadows, naturally warm skin, small amber practical accent. Retro 35mm lens softness and subtle grain, restrained highlights, no overall yellow wash or sharpened floral/stone detail.
Single shot, no cuts, morphing, flashes, particles, captions, watermark, looping or reverse motion. No audio. Output portrait H.264 MP4, 30 fps. Start and end on the provided compositions; use one consistent output framing for both endpoints.
```

首尾帧和同一提示词另存 assets/entrance-video-inputs/。若编码器要求偶数尺寸，整组使用一致的输出画布，不单独裁切首尾帧。

## 分层及验收

三位角色当前使用完整母图，sourceStatus 为 flat_fallback。assets/review/ 中的 V1 图层不适用于 V2，不可混用。未来图层应从 V2 母图提取，保留全画布、位置及真实 alpha，并检查叠合和运动边缘。

图片已目视检查色调、细节和景深。珠帘运动、前进、拉焦及衔接需要在实际 MP4 生成后验收，本轮未交付视频。
