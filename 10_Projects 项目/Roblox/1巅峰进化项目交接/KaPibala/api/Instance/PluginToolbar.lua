---@class PluginToolbar:Instance @PluginToolbar 是一种通过使用 Plugin:CreateToolbar 方法创建的对象，用于使用 CreateButton 函数来创建 PluginToolbarButton。大体来说，如果某一插件需要对其所有按钮使用一个且是唯一一个名称唯一的工具栏，这会是十分理想的做法。在 Roblox Studio 中，工具栏会在“Plugins（插件）”选项卡中渲染。
local c = {}
---@type fun(button_id:string,tool_tip:string,icon_name:string,text:string):PluginToolbarButton @创建 PluginToolbarButton ，它允许用户通过 Click 事件在 Roblox Studio 里初始化一个单一的一次性动作
---@param buuton_id string
---@param tool_tip string
---@param icon_name string
---@param text string
---@return PluginToolbarButton
function c:CreateButton(buuton_id,tool_tip,icon_name,text) end
