---
type: template
domain: roblox
status: active
owner: mixed
source: self
created: 2026-08-04
updated: 2026-08-12
---

# 魔法剑图像生成 Prompt 模板

## 使用规则

- `{DESIGN_LOCK}` 替换为已确认的几何、配色和关键零件。
- `{REFERENCE_IMAGE}` 指同一把剑的已通过视图。
- 每次只生成一个明确视图，不在一张图中排版多视图。
- 正式视图以结构一致性优先，不追求宣传插画效果。
- Prompt 不能用模糊的 `side view` 替代精确相机方向。
- 生成 `left/right/left45/right45` 前，Codex 必须主动询问并复述每个输出的 `{MUST_VISIBLE}`、`{MUST_HIDDEN}`、方向性结构数量/位置与 `{OCCLUSION_RELATIONSHIPS}`；用户确认并写入设计锁后才可使用对应模板。
- 不以“是否对称”决定工作流。四个侧向输出默认分别生成；只有用户明确授权指定输出对共用几何且设计锁留有授权记录时，才允许镜像或复用。
- top/bottom 只允许引用当前资产的 front、严格 side 和当前资产的真实 3D 代理渲染。
- 禁止把其他资产的 top/bottom 当布局样例；模型会继承其轮廓语法，而不只继承相机。
- 禁止把失败候选图作为相机或表面归属修复参考。相机、轴向或身份错误必须从纯净来源重新生成。
- top 与 bottom 独立生成，不互相作为图像参考；二者只共享 `{AXIAL_XZ_LOCK}` 中的数值和零件定义。

## 通用正向基底

```text
Roblox fantasy RPG magical sword prop, one complete single sword, closed rigid game-ready object, stylized chunky proportions, clean readable silhouette, large coherent geometry, clearly modeled thickness, connected parts, polished 3D concept reference, centered on a clean pure white background, no cast shadow, no floor, same exact sword design as the reference, same proportions, same component count, same materials and colors, no readable text.
```

## 通用负面 Prompt

```text
character, person, hand, arm, pedestal, table, floor, environment, scene, dramatic lighting, fog, smoke, floating particles, aura, halo, magic circle, floating fragments, chain, thin wire, readable text, logo, watermark, cropped object, duplicate sword, open weapon, bent sword, fisheye, wide angle, strong perspective, tilted camera, dutch angle, game icon composition, inconsistent design, changed proportions, extra gemstones, missing parts, glued-on decoration, paper-thin guard, disconnected guard, stretched geometry, opposite surfaces visible at the same time.
```

## effect.png

```text
Create a clean concept reference for {ASSET_NAME}.
{DESIGN_LOCK}

Near-orthographic strict front presentation, sword vertical with tip up, camera centered at the middle of the sword, yaw 0 degrees, pitch 0 degrees, roll 0 degrees. Show the entire sword with even margins. The front surface is readable; the back is fully hidden; side thickness is only a very narrow edge. Emphasize large connected armor plates, embedded gems, real guard thickness and Roblox-readable geometry. This is a modeling reference, not a game icon.
```

只有人工明确确认效果图后，才继续生成正式视图。

## front.png

```text
Using {REFERENCE_IMAGE}, reproduce the exact same magical sword in a strict orthographic front view.
Parallel projection, camera on +Z looking toward -Z, yaw 0, pitch 0, roll 0. Show only the complete X by Y front projection. Keep identical total length, blade width, guard width, handle length, pommel position, materials, colors, component count and embedded-gem placement. The back surface is completely hidden. Side faces appear only as extremely thin edge lines. Center the full sword on a square pure white canvas.
```

## back.png

```text
Using the approved front view and {DESIGN_LOCK}, show the exact same sword in a strict orthographic back view.
Parallel projection, camera on -Z looking toward +Z. Match the exact X by Y silhouette and all major proportions from the front. Use a structurally credible closed rear plate. Simplify front-only emblems when required by the design lock. Do not copy the complete raised front gem or front emblem onto the back. Do not reveal side faces beyond thin edge lines.
```

## left.png

```text
Using the approved design, show the exact same sword in a strict 90-degree orthographic left side view.
Parallel projection, camera on -X looking toward +X. Display only the Z by Y engineering side silhouette. The blade must collapse to its real narrow thickness and bevel profile. The guard must show front-to-back depth, not its wide front-facing wings. The gem sockets, handle and pommel must also become narrow side profiles. No 3/4 angle and no readable front decoration.

This output's confirmed visibility contract:
Must be visible: {MUST_VISIBLE}
Must be hidden: {MUST_HIDDEN}
Directional structures, exact counts and positions: {DIRECTIONAL_STRUCTURES}
Occlusion relationships: {OCCLUSION_RELATIONSHIPS}
Do not add, remove, relocate, reveal or hide any directional structure contrary to this contract.
```

## right.png

默认独立生成。只有设计锁中存在用户对 `left.png -> right.png` 的明确授权记录时，才可镜像或复用；否则镜像结果记为 `UNCONFIRMED_SIDE_MIRROR`。

```text
Using the approved design, show the exact same sword in a strict 90-degree orthographic right side view.
Parallel projection, camera on +X looking toward -X. Display only the Z by Y engineering side silhouette. Do not reveal a wide front blade face, expanded guard wings or the full front gem face.

This output's confirmed visibility contract:
Must be visible: {MUST_VISIBLE}
Must be hidden: {MUST_HIDDEN}
Directional structures, exact counts and positions: {DIRECTIONAL_STRUCTURES}
Occlusion relationships: {OCCLUSION_RELATIONSHIPS}
Do not infer this view from the opposite side. Do not add, remove, relocate, reveal or hide any directional structure contrary to this contract.
```

## top.png

允许的图像输入：当前资产已通过的 `front.png`、一张严格 side，或当前资产真实 3D 代理的 top 渲染。禁止输入其他资产端视图、当前资产失败稿和当前资产 `bottom.png`。

```text
Using only approved same-asset references and {AXIAL_XZ_LOCK}, show the exact same sword as a strict orthographic axial top end view.
The camera is on +Y at the sword tip, looking straight down the sword long axis toward the pommel. Parallel projection. Show only the X by Z cross-section stack visible from the tip direction. The visible Y length must be nearly zero. Use the locked blade thickness, guard depth and cross-section layers. Do not show the full sword length, a horizontal front-facing sword, expanded front guard wings, front armor panels, readable gem faces or perspective convergence.

Apply {TOP_END_DEFINITION}. Every front-only component listed in {FRONT_ONLY_COMPONENTS} must be hidden or collapse to a narrow edge. Preserve the actual X-position, curvature and root connection of each guard component; do not replace curved, winged or leaf-shaped parts with generic straight rails. Do not invent a central emblem or socket face. This is a projection of the existing object, not a new horizontal prop design.

Uniformly magnify X and Z together only if required for thumbnail readability. Keep the original X:Z ratio. The cross-section long edge should occupy about 60%-80% of the square canvas.
```

## bottom.png

允许的图像输入与 top 相同，但禁止输入 `top.png`。bottom 必须独立从当前资产纯净来源生成。

```text
Using only approved same-asset references and {AXIAL_XZ_LOCK}, show the exact same sword as a strict orthographic axial bottom end view.
The camera is on -Y at the pommel, looking straight along the sword long axis toward the tip. Parallel projection. Show only the X by Z cross-section stack visible from the pommel direction. The visible Y length must be nearly zero. The pommel end is a solid physically connected cap. A front-facing pommel gemstone may appear only as an extremely thin colored edge if the design lock allows it; never rotate the complete gemstone face onto the axial end.

Apply {BOTTOM_END_DEFINITION}. Every front-only component listed in {FRONT_ONLY_COMPONENTS} must be hidden or collapse to a narrow edge. Preserve the same X positions, Z thicknesses and component roots locked for top, but derive them independently from the same-asset references. Do not copy top pixels, do not invent a different center mechanism, and do not turn this projection into a decorative horizontal bar.

Uniformly magnify X and Z together only if required. Keep the original X:Z ratio and occupy about 60%-80% of the square canvas. Do not show the full sword, front armor, expanded guard wings or deep perspective.
```

## left45.png

```text
Using the approved front and side views, rotate the entire sword as one rigid object by exactly 45 degrees around its Y long axis toward the left.
Keep the camera level and centered with orthographic or extremely weak perspective projection. Every component must share the same rotation: blade, guard, handle, pommel, gems, sockets and all armor plates. Show only the front surface and one near side surface. The back and opposite side remain hidden. Front decorations must be horizontally foreshortened consistently. Do not rotate only the blade while leaving the guard or handle facing the camera.

Apply this confirmed output contract:
Must be visible: {MUST_VISIBLE}
Must be hidden: {MUST_HIDDEN}
Directional structures, exact counts and positions: {DIRECTIONAL_STRUCTURES}
Occlusion relationships: {OCCLUSION_RELATIONSHIPS}
```

## right45.png

默认独立生成。只有设计锁中存在用户对 `left45.png -> right45.png` 的明确授权记录时，才可镜像或复用；否则镜像结果记为 `UNCONFIRMED_SIDE_MIRROR`。

```text
Using the approved front and side views, rotate the entire sword as one rigid object by exactly 45 degrees around its Y long axis toward the right.
Keep the camera level and centered with orthographic or extremely weak perspective projection. Every component shares the same rotation. Show only the surfaces allowed by the confirmed output contract.

Apply this confirmed output contract:
Must be visible: {MUST_VISIBLE}
Must be hidden: {MUST_HIDDEN}
Directional structures, exact counts and positions: {DIRECTIONAL_STRUCTURES}
Occlusion relationships: {OCCLUSION_RELATIONSHIPS}
Do not infer this view from the opposite 45-degree output.
```

## 通用单张修复模板

只适用于相机、轴向、身份和表面归属已经通过后的局部材质或小结构问题。若命中 `TOP_VIEW_OFF_AXIS`、`BOTTOM_VIEW_OFF_AXIS`、`AXIAL_FRONT_FACE_LEAK`、`DESIGN_IDENTITY_DRIFT` 或跨资产参考污染，不得使用此模板，必须丢弃候选并从纯净来源重生。

```text
Edit only the {VIEW_NAME} view of this exact sword.
Keep the approved identity, silhouette, proportions, materials, colors, component count and all unaffected geometry unchanged.

Problem to fix:
{PROBLEM}

Required correction:
{CORRECTION}

Do not redesign the sword. Do not add decorative parts. Do not change another view. Keep a pure white square background and the required camera contract.
```

## 端视图摊宽修复

此类问题属于相机或表面归属失败，不再对失败图执行 edit。将失败稿移入 `失败对照/`，清空失败图引用，然后重新使用 top 或 bottom 的正式模板。第二次仍失败时进入 `AXIAL_BLOCKED`。

重生时补充：

```text
The previous candidate was rejected and is not an input to this generation. Reconstruct the axial projection only from the approved same-asset front view, strict side view and explicit X-by-Z design lock. Do not preserve any layout, rail, emblem, socket or silhouette from a rejected candidate or another asset.
```

## 45 度局部旋转修复

```text
The current 45-degree view rotates only the blade while the guard, handle, gems or pommel still face the camera. Rotate the entire sword assembly as one rigid body around the Y axis. Apply the same yaw to every component and ensure all front-facing decorations receive the same horizontal foreshortening.
```

## 侧视图压扁正面修复

```text
The current side view is a compressed front view rather than a true engineering side view. Replace it with a strict 90-degree Z by Y projection. Hide the broad blade face and expanded guard silhouette. Show only real thickness, bevel depth, socket depth, handle depth and pommel depth.

Reapply the confirmed per-output visibility contract exactly. If the contract is missing, stop with SIDE_VISIBILITY_CONTRACT_MISSING. If an existing candidate conflicts with the contract, discard it as SIDE_VISIBILITY_CONTRACT_BROKEN and regenerate from clean approved references. Never mirror or reuse the opposite output without a recorded user authorization; otherwise stop with UNCONFIRMED_SIDE_MIRROR.
```
