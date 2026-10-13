--!strict
-- 固定岛在 Studio 编辑；此服务只定位模板副本、绑定公开归属与播放港口演出。
-- 旅行奖励、开箱与升级完成均由业务 Domain 判断，演出不结算任何数据。
local Workspace = game:GetService("Workspace")
local Config = require(script.Parent.Parent.Config.TravelConfig)

local SETTINGS = {
	ResourcePath = "Models.TravelBuddy.",
	InteractDistance = 36,
	ContainerDistance = 30,
	HubDistance = 32,
	FadeStart = 0.6,
	IdleHeight = 0.12,
	IdleSpeed = 2.2,
}

local TravelWorldService = {
	Name = "TravelWorldService",
}

local function requireChild(parent, name, className)
	local child = parent:FindFirstChild(name)
	assert(child ~= nil and child:IsA(className), "Travel world missing " .. parent:GetFullName() .. "." .. name)
	return child
end

local function getLevel(value, maximum)
	if type(value) ~= "number" then
		return 1
	end
	return math.clamp(math.floor(value), 1, maximum)
end

local function getMotionSeconds(value, fallback, journey)
	local seconds = if type(value) == "number" then value else fallback
	if journey ~= nil and type(journey.StartAt) == "number" and type(journey.EndAt) == "number" then
		seconds = math.min(seconds, (journey.EndAt - journey.StartAt) / 3)
	end
	return math.max(0.5, seconds)
end

local function setLabel(model, signName, text)
	local sign = model:FindFirstChild(signName, true)
	local label = if sign ~= nil then sign:FindFirstChild("Label", true) else nil
	if label ~= nil and label:IsA("TextLabel") then
		label.Text = text
	end
end

local function tagOwner(instance, userId, plotId, containerId)
	instance:SetAttribute("OwnerUserId", userId)
	instance:SetAttribute("PlotId", plotId)
	if containerId ~= nil then
		instance:SetAttribute("ContainerId", containerId)
	end
	for _, descendant in ipairs(instance:GetDescendants()) do
		if descendant:IsA("ProximityPrompt") then
			descendant:SetAttribute("OwnerUserId", userId)
			descendant:SetAttribute("PlotId", plotId)
			if containerId ~= nil then
				descendant:SetAttribute("ContainerId", containerId)
			end
		end
	end
end

function TravelWorldService:Init(context)
	self._resources = context.Services.ResourceService
	assert(self._resources ~= nil, "TravelWorldService needs ResourceService")
	self._logger = context.Logger
	self._plotCount = Config.Settings.MaxPlayers
	self._maxHomeLevel = 1
	for level in pairs(Config.HomeCapacityByLevel) do
		self._maxHomeLevel = math.max(self._maxHomeLevel, level)
	end
	self._maxShipLevel = Config.MaxShipLevel
	self._players = {}
	self._plots = {}
	self._visuals = {}
	self._runtime = nil
	self._world = nil
end

function TravelWorldService:_registerVisual(model)
	local visual = { Parts = {}, Guis = {}, LastAlpha = nil }
	for _, descendant in ipairs(model:GetDescendants()) do
		if descendant:IsA("BasePart") then
			visual.Parts[descendant] = {
				Transparency = descendant.Transparency,
				CanCollide = descendant.CanCollide,
				CanQuery = descendant.CanQuery,
			}
		elseif descendant:IsA("SurfaceGui") or descendant:IsA("BillboardGui") then
			visual.Guis[descendant] = descendant.Enabled
		end
	end
	self._visuals[model] = visual
end

function TravelWorldService:_clone(name, parent)
	local path = SETTINGS.ResourcePath .. name
	local template, getCode = self._resources:Get("Server", path)
	assert(template ~= nil, "Travel resource missing: " .. path .. " " .. tostring(getCode))
	assert(template:GetAttribute("Template") == true, "Travel resource must have Template=true: " .. path)
	local copy, cloneCode = self._resources:Clone("Server", path, parent)
	assert(copy ~= nil, "Travel resource clone failed: " .. path .. " " .. tostring(cloneCode))
	copy:SetAttribute("Template", nil)
	if copy:IsA("Model") then
		self:_registerVisual(copy)
	end
	return copy
end

function TravelWorldService:_destroyModel(model)
	if model ~= nil then
		self._visuals[model] = nil
		model:Destroy()
	end
end

function TravelWorldService:_setAlpha(model, alpha)
	local visual = self._visuals[model]
	if visual == nil or visual.LastAlpha == alpha then
		return
	end
	visual.LastAlpha = alpha
	for part, original in pairs(visual.Parts) do
		part.Transparency = original.Transparency + (1 - original.Transparency) * alpha
		-- 船只离港是演出，不把站在船上的角色带去远方。
		part.CanCollide = original.CanCollide and alpha == 0
		part.CanQuery = original.CanQuery and alpha < 1
	end
	for gui, originalEnabled in pairs(visual.Guis) do
		gui.Enabled = originalEnabled and alpha == 0
	end
end

function TravelWorldService:_setConstruction(model, active)
	local marker = model:FindFirstChild("ConstructionSign", true)
	if marker == nil or not marker:IsA("BasePart") then
		return
	end
	local visual = self._visuals[model]
	if visual ~= nil then
		local partState = visual.Parts[marker]
		if partState ~= nil then
			partState.Transparency = if active then 0 else 1
		end
		local gui = marker:FindFirstChild("SignGui")
		if gui ~= nil and gui:IsA("SurfaceGui") then
			visual.Guis[gui] = active
		end
		visual.LastAlpha = nil
	end
	self:_setAlpha(model, 0)
end

function TravelWorldService:Start()
	local gameFolder = requireChild(Workspace, "Game", "Folder")
	local worldFolder = requireChild(gameFolder, "World", "Folder")
	local runtimeFolder = requireChild(gameFolder, "Runtime", "Folder")
	self._world = requireChild(worldFolder, "TravelIsland", "Model")
	local plots = requireChild(self._world, "Plots", "Folder")
	assert(runtimeFolder:FindFirstChild("TravelBuddy") == nil, "TravelBuddy runtime name is already occupied")
	self._runtime = self:_clone("PlotRuntime", runtimeFolder)
	self._runtime.Name = "TravelBuddy"
	local hub = requireChild(self._world, "Hub", "Folder")
	self._hubAnchors = {
		Shop = requireChild(hub, "ShopAnchor", "BasePart"),
		Inventory = requireChild(hub, "InventoryAnchor", "BasePart"),
		Collection = requireChild(hub, "CollectionAnchor", "BasePart"),
	}
	for index = 1, self._plotCount do
		local plotId = "Plot" .. tostring(index)
		local plot = requireChild(plots, plotId, "Folder")
		local slots = requireChild(plot, "ContainerSlots", "Folder")
		local slotAnchors = {}
		for slot = 1, Config.HomeCapacityByLevel[self._maxHomeLevel] do
			slotAnchors[slot] = requireChild(slots, "Slot" .. tostring(slot), "BasePart")
		end
		self._plots[index] = {
			Id = plotId,
			Index = index,
			HomeAnchor = requireChild(plot, "HomeAnchor", "BasePart"),
			PreparationAnchor = requireChild(plot, "PreparationAnchor", "BasePart"),
			ShipAnchor = requireChild(plot, "ShipAnchor", "BasePart"),
			SpawnAnchor = requireChild(plot, "SpawnAnchor", "BasePart"),
			DepartureEnd = requireChild(plot, "DepartureEnd", "BasePart"),
			Slots = slotAnchors,
			OwnerUserId = nil,
		}
	end
	self._logger.Info(self.Name, "四人共享岛与原生模型模板已就绪")
end

function TravelWorldService:Assign(player)
	local existing = self._players[player.UserId]
	if existing ~= nil then
		return if existing.Player == player then existing.Plot.Id else nil
	end
	for _, plot in ipairs(self._plots) do
		if plot.OwnerUserId == nil then
			local runtime = self:_clone("PlotRuntime", self._runtime)
			runtime.Name = plot.Id
			tagOwner(runtime, player.UserId, plot.Id)
			local preparation = self:_clone("PreparationStation", runtime)
			preparation.Name = "Preparation"
			preparation:PivotTo(plot.PreparationAnchor.CFrame)
			tagOwner(preparation, player.UserId, plot.Id)
			plot.OwnerUserId = player.UserId
			self._players[player.UserId] = {
				Player = player,
				Plot = plot,
				Runtime = runtime,
				Preparation = preparation,
				Home = nil,
				Ship = nil,
				Frog = nil,
				Containers = {},
				HomeLevel = nil,
				ShipLevel = nil,
				State = "HomeIdle",
				Journey = nil,
				HomeBuilding = nil,
				ShipBuilding = nil,
				DepartureSeconds = Config.Settings.DepartureSeconds,
				ReturnSeconds = Config.Settings.ReturnSeconds,
			}
			setLabel(self._world, "PlotSign" .. tostring(plot.Index), player.DisplayName .. " 的旅行地块")
			return plot.Id
		end
	end
	return nil
end

function TravelWorldService:Release(player)
	local record = self._players[player.UserId]
	-- 重进后可能收到旧 Player 的迟到清理，不能释放新会话占用的同账号地块。
	if record == nil or record.Player ~= player then
		return
	end
	self._players[player.UserId] = nil
	record.Plot.OwnerUserId = nil
	self:_destroyModel(record.Home)
	self:_destroyModel(record.Ship)
	self:_destroyModel(record.Frog)
	self:_destroyModel(record.Preparation)
	for _, container in pairs(record.Containers) do
		self:_destroyModel(container.Model)
	end
	-- 仅删除此服务从 PlotRuntime 克隆并持有的运行文件夹。
	record.Runtime:Destroy()
	setLabel(
		self._world,
		"PlotSign" .. tostring(record.Plot.Index),
		tostring(record.Plot.Index) .. " 号旅行家\n空闲地块"
	)
end

function TravelWorldService:_renderContainers(record, containers)
	local retained = {}
	local limit = Config.HomeCapacityByLevel[record.HomeLevel]
	for slot, publicContainer in ipairs(containers) do
		if slot <= limit and type(publicContainer.Id) == "string" then
			local id = publicContainer.Id
			local entry = record.Containers[id]
			if entry == nil then
				local model = self:_clone("Container", record.Runtime)
				model.Name = "Container" .. tostring(slot)
				tagOwner(model, record.Player.UserId, record.Plot.Id, id)
				entry = { Model = model }
				record.Containers[id] = entry
			end
			entry.Slot = slot
			entry.Model:PivotTo(record.Plot.Slots[slot].CFrame)
			setLabel(entry.Model, "ContainerSign", "旅行箱 " .. tostring(slot))
			retained[id] = true
		end
	end
	for id, entry in pairs(record.Containers) do
		if retained[id] ~= true then
			self:_destroyModel(entry.Model)
			record.Containers[id] = nil
		end
	end
end

function TravelWorldService:Render(player, state)
	if self:Assign(player) == nil then
		return
	end
	local record = self._players[player.UserId]
	local homeLevel = getLevel(state.HomeLevel, self._maxHomeLevel)
	local shipLevel = getLevel(state.ShipLevel, self._maxShipLevel)
	local homeChanged = record.HomeLevel ~= homeLevel
	local shipChanged = record.ShipLevel ~= shipLevel
	if record.HomeLevel ~= homeLevel then
		self:_destroyModel(record.Home)
		record.Home = self:_clone("HomeLv" .. tostring(homeLevel), record.Runtime)
		record.Home.Name = "Home"
		record.Home:PivotTo(record.Plot.HomeAnchor.CFrame)
		tagOwner(record.Home, player.UserId, record.Plot.Id)
		record.HomeLevel = homeLevel
	end
	if record.ShipLevel ~= shipLevel then
		self:_destroyModel(record.Ship)
		record.Ship = self:_clone("ShipLv" .. tostring(shipLevel), record.Runtime)
		record.Ship.Name = "Ship"
		record.Ship:PivotTo(record.Plot.ShipAnchor.CFrame)
		tagOwner(record.Ship, player.UserId, record.Plot.Id)
		record.ShipLevel = shipLevel
	end
	if record.Frog == nil then
		record.Frog = self:_clone("Frog", record.Runtime)
		tagOwner(record.Frog, player.UserId, record.Plot.Id)
	end
	record.State = state.State or "HomeIdle"
	local journey = state.Journey
	-- 只保存演出所需的公开时间；模型属性没有箱子品质、奖品或隐藏计划。
	record.Journey = if journey ~= nil
		then { Id = journey.Id, StartAt = journey.StartAt, EndAt = journey.EndAt }
		else nil
	record.DepartureSeconds = getMotionSeconds(state.DepartureSeconds, Config.Settings.DepartureSeconds, journey)
	record.ReturnSeconds = getMotionSeconds(state.ReturnSeconds, Config.Settings.ReturnSeconds, journey)
	local upgrades = state.Upgrades or {}
	local homeBuilding = upgrades.Home ~= nil
	local shipBuilding = upgrades.Ship ~= nil
	if homeChanged or record.HomeBuilding ~= homeBuilding then
		self:_setConstruction(record.Home, homeBuilding)
	end
	if shipChanged or record.ShipBuilding ~= shipBuilding then
		self:_setConstruction(record.Ship, shipBuilding)
	end
	record.HomeBuilding = homeBuilding
	record.ShipBuilding = shipBuilding
	self:_renderContainers(record, state.Containers or {})
	setLabel(
		self._world,
		"PlotSign" .. tostring(record.Plot.Index),
		player.DisplayName .. "\n小屋 Lv." .. tostring(homeLevel) .. " / 船 Lv." .. tostring(shipLevel)
	)
	self:_stepRecord(record, Workspace:GetServerTimeNow())
end

function TravelWorldService:_refreshPrompts(record, atDock)
	for _, model in ipairs({ record.Home, record.Ship }) do
		for _, descendant in ipairs(model:GetDescendants()) do
			if descendant:IsA("ProximityPrompt") then
				local action = descendant:GetAttribute("TravelAction")
				if action == "Voyage" then
					-- 出发由领域时钟决定；旧派遣入口保留为禁用的模板兼容节点。
					descendant.Enabled = false
				elseif action == "HomeUpgrade" then
					descendant.Enabled = record.HomeLevel < self._maxHomeLevel and not record.HomeBuilding
				elseif action == "ShipUpgrade" then
					descendant.Enabled = atDock
						and record.ShipLevel < self._maxShipLevel
						and not record.ShipBuilding
						and record.State ~= "ReturnPending"
				elseif action == "ClaimReturn" then
					descendant.Enabled = atDock and record.State == "ReturnPending"
				end
			end
		end
	end
end

function TravelWorldService:_stepRecord(record, now)
	if record.Home == nil or record.Ship == nil or record.Frog == nil then
		return
	end
	local dock = record.Plot.ShipAnchor.CFrame
	local distant = record.Plot.DepartureEnd.CFrame
	local shipCFrame = dock
	local alpha = 0
	local frogOnShip = false
	local atDock = true
	local journey = record.Journey
	local returning = record.State == "ReturnPending"
	if journey ~= nil and type(journey.EndAt) == "number" and now >= journey.EndAt then
		-- 提前领取旧流程奖励不跳过靠岸演出；行囊权限也使用同一归航窗口。
		returning = returning or now < journey.EndAt + record.ReturnSeconds
	end
	if journey ~= nil and type(journey.EndAt) == "number" and now >= journey.EndAt then
		returning = record.State == "Voyaging" or returning
	end
	if returning and journey ~= nil and type(journey.EndAt) == "number" then
		local progress = math.clamp((now - journey.EndAt) / record.ReturnSeconds, 0, 1)
		shipCFrame = distant:Lerp(dock, progress)
		alpha = math.clamp(1 - progress / (1 - SETTINGS.FadeStart), 0, 1)
		frogOnShip = progress < 1
		atDock = progress == 1
	elseif record.State == "Voyaging" then
		local startAt = if journey ~= nil and type(journey.StartAt) == "number" then journey.StartAt else now
		local progress = math.clamp((now - startAt) / record.DepartureSeconds, 0, 1)
		shipCFrame = dock:Lerp(distant, progress)
		alpha = math.clamp((progress - SETTINGS.FadeStart) / (1 - SETTINGS.FadeStart), 0, 1)
		frogOnShip = true
		atDock = false
	end
	if atDock then
		shipCFrame *= CFrame.new(0, math.sin(now * 1.4 + record.Plot.Index) * 0.045, 0)
	end
	record.Ship:PivotTo(shipCFrame)
	self:_setAlpha(record.Ship, alpha)
	local frogAnchor = if frogOnShip
		then requireChild(record.Ship, "FrogAnchor", "BasePart")
		else requireChild(record.Home, "FrogAnchor", "BasePart")
	if not frogOnShip and record.State == "Preparing" then
		-- 准备站位是可替换的表现锚点；缺失时仍在家待机，不影响权威出发条件。
		local preparationAnchor = record.Preparation:FindFirstChild("CompanionAnchor")
		if preparationAnchor ~= nil and preparationAnchor:IsA("BasePart") then
			frogAnchor = preparationAnchor
		end
	end
	local idle = math.sin(now * SETTINGS.IdleSpeed + record.Plot.Index)
	record.Frog:PivotTo(frogAnchor.CFrame * CFrame.new(0, idle * SETTINGS.IdleHeight, 0))
	self:_setAlpha(record.Frog, if frogOnShip then alpha else 0)
	self:_refreshPrompts(record, atDock)
end

function TravelWorldService:Step(now)
	if type(now) ~= "number" then
		now = Workspace:GetServerTimeNow()
	end
	for _, record in pairs(self._players) do
		self:_stepRecord(record, now)
	end
end

function TravelWorldService:GetPlotId(player)
	local record = self._players[player.UserId]
	return if record ~= nil and record.Player == player then record.Plot.Id else nil
end

function TravelWorldService:GetSpawnCFrame(player)
	local record = self._players[player.UserId]
	return if record ~= nil and record.Player == player then record.Plot.SpawnAnchor.CFrame else nil
end

function TravelWorldService:CanInteract(player, action, targetId)
	local record = self._players[player.UserId]
	local character = player.Character
	local characterRoot = if character ~= nil then character:FindFirstChild("HumanoidRootPart") else nil
	if record == nil or record.Player ~= player or characterRoot == nil or not characterRoot:IsA("BasePart") then
		return false
	end
	local anchor = self._hubAnchors[action]
	local distance = SETTINGS.HubDistance
	if action == "HomeUpgrade" then
		anchor = record.Plot.HomeAnchor
		distance = SETTINGS.InteractDistance
	elseif action == "Bag" then
		anchor = record.Plot.PreparationAnchor
		distance = 14
	elseif action == "ShipUpgrade" or action == "ClaimReturn" then
		anchor = record.Plot.ShipAnchor
		distance = SETTINGS.InteractDistance
	elseif action == "OpenContainer" then
		if type(targetId) ~= "string" then
			return false
		end
		local entry = record.Containers[targetId]
		if entry == nil or entry.Model:GetAttribute("OwnerUserId") ~= player.UserId then
			return false
		end
		anchor = record.Plot.Slots[entry.Slot]
		distance = SETTINGS.ContainerDistance
	end
	return anchor ~= nil and (characterRoot.Position - anchor.Position).Magnitude <= distance
end

return TravelWorldService
