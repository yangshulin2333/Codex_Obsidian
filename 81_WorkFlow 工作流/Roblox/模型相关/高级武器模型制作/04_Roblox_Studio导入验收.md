---
type: workflow
domain: roblox
status: active
owner: mixed
source: mixed
created: 2026-08-13
updated: 2026-08-14
---

# 04 Roblox Studio 导入验收

## 目标

验证导入的武器在 Roblox 实际运行环境中保持正确部件、尺寸、材质、连接和可读性。这个阶段验收的是**模型资产**，不添加特效。

## 导入前证据

必须已有：

- `FBX_REIMPORT_VERIFIED` 状态。
- FBX SHA-256、贴图事实源目录和导入说明。
- 期望部件名、数量、总尺寸、总三角面和 Pivot。
- Blender 回导截图或报告。

没有回导证据时停止，记录 `EXPORT_NOT_REIMPORTED`。`FBX_REIMPORT_VERIFIED` 只证明 Blender 能回读，不证明 Studio 的网格/纹理上传队列已经接受。

## 3D Importer 设置

正常导入时只选择最终 FBX；内嵌纹理的包不要求同时选择 PNG/JPG。外部 `textures/` 仅用于证据和失败回退。

预览阶段：

```text
Import Only as Model = On
Add to Workspace = On
Merge Meshes = Off
Insert Using Scene Position = Off
Make Double Sided = Off
Upload to Roblox = Off（先做本地预览；确认后再正式上传）
Scale Unit = 按项目 Manifest
```

正式导入阶段保持其他设置不变，将 `Upload to Roblox = On`，并记录 Creator、队列结果和生成的 Mesh/Texture 资产 ID。若当前 Studio 版本不提供本地预览分支，则直接正式导入，但仍必须先核对预览树。

预览中先核对：

- 最长边是否接近目标 Stud 长度。
- 部件数量和名称是否正确。
- 正面、上方向和握柄方向是否正确。
- 没有参考平面或隐藏旧零件。
- 贴图没有串件、纯白或丢失。

如果导入器预览已经不符，不要点击导入后再手工补救；先修导出包。导入后只能建立运行结构，不能重新移动或旋转零件来弥补 Blender 装配错误。

## Model 结构

剑类推荐：

```text
WeaponModel
├─ Blade      MeshPart
├─ Guard      MeshPart
├─ Handle     MeshPart  # PrimaryPart / Tool Handle 候选
└─ Pommel     MeshPart
```

部件名由项目 Manifest 决定，四件只是猫猫剑案例，不是所有武器的默认数量。

## 基础装配

任何写入前必须确认 `Project / Place`、准确 `target_model_path`、`studio_mode=display/tool/npc`、`root_part`、`anchored_policy` 和用户写入授权。缺一项时只做只读检查，不建立 Weld、不改碰撞属性。

### 展示模型

- `PrimaryPart = Handle` 或项目锁中的根件。
- 根件可以临时 `Anchored = true`。
- 其他视觉件用 `WeldConstraint` 焊接到根件。

### Tool / 游戏武器

- 由 Tool 流程控制根件是否锚定，通常不能保持 Anchored。
- 所有视觉 MeshPart：`CanCollide=false`、`CanTouch=false`、`CanQuery=false`。
- 非根视觉件：`Massless=true`；根件按项目物理策略确定。
- 命中检测使用服务器 Raycast 或简单不可见 Hitbox，不使用破碎的 AI 网格做精确碰撞。

若各视觉部件各自成为 AssemblyRoot 或 Play 后散开，记录 `STUDIO_PARTS_NOT_WELDED`。

## 材质验收

- `BaseColor`/ColorMap 应与部件对应，不串图。
- PBR 贴图按每个 MeshPart 的 SurfaceAppearance 绑定。
- 没有 `Metalness/Roughness/Normal` 时，明确标为 basecolor-only，不用 Studio 数值假装完整 PBR。
- EmissionMask 即使存在，也只是静态材质资产；动态呼吸、Trail 和粒子不在本流程。
- 在当前游戏 Lighting 下检查，不能只在导入器默认灯光判断。

## 三层视觉验收

### 1. 正交检查

- 正面：轮廓、部件比例、主轴和左右装饰。
- 背面：外侧结构、贴图方向和正背关系。
- 左右：厚度、双层结构、刃口/背部方向性结构和接缝。

### 2. 3/4 检查

- 连接处无悬空、透光、明显穿模。
- 宝石、护圈、刃框等不是平面贴片错位。
- 尾饰和握柄共轴。

### 3. 实际游戏相机

- 按玩家实际距离、FOV、Lighting 和画质检查。
- 远看仍能辨认主轮廓和核心配色。
- 细节没有因为贴图分辨率或过滤变糊。
- 武器与角色手、身体和地面尺度协调。

只在特写里好看而在游戏相机中失去层级，不能通过。

## 失败回退

| 现象 | 优先检查 | 处理 |
|---|---|---|
| 部件合并成一个 | `Merge Meshes`、导出 Mesh 数 | 删除本轮 Model，关闭合并后重导 |
| 尺寸错误 | Import Scale Unit、FBX 回导尺寸 | 修包，不在 Studio 随机缩放掩盖 |
| 方向错误 | Blender 导出轴与应用变换 | 修导出副本并回导 |
| 贴图丢失 | 贴图路径、上传权限、SurfaceAppearance | 修贴图包或重新绑定 |
| Play 后散架 | PrimaryPart、WeldConstraint | 建立根件焊接并复测 |
| 接口有缝 | Blender 装配合同 | 回退 WORK_CLEAN，不用光效遮盖 |
| 材质像塑料 | 是否只有 BaseColor、PBR 图是否真实 | 补烘焙贴图并复验 |

### 红叉但原因不明时的隔离顺序

1. 在同一 Studio 会话导入一份已知成功 FBX。
2. 导出同一候选的无贴图对照 FBX。
3. 把实际 PNG/JPG 单独上传，验证图片本身。
4. 比较导入队列、Creator、Mesh/Texture 资产 ID 和精确错误；没有服务器级证据时记录 `STUDIO_IMPORT_FAILED_UNCLASSIFIED`，不得只凭红叉或无关网络警告猜根因。

已知成功文件也失败，优先检查 Studio 会话、权限或上传服务；已知成功文件成功而候选失败，问题才集中到候选 FBX/纹理合同。

## 最终交付证据

保存到 `06_studio_checks/`：

- Explorer 结构截图。
- Importer 设置或导入记录。
- 导入队列结果、Creator，以及 Mesh/Texture 资产 ID；失败时保存准确错误文本。
- 正面、侧面和 3/4 游戏视图截图。
- 目标路径，如 `Workspace.<WeaponModel>` 或资产 ID。
- 部件数、总尺寸、根件、焊接和碰撞检查结果。
- 材质状态：basecolor-only / PBR maps / 待补。
- 用户最终结论。

## `STUDIO_ACCEPTED` 条件

- [ ] 部件数量、名称、尺寸和方向与 Manifest 一致。
- [ ] 正式上传队列成功，网格与贴图资产均已建立；正常导入只选择了最终 FBX。
- [ ] 根件、焊接、碰撞和 Massless 设置符合用途。
- [ ] 正、侧、3/4 无明显装配缺陷。
- [ ] 基础颜色/PBR 贴图正确。
- [ ] 实际游戏相机下比例和可读性通过。
- [ ] 正式 Model 中没有参考平面、旧件、候选或被否决的 VFX。
- [ ] 用户明确确认模型资产本身。

全部通过后，运行状态进入 `STUDIO_ACCEPTED`。动画、伤害和 VFX 只能从这里另开工作流。
