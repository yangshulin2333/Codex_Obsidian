local hotpot = _G.CommonHotpot

---@class ParticleHelper
local c = {}

function c:ReSizeParticle(part,scale)
    scale = scale or 1

    for k,v in ipairs(part:GetDescendants())do
        if v:IsA('ParticleEmitter') then
            local temp = {}
			
			
			for k2,v2 in pairs(v.Size.Keypoints) do
				local Time = v:FindFirstChild("Time"..k2)
				if not Time then
					Time = Instance.new('NumberValue',v)
					Time.Name = "Time"..k2
					Time.Value = v2.Time
				end
				
				local Value = v:FindFirstChild("Value"..k2)
				if not Value then
					Value = Instance.new('NumberValue',v)
					Value.Name = "Value"..k2
					Value.Value = v2.Value
				end
				
				local Envelope = v:FindFirstChild("Envelope"..k2)
				if not Envelope then
					Envelope = Instance.new('NumberValue',v)
					Envelope.Name = "Envelope"..k2
					Envelope.Value = v2.Envelope
				end
				
				local keyP = NumberSequenceKeypoint.new(Time.Value, Value.Value * scale, Envelope.Value * scale)
				table.insert(temp, keyP)
				
			end
			
			if next(temp) then
				v.Size = NumberSequence.new(temp)
			end
        end
    end
end

function c:ReSizeParticleAll(v, _scale)

	if not _scale then
		_scale = 1
	end

	if not v then
		return
	end

	--Size	
	local temp = {}

	for k2,v2 in pairs(v.Size.Keypoints) do


		local Time = v:FindFirstChild("Time"..k2)
		if not Time then
			Time = Instance.new('NumberValue',v)
			Time.Name = "Time"..k2
			Time.Value = v2.Time
		end

		local Value = v:FindFirstChild("Value"..k2)
		if not Value then
			Value = Instance.new('NumberValue',v)
			Value.Name = "Value"..k2
			Value.Value = v2.Value
		end

		local Envelope = v:FindFirstChild("Envelope"..k2)
		if not Envelope then
			Envelope = Instance.new('NumberValue',v)
			Envelope.Name = "Envelope"..k2
			Envelope.Value = v2.Envelope
		end

		local keyP = NumberSequenceKeypoint.new(Time.Value, Value.Value * _scale, Envelope.Value * _scale)
		table.insert(temp, keyP)

	end

	if next(temp) then
		v.Size = NumberSequence.new(temp)
	end
	--Drag
	local OriDrag = v:FindFirstChild("OriDrag")
	if not OriDrag then
		OriDrag =  Instance.new('NumberValue',v)
		OriDrag.Name = "OriDrag"
		OriDrag.Value = v.Drag
	end
	
	if OriDrag then
		v.Drag = OriDrag.Value * _scale
	end
	


	--VelocityInheritance
	local OriVelocityInheritance = v:FindFirstChild("OriVelocityInheritance")
	if not OriVelocityInheritance then
		OriVelocityInheritance = Instance.new('NumberValue',v)
		OriVelocityInheritance.Name = "OriVelocityInheritance"
		OriVelocityInheritance.Value = v.VelocityInheritance
	end
	
	if OriVelocityInheritance then
		v.VelocityInheritance = OriVelocityInheritance.Value * _scale
	end
	
	--Speed
	local OriSpeed = v:FindFirstChild("OriSpeed")
	if not OriSpeed then
		OriSpeed = Instance.new('Vector3Value',v)
		OriSpeed.Name = "OriSpeed"
		OriSpeed.Value = Vector3.new(v.Speed.Max, v.Speed.Min)
	end
	
	if OriSpeed then
		v.Speed = NumberRange.new(OriSpeed.Value.Y * _scale, OriSpeed.Value.X * _scale)
	end
	

	--Acceleration
	local OriAcceleration = v:FindFirstChild("OriAcceleration")
	if not OriAcceleration then
		OriAcceleration = Instance.new('Vector3Value',v)
		OriAcceleration.Name = "OriAcceleration"
		OriAcceleration.Value = v.Acceleration
	end
	
	if OriAcceleration then
		v.Acceleration = OriAcceleration.Value * _scale
	end

end

return c