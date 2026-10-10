---
type: workflow
domain: roblox
status: active
owner: mixed
source: codex
created: 2026-07-11
updated: 2026-08-12
---

# Roblox 魔法杖通用提示词模板

## 侧向可见性合同模板（生成前必填）

Codex 在生成任何 `left.png`、`right.png`、`left45.png`、`right45.png` 前，必须主动询问用户并逐项复述以下合同。用户确认前不得调用图片生成：

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

不得以“看起来对称”为由跳过合同。镜像只有在用户明确点名来源和目标文件后才可使用，并须写入运行记录。

硬停止 / 拒绝代码：

```text
SIDE_VISIBILITY_CONTRACT_MISSING
SIDE_VISIBILITY_CONTRACT_BROKEN
UNCONFIRMED_SIDE_MIRROR
```

## 效果图模板

```text
Create one clean landscape concept sheet showing exactly [N] distinct Roblox RPG magic wands in strict front view.

Each wand must be a separate complete object, vertically aligned, equally scaled, evenly spaced, and fully visible with generous padding. No overlap and no cropped parts.

Make every wand structurally distinct and suitable for later image-to-3D generation. Use clear model-friendly component boundaries and moderate decoration density.

Plain very light gray studio background. Orthographic front presentation. No text, numbers, labels, watermark, UI, magic effects, particles, hands, characters, scenery, floor, or props.
```

这张图只用于筛选。用户选中前不得生成多视图。

## 正视图模板

```text
Create one complete strict orthographic FRONT VIEW of this exact Roblox RPG magic wand.

This image becomes the only design baseline for later multi-view generation. Keep the complete object vertical and centered with generous blank padding. Nothing may touch or cross an image edge.

[paste proportion lock]
[paste fixed component list]
[paste material and color lock]

Single object only. Plain very light gray background. No perspective, text, watermark, UI, scene, particles, effects, extra ornaments, or cropped parts.
```

## left45 深度桥模板

```text
Image 1 is the user-approved front.png and is the exact identity and design lock.

Render the SAME physical wand rotated horizontally exactly 45 degrees to show its LEFT-FRONT side. Do not redesign it.

Keep the exact total height, vertical anchor positions, component count, colors, and materials.

[paste fixed component list]
[paste component depth contract]
[paste confirmed left45 visibility contract]

Camera: orthographic projection, horizontal yaw exactly 45 degrees left from the approved front, zero pitch, zero roll, no perspective. Full object visible with generous blank padding.

Do not add, remove, recolor, replace, or reshape any component. No text, watermark, UI, scene, particles, effects, or crop.
```

## 严格 left90 模板

输入必须同时包含 accepted `front.png` 与 accepted `left45.png`。

```text
Image 1 is the approved exact front design lock.
Image 2 is the accepted 45-degree left-front depth reference.

Render the SAME physical wand after rotating Image 2 another 45 degrees horizontally to a true LEFT SIDE view.

Camera contract: orthographic projection; exact 90-degree horizontal yaw from the approved front; zero pitch; zero roll; absolutely no front-facing three-quarter drift.

Keep the exact apparent total height, uniform scale, vertical anchors, component count, colors, and materials.

[paste fixed component list]
[paste component depth contract]
[paste confirmed left visibility contract]

Critical side-volume rules:
- A round shaft keeps approximately the same diameter as its front shaft width.
- The gemstone shows a substantial side body, bevel, or convex thickness, not a colored line or flat sheet.
- The holder keeps visible front-to-back layering.
- Metal collars remain complete cylindrical rings.
- The tail keeps its three-dimensional volume.

Do not redesign, add, remove, recolor, or replace any component. No perspective, text, watermark, UI, scene, particles, effects, or crop.
```

`right45.png` 和 `right.png` 使用相同结构的提示词，但必须分别粘贴已确认的 `right45` / `right` 可见性合同。不得仅替换 LEFT/RIGHT 单词后推测结构，也不得默认镜像。

若用户明确授权镜像，先记录：

```markdown
- Mirror source:
- Mirror target:
- Exact user authorization:
- Authorization date:
```

## 背视图模板

```text
Image 1 is the approved front design and exact proportion lock.
Image 2 is the accepted 45-degree depth reference.
Image 3 is the accepted strict side-depth reference.

Render the SAME physical wand viewed exactly from the BACK after a 180-degree horizontal rotation from Image 1. Do not redesign it.

Camera: orthographic projection, exact back view, zero pitch, zero roll, no perspective or three-quarter drift.

Keep the exact total height, silhouette, shaft width, thickness rhythm, vertical component positions, component count, colors, and material zones.

Back-side carved details may be simpler, but no part may be added, removed, replaced, recolored, or reshaped.

Full object visible with generous padding. Plain very light gray background. No text, watermark, UI, scene, particles, effects, or crop.
```

## 通用负面约束

```text
This is one strict multi-view object, not a set of variants.
The AI may only rotate the same wand.
Do not redesign the wand.
Do not add or remove parts.
Do not change component count, proportions, colors, materials, or anchor positions.
No extra wings, spikes, chains, cloth, vines, flowers, runes, gemstones, magic particles, background props, text labels, watermark, or UI icons.
Orthographic projection. Single complete object only.
```
