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
local first = read(one)
assert(first.Coins == 30 and first.WarehouseSupplies == 3 and first.PackedSupplies == 0 and first.Wood == 4)
assert(first.Version == 2 and first.BagCapacity == 3 and first.CanManageBag and first.Supplies == nil)
assert(first.FirstJourneySeconds == 3 and first.IsStudio)
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
		== "NOT_ENOUGH_PACKED_SUPPLIES"
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
assert(bagRestored.Version == 2 and bagRestored.WarehouseSupplies == 3 and bagRestored.PackedSupplies == 1)
assert(service:HandleRequest(one, packRequest).Ok and service:HandleRequest(one, unpackRequest).Ok)
assert(read(one).WarehouseSupplies == 3 and read(one).PackedSupplies == 1, "saved receipts keep transfers idempotent")

local voyage = command(one, "StartJourney", "voyage", { SeaId = "shallow", DurationId = "shallow_long" })
assert(voyage.Ok)
local atSea = voyage.Data.State
assert(atSea.Journey.EndAt - atSea.Journey.StartAt == 3, "tutorial time overrides long duration")
assert(atSea.DepartureSeconds == 1 and atSea.ReturnSeconds == 1)
assert(atSea.Journey.Container == nil and atSea.Journey.PostcardId == nil, "hidden reward snapshot")
assert(atSea.WarehouseSupplies == 3 and atSea.PackedSupplies == 0 and not atSea.CanManageBag)
assert(command(one, "PackSupply", "sea-pack", { Quantity = 1 }).Code == "BAG_READ_ONLY")
assert(command(one, "UnpackSupply", "sea-unpack", { Quantity = 1 }).Code == "BAG_READ_ONLY")

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
legacy.Revision = 28
local oldReceipts = {}
local oldOrder = {}
for _, operationId in ipairs({ "buy", "voyage" }) do
	oldReceipts[operationId] = legacy.Receipts[operationId]
	table.insert(oldOrder, operationId)
end
legacy.Receipts = oldReceipts
legacy.ReceiptOrder = oldOrder
local paidJourneyId = legacy.Journey.Id
local paidDeadline = legacy.Journey.EndAt
storage:SetPlayerData(legacyPlayer, legacyArchive)
service:_join(legacyPlayer)
local migrated = read(legacyPlayer)
assert(migrated.Version == 2 and migrated.WarehouseSupplies == 7 and migrated.PackedSupplies == 0)
assert(migrated.Revision == 29 and migrated.Journey.Id == paidJourneyId and migrated.Journey.EndAt == paidDeadline)
assert(migrated.Coins == 25 and migrated.Wood == 4, "legacy migration cannot charge an already paid journey")
local migratedArchive = storage:GetPlayerData(legacyPlayer)
assert(migratedArchive.Settings.Marker == "keep-settings" and migratedArchive.Modules.OtherGame.Marker == "keep-module")
assert(migratedArchive.Modules.TravelBuddy.Supplies == nil)
assert(service:HandleRequest(legacyPlayer, purchase).Ok, "legacy purchase receipt must survive migration")
assert(read(legacyPlayer).WarehouseSupplies == 7 and read(legacyPlayer).Coins == 25)
assert(read(legacyPlayer).Revision == 29, "repeated reads must not migrate again")
storage:ClosePlayer(legacyPlayer)
assert(storage:OpenPlayer(legacyPlayer))
storage:SetPlayerData(legacyPlayer, migratedArchive)
assert(read(legacyPlayer).Revision == 29 and read(legacyPlayer).WarehouseSupplies == 7)

now += 3
assert(
	read(one).State == "ReturnPending" and not read(one).CanManageBag,
	"logical return precedes final docking window"
)
assert(command(one, "PackSupply", "return-pack", { Quantity = 1 }).Code == "BAG_READ_ONLY")
assert(command(one, "UnpackSupply", "return-unpack", { Quantity = 1 }).Code == "BAG_READ_ONLY")
now += 1
local returned = read(one)
assert(returned.State == "ReturnPending")
local claimed, claimRequest = command(one, "ClaimReturn", "claim", { JourneyId = returned.Journey.Id })
assert(claimed.Ok and #claimed.Data.State.Containers == 1)
assert(claimed.Data.State.Containers[1].Quality == nil and claimed.Data.State.Containers[1].Items == nil)
local boxId = claimed.Data.State.Containers[1].Id
assert(command(two, "OpenContainer", "steal", { ContainerId = boxId }).Code == "CONTAINER_NOT_FOUND")
local opened, openRequest = command(one, "OpenContainer", "open", { ContainerId = boxId })
assert(opened.Ok and #opened.Data.State.Containers == 0 and opened.Data.State.Wood == 6)
world.Allow = false
assert(service:HandleRequest(one, openRequest).Ok, "retry survives removal of opened container")
assert(service:HandleRequest(one, claimRequest).Ok, "retry does not duplicate return rewards")
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

now += 3
assert(command(one, "PackSupply", "offline-pack", { Quantity = 1 }).Ok)
assert(command(one, "StartJourney", "offline", { SeaId = "shallow", DurationId = "shallow_short" }).Ok)
local archived = serde.decode("json", serde.encode("json", storage:GetPlayerData(one)))
storage:ClosePlayer(one)
assert(storage:OpenPlayer(one))
storage:SetPlayerData(one, archived)
now += 31
local restored = read(one)
assert(restored.State == "ReturnPending", "absolute deadline catches up after offline serialization reload")
assert(restored.Coins == 44 and restored.HomeLevel == 1 and restored.ShipLevel == 1)
assert(restored.WarehouseSupplies == 2 and restored.PackedSupplies == 0)
assert(command(one, "ClaimReturn", "offline-claim", { JourneyId = restored.Journey.Id }).Ok)

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
print(
	"TRAVEL_SERVICE_OK: bag transfers and limits, personal facility boundary, serialized v2 reload, v1 migration and receipt preservation, sea/docking read-only, requests, real StorageService copies, account isolation, hidden rewards, replay after removal, offline reload, loading retry, visual fault isolation, production timing"
)
