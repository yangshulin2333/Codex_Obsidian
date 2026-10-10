---@type RunService
local RunService = game:GetService('RunService')

local horizontal = 'horizontal'
local ignore = 'ignore'
local gradient_rotate = 0
local gradient_list = {}
local rotate_speed = 0.5

local counter = 0       -- phase shift 
local w = math.pi / 12  -- frequency 
local CS = {}           -- colorsequence table
local num = 15 			-- number of colorsequence points (maxed at 15 or 16 I believe)
local frames = 0		-- frame counter, used to buffer if you want lower framerate updates

---@class UIGradientHelper
local c = {}

function c:Add(gradient)
	if gradient:GetAttribute(ignore) then
		return
	end
	gradient_list[gradient] = true
end

function c:Remove(gradient)
	if gradient_list[gradient] then
		gradient_list[gradient] = nil
	end
end

local function Update()
	gradient_rotate = gradient_rotate + rotate_speed
	if gradient_rotate >= 360 then
		gradient_rotate = gradient_rotate - 360
	end

	if math.fmod(frames, 2) == 0 then
		for i = 0, num do
			local c = Color3.fromRGB(127 * math.sin(w*i + counter) + 128, 127 * math.sin(w*i + 2 * math.pi/3 + counter) + 128, 127*math.sin(w*i + 4*math.pi/3 + counter) + 128)
			table.insert(CS, i+1, ColorSequenceKeypoint.new(i/num, c))
		end
	end
	for gradient,_ in pairs(gradient_list)do
		if gradient:GetAttribute(horizontal) then
			if math.fmod(frames, 2) == 0 then
				gradient.Color = ColorSequence.new(CS)
			end
		else
			gradient.Rotation = gradient_rotate
		end
	end

	if math.fmod(frames, 2) == 0 then
		CS = {}
		counter = counter + math.pi/40
		if (counter >= math.pi * 2) then
			counter = 0
		end
	end 

	if frames >= 1000 then
		frames = 0
	end
	frames = frames + 1
end

RunService.Heartbeat:Connect(function()
	Update()
end)

return c