# Void Chain Scythe 三视图 Prompt 记录

生成时间：2026-06-10

## 用途

用于 Meshy AI 3D 模型生成的三张独立视角参考图。

本次只生成概念参考图，没有执行 Roblox FBX / GLB 导入打包流程。

## 输入参考

```text
C:\Users\14176\AppData\Local\Temp\codex-clipboard-0264f2dc-759f-4c65-afcd-218ce4a0e4e6.png
C:\Users\14176\AppData\Local\Temp\codex-clipboard-668462e2-d6b8-4ffa-adf7-b9bfa5376cc0.png
C:\Users\14176\AppData\Local\Temp\codex-clipboard-a76757c3-51c9-4e1d-ac54-b86cec026d3c.png
```

## 输出文件

```text
D:\SVN\Project_Analysis_Package\Roblox 武器模型制作工作流\generated_views\void_chain_scythe_2026-06-10_three_views\void_chain_scythe_front_view.png
D:\SVN\Project_Analysis_Package\Roblox 武器模型制作工作流\generated_views\void_chain_scythe_2026-06-10_three_views\void_chain_scythe_side_view.png
D:\SVN\Project_Analysis_Package\Roblox 武器模型制作工作流\generated_views\void_chain_scythe_2026-06-10_three_views\void_chain_scythe_back_view.png
```

## Design Lock

```text
Create one same-series redesigned Roblox low-poly fantasy scythe based on the reference screenshots.
Keep the same weapon family identity: very long slim black pole handle, large crescent scythe blade at the top, smaller rear hook blade, curved chain hanging under the head, small cross-like charm near the chain end, black wrapped grip near the lower handle, and sharp spear-like spike at the bottom.
Make only moderate variant changes: slightly more angular crescent blade, cleaner low-poly silhouette, darker gunmetal black handle, silver blade cutting edge with subtle cold blue-violet highlights, and small purple-blue rune accents on the head fittings.
The front, side, and back images must describe the exact same scythe design.
Use the same total height, same handle length, same handle thickness, same crescent blade shape, same rear hook position, same chain length, same charm position, same lower grip position, and same bottom spike shape in all views.
Use a clean Roblox low-poly readable silhouette with hand-painted texture detail, not dense high-poly sculpture.
```

## View Prompts

### Front View

```text
Generate only the FRONT VIEW of the exact same scythe.
Tall portrait composition, single weapon, vertical, centered, full length visible from top blade tip to bottom spike tip, orthographic camera, no perspective, no tilt.
The silhouette should be clear and model-friendly: long straight pole, wide crescent blade across the top, small rear hook, chain arc under the head, cross charm, lower grip wrap, bottom spike.
```

### Side View

```text
Generate only the 90-DEGREE SIDE VIEW of the exact same scythe.
Show thickness and side profile: the pole appears narrow but still visible, the scythe blade appears thinner from the side, the head fitting thickness is visible, the chain hangs in the same location under the head, and the cross charm stays near the same height.
```

### Back View

```text
Generate only the BACK VIEW of the exact same scythe.
Match the front view silhouette and proportions exactly: long straight pole, crescent blade sweeping across the top, rear hook, chain arc under the head, cross charm, lower grip wrap, bottom spike.
Show rear-side details only: darker rear metal surfaces, fewer rune marks, and the same cold blue-violet edge highlights.
```

## Negative Constraints

```text
no labels, no text, no watermark, no UI overlay, no character, no hand, no extra weapons, no floor, no room
no hammer, no axe, no mace, no double-headed weapon, no skulls, no broad hammer head, no shield panel, no round ring pommel
no high-poly sculpted relief, no dense geometry details, no tiny detached fragments, no noisy surface, no cropped weapon
```

## 检查结果

```text
front_view generated: 941x1672 PNG
side_view generated: 941x1672 PNG
back_view generated: 941x1672 PNG
background: white/light gray
no text or watermark
```
