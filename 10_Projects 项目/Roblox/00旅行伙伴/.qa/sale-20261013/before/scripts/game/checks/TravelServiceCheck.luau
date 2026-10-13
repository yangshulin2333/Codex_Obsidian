-- 本地联调：真实 Game Service + Domain + Config + 框架 StorageService/MemoryStorage。
-- 用确定时钟和网络/世界替身检查请求边界；不代表 Studio 或 DataStore 实测。
local fs = require("@lune/fs")
local luau = require("@lune/luau")
local serde = require("@lune/serde")

local now = 100000
local studio = true
local sequence = 0
local warnings = {}
local logger = {
	Info = function() end,
	Debug = function() end,
	Warn = function(_, message)
		table.insert(warnings, message)
	end,
}
local players = {}
local generated = {}
for _, name in ipairs({
	"TravelSettings",
	"TravelItems",
	"TravelSeas",
	"TravelDurations",
	"TravelUpgrades",
	"TravelPostcards",
	"Images",
}) do
	generated[name] = "src/ReplicatedStorage/Game/Shared/Config/Generated/" .. name .. ".lua"
end
local paths = {
	Domain = "src/ServerScriptService/Server/Game/Domain/TravelDomain.lua",
	Config = "src/ServerScriptService/Server/Game/Config/TravelConfig.lua",
	Service = "src/ServerScriptService/Server/Game/Services/TravelService.lua",
	Storage = "src/ServerScriptService/Server/Framework/Services/StorageService.lua",
	Memory = "src/ReplicatedStorage/Framework/Shared/Storage/MemoryStorage.lua",
	TableUtil = "src/ReplicatedStorage/Framework/Shared/Util/TableUtil.lua",
	StorageConfig = "src/ReplicatedStorage/Module/Shared/Config/StorageConfig.lua",
	NetResult = "src/ReplicatedStorage/Framework/Shared/Net/NetResult.lua",
	Protocol = "src/ReplicatedStorage/Game/Shared/TravelProtocol.lua",
}
local replicated = {
	Framework = {
		Shared = {
			Net = { NetResult = paths.NetResult },
			Util = { TableUtil = paths.TableUtil },
			Storage = { MemoryStorage = paths.Memory },
		},
	},
	Module = { Shared = { Config = { StorageConfig = paths.StorageConfig } } },
	Game = { Shared = { TravelProtocol = paths.Protocol, Config = { Generated = generated } } },
}
local services = {
	Players = players,
	ReplicatedStorage = replicated,
	HttpService = {
		GenerateGUID = function()
			sequence += 1
			return "server-id-" .. sequence
		end,
	},
	RunService = {
		IsStudio = function()
			return studio
		end,
	},
}
local clock = table.clone(os)
clock.time = function()
	return now
end
local cache = {}
local loadModule
loadModule = function(path)
	if path == "ProfileStoreStub" then
		return {}
	end
	if cache[path] ~= nil then
		return cache[path]
	end
	local scriptNode = { Parent = { Parent = {} } }
	if path == paths.Config then
		scriptNode.Parent.Generated =
			{ TravelWeights = "src/ServerScriptService/Server/Game/Config/Generated/TravelWeights.lua" }
	elseif path == paths.Service then
		scriptNode.Parent.Parent =
			{ Domain = { TravelDomain = paths.Domain }, Config = { TravelConfig = paths.Config } }
	elseif path == paths.Storage then
		scriptNode.Parent.Parent = { Storage = { ProfileStoreStorage = "ProfileStoreStub" } }
	elseif path == paths.Memory then
		scriptNode.Parent.Parent = { Util = { TableUtil = paths.TableUtil } }
	end
	local module = luau.load(fs.readFile(path), {
		debugName = path,
		injectGlobals = true,
		environment = {
			require = loadModule,
			script = scriptNode,
			os = clock,
			game = {
				GetService = function(_, name)
					return assert(services[name], name)
				end,
			},
			Random = {
				new = function()
					return {
						NextInteger = function(_, low)
							return low
						end,
					}
				end,
			},
			task = {
				spawn = function(callback, ...)
					callback(...)
				end,
			},
		},
	})()
	cache[path] = module
	return module
end

local storage = loadModule(paths.Storage)
local memory = loadModule(paths.Memory)
local storageConfig = loadModule(paths.StorageConfig)
storage._storage = memory.new(storageConfig.DefaultData, storageConfig.Validate)
storage._logger = logger
local world = { Assigned = {}, Allow = true, Broken = false, LastInteraction = nil }
function world:Assign(player)
	self.Assigned[player] = "Plot" .. tostring(player.UserId)
	return self.Assigned[player]
end
function world:GetPlotId(player)
	return self.Assigned[player]
end
function world:GetSpawnCFrame()
	return nil
end
function world:Render()
	assert(not self.Broken, "broken visual template")
end
function world:CanInteract(_, interaction)
	self.LastInteraction = interaction
	return self.Allow
end
function world:Release(player)
	self.Assigned[player] = nil
end
local pushes = {}
local net = {
	EnsureServerEvent = function() end,
	FireClient = function(_, _, player, state)
		pushes[player] = state
	end,
}
local service = loadModule(paths.Service)
service:Init({ Logger = logger, Services = { StorageService = storage, NetService = net, TravelWorldService = world } })
local function player(id)
	return {
		UserId = id,
		Name = "Tester" .. id,
		Parent = players,
		CharacterAdded = {
			Connect = function()
				return { Disconnect = function() end }
			end,
		},
		Kick = function(_, message)
			error("unexpected Kick: " .. message)
		end,
	}
end
local one, two = player(1), player(2)
assert(storage:OpenPlayer(one))
assert(storage:OpenPlayer(two))
service:_join(one)
service:_join(two)
local function read(target)
	local result = service:HandleRequest(target, { Action = "ReadState" })
	assert(result.Ok, result.Code)
	return result.Data.State
end
local function command(target, action, operationId, fields, revision)
	local payload = table.clone(fields or {})
	payload.Action = action
	payload.OperationId = operationId
	payload.ExpectedRevision = revision or read(target).Revision
	return service:HandleRequest(target, payload), payload
end
local function sameData(first, second)
	if type(first) ~= type(second) then
		return false
	end
	if type(first) ~= "table" then
		return first == second
	end
	for key, value in pairs(first) do
		if not sameData(value, second[key]) then
			return false
		end
	end
	for key in pairs(second) do
		if first[key] == nil then
			return false
		end
	end
	return true
end
local first = read(one)
assert(first.Coins == 30 and first.WarehouseSupplies == 3 and first.PackedSupplies == 0 and first.Wood == 4)
assert(first.Version == 4 and first.BagCapacity == 3 and first.CanManageBag and first.Supplies == nil)
assert(first.LatestReturn == nil and not first.HasUnreadReturn)
assert(first.FirstJourneySeconds == 3 and first.IsStudio)
assert(first.State == "HomeIdle" and first.Plan == nil and first.WaitingReason == "NO_PACKED_SUPPLIES")
assert(not service:HandleRequest(player(3), { Action = "ReadState" }).Ok)
assert(service:HandleRequest(one, { Action = "ReadState", Extra = 1 }).Code == "INVALID_REQUEST")
assert(
	service:HandleRequest(one, { Action = "BuySupply", OperationId = "nested", ExpectedRevision = 0, Quantity = {} }).Code
		== "INVALID_REQUEST"
)
assert(
	service:HandleRequest(one, { Action = "BuySupply", OperationId = "nan", ExpectedRevision = 0, Quantity = 0 / 0 }).Code
		== "INVALID_REQUEST"
)
assert(
	service:HandleRequest(
		one,
		{ Action = "BuySupply", OperationId = string.rep("x", 81), ExpectedRevision = 0, Quantity = 1 }
	).Code == "INVALID_REQUEST"
)
world.Allow = false
assert(command(one, "BuySupply", "far", { Quantity = 1 }).Code == "TOO_FAR")
assert(read(one).Coins == 30)
world.Allow = true
local bought, purchase = command(one, "BuySupply", "buy", { Quantity = 1 })
assert(bought.Ok and bought.Data.State.Coins == 25 and bought.Data.State.WarehouseSupplies == 4)
assert(bought.Data.State.PackedSupplies == 0, "buying supplies must not automatically pack")
world.Allow = false
assert(service:HandleRequest(one, purchase).Ok, "committed operation replay must work away from facility")
assert(read(one).Coins == 25 and read(one).WarehouseSupplies == 4 and read(one).PackedSupplies == 0)
local conflicting = table.clone(purchase)
conflicting.Quantity = 2
assert(service:HandleRequest(one, conflicting).Code == "OPERATION_CONFLICT")
world.Allow = true
assert(command(one, "BuySupply", "stale", { Quantity = 1 }, 0).Code == "STALE_STATE")
assert(
	read(two).Coins == 30 and read(two).WarehouseSupplies == 3 and read(two).PackedSupplies == 0,
	"account isolation"
)

assert(
	command(one, "StartJourney", "empty-bag", { SeaId = "shallow", DurationId = "shallow_short" }).Code
		== "INVALID_REQUEST",
	"the old manual dispatch request must be unavailable"
)
for index, quantity in ipairs({ 0, -1, 1.5, math.huge, 0 / 0, {}, "1" }) do
	assert(command(one, "PackSupply", "invalid-pack-" .. index, { Quantity = quantity }).Code == "INVALID_REQUEST")
	assert(command(one, "UnpackSupply", "invalid-unpack-" .. index, { Quantity = quantity }).Code == "INVALID_REQUEST")
end
assert(command(one, "PackSupply", "missing-pack").Code == "INVALID_REQUEST")
world.Allow = false
assert(command(one, "PackSupply", "far-pack", { Quantity = 1 }).Code == "TOO_FAR")
assert(command(one, "UnpackSupply", "far-unpack", { Quantity = 1 }).Code == "TOO_FAR")
assert(world.LastInteraction == "Bag", "both bag actions must bind to the personal preparation facility")
world.Allow = true
local packed, packRequest = command(one, "PackSupply", "pack", { Quantity = 2 })
assert(packed.Ok and packed.Data.State.WarehouseSupplies == 2 and packed.Data.State.PackedSupplies == 2)
local originalPlan = packed.Data.State.Plan
assert(packed.Data.State.State == "Preparing" and originalPlan.SeaId == "shallow")
assert(originalPlan.ReadyAt - now == 30, "the first preparation uses 30 real seconds in Studio")
assert(packed.Data.State.Journey == nil, "preparation cannot charge a voyage")
for _ = 1, 3 do
	local samePlan = read(one)
	assert(samePlan.Plan.Id == originalPlan.Id and samePlan.Plan.ReadyAt == originalPlan.ReadyAt)
	assert(samePlan.Plan.DurationId == originalPlan.DurationId and samePlan.PackedSupplies == 2)
end
world.Allow = false
assert(service:HandleRequest(one, packRequest).Ok, "committed pack replay remains valid away from facility")
assert(read(one).WarehouseSupplies == 2 and read(one).PackedSupplies == 2, "pack retry cannot transfer twice")
local packConflict = table.clone(packRequest)
packConflict.Quantity = 1
assert(service:HandleRequest(one, packConflict).Code == "OPERATION_CONFLICT")
world.Allow = true
local unpacked, unpackRequest = command(one, "UnpackSupply", "unpack", { Quantity = 1 })
assert(unpacked.Ok and unpacked.Data.State.WarehouseSupplies == 3 and unpacked.Data.State.PackedSupplies == 1)
world.Allow = false
assert(service:HandleRequest(one, unpackRequest).Ok, "committed unpack replay remains valid away from facility")
assert(read(one).WarehouseSupplies == 3 and read(one).PackedSupplies == 1)
world.Allow = true
assert(command(one, "PackSupply", "fill", { Quantity = 2 }).Ok)
assert(command(one, "PackSupply", "overflow", { Quantity = 1 }).Code == "BAG_FULL")
assert(read(one).WarehouseSupplies == 1 and read(one).PackedSupplies == 3, "overflow must preserve both balances")
assert(command(one, "UnpackSupply", "over-unpack", { Quantity = 4 }).Code == "NOT_ENOUGH_PACKED_SUPPLIES")
assert(command(one, "UnpackSupply", "restore-bag", { Quantity = 2 }).Ok)
assert(read(one).Coins == 25 and read(one).WarehouseSupplies + read(one).PackedSupplies == 4)
assert(read(two).WarehouseSupplies == 3 and read(two).PackedSupplies == 0, "bag transfers stay within the account")

local bagArchive = serde.decode("json", serde.encode("json", storage:GetPlayerData(one)))
storage:ClosePlayer(one)
assert(storage:OpenPlayer(one))
storage:SetPlayerData(one, bagArchive)
local bagRestored = read(one)
assert(bagRestored.Version == 4 and bagRestored.WarehouseSupplies == 3 and bagRestored.PackedSupplies == 1)
assert(bagRestored.Plan.Id == originalPlan.Id and bagRestored.Plan.ReadyAt == originalPlan.ReadyAt)
assert(service:HandleRequest(one, packRequest).Ok and service:HandleRequest(one, unpackRequest).Ok)
assert(read(one).WarehouseSupplies == 3 and read(one).PackedSupplies == 1, "saved receipts keep transfers idempotent")

world.Allow = false
assert(command(one, "PauseTravel", "far-pause").Code == "TOO_FAR")
assert(command(one, "ResumeTravel", "far-resume").Code == "TOO_FAR")
assert(world.LastInteraction == "Bag", "companion intervention belongs to the personal preparation table")
world.Allow = true
local paused, pauseRequest = command(one, "PauseTravel", "pause")
assert(paused.Ok and paused.Data.State.ManualPaused and paused.Data.State.Plan.ReadyAt == nil)
assert(paused.Data.State.Plan.Id == originalPlan.Id and paused.Data.State.PackedSupplies == 1)
now += 5
assert(command(one, "PauseTravel", "pause-again").Ok)
assert(read(one).Plan.Id == originalPlan.Id and read(one).ManualPaused, "repeated pauses cannot reroute")
local pausedArchive = serde.decode("json", serde.encode("json", storage:GetPlayerData(one)))
storage:ClosePlayer(one)
assert(storage:OpenPlayer(one))
storage:SetPlayerData(one, pausedArchive)
now = originalPlan.ReadyAt + 10
assert(read(one).ManualPaused and read(one).Plan.ReadyAt == nil, "manual pause survives reload")
assert(read(one).Journey == nil and read(one).PackedSupplies == 1, "offline time cannot bypass a saved manual pause")
world.Allow = false
assert(service:HandleRequest(one, pauseRequest).Ok, "committed pause replay works away from the facility")
world.Allow = true
local resumed, resumeRequest = command(one, "ResumeTravel", "resume")
assert(resumed.Ok and not resumed.Data.State.ManualPaused and resumed.Data.State.Plan.Id == originalPlan.Id)
assert(resumed.Data.State.Plan.ReadyAt == now + 30, "resume creates one fresh preparation deadline")
world.Allow = false
assert(service:HandleRequest(one, resumeRequest).Ok)
world.Allow = true
local resumedReadyAt = read(one).Plan.ReadyAt
now += 1
assert(command(one, "ResumeTravel", "resume-again").Ok)
assert(read(one).Plan.ReadyAt == resumedReadyAt, "repeated resume must not reset a running countdown")
assert(command(one, "UnpackSupply", "empty-before-departure", { Quantity = 1 }).Ok)
assert(read(one).Plan.Id == originalPlan.Id and read(one).Plan.ReadyAt == nil)
assert(read(one).WaitingReason == "NO_PACKED_SUPPLIES" and read(one).WarehouseSupplies == 4)
now += 1
local repacked = command(one, "PackSupply", "repack-before-departure", { Quantity = 1 })
assert(repacked.Ok and repacked.Data.State.Plan.Id == originalPlan.Id)
assert(repacked.Data.State.Plan.DurationId == originalPlan.DurationId)
local readyAt = repacked.Data.State.Plan.ReadyAt
assert(readyAt == now + 30, "repacking restarts only the wait")
now = readyAt - 1
assert(read(one).State == "Preparing" and read(one).PackedSupplies == 1)
now = readyAt
local atSea = read(one)
assert(atSea.State == "Voyaging" and atSea.Plan == nil)
assert(atSea.Journey.StartAt == readyAt, "the saved deadline is the authoritative departure time")
assert(atSea.Journey.EndAt - atSea.Journey.StartAt == 3, "tutorial time overrides long duration")
assert(atSea.DepartureSeconds == 1 and atSea.ReturnSeconds == 1)
assert(atSea.Journey.Container == nil and atSea.Journey.PostcardId == nil, "hidden reward snapshot")
assert(atSea.WarehouseSupplies == 3 and atSea.PackedSupplies == 0 and not atSea.CanManageBag)
assert(command(one, "PackSupply", "sea-pack", { Quantity = 1 }).Code == "BAG_READ_ONLY")
assert(command(one, "UnpackSupply", "sea-unpack", { Quantity = 1 }).Code == "BAG_READ_ONLY")
assert(command(one, "PauseTravel", "sea-pause").Code == "BAG_READ_ONLY")
assert(command(one, "ResumeTravel", "sea-resume").Code == "BAG_READ_ONLY")
local alreadyPaid = read(one)
assert(alreadyPaid.Journey.Id == atSea.Journey.Id and alreadyPaid.PackedSupplies == 0)

local legacyPlayer = player(3)
assert(storage:OpenPlayer(legacyPlayer))
local legacyArchive = serde.decode("json", serde.encode("json", storage:GetPlayerData(one)))
legacyArchive.Settings.Marker = "keep-settings"
legacyArchive.Modules.OtherGame = { Marker = "keep-module" }
local legacy = legacyArchive.Modules.TravelBuddy
legacy.Version = 1
legacy.Supplies = 7
legacy.WarehouseSupplies = nil
legacy.PackedSupplies = nil
legacy.Plan = nil
legacy.ManualPaused = nil
legacy.DecisionSerial = nil
legacy.DecisionRandomState = nil
legacy.LatestReturn = nil
legacy.ReturnReadId = nil
legacy.Journey.RestSeconds = nil
legacy.Revision = 28
local oldReceipts = {}
local oldOrder = {}
for _, operationId in ipairs({ "buy" }) do
	oldReceipts[operationId] = legacy.Receipts[operationId]
	table.insert(oldOrder, operationId)
end
oldReceipts["legacy-start"] = { Fingerprint = "legacy paid StartJourney", Result = { JourneyId = legacy.Journey.Id } }
table.insert(oldOrder, "legacy-start")
legacy.Receipts = oldReceipts
legacy.ReceiptOrder = oldOrder
local paidJourneyId = legacy.Journey.Id
local paidDeadline = legacy.Journey.EndAt
storage:SetPlayerData(legacyPlayer, legacyArchive)
service:_join(legacyPlayer)
local migrated = read(legacyPlayer)
assert(migrated.Version == 4 and migrated.WarehouseSupplies == 7 and migrated.PackedSupplies == 0)
assert(migrated.Revision == 31 and migrated.Journey.Id == paidJourneyId and migrated.Journey.EndAt == paidDeadline)
assert(migrated.Coins == 25 and migrated.Wood == 4, "legacy migration cannot charge an already paid journey")
local migratedArchive = storage:GetPlayerData(legacyPlayer)
assert(migratedArchive.Settings.Marker == "keep-settings" and migratedArchive.Modules.OtherGame.Marker == "keep-module")
assert(migratedArchive.Modules.TravelBuddy.Supplies == nil)
assert(service:HandleRequest(legacyPlayer, purchase).Ok, "legacy purchase receipt must survive migration")
assert(storage:GetPlayerModuleData(legacyPlayer, "TravelBuddy").Receipts["legacy-start"] ~= nil)
assert(
	command(legacyPlayer, "StartJourney", "legacy-start", { SeaId = "shallow", DurationId = "shallow_short" }).Code
		== "INVALID_REQUEST",
	"even an old dispatch receipt cannot reopen the removed remote action"
)
assert(read(legacyPlayer).WarehouseSupplies == 7 and read(legacyPlayer).Coins == 25)
assert(read(legacyPlayer).Revision == 31, "repeated reads must not migrate again")
storage:ClosePlayer(legacyPlayer)
assert(storage:OpenPlayer(legacyPlayer))
storage:SetPlayerData(legacyPlayer, migratedArchive)
assert(read(legacyPlayer).Revision == 31 and read(legacyPlayer).WarehouseSupplies == 7)

local legacyV2 = serde.decode("json", serde.encode("json", migratedArchive))
local moduleV2 = legacyV2.Modules.TravelBuddy
moduleV2.Version = 2
moduleV2.Plan = nil
moduleV2.ManualPaused = nil
moduleV2.DecisionSerial = nil
moduleV2.DecisionRandomState = nil
moduleV2.PackedSupplies = 2
moduleV2.Revision = 40
storage:SetPlayerData(legacyPlayer, legacyV2)
local migratedV2 = read(legacyPlayer)
assert(migratedV2.Version == 4 and migratedV2.Revision == 42)
assert(migratedV2.PackedSupplies == 2 and migratedV2.Journey.Id == paidJourneyId)
assert(migratedV2.Journey.EndAt == paidDeadline and migratedV2.Coins == 25, "v2 migration preserves the paid trip")

local legacyV3 = serde.decode("json", serde.encode("json", storage:GetPlayerData(legacyPlayer)))
local moduleV3 = legacyV3.Modules.TravelBuddy
moduleV3.Version = 3
moduleV3.LatestReturn = nil
moduleV3.ReturnReadId = nil
moduleV3.Journey.RestSeconds = nil
moduleV3.Revision = 50
storage:SetPlayerData(legacyPlayer, legacyV3)
local migratedV3 = read(legacyPlayer)
assert(migratedV3.Version == 4 and migratedV3.Revision == 51)
assert(migratedV3.PackedSupplies == 2 and migratedV3.Journey.Id == paidJourneyId)
assert(migratedV3.Journey.EndAt == paidDeadline and migratedV3.Coins == 25, "v3 migration preserves the paid trip")

now += 3
local docking = read(one)
assert(docking.State == "Returning" and not docking.CanManageBag, "automatic deposit precedes final docking window")
assert(docking.Journey.Status == "Settled" and #docking.Containers == 1 and docking.HasUnreadReturn)
assert(docking.Inventory.special_shell == 1 and docking.Postcards[docking.LatestReturn.PostcardId] == 1)
assert(docking.LatestReturn.JourneyId == atSea.Journey.Id and docking.LatestReturn.ReturnedAt == atSea.Journey.EndAt)
assert(docking.RestUntil == atSea.Journey.EndAt + 9, "Studio rest begins at actual arrival, not reward viewing")
assert(
	docking.Containers[1].Quality == nil and docking.Containers[1].Items == nil,
	"deposited box contents stay sealed"
)
assert(
	docking.LatestReturn.Quality == nil and docking.LatestReturn.Items == nil,
	"return summary cannot leak sealed contents"
)
for _ = 1, 3 do
	local unchanged = read(one)
	assert(unchanged.Revision == docking.Revision and #unchanged.Containers == 1)
	assert(unchanged.Inventory.special_shell == 1 and unchanged.Postcards[docking.LatestReturn.PostcardId] == 1)
end
assert(command(one, "PackSupply", "return-pack", { Quantity = 1 }).Code == "BAG_READ_ONLY")
assert(command(one, "UnpackSupply", "return-unpack", { Quantity = 1 }).Code == "BAG_READ_ONLY")
assert(
	command(one, "ClaimReturn", "old-claim", { JourneyId = docking.Journey.Id }).Code == "INVALID_REQUEST",
	"old manual claim cannot remain an alternative reward path"
)
world.Allow = false
world.LastInteraction = nil
assert(command(two, "MarkReturnRead", "foreign-return", { JourneyId = docking.Journey.Id }).Code == "RETURN_NOT_FOUND")
local viewed, viewRequest = command(one, "MarkReturnRead", "view-return", { JourneyId = docking.Journey.Id })
assert(viewed.Ok and not viewed.Data.State.HasUnreadReturn, "viewing rewards is allowed away from facilities")
assert(world.LastInteraction == nil, "read acknowledgement must not require a physical interaction")
assert(viewed.Data.State.RestUntil == docking.RestUntil and #viewed.Data.State.Containers == 1)
assert(viewed.Data.State.Coins == docking.Coins and viewed.Data.State.Wood == docking.Wood)
assert(
	viewed.Data.State.Inventory.special_shell == 1 and viewed.Data.State.Postcards[docking.LatestReturn.PostcardId] == 1
)
assert(service:HandleRequest(one, viewRequest).Ok, "replaying the read acknowledgement cannot grant rewards")
assert(command(one, "MarkReturnRead", "unknown-return", { JourneyId = "other-journey" }).Code == "RETURN_NOT_FOUND")
local staleRead = table.clone(viewRequest)
staleRead.OperationId = "stale-return-read"
assert(
	service:HandleRequest(one, staleRead).Code == "STALE_STATE",
	"view acknowledgements still require current revision"
)
assert(command(one, "OpenContainer", "far-open", { ContainerId = docking.Containers[1].Id }).Code == "TOO_FAR")
world.Allow = true

local claimedLegacyArchive = serde.decode("json", serde.encode("json", storage:GetPlayerData(one)))
local claimedLegacy = claimedLegacyArchive.Modules.TravelBuddy
claimedLegacy.Version = 3
claimedLegacy.LatestReturn = nil
claimedLegacy.ReturnReadId = nil
claimedLegacy.Journey.RestSeconds = nil
claimedLegacy.Journey.Status = "Claimed"
claimedLegacy.Revision = 70
claimedLegacy.Receipts["legacy-return"] = {
	Fingerprint = "legacy ClaimReturn paid once",
	Result = { JourneyId = claimedLegacy.Journey.Id },
}
table.insert(claimedLegacy.ReceiptOrder, "legacy-return")
local legacyAssets = {
	Inventory = claimedLegacy.Inventory,
	Postcards = claimedLegacy.Postcards,
	Containers = claimedLegacy.Containers,
}
local oldRestUntil = claimedLegacy.RestUntil
storage:SetPlayerData(legacyPlayer, claimedLegacyArchive)
local alreadySettledLegacy = read(legacyPlayer)
assert(alreadySettledLegacy.Version == 4 and alreadySettledLegacy.Revision == 71)
assert(alreadySettledLegacy.Journey.Status == "Settled" and alreadySettledLegacy.RestUntil == oldRestUntil)
local settledLegacyModule = storage:GetPlayerModuleData(legacyPlayer, "TravelBuddy")
assert(sameData(settledLegacyModule.Inventory, legacyAssets.Inventory))
assert(sameData(settledLegacyModule.Postcards, legacyAssets.Postcards))
assert(sameData(settledLegacyModule.Containers, legacyAssets.Containers), "old claimed trips must not mint another box")
assert(settledLegacyModule.Receipts["legacy-return"] ~= nil, "old return receipts remain saved")
assert(
	command(legacyPlayer, "ClaimReturn", "legacy-return", { JourneyId = alreadySettledLegacy.Journey.Id }).Code
		== "INVALID_REQUEST",
	"an old claim receipt cannot reopen a retired remote action"
)

local pendingLegacyArchive = serde.decode("json", serde.encode("json", legacyV3))
local pendingLegacy = pendingLegacyArchive.Modules.TravelBuddy
pendingLegacy.Journey.Status = "Returned"
pendingLegacy.Revision = 80
local oldReservedBoxId = pendingLegacy.Journey.Container.Id
storage:SetPlayerData(legacyPlayer, pendingLegacyArchive)
local settledPendingLegacy = read(legacyPlayer)
assert(settledPendingLegacy.Version == 4 and settledPendingLegacy.Journey.Status == "Settled")
assert(settledPendingLegacy.Containers[1].Id == oldReservedBoxId and #settledPendingLegacy.Containers == 1)
assert(settledPendingLegacy.Inventory.special_shell == 1 and settledPendingLegacy.HasUnreadReturn)
assert(settledPendingLegacy.RestUntil == paidDeadline + 9)
assert(storage:GetPlayerModuleData(legacyPlayer, "TravelBuddy").Receipts["legacy-start"] ~= nil)
assert(read(legacyPlayer).Revision == settledPendingLegacy.Revision and #read(legacyPlayer).Containers == 1)

now += 1
local returned = read(one)
assert(returned.State == "Resting" and returned.CanManageBag and not returned.HasUnreadReturn)
local boxId = returned.Containers[1].Id
assert(command(two, "OpenContainer", "steal", { ContainerId = boxId }).Code == "CONTAINER_NOT_FOUND")
local opened, openRequest = command(one, "OpenContainer", "open", { ContainerId = boxId })
assert(opened.Ok and #opened.Data.State.Containers == 0 and opened.Data.State.Wood == 6)
world.Allow = false
assert(service:HandleRequest(one, openRequest).Ok, "retry survives removal of opened container")
assert(service:HandleRequest(one, viewRequest).Ok, "read acknowledgement survives later opening of its box")
local inventory = read(one).Inventory
assert(inventory.item_old_book == 3 and inventory.special_shell == 1)
assert(read(two).Wood == 4 and next(read(two).Inventory) == nil)
world.Allow = true
assert(command(one, "SellAll", "sell").Ok)
local sold = read(one)
assert(sold.Coins == 44 and next(sold.Inventory) == nil and sold.DiscoveredItems.item_old_book)
world.Broken = true
assert(read(one).Coins == 44, "visual errors must not kill committed state delivery")
assert(#warnings > 0)
world.Broken = false

now = sold.RestUntil
assert(command(one, "PackSupply", "offline-pack", { Quantity = 2 }).Ok)
local offlinePreparation = read(one)
assert(offlinePreparation.State == "Preparing" and offlinePreparation.Plan.ReadyAt >= now + 15)
assert(offlinePreparation.Plan.ReadyAt <= now + 30, "ordinary Studio preparation uses its own window")
local offlineReadyAt = offlinePreparation.Plan.ReadyAt
local offlineDuration = offlinePreparation.Durations[offlinePreparation.Plan.DurationId].Seconds
local archived = serde.decode("json", serde.encode("json", storage:GetPlayerData(one)))
storage:ClosePlayer(one)
assert(storage:OpenPlayer(one))
storage:SetPlayerData(one, archived)
now = offlineReadyAt + offlineDuration + 5
local restored = read(one)
assert(restored.State == "Resting", "absolute deadlines settle an offline voyage without a claim request")
assert(restored.Journey.StartAt == offlineReadyAt and restored.Journey.EndAt == offlineReadyAt + offlineDuration)
assert(restored.Coins == 44 and restored.HomeLevel == 1 and restored.ShipLevel == 1)
assert(restored.WarehouseSupplies == 1 and restored.PackedSupplies == 1)
assert(restored.Journey.Status == "Settled" and #restored.Containers == 1 and restored.HasUnreadReturn)
assert(restored.RestUntil == restored.Journey.EndAt + 9, "offline rest is measured from saved arrival time")
assert(
	restored.LatestReturn.JourneyId == restored.Journey.Id
		and restored.LatestReturn.ContainerId == restored.Containers[1].Id
)
local settledArchive = serde.decode("json", serde.encode("json", storage:GetPlayerData(one)))
storage:ClosePlayer(one)
assert(storage:OpenPlayer(one))
storage:SetPlayerData(one, settledArchive)
local replayedOffline = read(one)
assert(replayedOffline.PackedSupplies == 1 and #replayedOffline.Containers == 1)
assert(replayedOffline.Revision == restored.Revision and replayedOffline.HasUnreadReturn)
assert(sameData(replayedOffline.Inventory, restored.Inventory))
assert(sameData(replayedOffline.Postcards, restored.Postcards))
now = restored.RestUntil
local preparingAgain = read(one)
assert(preparingAgain.State == "Preparing" and preparingAgain.Plan.ReadyAt > now)
assert(preparingAgain.HasUnreadReturn and preparingAgain.LatestReturn.JourneyId == restored.Journey.Id)
assert(
	preparingAgain.PackedSupplies == 1 and #preparingAgain.Containers == 1,
	"viewing is not a gate for the next preparation"
)
local preparingAgainId = preparingAgain.Plan.Id
for _ = 1, 3 do
	assert(read(one).Plan.Id == preparingAgainId and read(one).PackedSupplies == 1)
end
local unreadAcknowledged = command(one, "MarkReturnRead", "offline-view", { JourneyId = restored.Journey.Id })
assert(unreadAcknowledged.Ok and not unreadAcknowledged.Data.State.HasUnreadReturn)
local readArchive = serde.decode("json", serde.encode("json", storage:GetPlayerData(one)))
storage:ClosePlayer(one)
assert(storage:OpenPlayer(one))
storage:SetPlayerData(one, readArchive)
assert(not read(one).HasUnreadReturn and read(one).Plan.Id == preparingAgainId, "saved read marker preserves next plan")

local beforeFailure = serde.decode("json", serde.encode("json", storage:GetPlayerData(two)))
local oldNewId = service._context.NewId
service._context.NewId = function()
	error("forced plan allocation failure")
end
local failedTransfer = command(two, "PackSupply", "atomic-pack", { Quantity = 1 })
service._context.NewId = oldNewId
assert(failedTransfer.Code == "DATA_UPDATE_FAILED", "failed domain updates must return a recoverable error")
assert(sameData(storage:GetPlayerData(two), beforeFailure), "failed preparation must roll back transfer and receipt")
assert(not service._busy[two] and read(two).WarehouseSupplies == 3 and read(two).PackedSupplies == 0)

local actualWait = storage.WaitForPlayerData
local slow = player(4)
assert(storage:OpenPlayer(slow))
local attempts = 0
storage.WaitForPlayerData = function(self, target, timeout)
	if target == slow then
		attempts += 1
		if attempts == 1 then
			return false, "DATA_READY_TIMEOUT"
		end
	end
	return actualWait(self, target, timeout)
end
service:_join(slow)
assert(attempts == 2 and service._ready[slow], "temporary loading timeout must be retried")
storage.WaitForPlayerData = actualWait
studio = false
local production = table.clone(service)
production:Init({
	Logger = logger,
	Services = { StorageService = storage, NetService = net, TravelWorldService = world },
})
assert(production:_snapshot(one, storage:GetPlayerModuleData(one, "TravelBuddy")).FirstJourneySeconds == 60)
assert(production._publicConfig.Durations.shallow_short.Seconds == 600)
assert(not production._context.IsStudio and production._context.TimeScale == 1)
print(
	"TRAVEL_SERVICE_OK: autonomous prepare/depart/settle, exact offline arrival/rest, duplicate settlement safety, persistent return read marker independent of next preparation, v1/v2/v3 migration without recharging, bag and facility boundaries, blocked manual dispatch/claim, account isolation, sealed reward privacy, failed update rollback, loading retry, visual fault isolation, production timing"
)
