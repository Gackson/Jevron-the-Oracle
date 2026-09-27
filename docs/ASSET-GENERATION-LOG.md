# JEV 素材生成记录

2026-09-27。使用内建 image_gen 生成。原始需求见 ASSET-PROMPTS.md。
以下是实际提交的提示词。采用完整母图作为当前应用素材；分层候选单独保存到 assets/review。

## entrance-open (also oracle-master)

```text
Use case: photorealistic-natural.
Asset type: final frame of a portrait entrance video and native iPhone full-screen scene. Single portrait image, target 1440x3120, 9:19.5 aspect.
Scene: viewed through a modest old doorway into a quiet intimate kitchen sitting room. A beaded curtain parted to BOTH extreme sides, amber and dark wooden beads on plausible fine strings. Ordinary tactile beads, no magic.
Subject: a calm older woman in a simple apron, seated comfortably on a chair beside a small table with a plate of cookies. Warm, unhurried, quietly knowing presence of the Oracle in The Matrix, natural face, relaxed hands, lived-in clothing. Minimal furniture.
Composition: locked level camera outside doorway, straight verticals, real room depth. Face at about 38 percent of image height, clearly readable at phone size. Woman/chair/table group within central 70 percent width. Top 12 percent breathing room, lower 32 percent quiet dim floor and shadows for live app text. Doorframe and beads peripheral foreground. Full continuous scene, generous crop margin.
Light: restrained warm side light, dim cooler doorway, warm grey-black, tobacco brown, bone white. Rich visible shadows, realistic skin/cloth, subtle photographic grain, center sharp and only subtly soft periphery.
No text, letters, logos, watermarks, UI, border, collage, heavy blur, lens warp, fog, neon, runes, particles, fantastical accessories or excessive props. This image is the locked reference for subsequent entrance and Oracle assets.
```

## closed

```text
Use case: precise-object-edit. Input image 1 is the edit target, the locked open-curtain Oracle room. Close ONLY the existing beaded curtain across the doorway: same amber and dark wooden bead strands now hang vertically as a naturally dense curtain across the entire doorway. Small gaps allow only a faint impression of the seated woman and warm room. Preserve EXACTLY full 853x1844 canvas, camera, lens, crop, room geometry, woman identity, pose, furniture, light, color and exposure behind the beads. Do not redesign or shift anything behind the curtain. Strands identical bead scale/material, physically connected. Lower third visually quiet and dim for live introductory text. No words, logos, UI, hands, new characters or props. Single full canvas PNG, no border.
```

## stone

```text
Use case: photorealistic-natural. Input image 1 is STYLE REFERENCE ONLY for photographic realism, shadow detail, palette restraint and portrait aspect; do not copy its room or woman. Make a single full-screen portrait iPhone scene at 853x1844, aspect 9:19.5. One severe upright black monolith in austere silent stone chamber, complete rectangular undecorated silhouette, physically grounded and massive, slight angle showing two planes. Monolith extends from y=22% to y=66%, centered upper-middle, leaving top 12% and entire lower 32% visually quiet. Quiet architecture recedes behind it; low stone floor across bottom third, no small objects. Dense dark mineral surface, subtle grain, believable edges and contact shadow, cool restrained side light distinguishes silhouette from charcoal room. Clear center, softly defocused periphery, natural photographic detail and visible darks. No face, symbols, total blackness, sci-fi metal, floating rocks, galaxy, fog, runes, neon, text, border, UI or watermark.
```

## jester

```text
Use case: photorealistic-natural. Input image 1 is STYLE REFERENCE ONLY for photographic realism, shadow detail and aspect. New separate scene, no kitchen or woman. Single portrait iPhone scene at 853x1844, aspect 9:19.5. A single complete asymmetric theatrical mask on a discreet dark stand in intimate shadowed theatrical alcove. One subtly raised eyebrow, crooked knowing smile, unsettling wit but not horror. Bone ivory painted ceramic/plaster, worn muted oxblood details and charcoal shadows. Mask occupies upper-middle y=25%-55%, complete intact silhouette, slightly tilted, clear at phone size. Stand and minimal heavy dark fabric establish real depth. Top 12% breathing room, bottom 32% quiet dim soft fabric shadows for UI. Soft directional light, restrained natural wear, controlled highlights, visible shadow details. Center clear, periphery gently softer. No comic-book villain makeup, costume ornaments, floating magic, blood, bells, fine lace, particles, neon, words, logos, frame, watermark or UI.
```

## oracle-background

```text
Use case: precise-object-edit. Input image 1 is the exact edit target. Create a clean opaque background plate from this master. Remove ONLY the entire seated woman, her chair, her entire small table including cloth and every tabletop object (cookies, cup, vase), and the foreground bead strings on both sides. Reconstruct the hidden kitchen walls, furniture behind, floor and rug with matching perspective, materials and illumination. Remove residual silhouettes and subject-specific contact shadows. Preserve full 853x1844 canvas, crop, camera, doorframe and every unaffected background pixel. No new objects, no altered light. Output one full opaque PNG, no holes or duplicate subject.
```

## oracle-subject

```text
Use case: background-extraction. Input image 1 is exact edit target, a locked master. Extract ONLY the seated woman, her entire chair, the small table including cloth, cookies, cup and vase as one rigid group, with natural immediately attached contact shadows. EVERYTHING ELSE must be genuinely transparent alpha: kitchen, floor, doorway and bead curtains fully removed. Full original 853x1844 canvas, exact original pixel position, size, silhouette, identity, expression, hands, pose, clothes, colors, material and illumination. Do not recenter, crop tightly, enlarge, redraw or redesign. Preserve all visible details. Clean alpha edges, no matte halo, no rectangular background, NO drawn checkerboard, no solid color replacing transparency. Single RGBA PNG.
```

## stone-background

```text
Use case: precise-object-edit. Input image 1 is the exact edit target, approved stone master. Preserve full original 853x1844 canvas, camera and crop. Remove ONLY the entire black monolith and its object-specific cast/contact shadow. Reconstruct the wall and floor hidden behind it with exact matching stone texture, perspective and lighting. Keep all unaffected surroundings unchanged. Output full opaque clean background, no holes, residual silhouette, duplicate object or new props. No text, logo, border, UI or watermark.
```

## stone-subject

```text
Use case: background-extraction. Input image 1 is the exact edit target, approved stone master. Preserve full original 853x1844 canvas, camera and crop. Extract ONLY the entire monolith and immediately adjoining soft contact shadow on genuine transparent alpha. Remove entire room and floor, preserving exact full canvas position, size, silhouette, both stone planes, edges, mineral texture and light. Do not recenter, scale, redraw or crop. Single RGBA PNG, no solid backdrop and NO painted checkerboard. No text, logo, border, UI or watermark.
```

## jester-background

```text
Use case: precise-object-edit. Input image 1 is the exact edit target, approved jester master. Preserve full original 853x1844 canvas, camera and crop. Remove ONLY the entire mask and its complete stand including stem and round base and their residual shadows. Reconstruct hidden alcove and fabric folds in matching perspective, texture and lighting. Keep unaffected areas exact. Full opaque clean background plate, no mask/stand residue, holes or new props. No text, logo, border, UI or watermark.
```

## jester-subject

```text
Use case: background-extraction. Input image 1 is the exact edit target, approved jester master. Preserve full original 853x1844 canvas, camera and crop. Extract ONLY the entire mask and complete stand including stem and round base, together on genuine transparent alpha. Remove alcove and all fabric. Keep exact original canvas position, size, silhouette, tilt, asymmetry, smile, surface details and lighting. Eye holes truly transparent where background is visible. Do not recenter, crop, enlarge or redraw. Single RGBA PNG with clean alpha edges, no matte, no solid color and NO painted checkerboard. No text, logo, border, UI or watermark.
```

## oracle-foreground

```text
Use case: background-extraction. Input image 1 is the exact edit target, approved oracle master. Preserve full original 853x1844 canvas, camera and crop. Extract ONLY the amber and dark wooden beaded curtain strands at BOTH extreme sides. Remove everything else, including doorframe, woman, kitchen and floor, to genuine transparent alpha. Keep each original bead and string in exact original location, size, shape, color, lighting and focus. No new beads, no repositioning, no crop, no solid backdrop, NO painted checkerboard. Single RGBA PNG. No text, logo, border, UI or watermark.
```

## oracle-subject-v2

```text
Transparent cutout EDIT, not a new rendering. Source is full 853x1844 image. Delete background in place while preserving subject pixels spatially. Keep woman, chair, table with all tabletop objects. Exact geometry anchors: woman's hair begins approximately x315 y420; her face center x461 y531; chair left starts x190 y705; lowest shoe ends near x475 y1420; table top starts x526 y781, table reaches right edge near x802. Whole group's bounding box approximately x188 y420 to x816 y1427. TRANSPARENT MARGINS: first 419 rows remain empty alpha; last 416 rows remain empty alpha. Woman must NOT be enlarged or moved up. Keep the original dim exposure, original identity and every visible cloth detail. Remove room, floor, bead curtains and doorway only. Output genuine RGBA alpha at exact full source dimensions, no checkerboard. No re-centering, no tight cropping, no redesign, no added light.
```

## stone-subject-v2

```text
Transparent cutout EDIT, not a new rendering. Source is full 853x1844 image. Delete room/floor pixels IN PLACE while preserving monolith pixels and coordinates. Exact monolith polygon anchors approximately (216,230), (550,183), (633,236), (637,1136), (550,1158), (216,1140). Keep these positions and original dark natural mineral texture EXACTLY. Top 182 rows fully transparent and lower 670 rows transparent except tiny soft contact shadow at base. The monolith must NOT be moved down or enlarged, nor retextured. Remove only room and floor; alpha everywhere outside object and immediate contact shadow. Output full 853x1844 RGBA PNG, genuine alpha, no checkerboard, no solid backdrop, no crop or re-centering.
```

## jester-subject-v2

```text
Use case: background-extraction. Exact 853x1844 master image is the edit target. Transparent cutout, DELETE background in place, no new rendering. Preserve original mask silhouette and pixel placement: mask bounding box approximately x162 y271 to x677 y976, stand stem x391 y953 to x427 y1183, round base x234 y1181 to x591 y1329. Full group bounding box x162 y271 to x677 y1329. The first 270 rows and last 510 rows are entirely transparent. Keep original dark exposure, texture, colors and every detail. Remove alcove and fabric only to genuine alpha; transparent eye holes. Do NOT enlarge, recenter, change mask expression, brighten or retexture it. Output full 853x1844 RGBA PNG, no solid backdrop, no checkerboard.
```

