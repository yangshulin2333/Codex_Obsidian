# Tools 工具说明

这个目录里的工具必须保持通用，不写死项目名、GUI 名、页面名。

## 默认 HTTP 流程

```text
Start-GuiSnapshotReceiver.ps1
Receive-GuiSnapshotHttp.py
RobloxStudio_GuiHttpSnapshotExporter.luau
```

推荐由 Codex 启动接收器：

```powershell
powershell -ExecutionPolicy Bypass -File "<WorkflowDir>\Tools\Start-GuiSnapshotReceiver.ps1" `
  -OutDir "<ProjectDir>\Project_Analysis_Package\GuiSnapshots" `
  -Name "<GuiName>_Current_Http"
```

然后由 Codex 填写 `RobloxStudio_GuiHttpSnapshotExporter.luau` 顶部的 `TARGET_JOBS`，用户只在 Roblox Studio Command Bar 运行脚本。

## Output 备用流程

```text
RobloxStudio_GuiSnapshotExporter.luau
Parse-GuiSnapshot.ps1
Parse-ChunkedGuiSnapshot.ps1
```

只有项目不能开启 HTTP Requests 时，才使用 Output 备用流程。

## 对比和素材检查

```text
Compare-GuiSnapshots.ps1
Test-UiAssetMap.py
Test-UiAssetMap.ps1
```

`Compare-GuiSnapshots.ps1` 支持：

```text
1. Output markdown 快照。
2. HTTP 单段 JSON。
3. HTTP combined JSON。
```

`Test-UiAssetMap.py` 用于检查素材表，支持纯数字、`rbxassetid://数字`、Roblox URL 中的 `id=数字`。
