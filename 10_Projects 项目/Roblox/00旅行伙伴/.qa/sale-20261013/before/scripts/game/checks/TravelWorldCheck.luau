--!nonstrict
-- 本地 Lune 行为检查：原生 Instance + 模拟 PivotTo/时钟；不代替 Studio Play 或物理验收。
-- 从项目根目录执行，读取真实生成配置及 rbxmx。
-- 此两行使用 Lune 的字符串模块入口；主项目依然使用 Roblox require 的规则。
-- selene: allow(incorrect_standard_library_use)
local fs = require("@lune/fs")
-- selene: allow(incorrect_standard_library_use)
local roblox = require("@lune/roblox")
local rootPath = ""
roblox.implementMethod("Model", "PivotTo", function(model, pivot)
	local delta = pivot * model.PrimaryPart.CFrame:Inverse()
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CFrame = delta * part.CFrame
			part.Position = part.CFrame.Position
		end
	end
end)
local world = roblox.deserializeModel(fs.readFile(rootPath .. "src/Workspace/TravelIsland.rbxmx"))[1]
for _, part in ipairs(world:GetDescendants()) do
	if part:IsA("BasePart") then
		part.Position = part.CFrame.Position
	end
end
local workspaceFolder = roblox.Instance.new("Folder")
workspaceFolder.Name = "Workspace"
local gameFolder = roblox.Instance.new("Folder")
gameFolder.Name = "Game"
gameFolder.Parent = workspaceFolder
local worldFolder = roblox.Instance.new("Folder")
worldFolder.Name = "World"
worldFolder.Parent = gameFolder
world.Parent = worldFolder
local runtimeFolder = roblox.Instance.new("Folder")
runtimeFolder.Name = "Runtime"
runtimeFolder.Parent = gameFolder
local manual = roblox.Instance.new("Part")
manual.Name = "ManualWorldKeep"
manual.Parent = worldFolder
local workspaceProxy = {
	FindFirstChild = function(_, name)
		return workspaceFolder:FindFirstChild(name)
	end,
	GetFullName = function()
		return "Workspace"
	end,
	GetServerTimeNow = function()
		return 1000
	end,
}
local templates = {}
for _, name in ipairs({
	"HomeLv1",
	"HomeLv2",
	"ShipLv1",
	"ShipLv2",
	"Frog",
	"Container",
	"PreparationStation",
	"PlotRuntime",
}) do
	templates["Models.TravelBuddy." .. name] = roblox.deserializeModel(
		fs.readFile(rootPath .. "src/ServerStorage/Game/Resources/Models/TravelBuddy/" .. name .. ".rbxmx")
	)[1]
end
local resources = {
	Get = function(_, _, path)
		return templates[path]
	end,
	Clone = function(_, _, path, parent)
		local result = templates[path]:Clone()
		result.Parent = parent
		return result
	end,
}
local settingsRows = assert(
	loadstring(fs.readFile(rootPath .. "src/ReplicatedStorage/Game/Shared/Config/Generated/TravelSettings.lua"))
)()
local config = { Settings = {}, HomeCapacityByLevel = {}, MaxShipLevel = 1 }
for key, row in pairs(settingsRows) do
	config.Settings[key] = row.Value
	local level = string.match(key, "^HomeCapacity(%d+)$")
	if level then
		config.HomeCapacityByLevel[tonumber(level)] = row.Value
	end
end
local upgradeRows = assert(
	loadstring(fs.readFile(rootPath .. "src/ReplicatedStorage/Game/Shared/Config/Generated/TravelUpgrades.lua"))
)()
for _, row in pairs(upgradeRows) do
	if row.Target == "Ship" then
		config.MaxShipLevel = math.max(config.MaxShipLevel, row.Level)
	end
end
local serviceSource = fs.readFile(rootPath .. "src/ServerScriptService/Server/Game/Services/TravelWorldService.lua")
local chunk = assert(loadstring(serviceSource))
setfenv(
	chunk,
	setmetatable({
		CFrame = roblox.CFrame,
		script = { Parent = { Parent = { Config = { TravelConfig = "Config" } } } },
		require = function(module)
			assert(module == "Config", "unexpected simulated module request")
			return config
		end,
		game = {
			GetService = function()
				return workspaceProxy
			end,
		},
	}, { __index = getfenv() })
)
local service = chunk()
service:Init({ Services = { ResourceService = resources }, Logger = { Info = function() end } })
service:Start()
local function makePlayer(id, displayName)
	local character = roblox.Instance.new("Model")
	local root = roblox.Instance.new("Part")
	root.Name = "HumanoidRootPart"
	root.Position = roblox.Vector3.new(0, 5, 0)
	root.Parent = character
	return { UserId = id, DisplayName = displayName or ("Tester" .. id), Character = character }
end

local function checkOwnerTags(record)
	assert(record.Runtime:GetAttribute("OwnerUserId") == record.Player.UserId, "runtime owner tag")
	assert(record.Runtime:GetAttribute("PlotId") == record.Plot.Id, "runtime plot tag")
	for _, model in ipairs({ record.Home, record.Ship, record.Frog, record.Preparation }) do
		assert(model:GetAttribute("OwnerUserId") == record.Player.UserId, "model owner tag")
		assert(model:GetAttribute("PlotId") == record.Plot.Id, "model plot tag")
		for _, prompt in ipairs(model:GetDescendants()) do
			if prompt:IsA("ProximityPrompt") then
				assert(prompt:GetAttribute("OwnerUserId") == record.Player.UserId, "prompt owner tag")
				assert(prompt:GetAttribute("PlotId") == record.Plot.Id, "prompt plot tag")
			end
		end
	end
	for id, entry in pairs(record.Containers) do
		assert(entry.Model:GetAttribute("OwnerUserId") == record.Player.UserId, "container owner tag")
		assert(entry.Model:GetAttribute("ContainerId") == id, "container ID tag")
		for _, prompt in ipairs(entry.Model:GetDescendants()) do
			if prompt:IsA("ProximityPrompt") then
				assert(prompt:GetAttribute("OwnerUserId") == record.Player.UserId, "container prompt owner tag")
				assert(prompt:GetAttribute("ContainerId") == id, "container prompt ID tag")
			end
		end
	end
end

local players = {}
for id = 1, 5 do
	players[id] = makePlayer(id)
end
for id = 1, 4 do
	assert(service:Assign(players[id]) == "Plot" .. id, "plot order")
end
assert(service:Assign(players[5]) == nil, "must enforce four plots")
assert(service:Assign(players[1]) == "Plot1", "duplicate assignment")
local base = {
	HomeLevel = 1,
	ShipLevel = 1,
	State = "HomeIdle",
	Containers = { { Id = "owner-one", SeaId = "Shallow" } },
	Upgrades = {},
}
service:Render(players[1], base)
service:Render(
	players[2],
	{ HomeLevel = 1, ShipLevel = 1, State = "HomeIdle", Containers = { { Id = "owner-two" } }, Upgrades = {} }
)
for id = 3, 4 do
	service:Render(players[id], {
		HomeLevel = 1,
		ShipLevel = 1,
		State = "HomeIdle",
		Containers = { { Id = "owner-" .. id } },
		Upgrades = {},
	})
end
for id = 1, 4 do
	checkOwnerTags(service._players[id])
	assert(
		(service:GetSpawnCFrame(players[id]).Position - service._players[id].Plot.SpawnAnchor.Position).Magnitude
			< 0.001,
		"own spawn"
	)
	local preparation = service._players[id].Preparation
	assert(
		(preparation.Root.CFrame.Position - service._players[id].Plot.PreparationAnchor.Position).Magnitude < 0.001,
		"preparation station follows its declared plot anchor"
	)
end
for requester = 1, 4 do
	for owner = 1, 4 do
		local player = players[requester]
		player.Character.HumanoidRootPart.Position = service._players[owner].Plot.PreparationAnchor.Position
		assert(
			service:CanInteract(player, "Bag") == (requester == owner),
			"four-player preparation ownership and distance matrix"
		)
	end
end

-- 公共收购台共享入口，但每位玩家都要用本人当前会话和服务端位置验证。
local sellAnchor = world.Hub.SellAnchor
local sellPrompt = sellAnchor.SellPrompt
assert(sellAnchor.Transparency == 1 and not sellAnchor.CanCollide, "sale anchor is independent of whitebox appearance")
assert(sellPrompt:GetAttribute("TravelAction") == "Sell", "sale prompt opens the dedicated sale panel")
for id = 1, 4 do
	local player = players[id]
	local playerRoot = player.Character.HumanoidRootPart
	playerRoot.Position = sellAnchor.Position
	assert(service:CanInteract(player, "Sell"), "all four residents may use the shared sale facility")
	playerRoot.Position = sellAnchor.Position + roblox.Vector3.new(14, 0, 0)
	assert(service:CanInteract(player, "Sell"), "sale range includes the 14-stud boundary")
	playerRoot.Position += roblox.Vector3.new(0.01, 0, 0)
	assert(not service:CanInteract(player, "Sell"), "sale range rejects positions outside its own boundary")
	playerRoot.Position = world.Hub.ShopAnchor.Position
	assert(service:CanInteract(player, "Shop"), "the supply shop keeps its existing public entry")
	assert(not service:CanInteract(player, "Sell"), "standing at the supply shop cannot substitute for the sale facility")
end
players[5].Character.HumanoidRootPart.Position = sellAnchor.Position
assert(not service:CanInteract(players[5], "Sell"), "an unassigned player cannot mutate assets at a public facility")

local saleCounter = world.Hub.SaleCounter
local saleAppearance = saleCounter:FindFirstChild("Appearance")
assert(saleAppearance, "sale counter has an independently replaceable appearance")
saleAppearance.Parent = nil
local saleReplacement = roblox.Instance.new("Folder")
saleReplacement.Name = "Appearance"
saleReplacement.Parent = saleCounter
for id = 1, 4 do
	players[id].Character.HumanoidRootPart.Position = sellAnchor.Position
	assert(service:CanInteract(players[id], "Sell"), "replacing sale appearance cannot change server interaction range")
end
assert(world.Hub.SellAnchor == sellAnchor and sellAnchor.SellPrompt == sellPrompt and sellPrompt.Enabled,
	"replacing sale appearance retains the same authority anchor and prompt")
saleReplacement:Destroy()
saleAppearance.Parent = saleCounter

local record = service._players[1]
assert(record.Home:FindFirstChild("House"), "home template")
assert(record.Ship:FindFirstChild("Mast") == nil, "lv1 should not have sail")
assert(record.Frog:FindFirstChild("Pupil-1"), "3D frog")
assert(record.Frog:GetAttribute("Role") == "Companion", "generic companion role is independent of model name")
assert(record.Frog.Root.CompanionTag.Label.Text == players[1].DisplayName .. " 的伙伴", "visible owner nameplate")
assert(record.Frog.Root.CompanionTag.Enabled, "home companion tag enabled")
local firstRoot = players[1].Character.HumanoidRootPart
firstRoot.Position = record.Plot.PreparationAnchor.Position + roblox.Vector3.new(14, 0, 0)
assert(service:CanInteract(players[1], "Bag"), "bag interaction includes the 14-stud boundary")
firstRoot.Position += roblox.Vector3.new(0.01, 0, 0)
assert(not service:CanInteract(players[1], "Bag"), "bag interaction rejects just outside its boundary")
firstRoot.Position = record.Plot.Slots[1].Position
assert(service:CanInteract(players[1], "OpenContainer", "owner-one"), "own container at slot")
assert(not service:CanInteract(players[1], "OpenContainer", "owner-two"), "foreign container")
for id = 3, 4 do
	firstRoot.Position = service._players[id].Plot.Slots[1].Position
	assert(not service:CanInteract(players[1], "OpenContainer", "owner-" .. id), "foreign container at its own anchor")
end
firstRoot.Position = roblox.Vector3.new(1000, 5, 1000)
assert(not service:CanInteract(players[1], "OpenContainer", "owner-one"), "must validate server distance")
firstRoot.Position = record.Plot.ShipAnchor.Position
assert(not service:CanInteract(players[1], "Voyage"), "direct dispatch interaction is retired")
assert(not service:CanInteract(players[1], "UnknownAction"), "unknown action")
assert(not record.Ship.ShipControl.VoyagePrompt.Enabled, "manual departure prompt remains disabled at home")

-- 准备站位只影响表现；外观和可选锚点的更换不能改变服务端交互入口或权威状态。
local preparing = table.clone(base)
preparing.State = "Preparing"
local companionAnchor = record.Preparation:FindFirstChild("CompanionAnchor")
assert(companionAnchor and companionAnchor:IsA("BasePart"), "preparation template provides an optional companion pose")
local function checkFrogHorizontalAnchor(anchor, message)
	local actual = record.Frog.Root.CFrame.Position
	local expected = anchor.CFrame.Position
	assert(math.abs(actual.X - expected.X) < 0.001 and math.abs(actual.Z - expected.Z) < 0.001, message)
end
service:Render(players[1], preparing)
checkFrogHorizontalAnchor(companionAnchor, "preparing companion waits at the preparation pose")
assert(record.State == "Preparing", "world renders the public preparation state")
assert(record.Ship.Hull.Transparency == 0, "preparing ship stays docked")
assert(not record.Ship.ShipControl.VoyagePrompt.Enabled, "preparing never enables a dispatch prompt")
firstRoot.Position = record.Plot.PreparationAnchor.Position
assert(service:CanInteract(players[1], "Bag"), "preparing keeps the stable bag interaction")

local appearance = record.Preparation:FindFirstChild("Appearance")
assert(appearance, "preparation separates appearance from interaction anchors")
local control = record.Preparation.ControlAnchor
appearance.Parent = nil
service:Render(players[1], preparing)
checkFrogHorizontalAnchor(companionAnchor, "removed appearance does not affect the companion pose")
assert(
	record.Preparation.ControlAnchor == control and control.BagPrompt.Enabled,
	"removed appearance keeps its bag prompt"
)
assert(service:CanInteract(players[1], "Bag"), "removed appearance keeps server bag range")
local replacementAppearance = roblox.Instance.new("Folder")
replacementAppearance.Name = "Appearance"
replacementAppearance.Parent = record.Preparation
service:Render(players[1], preparing)
assert(
	record.State == "Preparing" and record.Preparation.ControlAnchor == control,
	"replacement appearance cannot change business state or anchors"
)
checkFrogHorizontalAnchor(companionAnchor, "replacement appearance does not affect the companion pose")
assert(service:CanInteract(players[1], "Bag"), "replacement appearance keeps server bag range")
replacementAppearance:Destroy()
appearance.Parent = record.Preparation

companionAnchor.Parent = nil
service:Render(players[1], preparing)
checkFrogHorizontalAnchor(record.Home.FrogAnchor, "missing optional preparation pose falls back to home")
assert(record.State == "Preparing", "missing pose cannot change the preparation state")
assert(service:CanInteract(players[1], "Bag"), "missing pose cannot change bag permission")
companionAnchor.Parent = record.Preparation
service:Render(players[1], preparing)
checkFrogHorizontalAnchor(companionAnchor, "restored optional pose is usable again")
checkOwnerTags(record)
service:Render(players[1], base)
checkFrogHorizontalAnchor(record.Home.FrogAnchor, "home idle uses the home pose")
assert(not record.Ship.ShipControl.VoyagePrompt.Enabled, "leaving preparation never re-enables manual dispatch")

local voyage = {
	HomeLevel = 1,
	ShipLevel = 1,
	State = "Voyaging",
	Journey = { Id = "v1", StartAt = 1000, EndAt = 1020 },
	Containers = {},
	Upgrades = {},
}
service:Render(players[1], voyage)
service:Step(1003)
assert(record.Ship.Root.CFrame.Position.Z > record.Plot.ShipAnchor.Position.Z, "departure motion")
service:Step(1007)
assert(record.Ship.Hull.Transparency == 1, "away boat hidden")
assert(record.Frog.Body.Transparency == 1, "away frog hidden")
assert(not record.Frog.Root.CompanionTag.Enabled, "away companion must not leave a floating nameplate")
assert(record.Preparation.ControlAnchor.BagPrompt.Enabled, "bag remains readable while companion is away")
assert(not record.Ship.ShipControl.VoyagePrompt.Enabled, "cannot voyage twice")
assert(service._players[2].Ship.Hull.Transparency == 0, "other player stays independent")
voyage.State = "Returning"
service:Render(players[1], voyage)
service:Step(1027)
assert(record.Ship.Hull.Transparency == 0, "boat recovered from clock")
assert(record.DepartureSeconds == math.min(config.Settings.DepartureSeconds, 20 / 3), "config capped departure")
assert(record.ReturnSeconds == math.min(config.Settings.ReturnSeconds, 20 / 3), "config capped return")
assert(not record.Ship.ShipControl.ClaimReturnPrompt.Enabled, "automatic deposit never enables manual claiming")
assert(not record.Ship.ShipControl.VoyagePrompt.Enabled, "claim and voyage are mutually exclusive")
assert(record.Frog.Body.Transparency == 0, "frog returned home")
assert(record.Frog.Root.CompanionTag.Enabled, "nameplate reappears at home")
assert(
	math.abs(record.Frog.Root.CFrame.Position.Z - record.Home.FrogAnchor.CFrame.Position.Z) < 0.001,
	"frog home anchor"
)
service:Render(players[1], {
	HomeLevel = 1,
	ShipLevel = 1,
	State = "Voyaging",
	Journey = { Id = "short", StartAt = 1000, EndAt = 1003 },
	DepartureSeconds = 1,
	ReturnSeconds = 1,
	Containers = {},
	Upgrades = {},
})
service:Step(1001.1)
assert(record.Ship.Hull.Transparency == 1, "short Studio trip leaves the island")
-- 收获已经入库并进入休息，船仍应走完同一靠岸窗口。
service:Render(players[1], {
	HomeLevel = 1,
	ShipLevel = 1,
	State = "Resting",
	Journey = { Id = "short", StartAt = 1000, EndAt = 1003 },
	DepartureSeconds = 1,
	ReturnSeconds = 1,
	Containers = {},
	Upgrades = {},
})
service:Step(1003.4)
assert(record.Ship.Root.CFrame.Position.Z > record.Plot.ShipAnchor.Position.Z, "settlement cannot skip docking motion")
assert(not record.Ship.ShipControl.VoyagePrompt.Enabled, "return motion still blocks departure")
service:Step(1004.1)
assert(record.Ship.Hull.Transparency == 0, "short Studio trip returns in one second")
service:Render(players[1], {
	HomeLevel = 2,
	ShipLevel = 2,
	State = "HomeIdle",
	Containers = { { Id = "one" }, { Id = "two" }, { Id = "three" }, { Id = "four" }, { Id = "five" }, { Id = "six" } },
	Upgrades = { Home = { Id = "h" } },
})
assert(record.Ship:FindFirstChild("Sail"), "lv2 sail template")
local count = 0
for _, entry in pairs(record.Containers) do
	count += 1
	assert(entry.Model:GetAttribute("Quality") == nil, "no hidden content attribute")
end
assert(count == 6, "level2 six slots")
assert(record.Home.ConstructionSign.SignGui.Enabled, "construction status")
checkOwnerTags(record)
local departingPreparation = record.Preparation
service:Release(players[1])
assert(service:GetPlotId(players[1]) == nil, "release owner")
assert(departingPreparation.Parent == nil, "departing player's preparation station is removed")
assert(service:Assign(players[5]) == "Plot1", "free plot reused")
assert(manual.Parent == worldFolder, "manual world retained")
assert(service._players[2].Home.Parent ~= nil, "other plot retained")
assert(service._players[2].Preparation.Parent ~= nil, "other preparation station retained")

-- 同账号新旧 Player 实例不能共享记录；新会话补位后，旧清理/旧渲染都应无效。
local oldPlayer = players[2]
local replacement = makePlayer(oldPlayer.UserId, "Rejoined")
replacement.Character.HumanoidRootPart.Position = service._players[2].Plot.Slots[1].Position
assert(service:Assign(replacement) == nil, "different Player instance cannot take a live account record")
assert(service:GetPlotId(replacement) == nil, "unassigned duplicate Player has no plot")
assert(service:GetSpawnCFrame(replacement) == nil, "unassigned duplicate Player has no spawn")
assert(
	not service:CanInteract(replacement, "OpenContainer", "owner-two"),
	"unassigned duplicate Player cannot interact"
)
replacement.Character.HumanoidRootPart.Position = service._players[2].Plot.PreparationAnchor.Position
assert(not service:CanInteract(replacement, "Bag"), "unassigned duplicate Player cannot change the bag")
local oldPreparation = service._players[2].Preparation
service:Release(oldPlayer)
assert(oldPreparation.Parent == nil, "previous session preparation is removed")
assert(service:Assign(replacement) == "Plot2", "same account rejoin takes released plot")
service:Render(replacement, {
	HomeLevel = 1,
	ShipLevel = 1,
	State = "HomeIdle",
	Containers = { { Id = "rejoined-two" } },
	Upgrades = {},
})
local replacementRecord = service._players[2]
local replacementRuntime = replacementRecord.Runtime
local replacementPreparation = replacementRecord.Preparation
service:Release(oldPlayer)
service:Render(oldPlayer, { HomeLevel = 2, ShipLevel = 2, State = "Voyaging", Containers = {}, Upgrades = {} })
assert(service._players[2] == replacementRecord, "late old cleanup retained replacement record")
assert(replacementRuntime.Parent == service._runtime, "late old cleanup retained replacement runtime")
assert(replacementPreparation.Parent == replacementRuntime, "late old cleanup retained replacement preparation")
assert(replacementRecord.HomeLevel == 1, "stale render cannot change replacement world")
assert(replacementRecord.Containers["rejoined-two"] ~= nil, "stale render cannot clear replacement containers")
assert(service:GetPlotId(oldPlayer) == nil, "old Player has no new session plot")
assert(service:GetSpawnCFrame(oldPlayer) == nil, "old Player has no new session spawn")
assert(
	not service:CanInteract(oldPlayer, "OpenContainer", "rejoined-two"),
	"old Player cannot use replacement container"
)
assert(service:CanInteract(replacement, "OpenContainer", "rejoined-two"), "replacement can use own container")
replacement.Character.HumanoidRootPart.Position = replacementRecord.Plot.PreparationAnchor.Position
assert(service:CanInteract(replacement, "Bag"), "replacement can use own preparation station")
assert(not service:CanInteract(oldPlayer, "Bag"), "old Player cannot use replacement preparation station")
checkOwnerTags(replacementRecord)

-- Studio 本地多客户端使用负 UserId；它们应与正式服正 ID 一样各占一个地块。
service:Release(players[5])
service:Release(replacement)
service:Release(players[3])
service:Release(players[4])
local studioPlayers = {}
for index = 1, 4 do
	local player = makePlayer(-index, "StudioPlayer" .. index)
	studioPlayers[index] = player
	assert(service:Assign(player) == "Plot" .. index, "negative UserId owns one distinct plot")
	service:Render(player, {
		HomeLevel = 1,
		ShipLevel = 1,
		State = "HomeIdle",
		Containers = { { Id = "studio-" .. index } },
		Upgrades = {},
	})
	checkOwnerTags(service._players[player.UserId])
end
for requester = 1, 4 do
	for owner = 1, 4 do
		local player = studioPlayers[requester]
		player.Character.HumanoidRootPart.Position = service._players[-owner].Plot.Slots[1].Position
		assert(
			service:CanInteract(player, "OpenContainer", "studio-" .. owner) == (requester == owner),
			"four-client container ownership matrix"
		)
		player.Character.HumanoidRootPart.Position = service._players[-owner].Plot.PreparationAnchor.Position
		assert(
			service:CanInteract(player, "Bag") == (requester == owner),
			"four-client preparation ownership and distance matrix"
		)
	end
end
local studioReplacement = makePlayer(-5, "StudioReplacement")
assert(service:Assign(studioReplacement) == nil, "negative ID fifth player refused")
service:Release(studioPlayers[3])
assert(service:Assign(studioReplacement) == "Plot3", "new negative ID fills released plot")
for _, player in ipairs(studioPlayers) do
	service:Release(player)
end
service:Release(studioReplacement)
assert(#service._runtime:GetChildren() == 0, "all departed players leave no runtime clones")
assert(next(service._visuals) == nil, "all departed players leave no visual cache entries")
print(
	"TRAVEL_WORLD_SERVICE_OK: four plots, bag ownership/range matrix, preparation pose fallback, replaceable appearance, retired dispatch, levels, clock return, cleanup, session guard, negative Studio IDs, vacancy refill"
)
