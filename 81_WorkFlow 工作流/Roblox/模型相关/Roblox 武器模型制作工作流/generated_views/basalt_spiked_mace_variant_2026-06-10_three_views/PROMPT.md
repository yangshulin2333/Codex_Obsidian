# Basalt Spiked Mace 三视图 Prompt 记录

生成时间：2026-06-10

## 用途

用于 Meshy AI 3D 模型生成的三张独立视角参考图。

本次只生成概念参考图，没有执行 Roblox FBX / GLB 导入打包流程。

## 输入参考

```text
C:\Users\14176\AppData\Local\Temp\codex-clipboard-20eb4c68-10aa-4723-9181-f97a126a5973.png
C:\Users\14176\AppData\Local\Temp\codex-clipboard-938eb4b8-14eb-4fbe-9e70-0a118c4f6c13.png
C:\Users\14176\AppData\Local\Temp\codex-clipboard-6662084a-87ad-4c36-90a0-999789f12e82.png
```

## 输出文件

```text
D:\SVN\Project_Analysis_Package\Roblox 武器模型制作工作流\generated_views\basalt_spiked_mace_variant_2026-06-10_three_views\basalt_spiked_mace_variant_front_view.png
D:\SVN\Project_Analysis_Package\Roblox 武器模型制作工作流\generated_views\basalt_spiked_mace_variant_2026-06-10_three_views\basalt_spiked_mace_variant_side_view.png
D:\SVN\Project_Analysis_Package\Roblox 武器模型制作工作流\generated_views\basalt_spiked_mace_variant_2026-06-10_three_views\basalt_spiked_mace_variant_back_view.png
```

## Design Lock

```text
Create one same-series redesigned Roblox low-poly fantasy spiked mace based on the reference screenshots.
Keep the same weapon family identity: a long straight dark stone handle, a pale white stone connector block below the head, a large dark gray rounded low-poly stone mace head, evenly spaced blunt stone spikes around the head, and a small pale white stone pommel cap at the bottom.
Make only moderate variant changes: make the mace head slightly more octagonal and faceted, make the spikes cleaner and more evenly spaced, keep the handle dark basalt gray, keep the connector and pommel pale marble white, add very subtle cool teal-blue crack lines and tiny rune accents painted on the stone head.
The front, side, and back images must describe the exact same mace design.
Use the same total height, same handle length, same handle thickness, same head size, same head shape, same number and placement logic of blunt spikes, same connector block shape, and same bottom pommel shape in all views.
Use a clean Roblox low-poly readable silhouette with hand-painted texture detail, not dense high-poly sculpture.
```

## View Prompts

### Front View

```text
Generate only the FRONT VIEW of the weapon.
Tall portrait composition, single weapon, vertical, centered, full length visible from top mace spike to bottom pommel, orthographic camera, no perspective, no tilt.
Show the main silhouette clearly: long straight handle, large round faceted mace head at the top, blunt spikes around the head, pale connector block below the head, pale pommel cap at the bottom.
```

### Side View

```text
Generate only the 90-DEGREE SIDE VIEW of the exact same single mace.
A side view of a round mace head should still look like a single round faceted stone ball, just slightly narrower in depth, with a few side studs visible around its rim.
Do not create paired weapons, mirrored weapons, scissors, ornate twin blades, crescent blades, axe blades, sword blades, scythe, chains, skulls, or purple gems.
```

### Back View

```text
Generate only the BACK VIEW of the exact same mace.
Match the front view silhouette and proportions exactly: long straight handle, large round faceted mace head at the top, evenly spaced blunt spikes around the head, pale connector block below the head, pale pommel cap at the bottom.
Show rear-side details only: darker rear stone facets, fewer teal-blue rune marks, same stone cracks and same blunt spike layout.
```

## Negative Constraints

```text
no labels, no text, no watermark, no UI overlay, no character, no hand, no extra weapons, no floor, no room
no paired weapons, no mirrored weapons, no scissors, no double blades, no curved blades, no axe blade, no sword blade, no chain, no skulls, no creature face
no high-poly sculpted relief, no dense geometry details, no tiny detached fragments, no noisy surface, no cropped weapon
```

## 检查结果

```text
front_view generated: 862x1825 PNG
side_view generated: 881x1786 PNG
back_view generated: 940x1672 PNG
background: white/light gray
no text or watermark
```
