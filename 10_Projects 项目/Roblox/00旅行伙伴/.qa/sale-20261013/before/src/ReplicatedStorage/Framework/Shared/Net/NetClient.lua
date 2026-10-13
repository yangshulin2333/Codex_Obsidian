--!strict

-- 客户端网络入口：查找服务器创建的 Remote，发送请求/事件，并监听服务器通知。
-- 不创建 Remote、不决定业务权限；公开函数使用点号，例如 NetClient.Request(name, payload)。
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NetResult = require(script.Parent.NetResult)
local RemoteGuards = require(script.Parent.RemoteGuards)
local RemoteNames = require(script.Parent.RemoteNames)
local RequestWait = require(script.Parent.RequestWait)

local NetClient = {}

-- 仅限制等待目录或 Remote 出现的时间，不是 InvokeServer 的响应超时。
local WAIT_TIMEOUT_SECONDS = 10

-- 首次成功查找后缓存目录引用；当前实现不处理运行中删除并重建整棵 Remote 目录。
local rootFolder = nil
local requestFolder = nil
local clientEventFolder = nil
local serverEventFolder = nil

-- 最多等待直接子对象出现；缺失或类型不为 Folder 时抛异常，而非返回 NetResult。
local function waitForFolder(parent, folderName)
	local child = parent:WaitForChild(folderName, WAIT_TIMEOUT_SECONDS)
	if child == nil or not child:IsA("Folder") then
		error("Missing remote folder: " .. folderName, 3)
	end
	return child
end

-- 返回 ReplicatedStorage/YanzoFrame_V2_Remotes 根目录；需要服务器先完成 NetService:Init。
function NetClient.GetRemoteFolder()
	if rootFolder == nil then
		rootFolder = waitForFolder(ReplicatedStorage, RemoteNames.RootFolder)
	end
	return rootFolder
end

-- 返回 ClientToServer/Requests，存放客户端请求服务器并等待结果的 RemoteFunction。
function NetClient.GetRequestFolder()
	if requestFolder == nil then
		local clientToServerFolder = waitForFolder(NetClient.GetRemoteFolder(), RemoteNames.ClientToServerFolder)
		requestFolder = waitForFolder(clientToServerFolder, RemoteNames.RequestFolder)
	end
	return requestFolder
end

-- 返回 ClientToServer/Events；这里的 Client 指事件发送方。
function NetClient.GetClientEventFolder()
	if clientEventFolder == nil then
		local clientToServerFolder = waitForFolder(NetClient.GetRemoteFolder(), RemoteNames.ClientToServerFolder)
		clientEventFolder = waitForFolder(clientToServerFolder, RemoteNames.EventFolder)
	end
	return clientEventFolder
end

-- 返回 ServerToClient/Events，客户端从此目录订阅服务器通知。
function NetClient.GetServerEventFolder()
	if serverEventFolder == nil then
		local serverToClientFolder = waitForFolder(NetClient.GetRemoteFolder(), RemoteNames.ServerToClientFolder)
		serverEventFolder = waitForFolder(serverToClientFolder, RemoteNames.EventFolder)
	end
	return serverEventFolder
end

-- 发送 payload 并等待服务器结果；正常路径返回 NetResult，业务失败检查 result.Ok。
-- 可选期限仅限制实际调用；超时结果未确认，不撤销服务器、不自动重试或修改 UI。
-- Remote 缺失返回 REMOTE_NOT_FOUND，调用异常返回 INVOKE_FAILED；接入参数/目录错误仍抛出。
function NetClient.Request(remoteName, payload, responseTimeoutSeconds)
	-- 这里只校验名称格式；payload 的业务结构必须由服务器检查。
	RemoteGuards.AssertRemoteName(remoteName, "remoteName")
	RemoteGuards.AssertResponseTimeout(responseTimeoutSeconds)

	-- 等待 Requests 中对应的 RemoteFunction；类型错误与缺失使用相同失败结果。
	local remote = NetClient.GetRequestFolder():WaitForChild(remoteName, WAIT_TIMEOUT_SECONDS)
	if remote == nil or not remote:IsA("RemoteFunction") then
		return NetResult.Err("REMOTE_NOT_FOUND", "Remote request is not available", {
			RemoteName = remoteName,
		})
	end

	local completed, ok, result = RequestWait.Run(function()
		-- InvokeServer 会让当前协程等待；服务器 OnServerInvoke 自动收到发起请求的 Player。
		return remote:InvokeServer(payload)
	end, responseTimeoutSeconds)

	if not completed then
		return NetResult.Err("REQUEST_TIMEOUT", "Request result is not confirmed", {
			RemoteName = remoteName,
			ResponseTimeoutSeconds = responseTimeoutSeconds,
		})
	end

	if not ok then
		return NetResult.Err("INVOKE_FAILED", "Remote request failed", {
			RemoteName = remoteName,
		})
	end

	-- 已是 NetResult 时原样返回，保留服务器的业务错误；普通返回值才包装为成功。
	if NetResult.IsResult(result) then
		return result
	end

	return NetResult.Ok(result)
end

-- 单向发送事件，不等待业务结果；名称、目录或 Remote 不合法时抛异常。
function NetClient.FireServer(remoteName, payload)
	-- 服务器需要先通过 RegisterClientEvent 注册接收函数。
	RemoteGuards.AssertRemoteName(remoteName, "remoteName")

	-- 查找 ClientToServer/Events 下的 RemoteEvent，不与 Requests 混用。
	local remote = NetClient.GetClientEventFolder():WaitForChild(remoteName, WAIT_TIMEOUT_SECONDS)
	if remote == nil or not remote:IsA("RemoteEvent") then
		error("Remote event is not available: " .. remoteName, 2)
	end

	remote:FireServer(payload)
end

-- 注册 callback(payload) 并返回 RBXScriptConnection（事件连接）；不会立刻调用回调。
-- GUI 或 Controller 不再需要监听时，调用返回连接的 Disconnect()，避免重复订阅。
function NetClient.OnServerEvent(remoteName, callback)
	RemoteGuards.AssertRemoteName(remoteName, "remoteName")
	if type(callback) ~= "function" then
		error("callback must be a function", 2)
	end

	-- 此函数名 OnServerEvent 指“监听服务器事件”；底层客户端实际监听 OnClientEvent。
	local remote = NetClient.GetServerEventFolder():WaitForChild(remoteName, WAIT_TIMEOUT_SECONDS)
	if remote == nil or not remote:IsA("RemoteEvent") then
		error("Remote event is not available: " .. remoteName, 2)
	end

	-- 服务器 FireClient/FireAllClients 后触发；这里没有额外用 pcall 包住 callback。
	return remote.OnClientEvent:Connect(callback)
end

return NetClient
