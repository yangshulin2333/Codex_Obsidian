local setmetatable = setmetatable
local type = type
local _G = _G
local pairs = pairs
local hotpot = _G.CommonHotpot
local function CreateTable()
    local tab = {}
    local tab_data = {}
    local meta = {}
    function meta:__index(key)
        return tab_data[key] or key
    end
    function meta:__newindex(key,val)
        if type(val) == "table" then
            tab_data[key] = CreateTable()
            for k,v in pairs(val) do
                tab_data[key][k] = v
            end
        end
    end
    return setmetatable(tab,meta)
end
local function Load(org,key,val)
    if type(val) == "table" then
        org[key] = {}
        for k,v in pairs(val) do
            Load(org[key],k,v)
        end
    else
        if type(val) == "boolean" then
            org[key] = key
        else
            org[key] = val
        end
    end
end
---@class HotpotEnum
local c = {}
local hotpotenum_define = hotpot.load.HotpotEnumDefine()
for k,v in pairs(hotpotenum_define) do
    Load(c,k,v)
end
local enum_define = hotpot.load.EnumDefine()
for k,v in pairs(enum_define) do
    Load(c,k,v)
end
return c