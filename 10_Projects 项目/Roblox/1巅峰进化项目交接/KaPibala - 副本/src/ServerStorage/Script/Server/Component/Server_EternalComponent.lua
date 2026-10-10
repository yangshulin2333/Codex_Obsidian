local hotpot = _G.ServerHotpot

local SEASON = 5
local BASETIME = 1756080000
local OVERTIME = 1762300800
local H_INTERVAL = 3600
local D_INTERVAL = 86400
local eternalRewardCfg = hotpot.config.EternalReward
local eternalTaskCfg = hotpot.config.EternalTask
local eternalSpinCfg = hotpot.config.EternalSpin
local eternalShopCfg = hotpot.config.EternalShop
local gachaCfg = hotpot.config.gacha
local pet_cfg = hotpot.config.pet
local spinTotal = 0
for k,v in ipairs(eternalSpinCfg)do
    spinTotal = spinTotal + v.weight
end

---@class Server_EternalComponent:Server_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Server_PlayerComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)

    self.data = self.parent.save_data:GetData('eternal')
    self.pay = self.parent.save_data:GetData('pay')

    self:Init()
    self:StartUpdate()

    -- self:AddCoins(100000000000000000)
    -- self:AddTicket(10)
end

function c:Init()
    self:CheckSeason()
    self:RefreshHour()
    self:RefreshDay()
end

function c:CheckSeason()
    if self.data.__real.season < SEASON then
        --重置数据
        self.parent.save_data:Execut(function()
            self.data.season = SEASON
            self.data.daily_mark = 0
            self.data.hour_mark = 0
            self.data.lv = 0
            self.data.exp = 0
            self.data.is_primium = false
            self.data.get.free = {}
            self.data.get.primium = {}
            self.data.task = {
                {done = false,num = 0},{done = false,num = 0},{done = false,num = 0},
                {done = false,num = 0},{done = false,num = 0},{done = false,num = 0},
                {done = false,num = 0},{done = false,num = 0},{done = false,num = 0},
            }
            self.data.ticket = 0
            self.data.coin = 0
            self.data.shop.list = {}
        end)
    end
end

function c:StartUpdate()
    if self.__co then
        return
    end
    self.__co = self:AddUpdate(self.Update,1)
end

function c:StopUpdate()
    if self.__co then
        self.__co:Disconnect()
        self.__co = nil
    end
end

function c:Update()
    self:AddTaskPoint(1,1)
    -- if not self:AddTaskPoint(1,1) then
    --     self:StopUpdate()
    -- end
end

function c:RefreshDay()
    local now = os.time()
    local sub = now - BASETIME

    local d_num = math.floor(sub / D_INTERVAL)
    if d_num > self.data.__real.daily_mark then   
        self.parent.save_data:Execut(function()
            self.data.daily_mark = d_num
    
            for i = 1,6 do
                self.data.task[i].done = false
                self.data.task[i].num = 0
            end
        end)
        return true,d_num
    end 
end

function c:RefreshHour()
    local now = os.time()
    local sub = now - BASETIME

    local h_num = math.floor(sub / H_INTERVAL)
    if h_num > self.data.__real.hour_mark then    
        self.parent.save_data:Execut(function()
            self.data.hour_mark = h_num
    
            for i = 7,9 do
                self.data.task[i].done = false
                self.data.task[i].num = 0
            end
        end)

        return true,h_num
    end 
end

function c:RefreshTask()
    for k,v in pairs(self.data.__real.task)do
        self.parent.save_data:Execut(function()
            self.data.task[k].done = false
            self.data.task[k].num = 0
        end)
    end

    self:StartUpdate()
end

function c:AddTaskPoint(id,num)
    local need = eternalTaskCfg[id].num
    local now = self.data.__real.task[id].num
    if now >= need then
        return
    end
    if now + num >= need then
        self:AddExp(eternalTaskCfg[id].exp)
    end

    self.parent.save_data:Execut(function()
        self.data.task[id].num = math.min(need,self.data.task[id].num + num)
        if self.data.task[id].num >= need then
            self.data.task[id].done = true
        end
    end)
    self:Fire('eternalAddPoint',id,num)

    return true
end

function c:AddExp(exp)
    local now_lv = self.data.__real.lv
    local now_exp = self.data.__real.exp
    local maxLV = #eternalRewardCfg

    if now_lv >= maxLV then
        return 
    end
    now_exp = now_exp + exp

    if now_exp >= eternalRewardCfg[now_lv + 1].exp then
        now_exp = now_exp - eternalRewardCfg[now_lv + 1].exp
        now_lv = math.min(maxLV,now_lv + 1)
    end

    self.parent.save_data:Execut(function()
        self.data.lv = now_lv
        self.data.exp = now_exp
    end)

    self:Fire('eternalAddExp',now_exp,now_lv,exp)

    return true
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

    self.parent.reward_cmp:AddReward({eternalRewardCfg[lv].reward1})

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

    self.parent.reward_cmp:AddReward({eternalRewardCfg[lv].reward2})

    return true
end

function c:AddTicket(num)
    self.parent.save_data:Execut(function()
        self.data.ticket = self.data.ticket + num
    end)
    self:Fire('eternalAddTicket',num)
    return true
end

function c:AddCoins(num)
    self.parent.save_data:Execut(function()
        self.data.coin = self.data.coin + num
    end)
    self:Fire('eternalAddCoins',num)
    return true
end

function c:CostCoins(num)
    local now = self.data.__real.coin
    if now < num then
        return
    end
    self.parent.save_data:Execut(function()
        self.data.coin = self.data.coin - num
    end)
    self:Fire('eternalCostCoins',num)
    return true
end

function c:Spin1()
    --判断数量
    if self.data.__real.ticket < 1 then
        return
    end
    local num = math.random(1,spinTotal)
    local id = 0
    for k,v in ipairs(eternalSpinCfg)do
        num = num - v.weight
        if num <= 0 then
            id = v.id
            break
        end
    end
    if id == 0 then
        id = 1
    end

    self.parent.save_data:Execut(function()
        self.data.ticket = self.data.ticket - 1
    end)

    self.parent.reward_cmp:AddReward({eternalSpinCfg[id].reward},true)

    return true,id
end

function c:SpinAll()
    local ticket = self.data.__real.ticket
    --判断数量
    if ticket < 1 then
        return
    end
    local list = {}
    local reward = {}
    for i = 1,ticket do
        local num = math.random(1,spinTotal)
        local id = 0
        for k,v in ipairs(eternalSpinCfg)do
            num = num - v.weight
            if num <= 0 then
                id = v.id
                break
            end
        end
        if id == 0 then
            id = 1
        end

        table.insert(list,id)
        -- reward[id] = reward[id] or 0
        -- reward[id] = reward[id] + 1
    end

    local re = {}
    for k,v in ipairs(list)do
        local r = eternalSpinCfg[v].reward
        local r_id = r[1]
        local r_type = r[2]
        local r_num = r[3]
        table.insert(re,{r_id,r_type,r_num})
    end

    self.parent.reward_cmp:AddReward(re,true)

    self.parent.save_data:Execut(function()
        self.data.ticket = 0
    end)

    return true,list,re
end

function c:GachaEgg(count)
    if count ~= 1 and count ~= 3 and count ~= 10 then
        return
    end
    local cfg = gachaCfg[40]
    local price = cfg.price
    local cost = price * count
    if self.data.__real.coin < cost then
        return
    end

    local re = {}
    for i = 1,count do
        local pet_id = self.parent.gacha_cmp:Gacha(40)
        table.insert(re,{pet_id = pet_id})
        self.parent.pet_cmp:AddPet(pet_id)
    end
    self:CostCoins(cost)

    self.parent.stats_cmp:AddEggs(count)

    return true,re
end

function c:BuyEternalItem(id)
    local cfg = eternalShopCfg[id]
    if not cfg then
        return
    end
    local price = cfg.price
    if self.data.__real.coin < price then
        return
    end

    if self.data.__real.shop.list[id] then
        return
    end

    self:CostCoins(price)
    self.parent.save_data:Execut(function()
        self.data.shop.list[id] = true
    end)

    self.parent.reward_cmp:AddReward({cfg.reward})

    return true
end

function c:GetDouble()
    return self.pay.__real.pay_list[134]
end

function c:SetEternalGiftPlayer(player)
    self.gift_player = player
end

c:RegistFunction('refreshEternalDailyTask',c.RefreshDay)
c:RegistFunction('refreshEternalHourTask',c.RefreshHour)
c:RegistFunction('getFreeEternal',c.GetFreeReward)
c:RegistFunction('getPrimiumEternal',c.GetPrimiumReward)
c:RegistFunction('useTicket',c.Spin1)
c:RegistFunction('useAllTicket',c.SpinAll)
c:RegistFunction('buyEternalEgg',c.GachaEgg)
c:RegistFunction('buyEternalItem',c.BuyEternalItem)
c:RegistEvent('eternalGiftPlayer',c.SetEternalGiftPlayer)

return c