--!nonstrict

-- 纯领域模块：时间、随机数和 ID 均由服务端注入，不访问玩家、Remote 或 Storage。
local TravelDomain = {}
TravelDomain.__index = TravelDomain

local MAX_INTEGER = 9007199254740991
local DECISION_MODULUS = 2147483647
local ACTION_FIELDS = {
	BuySupply = { Quantity = "quantity" },
	PackSupply = { Quantity = "quantity" },
	UnpackSupply = { Quantity = "quantity" },
	PauseTravel = {},
	ResumeTravel = {},
	MarkReturnRead = { JourneyId = "id" },
	OpenContainer = { ContainerId = "id" },
	SellItem = { ItemId = "id", Quantity = "quantity" },
	SellAll = {},
	Upgrade = { Target = "id" },
	ClaimRelief = {},
}

local function finite(value)
	return type(value) == "number" and value == value and value > -math.huge and value < math.huge
end

local function integer(value, minimum)
	return finite(value) and value >= minimum and value <= MAX_INTEGER and value % 1 == 0
end

local function validId(value)
	return type(value) == "string" and #value > 0 and #value <= 80 and string.find(value, "%S") ~= nil
end

local function copy(value)
	if type(value) ~= "table" then
		return value
	end
	local result = {}
	for key, entry in pairs(value) do
		result[key] = copy(entry)
	end
	return result
end

local function validArray(value)
	if type(value) ~= "table" then
		return false
	end
	local count = 0
	for key in pairs(value) do
		if not integer(key, 1) then
			return false
		end
		count += 1
	end
	return count == #value
end

local function fingerprint(action, payload)
	local keys = {}
	for key in pairs(payload) do
		if key ~= "OperationId" and key ~= "ExpectedRevision" then
			table.insert(keys, key)
		end
	end
	table.sort(keys)
	local parts = { action }
	for _, key in ipairs(keys) do
		local value = payload[key]
		local encoded = if type(value) == "number" then string.format("%.17g", value) else value
		table.insert(parts, string.format("%d:%s=%d:%s", #key, key, #encoded, encoded))
	end
	return table.concat(parts, "|")
end

local function validatePayload(action, payload)
	local fields = ACTION_FIELDS[action]
	if fields == nil or type(payload) ~= "table" or not validId(payload.OperationId) then
		return false
	end
	for key, value in pairs(payload) do
		if key == "ExpectedRevision" then
			if not integer(value, 0) then
				return false
			end
		elseif key ~= "OperationId" then
			local fieldType = fields[key]
			if fieldType == nil then
				return false
			end
			if fieldType == "quantity" and not integer(value, 1) then
				return false
			end
			if fieldType == "id" and not validId(value) then
				return false
			end
		end
	end
	for key in pairs(fields) do
		if payload[key] == nil then
			return false
		end
	end
	if action == "Upgrade" and payload.Target ~= "Home" and payload.Target ~= "Ship" then
		return false
	end
	return true
end

local function unopenedCount(data)
	return #data.Containers
end

local function journeyActive(data)
	return data.Journey ~= nil and data.Journey.Status ~= "Claimed" and data.Journey.Status ~= "Settled"
end

local function addItem(data, itemId, quantity)
	data.Inventory[itemId] = (data.Inventory[itemId] or 0) + quantity
	data.DiscoveredItems[itemId] = true
end

local function drawWeighted(random, weights)
	local total = 0
	for _, row in ipairs(weights) do
		total += row.Weight
	end
	local picked = random:NextInteger(1, total)
	for _, row in ipairs(weights) do
		picked -= row.Weight
		if picked <= 0 then
			return row.Quality
		end
	end
	error("quality weights have no outcome")
end

local function newId(context)
	local id = context.NewId()
	assert(validId(id), "NewId must return a non-empty ID of at most 80 characters")
	return id
end

local function scaledSeconds(seconds, timeScale)
	return math.max(1, math.floor(seconds * timeScale + 0.5))
end

function TravelDomain.new(config)
	assert(type(config) == "table", "TravelDomain requires server config")
	return setmetatable({ _config = config }, TravelDomain)
end

function TravelDomain:NewData()
	local settings = self._config.Settings
	return {
		Version = 4,
		Revision = 0,
		Coins = settings.InitialCoins,
		Wood = settings.InitialWood,
		WarehouseSupplies = settings.InitialSupplies,
		PackedSupplies = 0,
		HomeLevel = 1,
		ShipLevel = 1,
		Inventory = {},
		Containers = {},
		Postcards = {},
		DiscoveredItems = {},
		OpenedQualities = {},
		Journey = nil,
		Plan = nil,
		ManualPaused = false,
		DecisionSerial = 0,
		DecisionRandomState = 0,
		RestUntil = 0,
		LatestReturn = nil,
		ReturnReadId = nil,
		Upgrades = {},
		FirstJourney = true,
		Receipts = {},
		ReceiptOrder = {},
	}
end

-- 只迁移已经完整通过旧版校验的业务存档，不补坏档，也不再次扣除旧航次补给。
function TravelDomain:Migrate(data)
	if type(data) ~= "table" then
		return false, "INVALID_DATA", false
	end
	if data.Version == 4 then
		local valid = self:Validate(data)
		return valid, if valid then "OK" else "INVALID_DATA", false
	end
	if
		(data.Version ~= 1 and data.Version ~= 2 and data.Version ~= 3) or not self:_validateVersion(data, data.Version)
	then
		return false, "INVALID_DATA", false
	end
	local steps = 4 - data.Version
	if not integer(data.Revision + steps, 0) then
		return false, "INVALID_DATA", false
	end
	local candidate = copy(data)
	if candidate.Version == 1 then
		candidate.WarehouseSupplies = candidate.Supplies
		candidate.PackedSupplies = 0
		candidate.Supplies = nil
	end
	if candidate.Version < 3 then
		candidate.Plan = nil
		candidate.ManualPaused = false
		candidate.DecisionSerial = 0
		candidate.DecisionRandomState = 0
	end
	-- 已领取的旧航次只有状态改名，不重新给资产，也不重置它原有的休息时间。
	if candidate.Journey and candidate.Journey.Status == "Claimed" then
		candidate.Journey.Status = "Settled"
	end
	candidate.Version = 4
	candidate.Revision += steps
	if not self:Validate(candidate) then
		return false, "INVALID_DATA", false
	end
	for key in pairs(data) do
		data[key] = nil
	end
	for key, value in pairs(candidate) do
		data[key] = value
	end
	return true, "MIGRATED", true
end

function TravelDomain:CanManageBag(data, now)
	if not finite(now) or now < 0 then
		return false
	end
	local journey = data.Journey
	if journey then
		-- 资产在 EndAt 已入库，行囊操作仍等待同一返航动画窗口结束。
		local returnSeconds =
			math.max(0.5, math.min(self._config.Settings.ReturnSeconds, (journey.EndAt - journey.StartAt) / 3))
		if now < journey.EndAt + returnSeconds then
			return false
		end
	end
	return true
end

-- 只用于伙伴决策的持久随机流。重进、暂停和清空行囊不会重新选择路线。
function TravelDomain:_decisionDraw(data, context, minimum, maximum)
	if data.DecisionRandomState == 0 then
		data.DecisionRandomState = context.Random:NextInteger(1, DECISION_MODULUS - 1)
		assert(
			integer(data.DecisionRandomState, 1) and data.DecisionRandomState < DECISION_MODULUS,
			"Invalid decision seed"
		)
	end
	data.DecisionRandomState = (data.DecisionRandomState * 48271) % DECISION_MODULUS
	return minimum + data.DecisionRandomState % (maximum - minimum + 1)
end

function TravelDomain:_choose(data, context, rows)
	local total = 0
	for _, row in ipairs(rows) do
		assert(integer(row.Weight, 0), "Invalid autonomous choice weight")
		total += row.Weight
	end
	assert(integer(total, 1), "Autonomous choices have no legal outcome")
	local picked = self:_decisionDraw(data, context, 1, total)
	for _, row in ipairs(rows) do
		picked -= row.Weight
		if picked <= 0 then
			return row.Id
		end
	end
	error("autonomous weights have no outcome")
end

function TravelDomain:_waitingReason(data, now)
	if journeyActive(data) then
		return "JOURNEY_ACTIVE"
	elseif not self:CanManageBag(data, now) then
		return "NOT_DOCKED"
	elseif data.ManualPaused then
		return "MANUAL_PAUSED"
	elseif data.Upgrades.Ship then
		return "SHIP_UPGRADING"
	elseif now < data.RestUntil then
		return "RESTING"
	elseif data.PackedSupplies < self._config.Settings.SupplyCost then
		return "NO_PACKED_SUPPLIES"
	elseif unopenedCount(data) >= self._config.HomeCapacityByLevel[data.HomeLevel] then
		return "CONTAINER_FULL"
	end
	return nil
end

function TravelDomain:_prepareSeconds(data, context)
	local settings = self._config.Settings
	if data.FirstJourney then
		assert(integer(settings.FirstPrepareSeconds, 1), "Invalid first preparation time")
		return settings.FirstPrepareSeconds
	end
	local minimum = if context.IsStudio then settings.StudioPrepareMinSeconds else settings.PrepareMinSeconds
	local maximum = if context.IsStudio then settings.StudioPrepareMaxSeconds else settings.PrepareMaxSeconds
	assert(integer(minimum, 1) and integer(maximum, minimum), "Invalid preparation window")
	return self:_decisionDraw(data, context, minimum, maximum)
end

function TravelDomain:_createPlan(data, now, context)
	local seas = {}
	for id, sea in pairs(self._config.SeasById) do
		if sea.RequiredShipLevel <= data.ShipLevel then
			table.insert(seas, { Id = id, Weight = self._config.Settings["SeaChoiceWeight_" .. id] })
		end
	end
	table.sort(seas, function(left, right)
		return left.Id < right.Id
	end)
	local seaId = self:_choose(data, context, seas)
	local durations = {}
	for id, duration in pairs(self._config.DurationsById) do
		if duration.SeaId == seaId then
			local kind = string.match(id, "_(%a+)$")
			assert(kind == "short" or kind == "long", "Duration choice must use a short or long ID")
			table.insert(durations, {
				Id = id,
				Weight = self._config.Settings[if kind == "short" then "ShortChoiceWeight" else "LongChoiceWeight"],
			})
		end
	end
	table.sort(durations, function(left, right)
		return left.Id < right.Id
	end)
	local durationId = self:_choose(data, context, durations)
	data.DecisionSerial += 1
	data.Plan = {
		Id = newId(context),
		SeaId = seaId,
		DurationId = durationId,
		CreatedAt = now,
		ReadyAt = nil,
	}
end

-- 同一存档事务中把预约箱位换为封箱，并保存永久结算标识。
-- 与模型、靠岸动画、玩家是否查看收获无关；Settled 的航次永远不会再次发奖。
function TravelDomain:_settleJourney(data, context)
	local journey = data.Journey
	if journey == nil or not journeyActive(data) then
		return false
	end
	local timeScale = if context then context.TimeScale or 1 else 1
	assert(finite(timeScale) and timeScale > 0, "Invalid return settlement time scale")
	local restSeconds = journey.RestSeconds or scaledSeconds(self._config.Settings.RestSeconds, timeScale)
	local container = journey.Container
	assert(container ~= nil, "Unsettled journey has no reserved container")
	assert(unopenedCount(data) < self._config.HomeCapacityByLevel[data.HomeLevel], "Reserved container slot missing")
	assert(
		integer((data.Inventory[journey.SpecialItemId] or 0) + journey.SpecialQuantity, 1),
		"Special quantity overflow"
	)
	assert(integer((data.Postcards[journey.PostcardId] or 0) + 1, 1), "Postcard quantity overflow")
	assert(finite(journey.EndAt + restSeconds), "Return rest deadline overflow")
	table.insert(data.Containers, container)
	addItem(data, journey.SpecialItemId, journey.SpecialQuantity)
	data.Postcards[journey.PostcardId] = (data.Postcards[journey.PostcardId] or 0) + 1
	data.LatestReturn = {
		JourneyId = journey.Id,
		ContainerId = container.Id,
		SeaId = journey.SeaId,
		DurationId = journey.DurationId,
		ReturnedAt = journey.EndAt,
		PostcardId = journey.PostcardId,
		SpecialItemId = journey.SpecialItemId,
		SpecialQuantity = journey.SpecialQuantity,
	}
	journey.RestSeconds = restSeconds
	journey.Status = "Settled"
	journey.Container = nil
	data.RestUntil = journey.EndAt + restSeconds
	return true
end

function TravelDomain:Advance(data, now, context)
	if not finite(now) or now < 0 then
		return false
	end
	local changed = false
	if journeyActive(data) and now >= data.Journey.EndAt then
		changed = self:_settleJourney(data, context)
	end
	for _, facility in ipairs({ "Home", "Ship" }) do
		local upgrade = data.Upgrades[facility]
		if upgrade and now >= upgrade.EndAt then
			data[facility .. "Level"] = upgrade.TargetLevel
			data.Upgrades[facility] = nil
			changed = true
		end
	end
	if data.RestUntil > 0 and now >= data.RestUntil then
		data.RestUntil = 0
		changed = true
	end
	-- 没有注入决策上下文时只兼容旧读时钟，不替玩家生成新计划。
	if context then
		local waiting = self:_waitingReason(data, now)
		if waiting then
			if data.Plan and data.Plan.ReadyAt ~= nil then
				data.Plan.ReadyAt = nil
				changed = true
			end
		else
			if not data.Plan then
				self:_createPlan(data, now, context)
				changed = true
			end
			if data.Plan.ReadyAt == nil then
				data.Plan.ReadyAt = now + self:_prepareSeconds(data, context)
				changed = true
			elseif now >= data.Plan.ReadyAt then
				local ok, code = self:_perform(data, "__StartJourney", data.Plan, data.Plan.ReadyAt, context)
				assert(ok, "Autonomous departure failed: " .. tostring(code))
				data.Plan = nil
				-- 上线已经越过归家时间时，仍沿保存的出发时刻完成本趟。
				if now >= data.Journey.EndAt then
					self:_settleJourney(data, context)
					if now >= data.RestUntil then
						data.RestUntil = 0
					end
					-- 本阶段只补完这一趟；下一趟从当前加载时刻准备，后续再接离线多趟。
					if self:_waitingReason(data, now) == nil then
						self:_createPlan(data, now, context)
						data.Plan.ReadyAt = now + self:_prepareSeconds(data, context)
					end
				end
				changed = true
			end
		end
	end
	if changed then
		data.Revision += 1
	end
	return changed
end

function TravelDomain:_perform(data, action, payload, now, context)
	local config = self._config
	local settings = config.Settings
	local timeScale = context.TimeScale or 1
	if not finite(timeScale) or timeScale <= 0 then
		return false, "INVALID_CONTEXT"
	end
	if action == "BuySupply" then
		local price = settings.SupplyPrice * payload.Quantity
		if not integer(price, 1) or not integer(data.WarehouseSupplies + data.PackedSupplies + payload.Quantity, 0) then
			return false, "INVALID_QUANTITY"
		end
		if data.Coins < price then
			return false, "NOT_ENOUGH_COINS"
		end
		data.Coins -= price
		data.WarehouseSupplies += payload.Quantity
		return true, "OK", { Quantity = payload.Quantity, Paid = price }
	elseif action == "PackSupply" or action == "UnpackSupply" then
		if not self:CanManageBag(data, now) then
			return false, "BAG_READ_ONLY"
		end
		local quantity = payload.Quantity
		if action == "PackSupply" then
			if data.WarehouseSupplies < quantity then
				return false, "NOT_ENOUGH_WAREHOUSE_SUPPLIES"
			end
			if data.PackedSupplies + quantity > settings.BagCapacity then
				return false, "BAG_FULL"
			end
			data.WarehouseSupplies -= quantity
			data.PackedSupplies += quantity
		else
			if data.PackedSupplies < quantity then
				return false, "NOT_ENOUGH_PACKED_SUPPLIES"
			end
			data.PackedSupplies -= quantity
			data.WarehouseSupplies += quantity
		end
		return true,
			"OK",
			{
				Quantity = quantity,
				WarehouseSupplies = data.WarehouseSupplies,
				PackedSupplies = data.PackedSupplies,
			}
	elseif action == "PauseTravel" or action == "ResumeTravel" then
		if not self:CanManageBag(data, now) then
			return false, "BAG_READ_ONLY"
		end
		data.ManualPaused = action == "PauseTravel"
		return true, "OK", { ManualPaused = data.ManualPaused }
	elseif action == "MarkReturnRead" then
		if data.LatestReturn == nil or data.LatestReturn.JourneyId ~= payload.JourneyId then
			return false, "RETURN_NOT_FOUND"
		end
		data.ReturnReadId = payload.JourneyId
		return true, "OK", { JourneyId = payload.JourneyId }
	elseif action == "__StartJourney" then
		local sea = config.SeasById[payload.SeaId]
		local duration = config.DurationsById[payload.DurationId]
		if sea == nil or duration == nil or duration.SeaId ~= payload.SeaId then
			return false, "INVALID_DESTINATION"
		end
		if data.ShipLevel < sea.RequiredShipLevel then
			return false, "SEA_LOCKED"
		end
		if journeyActive(data) then
			return false, "JOURNEY_ACTIVE"
		end
		if data.Upgrades.Ship then
			return false, "SHIP_UPGRADING"
		end
		if now < data.RestUntil then
			return false, "RESTING"
		end
		if unopenedCount(data) >= config.HomeCapacityByLevel[data.HomeLevel] then
			return false, "CONTAINER_FULL"
		end
		if data.PackedSupplies < settings.SupplyCost then
			return false, "NOT_ENOUGH_PACKED_SUPPLIES"
		end
		local quality = drawWeighted(context.Random, config.WeightsBySea[sea.Id])
		local pool = config.ItemPoolsByQuality[quality]
		local multiplier = if data.FirstJourney then 1 else duration.YieldMultiplier
		local rewards = {}
		for _ = 1, settings.ItemsPerContainer do
			local itemId = pool[context.Random:NextInteger(1, #pool)]
			rewards[itemId] = (rewards[itemId] or 0) + multiplier
		end
		local postcards = config.PostcardsBySea[sea.Id]
		local journeyId = newId(context)
		local containerId = newId(context)
		if journeyId == containerId then
			return false, "INVALID_CONTEXT"
		end
		for _, container in ipairs(data.Containers) do
			if container.Id == containerId or container.JourneyId == journeyId then
				return false, "INVALID_CONTEXT"
			end
		end
		if data.Journey and data.Journey.Id == journeyId then
			return false, "INVALID_CONTEXT"
		end
		local seconds = if data.FirstJourney then settings.FirstJourneySeconds else duration.Seconds
		data.Journey = {
			Id = journeyId,
			SeaId = sea.Id,
			DurationId = duration.Id,
			PlanId = payload.Id,
			StartAt = now,
			EndAt = now + scaledSeconds(seconds, timeScale),
			RestSeconds = scaledSeconds(settings.RestSeconds, timeScale),
			Status = "Voyaging",
			Container = {
				Id = containerId,
				SeaId = sea.Id,
				Quality = quality,
				Items = rewards,
				Wood = settings.ContainerWood,
				JourneyId = journeyId,
			},
			PostcardId = postcards[context.Random:NextInteger(1, #postcards)],
			SpecialItemId = config.SpecialItems[context.Random:NextInteger(1, #config.SpecialItems)],
			SpecialQuantity = multiplier,
		}
		data.FirstJourney = false
		data.PackedSupplies -= settings.SupplyCost
		return true, "OK", { JourneyId = journeyId, EndAt = data.Journey.EndAt }
	elseif action == "OpenContainer" then
		local target = nil
		local targetIndex = nil
		for index, container in ipairs(data.Containers) do
			if container.Id == payload.ContainerId then
				target = container
				targetIndex = index
				break
			end
		end
		if target == nil then
			return false, "CONTAINER_NOT_FOUND"
		end
		local rewards = copy(target.Items)
		for itemId, quantity in pairs(rewards) do
			addItem(data, itemId, quantity)
		end
		data.Wood += target.Wood
		data.OpenedQualities[target.Quality] = true
		table.remove(data.Containers, targetIndex)
		return true, "OK", { ContainerId = target.Id, Quality = target.Quality, Items = rewards, Wood = target.Wood }
	elseif action == "SellItem" then
		local item = config.ItemsById[payload.ItemId]
		if item == nil then
			return false, "ITEM_NOT_FOUND"
		end
		if (item.Kind ~= "Commodity" and item.Kind ~= "Special") or not integer(item.SellPrice, 1) then
			return false, "ITEM_NOT_SELLABLE"
		end
		local owned = data.Inventory[payload.ItemId] or 0
		if owned < payload.Quantity then
			return false, "NOT_ENOUGH_ITEMS"
		end
		local coins = item.SellPrice * payload.Quantity
		if not integer(coins, 1) or not integer(data.Coins + coins, 0) then
			return false, "INVALID_QUANTITY"
		end
		data.Inventory[payload.ItemId] = if owned == payload.Quantity then nil else owned - payload.Quantity
		data.Coins += coins
		return true, "OK", { ItemId = payload.ItemId, Quantity = payload.Quantity, Coins = coins }
	elseif action == "SellAll" then
		-- 批量出售只覆盖普通商品；特产由玩家逐项选择，不能被一键清空。
		local coins, soldQuantity, soldItems = 0, 0, {}
		for itemId, quantity in pairs(data.Inventory) do
			local item = config.ItemsById[itemId]
			if item.Kind == "Commodity" and integer(item.SellPrice, 1) then
				coins += item.SellPrice * quantity
				soldQuantity += quantity
				soldItems[itemId] = quantity
			end
		end
		if coins == 0 then
			return false, "NO_ITEMS"
		end
		if not integer(coins, 1) or not integer(soldQuantity, 1) or not integer(data.Coins + coins, 0) then
			return false, "INVALID_QUANTITY"
		end
		for itemId in pairs(soldItems) do
			data.Inventory[itemId] = nil
		end
		data.Coins += coins
		return true, "OK", { Coins = coins, Quantity = soldQuantity, Items = soldItems }
	elseif action == "Upgrade" then
		local facility = payload.Target
		if facility ~= "Home" and facility ~= "Ship" then
			return false, "INVALID_FACILITY"
		end
		if data.Upgrades[facility] then
			return false, "UPGRADE_ACTIVE"
		end
		if facility == "Ship" and (journeyActive(data) or not self:CanManageBag(data, now)) then
			return false, "SHIP_AWAY"
		end
		local targetLevel = data[facility .. "Level"] + 1
		local upgrade = config.UpgradesByFacility[facility][targetLevel]
		if upgrade == nil then
			return false, "MAX_LEVEL"
		end
		if data.Coins < upgrade.CoinCost then
			return false, "NOT_ENOUGH_COINS"
		end
		if data.Wood < upgrade.WoodCost then
			return false, "NOT_ENOUGH_WOOD"
		end
		if
			data.WarehouseSupplies + data.PackedSupplies < settings.SupplyCost
			and data.Coins - upgrade.CoinCost < settings.SupplyPrice
		then
			return false, "KEEP_SUPPLY_RESERVE"
		end
		data.Upgrades[facility] = {
			Id = newId(context),
			TargetLevel = targetLevel,
			EndAt = now + scaledSeconds(upgrade.Seconds, timeScale),
		}
		data.Coins -= upgrade.CoinCost
		data.Wood -= upgrade.WoodCost
		return true, "OK", { Target = facility, TargetLevel = targetLevel, EndAt = data.Upgrades[facility].EndAt }
	elseif action == "ClaimRelief" then
		if
			data.Coins >= settings.SupplyPrice
			or data.WarehouseSupplies > 0
			or data.PackedSupplies > 0
			or next(data.Inventory) ~= nil
			or unopenedCount(data) > 0
			or journeyActive(data)
		then
			return false, "RELIEF_NOT_AVAILABLE"
		end
		data.WarehouseSupplies = settings.SupplyCost
		return true, "OK", { WarehouseSupplies = settings.SupplyCost }
	end
	return false, "INVALID_REQUEST"
end

function TravelDomain:Apply(data, action, payload, now, context)
	if not finite(now) or now < 0 or not validatePayload(action, payload) then
		return false, "INVALID_REQUEST"
	end
	local valid = self:Validate(data)
	if not valid then
		return false, "INVALID_DATA"
	end
	local intent = fingerprint(action, payload)
	local previous = data.Receipts[payload.OperationId]
	if previous then
		if previous.Fingerprint ~= intent then
			return false, "OPERATION_CONFLICT"
		end
		return true, "REPLAYED", copy(previous.Result)
	end
	-- 到期推进独立于请求成败；同一时刻的旧版暂停请求不能把出发回滚。
	self:Advance(data, now, context)
	if payload.ExpectedRevision ~= nil and payload.ExpectedRevision ~= data.Revision then
		return false, "STALE_STATE"
	end
	-- 成功前只改副本；坏数量、满箱、重放和升级失败不会留下部分扣款。
	local candidate = copy(data)
	local ok, code, result = self:_perform(candidate, action, payload, now, context or {})
	if not ok then
		return false, code
	end
	self:Advance(candidate, now, context)
	candidate.Revision += 1
	candidate.Receipts[payload.OperationId] = { Fingerprint = intent, Result = copy(result) }
	table.insert(candidate.ReceiptOrder, payload.OperationId)
	while #candidate.ReceiptOrder > self._config.Settings.ReceiptLimit do
		local expired = table.remove(candidate.ReceiptOrder, 1)
		candidate.Receipts[expired] = nil
	end
	local validCandidate = self:Validate(candidate)
	if not validCandidate then
		return false, "INVALID_RESULT"
	end
	for key in pairs(data) do
		data[key] = nil
	end
	for key, value in pairs(candidate) do
		data[key] = value
	end
	return true, code, copy(result)
end

function TravelDomain:Public(data, now)
	local state = "HomeIdle"
	if data.Journey and now < data.Journey.EndAt then
		state = "Voyaging"
	elseif data.Journey and not self:CanManageBag(data, now) then
		state = "Returning"
	elseif now < data.RestUntil then
		state = "Resting"
	elseif data.Plan and data.Plan.ReadyAt ~= nil then
		state = "Preparing"
	end
	local result = {
		State = state,
		Version = data.Version,
		Revision = data.Revision,
		Coins = data.Coins,
		Wood = data.Wood,
		WarehouseSupplies = data.WarehouseSupplies,
		PackedSupplies = data.PackedSupplies,
		BagCapacity = self._config.Settings.BagCapacity,
		CanManageBag = self:CanManageBag(data, now),
		HomeLevel = data.HomeLevel,
		ShipLevel = data.ShipLevel,
		Inventory = copy(data.Inventory),
		Containers = {},
		Postcards = copy(data.Postcards),
		DiscoveredItems = copy(data.DiscoveredItems),
		OpenedQualities = copy(data.OpenedQualities),
		RestUntil = data.RestUntil,
		Upgrades = copy(data.Upgrades),
		FirstJourney = data.FirstJourney,
		ManualPaused = data.ManualPaused,
		WaitingReason = self:_waitingReason(data, now),
		ServerNow = now,
		ContainerCapacity = self._config.HomeCapacityByLevel[data.HomeLevel],
		UnopenedCount = unopenedCount(data),
		ReservedContainers = if journeyActive(data) then 1 else 0,
		HasUnreadReturn = data.LatestReturn ~= nil and data.ReturnReadId ~= data.LatestReturn.JourneyId,
	}
	if data.LatestReturn then
		local returned = data.LatestReturn
		result.LatestReturn = {
			JourneyId = returned.JourneyId,
			ContainerId = returned.ContainerId,
			SeaId = returned.SeaId,
			DurationId = returned.DurationId,
			ReturnedAt = returned.ReturnedAt,
			PostcardId = returned.PostcardId,
			SpecialItemId = returned.SpecialItemId,
			SpecialQuantity = returned.SpecialQuantity,
		}
	end
	if data.Plan then
		result.Plan = {
			Id = data.Plan.Id,
			SeaId = data.Plan.SeaId,
			DurationId = data.Plan.DurationId,
			CreatedAt = data.Plan.CreatedAt,
			ReadyAt = data.Plan.ReadyAt,
		}
	end
	for _, container in ipairs(data.Containers) do
		local visible = {
			Id = container.Id,
			SeaId = container.SeaId,
			JourneyId = container.JourneyId,
		}
		table.insert(result.Containers, visible)
	end
	if data.Journey then
		result.Journey = {
			Id = data.Journey.Id,
			SeaId = data.Journey.SeaId,
			DurationId = data.Journey.DurationId,
			StartAt = data.Journey.StartAt,
			EndAt = data.Journey.EndAt,
			Status = data.Journey.Status,
		}
	end
	return result
end

function TravelDomain:Validate(data)
	return self:_validateVersion(data, 4)
end

function TravelDomain:_validateVersion(data, version)
	local config = self._config
	if type(data) ~= "table" or data.Version ~= version then
		return false, "invalid version"
	end
	for _, key in ipairs({ "Revision", "Coins", "Wood" }) do
		if not integer(data[key], 0) then
			return false, "invalid " .. key
		end
	end
	if version == 1 then
		if not integer(data.Supplies, 0) or data.WarehouseSupplies ~= nil or data.PackedSupplies ~= nil then
			return false, "invalid legacy supplies"
		end
	else
		if
			data.Supplies ~= nil
			or not integer(data.WarehouseSupplies, 0)
			or not integer(data.PackedSupplies, 0)
			or data.PackedSupplies > config.Settings.BagCapacity
			or not integer(data.WarehouseSupplies + data.PackedSupplies, 0)
		then
			return false, "invalid supplies"
		end
	end
	if not integer(data.HomeLevel, 1) or config.HomeCapacityByLevel[data.HomeLevel] == nil then
		return false, "invalid HomeLevel"
	end
	if not integer(data.ShipLevel, 1) or data.ShipLevel > config.MaxShipLevel then
		return false, "invalid ShipLevel"
	end
	if not finite(data.RestUntil) or data.RestUntil < 0 or type(data.FirstJourney) ~= "boolean" then
		return false, "invalid time or first journey"
	end
	if version < 4 then
		if data.LatestReturn ~= nil or data.ReturnReadId ~= nil then
			return false, "conflicting automatic return data"
		end
	else
		if data.ReturnReadId ~= nil and (not validId(data.ReturnReadId) or data.LatestReturn == nil) then
			return false, "invalid read return ID"
		end
		if data.LatestReturn ~= nil then
			local returned = data.LatestReturn
			local fields = {
				JourneyId = true,
				ContainerId = true,
				SeaId = true,
				DurationId = true,
				ReturnedAt = true,
				PostcardId = true,
				SpecialItemId = true,
				SpecialQuantity = true,
			}
			if type(returned) ~= "table" then
				return false, "invalid latest return"
			end
			for key in pairs(returned) do
				if not fields[key] then
					return false, "unknown latest return field"
				end
			end
			local postcard = config.PostcardsById[returned.PostcardId]
			local special = config.ItemsById[returned.SpecialItemId]
			local duration = if returned.DurationId then config.DurationsById[returned.DurationId] else nil
			if
				not validId(returned.JourneyId)
				or not validId(returned.ContainerId)
				or config.SeasById[returned.SeaId] == nil
				or not finite(returned.ReturnedAt)
				or returned.ReturnedAt < 0
				or postcard == nil
				or postcard.SeaId ~= returned.SeaId
				or special == nil
				or special.Kind ~= "Special"
				or not integer(returned.SpecialQuantity, 1)
				or (returned.DurationId ~= nil and (duration == nil or duration.SeaId ~= returned.SeaId))
			then
				return false, "invalid latest return"
			end
		end
	end
	if version < 3 then
		if
			data.Plan ~= nil
			or data.ManualPaused ~= nil
			or data.DecisionSerial ~= nil
			or data.DecisionRandomState ~= nil
		then
			return false, "conflicting autonomous data"
		end
	else
		if
			type(data.ManualPaused) ~= "boolean"
			or not integer(data.DecisionSerial, 0)
			or not integer(data.DecisionRandomState, 0)
			or data.DecisionRandomState >= DECISION_MODULUS
		then
			return false, "invalid autonomous fields"
		end
		if data.Plan ~= nil then
			local plan = data.Plan
			local sea = if type(plan) == "table" then config.SeasById[plan.SeaId] else nil
			local duration = if type(plan) == "table" then config.DurationsById[plan.DurationId] else nil
			if
				type(plan) ~= "table"
				or not validId(plan.Id)
				or sea == nil
				or duration == nil
				or duration.SeaId ~= plan.SeaId
				or sea.RequiredShipLevel > data.ShipLevel
				or not finite(plan.CreatedAt)
				or plan.CreatedAt < 0
				or (plan.ReadyAt ~= nil and (not finite(plan.ReadyAt) or plan.ReadyAt < plan.CreatedAt))
				or data.DecisionSerial == 0
				or data.DecisionRandomState == 0
				or journeyActive(data)
			then
				return false, "invalid autonomous plan"
			end
			if data.ManualPaused and plan.ReadyAt ~= nil then
				return false, "paused plan has deadline"
			end
		end
	end
	for _, key in ipairs({ "Inventory", "Postcards", "DiscoveredItems", "OpenedQualities", "Upgrades", "Receipts" }) do
		if type(data[key]) ~= "table" then
			return false, "invalid " .. key
		end
	end
	for itemId, quantity in pairs(data.Inventory) do
		if config.ItemsById[itemId] == nil or not integer(quantity, 1) then
			return false, "invalid inventory item"
		end
	end
	for itemId, discovered in pairs(data.DiscoveredItems) do
		if config.ItemsById[itemId] == nil or discovered ~= true then
			return false, "invalid discovery"
		end
	end
	for quality, opened in pairs(data.OpenedQualities) do
		if config.ItemPoolsByQuality[quality] == nil or opened ~= true then
			return false, "invalid opened quality"
		end
	end
	if not validArray(data.Containers) or not validArray(data.ReceiptOrder) then
		return false, "invalid history array"
	end
	local seenContainers = {}
	local seenJourneys = {}
	local function validContainer(container)
		if
			type(container) ~= "table"
			or not validId(container.Id)
			or not validId(container.JourneyId)
			or config.SeasById[container.SeaId] == nil
			or config.ItemPoolsByQuality[container.Quality] == nil
			or not integer(container.Wood, 0)
		then
			return false
		end
		if type(container.Items) ~= "table" or next(container.Items) == nil then
			return false
		end
		for itemId, quantity in pairs(container.Items) do
			local item = config.ItemsById[itemId]
			if
				item == nil
				or item.Kind ~= "Commodity"
				or item.Quality ~= container.Quality
				or not integer(quantity, 1)
			then
				return false
			end
		end
		return true
	end
	for _, container in ipairs(data.Containers) do
		if not validContainer(container) or seenContainers[container.Id] or seenJourneys[container.JourneyId] then
			return false, "invalid or duplicate container"
		end
		if
			version == 4
			and data.LatestReturn
			and container.JourneyId == data.LatestReturn.JourneyId
			and (container.Id ~= data.LatestReturn.ContainerId or container.SeaId ~= data.LatestReturn.SeaId)
		then
			return false, "latest return container mismatch"
		end
		seenContainers[container.Id] = true
		seenJourneys[container.JourneyId] = true
	end
	if data.Journey ~= nil then
		local journey = data.Journey
		if
			type(journey) ~= "table"
			or not validId(journey.Id)
			or config.SeasById[journey.SeaId] == nil
			or not finite(journey.StartAt)
			or journey.StartAt < 0
			or not finite(journey.EndAt)
			or journey.EndAt < journey.StartAt
			or (
				journey.Status ~= "Voyaging"
				and journey.Status ~= "Returned"
				and journey.Status ~= (if version < 4 then "Claimed" else "Settled")
			)
		then
			return false, "invalid journey"
		end
		if journey.DurationId ~= nil then
			local duration = config.DurationsById[journey.DurationId]
			if duration == nil or duration.SeaId ~= journey.SeaId then
				return false, "invalid journey duration"
			end
		end
		if journey.PlanId ~= nil and not validId(journey.PlanId) then
			return false, "invalid journey plan ID"
		end
		if journey.RestSeconds ~= nil and (version < 4 or not integer(journey.RestSeconds, 1)) then
			return false, "invalid journey rest snapshot"
		end
		if journey.Status == "Claimed" or journey.Status == "Settled" then
			if journey.Container ~= nil then
				return false, "invalid claimed journey"
			end
		else
			if
				not validContainer(journey.Container)
				or journey.Container.JourneyId ~= journey.Id
				or journey.Container.SeaId ~= journey.SeaId
				or seenContainers[journey.Container.Id]
				or seenJourneys[journey.Id]
			then
				return false, "invalid journey container"
			end
		end
		local postcard = config.PostcardsById[journey.PostcardId]
		local specialItem = config.ItemsById[journey.SpecialItemId]
		if
			postcard == nil
			or postcard.SeaId ~= journey.SeaId
			or specialItem == nil
			or specialItem.Kind ~= "Special"
			or not integer(journey.SpecialQuantity, 1)
		then
			return false, "invalid journey rewards"
		end
		if version == 4 and data.LatestReturn and data.LatestReturn.JourneyId == journey.Id then
			local returned = data.LatestReturn
			if
				journey.Status ~= "Settled"
				or returned.SeaId ~= journey.SeaId
				or returned.DurationId ~= journey.DurationId
				or returned.ReturnedAt ~= journey.EndAt
				or returned.PostcardId ~= journey.PostcardId
				or returned.SpecialItemId ~= journey.SpecialItemId
				or returned.SpecialQuantity ~= journey.SpecialQuantity
			then
				return false, "latest return journey mismatch"
			end
		end
	end
	if unopenedCount(data) + (if journeyActive(data) then 1 else 0) > config.HomeCapacityByLevel[data.HomeLevel] then
		return false, "container capacity exceeded"
	end
	for postcardId, quantity in pairs(data.Postcards) do
		if config.PostcardsById[postcardId] == nil or not integer(quantity, 1) then
			return false, "invalid postcard"
		end
	end
	for facility, upgrade in pairs(data.Upgrades) do
		if facility ~= "Home" and facility ~= "Ship" then
			return false, "invalid facility"
		end
		if
			type(upgrade) ~= "table"
			or not validId(upgrade.Id)
			or not integer(upgrade.TargetLevel, 2)
			or upgrade.TargetLevel ~= data[facility .. "Level"] + 1
			or config.UpgradesByFacility[facility][upgrade.TargetLevel] == nil
			or not finite(upgrade.EndAt)
			or upgrade.EndAt < 0
		then
			return false, "invalid upgrade"
		end
	end
	if data.Upgrades.Ship and journeyActive(data) then
		return false, "ship upgrade while away"
	end
	if #data.ReceiptOrder > config.Settings.ReceiptLimit then
		return false, "too many receipts"
	end
	local seenReceipts = {}
	for _, operationId in ipairs(data.ReceiptOrder) do
		local receipt = data.Receipts[operationId]
		if
			not validId(operationId)
			or seenReceipts[operationId]
			or type(receipt) ~= "table"
			or type(receipt.Fingerprint) ~= "string"
			or type(receipt.Result) ~= "table"
		then
			return false, "invalid receipt"
		end
		seenReceipts[operationId] = true
	end
	for operationId in pairs(data.Receipts) do
		if not seenReceipts[operationId] then
			return false, "receipt missing order"
		end
	end
	return true, "OK"
end

return TravelDomain
