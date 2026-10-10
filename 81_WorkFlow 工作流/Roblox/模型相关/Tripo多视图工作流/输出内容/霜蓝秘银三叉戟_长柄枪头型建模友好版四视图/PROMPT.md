# 霜蓝秘银三叉戟 建模友好版 Prompt 记录

## 目标

这版不是美术展示图，而是给 Tripo / 3D AI 更容易读懂结构的建模参考图。

核心调整：

- 减少碎小装饰、微小尖刺、复杂切面。
- 把枪尖、护架、晶体、柄部环扣都改成大块低模结构。
- 强化材质分区：银白金属、深钢灰、冰蓝晶体。
- 侧视图重点表达厚度和连接关系，不表达正面展开效果。

## Front Prompt

```text
Using the accepted frost-blue mithril trident front-view weapon image as the design reference, generate ONE independent FRONT VIEW image of a MODELING-FRIENDLY Roblox low-poly fantasy trident / polearm for Tripo / 3D AI modeling.

Purpose: this is not a decorative concept-art upgrade. It is a clean engineering-style 3D modeling reference designed to help Tripo understand simple geometry, material zones, and thickness. Preserve the weapon identity: tall vertical trident polearm, long straight shaft, three upward spear tips, tallest central spear tip, two slimmer side tips, one simple crescent guard below the head, central ice-blue diamond crystal block, alternating grip rings, bottom pointed pommel.

Simplify the previous design for better 3D generation: use larger clean low-poly planes, fewer parts, fewer bevel layers, no tiny decorative spikes, no micro notches, no fragmented trim. Make the crescent guard one continuous thick curved metal bar with simple blocky end caps. Make the side spear tips simple tapered prism blades. Make the central spear tip a single clean faceted prism blade with one vertical ice-blue inset. Make the crystal a simple raised diamond block, not a complex cut gem. Make the handle a clean cylinder with clear ring bands.

Color and material zones must be very readable: satin silver main metal, dark gunmetal inner sockets and handle, pale ice-blue crystal insets, small cyan accents only on large simple panels. Use flat hand-painted material blocks with low-poly faceted shading, not noisy texture.

Full weapon visible from tip to pommel, centered vertical orthographic FRONT view, simple light Roblox viewport-style background, generous padding. No labels, no text, no watermark, no UI, no character, no hand, no scene clutter, no 3/4 perspective, no high-poly ornament, no tiny spikes, no serrations, no overly detailed texture, no flat vector icon style.
```

## Back Prompt

```text
Using the model-friendly frost-blue mithril trident FRONT VIEW image just generated as the exact design lock, generate ONE independent BACK VIEW image of the same Roblox low-poly trident / polearm.

It must look like the same model rotated 180 degrees, not a new weapon. Preserve the simplified engineering-friendly structure: tall vertical polearm, long straight shaft, three upward spear tips, tallest central clean prism spear tip, two slimmer side prism spear tips, one continuous thick crescent guard below the head, simple blocky guard end caps, central diamond block position, alternating grip rings, bottom pointed pommel.

Keep the design modeling-friendly for Tripo: large clean low-poly planes, clear object separation, simple sockets, readable thickness, no fragmented trim, no tiny decorative spikes, no micro notches, no noisy texture. Rear side may have simpler crystal detail: the central diamond can become a plain raised rear plate with a pale ice-blue inset, but it must stay in the same position and same scale.

Color and material zones must remain very readable: satin silver main metal, dark gunmetal sockets and handle, pale ice-blue crystal insets, small cyan accents only on large simple panels. Use flat hand-painted material blocks and faceted low-poly shading.

Full weapon visible from tip to pommel, centered vertical orthographic BACK view, simple light Roblox viewport-style background, generous padding. No labels, no text, no watermark, no UI, no character, no hand, no scene clutter, no 3/4 perspective, no new parts, no high-poly ornament, no tiny spikes, no serrations, no overly detailed texture, no flat vector icon style.
```

## Left Prompt

```text
Using the model-friendly frost-blue mithril trident FRONT VIEW image just generated as the exact design lock, generate ONE independent LEFT 90-DEGREE SIDE VIEW image of the same Roblox low-poly trident / polearm.

This must be a true orthographic side profile, not a 3/4 view. Purpose: clear 3D modeling reference for Tripo. Preserve the simplified engineering-friendly structure: same total height, long straight shaft, bottom pointed pommel, alternating grip rings, three-prong trident head compressed in side view, thick central spear socket, continuous crescent guard seen edge-on, simple blocky guard end cap thickness.

Side-view geometry rule: the broad front-facing crescent guard must become a narrow thick curved bar edge, not a wide front spread. The central spearhead should appear as a long narrow faceted prism with visible thickness. The two side spear tips should align behind the central plane and appear as one narrow side-visible vertical side-tip/post, not as the full front three-prong spread. The central diamond crystal should appear only as a thin raised side block or small side inset, not a full front diamond.

Make it modeling-friendly: large clean low-poly planes, simple cylinders and prism blocks, clear sockets and collars, readable thickness, no tiny bevel fragments, no micro spikes, no serrations, no noisy texture. Color zones remain readable: satin silver main metal, dark gunmetal handle and sockets, pale ice-blue crystal side insets, small cyan accents only on simple large surfaces.

Full weapon visible from tip to pommel, centered vertical orthographic LEFT 90-degree side view, simple light Roblox viewport-style background, generous padding. No labels, no text, no watermark, no UI, no character, no hand, no 3/4 perspective, no broad front-facing guard, no full front-facing diamond gem, no new geometry, no high-poly ornament, no flat vector icon style.
```

## Right Rule

`right` 由 `left` 水平镜像生成。这样比独立生成右视图更稳定，能减少左右结构漂移。

