---@class UIGridStyleLayout:UILayout @网格风格 UI 布局的基类。
---@field AbsoluteContentSize Vector2 @栅格布局所占据空间的绝对大小。
---@field FillDirection FillDirection @决定 UI 元素被布置的轴。
---@field HorizontalAlignment HorizontalAlignment @决定父元素中 UI 元素的水平对齐方式。
---@field SortOrder SortOrder @确定布局时选择下一个 UI 元素的方式。
---@field VerticalAlignment VerticalAlignment @确定父元素中 UI 元素的垂直对齐方式。
local module = {}