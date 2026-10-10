---@class RBXScriptConnection @RBXScriptConnection，也称为连接，是由事件（RBXScriptSignal）的Connect方法返回的特殊对象。这主要用于断开侦听器与事件的连接
---@field Connected boolean @描述连接是否仍然有效。 如果调用connection：Disconnect（），它将变为false
local module = {}
---@type fun() @从事件断开连接
function module:Disconnect()
end