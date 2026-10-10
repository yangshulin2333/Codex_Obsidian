


### **总原则**
- UI 尽量用 `Scale`，少用 `Offset`，否则换分辨率/手机会变形。
- 图片 UI 导入后优先设 `ScaleType = Fit`，避免被拉伸。
- 保持清晰层级：`StarterGui > ScreenGui > 主容器 > 功能区域 > 具体控件`。
- 只在真正需要锁比例的“主容器/卡片容器”加 `UIAspectRatioConstraint`，不要给所有子对象乱加。
- 用 `ZIndex` 控制遮挡；背景通常负值，内容正值，参考图可临时设高值便于对齐。
- 导入时能在 Studio 里做的文字、按钮、渐变、描边，不要全部导成图片，后期更灵活。

#### **1. 图片导入与 Asset ID**
- Roblox Studio 内可批量导入图片。
- 导入完成后，在资源上右键 `Copy ID to Clipboard`，把 ID 填入 `ImageLabel.Image` 或 `ImageButton.Image`。
- 也可以到 `create.roblox.com > Creations > Development Items > Decals > Upload Asset` 上传。
- 注意：Roblox 的图片通常通过 decal 上传，再复制 asset ID 使用。
- 粘贴 ID 时只需要数字 ID；带 `rbxassetid://` 形式通常也能用。

#### **2. ScreenGui**
- `ScreenGui` 是 2D UI 的容器，应放在 `StarterGui` 下。
- `ScreenInsets`：控制 UI 是否避开手机安全区/顶部系统 UI。全屏 UI 如果被裁切，可设为 `None`。
- `DisplayOrder`：多个 `ScreenGui` 的显示顺序，类似全局层级。
- `Enabled`：开关整个 UI。
- `IgnoreGuiInset`：避免 Roblox 默认顶部栏影响 UI 位置。
- `ResetOnSpawn`：玩家重生后 UI 是否重置。
- `ZIndexBehavior`：视频建议保持 `Sibling`。

#### **3. BillboardGui**
- 用于 3D 世界中的 UI，始终面向相机，例如角色头顶名字、血条、提示。
- 关键属性：
  - `Active`：是否可交互/鼠标变点击样式。
  - `AlwaysOnTop`：是否无视遮挡始终显示在前。
  - `Enabled`：显示开关。
  - `LightInfluence`：受场景光照影响程度。
  - `MaxDistance`：超过距离后隐藏。
  - `StudsOffset`：相对绑定对象偏移；Y 往上，X 左右，Z 前后。
  - `ClipsDescendants`：子元素超出容器是否裁切。

#### **4. SurfaceGui**
- 把 UI 贴到 3D 物体表面，也可当“纹理屏幕”使用。
- 常见做法：`SurfaceGui` 放在 `StarterGui`，`Adornee` 指向 Workspace 里的 Part。
- 关键属性：
  - `Adornee`：绑定到哪个 Part。
  - `Face`：显示在哪个面，如 Front/Back/Left/Right/Top/Bottom。
  - `AlwaysOnTop`：被物体挡住时是否仍显示。
  - `LightInfluence`：受环境光影响。
  - `MaxDistance`：可视距离。
  - `PixelsPerStud`：每 stud 对应多少像素，影响清晰度/比例。
  - `ClipsDescendants`：裁切超出部分。

#### **5. 层级与 ZIndex**
- 导入 UI 时先搭层级，再调细节。
- 如果按钮在 holder frame 下方但看不见，多半是 `ZIndex` 或父子层级错了。
- 同一父级下，`ZIndex` 越大越靠前；也可用负数把背景压到后面。
- 示例：背景 `-10`，普通内容 `0/1`，文字/按钮 `3+`，参考图临时 `50`。

#### **6. Frame**
- `Frame` 是最常用的 UI 容器，可装文字、图片、按钮、列表等。
- `Active`：是否响应鼠标交互。
- `AnchorPoint`：动画和定位很重要，常用 `0.5, 0.5` 居中。
- `AutomaticSize`：内容变长时自动扩容；使用时常把基础 `Size` 设为 `0,0`，让子元素决定尺寸。
- `BackgroundColor3` / `BackgroundTransparency`：颜色与透明度。
- 视频不建议用默认 Border，建议用 `UIStroke`。
- `LayoutOrder`：配合 `UIListLayout` / `UIGridLayout` 控制排序。
- `Rotation`：旋转角度。
- `Visible`：显示开关。
- `ClipsDescendants`：隐藏超出父容器的内容。

#### **7. TextLabel**
- 基础属性继承 Frame 的思路。
- `FontFace`：选择字体，可用方向键快速预览。
- `Weight` / `Style`：字重、粗体、斜体。
- `LineHeight`：多行文字行距。
- `RichText`：允许一段文字中局部改色/加格式。
  - 示例：`<font color="#ff0000">49</font>/100`
- `TextColor3`：文字颜色。
- `TextScaled`：文字随容器缩放。
- `TextSize`：未开启 `TextScaled` 时的字号。
- `TextXAlignment` / `TextYAlignment`：水平/垂直对齐。
- `TextStroke` 或给 TextLabel 加 `UIStroke`：做描边效果。

#### **8. ImageLabel**
- 用于显示图片，关键是 `Image` 和 `ScaleType`。
- `Image`：填 asset ID。
- `ImageColor3`：给图片染色；白/灰度图染色效果最好。
- `ImageTransparency`：图片透明度。
- `ImageRectOffset` / `ImageRectSize`：用于 sprite sheet/flipbook。
- `ResampleMode`：像素化或平滑。
- `ScaleType`：
  - `Fit`：保持比例，导入 UI 最推荐。
  - `Crop`：保持比例并裁切填满。
  - `Stretch`：强行拉伸，容易变形。
  - `Tile`：平铺图片，适合重复纹理/加载背景。

#### **9. TextBox**
- 可输入文本，本质接近 TextLabel + 输入能力。
- `ClearTextOnFocus`：点击后是否清空原文本。
- `MultiLine`：允许回车多行。
- `TextEditable`：是否允许用户输入。
- `PlaceholderText`：未输入时显示的提示，如 `Search`。
- `PlaceholderColor3`：占位文字颜色。

#### **10. TextButton / ImageButton**
- `TextButton`：可点击文字按钮。
- `ImageButton`：可点击图片按钮。
- `AutoButtonColor`：Roblox 默认 hover/click 变暗效果；自定义 UI 通常关掉。
- `HoverHapticEffect` / `PressHapticEffect`：内置悬停/按压反馈。
- 如果视觉是 `ImageLabel` 但需要可点击，可在里面放透明 `ImageButton` 当 hitbox。

#### **11. CanvasGroup**
- 用来把一组 UI 当成整体处理。
- 可统一控制子元素透明度/颜色。
- 适合整组淡入淡出，但视频提醒：滚动列表边缘渐隐不建议滥用 CanvasGroup，用遮罩 Frame + UIGradient 更直接。

#### **12. ViewportFrame**
- 在 UI 中显示 3D 模型，比如单位/角色预览。
- 通常放在卡片或详情面板中，替代静态 PNG。
- 需要配合相机和模型设置。
- 导入完整 UI 时，角色展示位建议用 `ViewportFrame`，不要导出成死图。
- 背景可设较深颜色，避免模型边缘出现白边。

#### **13. ScrollingFrame**
- 用于可滚动列表，如背包、单位格子。
- 常配合 `UIGridLayout` 或 `UIListLayout`。
- `CanvasSize`：滚动内容区域大小。
- `AutomaticCanvasSize = Y`：让内容高度随子元素自动扩展。
- 滚动条颜色可用 `ScrollBarImageColor3`，厚度用 `ScrollBarThickness`。
- 视频指出：滚动条厚度在不同设备上的缩放不理想，最好用脚本处理，或自制滚动条。

#### **14. UICorner**
- 给 Frame/Image/Button 圆角。
- 圆形：正方形对象 + `UICorner.CornerRadius = 1`。
- 导入后圆角也要转成 Scale，避免不同分辨率下圆角不一致。

#### **15. UIStroke**
- 用于描边，替代默认 Border。
- 可设置 `Color`、`Thickness`、`Transparency`。
- `Thickness` 默认是像素值，导入后应转成 Scale。
- 文字描边也可通过给 TextLabel 加 `UIStroke` 实现。

#### **16. UIPadding**
- 给容器内部留边距。
- 常用于列表、按钮文字、搜索框。
- Padding 也应转成 Scale。
- 视频后面提到某些 padding/插件处理可能未来变化，实际项目中以当前 Studio 表现为准。

#### **17. UIScale**
- 整体缩放某个 UI 分支。
- 可用于适配、动画、整体放大缩小。
- 但不要用它替代正确的 Scale 尺寸体系。

#### **18. UIAspectRatioConstraint**
- 用于锁定宽高比。
- 正确做法：给“需要保持比例的主容器/卡片/圆形容器”加。
- 错误做法：给每个子元素都加，或给全屏 HUD 主背景乱加。
- 全屏 UI 如果锁死 16:9，在手机、VGA、方屏上会出现空边或布局错误。

#### **19. UIGradient**
- 可做颜色渐变，也可做透明度遮罩。
- `Color`：渐变颜色。
- `Transparency`：渐隐/隐藏局部。
- `Rotation`：方向，如 45、90、135、-90。
- `Offset`：移动渐变，可用于进度条动画。
- 注意：UIGradient 的透明度会影响其父对象整体可见性。

#### **20. UIListLayout**
- 把子元素按一条线排列。
- 加入 layout 后，子元素的 Position 通常不再手动控制。
- 需要局部移动/动画时，可用“占位 Frame + 内部内容偏移”的结构。
- 关键属性：
  - `Padding`：间距。
  - `FillDirection`：Horizontal/Vertical。
  - `SortOrder`：按 `LayoutOrder` 或 `Name` 排。
  - `HorizontalAlignment` / `VerticalAlignment`：对齐方式。
  - `Wraps`：是否换行。

#### **21. UIGridLayout**
- 网格布局，适合背包、卡片列表。
- 比 ListLayout 难动画，但可以统一控制每格大小。
- 关键属性：
  - `CellSize`：每个格子的大小。
  - `CellPadding`：X/Y 间距。
  - `FillDirection`：横向或纵向填充。
  - `FillDirectionMaxCells`：每行/列最大数量；`0` 表示不限直到父级边界。
  - `StartCorner`：从哪个角开始排。
  - `SortOrder`：同 ListLayout。
- GridLayout 默认会换行，不能像 ListLayout 那样完全关闭 wrap。

#### **22. UIPageLayout**
- 把每个子 Frame 当作一页，可滚轮/滑动切页。
- `Animated`：是否播放切页动画。
- `Circular`：最后一页后是否回到第一页。
- Tween 相关属性控制动画行为。
- 视频观点：现在实际项目较少用，更多人用 List/Grid + 自己写动画。

#### **23. UITableLayout**
- 类似表格/Excel 行列布局。
- 视频明确不推荐，认为 2024-2026 基本没人用。
- 实务上优先学 `UIListLayout`、`UIGridLayout`、`UIPageLayout`。

#### **24. 灰度化处理**
- 导入需要变色的图片时，尽量导成白色/灰度。
- 彩色图片用 `ImageColor3` 改色会偏色；白色图片能准确染成任意颜色。
- 适合光效、描边、卡片 glow、hover 高亮。
- 可叠加 `UIGradient` 做双色/多色效果。
- 在第三方软件中，把彩色 glow/icon 处理成白色再导出。

#### **25. Hitbox**
- 如果视觉按钮是 `ImageLabel`，但它本身不可点击，可在里面加透明 `ImageButton`。
- 操作：
  - 在视觉对象下新增 `ImageButton`。
  - 居中、`Fit to Parent Size`。
  - `BackgroundTransparency = 1`。
  - `ImageTransparency = 1` 或接近 1。
  - 命名为 `Hitbox`。
- 脚本绑定这个透明按钮，视觉仍由外层图片负责。

#### **26. 正确应用约束**
- 不要给所有节点加 `UIAspectRatioConstraint`。
- 先把对象尺寸/位置全部 Scale 化。
- 找到真正需要保持整体比例的父容器，只给它加约束。
- 全屏 holder 不要锁比例；内部主 UI 容器可以锁。
- 完成后必须切换不同设备预览检查。

#### **27. ScrollingFrame 淡入淡出**
- 不推荐用 CanvasGroup 做滚动边缘淡出。
- 推荐做法：
  - 在 ScrollingFrame 上方放一个遮罩 Frame。
  - 尺寸略覆盖列表边缘，但不要盖住滚动条。
  - 给遮罩加 `UIGradient`。
  - 用 `Transparency` 做从不透明到透明的过渡。
  - `Rotation` 通常设为 `-90` 或 `90`，按方向调整。
  - 颜色用 Pick Screen Color 取背景色。
- 本质是用背景色渐变遮住滚动内容的硬切边。

#### **28. 导入条形进度条**
- 不要通过横向移动图片或直接缩放图片来做血条，容易变形。
- 正确结构：
  - 外层 `Base`。
  - 内层 `HP` / `Fill` 图片。
  - 图片 `ScaleType = Fit`。
  - 给 Fill 加 `UIGradient`。
  - 在 `Transparency` 中设置硬切点：一侧可见，一侧透明。
  - 用 `UIGradient.Offset` 控制进度减少/增加。
- 例如 Offset 从 `0` 往 `-0.1/-0.5/-0.9` 移动，条会逐渐变空。
- 这种方式适合导入的异形血条/能量条。

#### **29. Slice / 九宫格切片**
- 用于拉伸图片但保护边角不变形。
- 操作：
  - ImageLabel 的 `ScaleType` 改为 `Slice`。
  - 打开 `SliceCenter` 编辑器。
  - 拖动切片线，把需要保护的边缘/圆角留在外侧。
  - 关闭后测试横向/纵向缩放。
- 作用：中间区域被拉伸，左右/上下边缘保持质量。
- 适合加载条、圆角长条、可变宽面板、按钮背景。

#### **30. 圆形/环形进度条**
- 结构：
  - 外层正方形 `Container`，居中，Scale 化，加 `UIAspectRatioConstraint`。
  - `Bottom`：圆形 Frame，`UICorner = 1`，加 `UIStroke`，作为底环。
  - `Left` 和 `Right`：两个半圆容器，宽度略大于一半，建议 `0.501` 而不是 `0.5`，避免中缝。
  - 左右容器开启 `ClipsDescendants`。
  - 容器内部放圆形 Frame + `UIGradient`，通过 `Rotation` 控制显示部分。
  - `Top`：顶层圆环/描边，用来遮盖拼接痕迹。
  - 中间可放 TextLabel 显示百分比。
- ZIndex：
  - `Bottom = 0`
  - `Left/Right = 1`
  - `Top = 2`
  - 文本更高。
- 实际项目中旋转值应由脚本根据百分比计算，避免手调出现断裂。

#### **31. Kekui / KUI 插件**
- 插件分区：
  - `Transform`
  - `Quick Actions`
  - `Reclass`
  - `UI Gradients`
- `Transform`：
  - 把 `Size`、`Position`、`UIStroke.Thickness`、`UICorner.CornerRadius`、layout `Padding`、Grid `CellSize/CellPadding`、ScrollingFrame `CanvasSize` 从 Offset 转 Scale。
  - 也可从 Scale 转 Offset。
- 九宫格定位按钮：
  - 可同时改 `AnchorPoint` 和 `Position`。
  - 推荐一般 UI 用 `AnchorPoint = 0.5, 0.5`，方便脚本动画。
  - 可只改 Anchor，不动 Position；或只改 Position，不动 Anchor。
- `Quick Actions`：
  - Center：居中。
  - Fit to Parent Size：填满父级。
  - Remove Background：清背景。
  - Fixed Aspect Ratio：按当前形状添加 `UIAspectRatioConstraint`，不破坏现有比例。
- `Ultra Scale`：
  - 一键把选中父级下所有后代的 Offset 类属性转 Scale。
  - 包括位置、尺寸、Stroke、Corner、Padding、CanvasSize 等。
  - 完整导入 UI 时非常关键。
- `Reclass`：
  - 把 Frame 转成 ScrollingFrame、ImageButton、ImageLabel、TextButton、TextLabel、ViewportFrame、TextBox 等，同时尽量保留属性和子级。
  - 视频提醒：Reclass 后不要依赖 Ctrl+Z，想撤销就再 Reclass 回原类型。
- `UI Gradients`：
  - 内置常用渐变。
  - 父对象最好是白色，渐变颜色才准确。
  - 选择新渐变会替换旧渐变，不会堆一堆 UIGradient。

#### **32. 导出完整动漫 UI**
- 在设计软件里先整理分组。
- 图标、光效、卡片底图、复杂背景导出为图片。
- 文本不要导出，尽量在 Studio 用 TextLabel 重建。
- 需要变色的 glow/光效导成白色/灰度。
- 导出前按用途分离：背景、header、按钮、icon、glow、卡片、装饰条等。
- 视频使用小号上传图片，原因是担心主号图片/素材被 Roblox 审核误标。

#### **33. 导入完整动漫 UI 到 Studio**
- 新建 `ScreenGui`。
- 建主容器，如 `MainInventory`，居中、合适大小、Scale 化。
- 放一张半透明 overview/reference 图作为对齐参考：
  - ImageLabel 填设计稿截图。
  - `ZIndex` 临时设高，如 `50`。
  - `ImageTransparency` 在 `0`、`0.5`、隐藏之间切换。
- 主容器加 `UIAspectRatioConstraint`，不要给全屏 holder 加。
- 导入顺序建议：
  - 背景 holder / background，`ZIndex = -10`。
  - Header 图片，`ScaleType = Fit`，`ZIndex` 较高。
  - Header Text 用 TextLabel 重建，字体、描边、颜色对齐。
  - Close Button 用 ImageButton 或 ImageLabel + Hitbox。
  - Search Bar 用 Frame + UICorner + UIStroke + TextBox + Search Icon。
  - Filter/Lock 等按钮用 ImageButton，视觉贴图放子 ImageLabel，按钮自身透明。
  - Unit capacity 用 TextLabel + RichText 实现双色数字。
  - Units holder 用 Frame 重建，圆角/描边按参考图取色。
  - ScrollingFrame 放进 holder，设滚动条颜色、厚度、`AutomaticCanvasSize = Y`。
  - ScrollingFrame 内用 `UIGridLayout`，按原图一行数量设置 `CellSize`、`CellPadding`。
  - 先做好一个 `Unit` 卡片，再复制。
  - Unit 卡片内部：背景图、ViewportFrame、glow、稀有度/trait/lock/favorite 等图标。
  - 详情面板右侧统计条用 ListLayout 垂直排列，每条再由背景、描边、渐变、文字、icon 组成。
- 每做完一块就 `Ultra Scale`。
- 多次切换设备预览：1080p、VGA、手机。
- 发现错位时优先检查：
  - 是否忘记 Scale。
  - 是否忘记给主容器加 AspectRatioConstraint。
  - 是否某个按钮/统计块仍是 Offset。
  - `ZIndex` 是否压错。
  - `ScaleType` 是否仍是 Stretch。
  - `ClipsDescendants` 是否误开导致 glow/边缘被裁。

**最后验收清单**
- 所有 Position/Size/Stroke/Corner/Padding/CanvasSize 已 Scale 化。
- 图片 `ScaleType` 多数为 `Fit`，需要九宫格的为 `Slice`。
- 文本用 TextLabel/TextBox 重建，已 `TextScaled`。
- 可点击区域有真实 Button 或 Hitbox。
- 主容器比例锁定，外层全屏 holder 不锁死比例。
- 切到手机/VGA 后没有溢出、压缩、空边、滚动区域异常。
- 滚动条厚度若不一致，交给脚本或自定义滚动条处理。

参考：  
[原视频](https://www.youtube.com/watch?v=_6v86vc-9Xc&t=4151s)  
[Roblox in-experience UI containers](https://create.roblox.com/docs/ui/in-experience-containers)  
[Roblox on-screen UI containers](https://create.roblox.com/docs/ui/on-screen-containers)

### 实用技巧
下面只总结 **1:52:00 之后完整导入 UI 到 Roblox Studio 的实操技巧**，不重复基础概念。

#### **导入前**
1. 用小号上传 UI 图片素材，避免主号素材被 Roblox 审核误伤。
2. 用 `Asset Manager > Bulk Import` 批量导入所有导出的图片。
3. 复杂图形、光效、按钮底图、卡片背景导成图片；文字、输入框、统计数值尽量在 Studio 里重建，方便脚本和后期修改。
4. 需要变色的光效、glow、图标尽量导成白色/灰度，之后用 `ImageColor3` 上色。

#### **搭主结构**
1. 新建 `ScreenGui` 后：
   - 开启 `IgnoreGuiInset`
   - 关闭 `ResetOnSpawn`
2. 在 `ScreenGui` 下建全屏 `HolderFrame`：
   - 居中
   - `Fit to Parent Size`
   - 移除背景
3. 导入整张 UI 截图作为 `Overview` 参考图：
   - `ImageLabel`
   - 居中、填满父级、移除背景
   - 加 `UIAspectRatioConstraint`
   - 用 `ImageTransparency = 0.5~0.6` 辅助对齐
   - 可临时把 `ZIndex` 设很高方便看，也可设很低放在底下

#### **主容器技巧**
1. 先做一个 `ContainerFrame` 包住整套 UI，后续移动/缩放整套 UI 更方便。
2. UI 分左右两块时，分别建：
   - `MainInventory`
   - `InventoryDetails`
3. 所有主区域尽量：
   - `AnchorPoint = 0.5, 0.5`
   - 位置和尺寸转为 `Scale`
4. 主 UI 容器加 `UIAspectRatioConstraint`，不要给全屏 holder 加比例约束。

#### **对齐技巧**
1. 不要完全靠鼠标拖，容易因为分辨率和吸附导致误差。
2. 精细位置用属性面板里的 `Position` / `Size` 数值调。
3. 对齐时反复切换：
   - `Overview` 显示
   - `Overview` 半透明
   - `Overview` 隐藏
4. 对齐参考图时，先大块定位，再处理小图标、文字、按钮。

#### **图片控件技巧**
1. 导入的 UI 图片默认优先设：
   - `ScaleType = Fit`
   - `BackgroundTransparency = 1`
2. 背景图片一般放低层：
   - 背景 `ZIndex = -10`
   - 普通内容 `0~2`
   - 文字/图标更高
3. 光效一般比主体大一点，放到主体后面：
   - `Size` 可设 `1.1~1.3`
   - `ZIndex = -1`
   - 用 `ImageTransparency` 调强弱
   - 用 `ImageColor3` 改颜色

#### **按钮制作技巧**
1. 不建议直接把视觉图片做成 `ImageLabel` 就结束；可点击对象必须是 `ImageButton`。
2. 推荐结构：
   - 外层 `ImageButton`：负责点击和动画
   - 内层 `ImageLabel` 命名 `Texture`：负责显示按钮图案
3. 外层按钮本身设透明：
   - `BackgroundTransparency = 1`
   - `ImageTransparency = 1`
4. 好处：
   - 点击区域可单独控制
   - 图案大小可单独调
   - 动画时缩放按钮更方便
5. 如果按钮点击范围太大，就缩小外层 `ImageButton`，不要只缩小里面的贴图。

#### **搜索框技巧**
1. 搜索框底用 `Frame` 做，不必整张导图。
2. 用：
   - `UICorner` 做圆角
   - `UIStroke` 做边线
   - `TextBox` 做输入
   - `ImageLabel` 做搜索 icon
3. `TextBox`：
   - 移除背景
   - 开启 `TextScaled`
   - `TextXAlignment = Left`
   - `PlaceholderText = Search`
   - 字体用整套 UI 一致的字体
4. 做完后对搜索框整体执行 `Ultra Scale`，避免内部 icon/textbox 仍是 offset。

#### **列表按钮技巧**
1. 多个并排小按钮用 `UIListLayout`，不要手动一个个摆。
2. 设置：
   - `FillDirection = Horizontal`
   - `HorizontalAlignment = Left` 或 `Center`
   - `VerticalAlignment = Center`
3. 每个按钮内部仍用：
   - 外层 `ImageButton`
   - 内层 `Texture`
   - 可选 `Glow`
4. 顺序用 `LayoutOrder` 控制，不靠拖动层级。

#### **容量文字技巧**
1. 类似 `49/100` 这种双色文字，用 `RichText`。
2. 示例思路：
   - TextLabel 开启 `RichText`
   - 数字或后半段用 `<font color="#xxxxxx">...</font>`
3. 取色时可先显示 `Overview`，用 Studio 的 `Pick Screen Color` 取原图颜色。

#### **单位网格技巧**
1. 背包/单位列表用：
   - `ScrollingFrame`
   - `UIGridLayout`
2. `ScrollingFrame`：
   - 移除背景
   - 调整 `ScrollBarImageColor3`
   - 调整 `ScrollBarThickness`
   - `AutomaticCanvasSize = Y`
3. `UIGridLayout`：
   - 用 `CellSize` 控制格子大小
   - 用 `CellPadding` 控制间距
   - 一行几个格子一定要对照原图确认，视频里一开始看成 5 个，后来修正为 6 个
4. 先只做好一个 `Unit` 卡片，再复制，不要一开始装饰全部格子。

#### **卡片制作技巧**
1. 单位卡片结构建议：
   - `Unit`
   - `CardBG`
   - `ViewportFrame`
   - `CardGlow`
   - trait/icon/lock/favorite 等小元素
2. 角色展示用 `ViewportFrame`，不要用静态 PNG，因为游戏里通常要显示真实模型。
3. `ViewportFrame` 可略大于卡片显示区域，例如 `0.78~0.8`，避免角色显得太小。
4. `CardGlow` 超出格子时会被 `ScrollingFrame` 裁掉。
5. 正确修复方式：
   - 不要乱加 padding
   - 把卡片内容整体缩小，让 glow 也包含在 `Unit` 格子范围内
   - 必要时给卡片内部容器开 `ClipsDescendants`
6. 如果 glow 太强，用 `ImageTransparency` 调，不要只缩尺寸。

#### **Grid 缩放坑**
1. `UIGridLayout.CellSize` 一开始可能是 Offset。
2. 后期发现跨设备不对时，把 `CellSize` 转成 Scale。
3. 转 Scale 后视觉大小可能变化，需要重新调 `CellSize` 数值。
4. 插件会给 Grid 加一个 `UIAspectRatioConstraint` 来保持格子正方形，所以不用给每个按钮单独加比例约束。

#### **底部三个主按钮**
1. 可复用前面做好的按钮组，再修改位置、大小和图片。
2. 三个按钮用 `UIListLayout` 横排。
3. 颜色顺序靠 `LayoutOrder` 控制，例如：
   - Green = 0
   - Pink = 1
   - Yellow = 2
4. 按钮文字用 TextLabel 重建：
   - `TextScaled`
   - 白色文字
   - 加 `UIStroke`
   - 字体和 UI 保持一致
5. 做完每个按钮后执行 `Ultra Scale`。

#### **右侧详情面板技巧**
1. 右侧也分上下容器：
   - 顶部信息容器
   - 底部操作/展示容器
2. 可以复制已有容器结构，再替换 texture 图片。
3. 顶部和底部容器都应单独检查比例，必要时加 `UIAspectRatioConstraint`。
4. 小 trait 图标用 `UIListLayout` 横排。
5. 如果图标顺序反了，用 `LayoutOrder` 调，不要手动乱拖。
6. trait 图标不居中时，进入每个图标内部，把子 ImageLabel 居中、fit parent。

#### **详情页 ViewportFrame 技巧**
1. 如果 ViewportFrame 放在详情容器内部会被阴影或层级盖住，可以调整父级位置。
2. 视频中把 ViewportFrame 放到 `BottomRight` 里，而不是原本的详情子容器里。
3. 用 `ZIndex` 插到正确层级：
   - Texture 之上
   - Shadow 之上或之下按效果调整
   - 例如 texture `0`，shadow `-10`，viewport `-5`
4. ViewportFrame 背景可设深灰，避免模型边缘白边。

#### **统计条技巧**
1. 右侧伤害、SPA、Range 等统计项用 `UIListLayout` 垂直排列。
2. 先做一个统计条，再复制三份。
3. 单个统计条结构：
   - 外层 Frame
   - 背景 Texture
   - 深色遮罩 Dark
   - `UIStroke`
   - `UIGradient`
   - 数值 TextLabel
   - Tier TextLabel
   - Icon ImageLabel
   - Trail 高光
4. 渐变角度要反复对照原图，视频里先试 `135`，后改为 `45`。
5. 左侧白色 trail 可用一个 Frame + `UIGradient`：
   - `Rotation = 180`
   - 一侧透明，一侧微亮
   - `BackgroundTransparency` 调到 `0.6~0.7`
6. 复制统计条后：
   - 改名字
   - 改 icon
   - 改 gradient 颜色
   - 改 `LayoutOrder`

#### **常用修复技巧**
1. 看不见对象：先查 `ZIndex`，再查父级是否 `Visible`，再查是否被 `ClipsDescendants` 裁掉。
2. 点击范围不对：检查外层 `ImageButton` 的尺寸，不是里面 texture 的尺寸。
3. 图片变形：检查 `ScaleType` 是否是 `Fit`。
4. 手机/VGA 错位：检查是否还有 Offset，执行 `Ultra Scale`。
5. 圆角/描边比例异常：检查 `UICorner`、`UIStroke` 是否 Scale 化。
6. 列表间距不对：检查 `UIGridLayout.CellPadding` 和 `CellSize`。
7. 光效被裁：让 glow 包含在格子本身范围内，而不是超出 ScrollingFrame 可裁切区域。
8. 文本不一致：检查字体、字重、TextScaled、UIStroke、TextTransparency。
9. 参考图挡住操作：临时改 Overview 的 `ZIndex` 或透明度。

#### **最终检查**
1. 切换到 VGA 预览。
2. 再切到手机预览。
3. 检查：
   - Close button 是否过大
   - 统计条是否缩放正常
   - ScrollingFrame 是否正常
   - 卡片是否仍是正方形
   - 文本是否溢出
   - 光效是否被裁
4. 视频最后发现：
   - Close button 忘记 scale
   - Statistics 忘记 scale
   修完后 UI 在不同设备上正常。
5. 滚动条厚度在不同设备可能不一致，这是 Studio 属性限制；更稳的做法是用脚本缩放滚动条厚度，或自定义滚动条。

核心一句话：  
这段实操的关键不是“把图片摆上去”，而是用参考图逐层重建 UI，并且不断保证 **Scale 化、中心锚点、正确 ZIndex、Fit 图片、布局组件管理、跨设备检查**。