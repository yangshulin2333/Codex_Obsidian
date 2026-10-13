--!strict

-- 借用客户端 ScreenGui，统一显示开关与清理；不拥有 GUI 实例或布局。
local RunService = game:GetService("RunService")

export type Binding = {
	Open: (self: Binding) -> boolean,
	Close: (self: Binding) -> boolean,
	IsOpen: (self: Binding) -> boolean,
	AddCleanup: (self: Binding, cleanup: () -> ()) -> (),
	Dispose: (self: Binding) -> (),
}

type Cleanup = () -> ()
type State = {
	gui: ScreenGui?,
	cleanups: { Cleanup },
	destroying: RBXScriptConnection?,
	disposed: boolean,
}

local WindowBinding = {}
local bindings: { [ScreenGui]: State } = setmetatable({}, { __mode = "k" })

local function getTarget(state: State): ScreenGui
	assert(not state.disposed, "WINDOW_BINDING_DISPOSED: bind the window again")
	local gui = state.gui
	assert(gui, "WINDOW_BINDING_DISPOSED: bind the window again")
	return gui
end

function WindowBinding.Bind(gui: ScreenGui): Binding
	assert(RunService:IsClient(), "WindowBinding.Bind is client-only")
	assert(typeof(gui) == "Instance" and gui:IsA("ScreenGui"), "WindowBinding.Bind expects a ScreenGui")
	assert(bindings[gui] == nil, "WINDOW_ALREADY_BOUND: finish disposing the old binding first")

	local state: State = {
		gui = gui,
		cleanups = {},
		destroying = nil,
		disposed = false,
	}
	local binding = {} :: Binding

	function binding:Open(): boolean
		local target = getTarget(state)
		if target.Enabled then
			return false
		end
		target.Enabled = true
		return true
	end

	function binding:Close(): boolean
		local target = getTarget(state)
		if not target.Enabled then
			return false
		end
		target.Enabled = false
		return true
	end

	function binding:IsOpen(): boolean
		local target = state.gui
		return not state.disposed and target ~= nil and target.Enabled
	end

	function binding:AddCleanup(cleanup: Cleanup)
		getTarget(state)
		assert(type(cleanup) == "function", "WindowBinding.AddCleanup expects a function")
		table.insert(state.cleanups, cleanup)
	end

	function binding:Dispose()
		if state.disposed then
			return
		end
		state.disposed = true
		if state.destroying then
			state.destroying:Disconnect()
			state.destroying = nil
		end

		local target = state.gui
		local path = target and target:GetFullName() or "ScreenGui"
		local cleanups = state.cleanups
		state.gui = nil
		state.cleanups = {}
		-- 逆序逐项清理。函数须同步返回；误用 yield 会延后 Dispose 和重绑。
		for index = #cleanups, 1, -1 do
			local cleanup = cleanups[index]
			local ok, failure = xpcall(cleanup, debug.traceback)
			if not ok then
				warn("WindowBinding cleanup failed: " .. path .. "\n" .. tostring(failure))
			end
		end
		-- 清理期间保留登记，避免新 owner 与尚未释放的旧资源重叠。
		if target and bindings[target] == state then
			bindings[target] = nil
		end
	end

	bindings[gui] = state
	state.destroying = gui.Destroying:Connect(function()
		binding:Dispose()
	end)

	return table.freeze(binding)
end

return WindowBinding
