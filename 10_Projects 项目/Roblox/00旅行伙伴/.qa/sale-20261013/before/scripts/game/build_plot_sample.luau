--!nonstrict
-- 从项目根目录用 Rokit Lune 执行；只构建布局走查 Place，不接入玩法或玩家存档。
-- selene: allow(incorrect_standard_library_use)
local fs = require("@lune/fs")
-- selene: allow(incorrect_standard_library_use)
local roblox = require("@lune/roblox")

local outputPath = "build/TravelBuddy-Plot1-Whitebox.rbxlx"
local resourcePath = "src/ServerStorage/Game/Resources/Models/TravelBuddy/"

local function readModel(path)
	local models = roblox.deserializeModel(fs.readFile(path))
	assert(#models == 1 and models[1]:IsA("Model"), "expected one Model: " .. path)
	return models[1]
end

local function placeModel(name, parent, target)
	local model = readModel(resourcePath .. name .. ".rbxmx")
	assert(model.PrimaryPart, "missing template PrimaryPart: " .. name)
	local delta = target * model.PrimaryPart.CFrame:Inverse()
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CFrame = delta * part.CFrame
			part.Position = part.CFrame.Position
		end
	end
	model:SetAttribute("LayoutPreview", true)
	if name == "HomeLv2" or name == "ShipLv2" then
		model:SetAttribute("PreviewLevel", 2)
	end
	model.Parent = parent
	return model
end

local function labelText(part, text)
	assert(part, "missing preview sign")
	local label = part:FindFirstChild("SignGui"):FindFirstChild("Label")
	assert(label and label:IsA("TextLabel"), "missing preview sign label")
	label.Text = text
end

local dataModel = roblox.Instance.new("DataModel")
dataModel:SetAttribute("LayoutPreview", true)
local workspace = dataModel:GetService("Workspace")
local gameFolder = roblox.Instance.new("Folder")
gameFolder.Name = "Game"
gameFolder.Parent = workspace
local worldFolder = roblox.Instance.new("Folder")
worldFolder.Name = "World"
worldFolder.Parent = gameFolder
local island = readModel("src/Workspace/TravelIsland.rbxmx")
island.Parent = worldFolder
island:SetAttribute("LayoutPreview", true)

local plot = island:FindFirstChild("Plots"):FindFirstChild("Plot1")
assert(plot, "missing Plot1")
local display = roblox.Instance.new("Folder")
display.Name = "SampleModels"
display.Parent = plot
display:SetAttribute("LayoutPreview", true)
local home = placeModel("HomeLv2", display, plot:FindFirstChild("HomeAnchor").CFrame)
local ship = placeModel("ShipLv2", display, plot:FindFirstChild("ShipAnchor").CFrame)
placeModel("Frog", display, home:FindFirstChild("FrogAnchor").CFrame)
placeModel("PreparationStation", display, plot:FindFirstChild("PreparationAnchor").CFrame)
for index = 1, 6 do
	local anchor = plot:FindFirstChild("ContainerSlots"):FindFirstChild("Slot" .. index)
	assert(anchor, "missing container anchor")
	local container = placeModel("Container", display, anchor.CFrame)
	container.Name = "SampleContainer" .. index
	container:SetAttribute("PreviewSlot", index)
	assert(container:GetAttribute("Quality") == nil, "preview boxes must remain neutral")
end

labelText(island.Hub.Guide, "白模场景走查\n住宅 → 准备区 → 箱区 → 船位\n功能待逐步接入")
labelText(island.Decor.PlotSign1, "1 号旅行家 · 布局示意\nLv.2 住宅 / 船 · 六箱位")
labelText(home.HomeSign, "住宅 Lv.2 · 布局示意\n六个箱位")
labelText(ship.ShipSign, "船 Lv.2 · 布局示意")

local spawn = roblox.Instance.new("SpawnLocation")
spawn.Name = "WhiteboxWalkSpawn"
spawn.Anchored = true
spawn.CanCollide = false
spawn.CanTouch = false
spawn.CanQuery = false
spawn.Transparency = 1
spawn.Size = roblox.Vector3.new(6, 0.1, 6)
spawn.CFrame = roblox.CFrame.new(-54, 2.08, 16)
spawn.Position = spawn.CFrame.Position
spawn.Neutral = true
spawn.Enabled = true
spawn.Duration = 0
spawn.Parent = workspace
spawn:SetAttribute("LayoutPreview", true)

-- 保存打开文件时的编辑视角；Play 时仍交给 Roblox 默认玩家相机。
local camera = roblox.Instance.new("Camera")
camera.Name = "WhiteboxCamera"
camera.CameraType = roblox.Enum.CameraType.Custom
camera.FieldOfView = 60
local focus = roblox.Vector3.new(-54, 3, 20)
camera.CFrame = roblox.CFrame.lookAt(roblox.Vector3.new(-84, 42, 93), focus)
camera.Focus = roblox.CFrame.new(focus)
camera.Parent = workspace
workspace.CurrentCamera = camera

local lighting = dataModel:GetService("Lighting")
lighting.ClockTime = 14
lighting.Brightness = 2
lighting.Ambient = roblox.Color3.fromRGB(170, 180, 190)
lighting.OutdoorAmbient = roblox.Color3.fromRGB(190, 200, 210)

local function validate(place)
	local previewIsland = place:GetService("Workspace").Game.World.TravelIsland
	local plots = previewIsland.Plots
	local models = plots.Plot1.SampleModels
	assert(#models:GetChildren() == 10, "expected home, ship, companion, preparation station and six containers")
	assert(models.HomeLv2 and models.HomeLv2.Chimney, "expected Lv2 home display")
	assert(models.ShipLv2 and models.ShipLv2.Sail, "expected Lv2 ship display")
	assert(models.Frog and models.Frog.Body, "expected one companion display")
	local preparation = models:FindFirstChild("PreparationStation")
	assert(preparation and preparation:GetAttribute("LayoutPreview") == true, "expected preparation station preview")
	assert(
		(preparation.Root.CFrame.Position - plots.Plot1.PreparationAnchor.CFrame.Position).Magnitude < 0.001,
		"preview preparation station follows the plot anchor"
	)
	assert(preparation.ControlAnchor.BagPrompt:GetAttribute("TravelAction") == "Bag", "preview keeps stable bag entry")
	assert(
		(models.Frog.Root.CFrame.Position - models.HomeLv2.FrogAnchor.CFrame.Position).Magnitude < 0.001,
		"preview companion follows the home anchor"
	)
	for index = 1, 6 do
		local container = models:FindFirstChild("SampleContainer" .. index)
		assert(container and container:GetAttribute("Quality") == nil, "expected six neutral containers")
	end
	for index = 2, 4 do
		assert(plots:FindFirstChild("Plot" .. index), "missing vacant plot")
		assert(not plots:FindFirstChild("Plot" .. index):FindFirstChild("SampleModels"), "keep vacant plots")
	end
	local spawnLocation = place:GetService("Workspace").WhiteboxWalkSpawn
	assert(
		spawnLocation:IsA("SpawnLocation") and spawnLocation.Enabled and spawnLocation.Duration == 0,
		"preview keeps its walkable spawn"
	)
	assert(spawnLocation.Transparency == 1 and not spawnLocation.CanCollide, "preview spawn remains invisible")
	local savedWorkspace = place:GetService("Workspace")
	local savedCamera = savedWorkspace.WhiteboxCamera
	assert(savedWorkspace.CurrentCamera == savedCamera, "missing saved editor camera reference")
	assert(
		savedCamera.CameraType == roblox.Enum.CameraType.Custom and savedCamera.FieldOfView == 60,
		"preview keeps its editor camera configuration"
	)
	assert(
		(savedCamera.CFrame.Position - roblox.Vector3.new(-84, 42, 93)).Magnitude < 0.001,
		"preview keeps its editor camera position"
	)
	assert(
		(savedCamera.Focus.Position - roblox.Vector3.new(-54, 3, 20)).Magnitude < 0.001,
		"preview keeps its editor camera focus"
	)
	local promptCount = 0
	for _, instance in ipairs(place:GetDescendants()) do
		assert(not instance:IsA("LuaSourceContainer"), "layout Place must not contain scripts")
		if instance:IsA("ProximityPrompt") then
			assert(not instance.Enabled, "layout Place must not expose active prompts")
			promptCount += 1
		end
	end
	return promptCount
end

for _, instance in ipairs(dataModel:GetDescendants()) do
	if instance:IsA("ProximityPrompt") then
		instance.Enabled = false
		instance:SetAttribute("LayoutPreview", true)
	end
end
local promptCount = validate(dataModel)
if not fs.isDir("build") then
	fs.writeDir("build")
end
fs.writeFile(outputPath, roblox.serializePlace(dataModel, true))
assert(validate(roblox.deserializePlace(fs.readFile(outputPath))) == promptCount, "Place round-trip validation")
print("PLOT_SAMPLE_BUILD_OK: " .. outputPath)
print("LAYOUT_ONLY: Lv2 home/ship, one companion, preparation station, six neutral containers, three vacant plots")
print("PREVIEW_CHECK_OK: " .. promptCount .. " disabled prompts, invisible walk spawn, no scripts or player data")
