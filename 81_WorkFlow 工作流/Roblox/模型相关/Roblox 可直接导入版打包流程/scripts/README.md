# scripts

本目录存放 Roblox 可直接导入版打包脚本。

## 主脚本

```text
Prepare-RobloxWeaponImport.ps1
```

默认行为：

- 自动识别目录、真 FBX、伪 FBX ZIP。
- 自动寻找主 FBX 和颜色贴图。
- 外部图片找不到时，会从真实单文件 FBX 的材质节点中提取 packed base color 图片。
- 自动压缩贴图到 `1024x1024`。
- 用 Blender 后台重新绑定材质。
- 输出文件名自动加入面数。
- 优先 FBX 使用同目录外部相对贴图，降低 Roblox `base_color_texture` 上传失败概率。
- 同时输出 embedded FBX 作为兼容性排查文件。
- FBX 使用 `match_glb_world_scale`：应用对象变换后以世界尺度导出，再自动回导 FBX / GLB 比较包围盒。
- 默认输出到 `%USERPROFILE%\Documents\RobloxImportPackages`，减少 Roblox Studio 读取 FBX 外部贴图时受中文长路径影响的概率。
- 如需指定输出目录，显式传入 `-OutputRoot`。

## 推荐调用

```powershell
$WorkflowRoot = "D:\AI\Codex\Codex_Obsidian\81_WorkFlow 工作流\Roblox\模型相关\Roblox 可直接导入版打包流程"
& "$WorkflowRoot\scripts\Prepare-RobloxWeaponImport.ps1" `
  -InputPath "用户给的文件或目录路径" `
  -Name "输出名" `
  -ImportNamePrefix "最终导入名前缀，例如 05" `
  -TextureSize 1024
```

## 命名硬性规则

- `-Name` 用于内部追踪输出目录，可以保留较完整的英文稳定名。
- `-ImportNamePrefix` 用于 Roblox 最终导入名，默认会组合成 `<ImportNamePrefix>_faces<实际面数>_<贴图尺寸>tex`。
- 例如 `-ImportNamePrefix "05"` 且导出面数为 `3712` 时，最终导入名为 `05_faces3712_1024tex`。
- 脚本会把该最终导入名写入 GLB 内部 `scene/root node/mesh/material` 名称；如果写入失败，脚本直接失败，不交付。
