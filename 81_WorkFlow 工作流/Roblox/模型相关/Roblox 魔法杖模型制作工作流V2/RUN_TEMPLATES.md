---
type: workflow
domain: roblox
status: processing
owner: mixed
source: codex
created: 2026-07-07
updated: 2026-08-12
---

# 单把魔法杖运行模板

> [!warning] V2.1 实验覆盖规则
> 先填写组件级深度合同和四份侧向可见性合同，再按 `front -> left45 -> left90` 执行。侧视宽度不再按整杖高度比例硬算。镜像默认未授权，详见 [[V2.1_稳定图片实验流程]]。

每处理一把魔法杖，先复制本页模板到该资产目录的 `_docs/` 中，再填具体内容。

## MEASUREMENTS.md 模板

```markdown
# [Asset Name] Measurements

## Source

- Source image:
- Target object:
- Crop file:
- Source crop size:
- Detected source object bbox:
- Source object width / height:

## Normalized Canvas Target

- Canvas: `1024x2048`
- Target object height: about `1720px`
- Target vertical center: `y=1024`
- Target top margin:
- Target bottom margin:

## View Width Records

整杖 bbox 仅用于发现明显异常，不作为侧视真实深度目标。

- `front.png`: target object bbox about `[w]x1720`, about `[x%]`
- `back.png`: target object bbox about `[w]x1720`, about `[x%]`
- `left.png`: strict vertical 90-degree profile, target bbox about `[w]x1720`, about `[x%]`
- `right.png`: strict vertical 90-degree profile, target bbox about `[w]x1720`, about `[x%]`
- `left45.png`: target object bbox about `[w]x1720`, about `[x%]`
- `right45.png`: target object bbox about `[w]x1720`, about `[x%]`

## Component Depth Contract

| Component | Front width | Expected side depth | Geometry basis | Confirmed by left45 |
| --- | ---: | ---: | --- | --- |
| Shaft | `[shaft_W]px` | `[shaft_D_min]-[shaft_D_max]px` | round / oval / flat | yes / no |
| Main gem | `[gem_W]px` | `[gem_D_min]-[gem_D_max]px` | sphere / faceted / cabochon / plate | yes / no |
| Holder | `[holder_W]px` | `[holder_D_min]-[holder_D_max]px` | claw / leaf / antler / frame | yes / no |
| Tail | `[tail_W]px` | `[tail_D_min]-[tail_D_max]px` | cone / cap / plate | yes / no |

## Component Height Targets

Define full object height as `100%`.

- Top main element: about `[x%-y%]` of total height.
- Top holder / fixing structure: about `[x%-y%]` of total height.
- Metal ring / band 1: about `[x%-y%]` of total height.
- Shaft / grip: about `[x%-y%]` of total height.
- Bottom ornament / tail: about `[x%-y%]` of total height.

## 90-Degree Side Rule

`left.png` and `right.png` must be true side profile views:

- Main front-facing gem does not show a broad face; it shows the side body, bevel, or convex depth defined by the depth contract.
- Holder / claws / leaves overlap in side view while retaining non-zero depth and front-to-back layering.
- Rings become narrow side bands or ellipses.
- Shaft stays vertically aligned and keeps the same taper rhythm.
- If the main gem face is broad or front facets are clearly visible, reject as `SIDE_VIEW_NOT_90_DEGREE`.
- If the camera is correct but the shaft, gem, holder, or tail is paper-thin, reject as `SIDE_DEPTH_COLLAPSE`.
- Never horizontally squeeze a candidate to make it satisfy a width target.
```

## SIDE_VISIBILITY_CONTRACTS.md 模板

```markdown
# [Asset Name] Side Visibility Contracts

Codex must ask, restate, and receive user confirmation before generating any side or 45-degree view.

## left.png
- Camera direction:
- Must be visible:
- Must be hidden or occluded:
- Exact counts and positions:
- Front-to-back occlusion order:
- Thickness / connection evidence:

## right.png
- Camera direction:
- Must be visible:
- Must be hidden or occluded:
- Exact counts and positions:
- Front-to-back occlusion order:
- Thickness / connection evidence:

## left45.png
- Camera direction:
- Must be visible:
- Must be hidden or occluded:
- Exact counts and positions:
- Front-to-back occlusion order:
- Thickness / connection evidence:

## right45.png
- Camera direction:
- Must be visible:
- Must be hidden or occluded:
- Exact counts and positions:
- Front-to-back occlusion order:
- Thickness / connection evidence:

## Confirmation
- Codex restatement:
- User confirmation:
- Confirmation date:

## Mirror Authorization
- Default: not authorized.
- Source file:
- Target file:
- Exact user authorization:
- Authorization date:
```

## STRUCTURE_LOCK.md 模板

```markdown
# [Asset Name] Structure Lock

## Source

- Source image:
- Target object:
- Target use: Roblox prop reference for Hunyuan 3D / TripoAI image-to-3D generation.
- Upload workflow: six views only, no `top.png` or `bottom.png`.
- Category: medium magic wand, not long staff, spear, sword, mace, dagger, or bone club.

## Core Principle

This is one strict multi-view object, not a group of variants.

The AI may only rotate the same wand. It must not redesign, add parts, delete parts, change colors, change materials, change proportions, or replace component shapes.

## Proportion Lock

Define full wand height as `100%`.

Normalized target:

- Canvas: `1024x2048`.
- Object height: about `1720px`.
- Front object width: about `[x]-[y]px`, about `[x%]-[y%]` of object height.
- Back object width: about `[x]-[y]px`, about `[x%]-[y%]` of object height.
- Strict 90-degree side width: about `[x]-[y]px`, about `[x%]-[y%]` of object height.
- 45-degree object width: about `[x]-[y]px`, about `[x%]-[y%]` of object height.

Estimated component proportions:

- [Top main element]: about `[x%]` of total height.
- [Top holder / fixing structure]: about `[x%]` of total height.
- [Metal ring / band]: around `[x%-y%]`.
- [Shaft / grip]: about `[x%]` of total height.
- [Bottom ornament / tail]: about `[x%]` of total height.

Do not enlarge the top, do not shorten the shaft, and do not turn the tail into a new ornament.

## Fixed Components

Components must stay fixed:

- 1 [top main element].
- 1 [top holder / fixing structure].
- [count] [metal rings / bands].
- 1 [shaft / grip].
- 1 [bottom ornament / tail].

Do not add extra gems, extra rings, vines, flowers, runes, chains, cloth strips, magic effects, background props, UI elements, or text labels.

Do not delete any original component.

Every accepted view must keep the same component count and material zones.

## Color And Material Lock

Colors and materials must stay fixed:

- Top main element: [color + material].
- Holder / fixing structure: [color + material].
- Metal parts: [color + material].
- Shaft / grip: [color + material].
- Bottom ornament / tail: [color + material].

Do not change material categories or colors.

## Side Visibility Contract Reference

- Contract file: `SIDE_VISIBILITY_CONTRACTS.md`.
- Codex asked and restated all four output contracts before generation: [yes / no].
- User confirmation date:
- Missing, hidden, one-sided, and occluded structures are governed by the per-file contracts, not inferred from the front image.
- Mirror authorization is absent unless recorded in the contract file with an exact source and target.

## Multi-View Requirements

Required views:

- `front.png`: orthographic front view.
- `back.png`: orthographic back view.
- `left.png`: orthographic strict vertical 90-degree left side profile.
- `right.png`: orthographic strict vertical 90-degree right side profile.
- `left45.png`: orthographic 45-degree front-left view.
- `right45.png`: orthographic 45-degree front-right view.

Excluded:

- `top.png`
- `bottom.png`

Reason: top and bottom views are not reliable from 2D image generation unless derived from real 3D geometry.
```

## FINAL_6_VIEW_STATUS.md 模板

```markdown
# Final 6-View Status

Asset:

Final upload folder:
`[path]`

Included files:
- `front.png`
- `back.png`
- `left.png`
- `right.png`
- `left45.png`
- `right45.png`

Excluded files:
- No `top.png`
- No `bottom.png`

Reason: top and bottom views cannot be inferred reliably from 2D front reference only. They should not be invented for Hunyuan or Tripo input.

## Locked Object Identity

This is one strict object across all views, not a set of variants.

Components must stay fixed:
- [component list]

Forbidden changes:
- [forbidden list]

## Final Measured Proportions

All measurements are based on non-background bounding boxes after normalization.

| View | Object bbox | Width / height |
| --- | ---: | ---: |
| front | `[w] x [h] px` | `[x%]` |
| back | `[w] x [h] px` | `[x%]` |
| left | `[w] x [h] px` | `[x%]` |
| right | `[w] x [h] px` | `[x%]` |
| left45 | `[w] x [h] px` | `[x%]` |
| right45 | `[w] x [h] px` | `[x%]` |

## Side View Gate

`left.png` and `right.png` are strict vertical 90-degree orthographic side views.

Acceptance notes:
- [left/right must-visible and hidden structures match their confirmed contracts]
- [one-sided detail count, position, and occlusion note]
- [main gem / top element side profile note]
- [holder compression note]
- [ring / band side profile note]
- [width ratio note]

Reject rule for future versions:
- If a side or 45-degree output was generated before its contract was confirmed, reject as `SIDE_VISIBILITY_CONTRACT_MISSING`.
- If visible, hidden, count, position, or occlusion differs from the confirmed contract, reject as `SIDE_VISIBILITY_CONTRACT_BROKEN`.
- If a file was mirrored without explicit source-to-target user authorization, reject as `UNCONFIRMED_SIDE_MIRROR`.
- If the main front-facing element shows a broad front face in `left.png` or `right.png`, reject as `SIDE_VIEW_NOT_90_DEGREE`.
- If the side view looks like a 45-degree or 80-degree view, reject even when the file name says left/right.

## Review Result

Status: accepted / rejected.

Review image:
`[path]`
```
