# Jevons the Oracle · iOS

SwiftUI application, iOS 17+. Generated with XcodeGen, no external package dependencies.

## Open and run

```sh
cd ios
xcodegen generate
open JEV.xcodeproj
```

Choose the JEV scheme and an iPhone simulator. For a physical iPhone, select an available development team under Signing & Capabilities and use a unique bundle identifier if necessary. No development-team identity is committed to this project.

```sh
xcodebuild -project JEV.xcodeproj -scheme JEV \
  -destination 'platform=iOS Simulator,name=iPhone Air' \
  -derivedDataPath /tmp/jev-build test
```

## Implemented

- First-visit introduction with full-screen background and an Enter action; every cold launch starts at the entrance.
- Bundled one-shot AVPlayer curtain video and synchronized audio cue, overlapping end dissolve, audio fade on skip, startup failure timeout, Reduce Motion bypass. The cue respects system silent mode.
- Full-screen scene compositor with continuous depth reprojection, Core Motion relative orientation, smoothing, limited displacement, static fallback.
- Metal edge diffusion/stretch, with clear fixed UI and a runtime effects switch.
- Independent character drafts and in-memory conversations; circular horizontal selection, vertical paged history, accessible alternative controls.
- Editable text/voice input, hold-to-speak and release-to-send from the idle composer, incremental verified-word delivery and gentle glow, Dynamic Type wrapping. The microphone button retains review-before-send; native selection remains available while editing.
- Request cancellation and stale-result isolation; bounded context for follow-ups; explicit preview/live modes.
- Unit tests for cancellation, duplicate submission, invalid/incomplete replies, context isolation and input limits; UI flow tests.

## Media

Five V2 stills are installed. V4 uses complete original RGB images and offline model-derived continuous depth fields. Metal performs bounded inverse reprojection; contact edges, supports and shadows share the same mapping. No independent foreground/background cutouts are used. See [spatial V3 research and implementation](../docs/SPATIAL-V3.md).

Cold launches always show the curtain home using the movie’s exact first frame. A paused aspect-fill player is visible before Enter, so playback continues in the same layer with identical framing. Tapping anywhere on the homepage starts `entrance.mov`. Its 650ms dissolve into The Oracle starts 700ms before the movie ends, with playback continuing throughout. Character switches blend imagery and blur simultaneously over 720ms. See [V4 motion update](../docs/SPATIAL-V4.md). Settings → Spatial preview allows maximum tilt inspection, with a Hide controls button to inspect the contact points.

Runtime media lives in `JEV/Resources/Media/`. Regenerate matching `.depth` data when changing a master; source hashes reject stale depth. Previous clean plates/masks remain archived under `assets/` and are no longer bundled or loaded.

## Direct JEV connection

Settings → Connection → enter and save your TypeSafe API key, then disable Sample replies. The app calls TypeSafe's official HTTPS API directly through `DirectJEVClient`; no separate server or service URL is required. The four 255-entry catalogs, semantic encoding and bounded composition rules run on the device. See [direct connection details](DIRECT-JEV.md).

The API key is stored in this device's Keychain, accessible while unlocked and excluded from iCloud synchronization. Settings supports replacement and deletion; the input clears after saving or leaving Settings. No real key is bundled with the app. Use normal Xcode simulator signing when testing Keychain; omit `CODE_SIGNING_ALLOWED=NO` from the command above.

Sample replies are manual fixtures. Network or generation failures produce separately labelled character fallback replies; neither sample turns nor fallback turns enter live context. Requests include up to six completed same-character turns. User cancellation does not create a fallback turn.

Selected character, visual preference and sample-mode preference persist in UserDefaults; the API key persists separately in Keychain. Questions, replies and drafts remain in memory and are lost on process termination. Clear conversation removes the current character's turns and draft without deleting the key.

Settings save/replace/delete operations and a real direct Oracle request have passed simulator tests. This verifies the connection, not Stela/Jester/Fool language quality; see [verification results](../docs/verification/direct-jev-2026-09-27.md). The Python service remains an optional development tool.

## Verification limits

Simulator testing does not validate gyroscope feel, on-device speech quality, real media continuity, GPU performance with final assets, live-model relevance or physical-device installation. These must be recorded separately after the corresponding resources and signing are available.

Incremental replies and entrance continuity are documented with simulator captures in [verification notes](Verification/streaming-entry/README.md). The active direct client publishes each validated selection before asking for the next word; only completed turns enter follow-up context.
