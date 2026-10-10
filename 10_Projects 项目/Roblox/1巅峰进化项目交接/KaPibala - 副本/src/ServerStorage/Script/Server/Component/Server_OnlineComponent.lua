local hotpot = _G.ServerHotpot

local online_cfg = hotpot.config.online_reward
local online_time = 'online_time'

---@class Server_OnlineComponent:Server_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Server_PlayerComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)

    self.get_list = {}
    self.time = 0

    self:AddUpdate(self.Update,1)
end

function c:Update()
    self.time = self.time + 1
    self:Fire(online_time,self.time)
end

function c:GetReward(id)
    local cfg = online_cfg[id]
    if not cfg then
        return false
    end
    if self.get_list[id] then
        return
    end
    if self.time < cfg.times then
        return
    end

    self.get_list[id] = true

    self.parent.reward_cmp:AddReward({cfg.reward})

    return true
end

function c:SkipAll()
    self.time = 3600*5
end

c:RegistFunction('get_online_reward',c.GetReward)

return c