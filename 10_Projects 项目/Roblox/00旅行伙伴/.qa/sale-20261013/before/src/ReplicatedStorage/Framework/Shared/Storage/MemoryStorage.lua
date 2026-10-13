--!strict

-- 内存存储适配器：提供与持久化后端相同的基础接口，但不会写 DataStore，进程结束即丢失。
-- 业务服务经 StorageService 使用它；Get/Set/Update 通过深拷贝隔离内部数据引用。
local TableUtil = require(script.Parent.Parent.Util.TableUtil)

local MemoryStorage = {}
-- new 返回独立实例；__index 让实例通过冒号调用此表中的方法。
MemoryStorage.__index = MemoryStorage

-- defaultData 是默认数据表；validate 可选，约定返回 true 或 false, message。
-- 这里只复制默认模板，真正创建某个 key 的数据要等 Open；参数类型错误抛异常。
function MemoryStorage.new(defaultData, validate)
	if type(defaultData) ~= "table" then
		error("defaultData must be a table", 2)
	end

	if validate ~= nil and type(validate) ~= "function" then
		error("validate must be a function", 2)
	end

	local self = setmetatable({}, MemoryStorage)
	self._defaultData = TableUtil.DeepCopy(defaultData)
	self._validate = validate
	self._dataByKey = {}
	self._updatingByKey = {}
	return self
end

-- key 是非空字符串，例如玩家 UserId 转成的文字；校验成功返回原值，否则抛异常。
function MemoryStorage:_assertKey(key)
	if type(key) ~= "string" or key == "" then
		error("key must be a non-empty string", 3)
	end
	return key
end

-- 未配置校验器时直接放行；配置了则检查整份数据，失败抛异常而非返回业务错误码。
function MemoryStorage:_validateData(data)
	if self._validate == nil then
		return
	end

	local ok, message = self._validate(data)
	if not ok then
		error("invalid storage data: " .. tostring(message), 3)
	end
end

-- 每次复制并校验一份默认数据，避免两个 key 共用同一张嵌套表。
function MemoryStorage:_createDefault()
	local data = TableUtil.DeepCopy(self._defaultData)
	self:_validateData(data)
	return data
end

-- 只检查 key 是否已打开，不创建数据；非法 key 仍会抛异常。
function MemoryStorage:IsOpen(key)
	key = self:_assertKey(key)
	return self._dataByKey[key] ~= nil
end

-- 首次打开时创建默认数据，重复打开保留现有数据；返回副本。
-- _options 仅为与持久化接口保持一致，此后端不处理取消加载或会话结束回调。
function MemoryStorage:Open(key, _options)
	key = self:_assertKey(key)

	if not self:IsOpen(key) then
		self._dataByKey[key] = self:_createDefault()
	end

	return self:Get(key)
end

-- 读取已打开 key 的深拷贝；未打开时抛异常，不会隐式 Open。
function MemoryStorage:Get(key)
	key = self:_assertKey(key)

	local data = self._dataByKey[key]
	if data == nil then
		error("storage key is not open: " .. key, 2)
	end

	return TableUtil.DeepCopy(data)
end

-- 校验后替换整份数据并返回新副本，不是合并字段；失败校验不会覆盖旧值。
function MemoryStorage:Set(key, data)
	key = self:_assertKey(key)

	if not self:IsOpen(key) then
		error("storage key is not open: " .. key, 2)
	end

	local copy = TableUtil.DeepCopy(data)
	self:_validateData(copy)
	self._dataByKey[key] = copy
	return self:Get(key)
end

-- 将当前数据副本交给 updateFn，回调必须返回完整数据，再经 Set 校验提交。
-- 防止同一 key 重入更新，但不是事务/排队锁；回调应短小、不等待，也不要直接调用同 key 的 Set/Close。
function MemoryStorage:Update(key, updateFn)
	key = self:_assertKey(key)

	if type(updateFn) ~= "function" then
		error("updateFn must be a function", 2)
	end

	if self._updatingByKey[key] then
		error("storage key is already being updated: " .. key, 2)
	end

	-- 先确认数据可读，再占用更新锁；未打开的 key 抛错时不能留下锁。
	local currentData = self:Get(key)
	self._updatingByKey[key] = true
	local ok, nextData = pcall(updateFn, currentData)
	-- 回调返回后先释放标记，再处理回调失败；丢弃失败回调的副本，不提交它的修改。
	self._updatingByKey[key] = nil

	if not ok then
		error(nextData, 2)
	end

	if nextData == nil then
		error("updateFn must return storage data", 2)
	end

	return self:Set(key, nextData)
end

-- 丢弃此 key 的内存数据和更新标记，无返回值；再次 Open 会重新使用默认数据。
-- 这里没有永久存档可删除；持久化后端的 Close 则是保存并释放会话，两者不要混淆。
function MemoryStorage:Close(key)
	key = self:_assertKey(key)
	self._updatingByKey[key] = nil
	self._dataByKey[key] = nil
end

return MemoryStorage
