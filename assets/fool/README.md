# The Fool

定位：充满好奇、荒诞而外放的局外人。与 Jester 的机敏戏剧面具区分，使用真实成年漫游者形象。

当前选用 master-v3.png：夸张歪纸冠、睁大的眼睛、张嘴笑、前倾和摊手，把小花当话筒。复古灰紫／青绿色、浅景深。master-v1.png 是被反馈为“太冷静”的初稿，仅保留作对比。

图片使用内建 image_gen 生成。运行时图片为 ../../ios/JEV/Resources/Media/fool-master.png。深度数据使用既有 Core ML 工具独立计算，不修改 RGB 图像；实际结果见配套验收记录。

## 初稿提示词

```text
Use case: photorealistic-natural.
Asset type: one full-screen portrait scene for the fourth character "The Fool" in a native iPhone oracle app. Target 853x1844, roughly 9:19.5.
Input image 1 is STYLE REFERENCE ONLY: borrow retro cinematic realism, subdued color layering, natural skin, stronger optical depth of field and quiet mood. Do not copy the woman, kitchen, curtains or scene.
Subject: a single adult male wanderer in his late twenties with slightly tousled dark hair, a gentle curious half-smile and an open unguarded gaze. The Fool is an imaginative outsider, innocent, lightly absurd and quietly poetic, not sinister and not a mocking clown. He wears a small handmade uneven bone-white PAPER CROWN with three simple points, a plain faded dusty-lavender oversized wool coat over plain charcoal clothes, and worn simple shoes. No patterned costume, bells, face paint, theatrical mask or circus styling. He sits relaxed sideways on a very simple wooden stool in a quiet abandoned conservatory, looking towards camera. One relaxed hand holds a single modest white flower as though it were a grand discovery, the other rests naturally on his knee. Hands anatomically natural. No other props.
Scene: dim intimate old conservatory with a few broad soft shapes of green glass and an indistinct arched opening behind him. Weathered but uncluttered; no dense foliage, rubble, intricate architecture or flowers everywhere. Near foreground is softly defocused smooth dark floor.
Composition: eye-level camera. Whole character and stool grounded with believable contact shadows; complete crown and relaxed body silhouette. Face at about 30% image height, clear at phone size, main group in upper-middle two-thirds. Top 12% breathing room, bottom 30% quiet dark floor/shadows for live UI. Generous crop-safe room around head and shoulders. No physical frame around image.
Color/light: layered desaturated lilac-grey cloth, petrol/teal-green shadows and neutral warm skin, a small pale late-afternoon highlight through glass. Avoid overall yellow/sepia wash. Dark but retain atmospheric detail.
Optics/materials: shot on vintage 35mm cinema film, eyes readable with gentle lens softness, background strongly optically defocused and near floor soft, restrained fine low-contrast grain and smooth highlight rolloff. Plain broad fabric folds and quiet matte surfaces; no sharpened wool fibers, busy grain, cracks, etched details or HDR look.
No text, letters, title, tarot-card border, numbers, logos, watermark, interface, collage, neon, magic glow, floating objects, cartoon or horror. A grounded cinematic portrait, emotionally distinct from a sly theatrical Jester mask.
```

## 当前夸张版提示词

```text
Use case: precise-object-edit / identity-preserve.
Input image 1 is The Fool's first draft. User finds him much too calm and wants a MUCH MORE EXAGGERATED character. Make a bold expressive V2, not a subtle adjustment.
Keep the same adult man's facial identity, photographic retro conservatory setting, dusty lavender / teal-green color family, portrait 853x1844 and real cinematic medium.
PERFORMANCE: transform the serene sitter into an exuberantly absurd, eccentric Fool. He leans enthusiastically toward camera from his stool, head cocked distinctly to one side. Both eyes very wide open, one eyebrow dramatically raised, mouth OPEN in a broad spontaneous delighted laugh so teeth are naturally visible, animated cheeks and laugh lines. Strong readable theatrical facial expression at thumbnail size; not a small smirk, not a calm fashion pose, not menacing or horror. This is a playful grown man delighted by his own impossible idea.
His simple handmade paper crown is comically OVERSIZED and crumpled, tall uneven points, perched precariously askew, but entire crown visible within crop-safe canvas. His plain dusty-purple coat is absurdly oversized with big broad lapels and loose sleeves, NO busy pattern or tiny fabric texture.
POSE/PROP: he holds the one tiny white flower directly below his mouth, solemnly treating it as a microphone while laughing, fingers natural around stem. His other hand makes a broad open-palmed flourish toward viewer with five natural fingers, like presenting a ridiculous discovery. Body and shoulders asymmetrical, weight visibly grounded on stool, feet firmly plausible. One muted oxblood sock peeks out to give a small witty color contrast. Exactly two arms, two hands, two legs.
Composition: crown/head and expression in upper-middle, face about y30%. Hands not covering face. Complete crown, crop-safe hands. Quiet dim lower third for live UI; no random new props. Retain old conservatory only as strongly defocused teal-green shapes. Broad soft floor gradients.
Vintage 35mm lens, soft film highlights and gentle fine grain; face readable without crunchy digital sharpening. Natural warm skin, muted lilac coat, cool green shadows. Plain low-frequency materials and pronounced shallow depth of field. Photorealistic human performance, NOT a cartoon, doll or distorted anatomy.
NO text, words, numbers, tarot-card border, painted clown makeup, theatrical mask, bells, logos, watermark, UI, neon, horror or collage. Exaggeration must come from unmistakably larger expression, gesture, leaning pose and ridiculous paper crown.
```


## 下半身修正 · 当前采用 master-v3.png

用户指出 V2 腿部数量异常。V3 重做下半身为两条不交叉的腿、两只脚分别落地，保留表情、纸冠、花和摊手动作。V2 仅作失败版本归档，不再用于应用。画廊的 V2 按钮代表整套视觉风格，其中 The Fool 展示本次最新 V3 修正图。

```text
Use case: precise-object-edit.
Input image 1 is the current The Fool portrait to FIX. User identified incorrect leg count. Change ONLY lower-body anatomy and coat arrangement around thighs/legs. Preserve exact face, huge laughing expression, wide eyes, tilted paper crown, head, torso, arms, hands, flower, camera, palette, lighting, background and full 853x1844 canvas.
ANATOMY CORRECTION IS THE SOLE PRIORITY:
The man is seated upright on the same stool with EXACTLY TWO LEGS, UNCROSSED, and EXACTLY TWO SHOES, both clearly planted on the floor. Replace ALL existing tangled/crossed trousers and legs below the pelvis; do not retain any old leg shapes.
There is one left thigh connected to one left knee and ONE straight lower leg ending in ONE shoe on image-left; one right thigh connected to one right knee and ONE straight lower leg ending in ONE shoe on image-right. Knees naturally about shoulder-width apart, both shins descend down to floor with a visibly clear gap of background between them. BOTH soles at the same plausible floor level. No lifted foot, no crossed knee, no third shin, no extra trouser tube, no detached foot.
Use plain low-texture charcoal trousers so every limb is easy to count. Drape the oversized dusty-purple coat to the OUTSIDE of the two legs and along stool sides, leaving both trouser silhouettes clearly readable. No thick folded coat shape hanging centrally that resembles another leg. Stool support should be a clearly wooden structure behind the two human legs, not an extra trouser-like limb.
The final person has exactly one head, two arms, two hands, two legs and two feet. Natural plausible pelvis-to-thigh continuity and seated weight. Keep the rest of the image unchanged, including exaggerated playful energy and film softness.
No text, UI, watermark, montage, new props, or change in facial identity.
```
