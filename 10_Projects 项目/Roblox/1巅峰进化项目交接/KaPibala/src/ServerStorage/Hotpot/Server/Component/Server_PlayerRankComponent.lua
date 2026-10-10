local _G = _G
local script = script
local hotpot = _G.ServerHotpot
local rank_manager = hotpot.load.Server_RankManager()
---@class Server_PlayerRankComponent:BaseComponent
---@field parent Server_Player
local c = hotpot.class.new(script,hotpot.files.Server_PlayerComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)
end
function c:dtor()
    c.super.dtor(self)
end
function c:GetValue(name)
    local key = self.parent:GetUserId()
    return rank_manager:GetRankValue(name,key)
end
function c:SetValue(name,func)
    local key = self.parent:GetUserId()
    rank_manager:SetRankValue(name,key,func)
end
function c:Increment(name,val)
    local key = self.parent:GetUserId()
    rank_manager:IncrementRankValue(name,key,val)
end
return c