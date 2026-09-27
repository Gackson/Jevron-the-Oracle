# JEV V2 实际生成提示词

工具：内建 image_gen。三位角色引用相应 V1 母图；Stone 二次编辑引用 V2 candidate，闭帘引用 V2 Oracle。V1 保留在 assets/versions/v1/。

## oracle

```text
Use case: precise-object-edit / style-transfer.
Input image 1 is the existing Oracle scene to revise. Make the definitive V2 scene, not a collage.
Portrait full canvas 853x1844, same older woman's identity, warm knowing expression and hand-to-cheek seated pose, modest kitchen and cookies. Revise art direction substantially:
COLOR: late-1990s cinematic 35mm film with Matrix-inspired muted olive / celadon GREEN room, deep forest-green and cyan-green shadows, neutral bone highlights, natural softly warm skin and a SMALL tungsten practical accent. Rich separation of cool green room versus skin; NO overall yellow, sepia or orange wash. Green is in walls and ambient light, not sickly skin.
SIMPLIFICATION: replace ALL tiny floral patterns on dress and apron with plain dark moss cotton dress and plain faded stone/sage apron, gentle broad folds only. Replace patterned tablecloth with plain muted grey-green linen, NO floral or embroidered motif. Plain cup, cookies, no vase of fine flowers. Simplify room clutter to a few softly described masses. Reduce floor/rug detail drastically.
DEPTH: clearly stronger shallow optical depth of field. Focus on her eyes and face, face naturally readable but no digital sharpening. Kitchen several feet behind her visibly defocused into soft shapes; near bead strands and nearest table edge out of focus. Organic vintage lens softness, subtle low-contrast grain, very restrained highlight halation and gently lifted black detail. Not plastic smoothing or thick mist.
FRAMING: end of a slow forward walk through the bead curtain, camera now just inside doorway, a modestly closer intimate seated portrait than source. Face around y=30%, body/table in upper two-thirds, lower 30% dim simple broad cloth/floor shadows for live text. Only a trace of softly blurred opened beads at extreme sides, no dominant doorframe. Do not tightly crop her face or hands.
Keep grounded photographic realism, no horror. No text, logos, UI, watermark, montage, ornate texture or over-sharpening.
```

## stone

```text
Use case: precise-object-edit / style-transfer.
Input image 1 is existing Stone scene, revise to V2. Full portrait canvas 853x1844. Preserve one massive upright rectangular black monolith, same two-plane silhouette, perspective, size and position.
User request: quieter high-frequency detail, much stronger depth separation, layered color, retro cinematic photography.
Replace cracked rocky mosaic floor with a broad continuous matte worn stone floor, very few large quiet seams if any, no pebbles, no dense cracks, no busy gritty texture. Monolith becomes smooth dense dark basalt with only faint broad mineral variation, NOT conspicuous marbling or glossy flakes. Soften background architecture into large dim stone masses.
COLOR: cool slate-blue / petrol-green shadow palette, neutral charcoal monument, subtle desaturated silver daylight on its side plane and tiny muted warm-grey bounce near base. Distinct cool/warm tonal layers, NOT yellow-brown or sepia wash.
DEPTH: focus on monolith's central silhouette and two planes, background wall clearly optically defocused; foreground floor increasingly softly blurred toward camera. Vintage 35mm film, gentle edges, restrained grain and slightly lifted blacks, soft highlight rolloff. No digital sharpening, crunchy microcontrast or etched textures. Still real believable stone, not smooth CG.
Preserve full object silhouette, stable base contact shadow, top breathing room and calm bottom third for text. No symbols, face, runes, fog clouds, floating objects, neon, words, logos, UI or borders.
```

## jester

```text
Use case: precise-object-edit / style-transfer.
Input image 1 is existing Jester scene, revise to V2. Full portrait canvas 853x1844. Keep same complete asymmetric theatrical mask with knowing crooked smile, same stand, tilt, scale and placement.
Simplify surface: remove dense scratches, tiny crackle network, grime flecks and intricate ornament. Plain matte aged bone-ivory plaster with subtle broad wear, one broad muted oxblood asymmetric painted area, understated charcoal eyebrow contours. Retain expression and tactile realism. No gold/yellow varnish. Velvet fabric becomes broad smooth dark folds with almost no visible microtexture.
COLOR: neutral bone-ivory mask, deep oxblood / aubergine fabric, charcoal and subtle cool teal-black shadows, soft neutral sidelight with tiny subdued rose-warm bounce. Rich color separation without overall amber/sepia filter.
DEPTH: vintage cinema lens, focus around mask's eyes/smile, background alcove substantially out of focus, nearest velvet folds softly out of focus. Gentle film softness, restrained fine grain, soft highlight rolloff; do not render razor-sharp pore/crackle detail. Broad tonal masses, intimate retro theatrical mood, not horror or shiny CG.
Lower third stays dim, quiet and uncluttered for live text, top 12% breathing room. No text, UI, watermark, frame, particles, neon, bells or added ornaments.
```

## Stone 材质修正

```text
Use case: precise-object-edit. Input image 1 is the V2 Stone edit target. Keep EXACT camera, object size, silhouette, architecture, cool slate-green palette, depth of field and lighting. Change MATERIAL TEXTURE ONLY, very substantially. The floor is now smooth poured dark-grey concrete, matte, softly worn, completely continuous with NO stone tessellation, NO pebble aggregate, NO cracks, NO crisscross lines, NO stippled detail. Large quiet gradients and soft cast shadow are the only visible floor features; the nearest floor remains strongly optically defocused. Replace the two faces of monolith with finely honed almost featureless dark basalt: uniform charcoal planes, just broad faint tonal clouds. Remove ALL marble veining, bright mineral flecks, branching networks and etched texture currently visible. Smooth stone, not a glossy mirror. Slight vintage lens softness on silhouette; restrained very fine film grain across image, no digitally sharpened texture. Preserve object grounding and silver/cool side light. Full 853x1844 portrait, no text/UI/frame.
```

## 闭帘首帧

```text
Use case: precise-object-edit.
Input image 1 is the V2 Oracle room reference and END frame. Create the START frame of approaching this same room, before pulling aside the bead curtain. Full portrait 853x1844, one photographic scene.
Move camera BACK outside doorway, visibly farther from the woman than reference. Close the same amber/dark wood bead curtain fully across the doorway. Dense vertical strings cover the entire opening; physically threaded small beads, modest highlights, no decorative crystals. Focus is on the middle depth of the near bead curtain, softly tactile with vintage lens rendition, not hyper-sharp.
CRITICAL: the interior behind the curtain is VERY OUT OF FOCUS due to a wide aperture and large focus distance separation. The woman is now smaller and distant, only an indistinct dark sage silhouette with a soft warm oval for a face. Absolutely NO readable eyes, nose, mouth, hair strands, fingers or garment texture through the beads. No sharply visible cookies or shelves. The room should read as soft abstract olive-green / forest-green masses, with one dim diffused amber practical light bloom toward the left. The curtain must visually dominate; we discover the woman only after opening and moving in.
Keep spatial plausibility with reference, but do NOT preserve its exact camera view, subject scale, or background sharpness: camera movement between frames is intentional. NO woman pasted sharply behind bead gaps. No opaque fabric curtain; this is still a bead curtain.
Retro 35mm cinematic tone, muted green ambience with small warm wooden bead highlights, rich soft shadow detail, controlled contrast and fine low-key grain. Lower third dim, quiet, no bright floor patterns; top 12% breathing room. No text, UI, watermark, frame, hands pulling curtain, added characters, fake fog, neon or over-sharpening.
```

## 视频提示词（未生成 MP4）

```text
Create a single continuous 4-second cinematic entrance shot using the supplied first and last frames.
First frame: camera outside a closed beaded doorway, focus on nearby beads. The room and seated woman behind are strongly out of focus; her face must not be readable.
0.0–0.5s: hold the quiet closed-curtain view briefly.
0.5–1.7s: bead strands separate gently from the center, gathering to both sides, with restrained physically plausible threaded sway.
1.0–3.5s: the camera smoothly and slowly DOLLIES FORWARD through the opened doorway toward the woman. Real perspective and scale change are intentional; this is not a locked camera or a simple digital zoom. Keep the room's spatial logic coherent. Smoothly rack focus from the near beads to the Oracle's face as we approach; no focus hunting.
3.5–4.0s: settle naturally on the supplied closer Oracle last frame and hold it stable. Near peripheral beads become defocused, the woman becomes readable, the kitchen behind remains softly defocused.
Preserve the same woman's identity, seated hand-to-cheek pose, plain moss dress, plain sage apron and tablecloth, cookies and cup. The woman stays still: no lip movement, gestures or change of expression. Furniture remains stationary in world space; screen position changes from camera motion are expected. No hands pulling the curtain.
Muted olive/celadon green room, forest/cyan-green shadows, naturally warm skin, small amber practical accent. Retro 35mm lens softness and subtle grain, restrained highlights, no overall yellow wash or sharpened floral/stone detail.
Single shot, no cuts, morphing, flashes, particles, captions, watermark, looping or reverse motion. No audio. Output portrait H.264 MP4, 30 fps. Start and end on the provided compositions; use one consistent output framing for both endpoints.
```
