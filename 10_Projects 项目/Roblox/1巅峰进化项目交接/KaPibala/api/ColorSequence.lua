---@class ColorSequence
---@field KeyPoints table
ColorSequence = {}
---@type fun(param:Color3):ColorSequence
---@param c Color3
---@return ColorSequence
function ColorSequence.new(c)
end
---@type fun(param:Color3,param:Color3):ColorSequence
---@param c0 Color3
---@param c1 Color3
---@return ColorSequence
function ColorSequence.new(c0,c1)
end
---@type fun(param:table):ColorSequence
---@param keypoints table
---@return ColorSequence
function ColorSequence.new(keypoints)
end