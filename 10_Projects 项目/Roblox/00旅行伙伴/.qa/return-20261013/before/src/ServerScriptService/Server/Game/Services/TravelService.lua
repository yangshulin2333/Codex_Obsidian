--!nonstrict

-- Game 集成层：只依赖 StorageService / NetService / TravelWorldService。
-- ProfileStore 的自动保存与离场保存由框架管理；Update 不是即时写盘确认。
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local NetResult = require(ReplicatedStorage.Framework.Shared.Net.NetResult)
local TableUtil = require(ReplicatedStorage.Framework.Shared.Util.TableUtil)
local StorageConfig = require(ReplicatedStorage.Module.Shared.Config.StorageConfig)
local Protocol = require(ReplicatedStorage.Game.Shared.TravelProtocol)
local TravelDomain = require(script.Parent.Parent.Domain.TravelDomain)
local Config = require(script.Parent.Parent.Config.TravelConfig)
local Generated = ReplicatedStorage.Game.Shared.Config.Generated

local TravelService = { Name = "TravelService" }
local MODULE_NAME = "TravelBuddy"
local MESSAGES = {
	DATA_NOT_READY = "玩家数据还在加载，请稍后再试。",
	INVALID_REQUEST = "请求格式不正确。",
	INVALID_PAYLOAD = "请求参数不正确。",
	INVALID_QUANTITY = "补给或物品数量不正确。",
	STALE_STATE = "状态已更新，请刷新后再操作。",
	TOO_FAR = "请走到自己的对应设施或公共收购台再操作。",
	BUSY = "上一次操作还在处理。",
	NOT_ENOUGH_COINS = "金币不足。",
	NOT_ENOUGH_WOOD = "木板不足。",
	NOT_ENOUGH_SUPPLIES = "请先购买补给。",
	NOT_ENOUGH_PACKED_SUPPLIES = "行囊补给不足，请到自己的准备桌装入补给。",
	NOT_ENOUGH_WAREHOUSE_SUPPLIES = "仓库补给不足，请先到商店购买。",
	BAG_FULL = "行囊最多装三份补给，请先收回或等待旅行消耗。",
	BAG_READ_ONLY = "伙伴正在旅行或尚未靠岸，目前只能查看行囊。",
	TRAVEL_IN_PROGRESS = "伙伴已经离港，目前不能暂缓或改动本次旅行。",
	CONTAINER_CAPACITY = "箱区已满，请先开箱。",
	CONTAINER_FULL = "箱区已满，请先开箱。",
	SEA_LOCKED = "需要升级船只才能前往这个海域。",
	JOURNEY_ACTIVE = "海蛙正在旅行，或本次奖励还未领取。",
	NOT_RETURNED = "海蛙还没有归来。",
	JOURNEY_NOT_READY = "海蛙还没有归来。",
	JOURNEY_NOT_FOUND = "这次远航不存在或已经结算。",
	JOURNEY_CLAIMED = "本次远航奖励已经领取。",
	RESTING = "海蛙正在休息，请稍后出发。",
	SHIP_UPGRADING = "船只正在升级，完工后才能出发。",
	SHIP_AWAY = "请先等海蛙归家并领取本次奖励，再升级船只。",
	CONTAINER_NOT_FOUND = "这个箱子不属于你或已经打开。",
	OPERATION_CONFLICT = "操作编号与原请求不一致。",
	UPGRADE_ACTIVE = "该设施正在升级。",
	MAX_LEVEL = "已经达到 Demo 的最高等级。",
	KEEP_TRAVEL_BUDGET = "升级后需要保留一份补给或下一趟补给费用。",
	KEEP_SUPPLY_RESERVE = "升级后需要保留一份补给或下一趟补给费用。",
	NO_ITEMS = "背包里没有可出售物品。",
	NOT_ENOUGH_ITEMS = "可出售数量不足。",
	RELIEF_NOT_AVAILABLE = "当前还有补给、金币或可用货物，无需领取应急补给。",
}

local function finiteInteger(value)
	return type(value) == "number" and value >= 0 and value <= 9007199254740991 and value % 1 == 0
end

-- Remote 只接受小型扁平指令，避免递归表、Instance 或巨型字符串进入业务处理。
local function boundedPayload(payload)
	if type(payload) ~= "table" then
		return false
	end
	local count = 0
	for key, value in pairs(payload) do
		count += 1
		if count > 6 or type(key) ~= "string" or #key > 32 then
			return false
		end
		if type(value) == "string" then
			if #value == 0 or #value > 80 then
				return false
			end
		elseif not finiteInteger(value) then
			return false
		end
	end
	return true
end

local function readOnlyRequest(payload)
	if type(payload) ~= "table" or payload.Action ~= Protocol.Actions.ReadState then
		return false
	end
	for key in pairs(payload) do
		if key ~= "Action" then
			return false
		end
	end
	return true
end

function TravelService:Init(context)
	self._logger = context.Logger
	self._storage = context.Services.StorageService
	self._net = context.Services.NetService
	self._world = context.Services.TravelWorldService
	self._domain = TravelDomain.new(Config)
	self._ready = {}
	self._loading = {}
	self._busy = {}
	self._lastRevision = {}
	self._characterConnections = {}
	self._timeScale = if RunService:IsStudio()
		then Config.Settings.StudioTimeScale
		else Config.Settings.ProductionTimeScale
	self._random = Random.new()
	self._context = {
		Random = self._random,
		NewId = function()
			return HttpService:GenerateGUID(false)
		end,
		TimeScale = self._timeScale,
		IsStudio = RunService:IsStudio(),
	}
	self._publicConfig = {
		Seas = require(Generated.TravelSeas),
		Items = require(Generated.TravelItems),
		Durations = TableUtil.DeepCopy(require(Generated.TravelDurations)),
		UpgradeOptions = TableUtil.DeepCopy(require(Generated.TravelUpgrades)),
		PostcardOptions = require(Generated.TravelPostcards),
		Images = require(Generated.Images),
	}
	for _, row in pairs(self._publicConfig.Durations) do
		row.BaseSeconds = row.Seconds
		row.Seconds = math.max(1, math.floor(row.Seconds * self._timeScale + 0.5))
	end
	for _, row in pairs(self._publicConfig.UpgradeOptions) do
		row.BaseSeconds = row.Seconds
		row.Seconds = math.max(1, math.floor(row.Seconds * self._timeScale + 0.5))
	end
	self._net:EnsureServerEvent(Protocol.StateEvent)
end

function TravelService:_snapshot(player, data)
	local now = os.time()
	local state = self._domain:Public(data, now)
	state.ServerTime = now
	state.PlotId = self._world:GetPlotId(player)
	state.StorageBackend = StorageConfig.Backend
	state.IsStudio = RunService:IsStudio()
	state.FirstJourneySeconds = math.max(1, math.floor(Config.Settings.FirstJourneySeconds * self._timeScale + 0.5))
	state.SupplyPrice = Config.Settings.SupplyPrice
	local journeySeconds = if state.Journey then state.Journey.EndAt - state.Journey.StartAt else math.huge
	state.DepartureSeconds = math.max(0.5, math.min(Config.Settings.DepartureSeconds, journeySeconds / 3))
	state.ReturnSeconds = math.max(0.5, math.min(Config.Settings.ReturnSeconds, journeySeconds / 3))
	if state.IsStudio then
		state.PersistenceNotice =
			"Studio 测试：真实重进存档需在已发布测试 Place 开启 API 后验证。"
	end
	for key, value in pairs(self._publicConfig) do
		state[key] = value
	end
	return state
end

function TravelService:_publish(player, data, force)
	if player.Parent ~= Players then
		return
	end
	local state = self:_snapshot(player, data)
	local rendered, renderError = pcall(self._world.Render, self._world, player, state)
	if not rendered then
		self._logger.Warn(self.Name, "Travel visuals failed; authoritative data retained: " .. tostring(renderError))
	end
	if force or self._lastRevision[player] ~= state.Revision then
		self._lastRevision[player] = state.Revision
		self._net:FireClient(Protocol.StateEvent, player, state)
	end
	return state
end

function TravelService:_update(player, callback)
	return self._storage:UpdatePlayerModuleData(player, MODULE_NAME, self._domain:NewData(), function(data)
		local migrated, migrationMessage = self._domain:Migrate(data)
		assert(migrated, "TravelBuddy migration rejected: " .. tostring(migrationMessage))
		local valid, message = self._domain:Validate(data)
		assert(valid, "Invalid TravelBuddy profile: " .. tostring(message))
		self._domain:Advance(data, os.time(), self._context)
		callback(data)
		self._domain:Advance(data, os.time(), self._context)
		local nextValid, nextMessage = self._domain:Validate(data)
		assert(nextValid, "TravelBuddy update rejected: " .. tostring(nextMessage))
		return data
	end)
end

function TravelService:_join(player)
	if self._loading[player] or self._ready[player] then
		return
	end
	self._loading[player] = true
	local ready, readyCode
	repeat
		ready, readyCode = self._storage:WaitForPlayerData(player, Config.Settings.DataReadyTimeout)
	until ready or readyCode ~= "DATA_READY_TIMEOUT" or player.Parent ~= Players
	if not ready or player.Parent ~= Players then
		self._loading[player] = nil
		self._logger.Warn(self.Name, "Travel data not ready: " .. tostring(readyCode))
		return
	end
	local plotId = self._world:Assign(player)
	if plotId == nil then
		self._loading[player] = nil
		player:Kick("本服四个住宅位已满，请进入其他服务器。")
		return
	end
	local ok, data = pcall(function()
		return self:_update(player, function() end)
	end)
	self._loading[player] = nil
	if not ok or player.Parent ~= Players then
		self._world:Release(player)
		if not ok then
			self._logger.Warn(self.Name, "Travel profile initialization failed: " .. tostring(data))
			if player.Parent == Players then
				player:Kick("海蛙数据未能加载，请重进；原存档没有被重置。")
			end
		end
		return
	end
	self._ready[player] = true
	self:_publish(player, data, true)
	local function placeCharacter(character)
		local root = character:WaitForChild("HumanoidRootPart", Config.Settings.DataReadyTimeout)
		if root and player.Parent == Players and self._ready[player] then
			local spawn = self._world:GetSpawnCFrame(player)
			if spawn then
				character:PivotTo(spawn)
			end
		end
	end
	self._characterConnections[player] = player.CharacterAdded:Connect(placeCharacter)
	if player.Character then
		task.spawn(placeCharacter, player.Character)
	end
end

function TravelService:_interaction(action, payload)
	if action == Protocol.Actions.Upgrade then
		return if payload.Target == "Home" then "HomeUpgrade" else "ShipUpgrade"
	end
	local interactions = {
		BuySupply = "Shop",
		PackSupply = "Bag",
		UnpackSupply = "Bag",
		PauseTravel = "Bag",
		ResumeTravel = "Bag",
		ClaimReturn = "ClaimReturn",
		OpenContainer = "OpenContainer",
		SellItem = "Shop",
		SellAll = "Shop",
		ClaimRelief = "Shop",
	}
	return interactions[action]
end

function TravelService:HandleRequest(player, payload)
	if not self._ready[player] or not self._storage:IsPlayerDataReady(player) then
		return NetResult.Err("DATA_NOT_READY", MESSAGES.DATA_NOT_READY)
	end
	if self._busy[player] then
		return NetResult.Err("BUSY", MESSAGES.BUSY)
	end
	if not boundedPayload(payload) or type(payload.Action) ~= "string" then
		return NetResult.Err("INVALID_REQUEST", MESSAGES.INVALID_REQUEST)
	end
	local action = payload.Action
	if Protocol.Actions[action] ~= action then
		return NetResult.Err("INVALID_REQUEST", MESSAGES.INVALID_REQUEST)
	end
	local isRead = action == Protocol.Actions.ReadState
	if isRead and not readOnlyRequest(payload) then
		return NetResult.Err("INVALID_REQUEST", MESSAGES.INVALID_REQUEST)
	end
	if not isRead and not finiteInteger(payload.ExpectedRevision) then
		return NetResult.Err("INVALID_REQUEST", "操作需要当前状态版本。")
	end
	if not isRead and (type(payload.OperationId) ~= "string" or string.find(payload.OperationId, "%S") == nil) then
		return NetResult.Err("INVALID_REQUEST", MESSAGES.INVALID_REQUEST)
	end
	local domainPayload = {}
	for key, value in pairs(payload) do
		if key ~= "Action" then
			domainPayload[key] = value
		end
	end
	self._busy[player] = true
	local applied, code, outcome = true, "OK", nil
	local success, data = pcall(function()
		return self:_update(player, function(profile)
			if not isRead then
				-- 已提交操作的原样重试不再要求箱子/设施仍存在；领域层核验收据指纹。
				-- 新操作必须在本人对应设施附近，不能用其他玩家的箱位或升级入口。
				if profile.Receipts[payload.OperationId] == nil then
					local interaction = self:_interaction(action, payload)
					if not interaction or not self._world:CanInteract(player, interaction, payload.ContainerId) then
						applied, code = false, "TOO_FAR"
						return
					end
				end
				applied, code, outcome = self._domain:Apply(profile, action, domainPayload, os.time(), self._context)
			end
		end)
	end)
	self._busy[player] = nil
	if not success then
		self._logger.Warn(self.Name, "Travel update failed: " .. tostring(data))
		return NetResult.Err("DATA_UPDATE_FAILED", "操作未能确认，请刷新状态。")
	end
	local state = self:_publish(player, data, false)
	if not applied then
		return NetResult.Err(code, MESSAGES[code] or "当前状态不允许这个操作。", { State = state })
	end
	return NetResult.Ok({ State = state, Outcome = outcome })
end

function TravelService:Start()
	self._net:RegisterRequest(Protocol.Request, function(player, payload)
		return self:HandleRequest(player, payload)
	end, Config.Settings.RequestCooldown)
	Players.PlayerAdded:Connect(function(player)
		task.spawn(function()
			self:_join(player)
		end)
	end)
	Players.PlayerRemoving:Connect(function(player)
		self._ready[player] = nil
		self._loading[player] = nil
		self._busy[player] = nil
		self._lastRevision[player] = nil
		local characterConnection = self._characterConnections[player]
		if characterConnection then
			characterConnection:Disconnect()
			self._characterConnections[player] = nil
		end
		self._world:Release(player)
	end)
	for _, player in ipairs(Players:GetPlayers()) do
		task.spawn(function()
			self:_join(player)
		end)
	end
	local stepElapsed = 0
	RunService.Heartbeat:Connect(function(delta)
		stepElapsed += delta
		if stepElapsed >= 0.1 then
			stepElapsed = 0
			self._world:Step(workspace:GetServerTimeNow())
		end
	end)
	task.spawn(function()
		while true do
			task.wait(Config.Settings.TickSeconds)
			for player in pairs(self._ready) do
				if not self._busy[player] and player.Parent == Players and self._storage:IsPlayerDataReady(player) then
					self._busy[player] = true
					local ok, data = pcall(function()
						return self:_update(player, function() end)
					end)
					self._busy[player] = nil
					if ok then
						self:_publish(player, data, false)
					else
						self._logger.Warn(self.Name, "Travel clock update failed: " .. tostring(data))
					end
				end
			end
		end
	end)
	self._logger.Info(self.Name, "TravelBuddy Demo started; storage=" .. StorageConfig.Backend)
end

return TravelService
