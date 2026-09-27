# JEV 素材交付 · V2

Jester 最新修订：改为佩戴面具的真人，使用 [master-v3.png](jester/master-v3.png) 及匹配深度。旧版独立面具保留在角色目录；画廊的新版入口显示真人版。[提示词与验收](jester/README.md)。

最新补充：The Fool 已加入，当前使用 [master-v3.png](fool/master-v3.png)，保留夸张表情并修正双腿。运行时图片和匹配的连续深度文件均已接入。提示词见 [角色记录](fool/README.md)，数值验证见 [validation.json](fool/validation.json)。画廊支持初稿与当前版本对比。以下为此前三角色阶段的历史说明。

2026-09-27。使用内建 image_gen 按用户反馈修订五张运行时图片，已同步至 ../ios/JEV/Resources/Media/。查看 gallery.html，可切换 V1 / V2 对比。

- Oracle：偏绿环境与暖肤色，去掉衣服、围裙、桌布碎花，强化前后景深。
- Stone：冷灰蓝绿；大幅简化地面和碑体纹理，柔化近处地面及背景。
- Jester：骨白与暗红，冷色暗部和暗红布景，降低细碎磨损及织物微纹理。
- 闭帘：更远的门外视点，珠帘为焦点，Oracle 和室内明显失焦。
- 开帘尾帧：走近后的 Oracle 场景，同时作为对话母图。

当前文件在 versions/v2/；旧版保存在 versions/v1/。角色目录保留 master-v1.png，新增 master-v2.png，manifest 指向 V2 并继续标注 flat_fallback。旧版图层在 review/，不可与 V2 混用。

## 规格与验收

五张图片均已标记 sRGB，色彩标记操作前后像素未改变。Stone 实际 853×1843；其他四张 853×1844。入口首尾尺寸相同，尾帧与 Oracle 母图像素完全相同。完整记录见 asset-audit.json。

已目视检查色调、低频材质、景深和闭帘遮蔽。真机裁切、文字对比度和实际视频运动尚未验收。

视频尚未生成。entrance-video-inputs/ 已更新两张输入图和 VIDEO-PROMPT.txt：珠帘打开、相机缓慢前进、焦点从珠帘转向 Oracle。不再要求锁定相机或首尾背景逐像素一致。

当前规范：../docs/ASSET-PROMPTS.md。实际提示词：../docs/ASSET-GENERATION-V2.md。V1 记录保留在 ../docs/ASSET-GENERATION-LOG.md。

上一轮构建因缺少 Metal Toolchain 失败；本轮仅更新素材，没有重复该构建或声称运行验收通过。

## iOS 空间场景接入更新

随后已生成 V2 补全背景、预计算原图前景蒙版，并接入原生双层视差与模糊入场。旧 Metal Toolchain 阻塞已解决，当前空间实现已成功编译。资源约定、实际提示词和验证记录见 ../docs/SPATIAL-V2.md 与 ../ios/Verification/。上述旧 manifest 的 flat_fallback 描述仍保留为母图交付记录；运行时空间资源清单为 spatial-v2.json。

## 当前运行时：V3 连续深度

V2 双层移动会破坏人物/椅子、碑底/地面和面具/支架接触关系，现已停用。最新 App 直接使用完整 V2 母图与 `depth-v3/` 的 Core ML 深度数据，不再加载独立背景或 alpha 蒙版。详见 ../docs/SPATIAL-V3.md。

## Current spatial tuning (V4)

`depth-v4/` contains stronger-motion continuous fields, with the original RGB unchanged. The supplied root `entrance.mov` is bundled unchanged. See `docs/SPATIAL-V4.md` and `ios/Verification/depth-v4/`. V3 depth remains archived.
