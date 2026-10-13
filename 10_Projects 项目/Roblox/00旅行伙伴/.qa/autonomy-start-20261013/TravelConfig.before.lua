--!nonstrict

-- 只适配导表字段；生成文件由 Excel 工具维护，不能手改。
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local shared = ReplicatedStorage.Game.Shared.Config.Generated
local TravelSettings = require(shared.TravelSettings)
local TravelItems = require(shared.TravelItems)
local TravelSeas = require(shared.TravelSeas)
local TravelDurations = require(shared.TravelDurations)
local TravelUpgrades = require(shared.TravelUpgrades)
local TravelPostcards = require(shared.TravelPostcards)
local TravelWeights = require(script.Parent.Generated.TravelWeights)

local function positiveInteger(value)
	return type(value) == "number" and value > 0 and value < math.huge and value % 1 == 0
end

local function sortedRows(rows)
	local list = {}
	for id, row in pairs(rows) do
		assert(type(id) == "string" and row.Id == id, "Travel config row ID mismatch")
		table.insert(list, row)
	end
	table.sort(list, function(left, right)
		if (left.Order or 0) == (right.Order or 0) then
			return left.Id < right.Id
		end
		return (left.Order or 0) < (right.Order or 0)
	end)
	return list
end

local config = {
	Settings = {},
	ItemsById = {},
	ItemPoolsByQuality = { Common = {}, Life = {}, Fine = {} },
	SpecialItems = {},
	SeasById = {},
	DurationsById = {},
	UpgradesByFacility = { Home = {}, Ship = {} },
	PostcardsById = {},
	PostcardsBySea = {},
	WeightsBySea = {},
	HomeCapacityByLevel = {},
	MaxShipLevel = 1,
}

for _, row in ipairs(sortedRows(TravelSettings)) do
	assert(
		type(row.Value) == "number" and row.Value == row.Value and math.abs(row.Value) < math.huge,
		"Invalid setting"
	)
	config.Settings[row.Id] = row.Value
	local capacityLevel = string.match(row.Id, "^HomeCapacity(%d+)$")
	if capacityLevel then
		assert(positiveInteger(row.Value), "Home capacity must be a positive integer")
		config.HomeCapacityByLevel[tonumber(capacityLevel)] = row.Value
	end
end

for _, key in ipairs({
	"SupplyPrice",
	"SupplyCost",
	"BagCapacity",
	"FirstJourneySeconds",
	"RestSeconds",
	"ContainerWood",
	"ItemsPerContainer",
	"ReceiptLimit",
}) do
	assert(positiveInteger(config.Settings[key]), "Missing or invalid TravelSettings: " .. key)
end
for _, key in ipairs({ "InitialCoins", "InitialWood", "InitialSupplies" }) do
	local value = config.Settings[key]
	assert(type(value) == "number" and value >= 0 and value < math.huge and value % 1 == 0, "Invalid " .. key)
end
assert(config.HomeCapacityByLevel[1], "Missing initial home capacity")
assert(positiveInteger(config.Settings.MaxPlayers), "MaxPlayers must be a positive integer")
for _, key in ipairs({
	"TickSeconds",
	"RequestCooldown",
	"StudioTimeScale",
	"ProductionTimeScale",
	"DataReadyTimeout",
	"RequestTimeout",
	"DepartureSeconds",
	"ReturnSeconds",
}) do
	local value = config.Settings[key]
	assert(type(value) == "number" and value > 0 and value < math.huge, "Missing or invalid " .. key)
end

for _, row in ipairs(sortedRows(TravelItems)) do
	assert(positiveInteger(row.Price), "Item price must be a positive integer")
	config.ItemsById[row.Id] = {
		Id = row.Id,
		Name = row.Name,
		Kind = row.Kind,
		Quality = row.Quality,
		SellPrice = row.Price,
	}
	if row.Kind == "Special" then
		assert(row.Quality == "Special", "Special item quality must be Special")
		table.insert(config.SpecialItems, row.Id)
	else
		assert(row.Kind == "Commodity" and config.ItemPoolsByQuality[row.Quality], "Invalid commodity quality")
		table.insert(config.ItemPoolsByQuality[row.Quality], row.Id)
	end
end
assert(#config.SpecialItems > 0, "Missing special items")
for _, pool in pairs(config.ItemPoolsByQuality) do
	assert(#pool > 0, "Commodity pool cannot be empty")
end

for _, row in ipairs(sortedRows(TravelSeas)) do
	assert(positiveInteger(row.ShipLevel), "Invalid sea ship level")
	config.SeasById[row.Id] = { Id = row.Id, RequiredShipLevel = row.ShipLevel }
	config.PostcardsBySea[row.Id] = {}
	config.WeightsBySea[row.Id] = {}
end

for _, row in ipairs(sortedRows(TravelDurations)) do
	assert(config.SeasById[row.SeaId], "Duration references unknown sea")
	assert(positiveInteger(row.Seconds) and positiveInteger(row.YieldMultiplier), "Invalid journey duration")
	config.DurationsById[row.Id] = {
		Id = row.Id,
		SeaId = row.SeaId,
		Seconds = row.Seconds,
		YieldMultiplier = row.YieldMultiplier,
	}
end

for _, row in ipairs(sortedRows(TravelUpgrades)) do
	assert(config.UpgradesByFacility[row.Target], "Unknown upgrade target")
	assert(positiveInteger(row.Level) and row.Level > 1 and positiveInteger(row.Seconds), "Invalid upgrade")
	assert(positiveInteger(row.Coins) and positiveInteger(row.Wood), "Invalid upgrade cost")
	assert(config.UpgradesByFacility[row.Target][row.Level] == nil, "Duplicate target upgrade level")
	config.UpgradesByFacility[row.Target][row.Level] = {
		TargetLevel = row.Level,
		CoinCost = row.Coins,
		WoodCost = row.Wood,
		Seconds = row.Seconds,
	}
	if row.Target == "Ship" then
		config.MaxShipLevel = math.max(config.MaxShipLevel, row.Level)
	else
		assert(config.HomeCapacityByLevel[row.Level], "Missing home capacity for upgrade")
	end
end

for _, row in ipairs(sortedRows(TravelPostcards)) do
	assert(config.SeasById[row.SeaId], "Postcard references unknown sea")
	config.PostcardsById[row.Id] = row
	table.insert(config.PostcardsBySea[row.SeaId], row.Id)
end

for _, row in ipairs(sortedRows(TravelWeights)) do
	assert(config.SeasById[row.SeaId] and config.ItemPoolsByQuality[row.Quality], "Invalid quality weight")
	assert(
		type(row.Weight) == "number" and row.Weight >= 0 and row.Weight < math.huge and row.Weight % 1 == 0,
		"Invalid quality weight"
	)
	table.insert(config.WeightsBySea[row.SeaId], { Quality = row.Quality, Weight = row.Weight })
end
for seaId, weights in pairs(config.WeightsBySea) do
	local total = 0
	local qualities = {}
	for _, row in ipairs(weights) do
		assert(not qualities[row.Quality], "Duplicate sea quality weight")
		qualities[row.Quality] = true
		total += row.Weight
	end
	assert(total > 0 and total < math.huge, "Sea quality weights have no outcome")
	assert(#config.PostcardsBySea[seaId] > 0, "Sea has no postcards")
	assert(config.SeasById[seaId].RequiredShipLevel <= config.MaxShipLevel, "Sea cannot be unlocked")
end

return config
