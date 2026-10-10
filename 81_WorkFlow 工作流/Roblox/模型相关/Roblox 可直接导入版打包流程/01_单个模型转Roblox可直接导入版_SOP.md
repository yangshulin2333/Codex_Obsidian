# 单个模型转 Roblox 可直接导入版 SOP

更新时间：2026-07-27

## 目标

用户给一个模型路径后，直接生成 Roblox Studio 可优先导入的 FBX/GLB 包，并给出可点击链接。

## 边界

本 SOP 只负责模型打包，不负责：

- 三视图生成
- Prompt 设计
- 手动建模
- Roblox Studio 内部效果确认
- Tool/Accessory 挂载逻辑

如果用户给的是截图或要求生成三视图，切换到三视图流程。

## 步骤 1：确认输入存在

```powershell
Test-Path -LiteralPath "用户给的路径"
Get-Item -LiteralPath "用户给的路径" | Select-Object FullName,Mode,Length,LastWriteTime
```

判断：

- `Mode` 是 `d-----`：这是目录，哪怕名字以 `.fbx` 结尾，也按目录包处理。
- `Mode` 是 `-a----`：这是文件，脚本会继续判断它是真 FBX 还是伪 FBX ZIP。

## 步骤 2：推断输出名

命名分两层：

- 内部输出名：用于脚本输出、工作记录和排查来源，可以保留较完整的英文或系列名，例如 `ElfAlchemy-05-FrostPrismShard-PBR`。
- 最终 Roblox 导入名：用户在 Roblox 导入窗口里实际选择的文件名，只保留编号、面数和贴图尺寸，格式固定为 `<序号>_faces<Roblox性能面数>_1024tex`。这里的“Roblox性能面数”指更接近 Roblox/GPU 实际渲染负担的三角面数；源 FBX/生成器界面可见的 Quad 面数只作为来源备注。
- 原名覆盖规则：如果用户明确要求“导入 Roblox 时名字保持原样 / 保留原名 / 不要改名”，最终 Roblox 导入名以源模型目录或源模型文件 basename 为准，不追加 `faces`、贴图尺寸、`PBR` 或调试词；面数、贴图尺寸和来源信息改写入 `manifest.csv`、README 和工作记录。

编号推断原则：

- 优先取源文件或源目录开头的数字编号，例如 `05_霜棱碎片PBR` -> `05`。
- 如果源路径没有开头编号，但用户在上下文里明确给了编号，就用用户给的编号。
- 如果完全没有编号，才使用短稳定标识；不要把长英文描述放进最终导入文件名。

示例：

```text
D:\Download\3DModel\MagicBook\2-1.fbx
内部输出名 -> MagicBook-2-1
最终导入名 -> 2-1_faces1807_1024tex

C:\Users\14176\Desktop\武器\玩具\模型导出-最终版\Gear.fbx
内部输出名 -> Gear
最终导入名 -> Gear_faces实际面数_1024tex

D:\Download\3DModel\精灵炼金道具库_20260722\05_霜棱碎片PBR
内部输出名 -> ElfAlchemy-05-FrostPrismShard-PBR
最终导入名 -> 05_faces1485_1024tex
```

## 步骤 3：执行固定脚本

```powershell
$WorkflowRoot = "D:\AI\Codex\Codex_Obsidian\81_WorkFlow 工作流\Roblox\模型相关\Roblox 可直接导入版打包流程"
& "$WorkflowRoot\scripts\Prepare-RobloxWeaponImport.ps1" `
  -InputPath "用户给的文件或目录路径" `
  -Name "输出名" `
  -ImportNamePrefix "最终导入名前缀，例如 05" `
  -TextureSize 1024
```

不传 `-OutputRoot` 时，脚本默认输出到：

```text
%USERPROFILE%\Documents\RobloxImportPackages
```

这个默认路径用于减少 Roblox Studio 导入 FBX 时受中文长路径、`.fbm` 目录和绝对路径引用影响的概率。如果需要输出到别的目录，可以显式传入 `-OutputRoot`。

成功时脚本会输出：

```text
ROBLOX_WEAPON_EXPORT_OK
source_fbx=...
texture=...
source_texture_mode=external_file 或 embedded_packed_image 或 none
faces=...
direct_fbx=...
direct_fbx_texture_mode=external_relative
fbx_scale_mode=match_glb_world_scale
fbx_glb_scale_match=True
direct_glb=...
embedded_fbx=...
mesh_only_fbx=...
```

导出的交付文件名会自动加入面数，例如：

```text
MagicBook-2-1_faces1807_direct_1024tex.fbx
MagicBook-2-1_faces1807_direct_1024tex.glb
MagicBook-2-1_faces1807_embedded_1024tex.fbx
MagicBook-2-1_faces1807_mesh_only.fbx
MagicBook-2-1_faces1807_texture_1024.jpg
```

## 步骤 4：验证输出文件

```powershell
Get-Item -LiteralPath `
  "$WorkflowRoot\outputs\输出名_roblox_direct\输出名_faces实际面数_direct_1024tex.fbx",`
  "$WorkflowRoot\outputs\输出名_roblox_direct\输出名_faces实际面数_direct_1024tex.glb",`
  "$WorkflowRoot\outputs\输出名_roblox_direct\输出名_faces实际面数_embedded_1024tex.fbx",`
  "$WorkflowRoot\outputs\输出名_roblox_direct\输出名_faces实际面数_mesh_only.fbx",`
  "$WorkflowRoot\outputs\输出名_roblox_direct\输出名_faces实际面数_texture_1024.jpg" |
  Select-Object Name,Length,LastWriteTime
```

如果未传 `-OutputRoot`，验证路径应替换为：

```powershell
$ImportRoot = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "RobloxImportPackages"
Get-Item -LiteralPath `
  "$ImportRoot\输出名_roblox_direct\输出名_faces实际面数_direct_1024tex.fbx",`
  "$ImportRoot\输出名_roblox_direct\输出名_faces实际面数_direct_1024tex.glb",`
  "$ImportRoot\输出名_roblox_direct\输出名_faces实际面数_embedded_1024tex.fbx",`
  "$ImportRoot\输出名_roblox_direct\输出名_faces实际面数_mesh_only.fbx",`
  "$ImportRoot\输出名_roblox_direct\输出名_faces实际面数_texture_1024.jpg" |
  Select-Object Name,Length,LastWriteTime
```

验证贴图：

```powershell
Add-Type -AssemblyName System.Drawing
$ImportRoot = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "RobloxImportPackages"
$p = "$ImportRoot\输出名_roblox_direct\输出名_faces实际面数_texture_1024.jpg"
$img = [System.Drawing.Image]::FromFile($p)
try {
  "width=$($img.Width)"
  "height=$($img.Height)"
  "pixelformat=$($img.PixelFormat)"
} finally {
  $img.Dispose()
}
```

期望：

```text
width=1024
height=1024
pixelformat=Format24bppRgb
```

## 步骤 5：查看导入说明

```powershell
$ImportRoot = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "RobloxImportPackages"
Get-Content -LiteralPath "$ImportRoot\输出名_roblox_direct\README_import_order.txt" -Encoding utf8
```

重点确认：

- Input type
- Source FBX
- Source texture
- Source texture 如果显示 `embedded packed image extracted from source FBX`，表示脚本已从单文件 FBX 内嵌图提取并转成同目录 1024 贴图。
- Recommended import
- GLB fallback
- Embedded FBX compatibility fallback
- Mesh-only fallback
- FBX scale mode

## 步骤 5.5：验证 FBX / GLB 尺寸一致

所有模型都必须通过自动回导尺寸检查，不再只针对已知的 100 倍问题。

期望：

```text
fbx_scale_mode=match_glb_world_scale
fbx_dimensions=(x, y, z)
glb_dimensions=(x, y, z)
fbx_glb_scale_match=True
```

判断：

- 如果 FBX / GLB 任一轴不一致，脚本必须失败，不能继续交付。
- 当前脚本应用对象变换后使用 `global_scale=1`，再回导两种格式比较整体包围盒。
- 旧版 `global_scale=0.01` 可能把已正常尺度的资产缩小 100 倍，不再作为通用规则。

## 步骤 5.6：检查材质与亮度

如果模型属于魔法书、纸张、布料、皮革、木头，或截图反馈“偏暗”，不要只判断贴图是否存在，还要检查材质参数和贴图亮度。

最小检查：

```text
源贴图 mean_luma
输出贴图 mean_luma
源 FBX 材质 Metallic / Roughness
导出 GLB 材质 Metallic / Roughness
```

判断：

- 如果源贴图和输出贴图 `mean_luma` 基本一致，说明不是贴图缩放脚本压暗。
- 如果源材质是 `Metallic=0`、高 `Roughness`，但通用导出变成 `Metallic=0.15 / Roughness=0.55`，暗色非金属模型在 Roblox 里会更沉，需要修正。
- 修正版应保持 `_IMPORT_ONLY` 第一层短文件名不变，把原始偏暗版备份进 `manual_fallback`。

已验证修正方向：

```text
暗色魔法书：
Metallic=0.0
Roughness=0.9
贴图只做温和暗部提亮，不要把亮部冲爆。
```

修正后必须重新检查 GLB：

```text
materials.pbrMetallicRoughness.metallicFactor
materials.pbrMetallicRoughness.roughnessFactor
embedded texture mean_luma
_IMPORT_ONLY 第一层仍只有一个推荐导入文件
```

## 步骤 5.7：检查是否源包带 PBR 贴图

如果源目录或 `.fbm` 目录里出现以下贴图，不能默认把它降级成普通单贴图包：

```text
*basecolor*
*normal*
*roughness*
*metallic*
*_rm.*
*_0_1.*
*_0_2.*
*_0_3.*
```

处理规则：

- 如果用户明确说要 PBR，或者用户反馈“应该有 PBR / 看着不像 PBR”，必须生成 PBR 专版。
- PBR 专版主 GLB 必须包含 `baseColorTexture`、`normalTexture`、`metallicRoughnessTexture`。
- glTF `MetallicRoughness` 贴图生成规则：G 通道写 roughness，B 通道写 metalness。
- 干净目录第一层仍只放短名主 GLB、README、manifest 和 `manual_surfaceappearance_fallback`；不要把 `PBR` 写进主导入文件名，避免影响 Roblox 默认 Model 名。
- `manual_surfaceappearance_fallback` 里保留 `ColorMap`、`NormalMap`、`RoughnessMap`、`MetalnessMap` 和 `ApplyPBRSurfaceAppearance.commandbar.lua`，仅在 Roblox 没有自动生成 `SurfaceAppearance` 时使用。
- 如果只交付普通包，必须在回复或 README 里说明“本包不是完整 PBR，只包含 baseColorTexture”。

## 步骤 5.8：检查 Tripo / Hyper3D 是否有 shaded 或 baked BaseColor

小型武器在生成器预览里常常使用 baked/shaded 观感；这不等于源包一定有完整 PBR。

处理规则：

- 如果源目录有 `shaded.png`，且用户反馈 Roblox PBR 版不如生成器预览，额外交付一个预览匹配测试版：`shaded.png` -> glTF `baseColorTexture`，不注入 normal/roughness/metallic。
- 如果源目录没有 `shaded.png`，但只有一张带明显高光、阴影、AO 的 `basecolor`，把它记录为 baked/shaded-looking BaseColor；不要把它误判为完整 PBR。
- 如果源贴图已经是目标尺寸，最终 GLB 优先嵌入源贴图原始 bytes，避免重复 JPEG/PNG 重编码导致观感继续变糊。
- `_shaded` 后缀只用于排查测试版。正式交付、批量导入版仍按 `<序号>_faces<Roblox性能面数>_<贴图尺寸>tex` 命名，除非用户明确要求保留后缀。

## 步骤 6：追加工作记录

记录位置：

```text
D:\AI\Codex\Codex_Obsidian\81_WorkFlow 工作流\Roblox\模型相关\Roblox 可直接导入版打包流程\logs\工作记录.md
```

每次成功或失败都要记录。成功记录模板见 [[03_交付与记录模板]]。

## 步骤 6.5：生成用户侧干净导入目录

脚本原始输出目录用于追踪和排查，不直接让用户在里面挑文件。回复用户前，必须整理一个 `_IMPORT_ONLY` 干净目录：

```text
%USERPROFILE%\Documents\RobloxImportPackages\<最终导入名>_IMPORT_ONLY
```

第一层只放：

```text
<最终导入名>.<fbx/glb>
README_IMPORT_THIS_ONLY.txt
manifest.csv
manual_surfaceappearance_fallback\
```

要求：

- `<最终导入名>` 必须是 `<序号>_faces<Roblox性能面数>_1024tex`，其中面数优先使用 GLB/Roblox 导入后的三角化面数；脚本输出的 `faces=` 作为源 FBX/生成器面数记录到 README 和日志。
- 如果用户明确要求导入名保持原样，则 `<最终导入名>` 必须保持源模型原名；`manifest.csv` 记录每个文件的三角面数、贴图尺寸、fallback 路径和源输出目录。
- 实际导入文件名不能包含 `IMPORT_THIS`、长英文描述、`PBR`、`direct`、`embedded` 等调试词。
- PBR 包的四张 map、手动绑定脚本、mesh-only FBX、metadata 等放入 `manual_surfaceappearance_fallback` 子目录。
- 如果同一个资产有多个候选 GLB/FBX，不要混在干净目录第一层；第一层只能有一个推荐导入文件，避免用户误选旧文件。
- README 可以写“导入这个文件”，但不要通过文件名前缀制造提示。

## 步骤 7：回复用户

必须包含：

- 干净导入目录链接
- 实际应导入的短文件名链接
- 导入后 Roblox 默认模型名，例如 `05_faces1485_1024tex`
- 内部输出目录链接，仅作为排查用
- 如果是普通 FBX 包，说明同目录贴图不要移走
- 如果是 PBR 包，说明 fallback map/脚本在 `manual_surfaceappearance_fallback`
- 如果做过材质/亮度修正，说明修正内容和原始版备份位置
- 兼容测试 embedded FBX 链接
- 保底 mesh-only FBX 链接
- 压缩贴图 JPG 链接
- 验证结果
- Roblox 导入顺序

## 反馈闭环

- 目标：把用户给的模型路径转成 Roblox 可直接导入包。
- 检查：脚本输出 `ROBLOX_WEAPON_EXPORT_OK`，文件存在，贴图为 `1024x1024`，优先 GLB 为干净目录短名主文件；FBX 兼容版为外部相对贴图模式，并且 `fbx_glb_scale_match=True`。
- 结果：交付 `faces实际面数_direct_1024tex.fbx`、`faces实际面数_direct_1024tex.glb`、`faces实际面数_embedded_1024tex.fbx`、`faces实际面数_mesh_only.fbx`、`faces实际面数_texture_1024.*`。
- 知识沉淀：追加到 `logs\工作记录.md`，必要时补充本 Obsidian 工作流。

## 补充规则：Roblox 导入名必须写入 GLB 内部

最终交付给用户导入的 GLB，不能只改外层文件名。交付前必须同步修改 glTF JSON 内部名称：

- `scenes[].name`：最终导入名，例如 `05_faces1485_1024tex`
- 根 `nodes[].name`：最终导入名；多节点使用 `最终导入名_node_02`
- `meshes[].name`：`最终导入名_mesh`
- `materials[].name`：`最终导入名_mat`

验证项固定为：

```text
glb_internal_names_include_faces=True
scene_name=<最终导入名>
root_node_name=<最终导入名>
mesh_name=<最终导入名>_mesh
material_name=<最终导入名>_mat
```

原因：Roblox 导入预览窗口可能优先显示 GLB 内部 `Scene`、node 或 mesh 名。只改 `.glb` 文件名时，用户在 Roblox 里仍可能看到 `Scene` 或脚本内部长名，无法判断哪个模型对应哪个面数。
