V2 RGB artwork + V4 continuous depth, 2026-09-27

Jester is now a real masked performer (assets/jester/master-v3.png,
829x1897 sRGB). Its jester-scene.depth was regenerated and source-bound.

Original RGB: entrance-closed/open.png, oracle/stone/jester/fool-master.png.
User-produced video: entrance.mov, copied unchanged from assets/video/entrance.mov;
5.0667s, 720x1280, 30fps. The original remains a muted fallback. A 650ms dissolve into The Oracle begins 700ms before the end; video keeps playing during the fade.

Depth: oracle/stone/jester/fool-scene.depth, UInt16, 518x392, source SHA256 bound.
Apple Depth Anything V2 Small F16, offline numeric processing only.
V4 slope projection targets 0.012 across 320 passes to support stronger motion.
All scene depth lies behind the glass. No independent cutouts or plates.
See docs/SPATIAL-V3.md for research and docs/SPATIAL-V4.md for current tuning.

Cold launch shows home. Character switching loops in both directions.
Blur and dissolve share one 720ms progress, never separate phases.

Entrance poster: entrance-poster.png is the movie's exact frame at time zero,
720x1280, extracted without image generation. Regenerate after replacing the movie:
  swift ios/Tools/extract-entrance-poster.swift
The paused AVPlayerLayer is already visible on the homepage, with the same
resizeAspectFill bounds as playback. The poster only covers decoder startup.

Sound-enabled entrance: entrance-scored.mov combines the original video with
source file "assets/audio/Cymatics - ACCENT Amore - 117 BPM F Maj.wav" (4.102562s stereo).
Both tracks start at zero; the full video duration remains 5.0667s.
AVFoundation passthrough preserves the original video without re-encoding.
Rebuild using: swift ios/Tools/compose-entrance-audio.swift
The app prefers this combined file so sound and video share a single clock.
The cue respects system silent mode, mixes with other audio, and fades on Skip.
