--!strict

-- 服务器网络边界：创建 Remote 目录、注册处理函数、包装请求结果，并执行按玩家/请求名的冷却。
-- 不判断具体玩法是否合法；handler 必须校验客户端 payload 与玩家权限，不能直接信任客户端。
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local NetResult = require(ReplicatedStorage.Framework.Shared.Net.NetResult)
local RemoteGuards = require(ReplicatedStorage.Framework.Shared.Net.RemoteGuards)
local RemoteNames = require(ReplicatedStorage.Framework.Shared.Net.RemoteNames)
local RemoteRateLimiter = require(script.Parent.Parent.Net.RemoteRateLimiter)

local NetService = {
	Name = "NetService",
}

-- 以下是服务表字段，不是全局变量；下划线表示内部使用约定，并不构成语言层面的私有保护。
-- 目录字段缓存 Instance 引用；两个 handler 表按名称记录注册情况，用于拒绝重复注册。
NetService._logger = nil
NetService._rootFolder = nil
NetService._requestFolder = nil
NetService._clientEventFolder = nil
NetService._serverEventFolder = nil
NetService._requestHandlers = {}
NetService._eventHandlers = {}
NetService._requestRateLimiter = nil
NetService._playerRemovingConnection = nil

-- 返回或创建直接子 Folder；同名对象类型不符时抛异常，不删除或覆盖现有对象。
local function getOrCreateFolder(parent, folderName)
	local existing = parent:FindFirstChild(folderName)
	if existing ~= nil then
		if not existing:IsA("Folder") then
			error("预期文件夹位于" .. existing:GetFullName(), 3)
		end
		return existing
	end

	local folder = Instance.new("Folder")
	folder.Name = folderName
	folder.Parent = parent
	return folder
end

-- 返回或创建用于“请求 -> 响应”的 RemoteFunction；只创建对象，暂不绑定回调。
local function getOrCreateRemoteFunction(parent, remoteName)
	local existing = parent:FindFirstChild(remoteName)
	if existing ~= nil then
		if not existing:IsA("RemoteFunction") then
			error("预期 RemoteFunction 位于" .. existing:GetFullName(), 3)
		end
		return existing
	end

	local remote = Instance.new("RemoteFunction")
	remote.Name = remoteName
	remote.Parent = parent
	return remote
end

-- 返回或创建单向通知使用的 RemoteEvent；同名但类型不符时抛异常。
local function getOrCreateRemoteEvent(parent, remoteName)
	local existing = parent:FindFirstChild(remoteName)
	if existing ~= nil then
		if not existing:IsA("RemoteEvent") then
			error("Expected RemoteEvent at " .. existing:GetFullName(), 3)
		end
		return existing
	end

	local remote = Instance.new("RemoteEvent")
	remote.Name = remoteName
	remote.Parent = parent
	return remote
end

-- 由 ServiceRegistry 注入 context.Logger，建立目录和请求冷却器；不在这里注册业务请求。
function NetService:Init(context)
	self._logger = context.Logger
	self._requestHandlers = {}
	self._eventHandlers = {}
	self._requestRateLimiter = RemoteRateLimiter.new()

	-- 玩家离开时删除冷却记录，避免一直持有 Player 引用；这里只替换离开事件的旧连接。
	if self._playerRemovingConnection ~= nil then
		self._playerRemovingConnection:Disconnect()
	end
	self._playerRemovingConnection = Players.PlayerRemoving:Connect(function(player)
		self._requestRateLimiter:ClearPlayer(player)
	end)

	local root = getOrCreateFolder(ReplicatedStorage, RemoteNames.RootFolder)
	local clientToServer = getOrCreateFolder(root, RemoteNames.ClientToServerFolder)
	local serverToClient = getOrCreateFolder(root, RemoteNames.ServerToClientFolder)

	-- 按发送方向分目录；同名事件在两个方向中也不会混用。
	self._rootFolder = root
	self._requestFolder = getOrCreateFolder(clientToServer, RemoteNames.RequestFolder)
	self._clientEventFolder = getOrCreateFolder(clientToServer, RemoteNames.EventFolder)
	self._serverEventFolder = getOrCreateFolder(serverToClient, RemoteNames.EventFolder)
	--[[
	NetService:Init(context) 完成后，Roblox 里应该有：
		ReplicatedStorage
		  YanzoFrame_V2_Remotes
		    ClientToServer
		      Requests
		      Events
		    ServerToClient
		      Events
	]]
end

-- 由注册器调用一次，登记框架连通性检查；Ping 只返回玩家 ID 和服务器时间，不修改数据。
function NetService:Start()
	self:RegisterRequest(RemoteNames.FrameworkPing, function(player, _payload)
		return {
			PlayerUserId = player.UserId,
			ServerTime = os.time(),
		}
	end, 1)

	self._logger.Info(self.Name, "Remote boundary ready")
end

-- 返回根目录 Instance；以下目录 getter 均要求 Init 已完成，否则抛异常。
function NetService:GetRemoteFolder()
	if self._rootFolder == nil then
		error("NetService is not initialized", 2)
	end
	return self._rootFolder
end

-- 返回 ClientToServer/Requests，客户端使用 InvokeServer 请求此处的 RemoteFunction。
function NetService:GetRequestFolder()
	if self._requestFolder == nil then
		error("NetService is not initialized", 2)
	end
	return self._requestFolder
end

-- 返回 ClientToServer/Events，服务器使用 OnServerEvent 接收客户端通知。
function NetService:GetClientEventFolder()
	if self._clientEventFolder == nil then
		error("NetService is not initialized", 2)
	end
	return self._clientEventFolder
end

-- 返回 ServerToClient/Events，服务器通过 FireClient/FireAllClients 推送消息。
function NetService:GetServerEventFolder()
	if self._serverEventFolder == nil then
		error("NetService is not initialized", 2)
	end
	return self._serverEventFolder
end

-- 提前创建并返回服务器推送事件，让客户端可以订阅；不会发送消息或绑定业务回调。
function NetService:EnsureServerEvent(remoteName)
	RemoteGuards.AssertRemoteName(remoteName, "remoteName")
	return getOrCreateRemoteEvent(self:GetServerEventFolder(), remoteName)
end

-- 注册 handler(player, payload)，返回 RemoteFunction；重复注册或参数不合法时抛异常。
-- cooldownSeconds 必须是大于 0 的有限秒数，没有默认值；同一玩家同一请求共用一份冷却。
-- 调用链：客户端 InvokeServer -> OnServerInvoke -> _handleRequest -> handler -> NetResult。
function NetService:RegisterRequest(remoteName, handler, cooldownSeconds)
	RemoteGuards.AssertRemoteName(remoteName, "remoteName")

	if type(handler) ~= "function" then
		error("handler必须是一个函数", 2)
	end

	-- 一个名称只能有一个请求处理函数，防止后注册的服务悄悄覆盖前面的行为。
	if self._requestHandlers[remoteName] ~= nil then
		error("请求已注册: " .. remoteName, 2)
	end
	self._requestRateLimiter:SetCooldown(remoteName, cooldownSeconds)

	-- 先保存 handler 用于重名检查，再把闭包绑定到这个 RemoteFunction。
	local remote = getOrCreateRemoteFunction(self:GetRequestFolder(), remoteName)
	self._requestHandlers[remoteName] = handler

	-- OnServerInvoke 是回调属性，不是用 Connect 订阅的事件；player 由 Roblox 自动提供。
	remote.OnServerInvoke = function(player, payload)
		-- 闭包保留本次注册的 self、remoteName、handler，注册函数返回后仍可使用。
		return self:_handleRequest(remoteName, handler, player, payload)
	end

	-- 注册只建立接收入口；直到客户端发来请求，handler 才会执行。
	self._logger.Debug(self.Name, "注册请求: " .. remoteName)
	return remote
end

-- 注册客户端单向事件 handler(player, payload)，返回 RemoteEvent；handler 的返回值不会传回客户端。
-- 此入口没有套用请求冷却器，业务方仍需自行做输入校验和必要的频率控制。
function NetService:RegisterClientEvent(remoteName, handler)
	RemoteGuards.AssertRemoteName(remoteName, "remoteName")

	if type(handler) ~= "function" then
		error("handler must be a function", 2)
	end

	if self._eventHandlers[remoteName] ~= nil then
		error("Client event already registered: " .. remoteName, 2)
	end

	-- 使用 ClientToServer/Events，与同方向的请求目录分开。
	local remote = getOrCreateRemoteEvent(self:GetClientEventFolder(), remoteName)
	self._eventHandlers[remoteName] = handler

	-- OnServerEvent 是信号，用 Connect 绑定；本接口返回 Remote，而非连接对象。
	remote.OnServerEvent:Connect(function(player, payload)
		-- pcall 捕获本次 handler 的异常并记录警告，不会回滚它已执行的业务修改。
		local ok, err = pcall(handler, player, payload)
		if not ok then
			self._logger.Warn(self.Name, "Client event failed: " .. remoteName .. " / " .. tostring(err))
		end
	end)

	self._logger.Debug(self.Name, "Registered client event: " .. remoteName)
	return remote
end

-- 向指定 Player 发送 payload，不等待客户端响应；玩家类型不合法时抛异常。
function NetService:FireClient(remoteName, player, payload)
	RemoteGuards.AssertRemoteName(remoteName, "remoteName")

	if typeof(player) ~= "Instance" or not player:IsA("Player") then
		error("player must be a Player", 2)
	end
	-- 事件可按需创建；若客户端应提前订阅，先在启动阶段调用 EnsureServerEvent。
	local remote = getOrCreateRemoteEvent(self:GetServerEventFolder(), remoteName)
	remote:FireClient(player, payload)
end

-- 向当前全部客户端广播 payload，不返回确认结果；本服务不维护历史消息重放，不能代替初始数据加载。
function NetService:FireAllClients(remoteName, payload)
	RemoteGuards.AssertRemoteName(remoteName, "remoteName")

	local remote = getOrCreateRemoteEvent(self:GetServerEventFolder(), remoteName)
	remote:FireAllClients(payload)
end

-- 内部请求流水线：冷却检查 -> 保护性调用 -> 结果包装；超频和回调异常转换为 NetResult。
-- 请求冷却未注册等接入错误仍会抛异常，不属于这里捕获的业务回调失败。
function NetService:_handleRequest(remoteName, handler, player, payload)
	-- 先占用冷却再执行业务；即使 handler 返回失败或抛异常，本次冷却仍已消耗。
	local allowed, retryAfterSeconds = self._requestRateLimiter:TryAcquire(player, remoteName)
	if not allowed then
		return NetResult.Err("RATE_LIMITED", "Request rate limited", {
			RemoteName = remoteName,
			RetryAfterSeconds = retryAfterSeconds,
		})
	end

	-- pcall(handler, player, payload) 相当于保护性执行 handler(player, payload)。
	-- ok 表示执行是否抛异常，result 是第一个返回值或错误；不等同于业务结果 result.Ok。
	local ok, result = pcall(handler, player, payload)

	-- 详细异常只写服务器日志；客户端收到通用 SERVER_ERROR，不暴露内部堆栈。
	if not ok then
		self._logger.Warn(self.Name, "请求失败: " .. remoteName .. " / " .. tostring(result))
		return NetResult.Err("SERVER_ERROR", "Request failed", {
			RemoteName = remoteName,
		})
	end

	-- handler 已返回 NetResult 时保留其成功/失败状态；普通值（包括 nil）才包装为 Ok。
	if NetResult.IsResult(result) then
		return result
	end

	return NetResult.Ok(result)
end

return NetService
