--!strict

-- 服务器存储统一入口：选择后端、管理玩家加载/离开/会话结束，并提供整档及模块数据接口。
-- 业务服务只依赖本服务，不直接操作底层 ProfileStore；Get 只读已打开数据，不能代替 Open。
-- 数据接口返回副本；底层参数/读写错误可能抛异常，只有明确返回错误码的接口才按结果处理。
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MemoryStorage = require(ReplicatedStorage.Framework.Shared.Storage.MemoryStorage)
local TableUtil = require(ReplicatedStorage.Framework.Shared.Util.TableUtil)
local StorageConfig = require(ReplicatedStorage.Module.Shared.Config.StorageConfig)
local ProfileStoreStorage = require(script.Parent.Parent.Storage.ProfileStoreStorage)

local StorageService = {
	Name = "StorageService",
}

StorageService._logger = nil
StorageService._storage = nil
-- 按玩家 key 记录当前加载身份、取消请求与状态；这些是内存运行状态，不写入玩家存档。
StorageService._openingByKey = {}
StorageService._cancelOpenByKey = {}
StorageService._playerDataStatusByKey = {}

local PLAYER_DATA_STATUS_LOADING = "LOADING"
local PLAYER_DATA_STATUS_READY = "READY"
local PLAYER_DATA_STATUS_LOAD_FAILED = "LOAD_FAILED"
local PLAYER_DATA_STATUS_SESSION_ENDED = "SESSION_ENDED"

-- 使用稳定的 UserId 字符串作为 key，避免玩家改名后读到另一份存档。
local function getPlayerKey(player)
	return tostring(player.UserId)
end

-- 校验可选的等待超时秒数，nil 表示持续等待直到出现确定结果。
-- 允许 0 表示只检查当前状态；排除负数、无穷和 NaN（不等于自身的数字）。
local function assertOptionalTimeout(timeoutSeconds)
	if timeoutSeconds == nil then
		return nil
	end

	if
		type(timeoutSeconds) ~= "number"
		or timeoutSeconds ~= timeoutSeconds
		or timeoutSeconds == math.huge
		or timeoutSeconds == -math.huge
		or timeoutSeconds < 0
	then
		error("timeoutSeconds 必须是大于或等于 0 的有限数字或 nil", 3)
	end

	return timeoutSeconds
end

-- moduleName 是 data.Modules 的索引名；只检查非空字符串，不负责判断业务模块是否注册。
local function assertModuleName(moduleName)
	if type(moduleName) ~= "string" or moduleName == "" then
		error("moduleName must be a non-empty string", 3)
	end
	return moduleName
end

-- 按 StorageConfig 创建一个后端实例；默认结构与校验函数注入后端，业务层不用知道具体实现。
local function createStorageBackend()
	if StorageConfig.Backend == "Memory" then
		return MemoryStorage.new(StorageConfig.DefaultData, StorageConfig.Validate)
	end

	if StorageConfig.Backend == "ProfileStore" then
		return ProfileStoreStorage.new(
			StorageConfig.ProfileStoreName,
			StorageConfig.DefaultData,
			StorageConfig.Validate
		)
	end

	error("Unsupported storage backend: " .. tostring(StorageConfig.Backend), 2)
end

-- 初始化日志、存储后端与状态表；此阶段尚未加载任何玩家，不代表数据已经可读。
function StorageService:Init(context)
	self._logger = context.Logger
	self._storage = createStorageBackend()
	self._openingByKey = {}
	self._cancelOpenByKey = {}
	self._playerDataStatusByKey = {}
end

-- 自动加载玩家的保护入口：捕获 OpenPlayer 异常/失败并记日志，仍在线时踢出以防无档游玩。
-- pcall(self.OpenPlayer, self, player) 显式传 self，等同于保护性执行 self:OpenPlayer(player)。
function StorageService:_openPlayerSafely(player)
	local key = getPlayerKey(player)
	local ok, data, openError = pcall(self.OpenPlayer, self, player)

	if not ok then
		if player.Parent == Players then
			self._playerDataStatusByKey[key] = PLAYER_DATA_STATUS_LOAD_FAILED
		end
		self._logger.Warn(self.Name, "Player data load crashed: " .. player.Name .. " / " .. tostring(data))
	elseif data ~= nil then
		return
	else
		if player.Parent == Players then
			self._playerDataStatusByKey[key] = PLAYER_DATA_STATUS_LOAD_FAILED
		end
		self._logger.Warn(self.Name, "Player data load failed: " .. player.Name .. " / " .. tostring(openError))
	end

	if player.Parent == Players then
		player:Kick("Player data could not be loaded. Please rejoin.")
	end
end

-- 连接加入/离开事件，并处理启动时已在线的玩家；每位玩家独立加载，不阻塞后续 Service:Start。
-- ProfileStore 后端的关服保存由库的 BindToClose 处理；Memory 后端不持久化，不额外重复保存。
function StorageService:Start()
	Players.PlayerAdded:Connect(function(player)
		-- task.spawn 启动单独协程；加载可能等待网络，不应阻塞这里的事件处理流程。
		task.spawn(function()
			self:_openPlayerSafely(player)
		end)
	end)

	Players.PlayerRemoving:Connect(function(player)
		self:ClosePlayer(player)
	end)

	-- 先监听再补扫，避免漏掉早于监听进入的玩家；重复加载请求由 OpenPlayer 协调。
	for _, player in ipairs(Players:GetPlayers()) do
		task.spawn(function()
			self:_openPlayerSafely(player)
		end)
	end

	self._logger.Info(self.Name, "Storage service started with backend: " .. StorageConfig.Backend)
end

-- 返回已构造的后端；初始化顺序错误直接抛异常，不在此偷偷创建新后端。
function StorageService:_getStorage()
	if self._storage == nil then
		error("StorageService is not initialized", 2)
	end
	return self._storage
end

-- 底层 key 接口：检查非空字符串 key 是否已有可用数据，不触发加载。
function StorageService:IsKeyOpen(key)
	return self:_getStorage():IsOpen(key)
end

-- 显式打开任意 key，返回数据副本或 nil, error；ProfileStore 可能等待，options 原样传给后端。
-- 普通玩家业务优先使用 OpenPlayer；直接 OpenKey 不维护玩家加载状态或踢出策略。
function StorageService:OpenKey(key, options)
	return self:_getStorage():Open(key, options)
end

-- 读取已打开 key 的数据副本；未打开则抛异常，不会自动创建默认数据。
function StorageService:GetKey(key)
	return self:_getStorage():Get(key)
end

-- 校验后替换整份数据并返回副本，不是字段合并，也不是远程保存完成的确认。
function StorageService:SetKey(key, data)
	return self:_getStorage():Set(key, data)
end

-- 回调接收副本并必须返回完整数据；回调失败或返回 nil 会抛异常，不能依赖外部副作用被回滚。
function StorageService:UpdateKey(key, updateFn)
	return self:_getStorage():Update(key, updateFn)
end

-- 释放已打开 key，无返回值；持久化后端结束会话，内存后端丢弃数据，均不是删除永久档案接口。
function StorageService:CloseKey(key)
	self:_getStorage():Close(key)
end

-- 打开指定玩家的数据；成功返回副本，已离开/加载失败/会话中断返回 nil, errorCode。
-- 同一 key 的并发调用优先等待已有加载；底层异常仍会向外抛，由自动加载入口统一处理。
function StorageService:OpenPlayer(player)
	local key = getPlayerKey(player)

	if player.Parent ~= Players then
		return nil, "PLAYER_LEFT"
	end

	if self:IsKeyOpen(key) then
		self._playerDataStatusByKey[key] = PLAYER_DATA_STATUS_READY
		return self:GetKey(key)
	end

	-- 另一调用正在加载时先等待，不同时向后端申请第二份会话；等待期间仍检查玩家离开与失败状态。
	if self._openingByKey[key] ~= nil then
		self._playerDataStatusByKey[key] = PLAYER_DATA_STATUS_LOADING

		while self._openingByKey[key] ~= nil do
			if player.Parent ~= Players then
				return nil, "PLAYER_LEFT"
			end

			local status = self._playerDataStatusByKey[key]
			if status == PLAYER_DATA_STATUS_LOAD_FAILED then
				return nil, "DATA_LOAD_FAILED"
			end

			if status == PLAYER_DATA_STATUS_SESSION_ENDED then
				return nil, "DATA_SESSION_ENDED"
			end

			task.wait(StorageConfig.PlayerDataReadyPollSeconds)
		end

		if self:IsKeyOpen(key) then
			self._playerDataStatusByKey[key] = PLAYER_DATA_STATUS_READY
			return self:GetKey(key)
		end

		local status = self._playerDataStatusByKey[key]
		if status == PLAYER_DATA_STATUS_LOAD_FAILED then
			return nil, "DATA_LOAD_FAILED"
		end

		if status == PLAYER_DATA_STATUS_SESSION_ENDED then
			return nil, "DATA_SESSION_ENDED"
		end
	end

	-- 新建空表作为这次加载的唯一身份；按引用比较，避免旧加载清理掉后来的状态。
	local openingToken = {}
	self._openingByKey[key] = openingToken
	self._cancelOpenByKey[key] = nil
	self._playerDataStatusByKey[key] = PLAYER_DATA_STATUS_LOADING

	-- 只清理仍属于本次加载的标记；成功、失败、玩家离开等出口都调用此函数。
	local function finishOpening()
		if self._openingByKey[key] == openingToken then
			self._openingByKey[key] = nil
			self._cancelOpenByKey[key] = nil
		end
	end

	local ok, data, openError = pcall(self.OpenKey, self, key, {
		UserId = player.UserId,
		-- 取消标记不强制终止协程，由支持此选项的持久化后端在加载过程中检查。
		Cancel = function()
			return self._cancelOpenByKey[key] == true or player.Parent ~= Players
		end,
		-- wasClosed 区分主动 Close 与意外失效；意外结束后不再让在线玩家继续使用失效存档。
		OnSessionEnd = function(wasClosed)
			if not wasClosed then
				if player.Parent == Players then
					self._playerDataStatusByKey[key] = PLAYER_DATA_STATUS_SESSION_ENDED
				end
				self._logger.Warn(self.Name, "Player data session ended unexpectedly: " .. player.Name)
				if player.Parent == Players then
					player:Kick("Player data session ended. Please rejoin.")
				end
			end
		end,
	})

	-- pcall 的 ok 为 false 表示抛异常；ok 为 true 但 data 为 nil 则是后端显式返回失败。
	if not ok then
		if player.Parent == Players then
			self._playerDataStatusByKey[key] = PLAYER_DATA_STATUS_LOAD_FAILED
		end
		finishOpening()
		error(data, 2)
	end

	if data == nil then
		if player.Parent == Players then
			self._playerDataStatusByKey[key] = PLAYER_DATA_STATUS_LOAD_FAILED
		end
		finishOpening()
		return nil, openError
	end

	-- 加载可能跨越玩家离开；拿到数据后再次确认在线，否则立即释放刚打开的会话。
	if player.Parent ~= Players then
		local closeOk, closeError = pcall(self.CloseKey, self, key)
		finishOpening()
		if not closeOk then
			error(closeError, 2)
		end
		return nil, "PLAYER_LEFT_DURING_LOAD"
	end

	self._playerDataStatusByKey[key] = PLAYER_DATA_STATUS_READY
	finishOpening()
	self._logger.Debug(self.Name, "Player data opened: " .. player.Name)
	return data
end

-- 非等待式检查：以底层 key 是否打开为准；不会触发 OpenPlayer，也不返回数据本身。
function StorageService:IsPlayerDataReady(player)
	return self:IsKeyOpen(getPlayerKey(player))
end

-- 等待指定玩家的数据就绪，并把离开、加载失败、会话中断和超时统一为结果码。
-- 成功返回 true, "READY"，失败返回 false, errorCode；timeoutSeconds 为 nil 时不设超时。
-- 这里只等已有加载流程，不会主动加载；超时不等于取消底层加载，可稍后再次检查。
function StorageService:WaitForPlayerData(player, timeoutSeconds)
	timeoutSeconds = assertOptionalTimeout(timeoutSeconds)

	local key = getPlayerKey(player)
	local deadline = nil
	if timeoutSeconds ~= nil then
		deadline = os.clock() + timeoutSeconds
	end

	while player.Parent == Players do
		if self:IsKeyOpen(key) then
			self._playerDataStatusByKey[key] = PLAYER_DATA_STATUS_READY
			return true, PLAYER_DATA_STATUS_READY
		end

		local status = self._playerDataStatusByKey[key]
		if status == PLAYER_DATA_STATUS_LOAD_FAILED then
			return false, "DATA_LOAD_FAILED"
		end

		if status == PLAYER_DATA_STATUS_SESSION_ENDED then
			return false, "DATA_SESSION_ENDED"
		end

		-- 先看就绪/失败，再看超时；timeoutSeconds = 0 时，已就绪的数据仍立即返回成功。
		if deadline ~= nil and os.clock() >= deadline then
			return false, "DATA_READY_TIMEOUT"
		end

		task.wait(StorageConfig.PlayerDataReadyPollSeconds)
	end

	return false, "PLAYER_LEFT"
end

-- 标记取消进行中的加载，并释放已打开数据；通常由 PlayerRemoving 调用，不删除永久存档。
function StorageService:ClosePlayer(player)
	local key = getPlayerKey(player)
	self._cancelOpenByKey[key] = true

	if self:IsKeyOpen(key) then
		self:CloseKey(key)
		self._logger.Debug(self.Name, "Player data closed: " .. player.Name)
	end

	self._playerDataStatusByKey[key] = nil
end

-- 读取玩家整档副本；调用前应 IsPlayerDataReady 或 WaitForPlayerData，不会隐式加载。
function StorageService:GetPlayerData(player)
	return self:GetKey(getPlayerKey(player))
end

-- 替换玩家整份存档并返回副本；只改少数字段时优先 UpdatePlayerData，避免漏掉其他模块数据。
function StorageService:SetPlayerData(player, data)
	return self:SetKey(getPlayerKey(player), data)
end

-- 将指定已打开玩家的整份存档恢复为当前默认结构。
-- 成功返回 true, 新数据，失败返回 false, errorCode；会覆盖全部 Modules，不是单模块重置。
-- 仅提供服务器接口，不默认暴露 Remote/UI；调用方负责管理权限，且此操作不是删除 DataStore key。
function StorageService:ResetPlayerData(player)
	if not self:IsPlayerDataReady(player) then
		return false, "DATA_NOT_READY"
	end

	local defaultData = TableUtil.DeepCopy(StorageConfig.DefaultData)
	local ok, dataOrError = pcall(self.SetPlayerData, self, player, defaultData)
	if not ok then
		self._logger.Warn(self.Name, "初始化玩家存档失败: " .. player.Name .. " / " .. tostring(dataOrError))
		return false, "DATA_RESET_FAILED"
	end

	return true, dataOrError
end

-- 对玩家整档执行读取副本 -> 回调修改 -> 校验提交；updateFn 必须返回完整数据表。
function StorageService:UpdatePlayerData(player, updateFn)
	return self:UpdateKey(getPlayerKey(player), updateFn)
end

-- 返回 data.Modules[moduleName] 的副本；模块不存在时返回 nil，不创建默认模块数据。
function StorageService:GetPlayerModuleData(player, moduleName)
	moduleName = assertModuleName(moduleName)
	local data = self:GetPlayerData(player)
	return TableUtil.DeepCopy(data.Modules[moduleName])
end

-- 只更新指定模块：不存在时先复制 defaultModuleData（nil 则用空表），再调用 updateFn(moduleData)。
-- 回调返回非 nil 时替换模块，返回 nil 时保留对副本的原地修改；这与整档 Update 的约定不同。
-- 返回更新后的模块副本；其余模块保留，整档仍由后端校验，模块内部业务约束由调用方负责。
function StorageService:UpdatePlayerModuleData(player, moduleName, defaultModuleData, updateFn)
	moduleName = assertModuleName(moduleName)

	if defaultModuleData ~= nil and type(defaultModuleData) ~= "table" then
		error("defaultModuleData must be a table or nil", 2)
	end

	if type(updateFn) ~= "function" then
		error("updateFn must be a function", 2)
	end

	local updatedData = self:UpdatePlayerData(player, function(data)
		local moduleData = data.Modules[moduleName]
		if moduleData == nil then
			moduleData = TableUtil.DeepCopy(defaultModuleData or {})
			data.Modules[moduleName] = moduleData
		end

		local nextModuleData = updateFn(moduleData)
		if nextModuleData ~= nil then
			data.Modules[moduleName] = nextModuleData
		end

		return data
	end)

	return TableUtil.DeepCopy(updatedData.Modules[moduleName])
end

return StorageService
