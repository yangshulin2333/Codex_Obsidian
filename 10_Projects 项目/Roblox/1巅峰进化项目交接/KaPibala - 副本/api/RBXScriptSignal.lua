---@class RBXScriptSignal @RBXScriptSignal，通常称为事件，是一种特殊的Roblox对象。它提供了一种在游戏中发生某些情况时调用用户定义函数（称为侦听器）的方法。当某个事件发生时，将触发该事件，并调用连接到该事件的所有侦听器。事件还可以将参数传递给每个侦听器，以提供有关发生的事件的更多信息
local module = {}
---@type fun(param:function):RBXScriptConnection @建立一个在引发事件时要调用的函数。 返回与连接关联的RBXScriptConnection对象。
---@param handler function @处理函数
---@return RBXScriptConnection
function module:Connect()
end
---@type fun() @产生当前线程，直到触发该信号。返回触发信号的内容。
function module:Wait()
end
function module:Disconnect()
end