# UI 理解清单

读 Roblox GUI 时，必须按这张清单走。

## 1. 总结构

```text
ScreenGui
Root
Page / Window / Popup
TopBar
TabBar
Body
LeftPanel
RightPanel
List / Scroll
Button / Text / Icon
```

要说明哪些是共用层，哪些是页面独有层。

## 2. 当前状态

必须确认：

```text
1. 哪个页面 Visible = true
2. TitleText 当前文字
3. 当前选中 Tab 的 Image
4. 影响切页的 Attribute，例如 TargetAttrContent、CurrentAttrContent
5. 顶部点数区域、关闭按钮、重置按钮是否显示
```

## 3. 布局

必须检查：

```text
1. Position / Size 是否使用 Scale
2. AnchorPoint 是否适合居中
3. LeftPanel / RightPanel 是否基于父框架居中
4. 子控件是否贴边、越界、重叠
5. ZIndex 是否能保证按钮、文字在背景上方
```

## 4. 素材

必须检查：

```text
1. Image AssetId
2. SourceAsset 自定义属性
3. NormalImage / SelectedImage
4. 顶部分割线、面板背景、按钮底图是否漏掉
5. Icon 和 Text 是否分层清楚
6. 本地 PNG 是否存在
7. AssetId 表里是空、纯数字、rbxassetid://数字，还是异常格式
```

AssetId 判断规则：

```text
1. 纯数字是合法的，写入 Roblox UI 前统一成 rbxassetid://数字。
2. rbxassetid://数字 是合法的，不应该被当成缺失。
3. Roblox URL 里带 id=数字 也是可解析格式。
4. 空值才是缺 AssetId；reference_only_layout_screenshot / no_asset_id_needed 例外。
5. 本地有 PNG 但 AssetId 为空时，应该说“本地图存在，但脚本暂时不能显示，需要上传或补 ID”。
```

如果素材表和用户看到的不一致：

```text
1. 先说明 Codex 读取的磁盘文件路径。
2. 运行 Tools/Test-UiAssetMap.py 生成检查报告，优先直接读取用户指定的 `.xlsx`。
3. 如果报告为空但用户表格界面有值，提醒用户保存表格，再重新读取。
4. 必要时帮用户打开表格，而不是让用户自己找。
5. 如果 `.xlsx` 和 `.csv` 不一致，使用用户明确指定的源文件，并同步或重生成辅助 CSV。
```

## 5. Slice / 九宫格

拉伸图片必须检查：

```text
ScaleType = Slice
SliceCenter
SliceScale
```

如果没有美术给 Slice 参数，默认用图片边长的一半作为上下左右偏移，再转换成 Roblox 的 `Rect.new(left, top, imageW - right, imageH - bottom)`。

## 6. 滚动

ScrollingFrame 必须检查：

```text
CanvasSize
AutomaticCanvasSize
ScrollingDirection
ScrollBarThickness
VerticalScrollBarInset
ClipsDescendants
```

如果用户说“滑不到最底部”，优先看：

```text
1. AutomaticCanvasSize 是否为 Y
2. CanvasSize 是否足够
3. 最后一个子节点是否超出 Canvas
4. UIListLayout / UIPadding 是否参与计算
```

## 7. 文字

必须检查：

```text
TextScaled
TextXAlignment
TextYAlignment
TextStrokeTransparency
TextStrokeColor3
TextColor3
TextLabel 自己的 Size 是否够大
```

用户偏好：文字尽量用 Scale，TextSize 可以作为设计参考，但不要靠固定 TextSize 解决适配。

## 8. 编辑态点击切页

如果 Studio 编辑界面可以点按钮切页，要说明清楚来源：

```text
1. 是 Command Bar 脚本临时连接了 Button.Activated
2. 这不是正式运行时逻辑
3. Studio 重新打开后可能失效
4. 正式项目后续要单独做 UI Controller / LocalScript
```
