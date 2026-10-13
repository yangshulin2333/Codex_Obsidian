--!strict

-- Native nodes own the layout. Only nodes marked Animation receive small local offsets.
local RunService = game:GetService("RunService")

local TravelSceneAnimation = {}
TravelSceneAnimation.__index = TravelSceneAnimation

local LOOP_SECONDS = 14
local TAU = math.pi * 2

local function child(root: Instance, name: string): any
	local node = root:FindFirstChild(name)
	assert(node and node:IsA("GuiObject"), "Travel scene GUI node missing: " .. name)
	return node
end

local function motionNode(root: Instance, name: string): any
	local node = child(root, name)
	assert(node:GetAttribute("Animation") == true, "Travel scene motion node must be marked Animation: " .. name)
	return {
		Node = node,
		Position = node.Position,
		Rotation = node.Rotation,
	}
end

local function boat(root: Instance, name: string): any
	local motion = motionNode(root, name)
	local frog = child(motion.Node, "Frog")
	child(frog, "Body")
	motion.EyesOpen = child(frog, "EyesOpen")
	motion.EyesClosed = child(frog, "EyesClosed")
	motion.Look = child(frog, "Look")
	motion.Drink = child(frog, "Drink")
	motion.Expression = nil
	motion.Defaults = {
		EyesOpen = motion.EyesOpen.Visible,
		EyesClosed = motion.EyesClosed.Visible,
		Look = motion.Look.Visible,
		Drink = motion.Drink.Visible,
	}
	return motion
end

local function offset(motion: any, x: number, y: number, rotation: number)
	local position = motion.Position
	motion.Node.Position = UDim2.new(position.X.Scale, position.X.Offset + x, position.Y.Scale, position.Y.Offset + y)
	motion.Node.Rotation = motion.Rotation + rotation
end

local function reset(motion: any)
	motion.Node.Position = motion.Position
	motion.Node.Rotation = motion.Rotation
	if motion.Defaults then
		for name, visible in pairs(motion.Defaults) do
			motion[name].Visible = visible
		end
		motion.Expression = nil
	end
end

local function disconnectAll(connections: { RBXScriptConnection })
	for _, connection in ipairs(connections) do
		connection:Disconnect()
	end
	table.clear(connections)
end

function TravelSceneAnimation.new(scene: Instance): any
	assert(scene:IsA("GuiObject"), "Travel scene must be a GuiObject")
	local self: any = setmetatable({
		_scene = scene,
		_seas = {},
		_boats = {},
		_visibilityConnections = {},
		_requested = false,
		_disposed = false,
		_elapsed = 0,
	}, TravelSceneAnimation)
	for id, name in pairs({ shallow = "Shallow", near = "Near" }) do
		local background = child(scene, name)
		self._seas[id] = {
			Node = background,
			Cloud = motionNode(background, "CloudLayer"),
			Wave = motionNode(background, "WaveLayer"),
		}
	end
	self._boats[1] = boat(scene, "BoatLv1")
	self._boats[2] = boat(scene, "BoatLv2")
	self:SetView("shallow", 1)
	self._ancestryConnection = scene.AncestryChanged:Connect(function()
		self:_watchVisibility()
	end)
	self._destroyingConnection = scene.Destroying:Connect(function()
		self:Dispose()
	end)
	self:_watchVisibility()
	return self
end

function TravelSceneAnimation:_reset()
	for _, background in pairs(self._seas) do
		reset(background.Cloud)
		reset(background.Wave)
	end
	for _, vessel in pairs(self._boats) do
		reset(vessel)
	end
	self._elapsed = 0
end

function TravelSceneAnimation:_visible(): boolean
	local current: Instance? = self._scene
	if not current.Parent or not self._scene:IsDescendantOf(game) then
		return false
	end
	while current do
		if current:IsA("GuiObject") and not current.Visible then
			return false
		end
		if current:IsA("LayerCollector") and not current.Enabled then
			return false
		end
		current = current.Parent
	end
	return true
end

function TravelSceneAnimation:_watchVisibility()
	disconnectAll(self._visibilityConnections)
	if self._disposed then
		return
	end
	local current: Instance? = self._scene
	while current do
		local property = if current:IsA("GuiObject")
			then "Visible"
			elseif current:IsA("LayerCollector") then "Enabled"
			else nil
		if property then
			table.insert(
				self._visibilityConnections,
				current:GetPropertyChangedSignal(property):Connect(function()
					self:_refreshPlayback()
				end)
			)
		end
		current = current.Parent
	end
	self:_refreshPlayback()
end

function TravelSceneAnimation:_step(delta: number)
	self._elapsed = (self._elapsed + delta) % LOOP_SECONDS
	local elapsed = self._elapsed
	local phase = elapsed / LOOP_SECONDS * TAU
	local background = self._currentSea
	local vessel = self._currentBoat
	offset(background.Cloud, math.sin(phase) * 8, 0, 0)
	offset(background.Wave, math.sin(phase * 2) * 10, math.sin(phase * 4) * 1.5, 0)
	offset(vessel, math.sin(phase) * 2, math.sin(phase * 4) * 3, math.sin(phase * 4 + 0.6) * 1.5)
	local blink = (elapsed >= 2.1 and elapsed < 2.24)
		or (elapsed >= 7.2 and elapsed < 7.34)
		or (elapsed >= 11.6 and elapsed < 11.74)
	local look = elapsed >= 5.6 and elapsed < 7.9
	local drink = elapsed >= 10.2 and elapsed < 11.3
	local expression = (if blink then 1 else 0) + (if look then 2 else 0) + (if drink then 4 else 0)
	if vessel.Expression ~= expression then
		vessel.Expression = expression
		vessel.EyesOpen.Visible = not blink
		vessel.EyesClosed.Visible = blink
		vessel.Look.Visible = look
		vessel.Drink.Visible = drink
	end
end

function TravelSceneAnimation:_refreshPlayback()
	if self._disposed then
		return
	end
	local playing = self._requested and self:_visible()
	if playing and not self._renderConnection then
		self._renderConnection = RunService.RenderStepped:Connect(function(delta)
			self:_step(delta)
		end)
	elseif not playing and self._renderConnection then
		self._renderConnection:Disconnect()
		self._renderConnection = nil
		self:_reset()
	end
end

function TravelSceneAnimation:SetView(seaId: string, shipLevel: number)
	if self._disposed then
		return
	end
	local sea = self._seas[seaId] or self._seas.shallow
	local vessel = self._boats[if shipLevel >= 2 then 2 else 1]
	if sea == self._currentSea and vessel == self._currentBoat then
		return
	end
	self:_reset()
	for _, background in pairs(self._seas) do
		background.Node.Visible = background == sea
	end
	for _, candidate in pairs(self._boats) do
		candidate.Node.Visible = candidate == vessel
	end
	self._currentSea = sea
	self._currentBoat = vessel
end

function TravelSceneAnimation:SetPlaying(playing: boolean)
	if self._disposed then
		return
	end
	self._requested = playing == true
	self:_refreshPlayback()
end

function TravelSceneAnimation:Dispose()
	if self._disposed then
		return
	end
	self:SetPlaying(false)
	self:_reset()
	self._disposed = true
	disconnectAll(self._visibilityConnections)
	self._ancestryConnection:Disconnect()
	self._destroyingConnection:Disconnect()
end

return TravelSceneAnimation
