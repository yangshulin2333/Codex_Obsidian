local string = string
local tostring = tostring
local tonumber = tonumber

local function encode_func(c)
    return string.format("%%%02X", string.byte(c))
end

local function decode_func(c)
    local n = tonumber(c, 16) 
    if n then
        return string.char(n)
    end
    return c
end


local M = {}

function M.encode(s)
    return (string.gsub(s, "([^%w%.%-%_])", encode_func))
end

function M.decode(s)
    return (string.gsub(s, '%%(%w%w)', decode_func))
end

return M