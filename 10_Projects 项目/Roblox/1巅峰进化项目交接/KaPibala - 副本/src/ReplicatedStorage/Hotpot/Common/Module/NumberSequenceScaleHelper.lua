--提供方法对NumberSequence进行缩放
-- 对象包括但不限于：粒子的Size，Transparency等
local NumberSequence = NumberSequence
local NumberSequenceKeypoint = NumberSequenceKeypoint
---@class NumberSequenceScaleHelper
local c = {}
---@type fun() @对NumberSequence进行缩放，自己确认缩放比例
---@param sequence NumberSequence @原sequence
---@param scale number @缩放比率
function c:ScaleNumberSequence(sequence,scale)
	local temp = {}
	for __,v in ipairs(sequence.Keypoints) do
		table.insert(temp,NumberSequenceKeypoint.new(v.Time, v.Value*scale,v.Envelope*scale))
	end
	return NumberSequence.new(temp)
end
return c