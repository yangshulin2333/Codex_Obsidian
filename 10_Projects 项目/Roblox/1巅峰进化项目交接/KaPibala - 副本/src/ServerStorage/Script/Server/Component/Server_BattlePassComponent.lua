local hotpot = _G.ServerHotpot

local SEASON = 3
local BASETIME = 1752969600
local INTERVAL = 86400
local BPReward = hotpot.config.BPReward
local BPTask = hotpot.config.BPTask

---@class Server_BattlePassComponent:Server_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Server_PlayerComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)

    self.data = self.parent.save_data:GetData('battle_pass')

    self:CheckSeason()
    self:Init()
    self:AddUpdate(self.Update,1)
end

function c:Init()
    local now = os.time()
    local sub = now - BASETIME
    local num = math.floor(sub / INTERVAL)
    if num > self.data.__real.mark then
        self:RefreshDay(num)       
    end 
end

function c:CheckSeason()
    if self.data.__real.season ~= SEASON then
        --重置数据
        self.parent.save_data:Execut(function()
            self.data.season = SEASON
            self.data.lv = 0
            self.data.exp = 0
            self.data.is_primium = false
            self.data.get.free = {}
            self.data.get.primium = {}
            self.data.mark = 0
            self.data.task = {
                {done = false,num = 0},{done = false,num = 0},{done = false,num = 0},
                {done = false,num = 0},{done = false,num = 0},{done = false,num = 0},
            }
        end)
    end
end

function c:RefreshDay(num)
    self.parent.save_data:Execut(function()
        self.data.mark = num
        for i = 1,6 do
            self.data.task[i].done = false
            self.data.task[i].num = 0
        end
    end)
end

function c:AddPoint(id,num)
    local need = BPTask[id].num
    local now = self.data.__real.task[id].num
    if now >= need then
        return
    end
    if now + num >= need then
        self:AddExp(BPTask[id].exp)
    end

    self.parent.save_data:Execut(function()
        self.data.task[id].num = math.min(need,self.data.task[id].num + num)
        if self.data.task[id].num >= need then
            self.data.task[id].done = true
        end
    end)

    self:Fire('bpAddPoint',id,num)

    return true
end

function c:AddExp(exp)
    local now_lv = self.data.__real.lv
    local now_exp = self.data.__real.exp
    local maxLV = #BPReward

    if now_lv >= maxLV then
        return 
    end
    now_exp = now_exp + exp

    if now_exp >= BPReward[now_lv + 1].exp then
        now_exp = now_exp - BPReward[now_lv + 1].exp
        now_lv = math.min(maxLV,now_lv + 1)
    end

    self.parent.save_data:Execut(function()
        self.data.lv = now_lv
        self.data.exp = now_exp
    end)

    self:Fire('bpAddExp',now_exp,now_lv)

    return true
end

function c:Update()
    self:AddPoint(1,1)
    -- if not self:AddPoint(1,1) then
    --     return true
    -- end
end

function c:BuyPrimium()
    self.parent.save_data:Execut(function()
        self.data.is_primium = true
    end)
    return true
end

function c:GetFreeReward(lv)
    if lv > self.data.__real.lv then
        return
    end
    if self.data.__real.get.free[lv] then
        return
    end

    self.parent.save_data:Execut(function()
        self.data.get.free[lv] = true
    end)

    self.parent.reward_cmp:AddReward({BPReward[lv].reward1})

    return true
end

function c:GetPrimiumReward(lv)
    if not self.data.__real.is_primium then
        return
    end

    if lv > self.data.__real.lv then
        return
    end
    if self.data.__real.get.primium[lv] then
        return
    end

    self.parent.save_data:Execut(function()
        self.data.get.primium[lv] = true
    end)

    self.parent.reward_cmp:AddReward({BPReward[lv].reward2})

    return true
end

function c:SetBattlePassGiftPlayer(player)
    self.gift_player = player
end

c:RegistFunction('getFreeBP',c.GetFreeReward)
c:RegistFunction('getPrimiumBP',c.GetPrimiumReward)
c:RegistEvent('battlepassGiftPlayer',c.SetBattlePassGiftPlayer)

return c