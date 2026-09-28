# JEV visual system, first native implementation

Status: implemented layout and motion defaults. Supplied entrance stills, three character masters, continuous depth and the user-produced curtain video are integrated. Real-device motion tuning remains pending. Based on the user's confirmed full-screen direction and beaded-curtain entrance. See `docs/ASSET-PROMPTS.md` for production prompts.

## Composition

Every character inhabits a full-bleed scene. Top navigation and character selection remain fixed; a short response occupies the lower-middle region; the composer sits above the safe area or keyboard. The keyboard does not turn the scene into a card. Earlier turns page vertically over the same character scene.

The welcome uses the entrance movie's exact first frame, a short product explanation and one Enter action. A paused, aspect-fill player is already visible on the homepage; Enter starts that same layer without changing its crop or position. Tapping anywhere on the homepage starts the supplied 5.07-second curtain video. The 650ms dissolve into The Oracle begins 700ms before the movie ends, while playback continues beneath the fade. The player is removed only after the dissolve completes. The supplied 4.1-second audio cue begins at the video’s first frame on the same playback timeline. Skip fades the sound with the picture; scene teardown stops both. Sound respects system silent mode. Every cold launch shows the entrance. Returning from the background preserves the current conversation.

## Theme and color

Scene: a quiet evening pause with a question still on the user's mind. Restrained dark neutrals; warm, readable text; scene-specific light. No gradient text. Optical effects affect imagery only.

Design color references in OKLCH (approximate targets; native rendering uses the sRGB values in `Palette`):

| Role | OKLCH target |
| --- | --- |
| Canvas | `oklch(0.16 0.005 150)` |
| Surface | `oklch(0.245 0.006 145)` |
| Primary text | `oklch(0.925 0.025 90)` |
| Secondary text | `oklch(0.765 0.02 90)` |
| Oracle scene accent | `oklch(0.70 0.09 75)` |
| Stone scene accent | `oklch(0.75 0.03 225)` |
| Jester scene accent | `oklch(0.59 0.10 20)` |

Final contrast on generated imagery must be checked; a dark scene overlay currently stabilizes the response/composer area.

## Type and controls

System type for controls and supporting copy, system Latin serif for English introductory headlines and replies. Chinese serif text uses bundled Noto Serif CJK SC Regular (SIL OFL), including punctuation; it never depends on a downloadable system font. Semantic Dynamic Type sizes, wrapping rather than shrink-to-fit. One-line responses are the default visual ambition, not a hard content limit. Buttons have minimum 44-point hit regions. Standard text editing, settings form, system microphone permission flow.

## Depth and motion

Continuous scene depth replaces independent foreground/background motion. Original RGB artwork and its contact shadows remain one connected image. Offline Depth Anything V2 Small estimates a smooth relative depth field; Metal performs bounded inverse reprojection, plus one shared projective tilt. No alpha cutouts are used. See `docs/SPATIAL-V3.md` for source research and `docs/SPATIAL-V4.md` for stronger recessed depth and current transitions.

Metal layer effect keeps center sharp and progressively softens and slightly stretches the periphery. UI stays outside the shader. Static imagery remains usable with all motion/effects disabled.

Verified response words appear immediately as each selection arrives; existing words remain visible and never replay a timed reveal queue. The Oracle selects a whole reply at once; its first word starts appearing immediately and the remaining words stagger at up to 120ms intervals, with the final word starting within 1.2 seconds. Words rise 4pt into place over 240ms and briefly glow. Words in a streamed single-word update receive no stagger delay. Waiting text and the newest incoming word gently float and glow, with no spinner or Cancel control. The composer remains anchored. Historical replies do not replay. VoiceOver announces completion. Reduce Motion skips entrance video, word movement and scene motion.

## Truthful development states

Missing artwork is a labeled development preview. Manual sample replies are labeled and separated from live conversation context. No automatic fixture fallback after an API failure. Full-screen final images, genuine multi-layer alignment, video continuity and physical-device performance remain separate acceptance items.

## Scene changes

The Oracle, The Stone and The Jester form a circular horizontal sequence. Role changes use one 720ms cross-dissolve; blur follows the same progress with a smooth 18pt peak at the midpoint. No separate blur / replace / refocus phases. Both images retain explicit full-screen bounds through the entire transition. Reduced Motion switches immediately.

The composer has no conditional text below it. History and input-length hints must not move the input away from its safe-area/keyboard anchor.

## Hold to speak

When the composer is idle, a short tap opens the keyboard and a 350ms hold begins voice capture. Releasing immediately stops capture, allows up to 800ms for the final transcription, and submits nonempty recognized speech. During active text editing, native long-press selection is preserved. The microphone button remains a separate record/stop flow that leaves transcription in the draft for review. Recording adds a subtle border and a haptic on microphone readiness, with no new text below the composer. Releasing during permission/preparation cancels the pending start; interruptions and gesture cancellation never auto-send.

Character scenes now share one conversation-owned motion session. Switching keeps its current pose and reference orientation throughout the dissolve. Both incoming and outgoing scenes receive prepared depth artwork on their first frame; removing a scene cannot stop or reset the shared sensor.

## Interface language

The persisted language switch controls the whole interface, accessibility labels, status copy, and new replies. Chinese mode translates the welcome, character invitations, settings, spatial preview, history controls, and recoverable errors. The brand title and four character names remain English. Existing questions and answers retain their original text; status labels follow the current interface language. Both languages retain semantic Dynamic Type scaling. Native permission descriptions are bundled in English and Simplified Chinese and follow the system’s app language.
