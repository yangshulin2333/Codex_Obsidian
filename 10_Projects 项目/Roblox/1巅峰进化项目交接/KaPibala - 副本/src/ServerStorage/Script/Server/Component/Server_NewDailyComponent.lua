local hotpot = _G.ServerHotpot

local daily_cfg = hotpot.config.newdaily_reward
local StartTime = 1739750400
local Interval = 86400

local addTime = 0

---@class Server_NewDailyComponent:Server_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Server_PlayerComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)

    if not self.parent.daily_cmp.__done then
        return
    end

    self.data = self.parent.save_data:GetData('new_daily')

    local now = os.time() + addTime
    local sub = now - StartTime
    local day = math.floor(sub / Interval)
    
    if self.data.__real.get >= 30 then
        return
    end

    local mark = self.data.__real.mark

    -- print(mark,day)
    if mark > day then
		self.parent.save_data:Execut(function()
			self.data.mark = day - 1
		end)
	end

    if day > mark then
        if mark == 0 then--第一天
            self.parent.save_data:Execut(function()
                self.data.can_get = true
                self.data.mark = day
            end)
        else--不是第一天
            if day - mark == 1 then--隔天
                self.parent.save_data:Execut(function()
                    self.data.can_get = true
                    self.data.mark = day
                end)
            else
                self.parent.save_data:Execut(function()
                    self.data.can_get = true
                end)
            end
        end
    end
end

function c:GetReward(id)
    if not self.data.__real.can_get then
        return false
    end
    if self.data.__real.get >= 30 then
        return false
    end
    if id ~= self.data.__real.get + 1 then
        return false
    end

    local cfg = daily_cfg[id]
    if not cfg then
        return false
    end

    local now = os.time() + addTime
    local sub = now - StartTime
    local day = math.floor(sub / Interval)

    self.parent.save_data:Execut(function()
        self.data.get = self.data.get + 1
        self.data.can_get = false
        self.data.mark = day
    end)

    self.parent.reward_cmp:AddReward(cfg.reward)

    return true,day
end

function c:Lost()
    self.parent.save_data:Execut(function()
        self.data.get = 0
        self.data.can_get = true
    end)
    return true
end

function c:Recover()
    local now = os.time() + addTime
    local sub = now - StartTime
    local day = math.floor(sub / Interval)

    self.parent.save_data:Execut(function()
        self.data.can_get = true
        self.data.mark = day
    end)

    self:Fire('set_daily_new_day',day)

    return true
end

function c:RecoverFree()
    if self.data.__real.get > 3 then
        return false
    end
    self:Recover()
    return true
end

c:RegistFunction('claim_daily',c.GetReward)
c:RegistFunction('daily_lost',c.Lost)
c:RegistFunction('recover_daily',c.RecoverFree)

return c