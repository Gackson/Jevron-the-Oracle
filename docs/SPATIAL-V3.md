# 空间效果 V3：连续深度重投影

2026-09-27。本轮替代 V2 的独立前后景位移，并修正角色切换与首页入口。

## 结论

当前三张静态素材最合适的实现是：**完整原图 + 离线估计的连续深度场 + 小视角重投影**。运行时不再抠出人物、石碑或面具，不再单独移动补全背景。人物与椅子、手肘与桌面、碑底与地面、面具与支架，以及原图的接触阴影，始终属于同一张连续画面。

这是有限视角的 2.5D 效果，不是恢复了完整房间的三维模型。深度图本身也不能恢复遮挡后的真实颜色；运动范围必须受约束。大幅环绕观察需要有深度的遮挡补全、多视角素材或真正的 3D 场景。

## 调研与方案选择

| 方案 | 接触与遮挡 | 本项目判断 |
| --- | --- | --- |
| 独立人物/背景平面 | 平面相对移动，接触点和投影会分离 | 停用。V2 视觉验收只检查了空洞，遗漏了接触关系 |
| Apple ImagePresentationComponent / Spatial3DImage | 系统生成空间场景 | Xcode 26.0 的公开 SDK 明确标注 `ImagePresentationComponent` 在 iOS 不可用、visionOS 26 可用，不能作为 iPhone 实现依赖 |
| 连续深度场的小视角重投影 | 完整 RGB 画面参与同一变换，没有独立剪切边缘 | 本轮采用。保留原图接触关系、轮廓和阴影，运行轻量 |
| 深度网格 + 遮挡分层补全（LDI） | 可填补视角变化后露出的背景 | 更适合较大幅度的 3D 照片，但需要质量更高的深度与颜色补全；单张图仍无法验证背面是否真实 |
| 多视角/真实 3D 模型 | 最完整的接触、遮挡与透视 | 后续若需要大角度绕视，这是更合适的资产升级方向 |

来源：

- Apple [WWDC25 RealityKit](https://developer.apple.com/videos/play/wwdc2025/287/) 与 [空间图片 API](https://developer.apple.com/documentation/realitykit/imagepresentationcomponent/spatial3dimage)。同时核对本机 iPhoneOS26.0 SDK 的 `RealityFoundation.swiftinterface`，而不是只根据网页上的 visionOS 演示推断 iOS 支持。
- [Depth Anything V2 官方项目](https://github.com/DepthAnything/Depth-Anything-V2) 与 [Apple 官方 Core ML Small 模型](https://huggingface.co/apple/coreml-depth-anything-v2-small)。选用 Small/F16，Apache-2.0；下载模型仅用于 Mac 离线预计算，不打包到 App，也不上传角色图片。
- Apple [Depth Pro](https://github.com/apple/ml-depth-pro) 能提供高分辨率、度量深度；本应用的有限视角效果只需相对深度，现成 Core ML Small 模型更直接。
- [3D Photography using Context-aware Layered Depth Inpainting, CVPR 2020](https://shihmengli.github.io/3D-Photo-Inpainting/) 使用显式像素连接关系和被遮挡区域的颜色/深度补全，说明大视角重建不能仅靠两张平移的图片。

## 素材与计算

- RGB：继续使用 V2 的完整 `oracle-master.png` / `stone-master.png` / `jester-master.png`，不修改任何可见像素。
- 深度：`assets/depth-v3/<id>-scene.depth`；运行时副本同名，位于 `ios/JEV/Resources/Media/`。
- 模型：Apple `DepthAnythingV2SmallF16.mlpackage`，固定仓库版本 `cfef6f6f2a70783dedc0bfae40cecbc2052285d3`。
- 工具：`ios/Tools/prepare-scene-depth.swift`，输入原图，按模型要求缩放到 518×392；直接读取 Float16 数值，避免把深度当作颜色做 gamma 变换。预览图是该数值网格的可视化，比例不是最终画面的比例。
- 深度归一化后进行轻量平滑与对称坡度约束，只处理几何数据。App 使用 UInt16 深度文件，包含尺寸与原图 SHA256；换图但未换深度时拒绝使用。
- V2 的 clean plates / foreground masks 保留作历史资产，但新渲染器完全不加载它们。石碑底部因此不再经过分割 alpha，消除了那条抠图锯齿的来源。

重新生成：

```sh
swift ios/Tools/prepare-scene-depth.swift /path/to/DepthAnythingV2SmallF16.mlpackage ios/JEV/Resources/Media assets/depth-v3
```

## 运行时几何与光学

`sceneDepth` Metal shader 对同一个完整图像执行 8 次固定点逆重投影。画布上每个像素根据自己的相对深度移动；接触区域共享连续映射，没有独立的人物位移或椅子位移。

最大基线为画布宽的 3% / 高的 1.1%，并限制在 16pt / 10pt；实际像素位移乘以 `(depth - 0.5)`。坡度与基线共同限制映射，测试检查最大对角倾斜时仍是收缩映射，避免深度边界翻折。完整场景另外共用最大 1.1° / 0.7° 的透视变化。1.10 倍绘制余量覆盖边缘。

中心清晰与外围渐进高斯模糊、轻微拉伸仍保留，作用于图像，不作用于文字和控件。传感器采用相对初始姿态、±12°、60Hz 与基于 dt 的 85ms 平滑。Reduce Motion 提供静态图和直接切换。

## 两个交互修正

- 冷启动始终进入珠帘首页；点击 Enter 后到 Oracle。旧的 `hasEntered` 持久化跳过规则已删除。进后台再回来不重置当前会话。
- 切换角色先约 180ms 失焦，再约 280ms 交叉溶解到目标，最后约 260ms 对焦。目的场景提前加载；切换期间拒绝重复切换/发送，避免角色与问题错配。Reduce Motion 立即切换。

## 验证

验证结果与截图记录在 `ios/Verification/depth-v3/`。验收重点为三处接触：Oracle 的椅子/桌面、Stone 的碑底/地面、Jester 的支架/底座。静态截图只能验证映射与接触外观，真机手感、帧率和功耗需要设备实测。
