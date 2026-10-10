---
type: workflow
domain: roblox
status: active
owner: mixed
source: mixed
created: 2026-08-04
updated: 2026-08-12
---

# Roblox 魔法剑模型制作工作流

## 定位

这条工作流负责把一把魔法剑的设计意图转成适合 Tripo、混元 AI 等 image-to-3D 工具的 8 张参考图。

它只负责：

- 效果图确认。
- 跨视图设计一致性。
- 严格正交视图和低透视 45 度辅助视图。
- 输出文件、联系表和质量门禁。

它不负责：

- 生成后的网格清理、UV 修复和减面。
- FBX / GLB 打包。
- Roblox Studio 导入、挂载和性能验收。

后续环节按需路由到相邻工作流，不在本目录复制实现：

- `../Roblox 武器模型制作工作流/Tripo武器低模清理与局部纹理修复流程.md`
- `../Roblox 武器模型制作工作流/Roblox导入_直接可用打包流程.md`

## 核心原则

1. 图片是几何输入，不是宣传插画。
2. 先确认一张效果图，再生成正式 8 视图。
3. 先锁定 X、Y、Z 三个真实轴，再决定每张图的相机和画布占比。
4. 生成 `left/right/left45/right45` 前，Codex 必须主动询问并复述每个输出的可见性合同，得到用户确认后才可生成。
5. 不得把“是否对称”作为默认分流条件，也不得根据外观自行决定镜像；复用或镜像几何只在用户明确授权指定输出对时允许，并记录授权。
6. 同一视图不得同时大面积展示一对相反表面。
7. 45 度图必须旋转整把剑，不允许只旋转剑身。
8. 顶部和底部是沿剑长轴观察的 X×Z 端视图，不是另一张完整竖剑图。
9. 装饰必须有厚度、根部和连接层级；华丽不等于增加漂浮碎片。
10. 相机或表面归属失败时必须从纯净来源重新生成，禁止拿失败稿继续编辑。
11. 轴向视图只能引用同一资产的已通过视图；禁止引用另一资产的 top/bottom 作为布局模板。
12. 正式上传目录只保留当前发布模式要求的 6 张或 8 张最终 PNG。
13. image-to-3D 结果必须反查参考图；好看的 2D 图不等于有效的 3D 输入。

## 参数化输入

每次执行先填写，禁止在工作流中写死具体项目、等级、配色或绝对输出路径。

```text
ASSET_NAME=资产名称
ASSET_TYPE=longsword | greatsword | shortsword | other
MODEL_TARGET=Hunyuan | Tripo | other
OUTPUT_ROOT=本次任务的输出根目录
CANVAS_SIZE=生成器原生正方形尺寸
STYLE_REFERENCE=可选，只继承视觉 DNA
UPLOAD_VIEW_MODE=Eight | Six
AXIAL_SOURCE_MODE=same_asset_ai | proxy_render | not_included
SIDE_VISIBILITY_CONTRACT_STATUS=draft | confirmed
SIDE_GEOMETRY_REUSE_AUTHORIZATION=none | user_confirmed
SIDE_GEOMETRY_REUSE_AUTHORIZED_OUTPUTS=无 | 例如 left->right
```

`CANVAS_SIZE` 不固定为某个像素值。正式 8 图只要求：

- 全部为相同尺寸。
- 全部为正方形。
- 同一资产保持相同边距策略。
- 不拉伸单独一个轴来填满画布。

## 视觉 DNA

每把剑单独填写：

```text
造型语言：
主色 / 辅色 / 核心色：
主体金属：
宝石或能量材质：
装饰密度：
块面尺寸：
剑刃轮廓：
护手轮廓：
握柄与剑首轮廓：
Roblox 游戏资产质感：
禁止风格：
```

引用其他道具时，只继承配色、材质、块面和装饰语言，不复制原道具轮廓与部件用途。其他资产的轴向图不得作为当前资产 `top.png` 或 `bottom.png` 的图像参考。

## L0-L3 结构层级

```text
L0：剑身、剑茎、握柄主体。
L1：护手承力块、剑脊、宝石托座、剑首连接块。
L2：刃面装甲、翼板、冠形护手、大块浮雕。
L3：嵌入式晶体、能量槽、核心宝石。
```

连接规则：

- L2/L3 必须通过 L1 连接到 L0。
- 晶体必须嵌入托座，不允许直接悬浮。
- 翼板、长刺和冠部必须有宽根部。
- 护手必须有真实 Z 厚度，不得只是正面贴片。
- 不使用链条、细丝、漂浮碎片和无法从侧面解释的薄饰片。

## XYZ 几何锁

统一坐标：

```text
X：护手左右宽度。
Y：剑尖到剑首的长轴。
Z：正面到背面的厚度。
```

投影关系：

| 文件 | 相机方向 | 投影平面 | 必须显示 | 必须隐藏 |
|---|---|---|---|---|
| `front.png` | 从 +Z 看向 -Z | X×Y | 完整正面 | 背面、大面积侧面 |
| `back.png` | 从 -Z 看向 +Z | X×Y | 完整背面 | 正面、大面积侧面 |
| `left.png` | 从 -X 看向 +X | Z×Y | 已确认合同中的 must-visible | 已确认合同中的 must-hidden |
| `right.png` | 从 +X 看向 -X | Z×Y | 已确认合同中的 must-visible | 已确认合同中的 must-hidden |
| `top.png` | 从 +Y 看向 -Y | X×Z | 剑尖端 X×Z 截面 | 完整剑长和正面装甲 |
| `bottom.png` | 从 -Y 看向 +Y | X×Z | 剑首端 X×Z 截面 | 完整剑长和正面装甲 |
| `left45.png` | 绕 Y 轴旋转 -45° | 辅助理解 | 已确认合同中的 must-visible | 已确认合同中的 must-hidden |
| `right45.png` | 绕 Y 轴旋转 +45° | 辅助理解 | 已确认合同中的 must-visible | 已确认合同中的 must-hidden |

所有正交图使用平行投影。45 度图允许极弱透视，但不得使用广角、俯拍、仰拍或游戏图标构图。

## 归一化规则

归一化包含 X、Y、Z 三个方向，不是只让正面图看起来一样大。

- `front/back` 锁定相同 X×Y 包围盒。
- `left/right` 锁定相同 Z×Y 包围盒。
- `top/bottom` 锁定相同 X×Z 包围盒。
- 同一张图内两个投影轴必须等比缩放。
- 禁止横向、纵向分别拉伸。
- `top/bottom` 在缩略图中过小时，允许 X 与 Z 使用同一个放大倍数。
- 端视图主体长边建议占画布 60%-80%，但必须保留原始 X:Z 比例。
- `design_lock.md` 同时记录理论包围盒、交付包围盒和端视放大倍数。

## 状态与门禁

```text
BRIEF_READY
-> EFFECT_REVIEW
-> DESIGN_LOCKED
-> SIDE_VISIBILITY_CONTRACT_REVIEW
-> ORTHOGRAPHIC_REVIEW
-> AXIAL_SOURCE_REVIEW
-> AXIAL_REVIEW
-> ANGLE45_REVIEW
-> PACKAGE_REVIEW
-> READY_FOR_IMAGE_TO_3D
-> MODEL_FEEDBACK
```

任何门禁未通过时，不得把资产标为下一状态。轴向视图连续两次失败时进入 `AXIAL_BLOCKED`，只能转为 `proxy_render` 或 `Six` 模式，不能继续用失败图迭代。

## 轴向证据等级

| 等级 | 可用证据 | 允许动作 |
|---|---|---|
| A | 同一资产的真实 3D 代理或已存在模型的正交渲染 | 可直接进入 8 视图轴向验收 |
| B | 同一资产已通过的 front、side 与完整 XYZ / 表面归属锁 | 可生成最多两轮 AI 轴向候选，经人工验收后进入 8 视图 |
| C | 只有 front、缺少厚度证据、引用其他资产端视图或需要依赖失败稿 | 禁止生成伪端视图；改用 6 视图或先建立 3D 代理 |

“看起来像截面”不构成证据。轴向端视必须能由同一资产的正面、侧面、零件表面归属和端面定义共同解释。

## 标准执行流程

### Gate 1：资产 Brief

填写视觉 DNA、用途、复杂度和禁止项。此阶段不要求 Codex 判断或分类“是否对称”。

输出：初版 `design_lock.md`。

### Gate 2：效果图确认

先生成一张 `effect.png`：

- 单把完整魔法剑，竖直居中。
- 纯白或浅灰背景。
- 近正交正面，yaw/pitch/roll 接近 0。
- 不用 3/4 游戏图标构图。
- 不用人物、手、地面、场景、烟雾、粒子和大面积光效。

人工确认造型、比例、配色和装饰层级。未确认前不批量生成 8 视图。

如果效果图本身已经满足严格正面要求，可以复制为 `front.png`；否则重新校准正面。

### Gate 3：设计锁

在 `design_lock.md` 中登记：

- X:Y:Z 比例。
- 剑身、护手、握柄、剑首比例。
- L0-L3 连接层级。
- 关键零件 P-ID、数量、表面归属和连接对象。
- 正面、背面、顶部和底部的可见性。
- `left/right/left45/right45` 各自的 must-visible、must-hidden，以及方向性结构的数量、位置和遮挡关系。
- 侧向可见性合同的用户确认记录；若允许两个指定输出共用或镜像几何，还要记录用户授权原文、输出对和时间。
- top/bottom 的证据等级、允许参考源和禁止参考源。
- 剑尖端、剑首端以及正面专属装饰在轴向视图中的可见形态。
- 理论包围盒与交付画布策略。

### Gate 4：正面与背面

1. 生成或确认 `front.png`。
2. 生成 `back.png`。
3. 检查总长、最大宽度、护手和握柄位置完全一致。
4. 背面允许简化纹章，但不允许换成另一把剑。
5. 正面核心不能无理由复制成背面同样高凸核心。

### Gate 5：严格左右侧面

在生成任何侧视图或 45 度图之前，先执行一次侧向可见性合同门禁：

1. Codex 主动逐项询问 `left.png`、`right.png`、`left45.png`、`right45.png` 各自的 must-visible 与 must-hidden。
2. 对每个输出继续询问所有方向性结构的 P-ID、数量、位置、朝向，以及被哪个零件遮挡或遮挡哪个零件。
3. Codex 用文件名和相机方向复述四份合同；用户明确确认后，将确认内容写入 `design_lock.md`。
4. 合同缺失时停止生成并记录 `SIDE_VISIBILITY_CONTRACT_MISSING`；不得用“看起来应该一样”补空白。
5. 先按 `left.png` 合同生成并验收真实 90 度侧视，再按 `right.png` 合同独立生成并验收。
6. 只有用户明确授权指定两个输出共用几何时，才允许镜像或复用；授权必须记录，Codex 不得根据外观或“对称性”自行授权。
7. 检查剑刃、护手、核心托座、握柄和剑首是否收成合同要求的真实窄侧面，并逐 P-ID 核对数量、位置和遮挡。

侧视图看到合同要求隐藏的表面，或缺失/新增/错位任何方向性结构，记录 `SIDE_VISIBILITY_CONTRACT_BROKEN` 并重做该单图。未经记录授权而镜像或复用，记录 `UNCONFIRMED_SIDE_MIRROR` 并直接判废。

### Gate 6：顶部与底部轴向端视图

先执行来源门禁：

1. 只允许使用当前资产的 `front.png`、一张已通过的严格 side、`design_lock.md`，或当前资产的真实 3D 代理渲染。
2. 禁止引用其他资产的 `top.png` / `bottom.png`，即使只想借用布局。
3. 禁止把任何失败候选图作为修复或重生成参考。
4. `top` 与 `bottom` 必须独立从纯净来源生成；二者只能共享数值化 X:Z、零件清单和画布占比，不能互相复制像素结构。

再执行几何门禁：

1. `top.png` 从剑尖看向剑首；`bottom.png` 从剑首看向剑尖。
2. 图中只表达 X×Z 截面层级，Y 方向可见长度接近 0。
3. 允许 X/Z 等比放大到画布长边 60%-80%。
4. 所有正面专属 P-ID 必须压缩成边缘或完全隐藏，不得保留完整正面轮廓。
5. 剑首正面宝石在 bottom 中应变成实体端盖或极窄彩色侧边，不能把完整宝石正面旋到端面。
6. top 与 bottom 的最大 X 宽度、Z 厚度和中心层级必须能由 front / side 解释。

以下情况必须重做：

- 护手被摊开成宽平面。
- 完整剑身横放在画面中。
- 正面装甲、晶体或宝石重复到轴向端面。
- 弯曲护手、翼板或叶甲被改画成与原结构无关的笔直导轨。
- top 与 bottom 使用不同的中央结构，或出现未登记的端盖、圆环和宝石。
- 端视图主体太小，平台缩略图近似空白。
- 单独拉宽 X 或拉厚 Z。

失败恢复：

1. 第一次失败：移入 `失败对照/`，从同一资产纯净来源重新生成，尝试次数记为 2。
2. 第二次失败：状态设为 `AXIAL_BLOCKED`，停止 AI 轴向重试。
3. 后续只能选择真实 3D 代理渲染，或把 `UPLOAD_VIEW_MODE` 改为 `Six`。

### Gate 7：左右 45 度辅助图

1. 仅在四份侧向可见性合同均已确认后开始。
2. `left45.png` 与 `right45.png` 分别按自己的 must-visible、must-hidden、结构数量、位置和遮挡合同生成。
3. 整把剑作为一个刚体绕 Y 轴旋转；剑身、护手、握柄、剑首和所有嵌件使用同一个 yaw。
4. 正面平面装饰必须出现一致的横向缩短。
5. 默认分别生成和验收两张图；只有用户已明确授权指定输出对共用几何时，才允许镜像或复用。

如果剑身已经侧转，但护手、宝石或握柄纹理仍完整正对相机，判定为 `ANGLE45_PARTIAL_ROTATION`。若图像违反已确认可见性合同，同时记录 `SIDE_VISIBILITY_CONTRACT_BROKEN`。

### Gate 8：联系表

生成：

- `orthographic_preview_contact_sheet.png`：front、back、left、right、top、bottom。
- `reference_preview_contact_sheet.png`：top、left45、front、right45、left、right、back、bottom。

联系表只用于人工检查，不放入正式上传目录。

联系表不能单独完成轴向验收。必须把 front、side、top、bottom 四张单图以全分辨率打开，逐个核对正面专属 P-ID、Z 厚度、剑尖端和剑首端的表面归属。

### Gate 9：自动与人工验收

先从 `VIEW_REVIEW_TEMPLATE.json` 复制当前资产的 `view_review.json`，由完成全分辨率视觉复核的人填写。然后运行：

```powershell
powershell -ExecutionPolicy Bypass -File .\Validate-ViewSet.ps1 `
  -AssetDir "<资产目录>\00_final_image_to_3d_upload" `
  -ViewMode Eight `
  -ReviewManifestPath "<资产目录>\view_review.json" `
  -RequireSemanticAttestation `
  -RequireSquare
```

六视图降级时把 `-ViewMode` 改为 `Six`，上传目录中不得保留 top/bottom。`Validate-8ViewSet.ps1` 仅作为旧命令兼容入口。

自动脚本验证文件契约、尺寸和人工确认记录是否完整，但不能判断图像里的真实相机和几何。不得由生成步骤直接把所有确认字段预填为 `true`。

### Gate 10：image-to-3D 反馈

模型生成后检查：

- 剑刃厚度是否合理。
- 护手层是否融合或漂浮。
- 宝石托座是否有深度。
- 顶/底端盖是否被误封。
- 左右侧是否出现正面贴片拉伸。

如果模型失败，先定位是哪张输入图提供了错误证据，再修单张。不要默认整批重做。

## 输出目录契约

```text
{OUTPUT_ROOT}/{ASSET_NAME}/
  effect.png
  design_lock.md
  front.png
  back.png
  left.png
  right.png
  top.png
  bottom.png
  left45.png
  right45.png
  orthographic_preview_contact_sheet.png
  reference_preview_contact_sheet.png
  reference_notes.md
  view_review.json
  失败对照/
  00_final_image_to_3d_upload/
    front.png
    back.png
    left.png
    right.png
    top.png        # Eight 模式才包含
    bottom.png     # Eight 模式才包含
    left45.png
    right45.png
```

`00_final_image_to_3d_upload/` 在 `Eight` 模式必须恰好包含 8 张 PNG，在 `Six` 模式必须恰好包含 front、back、left、right、left45、right45 六张 PNG。不得包含 JSON、Markdown、联系表、效果图、失败稿、子目录或其他文件。

## 混元多视图槽位顺序

```text
top -> left45 -> front -> right45
left -> right -> back -> bottom
```

文件名是权威契约，平台 UI 顺序变化时按槽位语义上传，不按缩略图猜测。

## 失败恢复

| 失败 | 处理 |
|---|---|
| 效果图未确认 | 停止，不生成正式多视图 |
| 单张视角不正 | 移入 `失败对照/`，只重做该视图 |
| `SIDE_VISIBILITY_CONTRACT_MISSING` | 停止生成所有侧视和 45 度图；Codex 主动补问、逐文件复述并等待用户确认 |
| `SIDE_VISIBILITY_CONTRACT_BROKEN` | 归档失败图；依据已确认的单图合同从纯净来源重做，不改动其他已通过视图 |
| `UNCONFIRMED_SIDE_MIRROR` | 候选直接判废；清除未授权镜像/复用结果，改为独立生成或先取得并记录用户授权 |
| 轴向候选引用另一资产 | 直接判废，不进入视觉验收；清除跨资产参考后重生 |
| 轴向修复依赖失败稿 | 直接判废；不得继续 edit，必须从同资产纯净来源重生 |
| top/bottom 第一次失败 | 归档失败稿，从同一资产 front + side + design lock 独立重生 |
| top/bottom 第二次失败 | 进入 `AXIAL_BLOCKED`；改用真实 3D 代理或 Six 模式 |
| 45 度局部旋转 | 强制整剑刚体旋转，不单独修饰局部 |
| 文件尺寸不一致 | 等比缩放并居中到统一正方形画布，禁止拉伸 |
| 3D 模型局部异常 | 反查提供该结构信息的 2-3 张图，只修证据冲突的图片 |

## 人工与自动边界

人工负责：

- 效果图审美确认。
- 判断结构是否真实可建模。
- 判断相机可见面与零件连接是否合理。
- 填写 `view_review.json` 的轴向来源和视觉确认字段。
- image-to-3D 模型验收。

自动工具负责：

- 生成候选图。
- 执行已确认的逐输出可见性合同。
- 仅在存在用户明确授权记录时，对指定输出对执行几何复用或镜像。
- 等比归一化画布。
- 生成联系表。
- 验证文件名、数量、格式和尺寸。
- 验证 `view_review.json` 的发布模式与人工确认字段是否完整。

自动处理不得擅自重画已确认的结构、增加零件或通过拉伸掩盖比例错误。

## 本轮实测依据

本版本在 5 把不同造型魔法剑的批量生成中完成文件契约测试，并通过后续轴向复盘暴露出视觉验收缺口。主要问题：

- 顶视图把护手展开成宽平面。
- 顶视图横向重复正面装甲。
- 底视图左右不对称。
- 顶视图 Z 厚度被夸大。
- 单张图尺寸偏离统一画布。
- 另一资产的 top 被用作当前资产布局参考，产生跨资产模板污染。
- 失败 top 被继续作为修复参考，错误结构被锚定并传给 bottom。
- 联系表缩略图检查通过，但全分辨率表面归属实际不一致。

这些问题已转成来源门禁、两次重试上限、结构化人工确认和六视图降级分支，而不是只作为经验备注。
