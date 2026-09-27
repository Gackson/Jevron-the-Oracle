# Entry continuity and incremental replies — 2026-09-27

The homepage uses the entrance movie's exact first frame as a startup poster. Once the decoder is ready, the paused AVPlayerLayer is visible before the user taps Enter. Enter starts the same layer in place: identical aspect-fill, position and bounds. The title and scrim fade independently; the movie starts dissolving into The Oracle 700ms before its end and continues playing throughout the 650ms fade. Tapping artwork, text or the Enter button starts the same guarded entry action.

The direct TypeSafe client now emits the rendered, validated prefix after every accepted selection and before requesting the next word. Planning choices and end markers emit no extra text. The Oracle chooses a whole authored reply in one provider request and shows that reply immediately when received. Other characters emit their verified words as each selection arrives. This is incremental composition over the provider's structured Choice API, not provider token streaming. The unused legacy HTTP client still has a complete-response contract.

A provisional turn appears immediately and shares its identity with the final committed turn. Only finished replies enter future context. Character changes and cancellation discard the provisional turn; late callbacks cannot resurrect it. A failed composition replaces provisional words with one character fallback. Word views retain their identity while the prefix grows, so existing words do not replay an artificial reveal queue.

Waiting shows a softly glowing, floating line in the answer area. There is no activity indicator or Cancel control. The newest received word has the same gentle motion, which stops at completion. Reduce Motion removes movement. Composer position stays anchored throughout waiting, incremental delivery and completion.

Automated checks cover direct-engine emission before the next provider call, partial output before completion, stable turn identity, cancellation, fallback replacement, role grammar parity, and simulator interaction flows. Paid live-provider tests are opt-in and were not run for this visual update.

Validation result: 20 iOS tests passed (10 ConversationTests, 7 DirectJEVTests, 3 FlowTests), 2 paid live tests skipped. Python/mobile grammar parity passed. Result bundle: `/private/tmp/jev-stream-verification.xcresult`.

Captured states: [home](home.png), [waiting](waiting.png), [first word](partial.png), [complete reply](complete.png). The UI test checks that the first visible answer is incomplete and that the composer retains the same Y position in all three response states.

Whole-reply animation refinement: words delivered together now stagger in their arrival batch (up to 120ms per word; final start capped at 1.2s). Single-word streaming updates still start immediately. Already-mounted words keep their state, and final response commitment does not replay the sequence. Reduced Motion and historical replies show all words directly.

Entrance overlap follow-up: the homepage now accepts background and headline taps as well as Enter. A playback-time observer starts the 650ms fade with 700ms remaining. The entrance stays mounted and the movie keeps playing until the fade completion removes the player. Incoming controls use disabled state during the fade, avoiding stale hit-testing of native glass controls. Background/text entry and post-fade menu/circular swipe UI tests passed in `/private/tmp/jev-entry-final.xcresult`; cold-launch/Oracle entry also passed in `/private/tmp/jev-entry-overlap.xcresult`.
