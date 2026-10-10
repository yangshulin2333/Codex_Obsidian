---@class PluginMenu:Instance
---@field Icon string @被当做子菜单使用时才会显示出来的图标
---@field Title string @被当做一个子菜单使用时会被显示的文本
local c = {}
---@type fun(action:PluginAction) @添加指定操作到菜单
function c:AddAction(action) end
---@type fun(menu:PluginMenu) @将指定的菜单作为分隔符添加
function c:AddMenu(menu) end
---@type fun(action_id:string,text:string,icon:string):PluginAction @创建一个临时动作，该动作不会在 Studio 的自定义快捷窗口中显示
function c:AddNewAction(action_id,text,icon) end
---@type fun() @在菜单中的各个项目之间添加分隔符
function c:AddSeparator() end
---@type fun():PluginAction @在鼠标光标处显示菜单，只有当一个物品被选中或者菜单被关闭时才会暂停
function c:ShowAsync() end