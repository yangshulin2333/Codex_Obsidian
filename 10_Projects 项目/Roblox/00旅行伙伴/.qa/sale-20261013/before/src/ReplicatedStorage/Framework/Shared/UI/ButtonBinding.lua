--!strict

-- 客户端按钮事件绑定；不创建 UI、不改布局，也不拥有按钮实例。
local RunService = game:GetService("RunService")

export type Binding = {
	Dispose: (self: Binding) -> (),
}

type Callback = (inputObject: InputObject, clickCount: number) -> ()
type Gate = () -> boolean
type State = {
	button: GuiButton?,
	callback: Callback?,
	gate: Gate?,
	activated: RBXScriptConnection?,
	destroying: RBXScriptConnection?,
	disposed: boolean,
}

local ButtonBinding = {}
local bindings: { [GuiButton]: State } = setmetatable({}, { __mode = "k" })
local running: { [GuiButton]: {} } = setmetatable({}, { __mode = "k" })

-- 检查有效显示状态；祖先的 Active 不代表其子按钮不可交互。
local function isAvailable(button: GuiButton): boolean
	if not button:IsDescendantOf(game) or not button:GetStyled("Active") or not button:GetStyled("Interactable") then
		return false
	end

	local foundLayer = false
	local object: Instance? = button
	while object do
		if object:IsA("GuiObject") and not object:GetStyled("Visible") then
			return false
		end
		if object:IsA("LayerCollector") then
			if not object.Enabled then
				return false
			end
			foundLayer = true
		end
		object = object.Parent
	end
	return foundLayer
end

function ButtonBinding.Bind(button: GuiButton, callback: Callback, canActivate: Gate?): Binding
	assert(RunService:IsClient(), "ButtonBinding.Bind is client-only")
	assert(typeof(button) == "Instance" and button:IsA("GuiButton"), "ButtonBinding.Bind expects a GuiButton")
	assert(type(callback) == "function", "ButtonBinding.Bind expects a callback")
	assert(canActivate == nil or type(canActivate) == "function", "ButtonBinding.Bind expects a canActivate function")
	assert(bindings[button] == nil, "BUTTON_ALREADY_BOUND: dispose the old binding first")

	local state: State = {
		button = button,
		callback = callback,
		gate = canActivate,
		activated = nil,
		destroying = nil,
		disposed = false,
	}
	local binding = {} :: Binding

	function binding:Dispose()
		if state.disposed then
			return
		end
		state.disposed = true
		if state.activated then
			state.activated:Disconnect()
			state.activated = nil
		end
		if state.destroying then
			state.destroying:Disconnect()
			state.destroying = nil
		end
		local target = state.button
		if target and bindings[target] == state then
			bindings[target] = nil
		end
		state.button = nil
		state.callback = nil
		state.gate = nil
		-- 已开始的回调继续执行；它返回前，同按钮的新绑定也不能并发进入。
	end

	bindings[button] = state
	state.destroying = button.Destroying:Connect(function()
		binding:Dispose()
	end)
	state.activated = button.Activated:Connect(function(inputObject: InputObject, clickCount: number)
		local target, handler = state.button, state.callback
		if state.disposed or not target or not handler or running[target] or not isAvailable(target) then
			return
		end

		local token = {}
		running[target] = token
		local path = target:GetFullName()
		local gate = state.gate
		local ok, failure = xpcall(function()
			if gate then
				local allowed = gate()
				assert(type(allowed) == "boolean", "ButtonBinding.canActivate must return a boolean")
				if not allowed or state.disposed or state.button ~= target or not isAvailable(target) then
					return
				end
			end
			handler(inputObject, clickCount)
		end, debug.traceback)
		if running[target] == token then
			running[target] = nil
		end
		if not ok then
			warn("ButtonBinding callback failed: " .. path .. "\n" .. tostring(failure))
		end
	end)

	return table.freeze(binding)
end

return ButtonBinding
