---
type: workflow
domain: roblox
status: active
owner: mixed
source: mixed
created: 2026-06-07
updated: 2026-07-29
---

# Roblox 导入打包流程

本页是武器任务入口。实际打包实现由相邻的通用工作流统一维护：

```text
../Roblox 可直接导入版打包流程/
```

禁止在武器、魔法书、魔法杖目录内各复制一份完整导出器。

路径变量：

```text
{WORKFLOW_ROOT}  当前“Roblox 武器模型制作工作流”目录
{SOURCE_PACKAGE} 用户提供的模型文件或目录
{DELIVERY_ROOT}  交付目录；不指定时使用通用脚本默认目录
```

## 什么时候用

用户给出 3D 模型网站下载的武器模型路径时，直接用这个流程。

最高优先级触发语句：

```text
生成可直接导入roblox版本
生成可直接导入 Roblox 版本
生成 Roblox 可导入版
生成 Roblox 可导入 FBX
可直接导入roblox
```

用户只要把这些话和一个本地模型路径一起发来，就不要重新写脚本，不要输出 `Roblox_Ready`，直接运行本流程的一条命令。

适用输入：

1. 下载目录。
2. 真 FBX 文件。
3. 表面是 `.fbx`、实际是 ZIP 压缩包的 Meshy 下载文件。

## 一条命令处理

用户给目录时，直接把目录放进 `-InputPath`：

```powershell
& "{WORKFLOW_ROOT}\scripts\Prepare-RobloxWeaponImport.ps1" `
  -InputPath "{SOURCE_PACKAGE}" `
  -Name "武器名或编号" `
  -TextureSize 512
```

用户给具体 FBX 时，也可以直接放进 `-InputPath`：

```powershell
& "{WORKFLOW_ROOT}\scripts\Prepare-RobloxWeaponImport.ps1" `
  -InputPath "{SOURCE_PACKAGE}\模型文件.fbx" `
  -Name "武器名或编号" `
  -TextureSize 512
```

换新武器时，通常只改：

```text
-InputPath
-Name
```

如果用户没给 `-Name`，脚本会用目录名或文件名自动生成输出名。

## 脚本现在会做什么

1. 判断 `InputPath` 是目录还是文件。
2. 如果是目录，递归查找主要 `.fbx`，默认选体积最大的 FBX。
3. 查找时排除 `Roblox_Ready`、`Roblox_Import*`、`.fbm`、`*_roblox_direct` 等历史输出目录，避免误选失败文件。
4. 如果是文件，判断是否为 ZIP 伪装包。
5. 如果是 ZIP 伪装包，自动解压并找真正的 FBX。
6. 自动寻找颜色贴图。
7. 贴图选择优先级：
   - 与 FBX 同目录优先。
   - 文件名包含 `basecolor`、`albedo`、`diffuse`、`color`、`texture` 优先。
   - 文件名包含 `normal`、`roughness`、`metallic`、`emissive`、`ao`、`height` 的贴图降权。
8. 把颜色贴图压成默认 `512x512 jpg`。
9. 用 Blender 后台导入 FBX。
10. 重新创建材质并绑定压缩贴图。
11. 输出外部相对贴图 FBX、GLB、内嵌 FBX 和 mesh-only 保底。
12. 记录面数、贴图来源和 FBX 缩放模式。

如果输入已经完成 Blender MCP 局部修复，打包脚本只负责格式与贴图尺寸转换，不重新展开 UV，也不重新绘制纹理。

## 输出

输出目录一般是：

```text
%USERPROFILE%\Documents\RobloxImportPackages\武器名_roblox_direct
```

里面重点看这几个：

```text
武器名_faces实际面数_direct_512tex.fbx
武器名_faces实际面数_direct_512tex.glb
武器名_faces实际面数_embedded_512tex.fbx
武器名_faces实际面数_mesh_only.fbx
武器名_faces实际面数_texture_512.jpg
README_import_order.txt
```

## Roblox 里怎么导

### 首次测试

1. 打开 Roblox Studio 的目标游戏。
2. 菜单选择 `File > Import`。
3. 选择 `*_direct_512tex.fbx`。
4. 在 Importer 中先关闭 `Upload to Roblox`，保留 `Add to Workspace`，用于无污染测试。
5. 检查预览中的模型方向、尺寸、材质和警告。
6. 点击 `Import`。

### 文件优先级

1. 导入 `*_direct_512tex.fbx`，不要移动同目录的 `*_texture_512.jpg`。
2. 如果贴图上传失败，导入 `*_direct_512tex.glb`。
3. 如需排查 FBX 兼容性，再试 `*_embedded_512tex.fbx`。
4. 如果还是失败，导入 `*_mesh_only.fbx`。
5. 最后手动上传 `*_texture_512.jpg`，并填到 MeshPart 的 `TextureID / TextureContent`。

### 导入后属性

对作为游戏道具的 MeshPart，先设置：

```text
Anchored=true         制作和检查阶段
CanCollide=false
CanTouch=false
CanQuery=false
CastShadow=按项目需求
RenderFidelity=Automatic 或 Precise
CollisionFidelity=Box 或 Hull
```

挂到 Tool 或装备系统前再改为 `Anchored=false`，并使用项目既有的 Handle、Attachment 或焊接规则。

## Codex 输出给用户时必须这样做

不要只给裸路径。要给可点击链接：

```md
- [打开输出文件夹](<{DELIVERY_ROOT}\武器名_roblox_direct>)
- [优先导入 FBX](<{DELIVERY_ROOT}\武器名_roblox_direct\武器名_faces实际面数_direct_512tex.fbx>)
- [备用 GLB](<{DELIVERY_ROOT}\武器名_roblox_direct\武器名_faces实际面数_direct_512tex.glb>)
- [保底 mesh-only FBX](<{DELIVERY_ROOT}\武器名_roblox_direct\武器名_faces实际面数_mesh_only.fbx>)
- [压缩贴图 JPG](<{DELIVERY_ROOT}\武器名_roblox_direct\武器名_faces实际面数_texture_512.jpg>)
```

同时报告：

```text
faces=实际面数
texture=512x512 RGB JPG
source_texture_mode=external_file 或 embedded_packed_image
direct_fbx generated
direct_glb generated
embedded_fbx generated
mesh_only_fbx generated
```

## 如何判断问题

如果 Roblox 报：

```text
base_color_texture 上传失败
```

优先判断是贴图/材质上传问题。

处理顺序：

1. 确认 512 贴图与 direct FBX 在同一目录。
2. 再试 `direct_512tex.glb`。
3. 再试 `mesh_only.fbx + 手动 texture_512.jpg`。
4. 如果 mesh-only 都导不进去，再考虑面数、FBX 版本、模型结构、Roblox 导入器兼容问题。

## 验证记录放哪里

具体某一把武器的输入、输出、面数、失败原因、解决方式，统一写入：

```text
{WORKFLOW_ROOT}\工作记录.md
```

主流程文档只保留通用规则，不绑定某个具体模型。

## 官方参考

- [Roblox Studio Importer](https://create.roblox.com/docs/studio/importer)
- [Roblox Texture specifications](https://create.roblox.com/docs/art/modeling/texture-specifications)
- [Roblox Reimport](https://create.roblox.com/docs/art/modeling/reimport)
- [Roblox MeshPart](https://create.roblox.com/docs/reference/engine/classes/MeshPart)
