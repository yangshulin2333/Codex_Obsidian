---@class RemoteFunction:Instance @RemoteFunction（远程函数）用于创建客户端和服务器用来彼此通信的游戏内 API。与 BindableFunction 相似，开发者可以通过调用 RemoteFunction 执行特定操作，并返回其结果。
---@field OnClientInvoke function @当客户端被 RemoteFunction:InvokeClient 调用时将对其进行调用。
---@field OnServerInvoke function @当服务器被 RemoteFunction:InvokeServer 调用时将对其进行调用。
local module = {}
---@type fun(player:Player,var_arg:any):any @通过 RemoteFunction.OnClientInvoke 为指定 Player 调用绑定至 RemoteFunction 的方法。请将其放入 Script 使用
---@param player Player @远程函数触发所影响的 Player
---@param var_arg any @传入 RemoteEvent/OnClientInvoke 方法的参数
---@return any @由 RemoteFunction.OnClientInvoke 返回的值
function module:InvokeClient(player,var_arg)
end
---@type fun(var_arg:any):any @通过 RemoteFunction.OnServerInvoke 调用绑定至 RemoteFunction 的方法。请将其放入 LocalScript 使用。将返回 RemoteFunction.OnServerInvoke 的返回内容。
---@param var_arg any @传入 RemoteEvent/OnServerInvoke 方法的参数
---@return any @由 RemoteFunction.OnServerInvoke 返回的值。
function module:InvokeServer(var_arg)
end