# Hold to speak — 2026-09-27

The idle text area distinguishes a short tap from a 350ms hold using native UIKit recognizers. A short tap focuses the existing SwiftUI editor. A hold starts speech capture, with a soft haptic only once capture is ready. Release stops capture immediately, allows up to 800ms for final transcription, and automatically submits nonempty recognized speech. The microphone button still leaves the transcript in the draft for review. Native text selection is preserved while the keyboard/editor is active.

The composer retains its existing bounds; the recording state adds a subtle border without extra hint rows. Empty speech, gesture cancellation, interruption and release during permission/preparation do not submit. Session IDs reject late permission and transcription callbacks. The capture timeout is cancelled on release so it cannot interrupt finalization.

Validation uses injected transcription without requesting simulator microphone access. Three speech lifecycle tests cover release/finalization, release during preparation and interruption. Three UI flows cover hold/release/send plus normal tapping, microphone review, and multiline keyboard input. Physical microphone quality, recognition latency and permission prompts still require an iPhone check.

Test injection requires both `--uitesting` and `--uitesting-speech`; it is never enabled by ordinary launch or as a failure fallback.

Final result: all 6 selected tests passed. Result bundle: `/private/tmp/jev-hold-final.xcresult`; build and test log: `/private/tmp/jev-hold-final.log`.
