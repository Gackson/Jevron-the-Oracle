# Continuous camera pose across character changes

The previous scene owned its own sensor instance. Beginning a character switch set its motionActive flag to false, which called stop() and reset the pose. The outgoing copy and incoming character also started with new motion instances and flat initial artwork.

RootView now owns one SceneMotion for the conversation. Both scenes read that same observable instance; only the scene subtrees observe its 60Hz pose updates. Character switching is excluded from the motion lifecycle. A character's disappearance cannot stop the shared sensor or replace its reference orientation. Standalone spatial preview retains its local motion lifecycle.

Before installing the dissolve layers, both characters' depth artwork is loaded and supplied to their initial state. The outgoing layer therefore matches the visible scene from its first frame, and the incoming scene starts at the current depth pose. The 720ms shared blur/cross-dissolve is unchanged.

Simulator coverage injects pose x=0.75, y=-0.5, verifies it remains unchanged through three menu changes and a horizontal swipe, and captures each resulting scene. It does not claim physical-device sensor validation. Circular swipes and the existing frame-rate-independent smoothing checks are also covered.

Verification passed: two spatial unit checks and circular swipes in `/private/tmp/jev-shared-tilt.xcresult`; nonzero-pose menu/swipe regression in `/private/tmp/jev-shared-tilt-final.xcresult`. Before/after Oracle scene ROI mean RGB difference: [0.0, 0.0, 0.0].
