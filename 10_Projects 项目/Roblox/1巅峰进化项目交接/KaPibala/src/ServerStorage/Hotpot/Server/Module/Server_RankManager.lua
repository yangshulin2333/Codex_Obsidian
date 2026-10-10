local _G = _G
local script = script
local hotpot = _G.ServerHotpot
local data_base_manager = hotpot.load.DataBaseManager()
local rank_list = hotpot.load.RankList()
for name,__ in pairs(rank_list) do
    rank_list[name] = name
    data_base_manager:CreateSortDataBase(name)
end
---@class Server_RankManager
local c = hotpot.class.new(script)
function c:GetRankList(name,ascending,num,min_value,max_value)
    return data_base_manager:GetSortedList(name,ascending,num,min_value,max_value)
end
function c:SetRankValue(name,key,func)
    data_base_manager:Save(name,key,func)
end
function c:GetRankValue(name,key)
    return data_base_manager:Load(name,key)
end
function c:IncrementRankValue(name,key,val)
    data_base_manager:Increment(name,key,val)
end
return c