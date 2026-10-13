--!strict

-- 显式提交显示状态与业务许可；只借用节点，不处理请求或布局。
local RunService = game:GetService("RunService")

export type Status = "Idle" | "Busy" | "Success" | "Error"
type View = Status | "Disabled"
export type Options = {
	States: { [View]: GuiObject }?,
	Message: TextLabel?,
}
export type Snapshot = { Enabled: boolean, State: Status, Message: string? }
export type Binding = {
	SetEnabled: (self: Binding, enabled: boolean) -> (),
	SetState: (self: Binding, status: Status, message: string?) -> (),
	GetState: (self: Binding) -> Snapshot?,
	CanActivate: (self: Binding) -> boolean,
	Dispose: (self: Binding) -> (),
}
type State = {
	root: GuiObject?,
	views: { [View]: GuiObject },
	label: TextLabel?,
	claims: { GuiObject },
	connections: { RBXScriptConnection },
	enabled: boolean,
	status: Status,
	message: string?,
	rendering: boolean,
	stopRequested: boolean,
	disposed: boolean,
}

local FeedbackBinding = {}
local owners: { [GuiObject]: State } = setmetatable({}, { __mode = "k" })
local roles: { [string]: boolean } = { Idle = true, Busy = true, Disabled = true, Success = true, Error = true }

function FeedbackBinding.Bind(root: GuiObject, options: Options): Binding
	assert(RunService:IsClient(), "FeedbackBinding.Bind is client-only")
	assert(typeof(root) == "Instance" and root:IsA("GuiObject"), "FeedbackBinding.Bind expects a GuiObject root")
	assert(type(options) == "table", "FeedbackBinding.Bind expects an options table")
	assert(options.States == nil or type(options.States) == "table", "FeedbackBinding.States must be a table")
	local views: { [View]: GuiObject } = {}
	local claims = { root }
	for role, gui in pairs(options.States or {}) do
		assert(type(role) == "string" and roles[role], "FEEDBACK_STATE_INVALID: unknown view")
		assert(
			typeof(gui) == "Instance" and gui:IsA("GuiObject") and gui:IsDescendantOf(root),
			"FEEDBACK_NODE_INVALID: state nodes must be inside root"
		)
		for _, previous in pairs(views) do
			assert(
				previous ~= gui and not previous:IsDescendantOf(gui) and not gui:IsDescendantOf(previous),
				"FEEDBACK_NODE_INVALID: state nodes must be separate"
			)
		end
		views[role :: View] = gui
		table.insert(claims, gui)
	end
	local label = options.Message
	if label ~= nil then
		assert(
			typeof(label) == "Instance" and label:IsA("TextLabel") and (label == root or label:IsDescendantOf(root)),
			"FEEDBACK_NODE_INVALID: Message must be a TextLabel inside root"
		)
		if not table.find(claims, label) then
			table.insert(claims, label)
		end
	end
	assert(next(views) ~= nil or label ~= nil, "FEEDBACK_NODE_INVALID: provide a state node or Message")
	for _, gui in claims do
		assert(owners[gui] == nil, "FEEDBACK_ALREADY_BOUND: finish disposing the old binding first")
	end
	local state: State = {
		root = root,
		views = views,
		label = label,
		claims = claims,
		connections = {},
		enabled = false,
		status = "Idle",
		message = nil,
		rendering = false,
		stopRequested = false,
		disposed = false,
	}
	local binding = {} :: Binding
	local function targetsPresent(): boolean
		local target = state.root
		if not target then
			return false
		end
		for _, gui in state.claims do
			if gui ~= target and not gui:IsDescendantOf(target) then
				return false
			end
		end
		return true
	end

	local function assertReady()
		assert(not state.disposed and not state.stopRequested, "FEEDBACK_BINDING_DISPOSED: bind the feedback again")
		assert(not state.rendering, "FEEDBACK_BINDING_BUSY: finish rendering first")
		if not targetsPresent() then
			binding:Dispose()
			error("FEEDBACK_TARGET_LOST: a declared node left the root", 2)
		end
	end

	local function render(message: string?)
		state.rendering = true
		local function assertTargets()
			if not targetsPresent() then
				state.stopRequested = true
			end
			assert(not state.stopRequested, "FEEDBACK_TARGET_LOST: a declared node left the root")
		end
		local ok, failure = xpcall(function()
			local selected: View = if state.status == "Busy"
				then "Busy"
				elseif not state.enabled then "Disabled"
				else state.status
			for role, gui in pairs(state.views) do
				assertTargets()
				gui.Visible = role == selected
			end
			if message ~= nil and state.label then
				assertTargets()
				state.label.Text = message
			end
			assertTargets()
		end, debug.traceback)
		state.rendering = false
		if state.stopRequested then
			binding:Dispose()
		end
		if not ok then
			error(failure, 0)
		end
	end

	function binding:SetEnabled(enabled: boolean)
		assertReady()
		assert(type(enabled) == "boolean", "FeedbackBinding.SetEnabled expects a boolean")
		state.enabled = enabled
		render(nil)
	end

	function binding:SetState(status: Status, message: string?)
		assertReady()
		assert(
			status ~= "Disabled" and roles[status] == true,
			"FEEDBACK_STATE_INVALID: use Idle, Busy, Success or Error"
		)
		assert(message == nil or type(message) == "string", "FeedbackBinding.SetState expects a string message")
		state.status = status
		if message ~= nil then
			state.message = message
		end
		render(message)
	end

	function binding:GetState(): Snapshot?
		if state.disposed or state.stopRequested or not targetsPresent() then
			return nil
		end
		return table.freeze({ Enabled = state.enabled, State = state.status, Message = state.message })
	end

	function binding:CanActivate(): boolean
		local target = state.root
		if
			state.disposed
			or state.stopRequested
			or state.rendering
			or not target
			or not target:IsDescendantOf(game)
		then
			return false
		end
		return targetsPresent() and state.enabled and state.status ~= "Busy"
	end

	function binding:Dispose()
		if state.disposed then
			return
		end
		assert(not state.rendering, "FEEDBACK_BINDING_BUSY: finish rendering first")
		state.disposed = true
		for _, connection in state.connections do
			connection:Disconnect()
		end
		state.connections = {}
		for _, gui in state.claims do
			if owners[gui] == state then
				owners[gui] = nil
			end
		end
		state.claims = {}
		state.views = {}
		state.root = nil
		state.label = nil
		state.message = nil
	end

	for _, gui in claims do
		owners[gui] = state
		table.insert(
			state.connections,
			gui.Destroying:Connect(function()
				state.stopRequested = true
				if not state.rendering then
					binding:Dispose()
				end
			end)
		)
	end
	return table.freeze(binding)
end

return FeedbackBinding
