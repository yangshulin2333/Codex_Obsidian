--!strict

-- 显式登记窗口与手柄焦点；借用 GUI，不改变 Studio 布局或层级。
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local WindowBinding = require(script.Parent.WindowBinding)

export type Options = {
	CloseOnBack: boolean?,
	DefaultSelection: GuiObject?,
}
export type Entry = {
	Open: (self: Entry) -> boolean,
	Close: (self: Entry) -> boolean,
	IsOpen: (self: Entry) -> boolean,
	AddCleanup: (self: Entry, cleanup: () -> ()) -> (),
	Dispose: (self: Entry) -> (),
}
export type Navigation = {
	Register: (self: Navigation, gui: ScreenGui, options: Options?) -> Entry,
	SetActive: (self: Navigation, active: boolean) -> boolean,
	Back: (self: Navigation) -> boolean,
	Dispose: (self: Navigation) -> (),
}

type WindowState = {
	gui: ScreenGui?,
	window: WindowBinding.Binding?,
	entry: Entry,
	connections: { RBXScriptConnection },
	defaultSelection: GuiObject?,
	returnSelection: GuiObject?,
	closeOnBack: boolean,
	enabled: boolean,
	order: number,
	disposed: boolean,
}
type State = {
	windows: { WindowState },
	connections: { RBXScriptConnection },
	previousSelection: GuiObject?,
	focused: WindowState?,
	ownedSelection: GuiObject?,
	ownsSelection: boolean,
	emptySelection: boolean,
	writingSelection: boolean,
	changing: boolean,
	active: boolean,
	disposed: boolean,
	order: number,
}

local WindowNavigation = {}
local owners: { [ScreenGui]: WindowState } = setmetatable({}, { __mode = "k" })
local activeOwner: State? = nil

local function getPlayerGui(): PlayerGui?
	local player = Players.LocalPlayer
	return if player then player:FindFirstChildOfClass("PlayerGui") else nil
end

local function isSelectable(object: GuiObject?): boolean
	local playerGui = getPlayerGui()
	if not object or not playerGui or not object:IsDescendantOf(playerGui) or not object:GetStyled("Selectable") then
		return false
	end
	if object.AbsoluteSize.X <= 0 or object.AbsoluteSize.Y <= 0 then
		return false
	end
	if object:IsA("GuiButton") and (not object:GetStyled("Active") or not object:GetStyled("Interactable")) then
		return false
	end
	local parent: Instance? = object
	while parent and parent ~= playerGui do
		if parent:IsA("GuiObject") and not parent:GetStyled("Visible") then
			return false
		end
		if parent:IsA("LayerCollector") and not parent.Enabled then
			return false
		end
		parent = parent.Parent
	end
	return true
end

function WindowNavigation.new(): Navigation
	assert(RunService:IsClient(), "WindowNavigation.new is client-only")
	local state: State = {
		windows = {},
		connections = {},
		previousSelection = nil,
		focused = nil,
		ownedSelection = nil,
		ownsSelection = false,
		emptySelection = false,
		writingSelection = false,
		changing = false,
		active = false,
		disposed = false,
		order = 0,
	}
	local navigation = {} :: Navigation

	local function assertReady()
		assert(not state.disposed, "WINDOW_NAVIGATION_DISPOSED: create a new navigation")
		assert(not state.changing, "WINDOW_NAVIGATION_BUSY: finish the current operation first")
	end

	local function getTop(backOnly: boolean): WindowState?
		local playerGui = getPlayerGui()
		local top: WindowState? = nil
		for _, item in state.windows do
			local gui, window = item.gui, item.window
			if
				not item.disposed
				and gui
				and window
				and window:IsOpen()
				and playerGui
				and gui:IsDescendantOf(playerGui)
			then
				if not backOnly or item.closeOnBack then
					local topGui = if top then top.gui else nil
					if
						not top
						or not topGui
						or gui.DisplayOrder > topGui.DisplayOrder
						or (gui.DisplayOrder == topGui.DisplayOrder and item.order > top.order)
					then
						top = item
					end
				end
			end
		end
		return top
	end

	local function setSelection(object: GuiObject?, owner: WindowState?)
		local wasChanging = state.changing
		state.changing = true
		state.writingSelection = true
		local ok, failure = pcall(function()
			GuiService.SelectedObject = object
		end)
		state.writingSelection = false
		state.ownsSelection = ok
			and GuiService.SelectedObject == object
			and owner ~= nil
			and not owner.disposed
			and owner.gui ~= nil
			and owner.gui.Enabled
		state.emptySelection = state.ownsSelection and object == nil
		state.focused = if state.ownsSelection then owner else nil
		state.ownedSelection = if state.ownsSelection then object else nil
		state.changing = wasChanging
		if not ok then
			warn("WindowNavigation selection failed: " .. tostring(failure))
		end
	end

	local function syncOwnership()
		if state.writingSelection or not state.ownsSelection then
			return
		end
		local selected, focused = GuiService.SelectedObject, state.focused
		local gui = if focused then focused.gui else nil
		if selected and gui and selected:IsDescendantOf(gui) then
			state.emptySelection = false
			state.ownedSelection = selected
			return
		end
		local playerGui = getPlayerGui()
		local removed = focused
			and (
				focused.disposed
				or not gui
				or not playerGui
				or not gui:IsDescendantOf(playerGui)
				or (focused.window and not focused.window:IsOpen())
			)
		-- 主动置空仍有归还资格；关闭/移除导致的引擎置空亦保留到本轮恢复。
		if not selected and focused and (state.emptySelection or removed) then
			return
		end
		-- Destroy 后引擎可能保留非 nil 的失效实例；只认可最后拥有的同一对象。
		if removed and selected ~= nil and selected == state.ownedSelection then
			return
		end
		state.ownsSelection = false
		state.emptySelection = false
		state.focused = nil
		state.ownedSelection = nil
	end

	local function updateFocus(force: boolean, returnSelection: GuiObject?)
		if not state.active or state.disposed or activeOwner ~= state or state.writingSelection then
			return
		end
		-- Deferred 信号可能尚未运行，归还前直接核对当前选择，避免抢回外部焦点。
		syncOwnership()
		if UserInputService.PreferredInput ~= Enum.PreferredInput.Gamepad then
			return
		end
		local top = getTop(false)
		-- 没有窗口且已无本模块焦点时，输入切换不恢复过时的外部选择。
		if not top and not state.ownsSelection then
			return
		end
		if force and top and not state.ownsSelection then
			-- 记录实际接管前的对象；键鼠阶段或外部系统可能已改变选择。
			local previous = GuiService.SelectedObject
			state.previousSelection = previous
			top.returnSelection = previous
		end
		if top == state.focused and state.ownsSelection then
			return
		end
		if not force and not state.ownsSelection then
			return
		end
		local target: GuiObject? = nil
		local topGui = if top then top.gui else nil
		if isSelectable(returnSelection) and (not topGui or (returnSelection :: GuiObject):IsDescendantOf(topGui)) then
			target = returnSelection
		elseif
			top
			and topGui
			and isSelectable(top.defaultSelection)
			and (top.defaultSelection :: GuiObject):IsDescendantOf(topGui)
		then
			target = top.defaultSelection
		elseif not top and isSelectable(state.previousSelection) then
			target = state.previousSelection
		end
		-- 无有效默认目标时主动清空，仍记住这一轮归还资格，不扫描或选择后层按钮。
		setSelection(target, if topGui and (not target or target:IsDescendantOf(topGui)) then top else nil)
	end

	local function refresh(item: WindowState)
		local gui = item.gui
		if state.disposed or item.disposed or not gui then
			return
		end
		local opened = gui.Enabled
		if opened ~= item.enabled then
			item.enabled = opened
			if opened then
				state.order += 1
				item.order = state.order
				item.returnSelection = GuiService.SelectedObject
				updateFocus(getTop(false) == item, nil)
			else
				updateFocus(false, item.returnSelection)
				item.returnSelection = nil
			end
		else
			updateFocus(false, nil)
		end
	end

	local function disposeEntry(item: WindowState)
		if item.disposed then
			return
		end
		item.disposed = true
		local gui, window = item.gui, item.window
		updateFocus(false, item.returnSelection)
		for _, connection in item.connections do
			connection:Disconnect()
		end
		item.connections = {}
		if window then
			-- WindowBinding 的同步逆序清理完成前保留 owner；不取消误用 yield 的清理。
			window:Dispose()
		end
		if gui and owners[gui] == item then
			owners[gui] = nil
		end
		local index = table.find(state.windows, item)
		if index then
			table.remove(state.windows, index)
		end
		item.gui = nil
		item.window = nil
		item.defaultSelection = nil
		item.returnSelection = nil
	end

	function navigation.Register(_navigation: Navigation, gui: ScreenGui, options: Options?): Entry
		assertReady()
		assert(typeof(gui) == "Instance" and gui:IsA("ScreenGui"), "WindowNavigation.Register expects a ScreenGui")
		assert(owners[gui] == nil, "WINDOW_NAVIGATION_ALREADY_REGISTERED: finish disposing the old entry first")
		assert(options == nil or type(options) == "table", "WindowNavigation.Register expects an options table")
		local settings: Options = options or {}
		assert(settings.CloseOnBack == nil or type(settings.CloseOnBack) == "boolean", "CloseOnBack must be a boolean")
		local selection = settings.DefaultSelection
		assert(
			selection == nil
				or (typeof(selection) == "Instance" and selection:IsA("GuiObject") and selection:IsDescendantOf(gui)),
			"DefaultSelection must be a GuiObject inside the registered ScreenGui"
		)
		local window = WindowBinding.Bind(gui)
		local entry = {} :: Entry
		local item: WindowState = {
			gui = gui,
			window = window,
			entry = entry,
			connections = {},
			defaultSelection = selection,
			returnSelection = nil,
			closeOnBack = settings.CloseOnBack ~= false,
			enabled = false,
			order = 0,
			disposed = false,
		}

		local function assertEntryReady(): WindowBinding.Binding
			assertReady()
			assert(not item.disposed and item.window, "WINDOW_NAVIGATION_ENTRY_DISPOSED: register the window again")
			return item.window :: WindowBinding.Binding
		end

		local function changeWindow(open: boolean): boolean
			local target = assertEntryReady()
			syncOwnership()
			state.changing = true
			local ok, result = pcall(function()
				local changed = if open then target:Open() else target:Close()
				refresh(item)
				return changed
			end)
			state.changing = false
			if not ok then
				error(result, 0)
			end
			return result
		end

		function entry:Open(): boolean
			return changeWindow(true)
		end
		function entry:Close(): boolean
			return changeWindow(false)
		end
		function entry:IsOpen(): boolean
			local target = item.window
			return not item.disposed and not state.disposed and target ~= nil and target:IsOpen()
		end
		function entry:AddCleanup(cleanup: () -> ())
			local target = assertEntryReady()
			assert(type(cleanup) == "function", "WindowNavigation.AddCleanup expects a function")
			target:AddCleanup(function()
				-- 包括 WindowBinding 的外部销毁清理，均禁止重新进入导航操作。
				local wasChanging = state.changing
				state.changing = true
				local ok, failure = xpcall(cleanup, debug.traceback)
				state.changing = wasChanging
				if not ok then
					error(failure, 0)
				end
			end)
		end
		function entry:Dispose()
			if item.disposed then
				return
			end
			assertReady()
			syncOwnership()
			state.changing = true
			disposeEntry(item)
			state.changing = false
		end

		owners[gui] = item
		table.insert(state.windows, item)
		-- 最先登记，逆序清理时最后执行；外部销毁也等业务清理完成才释放登记。
		window:AddCleanup(function()
			local wasChanging = state.changing
			state.changing = true
			disposeEntry(item)
			state.changing = wasChanging
		end)
		table.insert(
			item.connections,
			gui:GetPropertyChangedSignal("Enabled"):Connect(function()
				refresh(item)
			end)
		)
		table.insert(
			item.connections,
			gui:GetPropertyChangedSignal("DisplayOrder"):Connect(function()
				refresh(item)
			end)
		)
		table.insert(
			item.connections,
			gui.AncestryChanged:Connect(function()
				refresh(item)
			end)
		)
		state.changing = true
		refresh(item)
		state.changing = false
		return table.freeze(entry)
	end

	function navigation:SetActive(active: boolean): boolean
		assertReady()
		assert(type(active) == "boolean", "WindowNavigation.SetActive expects a boolean")
		if state.active == active then
			return false
		end
		state.changing = true
		if active then
			if activeOwner ~= nil then
				state.changing = false
				error("WINDOW_NAVIGATION_FOCUS_OWNED: deactivate the current navigation first", 2)
			end
			activeOwner = state
			state.active = true
			state.previousSelection = GuiService.SelectedObject
			table.insert(
				state.connections,
				GuiService:GetPropertyChangedSignal("SelectedObject"):Connect(function()
					syncOwnership()
				end)
			)
			table.insert(
				state.connections,
				UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(function()
					syncOwnership()
					if UserInputService.PreferredInput == Enum.PreferredInput.Gamepad then
						updateFocus(true, nil)
					elseif state.ownsSelection then
						setSelection(nil, nil)
					end
				end)
			)
			updateFocus(true, nil)
		else
			syncOwnership()
			state.active = false
			for _, connection in state.connections do
				connection:Disconnect()
			end
			state.connections = {}
			if state.ownsSelection then
				setSelection(if isSelectable(state.previousSelection) then state.previousSelection else nil, nil)
			end
			state.previousSelection = nil
			state.focused = nil
			state.ownedSelection = nil
			state.ownsSelection = false
			state.emptySelection = false
			if activeOwner == state then
				activeOwner = nil
			end
		end
		state.changing = false
		return true
	end

	function navigation:Back(): boolean
		assertReady()
		if not state.active then
			return false
		end
		local top = getTop(true)
		return if top then top.entry:Close() else false
	end

	function navigation:Dispose()
		if state.disposed then
			return
		end
		assertReady()
		syncOwnership()
		state.disposed = true
		state.changing = true
		for _, connection in state.connections do
			connection:Disconnect()
		end
		state.connections = {}
		if state.ownsSelection then
			setSelection(if isSelectable(state.previousSelection) then state.previousSelection else nil, nil)
		end
		for index = #state.windows, 1, -1 do
			disposeEntry(state.windows[index])
		end
		-- 同步清理完成后才释放焦点 lease，避免新旧资源重叠。
		if activeOwner == state then
			activeOwner = nil
		end
		state.active = false
		state.previousSelection = nil
		state.focused = nil
		state.ownedSelection = nil
		state.ownsSelection = false
		state.emptySelection = false
		state.changing = false
	end

	return table.freeze(navigation)
end

return WindowNavigation
