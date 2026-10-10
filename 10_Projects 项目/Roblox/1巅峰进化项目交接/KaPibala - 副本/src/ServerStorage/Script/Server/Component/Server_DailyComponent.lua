local hotpot = _G.ServerHotpot

local daily_cfg = hotpot.config.daily_reward
local StartTime = 1739750400
local Interval = 86400

---@class Server_DailyComponent:Server_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Server_PlayerComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)

    self.data = self.parent.save_data:GetData('daily')

    -- self.parent.save_data:Execut(function()
    --     self.data.get = 7    
    -- end)

    local now = os.time()
    local sub = now - StartTime
    local day = math.floor(sub / Interval)
    if self.data.__real.get == 7 then
        self.__done = true
        return
    end
    if day > self.data.__real.mark then
        self.parent.save_data:Execut(function()
            self.data.can_get = true
            self.data.mark = day
        end)
    end
end

function c:GetReward(id)
    if not daily_cfg[id] then
        return
    end
    if not self.data.__real.can_get then
        return
    end
    if self.data.__real.get >= id then
        return false
    end

    self.parent.save_data:Execut(function()
        self.data.can_get = false
        self.data.get = self.data.get + 1
    end)

    self.parent.reward_cmp:AddReward(daily_cfg[id].reward)

    return true

end

function c:Refresh()
    local now = os.time()
    local sub = now - StartTime
    local day = math.floor(sub / Interval)
    if self.data.__real.get == 7 then
        return
    end
    if day > self.data.__real.mark then
        self.parent.save_data:Execut(function()
            self.data.can_get = true
            self.data.mark = day
        end)
        return self.data.__real
    end
end

c:RegistFunction('get_daily_reward',c.GetReward)
c:RegistFunction('refreshDaily',c.Refresh)

return c