# Chinese interface verification · 2026-09-28

Device: iPhone Air simulator, iOS 26. Final result: /private/tmp/jev-interface-zh-final.xcresult, TEST SUCCEEDED (2 unit tests, 1 UI flow).

- Live English → Chinese → English settings update, Chinese spatial controls and accessibility labels.
- Language persists across termination and relaunch; welcome copy and entry action are Chinese.
- Brand and character names stay English; prior answer content is preserved.
- Noto Serif CJK SC Regular loads from the app bundle; CoreText confirms the expected font and nonzero Chinese/punctuation glyphs.
- Chinese Oracle/Stela replies render in the bundled serif; home, settings and Oracle screenshots visually inspected.
- Final build installed on the regular iPhone Air simulator. Physical device verification not performed.

The first font probe found Songti SC absent on this simulator, so the final build bundles Noto Serif CJK SC instead. An Xcode SwiftUI view-reparenting runtime warning was recorded during the UI flow; the flow passed with no assertion failures.
