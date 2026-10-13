--!nonstrict
-- 从项目根目录执行，检查原生模型结构、Template、Archivable 与交互元数据。
-- 此两行使用 Lune 的字符串模块入口；主项目依然使用 Roblox require 的规则。
-- selene: allow(incorrect_standard_library_use)
local fs = require("@lune/fs")
-- selene: allow(incorrect_standard_library_use)
local roblox = require("@lune/roblox")
local root = ""
local paths = {
	"src/Workspace/TravelIsland.rbxmx",
	"src/ServerStorage/Game/Resources/Models/TravelBuddy/HomeLv1.rbxmx",
	"src/ServerStorage/Game/Resources/Models/TravelBuddy/HomeLv2.rbxmx",
	"src/ServerStorage/Game/Resources/Models/TravelBuddy/ShipLv1.rbxmx",
	"src/ServerStorage/Game/Resources/Models/TravelBuddy/ShipLv2.rbxmx",
	"src/ServerStorage/Game/Resources/Models/TravelBuddy/Frog.rbxmx",
	"src/ServerStorage/Game/Resources/Models/TravelBuddy/Container.rbxmx",
	"src/ServerStorage/Game/Resources/Models/TravelBuddy/PreparationStation.rbxmx",
	"src/ServerStorage/Game/Resources/Models/TravelBuddy/PlotRuntime.rbxmx",
}
local settings =
	assert(loadstring(fs.readFile("src/ReplicatedStorage/Game/Shared/Config/Generated/TravelSettings.lua")))()
local maxSlots = 0
for key, row in pairs(settings) do
	if string.match(key, "^HomeCapacity%d+$") then
		maxSlots = math.max(maxSlots, row.Value)
	end
end

local function checkActivePromptBindings(model)
	local active = {}
	for _, prompt in ipairs(model:GetDescendants()) do
		if prompt:IsA("ProximityPrompt") and prompt.Enabled then
			assert(prompt.Parent:IsA("BasePart"), "native prompt requires a declared part anchor")
			local position = prompt.Parent.CFrame.Position
			for _, previous in ipairs(active) do
				if (position - previous.Position).Magnitude < 0.0001 then
					local prefix = "active prompts share a key at one anchor: " .. model.Name .. " "
					assert(prompt.KeyboardKeyCode ~= previous.Prompt.KeyboardKeyCode, prefix .. "keyboard")
					assert(prompt.GamepadKeyCode ~= previous.Prompt.GamepadKeyCode, prefix .. "gamepad")
				end
			end
			table.insert(active, { Prompt = prompt, Position = position })
		end
	end
end

local function checkPreparation(model)
	local control = model:FindFirstChild("ControlAnchor")
	assert(control and control:IsA("BasePart"), "preparation requires a stable control anchor outside appearance")
	assert(control.Transparency == 1 and not control.CanCollide, "preparation control anchor cannot block walking")
	local prompts = {}
	for _, descendant in ipairs(model:GetDescendants()) do
		if descendant:IsA("ProximityPrompt") then
			table.insert(prompts, descendant)
		end
	end
	assert(#prompts == 1, "preparation has exactly one interaction entry")
	assert(prompts[1].Parent == control, "preparation prompt stays on the control anchor")
	assert(prompts[1]:GetAttribute("TravelAction") == "Bag", "preparation prompt opens the bag")
end

for _, path in ipairs(paths) do
	local models = roblox.deserializeModel(fs.readFile(root .. path))
	assert(#models == 1, "one native root required")
	local model = models[1]
	assert(model:GetAttribute("OwnerUserId") == nil, "source root cannot retain a runtime owner")
	assert(model:GetAttribute("ContainerId") == nil, "source root cannot retain a runtime container ID")
	assert(model:GetAttribute("Quality") == nil, "native root cannot expose hidden container quality")
	local count = 0
	for _, descendant in ipairs(model:GetDescendants()) do
		assert(descendant.Archivable, "unarchivable child")
		assert(descendant:GetAttribute("OwnerUserId") == nil, "source template cannot retain a runtime owner")
		assert(descendant:GetAttribute("ContainerId") == nil, "source template cannot retain a runtime container ID")
		assert(descendant:GetAttribute("Quality") == nil, "native model cannot expose hidden container quality")
		if descendant:IsA("ProximityPrompt") then
			assert(type(descendant:GetAttribute("TravelAction")) == "string", "prompt action missing")
			count += 1
		end
	end
	if model.Name ~= "TravelIsland" then
		assert(model:GetAttribute("Template") == true, "missing Template=true")
	else
		assert(
			#model.Plots:GetChildren() == settings.MaxPlayers.Value,
			"native plot count must match max players config"
		)
		for index = 1, settings.MaxPlayers.Value do
			local plot = model.Plots:FindFirstChild("Plot" .. index)
			assert(plot ~= nil, "native plot missing")
			local preparationAnchor = plot:FindFirstChild("PreparationAnchor")
			assert(
				preparationAnchor and preparationAnchor:IsA("BasePart"),
				"each plot needs a stable preparation anchor"
			)
			assert(
				preparationAnchor.Transparency == 1 and not preparationAnchor.CanCollide,
				"plot preparation anchor is invisible"
			)
			assert(#plot.ContainerSlots:GetChildren() == maxSlots, "native slot count must match home capacity config")
			for slot = 1, maxSlots do
				assert(plot.ContainerSlots:FindFirstChild("Slot" .. slot) ~= nil, "native container slot missing")
			end
		end
	end
	if model:IsA("Model") then
		assert(model.PrimaryPart.Name == "Root", "stable origin required")
		assert(math.abs(model.PrimaryPart.Size.X - 0.1) < 0.0001, "size was not decoded")
	end
	checkActivePromptBindings(model)
	if model.Name == "Frog" then
		local tag = model.Root:FindFirstChild("CompanionTag")
		assert(tag and tag:IsA("BillboardGui") and tag.Enabled, "companion needs its native nameplate")
		assert(tag:FindFirstChild("Label") and tag.Label:IsA("TextLabel"), "companion label contract")
		assert(tag.MaxDistance == 80, "companion label has a bounded island range")
	end
	if model.Name == "PreparationStation" then
		checkPreparation(model)
		local replacement = model:Clone()
		local appearance = replacement:FindFirstChild("Appearance")
		assert(appearance, "preparation appearance must have its own replaceable folder")
		appearance:Destroy()
		checkPreparation(replacement)
		replacement:Destroy()
	end
	if model.Name == "ShipLv1" or model.Name == "ShipLv2" then
		local control = model.ShipControl
		assert(control.VoyagePrompt.KeyboardKeyCode == roblox.Enum.KeyCode.E, "voyage keeps E")
		assert(control.ClaimReturnPrompt.KeyboardKeyCode == roblox.Enum.KeyCode.E, "claim keeps E")
		assert(control.ShipUpgradePrompt.KeyboardKeyCode == roblox.Enum.KeyCode.F, "ship upgrade uses F")
		assert(control.ShipUpgradePrompt.GamepadKeyCode == roblox.Enum.KeyCode.ButtonY, "ship upgrade uses ButtonY")
		assert(not control.ClaimReturnPrompt.Enabled, "claim and voyage cannot be active together in template")
		assert(not control.VoyagePrompt.Enabled, "autonomous travel must disable the old dispatch prompt")
		-- 负例只修改离线副本，确保检查能拒绝旧的 E 冲突和手柄冲突。
		local conflict = model:Clone()
		conflict.ShipControl.VoyagePrompt.Enabled = true
		conflict.ShipControl.ShipUpgradePrompt.KeyboardKeyCode = roblox.Enum.KeyCode.E
		assert(not pcall(checkActivePromptBindings, conflict), "keyboard conflict was not detected")
		conflict.ShipControl.ShipUpgradePrompt.KeyboardKeyCode = roblox.Enum.KeyCode.F
		conflict.ShipControl.ShipUpgradePrompt.GamepadKeyCode = roblox.Enum.KeyCode.ButtonX
		assert(not pcall(checkActivePromptBindings, conflict), "gamepad conflict was not detected")
		conflict:Destroy()
	end
	print(model.Name .. " NATIVE_OK nodes=" .. #model:GetDescendants() .. " prompts=" .. count)
end
