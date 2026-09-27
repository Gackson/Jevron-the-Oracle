# Brand verification · 2026-09-27

Xcode 26.0; iOS 26.0; dedicated `Jevons Brand Verification` iPhone Air simulator. Other agents' booted simulators were not used.

## Confirmed

- Final simulator build succeeded, including Apple asset compiler processing of `OracleIcon.icon`.
- Built `Info.plist` reports `CFBundleDisplayName = Jevons the Oracle` and `CFBundleIconName = OracleIcon`.
- Apple `ictool` rendered light/dark previews from the actual layered icon package.
- Entrance, conversation/history, character-switching UI test passed.
- Accessibility XXXL and scene-effects UI test passed; entrance content remains scrollable.
- Screenshots: `entrance.png`, `conversation.png`, `large-type.png`.

## Remaining verification issue

The keyboard regression failed in both the initial run and an isolated repeat at `FlowTests.swift:147`: tapping the editor after a streamed answer appeared did not display the keyboard within three seconds. Earlier checks in that test (multiline alignment, dismiss/reopen, sending and receiving an answer) passed. This is recorded without attributing it to a specific cause; concurrent agents are changing conversation behavior and this brand task has not changed that logic.

Build logs: `/tmp/jevons-brand-final-build.log`.
Initial UI result: `/tmp/jevons-brand-ui.xcresult`.
Isolated keyboard repeat: `/tmp/jevons-brand-keyboard-retry.xcresult`.

No physical-device or older-iOS runtime test was performed. Compatibility branches compile with iOS 17 deployment target.

## Color inversion follow-up

- Light icon now uses olive background / citron O; dark icon specialization retained.
- Entrance keeps the text wordmark and removes the large O.
- Enter uses olive tint with citron text and arrow, including the pre-iOS-26 fallback.
- Build and `testEntranceConversationHistoryAndCharacterSwitching` passed again (0 failures).
- Result: `/tmp/jevons-brand-inverted-ui.xcresult`; log: `/tmp/jevons-brand-inverted-ui.log`.
