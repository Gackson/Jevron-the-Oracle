# Native verification, 2026-09-27

Current implementation: [V3 continuous depth verification](depth-v3/README.md). V3 supersedes the independent split-layer motion in V2 and always shows home on cold launch.

Latest spatial update: see [V2 spatial verification](spatial-v2/README.md). The original section below records the earlier master-only build; its shallow-motion and failed-layer notes are superseded by the V2 spatial implementation.

Xcode 26.0, iOS 26.0 iPhone Air simulator. Deployment target iOS 17.

## Passed

- Simulator build, including SwiftUI, Speech, Core Motion and the Metal shader.
- 7 conversation unit tests: duplicate-submit prevention; late-response cancellation isolation; incomplete reply rejection; same-character follow-up context; Unicode-scalar input limits; response identity/empty response validation; exclusion of preview replies from live context.
- 4 UI tests: welcome → two questions → actual vertical history swipe → character switch; long keyboard input and reachable send button; subsequent launch restoring the selected character; maximum accessibility text size plus effects toggle.
- Examined saved screenshots, found and fixed large-text truncation on welcome and character controls. Welcome is now scrollable and full text is retained; accessibility sizes use a character menu; microphone icons remain within their hit areas; reply text wraps and scrolls as needed.
- A final simulator rebuild passed after updating the media-status copy.

The final complete test run is `/private/tmp/jev-tests-3.xcresult` with 7 unit tests and 4 UI tests passing. Earlier runs were used to discover and reproduce the large-text defects; their screenshots are not the final state.

## Screenshots

- [Entrance](entrance.png)
- [Oracle reply](oracle-response.png)
- [Keyboard](keyboard.png)
- [History](history.png)
- [Stone reply](stone-response.png)
- [Largest accessibility reply](accessibility-response.png)

Replies in these screenshots are explicit manual fixtures. Artwork came from the shared media directory during implementation; provenance is in `docs/ASSET-GENERATION-LOG.md`. Runtime images are currently complete masters, not approved parallax layers.

## Not passed / not yet verified

- Physical iPhone Air detected over USB, iOS 26.6, Developer Mode enabled. Signed device build failed because Xcode has no logged-in account for the installed development certificate's team and no development provisioning profile for `com.jev.oracle`. No app was installed to the physical phone. Xcode project was opened for account/Team setup.
- Live API and real model output: no service endpoint supplied; v2 client contract awaits server integration.
- Entrance movie continuity/playback with final media: no `entrance.mp4` supplied. Missing-video entry and Reduce Motion bypass exist in code; final video needs a media-specific run.
- Physical gyroscope behavior, GPU performance with final layer assets, real speech permissions/transcription, and interruption behavior require device validation. Speech is implemented but not claimed verified by the simulator tests.
- Multi-layer asset candidates failed visual alignment/material checks and remain under review. The currently integrated master-image fallback gives only shallow motion.
- Session history is memory-only; cross-relaunch dialogue restoration is not implemented. Selected character and preferences persist.
