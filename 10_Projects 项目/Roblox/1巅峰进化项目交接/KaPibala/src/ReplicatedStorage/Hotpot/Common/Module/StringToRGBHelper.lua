local hotpot = _G.CommonHotpot

---@class StringToRGBHelper
local module = {}
---@return Color3
function module:ConverseStr(str)
    if string.len(str) ~= 6 then
        error("字符格式错误")
        return Color3.fromRGB(255,255,255)
    end
    local temp = {}
    temp[1] = string.sub(str,1,2)
    temp[2] = string.sub(str,3,4)
    temp[3] = string.sub(str,5,6)
    temp[1] = math.clamp((tonumber(temp[1],16)),0,255)
    temp[2] = math.clamp((tonumber(temp[2],16)),0,255)
    temp[3] = math.clamp((tonumber(temp[3],16)),0,255)
    return Color3.fromRGB(temp[1],temp[2],temp[3])
end

return module