--!nonstrict

-- 假时钟、可控随机数和 ID；不进入 Studio、不连接真实存档。
return function(testContext)
	local Domain = require(game.ServerScriptService.Server.Game.Domain.TravelDomain)
	local expect = testContext.expect

	local function fixture(draws)
		local config = {
			Settings = {
				InitialCoins = 30,
				InitialWood = 4,
				InitialSupplies = 3,
				BagCapacity = 3,
				ReturnSeconds = 5,
				SupplyPrice = 5,
				SupplyCost = 1,
				FirstJourneySeconds = 60,
				RestSeconds = 180,
				FirstPrepareSeconds = 30,
				PrepareMinSeconds = 60,
				PrepareMaxSeconds = 180,
				StudioPrepareMinSeconds = 15,
				StudioPrepareMaxSeconds = 30,
				SeaChoiceWeight_shallow = 1,
				SeaChoiceWeight_near = 1,
				ShortChoiceWeight = 1,
				LongChoiceWeight = 0,
				ContainerWood = 2,
				ItemsPerContainer = 3,
				ReceiptLimit = 100,
			},
			ItemsById = {
				book = { Id = "book", Quality = "Common", SellPrice = 5, Kind = "Commodity" },
				rope = { Id = "rope", Quality = "Common", SellPrice = 8, Kind = "Commodity" },
				lamp = { Id = "lamp", Quality = "Life", SellPrice = 18, Kind = "Commodity" },
				silk = { Id = "silk", Quality = "Fine", SellPrice = 40, Kind = "Commodity" },
				shell = { Id = "shell", Quality = "Special", SellPrice = 4, Kind = "Special" },
				pearl = { Id = "pearl", Quality = "Special", SellPrice = 10, Kind = "Special" },
			},
			ItemPoolsByQuality = { Common = { "book", "rope" }, Life = { "lamp" }, Fine = { "silk" } },
			SpecialItems = { "shell", "pearl" },
			SeasById = {
				shallow = { Id = "shallow", RequiredShipLevel = 1 },
				near = { Id = "near", RequiredShipLevel = 2 },
			},
			DurationsById = {
				shallow_short = { Id = "shallow_short", SeaId = "shallow", Seconds = 600, YieldMultiplier = 1 },
				shallow_long = { Id = "shallow_long", SeaId = "shallow", Seconds = 1800, YieldMultiplier = 3 },
				near_short = { Id = "near_short", SeaId = "near", Seconds = 1800, YieldMultiplier = 1 },
				near_long = { Id = "near_long", SeaId = "near", Seconds = 3600, YieldMultiplier = 2 },
			},
			UpgradesByFacility = {
				Home = { [2] = { CoinCost = 60, WoodCost = 8, Seconds = 180 } },
				Ship = { [2] = { CoinCost = 40, WoodCost = 6, Seconds = 120 } },
			},
			PostcardsById = {
				shallow_card = { Id = "shallow_card", SeaId = "shallow" },
				near_card = { Id = "near_card", SeaId = "near" },
			},
			PostcardsBySea = { shallow = { "shallow_card" }, near = { "near_card" } },
			WeightsBySea = {
				shallow = {
					{ Quality = "Common", Weight = 90 },
					{ Quality = "Life", Weight = 10 },
					{ Quality = "Fine", Weight = 0 },
				},
				near = {
					{ Quality = "Common", Weight = 20 },
					{ Quality = "Life", Weight = 20 },
					{ Quality = "Fine", Weight = 60 },
				},
			},
			HomeCapacityByLevel = { [1] = 3, [2] = 6 },
			MaxShipLevel = 2,
		}
		local nextId = 0
		local nextDraw = 0
		local context = {
			TimeScale = 1,
			NewId = function()
				nextId += 1
				return "id_" .. nextId
			end,
			Random = {
				NextInteger = function(_self, minimum, maximum)
					nextDraw += 1
					local value = if draws and draws[nextDraw] then draws[nextDraw] else minimum
					assert(value >= minimum and value <= maximum, "Test random draw outside requested range")
					return value
				end,
			},
		}
		local domain = Domain.new(config)
		return domain, domain:NewData(), context, config
	end

	local function request(domain, data, context, action, payload, now)
		payload.OperationId = payload.OperationId or "operation_" .. (data.Revision + 1)
		return domain:Apply(data, action, payload, now or 0, context)
	end
	local function clone(value)
		if type(value) ~= "table" then
			return value
		end
		local result = {}
		for key, entry in pairs(value) do
			result[key] = clone(entry)
		end
		return result
	end
	local function legacy(data, version)
		local result = clone(data)
		result.Version = version or 1
		result.LatestReturn, result.ReturnReadId = nil, nil
		if result.Journey then
			result.Journey.RestSeconds = nil
			if result.Journey.Status == "Settled" then
				result.Journey.Status = "Claimed"
			end
		end
		if result.Version < 3 then
			result.Plan, result.ManualPaused, result.DecisionSerial, result.DecisionRandomState = nil, nil, nil, nil
		end
		if result.Version == 1 then
			result.Supplies = result.WarehouseSupplies + result.PackedSupplies
			result.WarehouseSupplies, result.PackedSupplies = nil, nil
		end
		return result
	end
	local function depart(domain, data, context, now)
		now = now or 0
		if data.PackedSupplies == 0 then
			expect.truthy(request(domain, data, context, "PackSupply", { Quantity = 1 }, now))
		else
			domain:Advance(data, now, context)
		end
		expect.truthy(data.Plan and data.Plan.ReadyAt)
		local readyAt = data.Plan.ReadyAt
		expect.truthy(domain:Advance(data, readyAt, context))
		expect.equal(data.Journey.Status, "Voyaging")
		return readyAt
	end
	local function voyage(domain, data, context, now)
		depart(domain, data, context, now)
		local endAt = data.Journey.EndAt
		expect.truthy(domain:Advance(data, endAt, context))
		expect.equal(data.Journey.Status, "Settled")
		return endAt, data.Containers[#data.Containers].Id
	end

	testContext.test("new save and buying supplies never plan or auto pack", function()
		local domain, data, context = fixture()
		expect.equal(data.Version, 4)
		expect.equal(data.WarehouseSupplies, 3)
		expect.equal(data.PackedSupplies, 0)
		expect.falsy(domain:Advance(data, 0, context))
		expect.equal(domain:Public(data, 0).WaitingReason, "NO_PACKED_SUPPLIES")
		expect.truthy(request(domain, data, context, "BuySupply", { Quantity = 1 }))
		expect.equal(data.Plan, nil)
		expect.equal(data.WarehouseSupplies, 4)
		expect.equal(data.DecisionSerial, 0)
	end)
	testContext.test("first preparation saves one deadline and departure consumes once", function()
		local domain, data, context = fixture()
		expect.truthy(request(domain, data, context, "PackSupply", { Quantity = 2 }, 100))
		expect.equal(data.Plan.ReadyAt, 130)
		expect.equal(data.PackedSupplies, 2)
		expect.equal(domain:Public(data, 100).State, "Preparing")
		local planId, seed = data.Plan.Id, data.DecisionRandomState
		expect.falsy(domain:Advance(data, 129, context))
		expect.equal(data.Plan.Id, planId)
		expect.equal(data.DecisionRandomState, seed)
		expect.truthy(domain:Advance(data, 130, context))
		expect.equal(data.Plan, nil)
		expect.equal(data.Journey.PlanId, planId)
		expect.equal(data.Journey.StartAt, 130)
		expect.equal(data.Journey.EndAt, 190)
		expect.equal(data.PackedSupplies, 1)
		expect.falsy(domain:Advance(data, 130, context))
		expect.falsy(domain:Advance(data, 131, context))
		expect.equal(data.PackedSupplies, 1)
		expect.equal(domain:Public(data, 131).ReservedContainers, 1)
	end)
	testContext.test("saved preparation does not reroll on reconnect before or after its deadline", function()
		local domain, data, context = fixture()
		expect.truthy(request(domain, data, context, "PackSupply", { Quantity = 1 }, 100))
		local saved = clone(data)
		local _, _, replacement = fixture()
		replacement.Random.NextInteger = function(_self, minimum, maximum)
			expect.truthy(maximum < 2147483646) -- 保存已有决策流，不得请求新 seed。
			return minimum
		end
		expect.falsy(domain:Advance(saved, 120, replacement))
		expect.equal(saved.DecisionRandomState, data.DecisionRandomState)
		expect.equal(saved.Plan.Id, data.Plan.Id)
		expect.equal(saved.Plan.DurationId, data.Plan.DurationId)
		expect.equal(saved.Plan.ReadyAt, 130)
		expect.truthy(domain:Advance(saved, 150, replacement))
		expect.equal(saved.Journey.StartAt, 130)
		expect.equal(saved.Journey.EndAt, 190)
		expect.equal(saved.PackedSupplies, 0)
	end)
	testContext.test("late offline advance auto settles one saved trip then prepares at load time", function()
		local domain, data, context = fixture()
		expect.truthy(request(domain, data, context, "PackSupply", { Quantity = 3 }, 100))
		expect.truthy(domain:Advance(data, 99999, context))
		expect.equal(data.Journey.StartAt, 130)
		expect.equal(data.Journey.EndAt, 190)
		expect.equal(data.Journey.Status, "Settled")
		expect.equal(data.PackedSupplies, 2)
		expect.equal(data.DecisionSerial, 2)
		expect.equal(#data.Containers, 1)
		expect.equal(data.RestUntil, 0)
		expect.equal(domain:Public(data, 99999).State, "Preparing")
		expect.truthy(data.Plan.ReadyAt >= 100059 and data.Plan.ReadyAt <= 100179)
		expect.falsy(domain:Advance(data, 99999, context))
		expect.equal(data.Postcards.shallow_card, 1)
	end)
	testContext.test("production and Studio preparation windows never use voyage time scale", function()
		for _, studio in ipairs({ false, true }) do
			local domain, data, context = fixture()
			data.FirstJourney = false
			context.IsStudio, context.TimeScale = studio, 0.05
			expect.truthy(request(domain, data, context, "PackSupply", { Quantity = 1 }, 100))
			local wait = data.Plan.ReadyAt - 100
			expect.truthy(wait >= (if studio then 15 else 60))
			expect.truthy(wait <= (if studio then 30 else 180))
		end
		local domain, data, context = fixture()
		context.IsStudio, context.TimeScale = true, 0.05
		expect.equal(depart(domain, data, context, 10), 40)
		expect.equal(data.Journey.EndAt, 43)
	end)
	testContext.test("partial bag changes preserve deadline and emptying cancels only waiting", function()
		local domain, data, context = fixture()
		expect.truthy(request(domain, data, context, "PackSupply", { Quantity = 2 }, 100))
		local planId, durationId = data.Plan.Id, data.Plan.DurationId
		expect.truthy(request(domain, data, context, "UnpackSupply", { Quantity = 1 }, 105))
		expect.truthy(request(domain, data, context, "PackSupply", { Quantity = 1 }, 106))
		expect.equal(data.Plan.ReadyAt, 130)
		expect.truthy(request(domain, data, context, "UnpackSupply", { Quantity = 2 }, 110))
		expect.equal(data.Plan.ReadyAt, nil)
		expect.equal(data.Plan.Id, planId)
		expect.falsy(domain:Advance(data, 150, context))
		expect.truthy(request(domain, data, context, "PackSupply", { Quantity = 1 }, 200))
		expect.equal(data.Plan.Id, planId)
		expect.equal(data.Plan.DurationId, durationId)
		expect.equal(data.Plan.ReadyAt, 230)
		expect.equal(data.DecisionSerial, 1)
	end)
	testContext.test("manual pause survives reconnect and resource changes require explicit resume", function()
		local domain, data, context = fixture()
		expect.truthy(request(domain, data, context, "PackSupply", { Quantity = 1 }, 100))
		local planId = data.Plan.Id
		expect.truthy(request(domain, data, context, "PauseTravel", {}, 110))
		expect.equal(data.Plan.ReadyAt, nil)
		expect.equal(domain:Public(data, 110).WaitingReason, "MANUAL_PAUSED")
		local saved = clone(data)
		expect.truthy(domain:Validate(saved))
		expect.truthy(request(domain, saved, context, "BuySupply", { Quantity = 1 }, 200))
		expect.truthy(request(domain, saved, context, "PackSupply", { Quantity = 1 }, 200))
		expect.equal(saved.Plan.ReadyAt, nil)
		expect.falsy(domain:Advance(saved, 99999, context))
		expect.truthy(request(domain, saved, context, "ResumeTravel", {}, 300))
		expect.equal(saved.Plan.Id, planId)
		expect.equal(saved.Plan.ReadyAt, 330)
		expect.equal(saved.DecisionSerial, 1)
	end)
	testContext.test("deadline beats stale pause and a failed request never rolls departure back", function()
		local domain, data, context = fixture()
		expect.truthy(request(domain, data, context, "PackSupply", { Quantity = 1 }, 100))
		local ok, code = request(domain, data, context, "PauseTravel", { ExpectedRevision = data.Revision }, 130)
		expect.falsy(ok)
		expect.equal(code, "STALE_STATE")
		expect.equal(data.Journey.StartAt, 130)
		expect.equal(data.PackedSupplies, 0)
		expect.equal(data.ManualPaused, false)
		local again, againCode = request(domain, data, context, "PauseTravel", {}, 130)
		expect.falsy(again)
		expect.equal(againCode, "BAG_READ_ONLY")
		expect.equal(data.PackedSupplies, 0)
	end)
	testContext.test("external dispatch and extra pause fields cannot control route or timing", function()
		local domain, data, context = fixture()
		for _, action in ipairs({ "StartJourney", "__StartJourney" }) do
			local ok, code = request(domain, data, context, action, { SeaId = "near", DurationId = "near_long" })
			expect.falsy(ok)
			expect.equal(code, "INVALID_REQUEST")
		end
		expect.falsy(request(domain, data, context, "PauseTravel", { Paused = true }))
		expect.falsy(request(domain, data, context, "ResumeTravel", { ReadyAt = 0 }))
		expect.equal(data.Revision, 0)
	end)
	testContext.test("weights only choose unlocked seas and save exact selected long journey", function()
		local domain, data, context, config = fixture()
		data.FirstJourney = false
		config.Settings.ShortChoiceWeight, config.Settings.LongChoiceWeight = 0, 1
		depart(domain, data, context, 0)
		expect.equal(data.Journey.SeaId, "shallow")
		expect.equal(data.Journey.DurationId, "shallow_long")
		expect.equal(data.Journey.EndAt - data.Journey.StartAt, 1800)
		expect.equal(data.Journey.SpecialQuantity, 3)
		local other, saved, random, settings = fixture({ 1, 100 })
		saved.FirstJourney, saved.ShipLevel = false, 2
		settings.Settings.SeaChoiceWeight_shallow, settings.Settings.SeaChoiceWeight_near = 0, 1
		settings.Settings.ShortChoiceWeight, settings.Settings.LongChoiceWeight = 0, 1
		depart(other, saved, random, 0)
		expect.equal(saved.Journey.SeaId, "near")
		expect.equal(saved.Journey.DurationId, "near_long")
		expect.equal(saved.Journey.EndAt - saved.Journey.StartAt, 3600)
		expect.equal(saved.Journey.Container.Quality, "Fine")
		expect.equal(saved.Journey.Container.Items.silk, 6)
	end)
	testContext.test("ship construction cancels only waiting and resumes same route after completion", function()
		local domain, data, context = fixture()
		data.Coins, data.Wood = 100, 10
		expect.truthy(request(domain, data, context, "PackSupply", { Quantity = 1 }, 100))
		local planId, seaId = data.Plan.Id, data.Plan.SeaId
		expect.truthy(request(domain, data, context, "Upgrade", { Target = "Ship" }, 110))
		expect.equal(data.Plan.ReadyAt, nil)
		expect.equal(domain:Public(data, 110).WaitingReason, "SHIP_UPGRADING")
		expect.falsy(domain:Advance(data, 229, context))
		expect.truthy(domain:Advance(data, 230, context))
		expect.equal(data.ShipLevel, 2)
		expect.equal(data.Plan.Id, planId)
		expect.equal(data.Plan.SeaId, seaId)
		expect.equal(data.Plan.ReadyAt, 260)
		expect.equal(data.DecisionSerial, 1)
	end)
	testContext.test("full box area blocks planning and opening a box starts preparation", function()
		local domain, data, context = fixture()
		local endAt = 0
		for _ = 1, 3 do
			endAt = voyage(domain, data, context, endAt + 180)
		end
		expect.equal(#data.Containers, 3)
		data.WarehouseSupplies = 1
		expect.truthy(request(domain, data, context, "PackSupply", { Quantity = 1 }, endAt + 180))
		expect.equal(data.Plan, nil)
		expect.equal(domain:Public(data, endAt + 180).WaitingReason, "CONTAINER_FULL")
		expect.truthy(
			request(domain, data, context, "OpenContainer", { ContainerId = data.Containers[1].Id }, endAt + 180)
		)
		expect.truthy(data.Plan and data.Plan.ReadyAt)
		expect.truthy(domain:Advance(data, data.Plan.ReadyAt, context))
		expect.equal(#data.Containers, 2)
		expect.equal(domain:Public(data, data.Journey.StartAt).ReservedContainers, 1)
		expect.equal(data.PackedSupplies, 0)
		expect.truthy(domain:Validate(data))
	end)
	testContext.test("rest and docking must both finish before another preparation", function()
		local domain, data, context = fixture()
		local endAt = voyage(domain, data, context, 0)
		expect.truthy(request(domain, data, context, "PackSupply", { Quantity = 1 }, endAt + 5))
		expect.equal(data.Plan, nil)
		expect.falsy(domain:Advance(data, endAt + 179, context))
		expect.truthy(domain:Advance(data, endAt + 180, context))
		expect.truthy(data.Plan.ReadyAt >= endAt + 240 and data.Plan.ReadyAt <= endAt + 360)
		local other, saved, debugContext, config = fixture()
		config.Settings.RestSeconds = 1
		local arrived = voyage(other, saved, debugContext, 0)
		saved.PackedSupplies = 1
		expect.truthy(other:Advance(saved, arrived + 1, debugContext))
		expect.equal(saved.Plan, nil)
		expect.equal(other:Public(saved, arrived + 1).WaitingReason, "NOT_DOCKED")
		expect.truthy(other:Advance(saved, arrived + 5, debugContext))
		expect.truthy(saved.Plan.ReadyAt)
	end)
	testContext.test("first rewards stay hidden and auto return and open grant exactly once", function()
		local domain, data, context = fixture()
		depart(domain, data, context, 0)
		local public = domain:Public(data, 30)
		expect.equal(public.Journey.Container, nil)
		expect.equal(public.Journey.PostcardId, nil)
		expect.equal(public.Journey.SpecialItemId, nil)
		expect.equal(public.DecisionRandomState, nil)
		expect.equal(public.Receipts, nil)
		expect.equal(data.Journey.Container.Items.book, 3)
		expect.equal(data.Journey.SpecialQuantity, 1)
		local endAt = data.Journey.EndAt
		expect.truthy(domain:Advance(data, endAt, context))
		expect.equal(data.Inventory.shell, 1)
		expect.equal(data.Postcards.shallow_card, 1)
		local boxId = data.Containers[1].Id
		expect.equal(domain:Public(data, endAt).Containers[1].Quality, nil)
		expect.truthy(request(domain, data, context, "OpenContainer", { ContainerId = boxId }, endAt))
		expect.equal(data.Inventory.book, 3)
		expect.equal(data.Wood, 6)
		expect.truthy(data.OpenedQualities.Common)
		expect.falsy(request(domain, data, context, "ClaimReturn", { JourneyId = data.Journey.Id }, endAt))
		expect.falsy(request(domain, data, context, "OpenContainer", { ContainerId = boxId }, endAt))
		expect.equal(data.Inventory.book, 3)
		expect.equal(data.Inventory.shell, 1)
	end)
	testContext.test("long voyage snapshots quantity and constant wood against config edits", function()
		local domain, data, context, config = fixture()
		data.FirstJourney = false
		config.Settings.ShortChoiceWeight, config.Settings.LongChoiceWeight = 0, 1
		depart(domain, data, context, 0)
		local endAt = data.Journey.EndAt
		config.DurationsById.shallow_long.YieldMultiplier = 99
		config.Settings.ContainerWood = 99
		expect.truthy(domain:Advance(data, endAt, context))
		expect.equal(data.Inventory.shell, 3)
		expect.truthy(request(domain, data, context, "OpenContainer", { ContainerId = data.Containers[1].Id }, endAt))
		expect.equal(data.Inventory.book, 9)
		expect.equal(data.Wood, 6)
	end)
	testContext.test("purchase replay is idempotent and conflicts or stale intent cannot charge", function()
		local domain, data, context = fixture()
		local payload = { Quantity = 1, OperationId = "buy_one", ExpectedRevision = 0 }
		expect.truthy(request(domain, data, context, "BuySupply", payload))
		local revision = data.Revision
		local ok, code = request(domain, data, context, "BuySupply", payload)
		expect.truthy(ok)
		expect.equal(code, "REPLAYED")
		expect.equal(data.Coins, 25)
		expect.equal(data.WarehouseSupplies, 4)
		expect.equal(data.Revision, revision)
		payload.Quantity = 2
		local conflict, conflictCode = request(domain, data, context, "BuySupply", payload)
		expect.falsy(conflict)
		expect.equal(conflictCode, "OPERATION_CONFLICT")
		local stale, staleCode = request(domain, data, context, "BuySupply", { Quantity = 1, ExpectedRevision = 0 })
		expect.falsy(stale)
		expect.equal(staleCode, "STALE_STATE")
		expect.equal(data.Coins, 25)
	end)
	testContext.test("pruned receipt cannot replay an old purchase revision", function()
		local domain, data, context = fixture()
		data.Coins = 2000
		expect.truthy(
			request(domain, data, context, "BuySupply", { Quantity = 1, OperationId = "first", ExpectedRevision = 0 })
		)
		for index = 1, 100 do
			expect.truthy(
				request(domain, data, context, "BuySupply", { Quantity = 1, OperationId = "later_" .. index })
			)
		end
		expect.equal(#data.ReceiptOrder, 100)
		expect.equal(data.Receipts.first, nil)
		local coins = data.Coins
		local ok, code =
			request(domain, data, context, "BuySupply", { Quantity = 1, OperationId = "first", ExpectedRevision = 0 })
		expect.falsy(ok)
		expect.equal(code, "STALE_STATE")
		expect.equal(data.Coins, coins)
	end)
	testContext.test("supply requests reject malformed quantities and client fields atomically", function()
		local domain, data, context = fixture()
		for _, action in ipairs({ "BuySupply", "PackSupply", "UnpackSupply" }) do
			for index, quantity in ipairs({ 0, -1, 1.5, math.huge, 0 / 0, 9007199254740992, "1", true, {} }) do
				local ok, code =
					request(domain, data, context, action, { Quantity = quantity, OperationId = action .. index })
				expect.falsy(ok)
				expect.equal(code, "INVALID_REQUEST")
			end
			expect.falsy(request(domain, data, context, action, {}))
			expect.falsy(request(domain, data, context, action, { Quantity = 1, UserId = 42 }))
			expect.falsy(request(domain, data, context, action, { Quantity = 1, Price = 0 }))
		end
		expect.equal(data.Coins, 30)
		expect.equal(data.WarehouseSupplies, 3)
		expect.equal(data.PackedSupplies, 0)
		expect.equal(data.Revision, 0)
	end)
	testContext.test("bag capacity and replay conserve supplies without resetting preparation", function()
		local domain, data, context = fixture()
		local payload = { Quantity = 3, OperationId = "pack", ExpectedRevision = 0 }
		expect.truthy(request(domain, data, context, "PackSupply", payload))
		local deadline, revision = data.Plan.ReadyAt, data.Revision
		expect.truthy(request(domain, data, context, "PackSupply", payload))
		expect.equal(data.PackedSupplies, 3)
		expect.equal(data.Revision, revision)
		data.WarehouseSupplies = 1
		local full, fullCode = request(domain, data, context, "PackSupply", { Quantity = 1 })
		expect.falsy(full)
		expect.equal(fullCode, "BAG_FULL")
		expect.truthy(request(domain, data, context, "UnpackSupply", { Quantity = 2 }))
		expect.equal(data.WarehouseSupplies, 3)
		expect.equal(data.PackedSupplies, 1)
		expect.equal(data.Plan.ReadyAt, deadline)
		expect.falsy(request(domain, data, context, "UnpackSupply", { Quantity = 2 }))
		expect.equal(data.PackedSupplies, 1)
	end)
	testContext.test("bag and pause read only at sea and returning but allow adjustment once docked", function()
		local domain, data, context = fixture()
		expect.truthy(request(domain, data, context, "PackSupply", { Quantity = 2 }))
		depart(domain, data, context, 0)
		local endAt = data.Journey.EndAt
		for _, now in ipairs({ 30, endAt - 1, endAt, endAt + 4.999 }) do
			expect.falsy(domain:CanManageBag(data, now))
			for _, action in ipairs({ "PackSupply", "UnpackSupply", "PauseTravel", "ResumeTravel" }) do
				local payload = if action == "PackSupply" or action == "UnpackSupply" then { Quantity = 1 } else {}
				local ok, code = request(domain, data, context, action, payload, now)
				expect.falsy(ok)
				expect.equal(code, "BAG_READ_ONLY")
			end
		end
		expect.truthy(request(domain, data, context, "PackSupply", { Quantity = 1 }, endAt + 5))
		expect.truthy(request(domain, data, context, "UnpackSupply", { Quantity = 2 }, endAt + 5))
		expect.equal(data.Journey.Status, "Settled")
		expect.equal(data.WarehouseSupplies, 2)
		expect.equal(data.PackedSupplies, 0)
	end)
	testContext.test("automatic deposit cannot bypass docking and debug return keeps animation minimum", function()
		local domain, data, context = fixture()
		context.TimeScale = 0.001
		depart(domain, data, context, 10)
		local endAt = data.Journey.EndAt
		expect.equal(endAt, 41)
		expect.truthy(domain:Advance(data, endAt, context))
		expect.falsy(domain:CanManageBag(data, 41.499))
		expect.truthy(domain:CanManageBag(data, 41.5))
		expect.truthy(request(domain, data, context, "PackSupply", { Quantity = 1 }, 41.5))
	end)
	testContext.test("upgrade keeps one supply or purchase funds and completes once", function()
		local domain, data, context = fixture()
		data.Coins, data.Wood, data.WarehouseSupplies = 40, 6, 0
		local ok, code = request(domain, data, context, "Upgrade", { Target = "Ship" })
		expect.falsy(ok)
		expect.equal(code, "KEEP_SUPPLY_RESERVE")
		expect.equal(data.Coins, 40)
		data.Coins = 45
		expect.truthy(request(domain, data, context, "Upgrade", { Target = "Ship" }))
		expect.equal(data.Coins, 5)
		expect.equal(data.Wood, 0)
		expect.falsy(request(domain, data, context, "Upgrade", { Target = "Ship" }))
		expect.falsy(domain:Advance(data, 119, context))
		expect.truthy(domain:Advance(data, 120, context))
		expect.equal(data.ShipLevel, 2)
		expect.equal(data.Upgrades.Ship, nil)
		expect.falsy(domain:Advance(data, 9999, context))
	end)
	testContext.test("home construction runs during travel and ship waits until docked", function()
		local domain, data, context = fixture()
		data.Coins, data.Wood = 100, 14
		depart(domain, data, context, 0)
		expect.truthy(request(domain, data, context, "Upgrade", { Target = "Home" }, 30))
		local ok, code = request(domain, data, context, "Upgrade", { Target = "Ship" }, 30)
		expect.falsy(ok)
		expect.equal(code, "SHIP_AWAY")
		expect.truthy(domain:Advance(data, 210, context))
		expect.equal(data.HomeLevel, 2)
		expect.equal(data.Journey.Status, "Settled")
		expect.truthy(request(domain, data, context, "Upgrade", { Target = "Ship" }, 210))
	end)
	testContext.test("fixed price sales preserve discoveries and public copies", function()
		local domain, data, context = fixture()
		data.Inventory = { book = 2, pearl = 1 }
		data.DiscoveredItems = { book = true, pearl = true }
		expect.falsy(request(domain, data, context, "SellItem", { ItemId = "book", Quantity = 3 }))
		expect.truthy(request(domain, data, context, "SellItem", { ItemId = "book", Quantity = 1 }))
		expect.equal(data.Coins, 35)
		expect.truthy(request(domain, data, context, "SellAll", {}))
		expect.equal(data.Coins, 50)
		expect.equal(next(data.Inventory), nil)
		local public = domain:Public(data, 0)
		public.DiscoveredItems.book = nil
		expect.truthy(data.DiscoveredItems.book)
		expect.truthy(data.DiscoveredItems.pearl)
	end)
	testContext.test("relief never auto packs and cannot be farmed with other sellable assets", function()
		local domain, data, context = fixture()
		data.Coins, data.WarehouseSupplies = 4, 0
		data.Inventory.shell = 1
		expect.falsy(request(domain, data, context, "ClaimRelief", {}))
		data.Inventory, data.Coins = {}, 5
		expect.falsy(request(domain, data, context, "ClaimRelief", {}))
		data.Coins = 4
		expect.truthy(request(domain, data, context, "ClaimRelief", {}))
		expect.equal(data.WarehouseSupplies, 1)
		expect.equal(data.PackedSupplies, 0)
		expect.equal(data.Plan, nil)
		expect.falsy(request(domain, data, context, "ClaimRelief", {}))
	end)
	testContext.test("settled trip cannot grant again after receipt pruning", function()
		local domain, data, context, config = fixture()
		config.Settings.ReceiptLimit = 1
		local endAt, containerId = voyage(domain, data, context, 0)
		local oldJourney = data.Journey.Id
		data.Inventory, data.Coins, data.WarehouseSupplies = {}, 0, 0
		expect.falsy(request(domain, data, context, "ClaimRelief", {}, endAt))
		expect.truthy(request(domain, data, context, "OpenContainer", { ContainerId = containerId }, endAt))
		expect.falsy(request(domain, data, context, "ClaimReturn", { JourneyId = oldJourney }, endAt))
		expect.equal(data.Postcards.shallow_card, 1)
	end)
	testContext.test("integer bounds and autonomy invariants reject corrupt saves", function()
		local domain, data, context = fixture()
		data.WarehouseSupplies, data.PackedSupplies = 9007199254740989, 2
		expect.truthy(domain:Validate(data))
		local ok, code = request(domain, data, context, "BuySupply", { Quantity = 1 })
		expect.falsy(ok)
		expect.equal(code, "INVALID_QUANTITY")
		data.PackedSupplies = 4
		expect.falsy(domain:Validate(data))
		local _, fresh = fixture()
		for _, key in ipairs({ "WarehouseSupplies", "PackedSupplies", "DecisionSerial", "DecisionRandomState" }) do
			local broken = clone(fresh)
			broken[key] = -1
			expect.falsy(domain:Validate(broken))
		end
		fresh.DecisionRandomState = 2147483647
		expect.falsy(domain:Validate(fresh))
	end)
	testContext.test("v1 migration follows all steps and preserves receipts and assets", function()
		local domain, data, context = fixture()
		expect.truthy(
			request(domain, data, context, "BuySupply", { Quantity = 2, OperationId = "old_buy", ExpectedRevision = 0 })
		)
		data.Inventory.book, data.DiscoveredItems.book = 2, true
		local old = legacy(data)
		local revision = old.Revision
		local ok, code, changed = domain:Migrate(old)
		expect.truthy(ok)
		expect.equal(code, "MIGRATED")
		expect.equal(changed, true)
		expect.equal(old.Version, 4)
		expect.equal(old.Revision, revision + 3)
		expect.equal(old.WarehouseSupplies, 5)
		expect.equal(old.PackedSupplies, 0)
		expect.equal(old.Inventory.book, 2)
		expect.equal(old.ManualPaused, false)
		expect.equal(old.Plan, nil)
		local restored = clone(old)
		local again, againCode, againChanged = domain:Migrate(restored)
		expect.truthy(again)
		expect.equal(againCode, "OK")
		expect.equal(againChanged, false)
		expect.equal(restored.Revision, revision + 3)
		local replay, replayCode = request(
			domain,
			restored,
			context,
			"BuySupply",
			{ Quantity = 2, OperationId = "old_buy", ExpectedRevision = 0 }
		)
		expect.truthy(replay)
		expect.equal(replayCode, "REPLAYED")
		expect.equal(restored.Coins, 20)
		expect.equal(restored.WarehouseSupplies, 5)
	end)
	testContext.test("v2 migration keeps packed supplies and active trip without charging again", function()
		local domain, data, context = fixture()
		expect.truthy(request(domain, data, context, "PackSupply", { Quantity = 2 }, 100))
		expect.truthy(domain:Advance(data, 130, context))
		local old, journey = legacy(data, 2), clone(data.Journey)
		old.Journey.DurationId, old.Journey.PlanId = nil, nil
		local revision = old.Revision
		expect.truthy(domain:Migrate(old))
		expect.equal(old.Version, 4)
		expect.equal(old.Revision, revision + 2)
		expect.equal(old.WarehouseSupplies, 1)
		expect.equal(old.PackedSupplies, 1)
		expect.equal(old.Journey.Id, journey.Id)
		expect.equal(old.Journey.EndAt, journey.EndAt)
		expect.equal(old.Journey.Container.Id, journey.Container.Id)
		expect.equal(old.Journey.Container.Items.book, 3)
		expect.falsy(domain:Advance(old, 150, context))
		expect.equal(old.PackedSupplies, 1)
		expect.truthy(domain:Advance(old, journey.EndAt, context))
		expect.equal(old.Containers[1].Id, journey.Container.Id)
		expect.equal(old.Inventory.shell, 1)
	end)
	testContext.test("migration rejects malformed conflicting unknown overflow saves without mutation", function()
		local domain, data = fixture()
		local edits = {
			function(saved)
				saved.Supplies = -1
			end,
			function(saved)
				saved.WarehouseSupplies = 99
			end,
			function(saved)
				saved.ManualPaused = false
			end,
			function(saved)
				saved.Inventory = nil
			end,
			function(saved)
				saved.HomeLevel = 0
			end,
			function(saved)
				saved.Receipts.orphan = { Fingerprint = "x", Result = {} }
			end,
			function(saved)
				saved.Version = 5
			end,
			function(saved)
				saved.Revision = 9007199254740991
			end,
		}
		for _, edit in ipairs(edits) do
			local saved = legacy(data)
			edit(saved)
			local supplies, revision, version = saved.Supplies, saved.Revision, saved.Version
			local ok, code, changed = domain:Migrate(saved)
			expect.falsy(ok)
			expect.equal(code, "INVALID_DATA")
			expect.equal(changed, false)
			expect.equal(saved.Supplies, supplies)
			expect.equal(saved.Revision, revision)
			expect.equal(saved.Version, version)
		end
		expect.falsy(domain:Migrate({ Version = 1, Supplies = 3 }))
		expect.falsy(domain:Migrate(nil))
	end)
	testContext.test("automatic arrival deposits assets once and rests from actual arrival", function()
		local domain, data, context = fixture()
		depart(domain, data, context, 100)
		local journeyId, endAt, boxId = data.Journey.Id, data.Journey.EndAt, data.Journey.Container.Id
		expect.falsy(domain:Advance(data, endAt - 0.1, context))
		expect.equal(#data.Containers, 0)
		expect.truthy(domain:Advance(data, endAt, context))
		expect.equal(data.Journey.Status, "Settled")
		expect.equal(data.Journey.Container, nil)
		expect.equal(data.Containers[1].Id, boxId)
		expect.equal(data.Inventory.shell, 1)
		expect.equal(data.Postcards.shallow_card, 1)
		expect.equal(data.Wood, 4) -- 木材与封箱商品仍须玩家开箱。
		expect.equal(data.Inventory.book, nil)
		expect.equal(data.RestUntil, endAt + 180)
		expect.equal(data.LatestReturn.JourneyId, journeyId)
		expect.equal(data.LatestReturn.ReturnedAt, endAt)
		expect.equal(domain:Public(data, endAt).State, "Returning")
		expect.equal(domain:Public(data, endAt + 5).State, "Resting")
		expect.equal(domain:Public(data, endAt).ReservedContainers, 0)
		local restored = clone(data)
		expect.falsy(domain:Advance(restored, endAt + 20, context))
		expect.equal(#restored.Containers, 1)
		expect.equal(restored.Inventory.shell, 1)
		expect.equal(restored.Postcards.shallow_card, 1)
		expect.equal(restored.RestUntil, endAt + 180)
		expect.truthy(domain:Validate(restored))
	end)
	testContext.test("viewing return is persisted read state without assets or a new journey gate", function()
		local domain, data, context = fixture()
		expect.truthy(request(domain, data, context, "PackSupply", { Quantity = 2 }, 0))
		depart(domain, data, context, 0)
		local journeyId, endAt = data.Journey.Id, data.Journey.EndAt
		expect.truthy(domain:Advance(data, endAt, context))
		expect.truthy(domain:Public(data, endAt).HasUnreadReturn)
		local payload = { JourneyId = journeyId, OperationId = "read_first" }
		expect.truthy(request(domain, data, context, "MarkReturnRead", payload, endAt))
		expect.equal(data.ReturnReadId, journeyId)
		expect.falsy(domain:Public(clone(data), endAt).HasUnreadReturn)
		expect.truthy(request(domain, data, context, "MarkReturnRead", payload, endAt))
		expect.equal(data.Inventory.shell, 1)
		expect.equal(#data.Containers, 1)
		expect.equal(data.PackedSupplies, 1)
		expect.equal(data.RestUntil, endAt + 180)
		expect.falsy(request(domain, data, context, "MarkReturnRead", { JourneyId = "someone_else" }, endAt))
		expect.falsy(request(domain, data, context, "MarkReturnRead", { JourneyId = journeyId, Quantity = 1 }, endAt))
		-- 再次准备/出发不需要查看；最近归航记录仍能在新航次途中查看。
		data.ReturnReadId = nil
		expect.truthy(domain:Advance(data, endAt + 180, context))
		expect.equal(domain:Public(data, endAt + 180).State, "Preparing")
		local secondReadyAt = data.Plan.ReadyAt
		expect.truthy(domain:Advance(data, secondReadyAt, context))
		expect.truthy(data.Journey.Id ~= journeyId)
		expect.truthy(domain:Public(data, secondReadyAt).HasUnreadReturn)
		expect.truthy(request(domain, data, context, "MarkReturnRead", { JourneyId = journeyId }, secondReadyAt))
		expect.equal(data.ReturnReadId, journeyId)
		expect.equal(data.Inventory.shell, 1)
	end)
	testContext.test("saved rest seconds survive debug or config changes without a model context", function()
		local domain, data, context, config = fixture()
		context.TimeScale = 0.05
		depart(domain, data, context, 10)
		local endAt = data.Journey.EndAt
		expect.equal(data.Journey.RestSeconds, 9)
		config.Settings.RestSeconds = 900
		expect.truthy(domain:Advance(data, endAt + 2))
		expect.equal(data.RestUntil, endAt + 9)
		expect.equal(data.LatestReturn.ReturnedAt, endAt)
		expect.truthy(domain:Validate(data))
	end)
	testContext.test("v3 migration preserves pending plan pause random state and receipts", function()
		local domain, data, context = fixture()
		expect.truthy(request(domain, data, context, "PackSupply", { Quantity = 2 }, 100))
		expect.truthy(request(domain, data, context, "PauseTravel", {}, 110))
		local old = legacy(data, 3)
		local revision, planId, seed, serial = old.Revision, old.Plan.Id, old.DecisionRandomState, old.DecisionSerial
		expect.truthy(domain:Migrate(old))
		expect.equal(old.Version, 4)
		expect.equal(old.Revision, revision + 1)
		expect.equal(old.Plan.Id, planId)
		expect.equal(old.Plan.ReadyAt, nil)
		expect.equal(old.ManualPaused, true)
		expect.equal(old.DecisionRandomState, seed)
		expect.equal(old.DecisionSerial, serial)
		expect.equal(old.PackedSupplies, 2)
		expect.equal(#old.ReceiptOrder, #data.ReceiptOrder)
		expect.falsy(domain:Advance(old, 99999, context))
	end)
	testContext.test("legacy pending return auto settles once with real arrival deadline", function()
		local domain, data, context = fixture()
		depart(domain, data, context, 100)
		local old = legacy(data, 3)
		old.Journey.Status = "Returned"
		old.ManualPaused = true
		local endAt, boxId = old.Journey.EndAt, old.Journey.Container.Id
		expect.truthy(domain:Migrate(old))
		expect.equal(old.Journey.Status, "Returned")
		expect.truthy(domain:Advance(old, endAt + 100, context))
		expect.equal(old.Journey.Status, "Settled")
		expect.equal(old.Containers[1].Id, boxId)
		expect.equal(old.PackedSupplies, 0)
		expect.equal(old.Inventory.shell, 1)
		expect.equal(old.RestUntil, endAt + 180)
		expect.falsy(domain:Advance(old, endAt + 100, context))
		expect.truthy(domain:Advance(old, endAt + 200, context))
		expect.equal(old.Plan, nil)
		expect.equal(old.RestUntil, 0)
		expect.equal(old.Inventory.shell, 1)
	end)
	testContext.test("legacy claimed migration keeps rest and assets and blocks old claim receipts", function()
		local domain, data, context = fixture()
		local endAt = voyage(domain, data, context, 0)
		local old = legacy(data, 3)
		old.RestUntil = endAt + 500
		old.ManualPaused = true
		old.Receipts.old_claim = { Fingerprint = "ClaimReturn|old", Result = { JourneyId = old.Journey.Id } }
		table.insert(old.ReceiptOrder, "old_claim")
		expect.truthy(domain:Migrate(old))
		expect.equal(old.Journey.Status, "Settled")
		expect.equal(old.Journey.Container, nil)
		expect.equal(old.RestUntil, endAt + 500)
		expect.equal(old.LatestReturn, nil)
		expect.equal(old.Receipts.old_claim.Result.JourneyId, old.Journey.Id)
		local ok, code = request(domain, old, context, "ClaimReturn", {
			JourneyId = old.Journey.Id,
			OperationId = "old_claim",
		}, endAt + 5)
		expect.falsy(ok)
		expect.equal(code, "INVALID_REQUEST")
		expect.falsy(domain:Advance(old, endAt + 5, context))
		expect.equal(#old.Containers, 1)
		expect.equal(old.Inventory.shell, 1)
		expect.equal(old.Postcards.shallow_card, 1)
		expect.equal(old.RestUntil, endAt + 500)
	end)
	testContext.test("latest return public whitelist hides sealed contents and validates saved summaries", function()
		local domain, data, context = fixture()
		voyage(domain, data, context, 0)
		local public = domain:Public(data, data.Journey.EndAt)
		expect.equal(public.LatestReturn.Container, nil)
		expect.equal(public.LatestReturn.Items, nil)
		expect.equal(public.LatestReturn.Quality, nil)
		expect.equal(public.LatestReturn.Wood, nil)
		expect.equal(public.ReturnReadId, nil)
		expect.equal(public.Journey.RestSeconds, nil)
		public.LatestReturn.SpecialQuantity = 999
		expect.equal(data.LatestReturn.SpecialQuantity, 1)
		for _, edit in ipairs({
			function(saved)
				saved.LatestReturn.Items = { book = 3 }
			end,
			function(saved)
				saved.LatestReturn.SpecialQuantity = 0
			end,
			function(saved)
				saved.LatestReturn.DurationId = "near_short"
			end,
			function(saved)
				saved.ReturnReadId = ""
			end,
			function(saved)
				saved.Journey.RestSeconds = -1
			end,
		}) do
			local invalid = clone(data)
			edit(invalid)
			expect.falsy(domain:Validate(invalid))
		end
	end)
	testContext.test("plan validation rejects routes deadlines pause and absent random state", function()
		local domain, data, context = fixture()
		expect.truthy(request(domain, data, context, "PackSupply", { Quantity = 1 }, 100))
		local edits = {
			function(saved)
				saved.Plan.DurationId = "near_short"
			end,
			function(saved)
				saved.Plan.ReadyAt = 99
			end,
			function(saved)
				saved.Plan.ReadyAt = math.huge
			end,
			function(saved)
				saved.ManualPaused = true
			end,
			function(saved)
				saved.DecisionRandomState = 0
			end,
		}
		for _, edit in ipairs(edits) do
			local saved = clone(data)
			edit(saved)
			expect.falsy(domain:Validate(saved))
		end
		local public = domain:Public(data, 100)
		public.Plan.SeaId = "near"
		expect.equal(data.Plan.SeaId, "shallow")
		data.Plan.PrivateSeed = 99
		expect.equal(domain:Public(data, 100).Plan.PrivateSeed, nil)
	end)
end
