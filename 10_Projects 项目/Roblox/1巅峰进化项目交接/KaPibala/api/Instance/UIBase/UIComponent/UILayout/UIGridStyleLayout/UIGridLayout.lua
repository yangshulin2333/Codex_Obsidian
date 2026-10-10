---@class UIGridLayout:UIGridStyleLayout @设置一个 2D 网格 (可以改为 1D 网格以进行列表布局) 中 UI 元素的位置。同时还会将元素设置为特定大小，但可以通过对元素进行特定约束来覆盖此设置。可以通过将 UIGridLayout 设为 GuiObject 的父类来使用它。随后 UIGridLayout 会将其自身应用于所有 GuiObject 的同级类。
---@field CellPadding UDim2
---@field CellSize UDim2
---@field AbsoluteCellCount Vector2
---@field AbsoluteCellSize Vector2
---@field AbsoluteContentSize Vector2
local module = {}