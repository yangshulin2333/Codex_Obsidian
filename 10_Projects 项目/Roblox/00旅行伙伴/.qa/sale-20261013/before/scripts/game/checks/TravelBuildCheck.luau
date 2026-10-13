-- 校验最终 Place 的实际树和脚本编译；没有执行 Roblox 引擎 Play。
local fs = require("@lune/fs")
local roblox = require("@lune/roblox")
local luau = require("@lune/luau")
local place = roblox.deserializePlace(fs.readFile("build/TravelBuddy-Demo.rbxlx"))
local function node(path)
	local current = place
	for segment in string.gmatch(path, "[^.]+") do
		current = assert(current:FindFirstChild(segment), "Missing built node: " .. path)
	end
	return current
end
assert(node("ServerScriptService.UnitTestRunner").Disabled, "ordinary Play must not run unit tests")
assert(node("ReplicatedStorage.Game.Resources.UI.TravelBuddy.TravelHUD"):IsA("ScreenGui"))
assert(node("ReplicatedStorage.Game.Resources.UI.TravelBuddy.TravelWindow"):IsA("ScreenGui"))
assert(
	node("ReplicatedStorage.Game.Shared.Config.Generated"):FindFirstChild("TravelWeights") == nil,
	"hidden weights must stay server-side"
)
assert(node("ServerScriptService.Server.Game.Config.Generated.TravelWeights"):IsA("ModuleScript"))
assert(node("ServerScriptService.ServerPackages.ProfileStore"):IsA("ModuleScript"))
assert(node("ServerScriptService.ServerPackages"):FindFirstChild("_Index") == nil)
assert(node("Workspace.Game.Runtime"):IsA("Folder"))
assert(#node("Workspace.Game.World.TravelIsland.Plots"):GetChildren() == 4)
for index = 1, 4 do
	local plot = node("Workspace.Game.World.TravelIsland.Plots.Plot" .. index)
	assert(plot.HomeAnchor:IsA("BasePart") and plot.ShipAnchor:IsA("BasePart"))
	assert(plot.SpawnAnchor:IsA("BasePart") and plot.DepartureEnd:IsA("BasePart"))
	assert(#plot.ContainerSlots:GetChildren() == 6)
end
for _, name in ipairs({ "HomeLv1", "HomeLv2", "ShipLv1", "ShipLv2", "Frog", "Container", "PlotRuntime" }) do
	local template = node("ServerStorage.Game.Resources.Models.TravelBuddy." .. name)
	assert(template.Archivable and template:GetAttribute("Template") == true, "Template missing: " .. name)
end
local scriptCount = 0
for _, item in ipairs(place:GetDescendants()) do
	if item:IsA("LuaSourceContainer") then
		luau.compile(item.Source)
		scriptCount += 1
	end
end
local services = node("ServerScriptService.Server.Game.Runtime.GameServiceList").Source
assert(string.find(services, "TravelWorldService", 1, true) and string.find(services, "TravelService", 1, true))
assert(
	string.find(
		node("StarterPlayer.StarterPlayerScripts.Client.Game.Runtime.GameControllerList").Source,
		"TravelController",
		1,
		true
	)
)
assert(
	string.find(
		node("ReplicatedStorage.Module.Shared.Config.StorageConfig").Source,
		'StorageConfig.Backend = "ProfileStore"',
		1,
		true
	)
)
print(
	"TRAVEL_BUILD_OK: four plots, native templates/UI, private weights, explicit registration, persistent backend selection, disabled tests; compiled "
		.. scriptCount
		.. " scripts"
)
