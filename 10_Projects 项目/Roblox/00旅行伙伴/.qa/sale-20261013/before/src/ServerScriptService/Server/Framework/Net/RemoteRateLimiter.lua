--!strict

-- RemoteRateLimiter 只记录服务器内存中的请求冷却，不负责封禁、持久化或全局限流。
-- 冷却按 Player + remoteName 隔离；不同玩家、不同请求不会互相占用额度。
local RemoteRateLimiter = {}
RemoteRateLimiter.__index = RemoteRateLimiter

-- 成功返回冷却秒数，非法值抛异常；NaN（非数值）是唯一不等于自身的数字。
local function assertCooldownSeconds(cooldownSeconds)
	if
		type(cooldownSeconds) ~= "number"
		or cooldownSeconds ~= cooldownSeconds
		or cooldownSeconds <= 0
		or cooldownSeconds == math.huge
	then
		error("cooldownSeconds must be a finite number greater than 0", 3)
	end

	return cooldownSeconds
end

-- 创建独立冷却器；clock 可选，须返回递增秒数，默认 os.clock，不使用日期时间。
-- 测试可注入可控时钟，模拟经过几秒而无需真的等待。
function RemoteRateLimiter.new(clock)
	if clock ~= nil and type(clock) ~= "function" then
		error("clock must be a function", 2)
	end

	local self = setmetatable({}, RemoteRateLimiter)
	self._clock = clock or os.clock
	self._cooldownSecondsByName = {}
	self._lastRequestAtByPlayer = {}
	return self
end

-- 为请求设置正数冷却；可覆盖配置，但不会清空该请求已有的最近放行时间。
function RemoteRateLimiter:SetCooldown(remoteName, cooldownSeconds)
	if type(remoteName) ~= "string" or remoteName == "" then
		error("remoteName must be a non-empty string", 2)
	end

	self._cooldownSecondsByName[remoteName] = assertCooldownSeconds(cooldownSeconds)
end

-- 尝试占用一次请求机会：放行返回 true, 0；冷却中返回 false, 剩余秒数。
-- 必须先 SetCooldown；本模块不检查 player 是否为 Player，真实调用者由 NetService 提供。
function RemoteRateLimiter:TryAcquire(player, remoteName)
	local cooldownSeconds = self._cooldownSecondsByName[remoteName]
	if cooldownSeconds == nil then
		error("Request cooldown is not registered: " .. tostring(remoteName), 2)
	end

	local now = self._clock()
	local lastRequestAtByName = self._lastRequestAtByPlayer[player]
	if lastRequestAtByName == nil then
		lastRequestAtByName = {}
		self._lastRequestAtByPlayer[player] = lastRequestAtByName
	end

	local lastRequestAt = lastRequestAtByName[remoteName]
	if lastRequestAt ~= nil then
		local retryAfterSeconds = cooldownSeconds - (now - lastRequestAt)
		if retryAfterSeconds > 0 then
			-- 被拒绝不会更新时间戳，因此连续重试不会延长这轮冷却。
			return false, retryAfterSeconds
		end
	end

	lastRequestAtByName[remoteName] = now
	return true, 0
end

-- 玩家离开时释放其全部请求记录；不影响其他玩家，也不删除各请求的冷却配置。
function RemoteRateLimiter:ClearPlayer(player)
	self._lastRequestAtByPlayer[player] = nil
end

return RemoteRateLimiter
