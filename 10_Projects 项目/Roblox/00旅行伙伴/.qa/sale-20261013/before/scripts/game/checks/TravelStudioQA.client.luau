-- Studio MCP 客户端实机验收辅助；不映射进游戏，不提供正式服调试入口。
-- 只移动当前测试角色并调用真实 Remote；不直接改存档，不注入货币或材料。
local QA = {}
local player = game:GetService("Players").LocalPlayer
local net = require(game.ReplicatedStorage.Framework.Shared.Net.NetClient)
local http = game:GetService("HttpService")

function QA.Read()
	for _ = 1, 8 do
		local result = net.Request("TravelBuddy.Request", { Action = "ReadState" }, 10)
		if result.Ok then
			return result.Data.State
		end
		assert(result.Code == "RATE_LIMITED" or result.Code == "DATA_NOT_READY", result.Code)
		task.wait(0.35)
	end
	error("Player data or network remained unavailable during QA")
end

function QA.Move(anchor, offset)
	assert(player.Character and player.Character:FindFirstChild("HumanoidRootPart"), "Character not ready")
	player.Character:PivotTo(anchor.CFrame * CFrame.new(offset or Vector3.new(0, 5, 0)))
	task.wait(0.5)
end

function QA.Do(action, fields)
	local operationId = http:GenerateGUID(false)
	for _ = 1, 4 do
		local state = QA.Read()
		task.wait(0.3)
		local payload = table.clone(fields or {})
		payload.Action = action
		payload.OperationId = operationId
		payload.ExpectedRevision = state.Revision
		local result = net.Request("TravelBuddy.Request", payload, 10)
		if result.Ok then
			task.wait(0.3)
			return result.Data
		end
		assert(
			result.Code == "STALE_STATE" or result.Code == "RATE_LIMITED",
			result.Code .. ": " .. tostring(result.Message)
		)
		task.wait(0.35)
	end
	error("State kept changing during QA")
end

function QA.Summary(state)
	state = state or QA.Read()
	return {
		UserId = player.UserId,
		PlotId = state.PlotId,
		Revision = state.Revision,
		State = state.State,
		Coins = state.Coins,
		Wood = state.Wood,
		Supplies = state.Supplies,
		HomeLevel = state.HomeLevel,
		ShipLevel = state.ShipLevel,
		Containers = state.Containers,
		Journey = state.Journey,
		Upgrades = state.Upgrades,
		Inventory = state.Inventory,
	}
end

function QA.Plot(state)
	return workspace.Game.World.TravelIsland.Plots[(state or QA.Read()).PlotId]
end

function QA.Collect()
	local state = QA.Read()
	local plot = QA.Plot(state)
	if state.State == "ReturnPending" then
		QA.Move(plot.ShipAnchor, Vector3.new(0, 5, -10))
		state = QA.Do("ClaimReturn", { JourneyId = state.Journey.Id }).State
	end
	for _, container in ipairs(state.Containers) do
		QA.Move(plot.ContainerSlots.Slot1)
		state = QA.Do("OpenContainer", { ContainerId = container.Id }).State
	end
	return QA.Summary(state)
end

function QA.SellAndSupply(quantity)
	local state = QA.Read()
	QA.Move(workspace.Game.World.TravelIsland.Hub.ShopAnchor)
	if next(state.Inventory) then
		state = QA.Do("SellAll").State
	end
	if quantity and quantity > 0 then
		state = QA.Do("BuySupply", { Quantity = quantity }).State
	end
	return QA.Summary(state)
end

function QA.Depart()
	local state = QA.Read()
	while state.State == "Resting" do
		task.wait(0.5)
		state = QA.Read()
	end
	QA.Move(QA.Plot(state).ShipAnchor, Vector3.new(0, 5, -10))
	return QA.Summary(QA.Do("StartJourney", { SeaId = "shallow", DurationId = "shallow_short" }).State)
end
