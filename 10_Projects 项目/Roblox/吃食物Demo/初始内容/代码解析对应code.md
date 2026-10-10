```
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local CONFIG = {
	DropCount = 12,
	EatRadius = 30,
	RespawnSeconds = 8,
	DefaultWalkSpeed = 16,
	BoostWalkSpeed = 32,
	BoostDuration = 8,
	BoostCooldown = 2,
	DefaultBodyScale = 1,
	MuscleScaleDivisor = 1500,
	MaxBodyScale = 3.5,
	ScaleUpdateDelay = 0.45,
	MinScaleDelta = 0.035,
	Version = "v0.4.0",
}

print("[EatDemo] server boot", CONFIG.Version)

--工具函数，确保文件夹存在，如果不存在则创建一个
local function ensureFolder(parent, name) --比如 (ReplicatedStorage, "Msg")
	local folder = parent:FindFirstChild(name)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = name
		folder.Parent = parent
	end
	return folder
end
--工具函数，确保RemoteEvent存在，如果不存在则创建一个
local function ensureRemoteEvent(parent, name)--(msgFolder, "吃")
	local remote = parent:FindFirstChild(name)
	if not remote then
		remote = Instance.new("RemoteEvent")
		remote.Name = name
		remote.Parent = parent
	end
	return remote
end


--创建6个RemoteEvent通信函数
local msgFolder = ensureFolder(ReplicatedStorage, "Msg")
local serverMsgFolder = ensureFolder(ReplicatedStorage, "ServerMsg")
local eatEvent = ensureRemoteEvent(msgFolder, "吃")
local boostEvent = ensureRemoteEvent(msgFolder, "加速")
local sizeEvent = ensureRemoteEvent(msgFolder, "尺寸")
local eatResultEvent = ensureRemoteEvent(serverMsgFolder, "EatResult")
local boostResultEvent = ensureRemoteEvent(serverMsgFolder, "BoostResult")
local sizeResultEvent = ensureRemoteEvent(serverMsgFolder, "SizeResult")

--创建3个文件夹
local dropFolder = ensureFolder(workspace, "掉落物")
local centerDropFolder = ensureFolder(workspace, "掉落物Center")
local vipDropFolder = ensureFolder(workspace, "掉落物VIP")

--创建表
local dropFoldersByName = {
	["掉落物"] = dropFolder,
	["掉落物Center"] = centerDropFolder,
	["掉落物VIP"] = vipDropFolder,
}

--定义
local nextDropId = 0
local seededDropCount = 0
local boostExpiresAtByPlayer = {}
local lastBoostRequestAtByPlayer = {}
local scaleUpdateScheduledByPlayer = {}

local function getLeaderstat(player, statName)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
	end

	local value = leaderstats:FindFirstChild(statName)
	if not value then
		value = Instance.new("IntValue")
		value.Name = statName
		value.Value = 0
		value.Parent = leaderstats
	end

	return value
end

local function makeDropModel(folder, position, addAttr, addMoney, color)
	nextDropId += 1
	seededDropCount += 1

	local model = Instance.new("Model")
	model.Name = tostring(nextDropId)
	model:SetAttribute("HasEat", 0)
	model:SetAttribute("InitScale", 1)

	local part = Instance.new("Part")
	part.Name = "Food"
	part.Shape = Enum.PartType.Ball
	part.Size = Vector3.new(2.6, 2.6, 2.6)
	part.Position = position
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = true
	part.Material = Enum.Material.SmoothPlastic
	part.Color = color
	part.Transparency = 0
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part:SetAttribute("addAttr", addAttr)
	part:SetAttribute("addMoney", addMoney)
	part:SetAttribute("baseColorR", math.floor(color.R * 255))
	part:SetAttribute("baseColorG", math.floor(color.G * 255))
	part:SetAttribute("baseColorB", math.floor(color.B * 255))
	part.Parent = model

	model.PrimaryPart = part
	model.Parent = folder

	return model
end

local function seedDrops()
	for _, folder in ipairs({ dropFolder, centerDropFolder, vipDropFolder }) do
		for _, child in ipairs(folder:GetChildren()) do
			child:Destroy()
		end
	end

	nextDropId = 0
	seededDropCount = 0

	for index = 1, CONFIG.DropCount do
		local x = ((index - 1) % 6) * 8 - 20
		local z = math.floor((index - 1) / 6) * 8 + 10
		makeDropModel(
			dropFolder,
			Vector3.new(x, 3, z),
			5 + index,
			2 + math.floor(index / 2),
			Color3.fromRGB(238, 241, 245)
		)
	end

	makeDropModel(centerDropFolder, Vector3.new(0, 3, -10), 40, 20, Color3.fromRGB(246, 196, 83))
	makeDropModel(vipDropFolder, Vector3.new(12, 3, -10), 80, 40, Color3.fromRGB(93, 145, 225))

	print("[EatDemo] seeded drops", seededDropCount)
end

local function sendResult(player, ok, message, payload)
	payload = payload or {}
	payload.ok = ok
	payload.message = message
	payload.serverVersion = CONFIG.Version
	payload.muscle = getLeaderstat(player, "Muscle").Value
	payload.money = getLeaderstat(player, "Money").Value
	eatResultEvent:FireClient(player, payload)
end

local function sendBoostResult(player, ok, message, payload)
	payload = payload or {}
	payload.ok = ok
	payload.message = message
	payload.serverVersion = CONFIG.Version
	boostResultEvent:FireClient(player, payload)
end

local function sendSizeResult(player, ok, message, payload)
	payload = payload or {}
	payload.ok = ok
	payload.message = message
	payload.serverVersion = CONFIG.Version
	payload.muscle = getLeaderstat(player, "Muscle").Value
	payload.money = getLeaderstat(player, "Money").Value
	sizeResultEvent:FireClient(player, payload)
end

local function getHumanoid(player)
	local character = player.Character
	if not character then
		return nil
	end
	return character:FindFirstChildOfClass("Humanoid")
end

local function applyWalkSpeed(player, speed)
	local humanoid = getHumanoid(player)
	if humanoid then
		humanoid.WalkSpeed = speed
	end
end

local function applyCharacterScale(player, scale)
	local character = player.Character
	if not character then
		return false, "Character not ready"
	end

	local ok, err = pcall(function()
		character:ScaleTo(scale)
	end)

	if not ok then
		return false, tostring(err)
	end

	return true
end

local function calculateBodyScale(muscleValue, muscleMultiplier)
	local safeMuscle = math.max(0, muscleValue or 0)
	local safeMultiplier = math.max(1, muscleMultiplier or 1)
	local effectiveMuscle = safeMuscle * safeMultiplier
	local bodyScale = CONFIG.DefaultBodyScale + (effectiveMuscle / CONFIG.MuscleScaleDivisor)
	return math.clamp(bodyScale, CONFIG.DefaultBodyScale, CONFIG.MaxBodyScale), effectiveMuscle
end

local function getCurrentMuscleMultiplier(player)
	return 1
end

local function refreshBodyScaleFromMuscle(player)
	local muscleValue = getLeaderstat(player, "Muscle").Value
	local muscleMultiplier = getCurrentMuscleMultiplier(player)
	local bodyScale, effectiveMuscle = calculateBodyScale(muscleValue, muscleMultiplier)
	local currentBodyScale = player:GetAttribute("CurrentBodyScale")
	local shouldApply = typeof(currentBodyScale) ~= "number" or math.abs(currentBodyScale - bodyScale) >= CONFIG.MinScaleDelta
	local ok, err = true, nil

	if shouldApply then
		ok, err = applyCharacterScale(player, bodyScale)
	end

	if ok and shouldApply then
		player:SetAttribute("CurrentBodyScale", bodyScale)
	end

	if ok then
		player:SetAttribute("CurrentEffectiveMuscle", effectiveMuscle)
		player:SetAttribute("CurrentMuscleMultiplier", muscleMultiplier)
	end

	return ok, err, bodyScale, effectiveMuscle, muscleMultiplier
end

local function scheduleBodyScaleRefresh(player)
	local muscleValue = getLeaderstat(player, "Muscle").Value
	local muscleMultiplier = getCurrentMuscleMultiplier(player)
	local bodyScale, effectiveMuscle = calculateBodyScale(muscleValue, muscleMultiplier)

	if scaleUpdateScheduledByPlayer[player] then
		return true, nil, bodyScale, effectiveMuscle, muscleMultiplier
	end

	scaleUpdateScheduledByPlayer[player] = true
	task.delay(CONFIG.ScaleUpdateDelay, function()
		scaleUpdateScheduledByPlayer[player] = nil
		if player.Parent then
			refreshBodyScaleFromMuscle(player)
		end
	end)

	return true, nil, bodyScale, effectiveMuscle, muscleMultiplier
end

local function activateSpeedBoost(player)
	local now = os.clock()
	local lastRequestAt = lastBoostRequestAtByPlayer[player] or 0
	if lastRequestAt > 0 and now - lastRequestAt < CONFIG.BoostCooldown then
		sendBoostResult(player, false, "Speed cooldown", {
			active = player:GetAttribute("SpeedBoostActive") == true,
			walkSpeed = player:GetAttribute("CurrentWalkSpeed") or CONFIG.DefaultWalkSpeed,
		})
		return
	end

	lastBoostRequestAtByPlayer[player] = now

	local expiresAt = now + CONFIG.BoostDuration
	boostExpiresAtByPlayer[player] = expiresAt
	player:SetAttribute("SpeedBoostActive", true)
	player:SetAttribute("CurrentWalkSpeed", CONFIG.BoostWalkSpeed)
	applyWalkSpeed(player, CONFIG.BoostWalkSpeed)

	sendBoostResult(player, true, "2x speed active", {
		active = true,
		walkSpeed = CONFIG.BoostWalkSpeed,
		duration = CONFIG.BoostDuration,
	})

	print("[EatDemo] boost active", player.Name, CONFIG.BoostWalkSpeed)

	task.delay(CONFIG.BoostDuration, function()
		if not player.Parent then
			return
		end

		if boostExpiresAtByPlayer[player] ~= expiresAt then
			return
		end

		boostExpiresAtByPlayer[player] = nil
		player:SetAttribute("SpeedBoostActive", false)
		player:SetAttribute("CurrentWalkSpeed", CONFIG.DefaultWalkSpeed)
		applyWalkSpeed(player, CONFIG.DefaultWalkSpeed)
		sendBoostResult(player, true, "2x speed ended", {
			active = false,
			walkSpeed = CONFIG.DefaultWalkSpeed,
		})

		print("[EatDemo] boost ended", player.Name, CONFIG.DefaultWalkSpeed)
	end)
end

local function activateSizeBoost(player)
	local muscle = getLeaderstat(player, "Muscle")
	if muscle.Value <= 0 then
		sendSizeResult(player, false, "Eat first, Muscle is 0", {
			permanent = true,
			bodyScale = player:GetAttribute("CurrentBodyScale") or CONFIG.DefaultBodyScale,
			multiplier = 1,
		})
		return
	end

	muscle.Value *= 2
	player:SetAttribute("SizeBoostActive", false)
	local ok, err, targetScale, effectiveMuscle, muscleMultiplier = refreshBodyScaleFromMuscle(player)
	if not ok then
		sendSizeResult(player, false, err, {
			permanent = true,
			bodyScale = player:GetAttribute("CurrentBodyScale") or CONFIG.DefaultBodyScale,
			multiplier = 1,
		})
		return
	end

	sendSizeResult(player, true, "Muscle permanently doubled", {
		permanent = true,
		active = false,
		bodyScale = targetScale,
		multiplier = muscleMultiplier,
		effectiveMuscle = effectiveMuscle,
	})

	print("[EatDemo] size permanent", player.Name, "muscle", muscle.Value, "scale", targetScale)
end

local function consumeDrop(player, resName, dropName)
	if typeof(resName) ~= "string" or typeof(dropName) ~= "string" then
		sendResult(player, false, "Invalid eat request")
		return
	end

	local folder = dropFoldersByName[resName]
	if not folder then
		sendResult(player, false, "Unknown drop folder")
		warn("[EatDemo] unknown folder", player.Name, resName, dropName)
		return
	end

	local food = folder:FindFirstChild(dropName)
	if not food or not food:IsA("Model") or not food.PrimaryPart then
		sendResult(player, false, "Food not found")
		warn("[EatDemo] food not found", player.Name, resName, dropName)
		return
	end

	if food:GetAttribute("HasEat") == 1 then
		sendResult(player, false, "Already eaten", {
			position = food.PrimaryPart.Position,
		})
		return
	end

	local character = player.Character
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")
	if not rootPart then
		sendResult(player, false, "Character not ready")
		return
	end

	local rootXZ = Vector3.new(rootPart.Position.X, 0, rootPart.Position.Z)
	local foodXZ = Vector3.new(food.PrimaryPart.Position.X, 0, food.PrimaryPart.Position.Z)
	local distance = (rootXZ - foodXZ).Magnitude
	if distance > CONFIG.EatRadius then
		sendResult(player, false, "Too far away " .. tostring(math.floor(distance)), {
			position = food.PrimaryPart.Position,
		})
		warn("[EatDemo] too far", player.Name, resName, dropName, distance)
		return
	end

	food:SetAttribute("HasEat", 1)

	local addAttr = food.PrimaryPart:GetAttribute("addAttr") or 1
	local addMoney = food.PrimaryPart:GetAttribute("addMoney") or 0
	local respawnColor = Color3.fromRGB(
		food.PrimaryPart:GetAttribute("baseColorR") or 72,
		food.PrimaryPart:GetAttribute("baseColorG") or 221,
		food.PrimaryPart:GetAttribute("baseColorB") or 116
	)
	local muscle = getLeaderstat(player, "Muscle")
	local money = getLeaderstat(player, "Money")

	muscle.Value += addAttr
	money.Value += addMoney
	local _, _, bodyScale, effectiveMuscle, muscleMultiplier = scheduleBodyScaleRefresh(player)

	local position = food.PrimaryPart.Position
	local tween = TweenService:Create(food.PrimaryPart, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Transparency = 1,
		Size = food.PrimaryPart.Size * 0.2,
	})
	tween:Play()
	Debris:AddItem(food, 0.35)

	sendResult(player, true, "+" .. tostring(addAttr) .. " Muscle", {
		kind = "eat",
		addAttr = addAttr,
		addMoney = addMoney,
		position = position,
		bodyScale = bodyScale,
		effectiveMuscle = effectiveMuscle,
		multiplier = muscleMultiplier,
	})

	print("[EatDemo] consumed", player.Name, resName, dropName, addAttr, addMoney)

	task.delay(CONFIG.RespawnSeconds, function()
		if folder.Parent then
			local offset = Vector3.new(math.random(-24, 24), 3, math.random(-6, 22))
			makeDropModel(folder, offset, addAttr, addMoney, respawnColor)
		end
	end)
end

Players.PlayerAdded:Connect(function(player)
	getLeaderstat(player, "Muscle")
	getLeaderstat(player, "Money")
	player:SetAttribute("SpeedBoostActive", false)
	player:SetAttribute("CurrentWalkSpeed", CONFIG.DefaultWalkSpeed)
	player:SetAttribute("SizeBoostActive", false)
	player:SetAttribute("DefaultBodyScale", CONFIG.DefaultBodyScale)
	player:SetAttribute("CurrentBodyScale", CONFIG.DefaultBodyScale)
	player:SetAttribute("CurrentEffectiveMuscle", 0)
	player:SetAttribute("CurrentMuscleMultiplier", 1)
	player.CharacterAdded:Connect(function()
		task.defer(function()
			applyWalkSpeed(player, player:GetAttribute("CurrentWalkSpeed") or CONFIG.DefaultWalkSpeed)
			refreshBodyScaleFromMuscle(player)
		end)
	end)
	task.defer(function()
		sendResult(player, true, "Ready", {
			kind = "ready",
		})
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	boostExpiresAtByPlayer[player] = nil
	lastBoostRequestAtByPlayer[player] = nil
	scaleUpdateScheduledByPlayer[player] = nil
end)

eatEvent.OnServerEvent:Connect(consumeDrop)
boostEvent.OnServerEvent:Connect(activateSpeedBoost)
sizeEvent.OnServerEvent:Connect(activateSizeBoost)

seedDrops()

```