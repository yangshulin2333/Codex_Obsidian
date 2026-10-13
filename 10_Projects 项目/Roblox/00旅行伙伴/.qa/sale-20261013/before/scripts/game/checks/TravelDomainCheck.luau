--!nonstrict

-- 在项目根目录用 Lune 0.10.5 执行；不启动 Studio，不接触真实玩家存档。
-- 加载同一份领域用例和实际 Excel 生成配置，只替换 Roblox 的 require/目录对象。
-- selene: allow(incorrect_standard_library_use)
local fs = require("@lune/fs")
-- selene: allow(incorrect_standard_library_use)
local luau = require("@lune/luau")

local function loadFile(path)
	assert(fs.isFile(path), "Run TravelDomainCheck.luau from the TravelBuddy project root: missing " .. path)
	return luau.load(fs.readFile(path), { debugName = path })()
end

local function moduleIdentity(module)
	return module
end

local domainPath = "src/ServerScriptService/Server/Game/Domain/TravelDomain.lua"
local Domain = loadFile(domainPath)
local casePath = "tests/UnitTest/Cases/TravelDomain_Test.lua"
local makeCase = luau.load("return function(game, require)\n" .. fs.readFile(casePath) .. "\nend", {
	debugName = casePath,
})()
local caseFunction = makeCase({
	ServerScriptService = { Server = { Game = { Domain = { TravelDomain = Domain } } } },
}, moduleIdentity)

local passed, failed = 0, 0
caseFunction({
	expect = {
		equal = function(actual, expected)
			assert(actual == expected, string.format("expected %s, got %s", tostring(expected), tostring(actual)))
		end,
		truthy = function(value)
			assert(value, "expected truthy")
		end,
		falsy = function(value)
			assert(not value, "expected falsy")
		end,
	},
	test = function(name, callback)
		local ok, problem = pcall(callback)
		if ok then
			passed += 1
			print("PASS " .. name)
		else
			failed += 1
			print("FAIL " .. name .. ": " .. tostring(problem))
		end
	end,
})
print(string.format("TravelDomain: %d passed, %d failed", passed, failed))
assert(failed == 0, "TravelDomain tests failed")

local generated = {}
for _, name in ipairs({
	"TravelSettings",
	"TravelItems",
	"TravelSeas",
	"TravelDurations",
	"TravelUpgrades",
	"TravelPostcards",
}) do
	generated[name] = loadFile("src/ReplicatedStorage/Game/Shared/Config/Generated/" .. name .. ".lua")
end
local weights = loadFile("src/ServerScriptService/Server/Game/Config/Generated/TravelWeights.lua")
local configPath = "src/ServerScriptService/Server/Game/Config/TravelConfig.lua"
local makeConfig = luau.load("return function(game, script, require)\n" .. fs.readFile(configPath) .. "\nend", {
	debugName = configPath,
})()
local config = makeConfig({
	GetService = function()
		return { Game = { Shared = { Config = { Generated = generated } } } }
	end,
}, { Parent = { Generated = { TravelWeights = weights } } }, moduleIdentity)

local domain, nextId = Domain.new(config), 0
local data = domain:NewData()
local context = {
	TimeScale = 1,
	Random = {
		NextInteger = function(_self, minimum)
			return minimum
		end,
	},
	NewId = function()
		nextId += 1
		return "guid_" .. nextId
	end,
}
local function apply(action, payload, now)
	domain:Advance(data, now or 0, context)
	payload.OperationId = "op_" .. (data.Revision + 1)
	payload.ExpectedRevision = data.Revision
	local ok, code = domain:Apply(data, action, payload, now or 0, context)
	assert(ok, "Generated config smoke failed: " .. code)
end

assert(domain:Validate(data), "Generated config does not create valid new data")
assert(data.Version == 4 and data.WarehouseSupplies == 3 and data.PackedSupplies == 0, "New saves must not auto pack")
assert(config.Settings.BagCapacity == 3, "Demo bag capacity must be three")
apply("PackSupply", { Quantity = 2 }, 0)
apply("UnpackSupply", { Quantity = 1 }, 0)
assert(data.WarehouseSupplies == 2 and data.PackedSupplies == 1, "Bag transfer did not conserve supplies")
assert(data.Plan and data.Plan.ReadyAt == 30, "First preparation must save a thirty-second deadline")
assert(data.PackedSupplies == 1, "Preparation must not spend supplies before departure")
assert(domain:Advance(data, 30, context), "First autonomous departure did not start")
assert(
	data.Journey.StartAt == 30 and data.Journey.EndAt == 90 and data.Journey.Container.Items.item_old_book == 3,
	"Tutorial must last 60 seconds with unmultiplied rewards"
)
assert(data.PackedSupplies == 0, "Autonomous departure must spend exactly one packed supply")
assert(domain:Advance(data, 90, context), "First voyage must settle automatically without a claim request")
assert(data.Journey.Status == "Settled" and data.RestUntil == 270, "Return must start rest at the saved arrival time")
assert(domain:Public(data, 90).State == "Returning", "Asset settlement must not skip the return animation window")
assert(domain:Public(data, 95).State == "Resting", "Docked partner must rest before preparing again")
apply("MarkReturnRead", { JourneyId = data.Journey.Id }, 90)
assert(not domain:Public(data, 90).HasUnreadReturn, "Viewing returns must only clear the unread marker")
apply("OpenContainer", { ContainerId = data.Containers[1].Id }, 90)
apply("SellAll", {}, 90)
assert(data.Coins == 49 and data.Wood == 6, "Generated prices or container wood mismatch")
apply("Upgrade", { Target = "Ship" }, 95)
assert(data.Coins == 9 and data.Wood == 0 and data.Upgrades.Ship.EndAt == 215, "Ship upgrade cost or duration mismatch")
assert(domain:Advance(data, 215, context), "Offline ship upgrade did not complete")
assert(config.SeasById.near.RequiredShipLevel == data.ShipLevel, "Ship upgrade must unlock the near sea")
apply("PackSupply", { Quantity = 1 }, 270)
local plan = data.Plan
assert(plan and plan.ReadyAt >= 330 and plan.ReadyAt <= 450, "Production preparation must be sixty to 180 seconds")
local duration = config.DurationsById[plan.DurationId]
assert(config.SeasById[plan.SeaId].RequiredShipLevel <= data.ShipLevel, "Plan chose a locked sea")
assert(domain:Advance(data, plan.ReadyAt, context), "Second autonomous departure did not start")
assert(
	data.Journey.EndAt == plan.ReadyAt + duration.Seconds
		and data.Journey.Container.Items.item_old_book == 3 * duration.YieldMultiplier
		and data.Journey.SpecialQuantity == duration.YieldMultiplier,
	"Autonomous voyage time or multiplier mismatch"
)
assert(data.Journey.Container.Wood == 2, "Long voyages must retain exactly two container wood")
assert(domain:Validate(data), "Generated config smoke left invalid data")
print("Generated config + supply bag + autonomous preparation + first loop + ship unlock + second voyage: PASS")
