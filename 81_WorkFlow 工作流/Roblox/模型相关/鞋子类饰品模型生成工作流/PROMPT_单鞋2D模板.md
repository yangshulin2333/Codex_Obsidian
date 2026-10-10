---
type: workflow
domain: roblox
status: active
owner: mixed
source: mixed
created: 2026-07-02
updated: 2026-07-02
---

# 单鞋 2D 生成 Prompt 模板

## 使用方式

先准备一张已确认的一双鞋风格图，作为 `style anchor`。然后分别生成右鞋和左鞋。

## RightShoe 3/4 模板

```text
Use case: stylized-concept
Asset type: Roblox shoe accessory 2D reference image for Tripo / Hunyuan image-to-3D modeling, intended to become the RightShoe Accessory attached to RightFootAttachment.
Input image: use the visible pair of Roblox-style shoes as the style anchor. Preserve the same visual language, color palette, blocky proportions, material style, toe cap shape, thick sole, strap structure, collar opening, side panel idea, and low-poly game-prop quality.
Primary request: Generate one clean 3/4 front reference image of the RIGHT shoe only. The image must show a single right-foot shoe, not a pair.
Subject: exactly one Roblox-style chunky low-top speed shoe for the right foot. Oversized rounded white toe cap, bright orange-yellow main upper, saturated cyan/sky-blue tongue and inner lining, dark gray broad straps, black edge trim, white thick sole with cyan and orange block accents, simple side equipment panel. Clear separation between toe cap, sole, upper, straps, tongue, collar opening, heel, and side panel.
Style/medium: polished stylized 3D render, Roblox-compatible, low-poly but not childish, mature game equipment prop, clean bevels, toy-like material, strong silhouette, clear shapes for 3D model generation.
Composition/framing: orthographic-like 3/4 front view, right shoe centered with generous padding, full shoe visible and not cropped, plain white or very light gray background, no pedestal. Toe points slightly toward the lower-left viewer direction so the outer side panel is visible.
Constraints: exactly one shoe only; no left shoe; no pair; no character; no feet; no socks; no UI; no text; no watermark; no complex background; no brand logo; no trademark mark; no realistic sports shoe advertising style; no tiny decorative details; no thin laces; no extra objects.
```

## LeftShoe 3/4 模板

```text
Use case: stylized-concept
Asset type: Roblox shoe accessory 2D reference image for Tripo / Hunyuan image-to-3D modeling, intended to become the LeftShoe Accessory attached to LeftFootAttachment.
Input image: use the visible pair of Roblox-style shoes as the style anchor. Preserve the same visual language, color palette, blocky proportions, material style, toe cap shape, thick sole, strap structure, collar opening, side panel idea, and low-poly game-prop quality.
Primary request: Generate one clean 3/4 front reference image of the LEFT shoe only. The image must show a single left-foot shoe, not a pair.
Subject: exactly one Roblox-style chunky low-top speed shoe for the left foot. Oversized rounded white toe cap, bright orange-yellow main upper, saturated cyan/sky-blue tongue and inner lining, dark gray broad straps, black edge trim, white thick sole with cyan and orange block accents, simple side equipment panel. Clear separation between toe cap, sole, upper, straps, tongue, collar opening, heel, and side panel.
Style/medium: polished stylized 3D render, Roblox-compatible, low-poly but not childish, mature game equipment prop, clean bevels, toy-like material, strong silhouette, clear shapes for 3D model generation.
Composition/framing: orthographic-like 3/4 front view, left shoe centered with generous padding, full shoe visible and not cropped, plain white or very light gray background, no pedestal. Toe points slightly toward the lower-right viewer direction so the outer side panel is visible. The shoe should be the mirror counterpart of the right shoe, with matching proportions and details.
Constraints: exactly one shoe only; no right shoe; no pair; no character; no feet; no socks; no UI; no text; no watermark; no complex background; no brand logo; no trademark mark; no realistic sports shoe advertising style; no tiny decorative details; no thin laces; no extra objects.
```

## 可调参数

- 如果 3D 结果碎面：减少 `cyan and orange block accents`，改成 `one or two large color blocks only`。
- 如果鞋口塌陷：加强 `open collar ring with visible inner cavity`。
- 如果左右不对称：先固定一只合格单鞋，再通过镜像或严格 mirror prompt 生成另一只。
- 如果模型像普通运动鞋：强化 `Roblox game equipment prop`、`toy-like material`、`chunky blocky proportions`。
