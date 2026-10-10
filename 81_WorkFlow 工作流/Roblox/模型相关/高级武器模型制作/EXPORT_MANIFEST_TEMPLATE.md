---
type: workflow
domain: roblox
status: active
owner: mixed
source: self
created: 2026-08-13
updated: 2026-08-15
---

# 高级武器 EXPORT_MANIFEST 模板

> 复制到 `05_roblox_import_package/EXPORT_MANIFEST.md`。P8A 先填期望值；P8B 写导出事实；P8C 与 P9 分别写回导和 Studio 实际结果。

## 资产与发布状态

- 项目名：
- 运行目录：
- Export Blend：
- Export Blend SHA-256：
- FBX：
- FBX bytes：
- FBX SHA-256：
- 导出日期：
- Blender 版本：
- 导出脚本/手工设置：
- `EXPORT_COPY_READY`：`PASS / FAIL / NOT_RUN`
- `FBX_EXPORTED`：`PASS / FAIL / NOT_RUN`
- `FBX_REIMPORT_VERIFIED`：`PASS / FAIL / NOT_RUN`
- `STUDIO_ACCEPTED`：`PASS / FAIL / NOT_RUN`

证据分层：`L=本地导出审计 / R=Blender 空场景回导 / S=Studio 导入队列与显示 / P=Root/Weld/Play 运行验收`。

- evidence_status：`L / L+R / L+R+S / L+R+S+P`
- contract_conformance：`PASS / PASS_WITH_DEVIATION / FAIL`
- known_deviations：

## 正式建模参考集（P4 / 项目级交付）

> 此区记录用户确认的建模参考，不等同于当前图生 3D 平台已经接收的输入包。目录只放 PNG；Manifest、联系表、候选、提示词和历史未选图留在目录外。

- formal_reference_dir：`{RUN_DIR}/00_formal_model_references/`
- formal_reference_manifest：`{RUN_DIR}/07_handoff/FORMAL_REFERENCE_SET.md`
- expected / actual PNG count：
- folder_contains_only_manifest_entries：`PASS / FAIL`
- user-confirmed-only：`PASS / FAIL`
- semantic-name-unique：`PASS / FAIL`
- platform_input_status：`NOT_PREPARED / READY / PLATFORM_LIMIT_RECORDED`

| Delivery PNG | Component / role | Semantic view | Confirmed source path | Source SHA-256 | Delivered SHA-256 | User approval / date | platform_input | Notes |
|---|---|---|---|---|---|---|---|---|
|  |  |  |  |  |  |  | YES / NO |  |

禁止通过复制、翻转、镜像、重命名候选或把历史参考混入该表来补足平台槽位。若平台要求的图数与 `required_final_views` 不一致，记录 `PLATFORM_LIMIT_RECORDED` 并等待用户决定补图或改用其他建模路径。

## 装配与公共 Pivot

- selected_object_whitelist：
- root_part：
- common_pivot_definition：
- common_pivot_coordinates：
- Parent / Constraint / Delta Transform 处理：
- all_parts_identity_transform：`YES / NO`

| Name | Role | Location | Rotation | Scale | Dimensions | Vertices | Triangles | Materials | Texture Set |
|---|---|---|---|---|---|---:|---:|---:|---|
|  |  | 0,0,0 | 0,0,0 | 1,1,1 |  |  |  |  |  |

## 单位合同

- unit_strategy：`BU_AS_STUD / TRUE_METRE_ONCE / OTHER`
- target_length_studs：
- source_unit：
- metres_per_stud：`0.28 / N/A`
- conversion_applied_at：
- scene_unit_system：
- Global Scale：
- Apply Unit：
- Apply Scalings：
- 重复缩放检查：`PASS / FAIL`

## 贴图事实

材质状态：`basecolor-only / pbr-maps / mixed / pending`

| Mesh | Map | 声明文件名 | 声明扩展名 | 检测编码 | 扩展名匹配 | Resolution | Bytes | SHA-256 | FBX 内部引用名 | Embedded |
|---|---|---|---|---|---|---|---:|---|---|---|
|  | BaseColor |  |  | PNG / JPEG | PASS / FAIL |  |  |  |  | YES / NO |

- 每个 Mesh 一套正式材质：`PASS / FAIL`
- Shader 主链：`Image Texture -> Principled BSDF Base Color / 其他`
- `.blend` Pack Resources：`YES / NO`（不等于 FBX Embed）

## FBX 设置快照

```text
Selected Objects =
Selected object names =
Object Types =
Apply Modifiers =
Triangulate Faces =
Scale =
Apply Scalings =
Apply Unit =
Forward =
Up =
Use Space Transform =
Apply Transform =
Path Mode =
Embed Textures =
Add Leaf Bones =
Bake Animation =
```

## 期望值

- Mesh 数与名称：
- 总包围尺寸：
- 总三角面：
- 公共 Pivot / PrimaryPart 候选：
- 不应包含：参考图 / Camera / Light / Empty / 旧零件 / 其他

## JOINT 导出唯一性

| JOINT_ID | final_surface_owner | 已删除代理 | 保留隐藏工程件 | 共面重复表面检查 | P8J |
|---|---|---|---|---|---|
| JOINT_A |  |  |  | PASS / FAIL | PASS / FAIL |

- 禁止对象名：`ALIGN_PROXY_* / *_DELETE_AFTER_ALIGN`
- 禁止状态：共享可见外壳、装饰环、端盖或共面表面由两个部件同时持有。
- 只有全部 JOINT 的 P8J 为 `PASS`，才允许进入 `EXPORT_COPY_READY`。

## P8C 空场景回导结果

- 回导 Blender 版本：
- 回导方式/验证器版本：
- expected / actual Mesh 数与名称：
- expected / actual 总包围尺寸：
- expected / actual 总三角面：
- 每 Mesh 材质数：
- Rotation / Scale / Dimensions：
- UV：
- 贴图解码与方向：
- 公共 Pivot：
- 是否无需重新对位：
- 多余对象类型：
- 结果：`PASS / FAIL`
- 偏差与恢复动作：

> 只输出对象/材质清单、未与本 Manifest 自动比对的脚本属于信息采集器，不能单独形成 `PASS`。

## P9 Studio 实际结果

- Project / Place：
- Creator：
- Import Only as Model：
- Add to Workspace：
- Merge Meshes：
- Insert Using Scene Position：
- Make Double Sided：
- Scale Unit：
- 只选择最终 FBX：`YES / NO`
- import_queue_status：`PASS / FAIL / NOT_RUN`
- 目标 Model 路径：
- actual Model / MeshPart 名称：
- Mesh asset IDs：
- Texture asset IDs：
- root_part / PrimaryPart：
- Weld 状态：
- Collision / Massless：
- Play scatter test：`PASS / FAIL / NOT_RECORDED`
- 用户确认原话与日期：

只有 P8C 为 `PASS` 才能进入 `FBX_REIMPORT_VERIFIED`。只有 Studio 导入、Root/Weld/碰撞、Play 和用户确认全部有证据，才能进入 `STUDIO_ACCEPTED`。
