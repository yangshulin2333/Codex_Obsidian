---
type: resource
domain: 3d-modeling
status: summarized
owner: mixed
source: course
created: 2026-08-04
updated: 2026-08-04
tags:
  - type/resource
  - source/course
  - status/summarized
aliases:
  - 游戏道具纹理与 PBR 贴图
  - AI x 3D 第7课
  - Modddif 游戏道具纹理流程
---

# AI x 3D 第7课｜游戏道具纹理与 PBR 贴图

## 一句话说明

把已经定稿的低模和 UV 导入 Modddif 等 AI 纹理工具，生成不带固定光影的 Base Color，再通过单视图投影、局部修复和 Blender PBR 节点得到可用于游戏引擎的清晰贴图。

本文只保留武器、工具、宝箱、家具、拾取物等游戏道具需要的流程；角色眼睛、皮肤、服装分区、Mixamo 和绑定内容已移除。

## 课程来源

- 视频：`D:\BaiduNetdiskDownload\AI x 3D — 从创意到游戏角色\原声\#7 - 纹理\第七课：纹理处理-中文.mp4`
- 课程摘要：`D:\BaiduNetdiskDownload\AI x 3D — 从创意到游戏角色\原声\#7 - 纹理\新建文本文档.txt`
- 提示文件：`fa7d952b194242b7959f24e1b89bad7a.zip/lesson-07-hints.md`
- 课程素材包：`8638f22cb4fc47dfb04c529450431bd9.rar`

## 先回答最容易混淆的问题

### UV 不是最终纹理

UV 只规定“模型表面的某一点，要去二维图片的哪个位置取像素”。

- UV 线框 PNG：只是布局参考或绘制模板。
- Checker 棋盘格：只是检查拉伸、接缝和纹理密度。
- Base Color / Normal / Roughness 等图片：才是最终实际使用的纹理。

上传给 Modddif 的主体应是**带最终 UV 的 FBX 或 GLB 模型**，不是单独上传一张 UV 线框 PNG。

### 纹理开始后不要再重新展开 UV

纹理像素与 UV 坐标一一对应。Modddif 开始绘制后，如果重新 Unwrap、Pack 或移动 UV 岛，已经生成的纹理就会错位。

因此正确顺序是：

```text
低模定稿
  → UV 定稿并冻结
  → 高模烘焙 Normal / AO（如有）
  → Modddif 生成和修补纹理
  → Blender / 游戏引擎验收
```

## 本课在游戏道具流程中的位置

```text
第4课：低模拓扑清理
  → 第5课：UV
  → 第6课：高模到低模 Normal / AO 烘焙
  → 第7课：AI 生成 Base Color 与 PBR 清理
  → 输出游戏贴图
```

如果没有高模，可以跳过真实高低模烘焙，直接进行 AI 纹理；但 AI 生成的 Normal 只是根据颜色推测表面起伏，不能替代真实高模细节烘焙。

## 输入与输出合同

### 输入

- 已定稿的低模模型。
- 已冻结且无明显错误的 UV。
- 正、背、左、右，必要时顶、底和 45° 参考图。
- 明确的材质分区，例如金属、木头、皮革、宝石和发光区域。
- 可选：第 6 课烘焙完成的 Normal 与 AO。

### 输出

一件普通游戏道具通常保留：

```text
Prop_BaseColor_2K.png      # 2K 可编辑母版
Prop_Normal_2K.png         # 可选，高模烘焙或局部 AI 法线
Prop_Roughness_2K.png
Prop_Metallic_2K.png
Prop_AO_2K.png             # 可选
Prop_Emission_2K.png       # 可选

Prop_BaseColor_512.png     # 游戏交付版
Prop_Normal_512.png
Prop_Roughness_512.png
Prop_Metallic_512.png
```

如果目标引擎要求把 AO、Roughness、Metallic 打包到同一张通道图，应在最终引擎交付阶段按该引擎规范处理；本课本身没有建立统一的通道打包合同。

## PBR 贴图到底控制什么

| 贴图 | 作用 | 黑白含义 |
|---|---|---|
| Base Color / Albedo | 材质本来的颜色 | 不是遮罩；不应画死强阴影和高光 |
| Normal | 小尺度凹凸方向 | RGB 向量数据，不是灰度图 |
| Roughness | 表面粗糙程度 | 黑 = 光滑；白 = 粗糙 |
| Metallic | 是否为金属 | 黑 = 非金属；白 = 金属 |
| AO | 缝隙和遮蔽数据 | 白 =无遮挡；黑 = 遮蔽强 |
| Emission | 自发光颜色或遮罩 | 黑色遮罩通常代表不发光 |

金属度不应为了“看起来更亮”随意刷成灰色。课程提示文件强调：真实材质区域通常是金属或非金属，灰色主要出现在抗锯齿边界或材质混合区域。

## 为什么主路线使用 Modddif

课程比较了三条 AI 纹理路线：

### Hunyuan 纹理绘制

课程示例认为结果过于风格化，并把阴影画进了 Base Color，因此没有选为主路线。

### Tripo 纹理

优点是快速、对干净 UV 的简单物体效果稳定。课程同时提醒：它可能忽略已有烘焙 Normal，因此当高模法线细节非常重要时，不应把它作为默认路线。

### Modddif

Modddif 是本课主工具，因为它提供：

- Albedo 模式；
- Multiview 自动投影；
- Single View 单视图投影；
- 图层和蒙版；
- InPaint 局部修复；
- Normal Map 编辑；
- 模型或单张纹理导出。

## Modddif 当前时效说明

课程录制时演示了“免费创建私有项目”和“免费无限 2K”。当前官方文档已经有变化：

- 默认纹理为 2K，Pro 支持 4K；
- 免费用户只能创建公开项目；
- Pro 才提供私有项目和 FBX 导出；
- 官方建议回 Blender 时优先使用 GLB，并启用 Merge Vertices。

公开项目可能被其他用户访问、复制或下载，并受平台公开许可和训练规则影响。未公开的商业概念、客户资产或不希望外泄的设计，不应在不了解当前隐私条款时直接上传免费公开项目。

当前规则以官方文档为准：

- [Modddif Texture](https://docs.modddif.com/project/texture/)
- [Modddif Pro](https://docs.modddif.com/account/subscription/)
- [Create a project](https://docs.modddif.com/project/create_a_project/)
- [Import Modddif files in Blender](https://docs.modddif.com/project/tips/)

## 最短可执行流程

### 步骤 1：冻结低模与 UV

进入 Modddif 前确认：

- 低模几何已经定稿；
- UV 岛没有意外重叠；
- 接缝不集中在最显眼的正面；
- 重要表面获得足够 UV 面积；
- 各岛纹理密度接近；
- 目标贴图边距足够；
- 对象旋转、缩放和单位已检查；
- 材质槽数量已经确定；
- 保存独立备份。

### 步骤 2：准备模型和参考图

1. 导出带最终 UV 的低模 FBX 或 GLB。
2. 不要把 UV 线框 PNG 当作模型上传。
3. 准备同一件道具的正、背、侧和必要的顶底参考图。
4. 参考图应保持：
   - 同一个物体；
   - 结构和材质分区一致；
   - 无文字水印和 UI；
   - 无固定场景阴影；
   - 尽量接近正交视图。
5. 如果已经有高模 Normal / AO，把它们作为低模资产的一部分保留。

### 步骤 3：在 Modddif 建立项目

1. 创建项目并确认当前项目隐私。
2. 导入低模 FBX 或 GLB。
3. 检查模型朝向、尺寸和 UV 是否正常。
4. 课程使用 2K；对最终 512 游戏贴图，也建议先在 2K 生成和修补。
5. 在 Settings 中把生成模式设为 `Albedo`。

`Albedo` 的目的，是生成没有固定照明的材质本色，避免把参考图里的阴影和高光永久烘进 Base Color。

### 步骤 4：选择 Multiview 或 Single View

#### Multiview：快速初稿

适合：

- 结构简单；
- 材质分区大而清楚；
- 只需要快速看整体方向。

风险：

- 底面可能缺失或变黑；
- 细长侧面可能模糊；
- 左右装饰可能被错误复制；
- 接缝处容易发生图案断裂。

Multiview 应视为粗稿，不是默认最终结果。

#### Single View：默认精修路线

课程讲师 Stefan 推荐 Single View，因为每次投影的角度和范围更可控。

典型操作：

1. 选择一个清楚角度。
2. 使用对应参考图生成。
3. 满意后点击 `Add as layer + Upscale`。
4. 旋转模型到下一角度。
5. 重复正面、背面、左右侧面和底部。
6. 最后专门处理接缝与遮挡区域。

课程参考数量：

- 正面 2–3 次投影；
- 背面 1 次；
- 侧边、底部和接缝 1–2 次清理投影。

数量不是硬指标。应以所有可见表面得到稳定覆盖为准。

### 步骤 5：用 InPaint 和图层蒙版修复

局部修复原则：一次只修一个小问题。

1. 在设置中关闭会让修复扩散到已绘制区域的“部分再生”选项。
2. 用 Repair / InPaint 画笔只标记小范围。
3. 生成后检查邻近接缝和另一侧表面。
4. 如果某图层只在局部引入瑕疵：
   - 打开图层菜单；
   - 选择 Edit Mask；
   - 遮掉错误部分；
   - 不要删除包含其他有效修复的整个图层。

优先修复：

- 底面黑块；
- 左右图案不一致；
- 接缝断裂；
- 颜色渗到错误材质区；
- AI 乱码或假文字；
- 高光和阴影被画进 Base Color；
- 细长部位纹理被拉长。

### 步骤 6：处理 Normal

Normal 有两种来源：

1. **高模到低模烘焙**：用于真实雕刻、倒角、凹槽和高模几何细节，是优先方案。
2. **Modddif AI Normal**：适合浅划痕、图案压纹和轻微表面起伏，不等同于真实高模烘焙。

在 Modddif 中可以切换到 Normal Map 模式，由颜色生成或局部 InPaint。必须使用旋转灯光检查凸凹方向，不能只看一张蓝紫色平面图判断是否正确。

导回 Blender 时使用：

```text
Image Texture（Non-Color）
  → Normal Map 节点
  → Principled BSDF 的 Normal
```

如果目标引擎显示凹凸反向，应检查其 Normal 方向和绿色通道规则，不要直接认定贴图本身损坏。

### 步骤 7：在 Blender 中连接 PBR 贴图

| 贴图 | Blender 色彩空间 | 节点连接 |
|---|---|---|
| Base Color | `sRGB` | Image Color → Principled Base Color |
| Normal | `Non-Color` | Image Color → Normal Map → Principled Normal |
| Roughness | `Non-Color` | Image Color → Principled Roughness |
| Metallic | `Non-Color` | Image Color → Principled Metallic |
| AO | `Non-Color` | 作为数据图按引擎规则使用；Principled 没有通用 AO 输入 |
| Emission Color | `sRGB` | Image Color → Principled Emission Color |
| Emission Mask | `Non-Color` | 作为发光强度遮罩使用 |

> 重要修正：课程摘要把 AO 归入 sRGB，并把所有 Emission 都归入 Non-Color，这不适合作为通用硬规则。AO 是数据贴图，通常应使用 Non-Color；彩色 Emission 是颜色，遮罩式 Emission 才是 Non-Color。Blender 官方也说明 Normal、Bump、Stencil 等非颜色数据不应进行颜色转换。参见 [Blender Image Settings](https://docs.blender.org/manual/en/5.2/editors/image/image_settings.html) 与 [Normal Map Node](https://docs.blender.org/manual/en/4.2/render/shader_nodes/vector/normal_map.html)。

### 步骤 8：Blender 局部清理

课程使用以下 Texture Paint 工具：

- Smear：拖动像素，适合修细线和接缝；
- Clone：从干净区域采样并覆盖损坏区域；
- Template 投影：精确放置符号、条纹和标记；
- 隔离网格：编辑模式选择相连区域后单独显示，便于涂隐藏面。

贴花或标记不建议完全依赖 AI 生成文字。游戏道具需要清晰符号时，优先使用透明 PNG Alpha、模板投影或后期手工绘制。

Blender 不会自动替你保存外部图片。修改后必须在 Image Editor 中显式保存，或确认图片已正确 Pack 到 `.blend`。

## 512 游戏贴图策略

课程使用 2K 作为生成与编辑分辨率。本项目的既有游戏道具工作流采用：

```text
2K：生成、修复和保留母版
512：默认游戏交付版
1024：只有近景实机确认 512 不足后才测试
```

原因：

- 2K 每个方向是 512 的 4 倍，像素总量是 16 倍；
- AI 在 2K 上更容易生成干净边缘和细节；
- 修补完成后再缩到 512，通常比直接生成 512 更稳定；
- 512 仍有物理上限，极细花纹、微小文字和大量碎 UV 岛无法无限清晰。

让 512 更清楚的关键：

- 重要正面获得更大的 UV 面积；
- 减少无意义的碎小 UV 岛；
- 尽量少用材质槽；
- 不把像素浪费在不可见内部面；
- 对称且允许共用纹理的区域可以有意重叠；
- 缩图后检查 Normal 和遮罩，不只看 Base Color；
- 必须用游戏实际相机距离验收。

## 金属度、粗糙度和发光的道具用法

### Metallic

- 黑色：非金属，例如木头、布、皮革、石头、油漆层。
- 白色：金属，例如裸露钢铁、铜、金和银。
- 先明确材质是什么，再画 Metallic，不要为了增强反光把所有东西都设为金属。

### Roughness

- 黑色：更光滑、反射更锐利。
- 白色：更粗糙、更哑光。
- 抛光金属可偏暗；拉丝或旧金属可偏中灰；木头和布料通常更亮。
- 在小测试区域先使用极值，再旋转灯光理解效果。

### Emission

- 贴图负责发光颜色或区域。
- 强度应由材质的 Emission Strength 控制。
- 不要为了更亮把贴图颜色推到严重过曝，这会损失颜色层次。

## 游戏道具可以跳过什么

课程中的以下角色专属内容不需要写入普通道具流程：

- 虹膜 UV 岛对准；
- 眼睛发光绘制；
- 身体、头部、尾巴和服装分工具选择；
- 绑定前的角色材质整合；
- Mixamo / AccuRIG 往返。

但如果道具有宝石、魔法符文、能量核心或发光刀刃，Emission 的技术仍然适用。

## 常见失败与修复

### 纹理能包裹，但底部是黑色

原因：Multiview 没有可靠覆盖底视角。

处理：从底部运行一次 Single View，或用局部 InPaint 填补，不要把黑底直接保留到游戏贴图。

### 修复越界污染其他区域

原因：部分再生或图层扩散范围开启。

处理：关闭对应选项，缩小修复区域；局部错误使用 Edit Mask，而不是删除整个图层。

### 表面有明显固定阴影和高光

原因：没有使用 Albedo 模式，或参考图本身光影太强。

处理：切换 Albedo，使用更均匀的参考图；必要时重新投影受影响区域。

### Normal 出现条纹、凹凸反向或接缝

处理顺序：

1. 确认 Image Texture 为 Non-Color；
2. 确认经过 Normal Map 节点；
3. 检查 UV 是否在纹理后被修改；
4. 检查目标引擎绿色通道方向；
5. 旋转灯光检查，而不是只看颜色。

### Texture Paint 后重开文件，修改消失

原因：只保存了 `.blend`，没有保存外部图片。

处理：在 Image Editor 中执行 Save / Save As，或明确使用 Pack Resources，并验证重新打开后仍存在。

### 两个材质槽时画笔没有反应

原因：当前选中了另一个材质槽或另一张图片。

处理：检查活动材质槽、Image Texture 节点和当前绘制 Canvas 是否一致。

## 最终质量门禁

### UV 与覆盖

- [ ] UV 在纹理生成后没有移动。
- [ ] 没有非预期 UV 重叠。
- [ ] 正、背、左、右、顶、底均有覆盖。
- [ ] 接缝不在最显眼主视面，或已经修干净。
- [ ] 重要表面拥有足够像素。

### Base Color

- [ ] 没有画死的强阴影和高光。
- [ ] 没有 AI 乱码、假文字和随机符号。
- [ ] 材质分区没有互相渗色。
- [ ] 左右和前后设计符合参考图。

### PBR

- [ ] Normal 使用 Non-Color 并经过 Normal Map 节点。
- [ ] Metallic 的金属与非金属区域明确。
- [ ] Roughness 在旋转灯光下有合理反射差异。
- [ ] Emission 强度可控，没有颜色过曝。
- [ ] AO 按目标引擎规则使用，没有被误当普通颜色图。

### 游戏交付

- [ ] 保留 2K 母版。
- [ ] 交付贴图真实为 512×512。
- [ ] 文件名稳定并能区分各贴图用途。
- [ ] 模型只引用最终交付贴图路径。
- [ ] 在目标游戏的正常相机距离下检查清晰度。
- [ ] 导入后法线、金属、粗糙、透明和发光方向正确。

## 推荐文件结构

```text
道具名/
├─ source/
│  ├─ prop_low_uv_final.fbx
│  ├─ reference_front.png
│  ├─ reference_back.png
│  └─ reference_side.png
├─ texture_master_2k/
│  ├─ Prop_BaseColor_2K.png
│  ├─ Prop_Normal_2K.png
│  ├─ Prop_Roughness_2K.png
│  └─ Prop_Metallic_2K.png
├─ game_512/
│  ├─ Prop_BaseColor_512.png
│  ├─ Prop_Normal_512.png
│  ├─ Prop_Roughness_512.png
│  └─ Prop_Metallic_512.png
└─ blender/
   └─ prop_textured_final.blend
```

## 与现有工作流的关系

- 上一步：[[AI x 3D 第4课｜游戏道具拓扑重构与优化]]
- UV 检查：[[UV]]
- 武器资产入口：[[Roblox 武器模型制作工作流]]
- 最终导入包：[[Roblox 可直接导入版打包流程]]

## 最终记忆句

> 清晰游戏纹理不是“把一张漂亮图片贴上去”，而是冻结正确 UV，在 Albedo 模式逐面投影并修补，再让 Normal、Roughness、Metallic 和引擎光照各自承担正确职责。
