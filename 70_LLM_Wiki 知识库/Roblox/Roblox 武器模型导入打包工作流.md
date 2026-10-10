---
type: workflow
domain: roblox
status: evergreen
owner: codex
source: mixed
created: 2026-06-26
updated: 2026-07-29
---

# Roblox 武器模型导入打包工作流

## 一句话说明

这个工作流把 Meshy 或其他 3D 模型网站下载的武器模型，整理成 Roblox Studio 更容易导入和测试的 FBX / GLB 包。

## 触发场景

用户给出：

```text
某个 FBX / GLB / 模型下载目录路径
生成可直接导入 Roblox 版本
```

Codex 默认应该直接运行固定脚本，不重新写临时脚本，不让用户手动找贴图。

## 用户负责什么

- 提供下载目录或 FBX 文件路径。
- 在 Roblox Studio 里导入测试。
- 判断外形、贴图、比例是否能接受。
- 把失败截图或报错发给 Codex。

## Codex 负责什么

- 判断输入是目录、真 FBX、还是伪 FBX 压缩包。
- 自动选择主要 FBX。
- 自动选择颜色贴图，排除 normal、roughness、metallic、emissive 等非颜色贴图。
- 如果真实单文件 FBX 没有外部贴图，继续检查材质节点里的 packed base color 图，并导出为同目录 `*_texture_512.jpg`。
- 压缩贴图到 `512x512 jpg`。
- 用 Blender 后台重新绑定材质。
- 输出直接可导入的 FBX / GLB。
- 优先 FBX 使用同目录外部相对贴图，避免 Roblox 对 FBX 内嵌贴图上传不稳定。
- 额外输出 embedded FBX 作为兼容性排查文件。
- FBX 默认使用 `match_glb_world_scale`，并自动回导比较 FBX / GLB 包围盒。
- 保留 mesh-only 保底 FBX 和压缩贴图。
- 给用户可点击文件链接。
- 更新工作记录。

## 固定输出

常见输出目录：

```text
%USERPROFILE%\Documents\RobloxImportPackages\武器名_roblox_direct
```

重点文件：

```text
武器名_faces实际面数_direct_512tex.fbx
武器名_faces实际面数_direct_512tex.glb
武器名_faces实际面数_embedded_512tex.fbx
武器名_faces实际面数_mesh_only.fbx
武器名_faces实际面数_texture_512.jpg
README_import_order.txt
```

## 贴图来源规则

脚本按这个顺序寻找颜色贴图：

```text
1. 输入目录或源 FBX 同目录的外部颜色图
2. 当前 FBX 对应的 .fbm 贴图目录
3. 真实单文件 FBX 内部 packed 的 Base Color 图
```

如果第 3 种命中，脚本会把 packed 图转换成 `*_texture_512.jpg`，并在结果中记录：

```text
source_texture_mode=embedded_packed_image
direct_fbx_texture_mode=external_relative
```

这类输出仍然按“外部相对贴图”导入：`*_direct_512tex.fbx` 和 `*_texture_512.jpg` 必须留在同一目录。`*_embedded_512tex.fbx` 只作为兼容性排查文件。

## Roblox 导入顺序

```text
1. 先导入 *_direct_512tex.fbx，并保持 *_texture_512.jpg 在同一目录
2. 如果出现 base_color_texture 或贴图上传失败，导入 *_direct_512tex.glb
3. 如果需要排查 FBX 兼容性，再试 *_embedded_512tex.fbx
4. 仍失败时导入 *_mesh_only.fbx，再手动上传 *_texture_512.jpg
```

## 验证点

Codex 完成后至少确认：

```text
faces=实际面数
texture=512x512 RGB JPG
source_texture_mode=external_file 或 embedded_packed_image 或 none
direct_fbx generated
direct_fbx_texture_mode=external_relative
fbx_scale_mode=match_glb_world_scale
fbx_glb_scale_match=True
direct_glb generated
embedded_fbx generated when texture exists
mesh_only_fbx generated
```

## 2026-07-07 经验修正

一次魔法杖模型实测中，标准 FBX 报 `base_color_texture` 上传失败，但同包 GLB 可以导入。排查后确认模型几何、贴图尺寸和 GLB 都正常，问题更可能来自 Roblox 对 FBX 内嵌贴图上传/引用链路的不稳定。

后续固定规则：

- `*_direct_512tex.fbx` 不再默认内嵌贴图，而是引用同目录 `*_texture_512.jpg`。
- 默认输出到 `%USERPROFILE%\Documents\RobloxImportPackages`，避免 Roblox Studio 处理 FBX 外部贴图时受 Obsidian 中文长路径影响。
- 导入 direct FBX 时不要把 JPG 从输出目录移走。
- `*_embedded_512tex.fbx` 仅作为兼容性测试和故障排查，不作为首选交付。
- 如果 direct FBX 仍失败但 GLB 成功，优先交付 GLB 或 mesh-only + 手动贴图，不要判断为模型几何损坏。

## 2026-07-07 尺寸修正（历史，已被 2026-07-29 替代）

同一魔法杖模型中，GLB 导入 Roblox Studio 后接近 1 单位，但 FBX 导入后明显巨大。排查 FBX 二进制后发现旧导出包含：

```text
UnitScaleFactor=1
Lcl Scaling=(100,100,100)
vertex max dimension=1
```

这说明几何顶点没有变大，问题来自 FBX 节点缩放元数据。当前脚本已改为：

```text
global_scale=0.01
apply_scale_options='FBX_SCALE_ALL'
```

新输出应满足：

```text
UnitScaleFactor=1
Lcl Scaling=(1,1,1)
vertex max dimension=1
fbx_scale_mode=roblox_unit_1
```

如果用户反馈 FBX 比 GLB 大很多，优先确认是否导入的是旧 FBX；重新运行当前工作流后再测试。

这条固定 `global_scale=0.01` 规则只适合当时携带 100 倍节点缩放的来源。2026-07-29 实测证明它会把已经正常化的 FBX 缩小 100 倍，因此不再作为当前规则。

## 2026-07-08 内嵌贴图修正

`HY014`、`HY016` 两个魔法杖源文件是真实单文件 FBX，颜色贴图 packed 在 FBX 内部；旧脚本只扫描外部图片和 `.fbm` 目录，因此误判为 `texture=none`。

当前脚本已补上 packed 图提取：

- 外部贴图缺失时，扫描 Blender 材质节点里的 `ShaderNodeTexImage`。
- 优先选择连接到 `Base Color` 的图片。
- 降低 normal、roughness、metallic、emissive、ao、height 等非颜色图优先级。
- 将命中的 packed 图输出为同目录 `*_texture_512.jpg`。
- README 中记录 `Source texture: embedded packed image extracted from source FBX`。

修正后 `HY014`、`HY016` 均已重新导出 direct FBX、GLB、embedded FBX、mesh-only FBX 和 `512x512 Format24bppRgb JPG` 贴图。

## 2026-07-29 局部纹理修复门禁

Tripo 低模整体可用、只有少数底面或侧面纹理异常时，先进入独立修复流程，不直接用打包脚本覆盖材质：

```text
只读拓扑与 UV 审计
-> 恢复原始 Base Color
-> 只选择异常面
-> 保护非目标 UV
-> 正面 / 侧面 / 异常面三视角复核
-> FBX / GLB 回导
-> 512 标准打包
```

固定规则：

- 原 Tripo 纹理大部分可用时，禁止重画整张 UV 图集。
- 修复必须以原 Base Color 为底图，只写入确认的目标面。
- 底面修复后必须复核侧面；侧面变差则回退目标面范围。
- 2K 保留为 Blender 修复母版，512 是 Roblox 默认交付。
- 几何、UV、三角面和贴图尺寸必须在导出后回导验证。
- 游戏内最终完成仍以目标 Roblox 游戏的 Studio 验收为准。

### 尺度自检补充

当前导出器使用：

```text
fbx_scale_mode=match_glb_world_scale
global_scale=1
fbx_dimensions=(x, y, z)
glb_dimensions=(x, y, z)
fbx_glb_scale_match=True
```

导出器会自动回导 direct FBX 和 GLB。任一轴相对误差超出门限就直接失败，不发布导入包。

## 和 Tripo 多视图的区别

| 工作流 | 输入 | 输出 | 目的 |
|---|---|---|---|
| Tripo 多视图 | 武器截图或设计图 | front / back / left / right PNG | 给 3D AI 建模用 |
| 武器导入打包 | FBX / GLB / 下载目录 | Roblox 可导入 FBX / GLB | 给 Studio 导入测试用 |

## 来源

- [[../../81_WorkFlow 工作流/Roblox/模型相关/Roblox 可直接导入版打包流程/README]]
- [[../../81_WorkFlow 工作流/Roblox/模型相关/Roblox 可直接导入版打包流程/02_源文件问题诊断]]
- [[../../81_WorkFlow 工作流/Roblox/模型相关/Roblox 武器模型制作工作流/Tripo武器低模清理与局部纹理修复流程]]

## 相关链接

- [[Tripo 多视图工作流]]
- [[知识卡/Accessory挂到角色身体部位知识卡|Accessory 挂到角色身体部位知识卡]]
