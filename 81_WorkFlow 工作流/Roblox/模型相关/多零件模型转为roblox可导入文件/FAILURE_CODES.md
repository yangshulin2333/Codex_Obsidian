---
type: reference
domain: roblox
status: active
owner: mixed
source: mixed
created: 2026-08-14
updated: 2026-08-17
---

# 多零件模型直导失败码

| 失败码 | 含义 | 停止点 | 修复 |
|---|---|---|---|
| `SOURCE_OBJECT_SCOPE_UNCONFIRMED` | 不知道哪些对象应进入 FBX | P0 | 建正式对象清单 |
| `EXPORT_COPY_REQUIRED` | 快速脚本收到普通工作文件且没有显式 `-Parts` | Fast | 使用 `*_ROBLOX_EXPORT_vNN.blend`，或传入已确认零件名 |
| `FORMAL_PART_SCOPE_AMBIGUOUS` | 导出副本仍含隐藏候选 Mesh | Fast/P0 | 明确 `-Parts`，禁止自动猜测 |
| `FORMAL_PART_NOT_FOUND` | `-Parts` 指定对象不存在 | Fast/P0 | 核对 Outliner 中的精确对象名 |
| `NO_MESH` | 场景没有可导出的 Mesh | Fast/P0 | 检查输入文件与对象类型 |
| `REFERENCE_OBJECT_EXPORTED` | Camera/Light/参考平面/旧件进入 FBX | P4/P5 | 只选正式 Mesh 重导 |
| `PARTS_JOINED_UNEXPECTEDLY` | 不应合并的零件被 `Ctrl+J` 合并 | P1 | 回导出副本，保留独立对象 |
| `PART_PIVOT_MISMATCH` | 零件原点不统一，Studio 变换难管理 | P1/P5 | 重建公共枢轴 |
| `PART_TRANSFORM_NOT_BAKED` | 非预期 Location/Rotation/Scale 留在导出对象 | P3 | 导出副本应用变换并复验 |
| `NON_ASCII_PART_NAME` | 正式零件名含中文或不稳定字符 | Fast/P1 | 在导出副本中改为稳定英文 ASCII 名 |
| `ASSEMBLY_OFFSET_DRIFT` | 回导后零件错位 | P5 | 修公共坐标和世界变换烘焙 |
| `MIXED_UNIT_STRATEGY` | 顶点、对象、导出同时缩放 | P3 | 只保留一个缩放策略 |
| `MULTI_MATERIAL_SINGLE_MESH` | 一个 Mesh 依赖多个材质槽 | P2 | 按材质拆 Mesh 或烘焙 Atlas |
| `MATERIAL_CONTRACT_FAILED` | 快速脚本检测到材质槽数量不为 1 | Fast/P2 | 拆材质或整理为逐件单材质 |
| `TEXTURE_FILE_FORMAT_MISMATCH` | 扩展名与实际图像格式不一致 | P2/P4 | 用图像编辑器按真实格式另存 |
| `TEXTURE_REFERENCE_BROKEN` | 材质节点/FBX 找不到目标贴图 | P2/P5 | 重载文件并检查 Image Texture |
| `PBR_TRANSFER_ASSUMED` | 把 Blender 程序节点误当成可迁移 PBR | P2 | 烘焙贴图或 Studio 重建 |
| `IMPORT_PATH_RISKY` | Studio 首测文件位于中文、空格或过深目录 | P4/P6 | 复制到 `%USERPROFILE%\Documents\RobloxImportPackages\短英文资产名\` 后再测 |
| `PRIMARY_GLB_MISSING` | 顶层没有唯一的主 GLB，或交接者无法判断首测文件 | P4 | 生成含真实面数/贴图尺寸的主 GLB，其他格式移入回退目录 |
| `OUTPUT_EXISTS` | 同名快速交付已经存在 | Fast/P4 | 使用新版本名；只有确认覆盖时才传 `-Overwrite` |
| `GLB_EXPORT_FAILED` | Blender 未生成主 GLB | Fast/P4 | 保留错误输出，转完整导出流程 |
| `MULTI_PART_TEXTURE_MAPPING_LOST` | 多零件导出后被统一材质、丢图或串图 | P4/P5 | 按 Part -> Material -> Image 映射重导，禁止使用单材质脚本覆盖 |
| `FBX_EXPORT_CONTRACT_DRIFT` | 导出设置偏离项目基线 | P4 | 按 Manifest/快速卡重导 |
| `GLB_ROUNDTRIP_FAILED` | 主 GLB 空场景回导与 Manifest 不一致 | P5 | 禁止进入 Studio，修正导出对象或 GLB 设置 |
| `FBX_ROUNDTRIP_FAILED` | 空场景回导与 Manifest 不一致 | P5 | 禁止进入 Studio，回 Blender |
| `ROUNDTRIP_VERIFIER_INCOMPLETE` | 只运行信息采集脚本，未与 Manifest 人工比较 Rotation、Scale、尺寸、UV、杂物、编码、Pivot 和真实三角面 | P5 | 补全人工比较；在验证器升级前不得自动签发 PASS |
| `VERIFICATION_STATUS_OVERCLAIMED` | 把本地回导、Studio 导入或运行装配中的一个通过写成全部通过 | P5/P6 | 分别记录 `roundtrip`、`studio_import` 与 `runtime_assembly` |
| `STUDIO_MANUAL_REASSEMBLY_REQUIRED` | Studio 中必须重新移动零件 | P6 | 回 Blender 修装配和枢轴 |
| `STUDIO_TEXTURE_UPLOAD_FAILED` | 网格预览正常但纹理上传失败 | P6 | 无贴图对照、单独上传图片 |
| `STUDIO_MESH_UPLOAD_FAILED` | 无贴图 FBX 也无法上传 | P6 | 检查网格、三角面、单位和账号权限 |
| `STUDIO_PRIMARY_GLB_FAILED` | 主 GLB 被 Studio 拒绝 | P6 | 同会话依次测试已知成功 GLB、外置 FBX、纯网格 FBX |
| `STUDIO_EMBEDDED_FBX_FAILED` | 内嵌贴图 FBX 红叉，但其他格式状态尚不明确 | P6 | 不重做网格；改测同几何 GLB/外置 FBX并保留原失败证据 |
| `STUDIO_PARTS_NOT_WELDED` | Play 后零件散开 | P6 | 设置 Root 和 WeldConstraint |
| `STUDIO_RUNTIME_ASSEMBLY_NOT_VERIFIED` | 导入显示成功，但 Root/Weld/碰撞或 Play 未记录 | P6 | 保留 `studio_import=PASS`，补运行验收后再写 `STUDIO_ACCEPTED` |
| `STUDIO_IMPORT_FAILED_UNCLASSIFIED` | 只有红叉，没有足够服务器错误证据 | P6 | 保留证据，做已知成功/无贴图 A/B |

## 失败记录最小字段

```text
failed_at:
failure_code:
primary_glb_path:
primary_glb_sha256:
candidate_path:
candidate_format: GLB | FBX_EXTERNAL | FBX_EMBEDDED | FBX_MESH_ONLY
candidate_sha256:
path_is_short_ascii:
studio_place:
creator:
preview_result:
upload_result:
known_good_glb_result:
external_fbx_control_result:
mesh_only_control_result:
texture_only_control_result:
evidence_paths:
next_action:
```

## 禁止的归因方式

- 只凭“预览能显示”断言云端上传一定能成功。
- 只凭“空场景回导成功”断言 Studio 一定接受。
- 看到网络或插件日志警告就直接认定为根因。
- 每失败一次就随机更换单位、轴向、图片尺寸和导出格式。
- 把 `.fbm` 文件夹是否存在当成所有内嵌 FBX 的唯一判断标准。
- 因为同几何 GLB 成功，就倒推“长路径”或“内嵌贴图”中的某一个必然是唯一原因；两者没有单变量 A/B 时只能记录高概率范围。
