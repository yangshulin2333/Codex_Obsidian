---
type: workflow
domain: roblox
status: active
owner: mixed
source: mixed
created: 2026-08-17
updated: 2026-08-17
---

# Roblox 单侧视图生成工作流

> 版本：v1.0（2026-08-17）

## 一句话说明

这是一套只生成或修复**一张严格侧视图**的通用工作流，适用于 Roblox 武器、法杖、工具、机器、宝箱、瓶罐、装饰件和其他单体道具的 Tripo、混元 3D、Meshy 等图生 3D 参考图。

它不要求先做完整四视图，也不默认同时生成左右两侧。

## 解决的问题

常见失败包括：

1. 生成的是 3/4 视角，不是正交 90°。
2. 武器或道具仍然斜着摆，没有沿竖直中轴站直。
3. 把正视图横向压扁，保留了完整正面纹理和宝石。
4. 平面型物体被压成一像素线，厚度完全丢失。
5. 体块型物体被误判为薄片，圆鼓、锤头或箱体体积消失。
6. 宽而薄的层叠盘形结构露出完整正面，或反过来被压得过薄。
7. 左右侧的可见内容被自动猜测，单侧结构、数量、顺序或遮挡错误。
8. 已通过的一侧被直接镜像，却没有获得用户授权。
9. 候选图混入正式目录，或者找不到可直接审核的文件。
10. 图像生成卡顿后重复提交任务，产生多个无法追踪的候选。

## 工作流边界

本工作流负责：

- 从已确认正视图、背视图或结构证据生成一张 `left / right / side_a / side_b`。
- 修复已有侧视图的相机、姿态、体积、遮挡和一致性问题。
- 记录当前目标侧的可见性合同、几何分类、相机参数和验收结果。
- 输出可供 Tripo / 混元 3D / Meshy 等平台使用的单张工程侧视参考图。

本工作流不负责：

- 自动补齐完整四视图。
- Blender 建模、修模、UV、贴图或 FBX / GLB 导出。
- Roblox Studio 导入和运行时装配。
- 从单张正视图凭空确定没有证据的背面或隐藏结构。

需要完整四视图时，转到：

- [[../Tripo多视图工作流/README|Tripo 多视图工作流]]

## 最短触发口令

```text
参考：D:\AI\Codex\Codex_Obsidian\81_WorkFlow 工作流\Roblox\模型相关\单侧视图工作流
基于我提供的当前资产，只生成一张严格正交 90° 的 <left / right / Side A / Side B>。
先复述相机、几何分类、必须看见和必须隐藏的结构，再生成。
```

如果用户已经把目标方向和可见内容说清楚，Codex 复述一次后直接执行，不重复提问。

## 核心原则

```text
一次只处理一个资产、一个目标方向、一个活动生成任务。
先锁输入，再锁相机，再判断体积，再写可见性合同，最后生成。
“正交 90°”只解决相机方向，不自动解决厚度、遮挡和左右内容。
```

## 方向约定

本工作流默认把已确认正视图定义为 `yaw=0°`：

| 输出名 | 相机方向 | 固定参数 |
|---|---:|---|
| `left.png` | `yaw=-90°` | `projection=ORTHOGRAPHIC, pitch=0°, roll=0°` |
| `right.png` | `yaw=+90°` | `projection=ORTHOGRAPHIC, pitch=0°, roll=0°` |

重要规则：

1. 不同平台若采用相反的 yaw 正负号，必须先重新映射文件名和观察方向；同一运行中不能悄悄交换定义。
2. 如果 `left / right` 语义存在歧义，先使用 `Side A / Side B`，写清楚相机方向和可见结构，再映射正式文件名。
3. `left.png` 和 `right.png` 是两个独立输出合同，不因外观近似而自动互换。

## 输入合同

开始前最少需要：

1. **当前资产设计锁**：优先使用已确认的正视图。
2. **目标侧**：`left / right / Side A / Side B` 中的一个。
3. **主轴**：物体应沿哪条轴竖直或水平摆放。
4. **主要锚点**：头部中心、手柄起止、环箍、插槽、尾饰、轮轴或关键接口位置。
5. **可见性合同**：该侧必须看见和必须隐藏的结构。

强烈建议但非强制：

- 已确认背视图：用于双面结构、背面凸起和层厚判断。
- 已确认另一侧：只能作为厚度、比例和锚点基准，除非用户明确授权镜像。
- 结构草图、45° 图或模型截图：只用于补充被正背视图遮挡的体积证据。

如果关键隐藏结构没有任何证据，并且不同解释会明显改变侧视结果，记录 `SIDE_GEOMETRY_EVIDENCE_MISSING`，向用户询问一次后停止生成。

## 上下文减载门

每次生成最多加载 5 张当前资产图片：

1. 当前已确认正视图。
2. 当前已确认背视图（如有）。
3. 当前目标的结构补充图（如有）。
4. 已通过的另一侧厚度基准（如有）。
5. 当前待修候选（仅在精确修复时使用）。

禁止加载：

- 旧资产候选。
- 当前资产所有失败图。
- 与目标侧无关的联系表或平台结果。
- 上一把武器、上一件道具的设计锁。

## 几何分类门

侧视生成前必须选择一个**基础几何类**，再叠加零个或多个**修饰合同**。

### 基础几何类

| 代码 | 类型 | 典型资产 | 合格侧视 |
|---|---|---|---|
| `P1_THIN_PLATE` | 薄片 / 薄刃 | 剑、刀、薄镰刃、盾牌薄板 | 窄边，但仍有可读厚度、倒角和插槽 |
| `P2_LONG_HEAD` | 长柄枪头 / 长窄头 | 枪、矛、戟、长钻头 | 头部变窄但保持长度、护颈和连接轮廓 |
| `P3_LAYERED_FLAT_VOLUME` | 层叠盘形 / 扁体块 | 辐轮法杖头、徽章盘、双面宝石盘 | 正面结构重叠成窄体块，保留多层真实厚度 |
| `V1_ROUND_VOLUME` | 圆体块 / 旋转体 | 狼牙棒、球锤、圆鼓、瓶罐 | 侧面仍有接近真实的圆鼓、球体或圆柱体积 |
| `V2_BOX_IRREGULAR_VOLUME` | 箱体 / 不规则厚体 | 锤头、宝箱、机器、厚重工具 | 按结构卡保留前后深度、转角和接口，不套统一“变窄”规则 |
| `O1_OPEN_FRAME` | 开放框架 / 空腔 | 镂空机械框、轮架、门框、开放支架 | 保留侧向可见孔洞、支撑杆、前后梁与空腔关系 |

### 修饰合同

| 代码 | 含义 | 额外要求 |
|---|---|---|
| `A_ASYMMETRIC` | 单侧或方向性结构 | 记录数量、顺序、位置和遮挡；另一侧不得复制 |
| `D_DOUBLE_SIDED` | 正反两面都有装饰 | 侧面只显示两侧薄边或浅凸层，不露完整正反面 |
| `R_ROTATIONAL` | 绕主轴近似旋转对称 | 可以减少方向性猜测，但不能自动授权镜像文件 |
| `H_SHAFT_ANCHORED` | 长柄 / 长轴资产 | 锁定柄长、直径、环箍、接口和尾饰锚点 |
| `C_CAVITY_CRITICAL` | 孔洞或插槽是识别点 | 明确侧面应完整、部分还是完全遮挡 |

### 分类决策树

```text
侧面是否应保留接近正面的圆/球/鼓体积？
├─ 是 -> V1_ROUND_VOLUME
└─ 否
   ├─ 是否是开放框架或关键空腔？ -> O1_OPEN_FRAME
   ├─ 是否是箱体、锤头或不规则厚体？ -> V2_BOX_IRREGULAR_VOLUME
   ├─ 是否正面很宽但前后较薄，并有多层结构？ -> P3_LAYERED_FLAT_VOLUME
   ├─ 是否是长枪头、长钻头或狭长护颈？ -> P2_LONG_HEAD
   └─ 其余薄刃 / 薄板 -> P1_THIN_PLATE
```

分类不确定时，不要只写 `make it thin`。先输出两种可能分类及其侧面差异，选择证据更充分的一种；两种都合理且影响很大时询问用户。

## 单侧可见性合同门

每个目标文件必须单独填写：

| 字段 | 内容 |
|---|---|
| `target_view` | `left / right / Side A / Side B` |
| `camera` | `single camera / orthographic / yaw / pitch / roll` |
| `must_visible` | 必须看见的主体厚度、凸起、孔洞、尖刺、插槽、环箍、接口 |
| `must_hidden` | 必须隐藏的完整正面、完整背面、另一侧结构、被遮挡结构 |
| `count_order_position` | 单侧零件数量、从上到下顺序、前后位置 |
| `occlusion` | 完整可见、露薄边、部分遮挡、完全隐藏 |
| `thickness_landmarks` | 主体、装饰、环、宝石框、把手和尾饰的相对厚度 |
| `forbidden_transfer` | 不得从另一侧复制过来的结构 |

合同示例：

```text
target_view: right.png
camera: single camera, orthographic, yaw=+90°, pitch=0°, roll=0°
must_visible: 主体侧壁、后置圆环边缘、正反宝石薄边、长柄、环箍、尾饰侧面
must_hidden: 完整正面辐臂、完整方形宝石面、展开的圆盘轮廓
count_order_position: 上方主体 1 组；柄部环箍从上到下 2/1/2；尾饰 1 组
occlusion: 正反宝石仅露薄边；后置圆环只露边缘厚度
forbidden_transfer: 不复制 left 的高光、切面像素或单侧缺口
```

未完成时记录 `SIDE_VISIBILITY_CONTRACT_MISSING`，禁止生成。

## 锚点与比例锁

生成前至少记录：

| 锚点 | 要求 |
|---|---|
| 总高度 / 总长度 | 与设计锁一致 |
| 主体中心 | 在画布中的相对高度不变 |
| 柄 / 轴起点和终点 | 不缩短、不拉长、不弯曲 |
| 环箍 / 插槽 / 接口 | 数量和高度顺序一致 |
| 尾饰 / 端帽 | 位置、长度和厚度一致 |
| 画布 | 与设计锁或父工作流统一尺寸、边距和背景 |

只允许等比缩放、平移和补边。禁止为了塞入画布而非等比压扁侧视主体。

## 标准执行流程

### S0：建立单侧运行

记录：资产名、父工作流（如有）、目标侧、输出模式和当前活动任务。

状态：`SIDE_RUN_CREATED`

### S1：锁定输入

为每张输入图标明角色：

```text
Image 1: accepted front design lock
Image 2: accepted back / double-sided evidence（可选）
Image 3: structure or 45° evidence（可选）
Image 4: accepted opposite-side thickness benchmark only（可选）
Image 5: current edit target（仅修复模式）
```

状态：`SIDE_INPUT_LOCKED`

### S2：锁定相机

必须明确：

```text
camera_count=1
projection=ORTHOGRAPHIC
view=<LEFT / RIGHT / SIDE A / SIDE B>
yaw=<-90° / +90° / confirmed semantic direction>
pitch=0°
roll=0°
```

状态：`SIDE_CAMERA_LOCKED`

### S3：锁定几何分类与修饰合同

选择一个基础类，并记录所有适用修饰合同。

状态：`SIDE_GEOMETRY_CLASSIFIED`

### S4：确认可见性合同

Codex 先复述当前目标侧的必须可见、必须隐藏、数量、顺序、遮挡和不得复制内容。

- 用户已经说清楚：复述后直接继续。
- 关键内容没有证据：只问缺失部分。
- 不得把“看起来对称”当成镜像授权。

状态：`SIDE_VISIBILITY_CONFIRMED`

### S5：组装提示词

提示词必须按顺序包含：

1. 输入图片角色。
2. 单相机正交参数。
3. 基础几何类的侧面解释。
4. 当前目标侧的可见性合同。
5. 锚点和比例锁。
6. 风格、材质、背景。
7. 明确禁止项。

使用 [[PROMPT_TEMPLATES|提示词模板]]。

状态：`SIDE_PROMPT_READY`

### S6：生成一个候选

一次只提交一个目标侧任务。

生成任务超过 15–20 秒没有结果时：

1. 给用户简短状态更新。
2. 等待或恢复原任务。
3. 禁止提交第二个相同任务。
4. 只有确认原任务失败，才允许重试一次。

状态：`SIDE_GENERATING -> SIDE_CANDIDATE_READY`

### S7：自动检查

按 [[CHECKLIST|验收清单]] 检查：

1. 文件存在、可解码、尺寸有效。
2. 单相机正交 90°，无 3/4 和透视。
3. 主轴姿态正确，完整进入画面。
4. 侧面体积符合几何分类。
5. 可见性合同满足。
6. 设计、材质、锚点和画布没有漂移。
7. 没有文字、水印、UI、角色、手和场景杂物。

失败时只修当前候选，不重做已确认输入。

状态：`SIDE_AUTO_CHECK_PASSED` 或 `SIDE_CANDIDATE_REJECTED`

### S8：打开审核副本

将候选**复制**到短英文审核路径：

```text
<workspace_root>\_side_view_review\<asset_slug>\<target_view>.png
```

可以复用 Tripo 工作流的图片打开脚本：

```powershell
& "D:\AI\Codex\Codex_Obsidian\81_WorkFlow 工作流\Roblox\模型相关\Tripo多视图工作流\scripts\Open-ReviewImage.ps1" `
  -ImagePath "<review_png>" `
  -OpenImage
```

聊天中直接渲染图片；本地 Markdown 链接不是审核的唯一入口。

状态：`SIDE_WAITING_USER_REVIEW`

### S9：人工确认

用户明确说“确认、可以、这版很好、就用这张”等，才提升为正式侧视。

如果用户只说某个局部好，但仍指出其他问题，不视为整体确认。

状态：`SIDE_USER_APPROVED`

### S10：正式化与交付

两种模式：

#### 独立单侧模式

```text
<run_dir>\00_final_side_view\<target_view>.png
```

`00_final_side_view` 只包含当前已确认的一个 PNG，不放文档、候选、检查图或子目录。

#### 父工作流修复模式

把已确认文件写入父工作流规定的正式目标，例如：

```text
<four_view_run>\00_final_tripo_upload\right.png
```

只替换当前目标侧，不改动其他正式视图。

记录 SHA-256、尺寸、来源候选、用户确认原话和日期。

状态：`SIDE_FINALIZED`

## 另一侧的生成与镜像规则

### 独立生成（默认）

已通过的一侧可以作为：

- 总高度基准。
- 画布和边距基准。
- 厚度基准。
- 柄长、环箍、接口、尾饰的锚点基准。

但不能作为：

- 镜像源。
- 像素编辑目标。
- 单侧结构复制源。
- 高光和遮挡的固定模板。

提示词必须写：

```text
Use the accepted opposite-side view only as a thickness, landmark and framing benchmark.
Independently reconstruct the opposite camera direction.
Do not copy, flip, mirror, trace or reuse its pixels.
```

### 用户明确授权镜像

只有用户明确指定来源、目标和“允许镜像”时才执行，例如：

```text
允许 right.png 由已确认 left.png 做确定性水平镜像。
```

执行要求：

1. 使用本地确定性水平翻转，不调用生成模型伪造镜像。
2. 做往返翻转像素校验，预期误差为 0。
3. 记录 `source_view / target_view / authorized_by_user / date`。
4. 如果用户要求“单独生成”，镜像授权立即失效。

## 恢复路径

```text
相机不是 90°
-> 保留设计锁和可见性合同
-> 只强化 camera block
-> 重做当前候选

正面被横向压扁
-> 改写几何解释
-> 指定侧面应保留的厚度、层次和遮挡
-> 禁止把 front 当编辑目标

侧面过薄
-> 检查是否误分为 P1
-> 改为 P3 / V1 / V2
-> 补结构卡和最小厚度层次

侧面过宽或露完整正面
-> 强化 must_hidden
-> 明确 face-on detail 只能显示 edge/sliver
-> 重做当前候选

左右内容错误
-> 回到该文件自己的可见性合同
-> 不参考另一侧的单侧细节

生成任务卡住
-> 等待 / 恢复唯一活动任务
-> 不重复提交

连续两次同类失败
-> 停止盲目生图
-> 重写几何卡或补一张结构证据图
-> 必要时改用 Blender 简单块模正交渲染
```

完整失败码见 [[FAILURE_CODES|失败码与恢复表]]。

## 目录结构

```text
<run_dir>/
  00_final_side_view/
    <target_view>.png
  _candidates/
  _checks/
  _docs/
    RUN_STATE.md
    PROMPT.md
```

父工作流修复模式不额外建立第二套正式目录，遵循父工作流的正式目录合同。

## 状态机

```text
SIDE_RUN_CREATED
-> SIDE_INPUT_LOCKED
-> SIDE_CAMERA_LOCKED
-> SIDE_GEOMETRY_CLASSIFIED
-> SIDE_VISIBILITY_CONFIRMED
-> SIDE_PROMPT_READY
-> SIDE_GENERATING
-> SIDE_CANDIDATE_READY
-> SIDE_AUTO_CHECK_PASSED
-> SIDE_WAITING_USER_REVIEW
-> SIDE_USER_APPROVED
-> SIDE_FINALIZED
```

任一步失败：

```text
SIDE_CANDIDATE_REJECTED
-> 记录一个主失败码
-> 只修当前失败层
-> 返回对应 Gate
```

## 人工与自动边界

| 环节 | Codex 自动完成 | 用户确认 |
|---|---|---|
| 输入读取 | 识别当前设计锁与证据图 | 输入含义有歧义时确认 |
| 几何分类 | 提出基础类和修饰合同 | 多种解释会明显改变侧视时选择 |
| 可见性合同 | 复述必须可见/隐藏、数量、顺序、遮挡 | 关键隐藏结构和单侧内容 |
| 图像生成 | 组装提示词并生成一个候选 | 不需要操作工具 |
| 自动验收 | 检查相机、体积、锚点、背景和文件 | 不替代视觉审美确认 |
| 正式化 | 复制正式文件、记录哈希和尺寸 | 必须明确批准候选 |
| 镜像 | 只在授权后做确定性翻转 | 必须明确授权来源与目标 |

## 交接合同

新对话继续时只提供：

1. 当前运行目录。
2. `_docs/RUN_STATE.md`。
3. 当前设计锁图片。
4. 当前目标侧。
5. 当前可见性合同。
6. 下一步是生成、修复还是等待确认。

不要重新扫描旧候选目录。

模板见 [[RUN_STATE_TEMPLATE|运行状态模板]]。

## 最终验收标准

侧视正式化必须全部满足：

- [ ] 单相机正交 90°。
- [ ] `pitch=0°`、`roll=0°`，无 3/4 和透视。
- [ ] 主轴姿态与合同一致，完整可见。
- [ ] 体积符合基础几何类。
- [ ] 当前目标侧的必须可见、必须隐藏、数量、顺序和遮挡正确。
- [ ] 总高度、主体中心、柄长、接口、环箍和尾饰锚点一致。
- [ ] 没有把正视图横向压扁。
- [ ] 没有未经授权镜像或复制另一侧。
- [ ] 画布、背景、材质和风格与设计锁兼容。
- [ ] 用户已明确确认。
- [ ] 正式文件可解码，路径、尺寸和 SHA-256 已记录。

## 相关文件

- [[快速执行卡_QUICK_START|快速执行卡]]
- [[PROMPT_TEMPLATES|通用提示词模板]]
- [[CHECKLIST|验收清单]]
- [[FAILURE_CODES|失败码与恢复表]]
- [[RUN_STATE_TEMPLATE|运行状态模板]]
- [[STATUS|工作流状态与升级证据]]
- [[../Tripo多视图工作流/README|Tripo 多视图工作流]]
