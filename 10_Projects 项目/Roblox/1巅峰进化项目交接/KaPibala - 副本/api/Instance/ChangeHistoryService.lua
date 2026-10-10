---@class ChangeHistoryService:Instance @ChangeHistoryService 为插件提供了一种撤消和重做更改，以及在对场景进行更改时创建途经点的方法。
---@field OnRedo  RBXScriptSignal @在用户撤消掉撤消命令时触发。Waypoint 描述已经重做的输入操作。
---@field OnUndo RBXScriptSignal @用户在 studio 中撤消掉一个操作时触发。Waypoint 描述已经撤消的输入操作。
local module = {}
---@type fun():Tuple @返回是否有可以重做的操作，如果有，则返回最后一个操作。
---@return Tuple
function module:GetCanRedo()
end
---@type fun():Tuple @返回是否有可以撤消的操作，如果有，则返回最后一个操作。
---@return Tuple
function module:GetCanUndo()
end
---@type fun() @执行上次撤消的操作。
function module:Redo()
end
---@type fun() @清除历史记录，导致删除所有撤消/重做路径点。
function module:ResetWaypoints()
end
---@type fun(state:boolean) @设置是否启用 ChangeHistoryService 。
---@param state boolean
function module:SetEnabled(state)
end
---@type fun(name:string) @设置一个新路径点，可用作撤消或重做的节点。
---@param name string
function module:SetWaypoint(name)
end
---@type fun() @撤消上一次执行的、且存有路径点的操作。
function module:Undo()
end