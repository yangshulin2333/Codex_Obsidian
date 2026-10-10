# Prompt And Candidate Record

generation_route: built-in image_gen
phase: approved four-view output

## Design Lock Source

- accepted_front_candidate: D:\Work\Note\yanzo\81_WorkFlow 工作流\Roblox\Tripo多视图工作流\输出内容\翡翠黑铁翼刃长剑_长剑型正视图\emerald_blackiron_wing_sword_front_candidate_01.png
- candidate_archive: D:\Work\Note\yanzo\81_WorkFlow 工作流\Roblox\Tripo多视图工作流\输出内容\_imagegen_candidates\翡翠黑铁翼刃长剑_2026-06-23

## Front Prompt

Using the uploaded Roblox weapon screenshot as reference, generate ONE independent FRONT VIEW image of a same-series redesigned Roblox low-poly fantasy long sword / ceremonial wing-guard sword for Tripo / 3D AI modeling.

Preserve the weapon family identity from the reference: vertical long sword silhouette, long straight blade, broad ornate wing-shaped guard near the top, central shield-like plate below the handle, curved decorative lines running down the blade, pale grip rising above the guard, small strap / dangling charm near the top, symmetrical front-facing composition, elegant ceremonial fantasy sword proportions.

Make it clearly different from the reference by changing the theme color completely to an emerald-and-blackened-iron arcane forest relic: deep emerald green and jade inlays on the central blade grooves and guard center, blackened iron / dark graphite on the guard frame and top fittings, cool silver-white on the blade edges, muted antique brass only as thin trim, pale bone or moonstone grip, small toxic green glow inside rune grooves and gem sockets. Avoid the original white-and-gold dominant palette.

Change 2-3 local design details while preserving the same weapon family: make the wing-shaped guard slightly sharper and more leaf-feather-like, turn the central shield plate into a faceted emerald gem setting, make the blade's curved gold lines into glowing green vine-like rune inlays, and make the top dangling charm a small dark-metal talisman with an emerald tip. Do not add complex new parts.

Keep the Roblox low-poly viewport/model screenshot feel: faceted planes, hand-painted rough metal, game-ready shape, simple model-viewer lighting, readable silhouette, not flat vector art and not concept art.

Full weapon visible, centered vertical orthographic FRONT view, clean light Roblox viewport-style background, generous padding around the full weapon.
No text, no watermark, no UI, no character, no hand, no scene clutter, no dense micro-spikes, no serrated saw teeth, no high-poly ornament, no flat vector art, no photorealistic product render.

## Back Prompt

Using the accepted front-view weapon image as the exact design lock, generate ONE independent BACK VIEW image of the same Roblox low-poly fantasy long sword / ceremonial wing-guard sword.

It must look like the same model rotated 180 degrees, not a new weapon. Preserve the same total height, long straight blade length, blade width, broad leaf-feather wing-shaped guard, central shield/gem plate position, top pale braided grip, strap / dangling charm near the top, sharp bottom tip, emerald-and-blackened-iron palette, material texture, silhouette, and Roblox low-poly viewport/model screenshot feel.

Design lock details to preserve: deep emerald green and jade crystal accents, blackened iron / dark graphite guard frame and top fittings, cool silver-white blade edges, muted antique brass thin trim, pale bone / moonstone grip, toxic green glowing rune/vine inlays. The rear texture may be simpler and show fewer front-facing gems, but the major shape, guard width, blade proportions, top charm, and skin must match the accepted front view.

Full weapon visible, centered vertical orthographic BACK view, clean light Roblox viewport-style background, generous padding around the full weapon.
No text, no watermark, no UI, no character, no hand, no new parts, no changed silhouette, no changed blade length, no changed wing guard identity, no changed central plate position, no changed charm position, no serrations, no saw teeth, no extra spikes, no high-poly ornament, no flat vector art, no 3/4 view.

## Left Prompt

Using the accepted front-view weapon image as the exact design lock, generate ONE independent LEFT 90-DEGREE SIDE VIEW image of the same Roblox low-poly fantasy long sword / ceremonial wing-guard sword.

This must be a true orthographic 90-degree side profile, not a 3/4 view. Preserve the same total height, long blade length, top pale braided grip, top cap, strap / dangling charm near the top, guard position, material palette, and Roblox low-poly viewport/model screenshot feel.

Important side-profile rules for this exact weapon: this is a long sword with a broad front-facing leaf-feather wing guard. From the side, the wide wing guard, emerald central gem, feather layers, glowing vine rune lines, and silver blade shoulders must compress into a narrow side edge with visible thickness only. The blade should appear thin from the side, with a narrow dark graphite core and thin silver edges. The emerald gem and rune lines may appear only as thin glowing side slivers or be partly hidden by the guard thickness. The dangling charm should remain near the top but seen from the side as a small hanging emerald talisman.

Preserve the exact emerald-and-blackened-iron theme: deep emerald green, jade crystal accents, blackened iron / dark graphite guard and fittings, cool silver-white blade edges, muted antique brass thin trim, pale bone grip, toxic green glow in grooves.

Full weapon visible, centered vertical orthographic LEFT SIDE view, clean light Roblox viewport-style background, generous padding around the full weapon.
No text, no watermark, no UI, no character, no hand, no front-facing wing spread, no wide front guard, no full front gem face, no 3/4 view, no new parts, no changed silhouette height, no changed blade length, no serrations, no saw teeth, no extra side spikes, no flat vector art.

## Left Candidate 01 Failure

`left_candidate_01` was rejected after review.

Failure type:

```text
SIDE_VIEW_NOT_90_DEGREE
```

Cause:

```text
The image was narrow, but the guard/charm area still read as a partial 3/4 or non-perpendicular side view. It did not meet the strict engineering side-projection gate.
```

## Strict Left Candidate 02 Prompt

Using the accepted front-view weapon image as the exact design lock, generate ONE independent LEFT ORTHOGRAPHIC 90-DEGREE SIDE VIEW image of the same Roblox low-poly fantasy long sword / ceremonial wing-guard sword.

STRICT CAMERA RULE: the camera is exactly perpendicular to the front face, viewing along the weapon's local X axis. This is a CAD/model-sheet LEFT SIDE projection, not an illustration angle. The weapon remains perfectly vertical. No perspective, no rotation toward the viewer, no 3/4 angle, no front-facing surfaces.

SIDE SILHOUETTE RULE: from this exact 90-degree side view, the sword must become a very narrow vertical edge profile. The wide front-facing wing guard, leaf-feather layers, central emerald gem, glowing rune lines, and broad blade face must collapse into thin edge thickness only. The whole weapon's maximum visible width should be much narrower than the front view, roughly a slim blade-and-guard thickness profile, not a spread-out guard. The wing guard may appear only as a short stacked dark-metal side block / thin layered edge at the guard height, never as wings or feathers spreading left-right. The central emerald gem may appear only as a tiny green side sliver or be fully hidden. The blade should be a thin vertical silver-black edge with minimal green line slivers. The hanging charm near the top may remain visible as a thin side dangling talisman, but it must not make the weapon look like a front or 3/4 view.

Preserve identity from the accepted front: same total height, same long blade length, same top pale braided grip and cap, same blackened iron fittings, same emerald / jade / green glow palette, same sharp bottom tip, same Roblox low-poly viewport/model screenshot feel.

Full weapon visible, centered vertical orthographic LEFT SIDE view, clean light Roblox viewport-style background, generous padding around the full weapon.
No text, no watermark, no UI, no character, no hand, no 3/4 view, no front-facing wing spread, no visible broad guard face, no visible full emerald front gem, no front blade face, no feather fan silhouette, no wide blade shoulders, no new parts, no changed total height, no changed blade length, no serrations, no saw teeth, no extra side spikes, no flat vector art.

## Right Prompt

Right view was mirrored from approved left candidate 02 to prevent left/right drift.
