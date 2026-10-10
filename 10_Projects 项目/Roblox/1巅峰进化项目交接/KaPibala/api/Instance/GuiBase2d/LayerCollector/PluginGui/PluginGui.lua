---@class PluginGui:LayerCollector
---@field Title String @显示在 PluginGui 内容上方的标题
---@field PluginDragDropped RBXScriptSignal @鼠标在由 Plugin:StartDrag 开始的拖动操作过程中悬停于某一 PluginGui 上方时，用户松开鼠标时触发
---@field PluginDragEntered RBXScriptSignal @用户的鼠标在由 Plugin:StartDrag 开始的拖动操作过程中进入到某一 PluginGui 内时触发
---@field PluginDragLeft RBXScriptSignal @用户的鼠标在由 Plugin:StartDrag 开始的拖动操作过程中离开某一 PluginGui 时触发
---@field PluginDragMoved RBXScriptSignal @用户的鼠标在由 Plugin:StartDrag 开始的拖动操作过程中移动到某一 PluginGui 内时触发
local c = {}
---@type fun(func:function) @绑定函数到 PluginGui 的关闭按钮，覆盖默认行为
function c:BindToClose(func) end
---@type fun():Vector2 @返回鼠标相对于 PluginGui 的位置
function c:GetRelativeMousePosition() end