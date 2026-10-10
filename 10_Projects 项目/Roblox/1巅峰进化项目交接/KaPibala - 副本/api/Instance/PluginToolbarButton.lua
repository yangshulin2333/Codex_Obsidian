---@class PluginToolbarButton:Instance @PluginToolbarButton 是由 PluginToolbar:CreateButton 函数创建的一个对象，它允许玩家在 Roblox Studio 中使用 Click 事件初始化一个单独的一次性动作。下面的图片是 3 个 PluginToolbarButtons，从左到右分别是：默认状态、悬停状态以及按下状态。中间的悬停按钮显示的工具提示文本是传给 PluginToolbar:CreateButton 的第二个参数。
---@field ClickableWhenViewportHidden boolean
---@field Enabled boolean @确定按钮总体来说能否被点击
---@field Icon string 
---@field Click RBXScriptSignal
local c = {}
---@type fun(active:boolean)
function c:SetActive(active) end