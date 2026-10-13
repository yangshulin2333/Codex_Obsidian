--!strict

-- Game owns requests and content; both GUI trees are native Studio templates.
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local TravelSceneAnimation = require(script.Parent.TravelSceneAnimation)

local Shared = ReplicatedStorage.Game.Shared
local Protocol = require(Shared.TravelProtocol)
local ResourceClient = require(ReplicatedStorage.Framework.Shared.Resource.ResourceClient)
local ButtonBinding = require(ReplicatedStorage.Framework.Shared.UI.ButtonBinding)
local ListBinding = require(ReplicatedStorage.Framework.Shared.UI.ListBinding)
local WindowBinding = require(ReplicatedStorage.Framework.Shared.UI.WindowBinding)
local WindowNavigation = require(ReplicatedStorage.Framework.Shared.UI.WindowNavigation)

local TravelController = { Name = "TravelController" }
local TITLES = {
	Bag = "伙伴行囊",
	Voyage = "伙伴旅行计划",
	Inventory = "住宅船箱与背包",
	Collection = "航海图鉴",
	Upgrade = "住宅与船只施工",
	Result = "旅行收获",
	Status = "岛屿状态与补给商店",
}
local STATE_NAMES = {
	HomeIdle = "在岛上",
	Preparing = "准备出发",
	Voyaging = "海上旅行中",
	ReturnPending = "已归航 · 等待领取",
	Resting = "伙伴休息中",
}
local WAITING_NAMES = {
	MANUAL_PAUSED = "已暂缓出发，等待你恢复。",
	NO_PACKED_SUPPLIES = "行囊没有补给，装入后伙伴会自主准备。",
	CONTAINER_FULL = "箱区已满，打开船箱后才能继续出游。",
	SHIP_UPGRADING = "船只施工中，完工后伙伴会继续准备。",
	RESTING = "伙伴正在休息，休息结束后会准备下一趟。",
	RETURN_PENDING = "已归航，本阶段请到船位领取收获。",
	NOT_DOCKED = "船尚未靠岸，暂时只能查看。",
	JOURNEY_ACTIVE = "伙伴正在出游，你可以继续经营岛屿。",
}
local QUALITY_NAMES = { Common = "普通", Life = "生活", Fine = "精良", Special = "特产" }
local ERROR_NAMES = {
	STALE_STATE = "状态已改变，已同步最新数据，请重新操作。",
	RATE_LIMITED = "操作较快，请稍后再试。",
	NOT_READY = "岛屿数据尚未就绪，请稍后同步。",
	TOO_FAR = "请靠近对应的三维交互入口后操作。",
	OUT_OF_RANGE = "请靠近对应的三维交互入口后操作。",
	NOT_OWNER = "这个入口属于其他玩家。",
}

local function child(root: Instance, path: string): any
	local current = root
	for segment in string.gmatch(path, "[^.]+") do
		local found = current:FindFirstChild(segment)
		assert(found, "TravelBuddy GUI node missing: " .. path)
		current = found
	end
	return current
end

local function write(root: Instance, path: string, words: string)
	child(root, path).Text = words
end

local function loadRows(name: string): { [string]: any }
	local generated = Shared.Config.Generated:FindFirstChild(name)
	if not generated or not generated:IsA("ModuleScript") then
		return {}
	end
	local rows = require(generated)
	local indexed = {}
	for key, row in pairs(rows) do
		if type(row) == "table" then
			indexed[row.Id or key] = row
		end
	end
	return indexed
end

local function ordered(rows: { [string]: any }): { any }
	local values = {}
	for _, row in pairs(rows) do
		table.insert(values, row)
	end
	table.sort(values, function(left, right)
		local first, second = left.Order or 0, right.Order or 0
		return if first == second then tostring(left.Id) < tostring(right.Id) else first < second
	end)
	return values
end

local function has(map: any, id: string): boolean
	if type(map) ~= "table" then
		return false
	end
	if map[id] ~= nil then
		return map[id] ~= false and map[id] ~= 0
	end
	return table.find(map, id) ~= nil
end

local function duration(seconds: number): string
	seconds = math.max(0, math.ceil(seconds))
	if seconds < 60 then
		return tostring(seconds) .. " 秒"
	end
	return string.format("%d 分 %02d 秒", math.floor(seconds / 60), seconds % 60)
end

local function attribute(prompt: ProximityPrompt, name: string): any
	local object: Instance? = prompt
	while object and object ~= workspace do
		local value = object:GetAttribute(name)
		if value ~= nil then
			return value
		end
		object = object.Parent
	end
	return nil
end

function TravelController:Init(context: any)
	self._net = context.Net
	self._state = nil
	self._busy = false
	self._pending = nil
	self._disposed = false
	self._connections = {}
	self._buttons = {}
	self._lists = {}
	self._panel = "Status"
	self._viewToken = 0
	self._clockOffset = 0
	self._lastServerTime = 0
	self._nextBoundaryRead = 0
	self._watchOpen = false
	self._dismissedReturnJourney = nil
	self._configs = {
		Seas = loadRows("TravelSeas"),
		Items = loadRows("TravelItems"),
		Durations = loadRows("TravelDurations"),
		UpgradeOptions = loadRows("TravelUpgrades"),
		PostcardOptions = loadRows("TravelPostcards"),
		Images = loadRows("Images"),
		Settings = loadRows("TravelSettings"),
	}
end

function TravelController:_rows(name: string): any
	local state = self._state
	return if state and type(state[name]) == "table" then state[name] else self._configs[name] or {}
end

function TravelController:_setting(id: string): number?
	local row = self._configs.Settings[id]
	return if row then tonumber(row.Value) else nil
end

function TravelController:_now(): number
	return os.time() + self._clockOffset
end

function TravelController:_notice(words: string)
	if self._disposed or not self._hud then
		return
	end
	write(self._hud, "Root.Notice", words)
	write(self._window, "Root.Panel.Message", words)
end

function TravelController:_open(panelName: string)
	if self._disposed then
		return
	end
	self._panel = panelName
	self._watchOpen = false
	self._viewToken += 1
	local content = child(self._window, "Root.Panel.Content")
	for name in pairs(TITLES) do
		child(content, name).Visible = name == panelName
	end
	write(self._window, "Root.Panel.Header.Title", TITLES[panelName] or "旅行伙伴")
	self._windowBinding:Open()
	self:_render()
end

function TravelController:_close()
	self._viewToken += 1
	self._windowBinding:Close()
	self:_render_clock()
end

function TravelController:_watch(open: boolean)
	if self._disposed then
		return
	end
	self._watchOpen = open
	if open then
		self:_close()
	end
	self:_render_clock()
end

function TravelController:_accept(state: any): boolean
	if self._disposed or type(state) ~= "table" or type(state.Revision) ~= "number" then
		return false
	end
	-- A newer push always wins over an older InvokeServer response.
	if self._state and state.Revision < self._state.Revision then
		return false
	end
	local firstState = self._state == nil
	self._state = state
	if type(state.ServerTime) == "number" and state.ServerTime >= self._lastServerTime then
		self._clockOffset = state.ServerTime - os.time()
		self._lastServerTime = state.ServerTime
	end
	self:_render()
	if firstState then
		self:_notice("欢迎来到海岛，前往自家准备桌装入补给，伙伴会自主准备出游。")
	end
	return true
end

function TravelController:_invoke(payload: any): (boolean, any)
	return pcall(function()
		return self._net.Request(Protocol.Request, payload, self:_setting("RequestTimeout") or 10)
	end)
end

function TravelController:_read(): boolean
	local ok, result = self:_invoke({ Action = "ReadState" })
	if self._disposed then
		return false
	end
	if ok and type(result) == "table" and result.Ok then
		local data = result.Data
		if type(data) == "table" then
			local state = data.State or data
			local accepted = self:_accept(state)
			return accepted
				or (self._state ~= nil and type(state.Revision) == "number" and state.Revision < self._state.Revision)
		end
	end
	self:_notice("暂时无法同步岛屿，请点击同步状态。")
	return false
end

function TravelController:_refresh()
	if self._busy or self._disposed then
		return
	end
	self._busy = true
	self:_render_bag()
	self:_notice("正在同步岛屿…")
	local accepted = self:_read()
	self._busy = false
	if accepted then
		self:_notice(
			if self._pending
				then "原操作结果尚未确认，可确认并重试原操作。"
				else "岛屿状态已同步。"
		)
	end
	self:_render()
end

function TravelController:_outcome(action: string, outcome: any, showResult: boolean)
	local summary = {
		PauseTravel = "已暂缓伙伴出发；恢复后会继续准备。",
		ResumeTravel = "已恢复伙伴出游，满足条件后会自主准备。",
		ClaimReturn = "归航奖励已领取，船箱已送到住宅。",
		OpenContainer = "船箱已打开，物品已收入背包。",
		BuySupply = "补给已买入仓库，请到准备桌装入行囊。",
		PackSupply = "补给已从仓库装入伙伴行囊。",
		UnpackSupply = "补给已从伙伴行囊收回仓库。",
		SellItem = "商品已按固定价格出售。",
		SellAll = "背包商品已出售。",
		Upgrade = "施工已开始，完成后将自动升级。",
		ClaimRelief = "应急补给已收入仓库，需要手动装入行囊。",
	}
	local words = summary[action] or "操作已完成。"
	self:_notice(words)
	if action ~= "OpenContainer" and action ~= "ClaimReturn" then
		return
	end
	write(self._window, "Root.Panel.Content.Result.Summary", words)
	local lines = {}
	if type(outcome) == "table" then
		local quality = outcome.Quality or outcome.OpenedQuality
		if quality then
			table.insert(lines, "开箱品质：" .. (QUALITY_NAMES[quality] or tostring(quality)))
		end
		local rewards = outcome.Items or outcome.Rewards
		if type(rewards) == "table" then
			for id, amount in pairs(rewards) do
				local row = self:_rows("Items")[id]
				if type(amount) == "number" then
					table.insert(lines, (if row then row.Name else tostring(id)) .. " × " .. tostring(amount))
				end
			end
		end
		if outcome.Wood then
			table.insert(lines, "木材 +" .. tostring(outcome.Wood))
		end
		if outcome.SpecialItemId then
			local special = self:_rows("Items")[outcome.SpecialItemId]
			if special then
				table.insert(lines, special.Name .. " × " .. tostring(outcome.SpecialQuantity or 1))
			end
		end
		local cardId = outcome.PostcardId or outcome.CardId
		local card = cardId and self:_rows("PostcardOptions")[cardId]
		if card then
			table.insert(lines, "旅行明信片：" .. card.Title)
			self:_art(child(self._window, "Root.Panel.Content.Result"), card.ImageId or card.Id)
		else
			self:_art(child(self._window, "Root.Panel.Content.Result"), nil)
		end
	end
	write(
		self._window,
		"Root.Panel.Content.Result.Detail",
		if #lines > 0 then table.concat(lines, "\n") else "收获已经记录，可在背包与图鉴查看。"
	)
	if showResult then
		self:_open("Result")
	end
end

function TravelController:_perform(payload: any)
	local viewToken = self._viewToken
	local wasOpen = self._windowBinding:IsOpen()
	local function ownsView(): boolean
		return viewToken == self._viewToken and (not wasOpen or self._windowBinding:IsOpen())
	end
	self._busy = true
	self:_render_bag()
	self:_notice("正在向服务器确认…")
	local ok, result = self:_invoke(payload)
	if self._disposed then
		return
	end
	local data = if ok and type(result) == "table" then result.Data else nil
	if type(data) == "table" and type(data.State) == "table" then
		self:_accept(data.State)
	end
	local uncertain = not ok
		or type(result) ~= "table"
		or result.Code == "REQUEST_TIMEOUT"
		or result.Code == "INVOKE_FAILED"
		or result.Code == "DATA_UPDATE_FAILED"
		or result.Code == "SERVER_ERROR"
	if uncertain then
		-- Keep the exact operation and revision. A retry may only reuse this payload.
		self._pending = { Payload = table.clone(payload), Action = payload.Action }
		self:_notice("结果尚未确认，正在同步权威状态…")
		self:_read()
		self:_notice("结果尚未确认；已尝试同步。请确认并重试原操作。")
		self._busy = false
		if ownsView() then
			self:_open("Status")
		else
			self:_render()
		end
		return
	end
	self._pending = nil
	if result.Ok then
		self:_outcome(payload.Action, if type(data) == "table" then data.Outcome else nil, ownsView())
	else
		if result.Code == "STALE_STATE" then
			self:_read()
		end
		self:_notice(ERROR_NAMES[result.Code] or result.Message or "操作未完成，请同步状态后再试。")
	end
	self._busy = false
	self:_render()
end

function TravelController:_request(action: string, fields: any?)
	if self._busy or self._disposed then
		return
	end
	if self._pending then
		self:_notice("前一次操作结果尚未确认，请先确认并重试原操作。")
		self:_open("Status")
		return
	end
	if not self._state then
		self:_refresh()
		self:_notice("请等待岛屿数据同步后再操作。")
		return
	end
	local payload = table.clone(fields or {})
	payload.Action = action
	payload.OperationId = HttpService:GenerateGUID(false)
	payload.ExpectedRevision = self._state.Revision
	if action == "ClaimReturn" then
		local journey = self._state.Journey
		if not journey then
			self:_notice("当前没有等待领取的归航奖励。")
			return
		end
		payload.JourneyId = journey.Id
	end
	self:_perform(payload)
end

function TravelController:_bind(
	root: Instance,
	path: string,
	callback: () -> (),
	mutation: boolean?,
	canActivate: (() -> boolean)?
)
	local binding = ButtonBinding.Bind(child(root, path), callback, function()
		return not self._disposed and (not mutation or not self._busy) and (canActivate == nil or canActivate())
	end)
	table.insert(self._buttons, binding)
end

function TravelController:_art(root: Instance, id: string?)
	local artwork = child(root, "Artwork")
	local fallback = child(root, "Illustration")
	local row = id and self:_rows("Images")[id]
	local assetId = row and tostring(row.AssetId or "") or ""
	local usable = string.match(assetId, "^rbxassetid://%d+$") ~= nil or string.match(assetId, "^%d+$") ~= nil
	artwork.Visible = usable and assetId ~= "0" and assetId ~= "rbxassetid://0"
	fallback.Visible = not artwork.Visible
	artwork.Image = if artwork.Visible
		then (if string.match(assetId, "^%d+$") then "rbxassetid://" .. assetId else assetId)
		else ""
end

function TravelController:_make_lists()
	local content = child(self._window, "Root.Panel.Content")
	local inventory =
		ListBinding.Bind(child(content, "Inventory.Rows"), child(self._window, "Templates.ItemTemplate"), {
			GetKey = function(data)
				return data.Key
			end,
			Mount = function(entry)
				local binding = ButtonBinding.Bind(child(entry.Gui, "Action"), function()
					local data = entry:GetData()
					if not data then
						return
					end
					if data.ContainerId then
						self:_request("OpenContainer", { ContainerId = data.ContainerId })
					else
						self:_request("SellItem", { ItemId = data.ItemId, Quantity = 1 })
					end
				end, function()
					return not self._busy and not self._disposed
				end)
				entry:AddCleanup(function()
					binding:Dispose()
				end)
			end,
			Render = function(entry, data)
				write(entry.Gui, "Name", data.Name)
				write(entry.Gui, "Detail", data.Detail)
				write(entry.Gui, "Action", data.Action)
				child(entry.Gui, "Action").Visible = data.CanAct
			end,
		})
	local collection =
		ListBinding.Bind(child(content, "Collection.Rows"), child(self._window, "Templates.PostcardTemplate"), {
			GetKey = function(data)
				return data.Key
			end,
			Render = function(entry, data)
				write(entry.Gui, "Name", data.Name)
				write(entry.Gui, "Detail", data.Detail)
				self:_art(entry.Gui, data.ImageId)
			end,
		})
	self._inventoryList = inventory
	self._collectionList = collection
	table.insert(self._lists, inventory)
	table.insert(self._lists, collection)
end

function TravelController:_waiting_words(): string?
	local state = self._state
	if not state then
		return nil
	end
	if state.ManualPaused == true then
		return WAITING_NAMES.MANUAL_PAUSED
	end
	return WAITING_NAMES[state.WaitingReason]
end

function TravelController:_plan_words(): string
	local state = self._state
	if not state then
		return "正在同步伙伴的计划…"
	end
	local journey = state.Journey
	if state.State == "Voyaging" and journey then
		local sea = self:_rows("Seas")[journey.SeaId]
		return (if sea then sea.Name else "海上")
			.. "旅行中 · 距离归航 "
			.. duration(journey.EndAt - self:_now())
	end
	local plan = state.Plan
	local lines = {}
	if type(plan) == "table" then
		local sea = self:_rows("Seas")[plan.SeaId]
		local route = self:_rows("Durations")[plan.DurationId]
		local first = state.FirstJourney == true
		local seconds = if first then state.FirstJourneySeconds else if route then route.Seconds else nil
		table.insert(
			lines,
			"伙伴计划："
				.. (if sea then sea.Name else "待定海域")
				.. " · "
				.. (if first then "首航体验" else if route then route.Name else "待定航程")
		)
		if type(seconds) == "number" then
			table.insert(lines, "实际航程 " .. duration(seconds))
		end
		if state.State == "Preparing" and type(plan.ReadyAt) == "number" then
			table.insert(lines, "距离自主出发 " .. duration(plan.ReadyAt - self:_now()))
		end
	end
	local waiting = self:_waiting_words()
	if waiting then
		table.insert(lines, waiting)
	elseif state.State == "Resting" then
		table.insert(lines, "伙伴休息中 · 剩余 " .. duration((state.RestUntil or 0) - self:_now()))
	elseif state.State == "ReturnPending" then
		table.insert(lines, WAITING_NAMES.RETURN_PENDING)
	elseif #lines == 0 then
		table.insert(lines, "伙伴在岛上，满足条件后会自主选择海域与航程。")
	end
	return table.concat(lines, "\n")
end

function TravelController:_can_control_travel(action: string): boolean
	local state = self._state
	return state ~= nil
		and state.CanManageBag == true
		and not self._busy
		and self._pending == nil
		and not self._disposed
		and (if action == "ResumeTravel" then state.ManualPaused == true else state.ManualPaused ~= true)
end

function TravelController:_bag_quantity(action: string, all: boolean): number
	local state = self._state
	if not state then
		return 0
	end
	local packed = state.PackedSupplies or 0
	local available = packed
	if action == "PackSupply" then
		available = math.min(state.WarehouseSupplies or 0, math.max(0, (state.BagCapacity or 0) - packed))
	end
	return if all then available else math.min(1, available)
end

function TravelController:_can_change_bag(action: string, all: boolean): boolean
	local state = self._state
	return state ~= nil
		and state.CanManageBag == true
		and not self._busy
		and self._pending == nil
		and self:_bag_quantity(action, all) > 0
end

function TravelController:_render_bag()
	if not self._window or self._disposed then
		return
	end
	local root = child(self._window, "Root.Panel.Content.Bag")
	local state = self._state
	write(
		root,
		"Summary",
		if state
			then string.format(
				"仓库补给 %s 份\n伙伴行囊 %s/%s 份",
				tostring(state.WarehouseSupplies or 0),
				tostring(state.PackedSupplies or 0),
				tostring(state.BagCapacity or "…")
			)
			else "正在同步仓库与伙伴行囊…"
	)
	write(root, "Plan", self:_plan_words())
	local hint = "在家可装取补给；准备等待期间也可调整行囊。"
	if not state then
		hint = "请等待岛屿数据同步。"
	elseif state.CanManageBag ~= true then
		hint = "伙伴正在出游或尚未靠岸，行囊只能查看。归家后可调整。"
	elseif self._pending then
		hint = "上一次操作结果尚未确认，请先确认并重试原操作。"
	elseif self._busy then
		hint = "正在向服务器确认，请稍候。"
	end
	write(root, "Hint", hint)
	write(
		root,
		"Info",
		"伙伴自主选择海域与航程，每趟出发消耗 1 份行囊补给。\n购买只存仓库；归航领取本阶段暂时保留。"
	)
	for _, option in
		{
			{ Path = "Actions.PackOne", Action = "PackSupply", All = false },
			{ Path = "Actions.PackFull", Action = "PackSupply", All = true },
			{ Path = "SecondaryActions.UnpackOne", Action = "UnpackSupply", All = false },
			{ Path = "SecondaryActions.UnpackAll", Action = "UnpackSupply", All = true },
		}
	do
		local button = child(root, option.Path)
		local enabled = self:_can_change_bag(option.Action, option.All)
		button.Active = enabled
		button.Selectable = enabled
		button.AutoButtonColor = enabled
		button.TextTransparency = if enabled then 0 else 0.45
	end
	for _, option in { { Name = "Pause", Action = "PauseTravel" }, { Name = "Resume", Action = "ResumeTravel" } } do
		local button = child(root, "TravelActions." .. option.Name)
		local enabled = self:_can_control_travel(option.Action)
		button.Active = enabled
		button.Selectable = enabled
		button.AutoButtonColor = enabled
		button.TextTransparency = if enabled then 0 else 0.45
	end
end

function TravelController:_render_inventory()
	local state = self._state
	if not state then
		return
	end
	local rows = {}
	for _, container in ipairs(state.Containers or {}) do
		local sea = self:_rows("Seas")[container.SeaId]
		table.insert(rows, {
			Key = "box_" .. container.Id,
			ContainerId = container.Id,
			Name = (if sea then sea.Name else "旅行") .. "船箱",
			Detail = "未开箱 · 品质待揭晓\n请到自家住宅船箱旁打开。",
			Action = "打开船箱",
			CanAct = true,
		})
	end
	for _, config in ordered(self:_rows("Items")) do
		local count = (state.Inventory or {})[config.Id] or 0
		if count > 0 then
			local sellable = (config.Price or 0) > 0
			table.insert(rows, {
				Key = "item_" .. config.Id,
				ItemId = config.Id,
				Name = config.Name .. " × " .. tostring(count),
				Detail = if sellable
					then "固定售价 " .. tostring(config.Price) .. " 金币/个\n请到公共收购台出售。"
					else "旅行特产 · 已记入图鉴",
				Action = "出售 1 个",
				CanAct = sellable,
			})
		end
	end
	self._inventoryList:Update(rows)
	write(
		self._window,
		"Root.Panel.Content.Inventory.Summary",
		"船箱 "
			.. tostring(#(state.Containers or {}))
			.. "/"
			.. tostring(state.ContainerCapacity or "…")
			.. "\n木材 "
			.. tostring(state.Wood or 0)
	)
end

function TravelController:_render_collection()
	local state = self._state
	if not state then
		return
	end
	local rows, discovered, cards = {}, 0, 0
	for _, config in ordered(self:_rows("Items")) do
		local known = has(state.DiscoveredItems, config.Id)
		if known then
			discovered += 1
		end
		table.insert(rows, {
			Key = "item_" .. config.Id,
			Name = if known then config.Name else "未发现物品",
			Detail = if known
				then "已发现 · " .. (QUALITY_NAMES[config.Quality] or "收集品") .. "\n背包数量 " .. tostring(
					(state.Inventory or {})[config.Id] or 0
				)
				else "打开旅行船箱，发现新的商品与特产。",
		})
	end
	for _, config in ordered(self:_rows("PostcardOptions")) do
		local count = (state.Postcards or {})[config.Id] or 0
		if count > 0 then
			cards += 1
		end
		table.insert(rows, {
			Key = "card_" .. config.Id,
			Name = if count > 0 then config.Title else "未收集明信片",
			Detail = if count > 0
				then "已收藏 × " .. tostring(count) .. "\n" .. (config.Description or "")
				else "完成对应海域的旅行，可获得明信片。",
			ImageId = if count > 0 then config.ImageId or config.Id else nil,
		})
	end
	self._collectionList:Update(rows)
	write(
		self._window,
		"Root.Panel.Content.Collection.Summary",
		string.format("图鉴 · 已发现 %d 种物品 · 已收集 %d/10 张明信片", discovered, cards)
	)
end

function TravelController:_render_upgrade()
	local state = self._state
	if not state then
		return
	end
	local root = child(self._window, "Root.Panel.Content.Upgrade")
	for _, target in { "Home", "Ship" } do
		local level = state[target .. "Level"] or 1
		local progress = (state.Upgrades or {})[target]
		local nextRow = self:_rows("UpgradeOptions")[target .. tostring(level + 1)]
		local targetName = if target == "Home" then "住宅" else "船只"
		local capacity = state.ContainerCapacity or self:_setting("HomeCapacity" .. tostring(level))
		local detail = if target == "Home"
			then " · 船箱位 " .. tostring(capacity or "…")
			else " · 升级可解锁近海"
		write(root, target, targetName .. " Lv." .. tostring(level) .. detail)
		if progress then
			write(root, target .. "Cost", "施工中 · 距离完成 " .. duration(progress.EndAt - self:_now()))
		elseif nextRow then
			write(
				root,
				target .. "Cost",
				string.format(
					"%s 金币 + %s 木材 · 施工 %s",
					tostring(nextRow.Coins),
					tostring(nextRow.Wood),
					duration(nextRow.Seconds)
				)
			)
		else
			write(root, target .. "Cost", "已达到当前最高等级。")
		end
		child(root, target .. "Start").Visible = nextRow ~= nil and progress == nil
	end
end

function TravelController:_render_status()
	local state = self._state
	if not state then
		return
	end
	local root = child(self._window, "Root.Panel.Content.Status")
	local stateName = STATE_NAMES[state.State] or tostring(state.State)
	local journey = state.Journey
	if state.State == "Voyaging" and journey then
		stateName ..= " · 归航倒计时 " .. duration(journey.EndAt - self:_now())
	elseif state.State == "Resting" then
		stateName ..= " · " .. duration((state.RestUntil or 0) - self:_now())
	elseif state.State == "Preparing" and state.Plan and type(state.Plan.ReadyAt) == "number" then
		stateName ..= " · 自主出发倒计时 " .. duration(state.Plan.ReadyAt - self:_now())
	end
	write(
		root,
		"Summary",
		string.format(
			"%s\n金币 %s · 木材 %s\n仓库补给 %s · 行囊 %s/%s",
			stateName,
			tostring(state.Coins),
			tostring(state.Wood),
			tostring(state.WarehouseSupplies or 0),
			tostring(state.PackedSupplies or 0),
			tostring(state.BagCapacity or "…")
		)
	)
	local supplyPrice = self:_setting("SupplyPrice")
	write(
		root,
		"PrimaryActions.BuySupply",
		if supplyPrice then "补给 1 份 · " .. tostring(supplyPrice) .. " 金币" else "购买补给 1 份"
	)
	write(
		root,
		"Detail",
		"购买补给只放入仓库，请到自家准备桌装入行囊。\n购买与出售请到收购台；归航领取请到自家船位。"
	)
	child(root, "PrimaryActions.ClaimReturn").Visible = state.State == "ReturnPending"
	child(root, "Retry").Visible = self._pending ~= nil
end

function TravelController:_render_clock()
	local state = self._state
	if not state then
		return
	end
	local scene = child(self._hud, "Root.TravelScene")
	local departure = if state.Journey
		then state.Journey.DepartAt or (state.Journey.StartAt + (state.DepartureSeconds or self:_setting(
			"DepartureSeconds"
		) or 0))
		else 0
	local travelling = state.State == "Voyaging" and self:_now() >= departure
	if not travelling then
		self._watchOpen = false
	end
	local watching = travelling and self._watchOpen and not self._windowBinding:IsOpen()
	scene.Visible = watching
	child(self._hud, "Root.TravelWatch").Visible = travelling and not watching and not self._windowBinding:IsOpen()
	local gamepad = UserInputService.PreferredInput == Enum.PreferredInput.Gamepad
	write(self._hud, "Root.TravelWatch", if gamepad then "R1 · 查看海蛙旅途" else "查看海蛙旅途")
	write(scene, "Close", if gamepad then "B · 返回岛屿" else "返回岛屿")
	for _, name in { "Top", "Hint", "Notice" } do
		child(self._hud, "Root." .. name).Visible = not watching
	end
	local journey = state.Journey
	local returned = state.State == "ReturnPending" and journey ~= nil
	local returnNotice = child(self._hud, "Root.ReturnNotice")
	returnNotice.Visible = returned and journey.Id ~= self._dismissedReturnJourney and not self._windowBinding:IsOpen()
	child(self._hud, "Root.Notice").Visible = not watching and not returnNotice.Visible
	write(returnNotice, "Text", "海蛙回来了！前往自己的船位领取旅行收获。")
	if travelling and journey then
		local sea = self:_rows("Seas")[state.Journey.SeaId]
		write(scene, "Title", (if sea then sea.Name else "海上") .. " · 海蛙旅途")
		write(scene, "Progress", "距离归航 " .. duration(state.Journey.EndAt - self:_now()))
		self._sceneAnimation:SetView(journey.SeaId, state.ShipLevel)
	end
	self._sceneAnimation:SetPlaying(watching and self._hud.Enabled)
	write(
		self._hud,
		"Root.Top.State",
		(STATE_NAMES[state.State] or tostring(state.State))
			.. " · 住宅 Lv."
			.. tostring(state.HomeLevel)
			.. " · 船 Lv."
			.. tostring(state.ShipLevel)
	)
	local hint = self:_waiting_words()
	if state.State == "Preparing" and state.Plan and type(state.Plan.ReadyAt) == "number" then
		local sea = self:_rows("Seas")[state.Plan.SeaId]
		hint = (if sea then sea.Name else "伙伴旅行")
			.. " · 距离自主出发 "
			.. duration(state.Plan.ReadyAt - self:_now())
	elseif state.State == "Voyaging" then
		hint = "伙伴正在出游，你可以继续经营岛屿。"
	elseif not hint then
		hint = "靠近自家准备桌，查看伙伴计划和调整行囊。"
	end
	write(self._hud, "Root.Hint", hint)
	self:_render_upgrade()
	self:_render_status()
	self:_render_bag()
end

function TravelController:_render()
	if not self._hud or self._disposed then
		return
	end
	local state = self._state
	if not state then
		return
	end
	write(
		self._hud,
		"Root.Top.Resources",
		string.format(
			"金币 %s · 仓库 %s · 行囊 %s/%s · 木材 %s",
			tostring(state.Coins),
			tostring(state.WarehouseSupplies or 0),
			tostring(state.PackedSupplies or 0),
			tostring(state.BagCapacity or "…"),
			tostring(state.Wood)
		)
	)
	self:_render_clock()
	self:_render_inventory()
	self:_render_collection()
end

function TravelController:_prompt(prompt: ProximityPrompt, triggeringPlayer: Player?)
	if triggeringPlayer and triggeringPlayer ~= Players.LocalPlayer then
		return
	end
	local action = attribute(prompt, "TravelAction")
	if type(action) ~= "string" then
		return
	end
	local owner = attribute(prompt, "OwnerUserId")
	if owner and owner ~= 0 and owner ~= Players.LocalPlayer.UserId then
		self:_notice(
			if action == "OpenContainer" then "此箱属于其他玩家。" else "此入口属于其他玩家。"
		)
		return
	end
	if action == "OpenContainer" then
		local containerId = attribute(prompt, "ContainerId")
		if type(containerId) == "string" then
			self:_request("OpenContainer", { ContainerId = containerId })
		else
			self:_open("Inventory")
		end
	elseif action == "Bag" or action == "Voyage" then
		self:_open("Bag")
	elseif action == "HomeUpgrade" or action == "ShipUpgrade" then
		self:_open("Upgrade")
	elseif action == "Collection" then
		self:_open("Collection")
	elseif action == "Inventory" then
		self:_open("Inventory")
	else
		self:_open("Status")
	end
end

function TravelController:Start()
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local hud, hudCode = ResourceClient:Clone("UI.TravelBuddy.TravelHUD", playerGui)
	assert(hud and hud:IsA("ScreenGui"), "TravelBuddy HUD unavailable: " .. tostring(hudCode))
	local window, windowCode = ResourceClient:Clone("UI.TravelBuddy.TravelWindow", playerGui)
	assert(window and window:IsA("ScreenGui"), "TravelBuddy window unavailable: " .. tostring(windowCode))
	self._hud = hud
	self._window = window
	self._sceneAnimation = TravelSceneAnimation.new(child(hud, "Root.TravelScene.Illustration"))
	self._hudBinding = WindowBinding.Bind(hud)
	self._navigation = WindowNavigation.new()
	self._windowBinding = self._navigation:Register(
		window,
		{ DefaultSelection = child(window, "Root.Panel.Header.Close"), CloseOnBack = true }
	)
	self._navigation:SetActive(true)
	table.insert(
		self._connections,
		window:GetPropertyChangedSignal("Enabled"):Connect(function()
			if not window.Enabled then
				self._viewToken += 1
			end
		end)
	)
	self:_make_lists()
	local content = child(window, "Root.Panel.Content")
	self:_bind(hud, "Root.TravelWatch", function()
		self:_watch(true)
	end)
	self:_bind(hud, "Root.TravelScene.Close", function()
		self:_watch(false)
	end)
	self:_bind(hud, "Root.ReturnNotice.Dismiss", function()
		local journey = self._state and self._state.Journey
		self._dismissedReturnJourney = journey and journey.Id
		self:_render_clock()
	end)
	table.insert(
		self._connections,
		UserInputService.InputBegan:Connect(function(input, processed)
			if self._watchOpen and input.KeyCode == Enum.KeyCode.ButtonB then
				self:_watch(false)
				return
			end
			if processed then
				return
			end
			if input.KeyCode == Enum.KeyCode.ButtonR1 and not self._windowBinding:IsOpen() then
				self:_watch(not self._watchOpen)
			end
		end)
	)
	table.insert(
		self._connections,
		hud:GetPropertyChangedSignal("Enabled"):Connect(function()
			self._sceneAnimation:SetPlaying(hud.Enabled and child(hud, "Root.TravelScene").Visible)
		end)
	)
	self:_bind(window, "Root.Panel.Header.Close", function()
		self:_close()
	end)
	for _, option in
		{
			{ Path = "Actions.PackOne", Action = "PackSupply", All = false },
			{ Path = "Actions.PackFull", Action = "PackSupply", All = true },
			{ Path = "SecondaryActions.UnpackOne", Action = "UnpackSupply", All = false },
			{ Path = "SecondaryActions.UnpackAll", Action = "UnpackSupply", All = true },
		}
	do
		self:_bind(
			content,
			"Bag." .. option.Path,
			function()
				local quantity = self:_bag_quantity(option.Action, option.All)
				if quantity > 0 then
					self:_request(option.Action, { Quantity = quantity })
				end
			end,
			true,
			function()
				return self:_can_change_bag(option.Action, option.All)
			end
		)
	end
	for _, option in { { Name = "Pause", Action = "PauseTravel" }, { Name = "Resume", Action = "ResumeTravel" } } do
		self:_bind(
			content,
			"Bag.TravelActions." .. option.Name,
			function()
				self:_request(option.Action)
			end,
			true,
			function()
				return self:_can_control_travel(option.Action)
			end
		)
	end
	self:_bind(content, "Inventory.SellAll", function()
		self:_request("SellAll")
	end, true)
	for _, target in { "Home", "Ship" } do
		self:_bind(content, "Upgrade." .. target .. "Start", function()
			self:_request("Upgrade", { Target = target })
		end, true)
	end
	for _, action in { "BuySupply", "ClaimReturn", "ClaimRelief" } do
		local group = if action == "ClaimRelief" then "SecondaryActions" else "PrimaryActions"
		self:_bind(content, "Status." .. group .. "." .. action, function()
			self:_request(action, if action == "BuySupply" then { Quantity = 1 } else nil)
		end, true)
	end
	self:_bind(content, "Status.SecondaryActions.Refresh", function()
		self:_refresh()
	end, true)
	self:_bind(content, "Status.Retry", function()
		local pending = self._pending
		if pending then
			self:_perform(table.clone(pending.Payload))
		end
	end, true)
	self:_bind(content, "Result.Inventory", function()
		self:_open("Inventory")
	end)
	table.insert(
		self._connections,
		ProximityPromptService.PromptTriggered:Connect(function(prompt, triggeringPlayer)
			self:_prompt(prompt, triggeringPlayer)
		end)
	)
	local subscribed, connection = pcall(function()
		return self._net.OnServerEvent(Protocol.StateEvent, function(state)
			self:_accept(state)
		end)
	end)
	if subscribed then
		table.insert(self._connections, connection)
	else
		warn("TravelBuddy state subscription unavailable: " .. tostring(connection))
	end
	self._hudBinding:Open()
	self:_refresh()
	-- Local countdown display only; completion and rewards always come from server state.
	task.spawn(function()
		while not self._disposed do
			task.wait(1)
			if self._disposed then
				break
			end
			self:_render_clock()
			local state = self._state
			local boundary = state and state.Journey and state.State == "Voyaging" and state.Journey.EndAt
			if state and state.State == "Resting" then
				boundary = state.RestUntil
			end
			if state and state.State == "Preparing" and state.Plan and type(state.Plan.ReadyAt) == "number" then
				boundary = if boundary then math.min(boundary, state.Plan.ReadyAt) else state.Plan.ReadyAt
			end
			-- Read dock availability from the server after the visual return finishes.
			-- A countdown alone never grants permission to change the bag.
			if state and state.Journey and state.CanManageBag ~= true then
				local dockBoundary = state.Journey.EndAt + (state.ReturnSeconds or self:_setting("ReturnSeconds") or 0)
				boundary = if boundary then math.min(boundary, dockBoundary) else dockBoundary
			end
			if boundary and self:_now() >= boundary and self:_now() >= self._nextBoundaryRead and not self._busy then
				self._nextBoundaryRead = self:_now() + 5
				self:_refresh()
			end
		end
	end)
end

function TravelController:Dispose()
	if self._disposed then
		return
	end
	self._disposed = true
	if self._sceneAnimation then
		self._sceneAnimation:Dispose()
	end
	for _, connection in self._connections do
		connection:Disconnect()
	end
	for _, binding in self._buttons do
		binding:Dispose()
	end
	for _, binding in self._lists do
		binding:Dispose()
	end
	if self._navigation then
		self._navigation:Dispose()
	end
	if self._hudBinding then
		self._hudBinding:Dispose()
	end
	if self._hud then
		self._hud:Destroy()
	end
	if self._window then
		self._window:Destroy()
	end
end

return TravelController
