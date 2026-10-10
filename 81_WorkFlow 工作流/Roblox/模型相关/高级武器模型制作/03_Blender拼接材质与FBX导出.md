---
type: workflow
domain: roblox
status: active
owner: mixed
source: mixed
created: 2026-08-13
updated: 2026-08-14
---

# 03 Blender 拼接、材质与 FBX 导出

## 目标

把已通过的独立 AI 网格拼成一把比例合理、接口可信、材质可迁移、可验证导出的武器。任何操作都不能破坏原始 AI 源文件。

## 三层文件

```text
Weapon_SOURCE_HIGH/           # 原始下载模型与贴图，只读
Weapon_WORK_CLEAN_vNN.blend   # 拼接、清理、UV、材质工作版
Weapon_ROBLOX_EXPORT_vNN.blend# 只保留正式导出对象的副本
```

- `SOURCE_HIGH` 不覆盖、不移动、不全局焊接。
- `WORK_CLEAN` 保留独立部件、参考空轴和检查点。
- 应用变换、删除参考图、按材质拆分、统一命名和三角化只在 `EXPORT` 副本执行。

## Gate P5B：AI -> Blender 交接审计

导入每个部件后先只读统计：

- 对象、网格、材质、贴图、UV 数量。
- 世界包围盒、长宽厚和当前轴向。
- 顶点、面和三角面数量。
- 是否存在大量断开岛、边界边、非流形、重复面或法线异常。
- 贴图路径是外部、packed 还是丢失。

不要因“边界边很多”立即 Weld by Distance。AI 网格可能把切面拆为独立顶点；全局焊接会破坏 UV、硬边和外观。先做副本和可视测试。

还必须记录来源平台、任务/版本、正式输入图哈希、原始模型路径和已知缺陷。P5A 视觉验收与本交接审计都通过后，只把当前部件写为 `ai_mesh_gate=PASS`；全部 `required` 部件通过后，项目才进入 `AI_MESH_ACCEPTED`。

## Gate P6：块模与装配

### 1. 建立装配基准

- 用 Empty 或简单几何建立整剑主轴。
- 按 `PROJECT_LOCK.md` 标出各站位、可见长度、厚度包络和接口重叠。
- 为每个接口建立 `AXIS_<ID>`、`FRONT_<ID>` 和可量化的 `JOINT_<ID>_DATUM`；共享对位区只用于定位，不直接信任 AI 网格尺寸。
- 先用 Box/Cylinder 块模检查比例，不直接拖动高密度 AI 网格反复试错。

### 2. 替换正式部件

推荐顺序：

1. 锁定决定总长和刃线的主体部件。
2. 对齐视觉中心与实际接口中心；不以不对称外形的包围盒中心代替接口轴。
3. 放置护手/中段。
4. 让握柄轴与装配轴共线。
5. 最后放置尾饰和隐藏插头。

### 3. 连接处理

- 连接处必须存在实际相交或隐藏连接芯，不能只让两个边界“刚好碰到”。
- 插头应进入母槽或内部重叠区，外露接缝由端环/外框遮挡。
- 按 `JOINT_<ID>.md` 用基础几何重建精确插头、母槽和防转键；两个独立 AI 网格即使外观相同，也不能直接视为同尺寸接口。
- 先用 `ALIGN_PROXY_<ID>` 对齐共享基准，再按中心轴、`FRONT` 和插入深度复核；完成后删除代理副本。
- 正、背、左、右和 3/4 都检查背景是否从接口透出。
- 若外壳正确但接口不适合，优先用简单 Box/Cylinder/D 形芯重建；不要为了开孔破坏百万面装饰网格。
- 静态资产可保留隐藏内部重叠；要做可替换/打印结构时另走工程清理。

### Gate P6J：接口重建与代理清理

每个 JOINT 必须同时通过：

- `JOINT_ID`、主轴、`FRONT`、防转方向和插入深度与合同一致。
- 精确连接已由 Blender 可量化几何重建，不依赖 AI 近似尺寸。
- 最终所有者的可见外壳保留；代理副本及 `DELETE_AFTER_ALIGN` 项已删除。
- 隐藏插头/连接芯不产生共面重复表面，且从正、背、左、右、3/4 无透光或错轴。

未通过时不得把项目标记为 `ASSEMBLY_APPROVED`。

### 4. 比例调整

- 先整体等比缩放到站位，再讨论非等比调整。
- 非等比调整必须由用户看过正、侧视结果后确认，并记录绝对 Scale 或乘数。
- 不把单次案例参数升级为全局默认。
- 部件插接后，最终外廓长度应按包围盒计算，不能靠各部件长度相加。

### 5. 拼接验收

- 正视：轮廓、刃线、护手、握柄和尾饰的轴向关系正确。
- 侧视：厚度、双层结构、接口和前后层居中。
- 3/4：没有单边贴合、悬空、明显穿帮和尺度突变。
- 选择模式隐藏参考图，仍能独立读出完整武器。

用户确认后，保存带时间戳检查点，状态进入 `ASSEMBLY_APPROVED`。

## Blender 卡死与恢复

### 预防

- 复杂节点搭建、批量几何修改和保存分成多个小步骤。
- 自动脚本必须幂等，只删除带自己标签的节点/对象；不能 `clear()` 整个节点树。
- 大操作前保存 `*_checkpoint_before_<action>.blend`。
- 执行后先只读核对对象、材质、变换和统计，再保存。
- 用户明确说“不用备份”时，仍不得覆盖唯一源文件；至少保留 Blender autosave 路径和导出副本边界。

### 恢复

1. 不连续点击或强制重复同一操作。
2. 核对 Blender 进程 CPU / 内存和 UI 响应；确认无响应后再结束进程。
3. 从最近 autosave 或 checkpoint 打开。
4. 另存为新的 `*_RECOVERED_YYYYMMDD_HHMMSS.blend`。
5. 核对对象数、材质槽、变换、面数和最近成功操作，再继续。
6. 将导致卡死的复合动作拆成可验证的小步骤。

## Gate P7：材质与可迁移性

### 两类材质必须分开

| 类型 | 用途 | 典型内容 | 能否直接信任 FBX 迁移 |
|---|---|---|---|
| Blender 预览材质 | Blender 中审美确认 | 程序 HSV Mask、Noise、Coat、复杂 Mix、节点 Emission | 否 |
| Roblox 可迁移材质 | Studio 的 SurfaceAppearance | BaseColor、Metalness、Roughness、Normal、EmissionMask | 贴图可迁移，仍需 Studio 验收 |

若只有一张含烘焙高光/阴影的 BaseColor，应称为 `basecolor-only` 或 `baked/shaded-looking basecolor`，不能称为完整 PBR。

### 建议材质顺序

1. 在 Blender 中用侧光区分金属、暗钢、皮革、珐琅和宝石。
2. 不让整把剑或整片刃口持续发光；发光属于可选材质图或后续运行时表现。
3. 确认视觉后烘焙：
   - 必需：`BaseColor`
   - 正式 PBR：`Metalness`、`Roughness`
   - 按需：`Normal`、`EmissionMask`
4. 用目标分辨率和实际游戏相机检查，不只看 Blender 特写。
5. 记录每个 Mesh 对应的一套贴图；避免一个 Mesh 多材质依赖 Studio 猜测。

完成贴图清单和用户材质确认后进入 `MATERIAL_TRANSFER_READY`。

## Gate P8A：导出专用副本

### 导出前清理

- 只保留正式 Mesh；删除参考平面、旧零件、Empty、摄像机、灯光和临时连接标记。
- 删除全部 `ALIGN_PROXY_*`、`*_DELETE_AFTER_ALIGN` 和未在 JOINT 合同中批准的临时接口对象。
- 对每个共享对位区执行唯一性检查：同一可见外壳、装饰环或共面表面只能由 `final_surface_owner` 保留一份。
- 只保留 Manifest 白名单中的稳定英文 ASCII 名，如 `Blade`、`Guard`、`Handle`、`Pommel`；不能按“当前隐藏”推断不会导出。
- 不执行 `Ctrl+J`。未来需要独立贴图、焊接或控制的语义部件继续保持独立 Mesh。
- 按材质或 Studio 控制需求拆分，使每个导出 Mesh 只有一套可迁移材质。
- 记录目标总长、部件数、三角面、材质数和贴图清单。

### 公共 Pivot 与 `0/0/1` 手动步骤

只在 `*_ROBLOX_EXPORT_vNN.blend` 中执行，并在操作前保存检查点：

前置检查：若正式对象存在 Parent、Constraint 或 Delta Transform，先逐件记录 `matrix_world`，使用 `Clear Parent Keep Transform` 或复制评估后网格把世界变换烘焙到副本，再进入下列步骤。否则 `Alt+G` 清除的是局部位置，可能拆散装配。

1. 只选 `PROJECT_LOCK.root_part`，例如 `Handle`。
2. `物体 > 设置原点 > 原点到几何中心`；若 Root 应落在接口基准，改用已确认的 Empty/Datum，不强行使用几何中心。
3. `Shift+S > 游标到选中项`。
4. 选中全部正式 Mesh。
5. `物体 > 设置原点 > 原点到 3D 游标`，使所有正式对象共享同一公共 Pivot。
6. `Alt+G` 清除位置，把这组公共 Pivot 移到世界原点。
7. 围绕公共 Pivot 整体等比缩放到目标尺寸；不得逐件改比例。
8. `Ctrl+A > 旋转与缩放`。
9. 逐件核对：`Location=0,0,0`、`Rotation=0,0,0`、`Scale=1,1,1`，同时正、侧、3/4 的相对装配位置没有变化。

若任一零件发生相对位移、旋转或比例漂移，立即回退检查点。禁止到 Studio 再手工重新拼接。

### 单位策略：只能选一套

推荐静态武器导出副本使用下列确定性发布路径；它不是 Roblox 唯一合法单位方案：

```text
Scene Units = None
1 Blender Unit = 1 Stud
完整模型最长尺寸 = PROJECT_LOCK.TARGET_LENGTH_STUDS
FBX Scale = 1
Apply Scalings = FBX Unit Scale
```

若来源确实按米制作，只允许一次 `stud = metre / 0.28` 转换，随后应用 Rotation/Scale。禁止同时使用顶点缩放、对象 `Scale=100`、FBX `0.01` 或其他重复补偿。单位策略必须写入 `PROJECT_LOCK.md` 与 `EXPORT_MANIFEST.md`。

P8A 通过条件：对象白名单、公共 Pivot、唯一单位策略、逐件 `0/0/1`、P8J 和装配截图全部通过。通过后写 `EXPORT_COPY_READY`。

### Gate P8J：接口导出唯一性

在 FBX 导出前逐个核对 `JOINT_<ID>.md`：

- `joint_export_gate=PASS`。
- `EXPORT_COPY` 不含任何代理副本或待删除对象。
- 没有两份共面共享壳、重复环、重复端盖或双层可见表面。
- 保留的隐藏工程连接属于合同允许对象，且不与可见壳共面重叠。
- 对象清单与 `EXPORT_MANIFEST.md` 的 JOINT 唯一性记录一致。

任一失败时记录 `EXPORT_DUPLICATE_JOINT_SURFACE` 或 `JOINT_PROXY_NOT_REMOVED`，停止导出。

## Gate P8B：真实贴图与 FBX 导出

### 把贴图真正另存为文件

对每个正式材质：

1. 在 Image Editor 选择材质实际使用的图片。
2. 执行 `图像 > 另存为`，不是“保存副本”。
3. 保存到包内 `textures/`，使用稳定英文文件名和真实扩展名，例如 `Handle_BaseColor.png`。
4. 保存面板选择真实格式：`.png` 必须是 PNG，`.jpg/.jpeg` 必须是 JPEG；不能只改文件后缀。
5. 回到 Shader Editor，确认 `Image Texture -> Principled BSDF / Base Color` 引用的是刚保存的文件。
6. 记录实际编码、分辨率、SHA-256 和 FBX 内部引用名；内部引用名必须包含 `.png/.jpg/.jpeg`。

`文件 > 外部数据 > 打包资源` 只保证 `.blend` 可迁移，**不等于** FBX 已内嵌纹理。

### FBX 设置

```text
Selected Objects = On
Object Types = Mesh only
Apply Modifiers = On
Triangulate Faces = On
Scale = 1
Apply Scalings = FBX Unit Scale
Apply Unit = On
Forward = -Z
Up = Y
Use Space Transform = On
Apply Transform = Off
Path Mode = Copy
Embed Textures = On（点亮 Path Mode 右侧的小包裹图标）
Add Leaf Bones = Off
Bake Animation = Off
```

`-Z Forward / Y Up` 是当前已验证的项目基线；新项目若改变轴向，必须先写入 Manifest 并通过回导与 Studio 预览，不能在同一项目中途切换。

只选 `Copy` 而没有点亮小包裹，不算内嵌纹理。正常 Studio 导入只选择最终 FBX；`textures/` 是事实源和失败回退，不是第二个必选输入。

已完成装配、必须保留多个语义 MeshPart 的 Blender 文件，**必须**执行 [[../多零件模型转为roblox可导入文件/README|多零件模型转为 Roblox 可导入文件]] 的 P0-P5；它是本 Gate 的权威执行规范。下载站单体模型包、伪 FBX、`.fbm` 和 GLB 兼容诊断，才转交 [[../Roblox 可直接导入版打包流程/README|Roblox 可直接导入版打包流程]]。两个入口不得混用。

导出后记录 FBX 路径、大小、SHA-256、Blender 版本、正式对象白名单、单位策略、公共 Pivot、逐件统计、贴图哈希和完整设置快照。通过后写 `FBX_EXPORTED`。

## Gate P8C：强制空场景回导

在空 Blender 场景中导入刚生成的 FBX，并与 Manifest 对比：

- Mesh 数量与稳定名称。
- 总包围尺寸和主轴方向。
- 每件三角面及总三角面。
- 每个 Mesh 材质数。
- 贴图路径和基础颜色。
- 公共原点/枢轴。
- 每个零件仍可独立选中，且不需要再次位移、旋转或缩放。
- 没有参考平面、旧零件、摄像机或灯光。

尺寸、部件数、贴图或装配位置任一不符时，FBX 不能发布，记录 `FBX_ROUNDTRIP_FAILED`。全部通过后才能写 `FBX_REIMPORT_VERIFIED`；该状态只证明 Blender 能正确回读，不能提前声称 Roblox 已接受。

自动脚本只有在实际核对 Manifest、Rotation/Scale/Dimensions、真实三角面、UV、额外对象类型、贴图编码和公共 Pivot，并以退出码报告偏差时，才能单独形成 PASS。只输出对象/材质清单的脚本属于信息采集器，仍需人工逐项比对 Manifest。

## 导出包最小内容

```text
Weapon_vNN.fbx
Weapon_ROBLOX_EXPORT_vNN.blend
textures/
preview_3q.png
README_导入说明.md
EXPORT_MANIFEST.md 或 JSON
```

导出包不得混入原始 AI 高模、参考图和失败版本。

## Blender / FBX 验收清单

- [ ] 原始源文件未覆盖。
- [ ] 拼接版已通过正、侧、3/4 人工确认。
- [ ] 接口没有背景透出，插头按合同隐藏。
- [ ] 每个接口已通过 P6J；精确基准与防转结构由 Blender 重建。
- [ ] 每个接口已通过 P8J；共享外壳只有最终所有者一份，代理未进入 EXPORT_COPY。
- [ ] 预览材质与 Roblox 贴图清单分开记录。
- [ ] 导出副本只含正式 Mesh。
- [ ] root_part、对象白名单、公共 Pivot 和单位策略已锁定。
- [ ] 每件 Location/Rotation/Scale 均为 `0/0/1`，装配相对位置未改变。
- [ ] 没有混用顶点缩放、对象 100 倍、FBX 0.01 等多套单位补偿。
- [ ] 贴图真实格式、扩展名、节点引用和哈希已核对。
- [ ] 每个导出 Mesh 只有预期材质。
- [ ] `Path Mode=Copy` 且 `Embed Textures` 小包裹已点亮。
- [ ] FBX 已在新场景回导并与 Manifest 一致。
- [ ] 回导后各件无需重新对位，且 `FBX_REIMPORT_VERIFIED` 没有被误写成 `STUDIO_ACCEPTED`。
