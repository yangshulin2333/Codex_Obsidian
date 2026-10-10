# Studio 纯色预览棚使用说明

脚本路径：

```text
D:\SVN\Tools\Create_WeaponPreview_SolidBackground_CommandBar.luau
```

## 用途

在空 Roblox 模板中创建一个干净的纯色武器预览空间，避免原项目 Workspace 里角色、NPC、UI、地形和背景干扰判断。

## 使用步骤

1. 打开 Roblox Studio 空模板。
2. 打开 `View > Command Bar`。
3. 复制脚本全部内容到 Command Bar。
4. 回车运行。
5. 运行后会创建：

```text
Workspace/__WeaponPreviewStudio
```

6. 把单独武器复制到 `Workspace`。
7. 把武器移动到：

```text
Workspace/__WeaponPreviewStudio/WeaponPlacePoint
```

附近。

## 重要修复记录

旧版脚本把相机设成：

```lua
workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
```

这样会导致用户无法正常移动视角。

当前脚本已改成：

```lua
workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
```

如果遇到视角不能动，可以在 Command Bar 运行：

```lua
if workspace.CurrentCamera then
	workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
end
```

## 使用原则

1. 预览棚只负责干净环境，不负责最终展示效果。
2. 不要在预览棚里放多个角色、NPC 或复杂地图。
3. 判断模型时优先看：
   - 外轮廓
   - 贴图是否清楚
   - 面数压低后是否变块
   - Roblox 导入是否报错
