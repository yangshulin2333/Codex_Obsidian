---
type: workflow
domain: roblox
status: active
owner: mixed
source: mixed
created: 2026-06-29
updated: 2026-07-27
---

# Prompt 模板

用途：生成或修复 Roblox 单体道具 image-to-3D 参考图。

变量说明：

```text
{ASSET_TYPE}       道具类型，例如 book / sword / chest / potion bottle
{ASSET_NAME}       道具名称
{STYLE}            风格，例如 Roblox fantasy RPG prop
{MATERIALS}        材质分区
{CORE_FEATURES}    核心识别点
{SIDE_TERMS}       侧面语义，例如 spine/page edge 或 blade edge/back edge
{OUTPUT_USE}       后续用途，例如 Tripo / Hunyuan image-to-3D
{STYLE_DNA}        视觉语言锁：造型、材质、颜色、块面、装饰密度
{PART_INVENTORY}   关键零件 ID、固定数量、层级和所属表面
{SURFACE_OWNER}    当前视图中正面、背面、近侧面、远侧面的归属
{FRONT_RAIL}       顶/底视图中对应正面的外轨
{BACK_RAIL}        顶/底视图中对应背面的外轨
```

## 通用负面 Prompt

```text
people, hands, table, desk, background scene, open object unless requested, readable letters, English text, Chinese text, numbers, watermark, logo, floating particles, smoke, dramatic glow, magic circle background, complex lighting, cropped object, cut-off edges, strong perspective, wide angle, tilted camera, fake clasp, glued-on buckle, floating parts, side protrusions, unexplained side hardware, game icon composition, impossible camera geometry, stitched-together views, both opposite side faces visible, both top and bottom visible, far-side decoration fully visible, duplicated ornaments, changed part count, unregistered crystal, decorated end cap, front relief copied onto back rail
```

## 通用风格基底

```text
{STYLE_DNA}, single closed or complete prop object, stylized game-ready asset, slightly chunky proportions, clean readable geometry, centered single object, full object visible, plain white background, polished stylized 3D concept art, no readable text. Preserve this exact key-part inventory across all views: {PART_INVENTORY}.
```

## 正面模板

用于 `front.png`。

```text
Use case: stylized-concept
Asset type: Roblox image-to-3D reference, {ASSET_TYPE}, strict front orthographic view
Primary request: Reconstruct the approved effect design as a strict front orthographic reference image for {ASSET_NAME}. This is for 3D modeling reference, not a game icon.
Input role: {EFFECT_IMAGE} is a design anchor for palette, silhouette, core motif, material blocks, and attachment hierarchy. It is not a camera reference and must not transfer its visible side surface into the front view.
Scene/backdrop: perfectly clean white background, no ground plane, no shadow, no scene.
Subject: one complete {ASSET_TYPE}, centered, full object visible. Camera yaw 0, pitch 0, roll 0. Strict front view: only the front face is visible. Hide the spine, page edge, top plane, and bottom plane.
Style/medium: polished stylized 3D concept art for Roblox game prop, slightly chunky proportions, simple readable geometry.
Design: {CORE_FEATURES}. Materials: {MATERIALS}. Use bold readable shapes and clear material separation.
Attachment hierarchy: preserve {L1_BASES}, {L2_RELIEFS}, and {L3_CORES}. Every L2/L3 element must visibly connect through a broad L1 mounting base to the main cover. No floating ornament.
Part conservation: preserve exactly {PART_INVENTORY}. Do not add, remove, split, mirror, or duplicate registered parts.
Composition/framing: square 1:1, strict orthographic parallel projection, centered, consistent scale, generous padding.
Constraints: no readable text; no characters; no hands; no table; no particles; no dramatic glow; no smoke; no complex background.
Avoid: copied right page edge from the effect image, visible left spine, visible top or bottom, unexplained side parts, floating parts, perspective distortion, cropped object.
```

## 背面模板

用于 `back.png`。

```text
Use case: stylized-concept
Asset type: Roblox image-to-3D reference, {ASSET_TYPE}, strict back orthographic view
Primary request: Generate a strict back orthographic reference image for the same {ASSET_NAME}. This is for 3D modeling reference, not a game icon.
Scene/backdrop: perfectly clean white background, no ground plane, no shadow, no scene.
Subject: one complete {ASSET_TYPE}, centered, full object visible. Strict back view: only the back face is visible, no front emblem and no large side surface.
Design: match the same design family, colors, materials, and scale as the front view. The back should explain the rear structure and any connection points.
Surface ownership: preserve {SURFACE_OWNER}. Front-only registered parts must not be copied onto the back.
Important: do not add new hardware or side parts that are not visible or explainable in the other views.
Composition/framing: square 1:1, strict orthographic parallel projection, centered, consistent scale.
Avoid: front-only emblem, fake clasp, side protrusions, readable text, perspective distortion, cropped object.
```

## 左侧模板

用于 `left.png` 或资产语义化侧面，例如 `spine_left.png`。

使用前必须已确认该文件的 must-visible / must-hidden 合同。

```text
Use case: stylized-concept
Asset type: Roblox image-to-3D reference, {ASSET_TYPE}, strict left side orthographic view
Primary request: Generate a strict left-side orthographic reference image for the same {ASSET_NAME}. This is for 3D modeling reference, not a game icon.
Visibility contract: must be visible: {LEFT_MUST_VISIBLE}. Must be hidden: {LEFT_MUST_HIDDEN}. Direction-specific counts and positions: {LEFT_DIRECTIONAL_DETAILS}. Do not copy opposite-side-only structures.
Scene/backdrop: perfectly clean white background, no ground plane, no shadow, no scene.
Subject: one complete {ASSET_TYPE}, centered, full object visible. Camera faces the left side directly. Show only the left-side structure and thin front/back edges.
Critical geometry: explain {SIDE_TERMS} clearly. Materials must remain separated: {MATERIALS}.
Important constraints: no floating parts, no unexplained side hardware, no newly invented parts.
Part conservation: only show registered left-side parts from {PART_INVENTORY}; all far-side complete registered parts must remain hidden.
Composition/framing: square 1:1, strict orthographic parallel projection, centered, realistic thickness.
Avoid: front view leaking into side view, strong perspective, cropped object, oversized thickness.
```

## 右侧模板

用于 `right.png` 或资产语义化侧面，例如 `page_edge_right.png`。

使用前必须已确认该文件的 must-visible / must-hidden 合同。

```text
Use case: stylized-concept
Asset type: Roblox image-to-3D reference, {ASSET_TYPE}, strict right side orthographic view
Primary request: Generate a strict right-side orthographic reference image for the same {ASSET_NAME}. This is for 3D modeling reference, not a game icon.
Visibility contract: must be visible: {RIGHT_MUST_VISIBLE}. Must be hidden: {RIGHT_MUST_HIDDEN}. Direction-specific counts and positions: {RIGHT_DIRECTIONAL_DETAILS}. Do not copy opposite-side-only structures.
Scene/backdrop: perfectly clean white background, no ground plane, no shadow, no scene.
Subject: one complete {ASSET_TYPE}, centered, full object visible. Camera faces the right side directly. Show only the right-side structure and thin front/back edges.
Critical geometry: the right-side material and thickness must be clear. Do not let trim, metal, labels, gems, or decorative parts hide the real side structure.
Important constraints: no floating parts, no unexplained side hardware, no newly invented parts.
Part conservation: only show registered right-side parts from {PART_INVENTORY}; all far-side complete registered parts must remain hidden.
Composition/framing: square 1:1, strict orthographic parallel projection, centered, realistic thickness.
Avoid: solid metal side slab unless the object is truly metal, front emblem visible, strong perspective, cropped object, oversized thickness.
```

## 顶部 / 底部模板

用于 `top.png` 和 `bottom.png`。

```text
Use case: stylized-concept
Asset type: Roblox image-to-3D reference, {ASSET_TYPE}, strict {TOP_OR_BOTTOM} orthographic view
Primary request: Generate a strict {TOP_OR_BOTTOM} view for the same {ASSET_NAME}. This is for 3D modeling reference, not a game icon.
Scene/backdrop: perfectly clean white background, no ground plane, no shadow, no scene.
Subject: one complete {ASSET_TYPE}, centered, full object visible. Camera faces the {TOP_OR_BOTTOM} side directly. Show the real top/bottom material, edge thickness, and connection relationships.
Endpoint semantics: {CLOSED_END_DESCRIPTION} is the structurally closed or connected end. {OPEN_END_DESCRIPTION} is the free open end and must remain visibly open. Internal layers or the open cavity must continue to that endpoint.
Critical geometry: the visible top/bottom surface must match the object's real structure. Do not turn it into a decorative slab if the object should show layered material, open rim, blade thickness, bottle bottom, or base structure.
Important constraints: no newly invented hardware, no floating parts, no isolated metal plates. Separate protectors attached to opposite outer surfaces must not merge into a continuous U-shaped frame, C-shaped frame, end plate, cap, or bridge across {OPEN_END_DESCRIPTION}.
Rail ownership: {FRONT_RAIL} may show the side-profile height of registered front relief. {BACK_RAIL} must show only registered back relief or remain nearly flat. Never duplicate front relief onto both rails.
Part conservation: preserve exactly the visible subset of {PART_INVENTORY}; unregistered end-cap crystals, windows, spikes, straps, and plates are forbidden.
Composition/framing: square 1:1, strict orthographic parallel projection, centered, realistic thickness.
Avoid: sealed open end, continuous end cap, bridged corner protectors, wrong top material, fake clasp, unexplained hardware, perspective distortion, cropped object.
```

书本类资产的变量映射示例：

```text
{CLOSED_END_DESCRIPTION} = the left bound spine end
{OPEN_END_DESCRIPTION} = the right free page fore-edge
Book-specific lock: page layers must visibly reach the right endpoint. The upper-cover and lower-cover corner protectors may be present only as two independent pieces with a clear gap between them. No vertical metal plate may cover the page fore-edge.
```

## 左 45 度模板

用于 `left45.png`。

继承已确认的左侧可见性合同。

```text
Use case: stylized-concept
Asset type: Roblox image-to-3D reference, {ASSET_TYPE}, left 45 degree modeling view
Primary request: Generate a left 45 degree auxiliary modeling view for the same {ASSET_NAME}. This is for image-to-3D modeling reference, not a dramatic game icon.
Scene/backdrop: perfectly clean white background, no ground plane, no shadow, no scene.
Subject: one complete {ASSET_TYPE}, centered, full object visible. Use orthographic parallel projection, yaw about -30 degrees, pitch 0 degrees, roll 0 degrees. Show only the front and left side together.
Visibility lock: the left side is the near side. The right-side outer surface is the far side and must be occluded by the object. Do not show the top or bottom surface.
Design: match the accepted front and left-side designs. Do not invent new parts.
Part conservation: preserve the visible subset of {PART_INVENTORY}; complete far-side registered ornament count must be zero.
Important constraints: no floating parts, no unexplained side hardware, no exaggerated perspective.
Composition/framing: square 1:1, clean auxiliary angled view, orthographic parallel projection, centered, generous padding.
Avoid: game icon composition, strong perspective, floating parts, fake hardware, cropped object, visible far-side decoration, front plus both side faces, visible top or bottom plane.
```

## 右 45 度模板

用于 `right45.png`。这是最容易误导 image-to-3D 的视图之一。

继承已确认的右侧可见性合同。

```text
Use case: stylized-concept
Asset type: Roblox image-to-3D reference, {ASSET_TYPE}, right 45 degree modeling view
Primary request: Generate a right 45 degree auxiliary modeling view for the same {ASSET_NAME}. This is for image-to-3D modeling reference, not a dramatic game icon.
Scene/backdrop: perfectly clean white background, no ground plane, no shadow, no scene.
Subject: one complete {ASSET_TYPE}, centered, full object visible. Use orthographic parallel projection, yaw about 30 degrees, pitch 0 degrees, roll 0 degrees. Show only the front and right side together.
Visibility lock: the right side is the near side. The left-side outer surface is the far side and must be occluded by the object. Do not show the top or bottom surface.
Far-side silhouette lock: the left silhouette may show only the thin turning edge of the front face. It must not form a separate continuous side-material strip, and the count of complete far-side ornaments must be zero.
Critical geometry: the visible right side must match the object's real materials and thickness. Do not paint it as a decorative slab if the real object should show layers, edges, blade thickness, bottle wall, page stack, or base structure.
Design: match the accepted front and right-side designs, but simplify the 45 degree view for modeling clarity. Keep decoration readable without hiding the side structure.
Part conservation: preserve the visible subset of {PART_INVENTORY}; complete far-side registered ornament count must be zero.
Important constraints: no newly invented side hardware, no floating parts, no exaggerated side protrusions. Trim or corner caps must not hide the core side material.
Composition/framing: square 1:1, clean auxiliary angled view, orthographic parallel projection, centered, realistic thickness.
Avoid: solid side slab, fake clasp, side protrusions, perspective distortion, game icon composition, cropped object, visible far-side decoration, front plus both side faces, visible top or bottom plane.
```

## 修复 Prompt 模板

用于局部修单图。

```text
Use case: precise-object-edit
Asset type: Roblox image-to-3D reference repair
Input image: use the displayed image as the edit target.
Primary request: Edit only the problem area: {PROBLEM}. Keep the object centered and otherwise the same design.
Keep unchanged: the main design, material style, scale, clean white background, orthographic or orthographic-like view, and all unaffected edges.
After repair: {EXPECTED_RESULT}.
Constraints: no new objects, no readable text, no characters, no hands, no table, no particles, no glow, no smoke, no perspective change, no crop or rotation.
Avoid: changing the whole design, adding new side hardware, hiding the real side/top material, making the side or top a wrong solid slab.
```

## 相机畸形修复模板

用于“细节好看，但多个相反表面被拼进同一张图”的整图重构。

```text
Use case: precise-object-edit
Asset type: image-to-3D reference camera repair
Input image: use the displayed image as the design reference and edit target.
Primary request: re-render the same asset with physically coherent camera geometry; do not merely erase one decoration.
Camera lock: orthographic parallel projection, yaw {YAW}, pitch {PITCH}, roll 0.
Visibility lock: show only {VISIBLE_FACES}. The far-side surface {HIDDEN_FACES} must be occluded by the object.
Opposite-face lock: never show both left and right outer surfaces; never show both top and bottom surfaces.
Far-side silhouette lock: {HIDDEN_FACES} may show at most one extremely thin turning edge. It must not form a separate material band or side plane. Complete far-side ornament count must be zero.
Preserve: {CORE_FEATURES}, materials, palette, centered scale, clean silhouette.
Constraints: straight parallel structural edges, realistic thickness, full object visible, white background.
Avoid: impossible camera geometry, stitched-together views, far-side complete decoration, game-icon perspective, exaggerated thickness, floating parts.
```
