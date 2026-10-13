--!strict

-- 按稳定 key 复用列表项；只拥有自建克隆，布局由 Studio 管理。
local RunService = game:GetService("RunService")

export type Key = string | number
export type Item = {
	Gui: GuiObject,
	Key: Key,
	GetData: (self: Item) -> any,
	AddCleanup: (self: Item, cleanup: () -> ()) -> (),
}
export type Options = {
	GetKey: (data: any) -> Key,
	Mount: ((item: Item) -> ())?,
	Render: (item: Item, data: any, index: number) -> (),
}
export type Binding = {
	Update: (self: Binding, data: { any }) -> (),
	Get: (self: Binding, key: Key) -> Item?,
	Dispose: (self: Binding) -> (),
}

type Entry = {
	item: Item,
	data: any,
	cleanups: { () -> () },
	destroying: RBXScriptConnection?,
	disposed: boolean,
	lost: boolean,
	attached: boolean,
}
type Record = { key: Key, data: any, entry: Entry? }
type State = {
	container: GuiObject?,
	template: GuiObject?,
	options: Options?,
	entries: { [Key]: Entry },
	order: { Entry },
	connections: { RBXScriptConnection },
	busy: boolean,
	disposed: boolean,
	stopRequested: boolean,
}

local ListBinding = {}
local owners: { [GuiObject]: State } = setmetatable({}, { __mode = "k" })

local function isKey(key: any): boolean
	if type(key) == "string" then
		return key ~= ""
	end
	return type(key) == "number" and key == key and key ~= math.huge and key ~= -math.huge
end

local function prepare(data: { any }, getKey: (any) -> Key): { Record }
	assert(type(data) == "table", "ListBinding.Update expects a dense array")
	local count, maximum = 0, 0
	for index in pairs(data) do
		assert(type(index) == "number" and index >= 1 and index % 1 == 0, "LIST_DATA_INVALID: use a dense array")
		count += 1
		maximum = math.max(maximum, index)
	end
	assert(count == maximum, "LIST_DATA_INVALID: array has holes")
	local values = table.clone(data)
	local seen: { [Key]: boolean } = {}
	local records: { Record } = {}
	for index = 1, count do
		local value = values[index]
		local key = getKey(value)
		assert(isKey(key), "LIST_KEY_INVALID: use a nonempty string or finite number")
		assert(not seen[key], "LIST_KEY_DUPLICATE: " .. tostring(key))
		seen[key] = true
		table.insert(records, { key = key, data = value, entry = nil })
	end
	return records
end

function ListBinding.Bind(container: GuiObject, template: GuiObject, options: Options): Binding
	assert(RunService:IsClient(), "ListBinding.Bind is client-only")
	assert(
		typeof(container) == "Instance" and container:IsA("GuiObject"),
		"ListBinding.Bind expects a GuiObject container"
	)
	assert(
		typeof(template) == "Instance" and template:IsA("GuiObject"),
		"ListBinding.Bind expects a GuiObject template"
	)
	assert(
		container ~= template and not container:IsDescendantOf(template),
		"LIST_TEMPLATE_INVALID: template contains the container"
	)
	assert(
		template:GetAttribute("Template") == true and template.Archivable,
		"LIST_TEMPLATE_INVALID: use an archivable Template=true object"
	)
	assert(
		type(options) == "table" and type(options.GetKey) == "function" and type(options.Render) == "function",
		"ListBinding.Bind expects GetKey and Render"
	)
	assert(options.Mount == nil or type(options.Mount) == "function", "ListBinding.Mount must be a function")
	assert(owners[container] == nil, "LIST_ALREADY_BOUND: finish disposing the old binding first")
	local state: State = {
		container = container,
		template = template,
		options = { GetKey = options.GetKey, Mount = options.Mount, Render = options.Render },
		entries = {},
		order = {},
		connections = {},
		busy = false,
		disposed = false,
		stopRequested = false,
	}
	local binding = {} :: Binding

	local function assertReady()
		assert(not state.disposed and not state.stopRequested, "LIST_BINDING_DISPOSED: bind the list again")
		assert(not state.busy, "LIST_BINDING_BUSY: finish the current operation first")
	end

	local function clean(entry: Entry)
		if entry.disposed then
			return
		end
		entry.disposed = true
		if entry.destroying then
			entry.destroying:Disconnect()
			entry.destroying = nil
		end
		if state.entries[entry.item.Key] == entry then
			state.entries[entry.item.Key] = nil
		end
		local cleanups = entry.cleanups
		entry.cleanups = {}
		entry.data = nil
		for index = #cleanups, 1, -1 do
			local ok, failure = xpcall(cleanups[index], debug.traceback)
			if not ok then
				warn("ListBinding cleanup failed: " .. tostring(entry.item.Key) .. "\n" .. tostring(failure))
			end
		end
		entry.item.Gui:Destroy()
	end

	local function removeLost()
		-- 清理可引发另一个自有项销毁；重新扫描直到现有集合全部处理。
		local removed = true
		while removed do
			removed = false
			for index = #state.order, 1, -1 do
				local entry = state.order[index]
				if entry.lost or entry.disposed then
					clean(entry)
					table.remove(state.order, index)
					removed = true
				end
			end
		end
	end

	local function create(record: Record, source: GuiObject): Entry
		local gui = source:Clone()
		assert(gui, "LIST_CLONE_FAILED: template must be archivable")
		local item = {} :: Item
		local entry: Entry = {
			item = item,
			data = record.data,
			cleanups = {},
			destroying = nil,
			disposed = false,
			lost = false,
			attached = false,
		}
		item.Gui = gui
		item.Key = record.key
		function item:GetData(): any
			local missing = entry.attached and gui.Parent ~= state.container
			return if entry.disposed
					or entry.lost
					or missing
					or state.disposed
					or state.stopRequested
				then nil
				else entry.data
		end
		function item:AddCleanup(cleanup: () -> ())
			assert(
				not entry.disposed
					and not entry.lost
					and not state.disposed
					and not state.stopRequested
					and (not entry.attached or gui.Parent == state.container),
				"LIST_ITEM_DISPOSED: item no longer exists"
			)
			assert(type(cleanup) == "function", "ListBinding.AddCleanup expects a function")
			table.insert(entry.cleanups, cleanup)
		end
		entry.item = table.freeze(item)
		gui:SetAttribute("Template", nil)
		gui.Visible = true
		entry.destroying = gui.Destroying:Connect(function()
			entry.lost = true
			if not state.busy and not state.disposed then
				state.busy = true
				removeLost()
				state.busy = false
				if state.stopRequested then
					binding:Dispose()
				end
			end
		end)
		return entry
	end

	function binding:Get(key: Key): Item?
		if state.disposed or state.stopRequested then
			return nil
		end
		assert(isKey(key), "LIST_KEY_INVALID: use a nonempty string or finite number")
		local entry = state.entries[key]
		return if entry
				and not entry.disposed
				and not entry.lost
				and entry.item.Gui.Parent == state.container
			then entry.item
			else nil
	end

	function binding:Update(data: { any })
		assertReady()
		local target, source, settings = state.container, state.template, state.options
		assert(target and source and settings, "LIST_BINDING_DISPOSED")
		state.busy = true
		local staged: { Entry } = {}
		local committed = false
		local ok, failure = xpcall(function()
			local records = prepare(data, settings.GetKey)
			assert(not state.stopRequested, "LIST_TARGET_DESTROYED")
			assert(source:GetAttribute("Template") == true and source.Archivable, "LIST_TEMPLATE_INVALID")
			for _, record in records do
				local entry = state.entries[record.key]
				if entry and entry.item.Gui.Parent ~= target then
					entry.lost = true
				end
				if not entry or entry.disposed or entry.lost then
					entry = create(record, source)
					table.insert(staged, entry)
					if settings.Mount then
						settings.Mount(entry.item)
					end
				end
				assert(not entry.lost and not state.stopRequested, "LIST_TARGET_DESTROYED")
				record.entry = entry
			end
			for _, entry in staged do
				entry.item.Gui.Parent = target
				entry.attached = true
				assert(not entry.lost and not state.stopRequested, "LIST_TARGET_DESTROYED")
			end
			local previous = state.order
			state.entries = {}
			state.order = {}
			for _, record in records do
				local entry = record.entry :: Entry
				entry.data = record.data
				state.entries[record.key] = entry
				table.insert(state.order, entry)
			end
			committed = true
			for index = #previous, 1, -1 do
				local entry = previous[index]
				if state.entries[entry.item.Key] ~= entry then
					clean(entry)
				end
			end
			local renderFailure: string? = nil
			local function assertPresent(entry: Entry)
				if entry.item.Gui.Parent ~= target then
					entry.lost = true
				end
				assert(not entry.lost and not state.stopRequested, "LIST_TARGET_DESTROYED: item moved or destroyed")
			end
			for index, record in records do
				local entry = record.entry :: Entry
				local rendered, message = xpcall(function()
					assertPresent(entry)
					settings.Render(entry.item, record.data, index)
					assertPresent(entry)
				end, debug.traceback)
				if not rendered and not renderFailure then
					renderFailure = tostring(message)
				end
			end
			if renderFailure then
				error("LIST_RENDER_FAILED: structure updated; fix Render and retry\n" .. renderFailure, 0)
			end
		end, debug.traceback)
		if not committed then
			for index = #staged, 1, -1 do
				clean(staged[index])
			end
		end
		removeLost()
		state.busy = false
		if state.stopRequested then
			self:Dispose()
		end
		if not ok then
			error(failure, 0)
		end
	end

	function binding:Dispose()
		if state.disposed then
			return
		end
		assert(not state.busy, "LIST_BINDING_BUSY: finish the current operation first")
		state.disposed = true
		state.busy = true
		for _, connection in state.connections do
			connection:Disconnect()
		end
		state.connections = {}
		for index = #state.order, 1, -1 do
			clean(state.order[index])
		end
		state.order = {}
		state.entries = {}
		local oldTarget = state.container
		if oldTarget and owners[oldTarget] == state then
			owners[oldTarget] = nil
		end
		state.container = nil
		state.template = nil
		state.options = nil
		state.busy = false
	end

	owners[container] = state
	local function stop()
		state.stopRequested = true
		if not state.busy then
			binding:Dispose()
		end
	end
	table.insert(state.connections, container.Destroying:Connect(stop))
	table.insert(state.connections, template.Destroying:Connect(stop))
	return table.freeze(binding)
end

return ListBinding
