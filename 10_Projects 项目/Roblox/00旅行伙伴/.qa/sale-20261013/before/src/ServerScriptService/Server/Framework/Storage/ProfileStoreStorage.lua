--!strict

-- 将 ProfileStore 会话封装成 Open/Get/Set/Update/Close 接口，供 StorageService 调用。
-- 本层负责副本隔离与会话有效性；自动保存/锁管理交给第三方库，不提供删除永久存档接口。
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ProfileStore = require(ServerScriptService.ServerPackages.ProfileStore)
local TableUtil = require(ReplicatedStorage.Framework.Shared.Util.TableUtil)

local ProfileStoreStorage = {}
-- __index 将实例方法查找转到本表；_profilesByKey 保存各 key 当前拥有的会话对象。
ProfileStoreStorage.__index = ProfileStoreStorage

-- storeName 是持久化存储名称，defaultData 是默认表，validate 可选并返回 true 或 false, message。
-- 构造器只创建适配器与存储入口，不加载玩家数据；更改 storeName 会访问另一套存档。
function ProfileStoreStorage.new(storeName, defaultData, validate)
	if type(storeName) ~= "string" or storeName == "" then
		error("storeName must be a non-empty string", 2)
	end

	if type(defaultData) ~= "table" then
		error("defaultData must be a table", 2)
	end

	if validate ~= nil and type(validate) ~= "function" then
		error("validate must be a function", 2)
	end

	local self = setmetatable({}, ProfileStoreStorage)
	self._store = ProfileStore.New(storeName, TableUtil.DeepCopy(defaultData))
	self._validate = validate
	self._profilesByKey = {}
	self._closingByKey = {}
	self._updatingByKey = {}
	return self
end

-- 校验非空字符串 key；成功返回原值，失败抛异常，供公开接口统一复用。
function ProfileStoreStorage:_assertKey(key)
	if type(key) ~= "string" or key == "" then
		error("key must be a non-empty string", 3)
	end
	return key
end

-- 返回 true 或 false, message；此处不主动抛校验失败，由 Open/Set 决定如何处理。
function ProfileStoreStorage:_validateData(data)
	if self._validate == nil then
		return true
	end

	local ok, message = self._validate(data)
	if not ok then
		return false, tostring(message)
	end
	return true
end

-- 取得仍然有效的已打开会话；缺失或失效时抛异常，不在读写过程中重新加载。
function ProfileStoreStorage:_getProfile(key)
	key = self:_assertKey(key)

	local profile = self._profilesByKey[key]
	if profile == nil or not profile:IsActive() then
		error("storage key is not open: " .. key, 3)
	end
	return profile
end

-- 同时检查本地引用与 IsActive，避免把已结束但尚有引用的会话误判为可写。
function ProfileStoreStorage:IsOpen(key)
	key = self:_assertKey(key)
	local profile = self._profilesByKey[key]
	return profile ~= nil and profile:IsActive()
end

-- 打开持久化会话并返回数据副本；加载失败返回 nil, errorCode，准备阶段异常仍会抛出。
-- options 可传 UserId、Cancel() 与 OnSessionEnd(wasClosed)；重复打开有效 key 直接读当前副本。
function ProfileStoreStorage:Open(key, options)
	key = self:_assertKey(key)
	options = options or {}

	if self:IsOpen(key) then
		return self:Get(key)
	end

	-- Async 表示此调用可能等待；Cancel 交给库检查，用于取消离线玩家仍在进行的加载。
	local profile = self._store:StartSessionAsync(key, {
		Cancel = options.Cancel,
	})

	if profile == nil then
		return nil, "PROFILE_LOAD_FAILED"
	end

	local prepareOk, isValid, validationError = pcall(function()
		if options.UserId ~= nil then
			profile:AddUserId(options.UserId)
		end
		-- Reconcile 补齐模板缺失字段，不是版本迁移；之后仍必须通过当前 Schema 校验。
		profile:Reconcile()
		return self:_validateData(profile.Data)
	end)

	if not prepareOk then
		-- 准备数据时异常也要尝试释放会话；保留原错误，不让释放错误覆盖真正原因。
		pcall(profile.EndSession, profile)
		error(isValid, 2)
	end

	if not isValid then
		profile:EndSession()
		return nil, "INVALID_PROFILE_DATA: " .. tostring(validationError)
	end

	self._profilesByKey[key] = profile
	-- 会话结束可能来自主动 Close，也可能来自外部失效；回调将原因交给 StorageService。
	profile.OnSessionEnd:Connect(function()
		local wasClosed = self._closingByKey[key] == true
		self._closingByKey[key] = nil
		self._updatingByKey[key] = nil

		-- 引用相等才移除，避免旧会话结束时删掉同 key 后来取得的新会话引用。
		if self._profilesByKey[key] == profile then
			self._profilesByKey[key] = nil
		end

		if type(options.OnSessionEnd) == "function" then
			options.OnSessionEnd(wasClosed)
		end
	end)

	return self:Get(key)
end

-- 返回当前会话数据的深拷贝；直接改返回表不会保存，必须再调用 Set 或 Update。
function ProfileStoreStorage:Get(key)
	local profile = self:_getProfile(key)
	return TableUtil.DeepCopy(profile.Data)
end

-- 校验副本后替换当前会话的整份数据，返回新副本；不是立即完成一次远程写盘。
-- 持久化时机由 ProfileStore 管理；校验失败抛异常并保留原会话数据。
function ProfileStoreStorage:Set(key, data)
	local profile = self:_getProfile(key)
	local copy = TableUtil.DeepCopy(data)
	local isValid, validationError = self:_validateData(copy)

	if not isValid then
		error("invalid storage data: " .. tostring(validationError), 2)
	end

	-- table.clear 清空表内容但保留表本身，让持有 profile.Data 引用的库继续使用同一张表。
	table.clear(profile.Data)
	for dataKey, value in pairs(copy) do
		profile.Data[dataKey] = value
	end

	return self:Get(key)
end

-- 将数据副本交给 updateFn；必须返回完整数据，随后检查会话仍有效再提交。
-- 拒绝同 key 重入 Update，不提供回调副作用回滚；回调应避免等待与自行切换存储会话。
function ProfileStoreStorage:Update(key, updateFn)
	key = self:_assertKey(key)

	if type(updateFn) ~= "function" then
		error("updateFn must be a function", 2)
	end

	if self._updatingByKey[key] then
		error("storage key is already being updated: " .. key, 2)
	end

	local profile = self:_getProfile(key)
	-- 空表每次都有不同引用，作为本次更新的 token（身份标记），防止误清理其他更新。
	local updateToken = {}
	self._updatingByKey[key] = updateToken
	local ok, nextData = pcall(updateFn, TableUtil.DeepCopy(profile.Data))
	if self._updatingByKey[key] == updateToken then
		self._updatingByKey[key] = nil
	end

	if not ok then
		error(nextData, 2)
	end

	if nextData == nil then
		error("updateFn must return storage data", 2)
	end

	-- 回调期间会话可能已关闭/更换，不能把旧数据写进新的会话。
	if self._profilesByKey[key] ~= profile or not profile:IsActive() then
		error("storage session changed during update: " .. key, 2)
	end

	return self:Set(key, nextData)
end

-- 主动结束会话，由库处理保存与释放；本方法无返回值，不表示远程保存此刻已全部完成。
-- 未打开的 key 直接返回；不会删除永久数据，下次 Open 仍可加载此前存档。
function ProfileStoreStorage:Close(key)
	key = self:_assertKey(key)

	local profile = self._profilesByKey[key]
	if profile == nil then
		return
	end

	self._closingByKey[key] = true
	-- 先从本地可用集合移除，防止 EndSession 后仍有业务继续读取或写入该会话。
	self._updatingByKey[key] = nil
	self._profilesByKey[key] = nil
	profile:EndSession()
end

return ProfileStoreStorage
