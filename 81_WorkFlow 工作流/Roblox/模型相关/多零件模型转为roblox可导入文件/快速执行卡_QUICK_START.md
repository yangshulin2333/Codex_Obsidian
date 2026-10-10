---
type: checklist
domain: roblox
status: active
owner: mixed
source: mixed
created: 2026-08-14
updated: 2026-08-17
---

# 多零件 Roblox GLB 快速执行卡

## 用户只需说

```text
参考 ：D:\AI\Codex\Codex_Obsidian\81_WorkFlow 工作流\Roblox\模型相关\多零件模型转为roblox可导入文件 工作流，导出为可直接导入roblox的文件
```

不需要提供 `.blend` 路径、资产名、格式或贴图尺寸。

## Codex 默认动作

1. 从当前对话、当前 Blender 文件、最近的 `*_ROBLOX_EXPORT_vNN.blend` 和当前项目唯一候选中依次定位源文件。
2. 确认正式 Mesh 范围；上下文已明确时不重复询问。
3. 自动沿用当前武器名，或从 `.blend` 文件名生成短英文资产名。
4. 运行 `scripts/Export-RobloxMultiPartGlbFast.ps1`。
5. 脚本只生成一个 GLB，并自动工厂空场景回导。
6. 返回 GLB 绝对路径和验证结果，然后停止。

```powershell
& 'D:\AI\Codex\Codex_Obsidian\81_WorkFlow 工作流\Roblox\模型相关\多零件模型转为roblox可导入文件\scripts\Export-RobloxMultiPartGlbFast.ps1' `
  -BlendPath 'D:\Path\Asset_ROBLOX_EXPORT_v01.blend' `
  -AssetName Asset_v01
```

默认输出到：

```text
%USERPROFILE%\Documents\RobloxImportPackages\Asset_v01_IMPORT_ONLY\
```

## 只在这些情况停下来

- 存在多个同等可信的 `.blend` 候选，无法唯一定位源文件。
- 正式零件范围不明确。
- 对象没有共享公共原点或变换不是 `0/0/1`。
- 零件不是英文 ASCII 名。
- 材质或贴图缺失。
- GLB 空场景回导不一致。

## 失败后才做

- 修导出副本。
- 生成外置贴图、纯网格或内嵌 FBX 对照。
- 进入 [[03_空场景回导与Studio验收|完整 Studio 故障分流]]。

不要在主 GLB 成功前生成 FBX、长篇 Manifest 或多份同级候选文件。
