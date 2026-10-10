# Prompt 素材库

## 低模 Roblox 武器核心 Prompt

```text
low-poly Roblox fantasy weapon, clean flat planes, game-ready low-poly mesh, details painted in texture, not sculpted geometry, simple solid silhouette, no sculpted skull details, no tiny raised ornaments, no dense relief, no noisy surface, no small 3D cracks, optimized for 3000 to 4000 triangles
```

## 三视图参考图 Prompt 方向

默认规则：三视图生成优先直接生成三张独立图片，不要默认只生成一张三视图合图再裁切。合图可以作为人工检查附加图，但最终给 3D AI 的主交付应是：

```text
*_front_view.png
*_side_view.png
*_back_view.png
```

## 内置图像生成风险提示

当任务目标是“3D AI 建模参考三视图”时，稳定性比探索性更重要。不要默认把内置图像生成作为正式交付路线；它可以用于探索概念，但一旦出现无关内容或风格漂移，要立即切换到本地可控生成 / 渲染流程。

流程风险比 prompt 风险更高：即使 prompt 写得正确，也不能从 `C:\Users\14176\.codex\generated_images` 全局目录按最新时间复制图片。正式交付只能来自：

```text
1. 本次 image_gen 明确返回的生成目录，经人工视觉验收后复制。
2. 本地可控渲染 / 绘制输出目录，经人工视觉验收后复制。
```

入库必须使用：

```powershell
D:\SVN\Project_Analysis_Package\Roblox 武器模型制作工作流\scripts\Approve-ThreeViewCandidate.ps1
```

正式三视图的负向约束里必须明确排除：

```text
no infographic, no chart, no poster, no text, no watermark, no UI screenshot, no coffee, no food, no portrait, no biography, no tax table, no document, no unrelated object, no character, no hand, no scene, no environment, no realistic photo, no flat vector poster when Roblox low-poly render style is required
```

风格锁定优先级：

1. 先锁定参考图的渲染风格，例如 Roblox Studio 低模截图、手绘贴图、干净正交视角。
2. 再锁定武器类型和结构。
3. 最后才允许小幅调整颜色和局部形状。
4. 如果用户指出“风格变了”，下一版必须使用本地可控渲染或绘制，不继续盲目重试同一个图像生成路线。

## 风格不对时的纠偏 Prompt 原则

如果用户反馈“风格不对 / 不像 / 失望”，先不要继续完整生成三张图。必须先做一张正视图纠偏小样，并在 Prompt 中明确：

```text
Primary goal: preserve the visual style of the reference Roblox viewport screenshot.
This is not a new unrelated redesign.
Keep the same weapon family identity, silhouette ratio, material language, decoration density, and low-poly game-asset render feel.
Only make small same-series changes to color accents, gem shapes, edge shapes, and local markings.
Do not change the weapon into a flat vector icon, poster illustration, realistic render, or different fantasy style.
Do not simplify away the reference material feel.
```

中文检查口径：

```text
先问像不像原图同系列，再问三视图是否一致。
如果不像原图同系列，就算三张图文件正确，也不能交付。
```

复制前人工验收用语：

```text
This candidate is a single weapon only.
It matches the requested weapon type and Roblox low-poly render style.
It has no person, no biography, no infographic, no poster, no chart, no UI, no watermark, and no readable text.
The full weapon is visible from top tip to bottom tip.
Only after this check can the image be copied into generated_views.
```

```text
Create a low-poly Roblox-style fantasy weapon reference sheet.
Use a clean silhouette and painted texture details.
Do not show sculpted high-poly relief.
Do not add tiny 3D ornaments, small spikes, noisy surface, or dense skull geometry.
The weapon should look good with about 3000 to 4000 triangles.
```

## 独立三张三视图 Prompt 骨架

先写一段共用设计锁定，再分别生成正视、侧视、背视。三张图必须复用同一段 `Design lock`，只改变视角要求。

```text
Design lock:
Create one same-series redesigned Roblox fantasy weapon based on the provided reference screenshots.
Preserve the reference Roblox viewport render feel: low-poly game asset, readable hand-painted material, similar lighting, similar decoration density, and similar proportions.
Keep the same weapon family identity, main silhouette, total height, handle length, head size, guard position, pommel shape, color family, material language, and decorative element placement.
Make only small same-series variant changes to color accents and local shapes.
The front, side, and back images must describe the exact same weapon design.
Use a clean Roblox low-poly readable silhouette with hand-painted texture detail, not dense high-poly sculpture.
```

正视图：

```text
Use the shared Design lock. Generate only the FRONT VIEW of the weapon.
Single weapon, vertical, centered, full length visible, orthographic camera, no perspective.
Plain white or light gray background. No labels, text, watermark, UI, character, hand, or extra weapons.
```

侧视图：

```text
Use the shared Design lock. Generate only the 90-DEGREE SIDE VIEW of the exact same weapon.
Show thickness and side profile, but do not invent a different weapon.
All major parts must align with the front view: blade height, handle length, guard position, pommel position.
Plain white or light gray background. No labels, text, watermark, UI, character, hand, or extra weapons.
```

背视图：

```text
Use the shared Design lock. Generate only the BACK VIEW of the exact same weapon.
Match the front view silhouette and proportions, with rear-side panel details only.
Do not change blade shape, handle length, guard position, pommel position, or color family.
Plain white or light gray background. No labels, text, watermark, UI, character, hand, or extra weapons.
```

## 反向约束

用于避免 Meshy 生成高模雕塑：

```text
no high-poly sculpted relief, no dense geometry details, no tiny detached parts, no floating fragments, no noisy surface, no hair-like spikes, no small 3D cracks, no complex skull sculpture, no dense filigree, no random blocks
```

## 中文解释

Prompt 的核心不是“做得更精细”，而是“让细节画在贴图里”。

Roblox 低模武器更适合：

1. 大轮廓清楚。
2. 刀刃、护手、手柄结构明确。
3. 细节靠颜色、发光贴图、法线和 Roblox 特效补。
4. 不要让 AI 把每个纹路都生成成真实几何。
