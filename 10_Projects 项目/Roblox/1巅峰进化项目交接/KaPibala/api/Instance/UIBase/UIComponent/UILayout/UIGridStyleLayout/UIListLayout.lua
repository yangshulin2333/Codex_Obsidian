---@class UIListLayout:UIGridStyleLayout @一个 UIListLayout 将自己的子项 UI 元素在父项 UI 元素里的一个单独的行中排列展示出来，要么用水平方式排列、要么用垂直方式排列。每一个子项 UI 元素都保留着其原始的 GuiObject.Size，但其 GuiObject.Position 将会被 UIListLayout 所控制，由于这种控制的存在，每一个子项 UI 元素的 Position 属性都将无法在属性窗口中进行编辑。
---@field Padding UDim @确定每个元素之间的可用空间量。
local module = {}