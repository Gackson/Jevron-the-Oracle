# V4 visual and interaction verification

2026-09-27 · iPhone Air simulator · iOS 26 · Xcode 26.

- Seven spatial/domain unit tests passed on final integration: source-bound depth assets, continuous mapping at maximum diagonal tilt, pose clamping/smoothing, circular navigation, and explicit missing artwork for the newly added Fool.
- Six UI flow tests passed across the smoke and remaining-flow runs: actual entrance video completion, circular swipes in both directions, history with stable composer position, keyboard/multiline input, large text, cold launch, and nine extreme-pose captures. The video/circular-swipe flow was rerun after the fourth character was added and passed.
- Final entrance was recorded after hiding the closed still during video playback. Inspected the final-frame dissolve at 42.1 / 42.5 / 42.9 seconds of the full recording: no closed-curtain flash, frozen top strip or uncovered top safe area. Fading entrance no longer intercepts taps.
- Character-transition frames show blur and image blending advancing together, with explicit full-screen image bounds. No independently sliding cutouts.
- Source `assets/video/entrance.mov` and bundled copy share SHA256 c22110a950f819591922eabcb121c643fc663e8bccf27c4e1c8bee22dab35dbf.

[Entrance video and dissolve](entrance.mov) · [Simultaneous character dissolve](character-switch.mov)

Result bundles: /private/tmp/jev-v4-smoke.xcresult, /private/tmp/jev-v4-verification.xcresult, /private/tmp/jev-v4-final-integration.xcresult. Final build: /private/tmp/jev-v4-final-build.log. Earlier failed runs were resolved before these passing runs.

Captures use original asset IDs (Stone is now displayed as The Stela). Three master scenes have true model-derived depth; The Fool uses an explicit development placeholder pending its own artwork.

| Scene | Left/top | Center | Right/bottom |
| --- | --- | --- | --- |
| Oracle | [View](spatial-Oracle-left-top.png) | [View](spatial-Oracle-center.png) | [View](spatial-Oracle-right-bottom.png) |
| Stone / Stela | [View](spatial-Stone-left-top.png) | [View](spatial-Stone-center.png) | [View](spatial-Stone-right-bottom.png) |
| Jester | [View](spatial-Jester-left-top.png) | [View](spatial-Jester-center.png) | [View](spatial-Jester-right-bottom.png) |

Physical gyroscope feel, sustained GPU frame rate and power remain unverified. The current result is stronger small-baseline image reprojection, not a recovered full 3D room.
