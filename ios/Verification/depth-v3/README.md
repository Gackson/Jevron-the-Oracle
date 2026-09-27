# Continuous depth V3 verification

2026-09-27, iPhone Air simulator / iOS 26.0 / Xcode 26.0.

- 5 depth tests passed: all three scenes load model-derived depth; source hash/truncation rejection; maximum diagonal mapping remains a contraction (including quantization); invalid sensor/clamping; frame-rate independent smoothing.
- 5 FlowTests passed: cold launch always starts at home; entrance/conversation/history/role switching; multiline input and keyboard; largest accessibility type; extreme spatial poses.
- Re-ran 5 depth tests and the spatial UI test with normal simulator signing and hidden diagnostic controls. Nine full-scene captures show original contact shadows and connected chair/table/floor/stand. Stone no longer uses a cutout edge.

- Final signed build passed after removing routine speech helper copy and fixing the transition container to explicit full-screen bounds. Recorded the Oracle → Stone transition and inspected defocus, dissolve, and refocus frames: the outgoing and incoming artwork cover the status-bar area throughout the sampled transition. [Transition recording](character-switch.mov).

Result bundles: `/private/tmp/jev-depth-tests-1.xcresult` and `/private/tmp/jev-depth-contact-tests.xcresult`.

| Role | Left/top | Center | Right/bottom |
| --- | --- | --- | --- |
| Oracle | [View](spatial-Oracle-left-top.png) | [View](spatial-Oracle-center.png) | [View](spatial-Oracle-right-bottom.png) |
| Stone | [View](spatial-Stone-left-top.png) | [View](spatial-Stone-center.png) | [View](spatial-Stone-right-bottom.png) |
| Jester | [View](spatial-Jester-left-top.png) | [View](spatial-Jester-center.png) | [View](spatial-Jester-right-bottom.png) |

This is small-baseline image reprojection, not a full recovered 3D room or unseen-surface reconstruction. Device motion feel, sustained frame rate and power are not validated by simulator poses. The previous physical signing blocker remains separately tracked.
