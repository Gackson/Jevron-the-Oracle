# V2 空间场景与模糊入场

2026-09-27。替换了五张 V2 运行时静态图。新增三张补全背景和与原图 SHA256 绑定的前景蒙版数据，应用运行时从原图像素合成透明主体，不重绘脸部、材质或轮廓。

## 为什么旧效果很弱

旧配置在缺少背景与透明主体文件时，退回完整母图。10pt 的公共位移再乘 0.15，最大只有 1.5pt，没有独立层间位移，也没有随姿态的透视角度变化。

## 当前组成

| 角色 | 前景 | 后景 |
| --- | --- | --- |
| Oracle | Vision 从原图识别的女人、衣服和鞋 | 移除人物后补全的房间、空椅子、桌子和珠帘 |
| Stone | 原图石碑 | 移除石碑与投影后补全的墙面、地面 |
| Jester | 原图面具与支架 | 移除主体后补全的布景与绒布 |

每个角色文件：

- `assets/<id>/master-v2.png`：已批准的新版母图。
- `assets/<id>/background-spatial-v2.png`：内建 image_gen 编辑出的完整后景。
- `assets/<id>/foreground-v2.mask`：系统 Vision 计算的前景覆盖率数据，不是重新生成的人物图。
- `ios/JEV/Resources/Media/<id>-background-v2.png` / `<id>-foreground-v2.mask`：App 打包副本。
- `assets/spatial-v2.json`：原图与背景版本记录。

蒙版带 8 字节格式标识、宽高、原图 SHA256、8-bit coverage 数组。原图改变而蒙版未更新时拒绝使用，避免旧人物轮廓套到新素材。生成工具 `ios/Tools/prepare-spatial-masks.swift` 使用 macOS Vision 生成数据；iOS Core Image 只将原图按覆盖率合成透明层。文件缺失时才尝试在设备上执行 Vision，失败则诚实退回完整母图。

模拟器不支持这项 Vision 推理，因此预计算蒙版也使模拟器与真机使用一致的分层，而不是在模拟器静默关闭空间效果。三张图的主体覆盖比例约为 23% / 25% / 19%。

角色旧 `manifest.json` 仍记录母图交付的 flat_fallback 形式；新的运行时合成器使用上述空间资源约定。不要把 V1 的 review 图层混入 V2。待统一资产契约升级时再迁移 manifest schema。

## 运动与光学效果

- 以进入时的姿态为基准，±12° 对应归一化 ±1。
- 60 Hz 更新，以真实 dt 做指数平滑，时间常数 85ms；不会在每个传感器事件上重排文字或解码图片。
- 水平方向：背景最大 −18pt、主体最大 +14pt，总位移差约 32pt。
- 垂直方向：背景最大 −11pt、主体最大 +7pt，总位移差约 18pt。
- 背景额外产生最大 4° 横向 / 3.2° 纵向透视，主体较小，分别 1.6° / 1.2°。
- 两层共用母图画布、相同初始缩放和中心，零位保持对齐。1.16 倍绘制余量用于覆盖偏移与旋转。
- 合成后，中心保留清晰度，外围通过两次各 25 采样的可分离高斯渐进软化及向外拉伸，避免稀疏采样造成多重轮廓；文字和控件不进入图像着色器。
- Reduce Motion 关闭空间运动和光学变化；进入后台或编辑文字时停止传感器。

这是使用公开 SwiftUI/Core Motion/Vision API 实现的双层空间视差，不是系统私有空间照片转换，也没有恢复物体的完整三维背面。参考 [SwiftUI 透视变换](https://developer.apple.com/documentation/swiftui/view/rotation3deffect(_:axis:anchor:anchorz:perspective:)) 和 [Vision 前景分割](https://developer.apple.com/documentation/vision/vngenerateforegroundinstancemaskrequest)。

## 首页过渡

无 `entrance.mp4` 时：简介淡出，闭帘画面用约 240ms 失焦，约 360ms 溶解到实际 Oracle 场景，再用约 380ms 恢复清晰度。总时长约 0.92s，随时可 Skip。不是模拟门帘几何开合，而是暂代视频的光学过渡。

完成后同一 Oracle 场景继续用于对话，避免从一张清晰尾帧突然跳到另一种裁切。Reduce Motion 直接进入；未来加入 MP4 后仍使用既有单次播放路径。

## 检查入口

App → Settings → Spatial preview。滑块驱动与陀螺仪相同的姿态数据，可查看每位角色的零位、正负方向和对角线极限。状态明确显示两层就绪或单图降级。这里的显示参数与实际对话场景相同。

## 补全背景的实际 image_gen 提示词

三次均为本地母图编辑，不改变主体母图，输出保存到上述 background-spatial-v2.png。原始生成文件保留在工具默认目录。

### Oracle

```text
Use case: precise-object-edit. Input is the exact edit target, the approved green-toned Oracle room. Produce ONLY an opaque clean background plate for parallax. Remove the entire seated woman including her clothes, hands, legs, shoes and her body-specific shadows. KEEP the chair, the table with plain cloth, plate of cookies, cup, doorway bead strings, all furniture and room geometry exactly where they are. Reconstruct the empty chair seat/back and the small regions of room/floor that were hidden behind her, matching existing blur, lighting, perspective and olive-green film palette. Do not change the camera, crop, full 853x1844 canvas, exposure, color, texture, furniture or any unaffected visible background area. No trace of the woman, no human shape, no new objects. Preserve the outer edges and the soft bead curtains. Output a single seamless full-frame PNG with no text or UI.
```

### Stone

```text
Use case: precise-object-edit. Input is the exact edit target, the approved dark monolith scene. Create ONLY a clean opaque background plate. Remove the entire central black monolith and its cast and contact shadow. Reconstruct the cold grey blue-green chamber wall and smooth floor behind it, maintaining the existing scene's perspective, focus, directional light, texture scale and subtle gradients. Keep every unaffected pixel, camera, full portrait 853x1843 canvas, lens, framing, exposure and palette unchanged. Do not invent columns or any new objects. No black rectangle, residual silhouette or pedestal. No text/UI. Output one seamless full-canvas PNG.
```

### Jester

```text
Use case: precise-object-edit. Input is the exact edit target, the approved ivory/dark-red Jester mask on a stand. Create ONLY a clean opaque background plate. Remove the entire mask, its complete thin support stem and round base, and their object-specific shadows. Reconstruct the dark aubergine/crimson velvet folds and cool shadowed alcove behind them, exactly matching their depth of field, existing lighting, perspective and color. Preserve the full 853x1844 canvas, camera, crop and all unaffected fabric and background pixels. No new folds that visibly change the original foreground, no new objects, no mask-shaped residue. No text or UI. Single seamless full-frame PNG.
```

## 本轮验证

Xcode 26.0 / iOS 26.0 iPhone Air 模拟器。四项空间测试通过：三角色真实分层、蒙版版本/截断校验、姿态限幅/异常值、帧率无关平滑。空间 UI 测试通过，三角色中立与相反对角极限共九张截图位于 `ios/Verification/spatial-v2/`。目视复查修正了旧稀疏模糊的多重轮廓，当前画面无明显图层空洞或重复主体。结果包 `/private/tmp/jev-spatial-tests-3.xcresult`。

此处验证的是模拟姿态下的构图和合成。物理 iPhone Air 的传感器手感、帧率与功耗尚未验收；此前签名配置缺少 Xcode 登录账号和 provisioning profile，仍需完成设备安装后验证。

随后回归通过 7 项对话单测与 4 项既有 UI 流程测试；连同空间验证，本次共 16 项相关测试通过。结果包 `/private/tmp/jev-spatial-regression.xcresult`。最新版已安装并打开到 iPhone Air 模拟器首页，空间效果开启。
