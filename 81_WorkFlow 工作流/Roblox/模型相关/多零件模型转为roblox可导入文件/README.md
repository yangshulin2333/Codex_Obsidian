---
type: workflow
domain: roblox
status: active
owner: mixed
source: mixed
created: 2026-08-14
updated: 2026-08-17
---

# 多零件模型转为 Roblox 可导入文件

## 目标

把 Blender 中已经拼好的多个刚性零件，优先快速导出成一个 Roblox Studio 可导入的 GLB，并保持：

- 每个零件仍是独立 `MeshPart`。
- 零件之间的位置、比例、方向和公共枢轴不变。
- 每个 Mesh 的基础颜色贴图能被识别。
- Studio 不需要重新手工拼接，只需要设置根件、焊接和碰撞属性。

本流程适用于武器、道具、机械装置和多段装饰物。**不适用于**骨骼、蒙皮、角色动画或可变形模型。

## 一句话原则

> Blender 负责把多零件整理成同一坐标系内的完整装配；短英文路径下的 GLB 是默认主交付；FBX 只作为兼容和诊断回退；Studio 只验收和焊接，不重新拼模型。

## 下次默认怎么做

固定触发词（空格和中文冒号差异不影响识别）：

```text
参考 ：D:\AI\Codex\Codex_Obsidian\81_WorkFlow 工作流\Roblox\模型相关\多零件模型转为roblox可导入文件 工作流，导出为可直接导入roblox的文件
```

用户不需要再补充 `.blend` 路径、资产名、输出格式或贴图尺寸。Codex 默认直接执行，不先展开讨论：

```text
1. 自动定位当前任务对应的 .blend。
2. 确认正式 Mesh 范围和资产名；上下文已明确时不再询问。
3. 运行快速脚本，只生成一个 GLB。
4. 脚本自动在工厂空场景回导并核对零件、面数、尺寸、材质和贴图。
5. 只向用户返回 GLB 绝对路径和 PASS/FAIL。
6. GLB 成功后停止；失败时才进入完整工作流或 FBX 回退。
```

源文件按以下顺序自动定位：

1. 当前对话或当前任务已经明确的 `.blend`。
2. 当前 Blender 窗口中已保存并正在编辑的 `.blend`。
3. 当前武器项目或输出目录中最近修改的 `*_ROBLOX_EXPORT_vNN.blend`。
4. 当前项目中唯一且与资产语义匹配的 `.blend`。

如果有多个同等可信的候选文件，禁止静默猜测，只向用户询问一次“使用哪一个 `.blend`”。如果可以唯一定位，就不得再次索要路径。资产名优先沿用当前武器名称，否则从 `.blend` 文件名生成短英文名。

正式 Mesh 优先采用当前任务已确认的零件、干净导出副本中的全部 Mesh，或当前 Blender 中明确选择的正式零件。只有正式 Mesh 范围仍无法唯一判断时，才询问一次。

### 自动化入口

```powershell
& 'D:\AI\Codex\Codex_Obsidian\81_WorkFlow 工作流\Roblox\模型相关\多零件模型转为roblox可导入文件\scripts\Export-RobloxMultiPartGlbFast.ps1' `
  -BlendPath 'D:\Path\Asset_ROBLOX_EXPORT_v01.blend' `
  -AssetName Asset_v01
```

默认输出：

```text
%USERPROFILE%\Documents\RobloxImportPackages\Asset_v01_IMPORT_ONLY\
├─ Asset_v01_facesNNNN_1024tex.glb
└─ Asset_v01_facesNNNN_1024tex.verification.json
```

快速脚本不保存源 `.blend`、不生成 FBX、不创建手工 Manifest。验证 JSON 是自动审计证据。若输入不是已整理的 `*_ROBLOX_EXPORT_vNN.blend`，Codex 可以在已明确正式零件时使用 `-Parts`；范围仍不明确则停止，禁止猜测导出对象。

## 工作流入口

1. [[01_Blender导出副本准备]]
2. [[02_材质纹理与FBX导出]]
3. [[03_空场景回导与Studio验收]]
4. [[快速执行卡_QUICK_START|2 秒 GLB 快速执行卡]]
5. [[CHECKLIST]]
6. [[FAILURE_CODES]]
7. [[EXPORT_MANIFEST_TEMPLATE]]
8. [[案例_猫猫剑与冰晶战锤]]
9. [[案例_黑曜狼首月牙战斧_GLB导入复盘|案例：黑曜狼首月牙战斧 GLB 导入复盘]]

## 文件分层（完整兼容包模式）

```text
Asset_SOURCE.blend                         # 原始工作文件，只读保留
Asset_ROBLOX_EXPORT_vNN.blend              # 只含正式导出对象的副本
%USERPROFILE%/Documents/RobloxImportPackages/Asset_vNN/
├─ Asset_facesNNNN_1024tex.glb             # 默认首选，只把这一项交给 Studio
├─ README_IMPORT_ORDER.txt
├─ Asset_vNN.manifest.json                 # 对象、尺寸、贴图、回导和哈希
└─ manual_fallback/                        # 仅 GLB 失败或明确要求完整兼容包时生成
   ├─ Asset_facesNNNN_1024tex_external.fbx # 外置贴图 FBX 回退
   ├─ PartA_BaseColor.jpg
   ├─ PartB_BaseColor.jpg
   ├─ Asset_facesNNNN_1024tex_embedded.fbx # 内嵌 FBX 最后回退
   └─ Asset_facesNNNN_mesh_only.fbx        # 无材质/贴图诊断对照
```

主交付目录和文件名必须使用短英文 ASCII，避免把中文、空格、过深目录和格式问题同时带入 Studio。GLB 在一个容器内携带多个 Mesh、材质和贴图，正常导入时只选择顶层 GLB。外置 FBX 必须与对应 JPG/PNG 保持在同一回退目录；内嵌 FBX 不再作为默认首选。

## 七个 Gate

| Gate | 通过条件 | 失败时 |
|---|---|---|
| P0 源对象范围 | 正式 Mesh 清单、根件、零件用途已确认 | 不进入清理 |
| P1 装配与公共坐标 | Blender 中已拼好，连接无缝；所有正式零件共享公共枢轴 | 回装配版修正 |
| P2 材质与贴图 | 每个 Mesh 一套正式材质、一个 UV 集；贴图格式与扩展名一致 | 拆材质或烘焙 Atlas |
| P3 单位与变换 | 只采用一种缩放策略；导出副本中 Location/Rotation/Scale 为 `0/0/1` | 停止导出 |
| P4 导入包合同 | 默认先生成唯一主 GLB；GLB 失败或明确要求完整包时再生成三个 FBX 回退；零件/材质不合并 | 删除失败包重导 |
| P5 空场景回导 | 主 GLB 必验；任何已生成回退也必须逐项回导；对象数、名称、尺寸、三角面、材质和贴图与自动验证报告或 Manifest 一致 | 不进入 Studio |
| P6 Studio 验收 | 先导入短路径 GLB；独立 MeshPart 对齐、贴图正确、根件与 Weld 正确、Play 不散架 | 按固定 A/B 分流回退 |

## 发布状态机

```text
ASSEMBLY_ACCEPTED
  -> EXPORT_COPY_READY
  -> IMPORT_PACKAGE_EXPORTED
  -> ROUNDTRIP_VERIFIED
  -> STUDIO_IMPORT_PASS
  -> STUDIO_ACCEPTED
```

- `ROUNDTRIP_VERIFIED` 只表示 Blender 空场景能够正确回读最终 GLB/FBX，不能对外称为“Roblox 已验证版”。
- `STUDIO_IMPORT_PASS` 只表示 Studio 接受文件并生成资产；Root、Weld、碰撞和 Play 尚未验证。
- 只有 Studio 导入队列成功、MeshPart/贴图正确且 Play 不散架，才允许标记 `STUDIO_ACCEPTED`。
- 失败产物不得覆盖上一份已通过版本；修复后递增版本号重新走 P4-P6。首选文件成功后停止，不为了“证明所有格式都能用”继续更换导入变量。

## 当前推荐的静态多零件合同

```text
对象：只保留正式 Mesh；不用 Ctrl+J 合并
命名：稳定英文 ASCII，例如 HammerHead / Handle
根件：Handle 或项目明确指定的 Root
枢轴：所有导出 Mesh 使用同一个公共原点
变换：Location=0, Rotation=0, Scale=1
材质：每个 Mesh 一套可迁移材质
贴图：真实 PNG/JPG；扩展名必须与文件内容一致
单位：导出副本只保留一种缩放策略
轴向：当前项目锁定 -Z Forward / Y Up；新项目不得中途更换
主格式：GLB，材质与贴图写入容器
回退：仅按需生成，顺序为外置贴图 FBX -> 纯网格 FBX 诊断 -> 内嵌 FBX 最后回退
路径：%USERPROFILE%\Documents\RobloxImportPackages\短英文资产名\
命名：Asset_faces<真实三角面>_<贴图尺寸>tex.glb
验证：主 GLB 与回退文件必须分别在空 Blender 场景回导
Studio：先选主 GLB，Merge Meshes=Off，不在 Studio 重新拼位置
```

`-Z Forward / Y Up` 只适用于本流程的 FBX 回退，是猫猫剑和冰晶战锤导出副本的项目基线；GLB 使用 glTF 的 Y Up 合同。新项目若采用别的轴向，必须写入 Manifest，并用空场景回导与 Studio 预览证明方向正确。

## 单位策略：只能选一种

### 策略 A：Blender Unit 直接作为 Stud（本流程推荐）

- 导出副本使用 `Scene Units = None`。
- 在 Blender 中把完整模型最长尺寸直接调整到目标 Stud 数。
- GLB 保持 1:1 尺寸；FBX 回退使用 `Global Scale = 1`、`Apply Scalings = FBX Unit Scale`。
- 不再额外使用 `0.01` 或对象 `Scale=100`。

### 策略 B：真实米制来源

只有源模型确实按米制作时才使用：

```text
stud = metre / 0.28
1 metre = 3.5714286 studs
```

转换必须只发生一次，转换后再应用 Rotation/Scale。禁止同时修改顶点、对象 Scale 和 FBX Global Scale。

Roblox 官方单位参考：<https://create.roblox.com/docs/physics/units>

## 与现有工作流的边界

- AI 网格清理、部件拼接和接口设计：引用 [[../高级武器模型制作/03_Blender拼接材质与FBX导出|高级武器 Blender 拼接流程]]。
- 单件旧模型批量打包与兼容包：引用 [[../Roblox 可直接导入版打包流程/README|Roblox 可直接导入版打包流程]]。
- 本流程专门解决：**多个已经拼好的刚性零件，如何作为同一个 Model 保持独立 MeshPart 并直接进入 Studio。**

禁止把已经完成语义分件、每件使用不同贴图的 Blender 装配，直接交给旧版 `Prepare-RobloxWeaponImport.ps1`。该脚本属于下载站单体模型包的兼容打包入口，可能重命名部件或统一材质，不承担本流程的公共 Pivot、每件材质和装配保持合同。

## 权威参考

- Roblox FBX 导出设置：<https://create.roblox.com/docs/art/modeling/export-requirements>
- Blender 与 Roblox 单位/轴向：<https://create.roblox.com/docs/art/blender>
- 纹理和单材质限制：<https://create.roblox.com/docs/art/modeling/texture-specifications>
- Blender 贴图连接：<https://create.roblox.com/docs/art/modeling/assign-textures>
- Studio 3D Importer：<https://create.roblox.com/docs/studio/importer>

## Workflow Check

- Missing gate: 已补上短英文路径门、GLB 快速通道、按需回退门和固定 A/B 失败分流；云端红叉但没有详细错误时仍不得猜唯一根因。
- Manual/automatic boundary: Blender 装配外观、根件和 Studio 最终视觉由人工确认；导出、哈希、对象数、三角面、尺寸、材质/贴图映射和空场景回导可自动检查。
- Verification evidence: Import Manifest、各格式 SHA-256、空场景回导报告、Studio 导入队列、Explorer 与 Play 截图。
- Handoff impact: 交接者默认只拿顶层 GLB；只有失败时才创建并进入 `manual_fallback/`，不再面对多个同级候选文件。
- Rule/doc update: 2026-08-17 已根据黑曜狼首月牙战斧的“FBX 红叉 / 同几何 GLB 成功”证据升级默认格式与分流规则。
