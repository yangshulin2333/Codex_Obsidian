# Roblox 可直接导入版打包流程

更新时间：2026-07-27

## 这个流程解决什么

把 Tripo、Meshy 或其他 3D 模型网站导出的模型包，整理成 Roblox Studio 更容易直接导入的文件。

用户常见输入：

```text
D:\Download\3DModel\MagicBook\2-1.fbx 转一下
C:\Users\14176\Desktop\武器\玩具\模型导出-最终版\Gear.fbx 转成roblox可直接导入版
```

注意：很多路径虽然以 `.fbx` 结尾，但实际是一个目录包，里面才是真正的 `tripo_convert_*.fbx` 和 `.fbm` 贴图目录。不要把这种源包直接交给 Roblox。

## 当前固定结论

- 工作流根目录：`D:\AI\Codex\Codex_Obsidian\81_WorkFlow 工作流\Roblox\模型相关\Roblox 可直接导入版打包流程`
- 固定脚本：`scripts\Prepare-RobloxWeaponImport.ps1`
- 默认 Studio 导入包输出根目录：`%USERPROFILE%\Documents\RobloxImportPackages`
- 兼容说明：如需输出到指定目录，可显式传入 `-OutputRoot`。
- 本地工作记录：`logs\工作记录.md`
- 当前默认纹理：`1024x1024`
- 当前优先导入文件：干净目录第一层的 `<短名>.glb`
- 当前用户侧最终导入文件名：`<序号>_faces<Roblox性能面数>_1024tex.<fbx/glb>`，例如 `04_faces5591_1024tex.glb`
- `IMPORT_THIS` 只允许出现在说明文字、README 或目录提示里，禁止进入实际被 Roblox 选择导入的文件名。
- 当前 FBX 贴图策略：优先使用同目录外部相对贴图，不默认内嵌贴图。
- 当前 FBX 尺寸策略：应用对象旋转与缩放后，以 `global_scale=1` 导出，并自动回导比较 FBX / GLB 包围盒。
- 当前材质策略：通用导出可控制 Metallic、Roughness、BaseColor/贴图亮度等导入观感；暗色非金属资产不要直接套用偏金属的通用材质。
- 当前兼容测试文件：`*_faces实际面数_embedded_1024tex.fbx`
- 当前验证标志：`ROBLOX_WEAPON_EXPORT_OK`

旧记录里可能出现 `512`，那是历史版本或低配包。现在除非用户明确要求低配、批量极轻量化或 Roblox 上传限制排查，否则统一用 `-TextureSize 1024`。

## 新对话触发条件

只要用户给出本地模型路径，并表达下面任意意思，就直接走本流程：

- 转一下
- 生成 Roblox 可导入版
- 转成 Roblox 可直接导入版
- 生成可直接导入 Roblox 版本
- 生成 Roblox 可导入 FBX
- 路径包含 `.fbx`、`.glb`、`texture_fbx`、`Meshy_AI`、`模型下载`，且上下文是在处理 3D 模型导入 Roblox

不要停在教程层面，不要让用户手动找 FBX 或贴图。

## 文档索引

1. [[01_单个模型转Roblox可直接导入版_SOP]]
2. [[02_源文件问题诊断]]
3. [[03_交付与记录模板]]

## 固定执行命令

```powershell
$WorkflowRoot = "D:\AI\Codex\Codex_Obsidian\81_WorkFlow 工作流\Roblox\模型相关\Roblox 可直接导入版打包流程"
& "$WorkflowRoot\scripts\Prepare-RobloxWeaponImport.ps1" `
  -InputPath "用户给的文件或目录路径" `
  -Name "自动推断或用户指定的名称" `
  -ImportNamePrefix "最终导入名前缀，例如 05" `
  -TextureSize 1024
```

不传 `-OutputRoot` 时，脚本会自动输出到 `%USERPROFILE%\Documents\RobloxImportPackages`，避免 Roblox Studio 读取 FBX 贴图时受中文长路径影响。

## 标准输出

输出目录：

```text
%USERPROFILE%\Documents\RobloxImportPackages\名称_roblox_direct
```

标准文件：

```text
名称_faces实际面数_direct_1024tex.fbx
名称_faces实际面数_direct_1024tex.glb
名称_faces实际面数_embedded_1024tex.fbx
名称_faces实际面数_mesh_only.fbx
名称_faces实际面数_texture_1024.jpg
README_import_order.txt
```

## 用户侧干净导入目录

脚本输出目录可以保留内部追踪用的长名称，例如 `ElfAlchemy-05-FrostPrismShard-PBR_faces2931_pbr.glb`。但最终交给用户在 Roblox 导入窗口里选择的文件，必须再复制到一个干净目录，并改成短名称：

```text
%USERPROFILE%\Documents\RobloxImportPackages\<短名>_IMPORT_ONLY
```

干净目录第一层只放：

```text
<序号>_faces<实际面数>_1024tex.<fbx/glb>
README_IMPORT_THIS_ONLY.txt
manual_surfaceappearance_fallback\
```

命名规则：

- 优先从源文件或源目录提取开头编号，例如 `05_霜棱碎片PBR` -> `05`。
- 面数使用 Roblox/GPU 实际渲染更接近的三角面数，也就是 GLB/Roblox 导入后的三角化面数。源 FBX/生成器界面可见的 Quad 面数只作为来源备注，不用于性能命名。
- 贴图尺寸使用本流程默认 `1024tex`。
- 最终导入文件名不要包含资产英文描述、`PBR`、`IMPORT_THIS`、`direct`、`embedded` 等调试词。

示例：

```text
04_翡翠时序魔法书，源 faces=3330，三角化诊断 faces=5591，texture=1024 -> 04_faces5591_1024tex.glb
02_太阳巨龙魔法书，源 faces=3550，三角化诊断 faces=5554，texture=1024 -> 02_faces5554_1024tex.glb
```

Roblox 默认会把导入后的 Model 命名为文件基名。为了减少后续整理成本，最终导入名必须按上面的短格式输出。

重要：只改 GLB 文件名不够。执行脚本时必须传入 `-ImportNamePrefix`，让脚本把最终导入名同步写入 GLB 内部 `scenes[].name`、根 `nodes[].name`、`meshes[].name`、`materials[].name`，例如 `01_faces3702_1024tex`、`01_faces3702_1024tex_mesh`、`01_faces3702_1024tex_mat`。否则 Roblox 导入预览可能仍显示 `Scene` 或脚本内部长名。

说明：

- `*_direct_1024tex.glb` 是当前优先导入版，正式交付时复制到 `_IMPORT_ONLY` 干净目录并改成短名。
- `*_direct_1024tex.fbx` 是 FBX 兼容测试版，贴图以同目录图片形式引用。导入时不要把同目录的 `*_texture_1024.*` 移走。
- `*_embedded_1024tex.fbx` 是兼容测试版，仅在 direct FBX 失败、需要排查 FBX 贴图链路时使用。
- 贴图来源可以是同目录图片、当前 FBX 自己的 `.fbm` 目录，或真实单文件 FBX 内的 packed base color 图片；脚本会统一转成同目录 `*_texture_1024.*`。
- 如果源文件确实没有可用颜色贴图，`texture=none`、`embedded_fbx=none` 是允许结果，此时以 direct FBX、GLB 和 mesh-only FBX 交付。

## Roblox 导入顺序

1. 先导入 `_IMPORT_ONLY` 干净目录第一层的短名主 GLB，例如 `09_faces2512_1024tex.glb`。
2. 如果 GLB 贴图异常，再打开内部输出目录试 `*_faces实际面数_direct_1024tex.fbx`，并保持 `*_faces实际面数_texture_1024.*` 在同一目录。
3. 如果需要继续排查 FBX 兼容性，再试 `*_faces实际面数_embedded_1024tex.fbx`。
4. 如果仍失败，用 `*_faces实际面数_mesh_only.fbx + *_faces实际面数_texture_1024.*` 保底。

## 必须验证

完成后至少确认：

```text
ROBLOX_WEAPON_EXPORT_OK
faces=实际面数
texture=1024x1024 或 none
filename includes faces实际面数
glb_internal_names_include_faces=True
direct_fbx generated
direct_fbx_texture_mode=external_relative 或 none
fbx_scale_mode=match_glb_world_scale
fbx_glb_scale_match=True
direct_glb generated
embedded_fbx generated when texture exists
mesh_only_fbx generated
```

FBX 尺寸验证重点：

```text
fbx_dimensions=(x, y, z)
glb_dimensions=(x, y, z)
fbx_glb_scale_match=True
```

如果 FBX 与 GLB 任一轴的相对尺寸误差超过门限，脚本直接失败，不发布导入包。旧版 `global_scale=0.01 / roblox_unit_1` 只适用于携带特定 100 倍节点缩放的来源，会把已经正常化的模型缩小 100 倍，现已废止。

## 材质与亮度控制

脚本不只是转格式，也会影响 Roblox 导入后的观感。当前至少能控制：

- `Metallic`：是否表现为金属反光。
- `Roughness`：表面粗糙度，影响高光和阴影表现。
- `BaseColor`/贴图：可保持原贴图，也可做轻微亮度或暗部提升。
- `SurfaceAppearance`：PBR 专版可进一步绑定 ColorMap、NormalMap、RoughnessMap、MetalnessMap。

Tripo / Hyper3D 小型武器要额外区分“PBR 材质”和“预览匹配材质”：

- 如果源包里有 `shaded.png`，且 Roblox 里的 PBR 版比生成器预览更糊或更平，优先额外交付一个 `shaded` 测试版：只把 `shaded.png` 作为 BaseColor，不注入 normal/roughness/metallic。
- 如果源包没有独立 `shaded.png`，但只有一张带明显高光和阴影的 `basecolor`，不要伪造成 PBR；按 baked/shaded-looking BaseColor 处理。
- 为了避免继续变糊，源贴图已经是目标尺寸时，最终 GLB 优先保留源图 bytes，不做重复 JPEG/PNG 重编码。
- `_shaded` 只用于排查或预览匹配测试版。用户确认采用后，正式交付仍应回到 `<序号>_faces<实际面数>_<贴图尺寸>tex` 短名，除非用户明确要求保留 `_shaded`。

通用材质适合大部分武器、矿石、金属饰品，但不一定适合暗色非金属模型。遇到下面类型要额外检查：

- 魔法书
- 纸张、布料、皮革、木头
- 暗色贴图占比很高的模型
- 源 FBX 材质明确为 `Metallic=0`、高 `Roughness` 的模型

检查规则：

```text
如果源贴图 mean_luma 很低，但输出贴图 mean_luma 基本一致：
  不是贴图缩放压暗，通常是源贴图本身暗或材质/Roblox 光照造成。

如果源材质 Metallic=0 / Roughness 高，而通用导出改成 Metallic>0 / Roughness 较低：
  需要提供非金属修正版。
```

已验证案例：

```text
01_深渊星辰魔法书
源贴图 mean_luma=51.24
输出贴图 mean_luma=51.27
结论：贴图未被脚本压暗。
修正：Metallic=0.0, Roughness=0.9, 暗部温和提亮到 mean_luma≈72.74。
```

后续遇到同类问题时，优先在 `_IMPORT_ONLY` 目录保持同一个短文件名替换修正版，并把原始偏暗版放进 `manual_fallback` 备份，避免用户在 Roblox 导入窗口里误选。

## 禁止事项

- 不要临时写 `.codex_tmp/prepare_roblox_fbx.py`、`inspect_fbx.py` 替代固定脚本。
- 不要输出 `Roblox_Ready` 这类未验证目录。
- 不要默认把 PBR 多贴图全部嵌入 FBX。
- 不要默认把 Tripo/Meshy 原始 FBX 直接交给用户导入。
- 不要只给裸路径，最终必须给可点击链接。
