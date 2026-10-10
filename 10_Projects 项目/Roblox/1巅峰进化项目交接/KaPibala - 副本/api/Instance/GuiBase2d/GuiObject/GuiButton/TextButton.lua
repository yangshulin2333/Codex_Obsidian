---@class TextButton:GuiButton @一个 TextButton ，它在渲染 GuiButton 的附加行为时和 TextLabel 的行为模式很相似。它和 TextLabel 都定义了相同的文本渲染属性。
---@field Font Font @决定渲染文本的字体。
---@field LineHeight number @缩放 TextButton 中文本行之间的间距
---@field LocalizedText string @设置 TextButton 是否应为 GuiBase2d.Localize（本地化）。
---@field Text string @决定由 UI 元素渲染的字符串。
---@field TextBounds Vector2 @UI 元素文本的像素大小。
---@field TextColor3 Color3 @决定被渲染文本的颜色
---@field TextFits boolean @一个布尔值，代表着 TextButton 的文本是否能放入其中。
---@field TextScaled boolean @更改文本是否需要调整大小以便放进 TextButton 中。
---@field TextSize  number @决定文本行的高度，以像素为单位。
---@field TextStrokeColor3 Color3 @确定文本描边（轮廓）的颜色。
---@field TextStrokeTransparency number @确定文本描边（轮廓）的透明度
---@field TextTransparency number @决定被渲染文本的透明度。
---@field TextTruncate TextTruncate @控制此 TextButton 中显示文本的截断。
---@field TextWrapped boolean @确定文本在 GUI 元素空间内是否换行，截断多余的文本
---@field TextXAlignment TextXAlignment @确定渲染文本的水平对齐方式。
---@field TextYAlignment TextYAlignment @决定渲染文本的垂直对齐方式。
local module = {}
---@type fun(text:string) @将 TextButton 的 TextButton.Text 设置为 text（文本），并使用 TextInput 的 UserInputType 触发 TextButton 的 GuiObject.InputChanged 事件。
---@param text string @
function module:SetTextFromInput(text)
end