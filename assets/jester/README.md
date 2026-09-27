# The Jester · 真人面具版

当前选用 master-v3.png。由原本独立陈列的面具，改为真实成年演员佩戴面具；可见眼睛、头发、颈部与双手。暗红外套、骨白面具、冷青黑背景，前倾托腮、歪头的狡黠姿态。保留复古镜头质感和浅景深。

目视核对：面具贴合人脸；两只手、两条不交叉的腿、两只鞋；头顶与两侧留有手机裁切余量。旧版 master-v1.png / master-v2.png 与旧深度保留作对比。

图片通过内建 image_gen 制作。角色 manifest 记录完整二维母图；应用的空间效果另外加载与母图 SHA256 匹配的 jester-scene.depth，使用现有 Core ML 工具离线计算，不修改 RGB 像素。

## 初次生成提示词

```text
Use case: photorealistic-natural / compositing.
Asset type: JEV "The Jester" character scene, full portrait 853x1844 approximately 9:19.5.
Input image 1: reference for the EXISTING bone-ivory and oxblood asymmetric theatrical mask, retro film finish and theatrical alcove palette. Transform the concept from a freestanding mask into a REAL LIVING ADULT PERSON WEARING the mask. Remove the display stand and pedestal entirely.
Subject: a real slender adult theatrical performer around 35-45, medium-length casually swept dark hair, neck, ears and both hands visibly human. They WEAR a face-sized version of the reference mask physically fitted to their own face, secured by a discreet dark strap. Mask not hovering, not held in hand, not oversized sculpture. Real intelligent eyes visible naturally behind eyeholes, dark hair at temples, skin at neck and wrists. The mask retains bone ivory, one broad muted oxblood asymmetric patch, a raised eyebrow and crooked knowing smile; simplify scratches and ornaments, no dense crackle.
Body/pose: seated on a simple low dark wooden chair in the theatrical alcove, shoulders tilted asymmetrically, head cocked slightly toward viewer, body leaning forward with conspiratorial playful intelligence. One hand loosely supports the chin/mask edge in a skeptical knowing gesture; the other rests open and casually on one knee. Natural anatomical fingers. Exactly two arms, two hands, TWO UNCROSSED legs, two shoes visibly grounded. Two knees separated, no crossed-leg tangles or extra limbs. Whole human silhouette clear. This is a witty trickster who notices your contradictions, not a horror villain, clown or serene mannequin.
Clothes: plain worn muted burgundy tailored coat over charcoal shirt and plain dark trousers, an understated off-white loose collar. Broad clean fabric folds, no busy pattern, no harlequin diamonds, lace, bells, sequins, crown, makeup or ornate costume. Hands/neck show real skin; body must unmistakably read as a person, not a porcelain doll or fully armored figure.
Environment: shadowy intimate theatrical backstage alcove with a broad dark wine/aubergine velvet curtain to one side and muted cool petrol-green/charcoal wall beyond. Minimal furniture and NO extra props. Smooth dark floor with very quiet texture. Scene has coherent real depth.
Framing: locked eye-level portrait, complete head/mask, visible torso, hands, legs and chair. Face at y~30%, not too small; generous head margin and crop-safe hands. Bottom 25-30% low contrast with soft foreground shadow for app UI. Top 12% breathing room. No tarot border or graphic frame.
Light/color/optics: neutral warm ivory mask and natural skin, dark burgundy clothing, cool teal-black ambient shadows; soft directional side light. NO overall yellow/sepia wash. Real vintage 35mm cinematic photography, gentle lens softness and subdued fine grain, soft highlights. Focus on mask and eyes, background strongly optically defocused, near floor softly blurred. Avoid crunchy microcontrast, etched textures and sharp fabric fibers.
No text, logos, watermark, UI, collage, magic particles, neon, fog clouds, blood, horror, recognizable comic-book villain or cartoon. One coherent photograph of a masked PERSON.
```

## 竖屏构图调整

```text
Use case: precise-object-edit, composition outpaint.
Input image is the selected masked HUMAN Jester. Preserve his exact identity, wearable mask, hair, sly tilted head, both hands/pose, burgundy coat, two uncrossed legs, exactly two shoes, stool, colors and film look.
PRIMARY CHANGE: reframe as a MUCH TALLER phone wallpaper 9:19.5, target canvas 853 pixels wide by 1844 pixels high. NOT a 9:16 portrait. Pull camera back a little and extend the simple dark scene above and below. The person must be fully inside the central crop-safe region. Top of hair at y=18%, mask/eyes around y=30%, boots finish around y=80%. Leftmost coat/hand stays within x=14%, rightmost knee/arm within x=86%. Do not stretch the person's anatomy.
Top 12-15% quiet defocused dark alcove; bottom 20-25% quiet DARK smooth floor shadow with no busy texture, brightest reflection or prop. Preserve the intimate photographic person, do not reduce him into a tiny full room shot. Extra side space and simple lower ground are intentional live-UI safe areas.
Soften nearest floor microtexture into broad shadow gradients and background into cool petrol-green / charcoal bokeh. Keep the face/mask readable. Maintain dark wine-red curtain, neutral bone mask, warm real skin, subtle grain. No extra body parts, changes to hands/face, text, UI, border, new objects or watermark. Single continuous full-bleed tall image.
```

真机裁切、持续帧率和陀螺仪手感尚未实测。文件及几何验证见 validation.json。
