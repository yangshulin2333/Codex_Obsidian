# Venom Bone Greatsword 三视图 Prompt 记录

生成时间：2026-06-12

## 用途

用于 Meshy AI 3D 模型生成的三张独立视角参考图。

本次只生成概念参考图，没有执行 Roblox FBX / GLB 导入打包流程。

## 输入参考

```text
C:\Users\14176\AppData\Local\Temp\codex-clipboard-b6bc6f60-d103-41bc-9853-c03922e713c8.png
C:\Users\14176\AppData\Local\Temp\codex-clipboard-a2e03391-49e2-48ec-b550-57bcdab407d2.png
C:\Users\14176\AppData\Local\Temp\codex-clipboard-21371b15-6505-46ca-bdf6-4b4b2dc914d8.png
```

## 输出文件

```text
D:\SVN\Project_Analysis_Package\Roblox 武器模型制作工作流\generated_views\venom_bone_greatsword_variant_2026-06-12_three_views\venom_bone_greatsword_variant_front_view.png
D:\SVN\Project_Analysis_Package\Roblox 武器模型制作工作流\generated_views\venom_bone_greatsword_variant_2026-06-12_three_views\venom_bone_greatsword_variant_side_view.png
D:\SVN\Project_Analysis_Package\Roblox 武器模型制作工作流\generated_views\venom_bone_greatsword_variant_2026-06-12_three_views\venom_bone_greatsword_variant_back_view.png
```

## Design Lock

```text
Create one same-series redesigned Roblox low-poly fantasy greatsword based on the reference screenshots.
Keep the same weapon family identity: a long vertical greatsword, dark black-teal blade body, silver bone-like armor ribs along the blade, neon green venom glow running through the center channel, jagged symmetrical crossguard with hooked bone spikes, wrapped vertical grip above the guard, diamond spear-like pommel at the top, and long pointed blade tip at the bottom.
Make only moderate variant changes: slightly cleaner low-poly blade planes, a more balanced symmetrical guard silhouette, deeper black-blue metal panels, pale silver bone edges, and emerald-cyan glow instead of pure green.
The front, side, and back images must describe the exact same sword design.
Use the same total height, same blade length, same blade width, same grip length, same top pommel shape, same crossguard height, same left/right guard spike placement, same central glow channel, and same bottom blade tip shape in all views.
Use a clean Roblox low-poly readable silhouette with hand-painted texture detail, not dense high-poly sculpture.
```

## 生成方式说明

```text
Built-in image generation was tried first, but it repeatedly generated unrelated text-heavy guide/infographic images.
Those generated images were discarded.
The final deliverables were made with local controlled drawing so the three views share the same coordinates, proportions, colors, and structure.
```

## View Prompts

### Front View

```text
Generate only the FRONT VIEW of the weapon.
Tall portrait composition, single weapon, vertical, centered, full length visible from top pommel tip to bottom blade tip, orthographic camera, no perspective, no tilt.
Show the main silhouette clearly: long straight greatsword, broad dark blade, central emerald-cyan glowing channel, jagged bone-like crossguard, hooked side spikes, wrapped grip, diamond top pommel, long bottom tip.
```

### Side View

```text
Generate only the 90-DEGREE SIDE VIEW of the exact same weapon.
Use the same height and part positions, but show the blade as a thinner side profile.
Keep the same top pommel, grip, guard position, central glow line, side thorns, and pointed blade tip.
```

### Back View

```text
Generate only the BACK VIEW of the exact same weapon.
Match the front view silhouette and proportions, with simpler rear-side panels, reduced green glow marks, and the same dark metal / pale bone color family.
```

## Negative Constraints

```text
no labels, no text, no watermark, no UI overlay, no character, no hand, no extra weapons, no floor, no room
no axe, no scythe, no mace, no shield, no paired weapons, no crossed weapons, no creature body, no face, no skull sculpture
no high-poly sculpted relief, no dense geometry details, no tiny detached fragments, no noisy surface, no cropped weapon
```

## 检查结果

```text
front_view generated: 1200x2000 PNG
side_view generated: 1200x2000 PNG
back_view generated: 1200x2000 PNG
background: white/light gray
no text or watermark
```
