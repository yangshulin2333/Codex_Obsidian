---@type ClientHotpot
local Hotpot = _G.ClientHotpot
---@class DataValue
local module = Hotpot.class.new(script)

local MAX_CONFETTI = 200
local REMOVE_OLD_AT_MAX = false	-- Can be slow when max is hit

local MASTER_SCALE = 1
local CONFETTI_WIDTH = 40
local CONFETTI_HEIGHT = 25
local Z_INDEX = 80

local AVG_FLICKER_TIME = .5
local MAX_ROTATION_SPEED = 360
local NUDGE_CHANCE_PER_SECOND = 4
local NUDGE_SPEED = 100

local DRAG = .61
local GRAVITY = Vector2.new(0,150)

local CONFETTI_COLORS = {}
local GENERATED_COLORS = 8
local GENERATED_COLOR_SATURATION = .7--.5
local GENERATED_COLOR_VALUE = .9
local screenGui = _G.Resources.Prefab.Confetti:Clone()
local confettiCount = 0
local confettis = {}
local topbarOffset = (screenGui.IgnoreGuiInset and game.GuiService:GetGuiInset()) or Vector2.new(0,0)
local killzone = screenGui.AbsoluteSize.Y + topbarOffset.Y + 100
local screenWidth = screenGui.AbsoluteSize.X
local random = math.random
local min = math.min
local sin = math.sin
local cos = math.cos
local tau = math.pi*2
local abs = math.abs

local confettiTemplate = Instance.new('Frame')
confettiTemplate.Size = UDim2.new(0,0,0,0)
confettiTemplate.ZIndex = Z_INDEX
confettiTemplate.AnchorPoint = Vector2.new(.5,.5)
confettiTemplate.BorderSizePixel = 0

function module:updateScreenSize()
	killzone = screenGui.AbsoluteSize.Y + 100
	screenWidth = screenGui.AbsoluteSize.X
end
module:updateScreenSize()
screenGui:GetPropertyChangedSignal('AbsoluteSize'):connect(function()
    module:updateScreenSize()
end)


for i=1,GENERATED_COLORS do
	local color = Color3.fromHSV(
		i/GENERATED_COLORS,
		GENERATED_COLOR_SATURATION,
		GENERATED_COLOR_VALUE
	)
	table.insert(CONFETTI_COLORS, color)
end


function module:randomDirection(speed)
	local direction = random()*tau
	return Vector2.new(sin(direction),cos(direction)) * (speed or 1)
end

function module:createConfetti(posScale,pos, vel)
	local maxedOut = confettiCount >= MAX_CONFETTI
	if maxedOut and REMOVE_OLD_AT_MAX and random() then
		-- This is the best method I can figure for removing a random item from a dictionary of known length
		local removeCoutndown = random(1,MAX_CONFETTI)
		for confetti,_ in pairs(confettis) do
			removeCoutndown = removeCoutndown - 1
			if removeCoutndown <= 0 then
				confetti:Destroy()
				confettiCount = confettiCount - 1
				confettis[confetti] = nil
				maxedOut = confettiCount >= MAX_CONFETTI
				break
			end
		end
	end
	if not maxedOut then
		confettiCount = confettiCount + 1
		local color = CONFETTI_COLORS[random(1,#CONFETTI_COLORS)]
		local h,s,v = Color3.toHSV(color)
		local darkColor = Color3.fromHSV(h,s,v*.7)
		local rot = random()*360
		local data = {
			flickerTime = AVG_FLICKER_TIME*(.75+random()*.5),
			rotVel = (random()*2-1) * MAX_ROTATION_SPEED,
			rot = rot,
			color = color,
			darkColor = darkColor,
			pos = (pos or Vector2.new(0,0)) + topbarOffset,
			vel = vel or Vector2.new(0,0),
			scale = (.5+random()*.5) * MASTER_SCALE,
			posScale = posScale or Vector2.new(0.5,0.5)
		}
		local confetti = confettiTemplate:Clone()
		confetti.Rotation = rot
		confetti.BackgroundColor3 = data.color
		confettis[confetti] = data
		confetti.Parent = screenGui
	end
end
function module:explode(posScale, count, speed,player)
	if not screenGui.Parent then
		screenGui = _G.Resources.Prefab.Confetti:Clone()
	end
    screenGui.Parent = player.PlayerGui
	local count = count or 50
	local speed = speed or 300
	local pos = Vector2.new(0,0)
	for i=1, count do
		local vel = module:randomDirection(speed)*(random()^.5)
		module:createConfetti(posScale,pos,vel)
	end
    return screenGui
end


game:GetService('RunService').Heartbeat:Connect(function(delta)
	local t = tick()
	local drag = DRAG^delta
	for confetti, data in pairs(confettis) do
		if confetti.Parent then
			local scale = data.scale
			local flickerPercent = (t/data.flickerTime)%1
			if random() < NUDGE_CHANCE_PER_SECOND*delta then
				data.rotVel = data.rotVel + ((random()*2-1)*180)
				data.vel = data.vel + Vector2.new(NUDGE_SPEED*(random()*2-1), NUDGE_SPEED*(random()*.5))
			end
			data.vel = (data.vel * drag) + GRAVITY*delta*MASTER_SCALE
			data.pos = data.pos + data.vel*delta
			data.rotVel = data.rotVel * drag
			data.rot = data.rot + data.rotVel*delta
			confetti.BackgroundColor3 = flickerPercent > .5 and data.color or data.darkColor
			confetti.Position = UDim2.new(data.posScale.X,data.pos.x,data.posScale.Y,data.pos.y)
			confetti.Size = UDim2.new(0,CONFETTI_WIDTH*scale,0,CONFETTI_HEIGHT*abs(sin(flickerPercent*tau))*scale)
			confetti.Rotation = data.rot
			if confetti.AbsolutePosition.Y > killzone then
				confetti:Destroy()
				confettiCount = confettiCount - 1
				confettis[confetti] = nil
			end
		else
			confettiCount = confettiCount - 1
			confettis[confetti] = nil
		end
	end
end)
return module