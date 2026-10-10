---
type: workflow
domain: roblox
status: processing
owner: mixed
source: codex
created: 2026-07-07
updated: 2026-08-12
---

# 提示词模板

> [!warning] V2.1 实验覆盖规则
> 当前先生成并确认 `left45.png`，再用 `front.png + left45.png` 两张参考生成 `left.png`。旧模板中的 `collapse into a thin edge` 和 `6%-8% of object height` 不再直接使用，避免纸片化。详见 [[V2.1_稳定图片实验流程]]。

## 侧向可见性合同模板（生成前强制确认）

Codex 必须先询问用户，并逐个文件复述以下内容。用户确认前不得生成 `left.png`、`right.png`、`left45.png` 或 `right45.png`：

```markdown
## [filename] Visibility Contract
- Camera direction / yaw:
- Must be visible:
- Must be hidden or occluded:
- One-sided details: [exact count + position]
- Front-to-back occlusion order:
- Required thickness / connection evidence:
- User confirmation:
```

不要问“它是否对称”来代替合同，也不要从正视图自行决定镜像。镜像必须有用户明确点名的来源文件与目标文件授权，并写入运行记录。

硬停止 / 拒绝代码：

```text
SIDE_VISIBILITY_CONTRACT_MISSING
SIDE_VISIBILITY_CONTRACT_BROKEN
UNCONFIRMED_SIDE_MIRROR
```

## V2.1 组件级深度合同模板

```text
Depth contract:
- Shaft front width: [shaft_W] px; target side diameter/depth: [shaft_D_min]-[shaft_D_max] px.
- Gem front width: [gem_W] px; target side depth: [gem_D_min]-[gem_D_max] px.
- Holder front width: [holder_W] px; target side depth envelope: [holder_D_min]-[holder_D_max] px.
- Tail front width: [tail_W] px; target side depth: [tail_D_min]-[tail_D_max] px.

The camera must be side-on, but the object must keep non-zero physical volume.
Do not flatten the gemstone, holder, shaft, or tail into paper-thin shapes.
```

## V2.1 严格 90°左侧视图模板

输入图必须包含已确认的 `front.png` 和 `left45.png`。

```text
Image 1 is the accepted orthographic front view and locks identity, proportions, colors, materials, and component count.
Image 2 is the accepted orthographic front-left 45-degree view and locks depth, thickness, and front-to-back relationships.

Rotate the exact same object from Image 2 another 45 degrees to reach a true orthographic 90-degree LEFT SIDE VIEW.
The camera is exactly side-on. Do not retain broad front-facing gemstone surfaces.
The object must keep realistic non-zero volume.

[paste component depth contract]
[paste confirmed left visibility contract]

The shaft must retain its cylindrical or elliptical diameter.
The gemstone must show its side body, bevel, or convex thickness, not a colored line.
The holder must retain front-to-back layering and must not collapse into a needle-like silhouette.
The tail must retain its physical volume.

Do not redesign, add, remove, recolor, or replace any component.
Do not use perspective or a 3/4 angle.
Do not make the object as narrow as possible.
```

这些模板用于 Roblox 魔法杖多视图参考图生成。每次使用前，先把具体魔法杖的结构锁和比例锁填进去。

## 通用负面规则

所有视图都必须包含：

```text
Do not redesign the wand.
Do not add or remove parts.
Do not change component count.
Do not change colors or materials.
No extra wings, spikes, chains, cloth, vines, flowers, runes, extra gemstones, magic particles, background props, text labels, watermark, or UI icons.
Clean plain background.
Orthographic projection.
Single object only.
Roblox-style stylized 3D game prop.
```

中文审核含义：

- 不重设计。
- 不增删零件。
- 不改组件数量。
- 不改颜色和材质。
- 不加背景、文字、水印、UI。
- 正交视图。
- 单个道具。

## 结构锁模板

```text
This is one strict multi-view object, not a set of variants.
The AI may only rotate the same wand.

Full object height = 100%.

Proportion lock:
- Top main element: [x%-y%] of total height.
- Top holder / fixing structure: [x%-y%] of total height.
- Metal rings / bands: [count and positions].
- Shaft / grip: [x%-y%] of total height.
- Bottom ornament / tail: [x%-y%] of total height.
- Front maximum width: about [x%] of total height.
- Strict 90-degree side maximum width: about [x%] of total height.
- 45-degree maximum width: about [x%] of total height.

Fixed components:
- 1 [top main element].
- 1 [top holder / fixing structure].
- 1 [shaft / grip].
- [middle ornaments count and positions].
- [metal rings / bands count and positions].
- 1 [bottom ornament / tail].

Fixed colors and materials:
- Top main element: [color + material].
- Metal parts: [color + material].
- Shaft / grip: [color + material].
- Middle gemstone: [color + material].
- Bottom ornament: [color + material].

Side visibility contracts:
- left.png: [must-visible / hidden / counts / positions / occlusion].
- right.png: [must-visible / hidden / counts / positions / occlusion].
- left45.png: [must-visible / hidden / counts / positions / occlusion].
- right45.png: [must-visible / hidden / counts / positions / occlusion].

Mirror authorization:
- Default: not authorized.
- [source -> target + exact user authorization, or none].
```

## 正视图确认模板

用于从参考图裁切或生成 `front.png`。

```text
Create a clean orthographic front view of this exact Roblox-style magic wand.

Use the provided reference as the source of truth.
Keep the exact silhouette, component count, proportions, colors, and materials.

Canvas: 1024x2048.
Object height: about 1720 px.
Centered object.
Plain light background.

The wand must remain a medium handheld magic wand, not a staff, spear, sword, mace, dagger, or bone club.

[paste structure lock here]

[paste common negative rules here]
```

审核重点：

- 如果原图能裁切，优先裁切，不要重画。
- 正视图确认前，不生成其他视图。

## 背视图模板

用于生成 `back.png`。

```text
Generate the strict orthographic back view of the same magic wand shown in the approved front view.

This is the same object rotated 180 degrees around the vertical axis.
Keep the same height, same silhouette, same component count, same material zones, same colors, and same proportions.

The back may show simpler carved details, but it must not become a different wand.
Do not add new decorations.
Do not remove any original structural component.
Do not change the top element shape, holder shape, shaft length, ring positions, or bottom tail.

Canvas: 1024x2048.
Object height: about 1720 px.
Orthographic projection.
Centered object.
Plain light background.

[paste structure lock here]

[paste common negative rules here]
```

审核重点：

- 背面不是新设计。
- 背面可以少一些正面雕刻细节，但轮廓、比例、材质区必须一致。

## 严格 90°左侧视图模板

旧版单参考模板已废止。生成 `left.png` 时必须使用本页顶部的“V2.1 严格 90°左侧视图模板”，并同时输入 `front.png` 与已确认的 `left45.png`。

```text
DEPRECATED: do not generate a 90-degree side view from the front image alone.
Use the V2.1 dual-reference prompt and the component depth contract.
```

硬拒绝：

```text
If the main gemstone still appears as a broad colored front face, reject as SIDE_VIEW_NOT_90_DEGREE.
```

## 严格 90°右侧视图模板

必须使用 `front.png + accepted right45.png + confirmed right visibility contract` 独立生成。只有用户明确授权 `left.png -> right.png` 时才允许镜像，并须记录。

```text
Image 1 is the accepted orthographic front view and locks identity, proportions, colors, materials, and component count.
Image 2 is the accepted orthographic front-right 45-degree view and locks depth, thickness, and front-to-back relationships.

Rotate the exact same object from Image 2 another 45 degrees to reach a true orthographic 90-degree RIGHT SIDE VIEW.
[paste component depth contract]
[paste confirmed right visibility contract]

Do not redesign, add, remove, recolor, replace, or mirror any component unless the recorded user authorization explicitly permits that mirror operation.
```

## 左前 45°视图模板

用于生成 `left45.png`。

```text
Generate the orthographic 45-degree front-left view of the exact same magic wand.

Camera angle: 45 degrees between front view and left side view.
This is the view that may show both front design details and side thickness.
Do not confuse this with left.png, which must be a strict 90-degree side profile.

Keep the same component count, proportions, colors, materials, top element, holder, ring positions, shaft, and bottom tail.

Canvas: 1024x2048.
Object height: about 1720 px.
Orthographic projection.
Centered object.
Plain light background.

[paste structure lock here]
[paste confirmed left45 visibility contract]

[paste common negative rules here]
```

## 右前 45°视图模板

按已确认的 `right45` 可见性合同独立生成。只有用户明确授权 `left45.png -> right45.png` 时才允许镜像，并须记录。

```text
Generate the orthographic 45-degree front-right view of the exact same magic wand.

Camera angle: 45 degrees between front view and right side view.
This is the view that may show both front design details and side thickness.
Do not confuse this with right.png, which must be a strict 90-degree side profile.

Keep the same component count, proportions, colors, materials, top element, holder, ring positions, shaft, and bottom tail.

Canvas: 1024x2048.
Object height: about 1720 px.
Orthographic projection.
Centered object.
Plain light background.

[paste structure lock here]
[paste confirmed right45 visibility contract]

[paste common negative rules here]
```

## top / bottom 风险模板

默认不生成 `top.png` / `bottom.png`。

如果用户明确要求，并接受推断风险，必须先说明：

```text
Top and bottom views cannot be reliably inferred from a 2D front reference only.
They may introduce invented geometry.
Use them only if the target 3D tool explicitly requires them and the user accepts the risk.
```

生成时必须使用：

```text
Strict orthographic overhead view from directly above the complete object.
No perspective.
No angled 3/4 view.
No decorative layout.
No invented new parts.
```

如果看起来不像完整物体从正上 / 正下看，而像重新设计的符号图，必须拒绝。
