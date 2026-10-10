# Prompt - 冰蓝暗钢短剑四视图

## Accepted Front Design Lock

```text
Weapon class: flat straight sword / short sword.
Palette: cold blue mithril, dark gunmetal, pale cyan glow.
Silhouette: long faceted vertical blade, compact short curved guard, dark segmented grip, faceted hex pommel.
Material: Roblox low-poly model screenshot, hand-painted metal and dark grip.
Forbidden changes: no serrations, no long spikes, no high-poly filigree, no 3/4 side views.
```

## Back Prompt

```text
Using the accepted front-view weapon image as the exact design lock, generate ONE independent BACK VIEW image of the same Roblox low-poly fantasy flat straight sword / short sword.

It must look like the same model rotated 180 degrees, not a new weapon. Preserve the same total height, long faceted blade length, blade width, compact short curved angular crossguard, dark segmented grip, faceted hex blue pommel, cold blue mithril and dark gunmetal palette, pale cyan material language, and Roblox viewport / low-poly model screenshot feel.

Rear details may be simpler: the central cyan front groove can become a subtle rear ridge or muted cyan seam, and the guard center diamond can become a rear socket plate, but the major shape and skin must match the accepted front view.

Full weapon visible, centered vertical orthographic BACK VIEW, straight upright axis, solid flat light blue-gray background only. No floor plane, no horizon line, no gradient, no viewport UI, no axis widget, no text, no watermark, no character, no hand, no new parts, no serrations, no dense micro-spikes, no high-poly ornament, no flat vector style. The entire sword must fit inside the image with padding at top and bottom.
```

## Rejected AI Side Prompt

```text
Using the accepted front-view weapon image as the exact design lock, generate ONE independent LEFT 90-DEGREE SIDE VIEW image of the same Roblox low-poly fantasy flat straight sword / short sword.

This must be a true orthographic engineering side profile, not a 3/4 view. Preserve the same total height, long blade length, dark segmented grip, faceted hex blue pommel, cold blue mithril / dark gunmetal / pale cyan palette, and Roblox low-poly model screenshot feel.

Because this is a flat sword, compress the front-facing blade, guard, diamond socket, and cyan groove into a narrow vertical side edge. The blade should appear thin from the side. The curved crossguard should NOT spread horizontally like the front view; it should collapse into a short thick side sliver at the guard height. The cyan diamond gem may appear only as a tiny thin side sliver or be mostly hidden by the guard socket.

The side profile must stand perfectly upright on a centered vertical axis. Maximum visible width should be much narrower than the front view, like a clean thin vertical edge with small thickness at grip, guard, pommel, and blade. No diagonal lean, no crossed pose, no perspective rotation, no visible broad front face.
```

## Rejected Side Method

```text
Do not horizontally compress the accepted front image and call it a side view.
That produces SIDE_VIEW_FRONT_COMPRESSED_FAKE because the image still reads as a front blade face.
```

## Final Side Method

```text
For this flat sword, final side views were reconstructed as a true 90-degree orthographic side silhouette.
Preserve total height, handle length, guard position, pommel position, and palette.
Draw only side thickness: narrow blade edge, narrow grip edge, hidden-or-sliver gem, short front/back guard-depth block.
Left is the reconstructed strict 90-degree side silhouette.
Right is a horizontal mirror of left.
```
