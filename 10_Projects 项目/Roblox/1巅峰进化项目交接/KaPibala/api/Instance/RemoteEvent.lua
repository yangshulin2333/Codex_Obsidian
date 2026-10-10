---@class RemoteEvent:Instance @RemoteEvent（远程事件）的作用是在客户端和服务器端之间提供一个单向讯息传播途径，它允许 Script（脚本）和 LocalScript（本地脚本）之间互相调用其内部的代码。讯息可以由客户端传向服务器端，也可以由服务器端传向特定的客户端，还可以由服务器端传给所有客户端。
---@field OnClientEvent RBXScriptSignal @当从脚本中调用RemoteEvent：FireClient或RemoteEvent：FireAllClients时，触发LocalScript中的侦听功能
---@field OnServerEvent RBXScriptSignal @从LocalScript调用RemoteEvent：FireServer时触发脚本中的侦听功能
local module = {}
---@type fun(param:any) @在每个客户端触发 RemoteEvent.OnClientEvent 事件。
---@param vararg any @参数集
function module:FireAllClients()
end
---@type fun(param:Player,param:any)
---@param player Player
---@param vararg any
function module:FireClient()
end
---@type fun(param:any)
---@param vararg any
function module:FireServer()
end