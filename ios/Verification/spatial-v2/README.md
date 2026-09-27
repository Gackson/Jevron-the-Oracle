# V2 spatial verification — 2026-09-27

Xcode 26.0 / iOS 26.0 iPhone Air simulator.

- Four SpatialTests passed: real foreground/background composition for all three characters; checksum-bound mask validation; sensor clamping/nonfinite values; frame-rate independent smoothing.
- One spatial UI test passed, capturing nine screenshots: neutral and both diagonal extremes for Oracle, Stone and Jester.
- Reviewed subject/background separation and outer canvas coverage. Replaced sparse nine-tap blur, which produced repeated contours, with two dense 25-tap Gaussian passes. Current screenshots use the corrected shader.
- Result: `/private/tmp/jev-spatial-tests-3.xcresult`.

## Screenshots

| Character | Left / top | Center | Right / bottom |
| --- | --- | --- | --- |
| Oracle | [View](spatial-Oracle-left-top.png) | [View](spatial-Oracle-center.png) | [View](spatial-Oracle-right-bottom.png) |
| Stone | [View](spatial-Stone-left-top.png) | [View](spatial-Stone-center.png) | [View](spatial-Stone-right-bottom.png) |
| Jester | [View](spatial-Jester-left-top.png) | [View](spatial-Jester-center.png) | [View](spatial-Jester-right-bottom.png) |

The diagnostic screen drives the same pose/compositor used in conversation. This validates simulated poses, not physical sensor feel or sustained GPU performance. Physical iPhone Air installation was previously blocked by missing Xcode account/provisioning configuration; on-device motion, performance and power remain unverified.

Entrance video is absent. The current entry is a 0.92-second blur dissolve into the actual Oracle compositor. Source and asset details: `docs/SPATIAL-V2.md`.

## Regression

The subsequent regression run passed all 7 conversation unit tests and 4 existing UI tests (entry/conversation/history/character switching, multiline keyboard input, large accessibility type/effects switch, repeat launch). Result: `/private/tmp/jev-spatial-regression.xcresult`. Together with the spatial run, 16 relevant tests passed. The current simulator app was installed and launched with spatial effects enabled.
