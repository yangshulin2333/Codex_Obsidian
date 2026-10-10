local hotpot = _G.ServerHotpot
local HttpService = game:GetService("HttpService")
---@type BadgeHelper
local badgeHelper = hotpot.load.BadgeHelper()
---@type GameServer
local server = _G.server
---@type PlaceManager
local placeManager = hotpot.load.PlaceManager()
---@type Server_RankManager
local rank_manager = hotpot.load.Server_RankManager()

local badgeCfg = hotpot.config.badge
local funnelSessionId = HttpService:GenerateGUID()
local player_lv_cfg = hotpot.config.playerLv
local reborn_cfg = hotpot.config.reborn
local free_gems_cd = hotpot.pro_cfg.free_gems_cd
local UpgradeEff = hotpot:GetPath_Loop('pfb.UpgradeEff',hotpot.Resource)
local isWeekend = hotpot:GetPath_Loop('CheckWeekend.IsWeekend',workspace)
local hpList = {
    --50K,160K,500K,1.5M,2M,2.5M,3M,3.5M,4M,4.5M
    50000,160000,500000,1500000,2000000,2500000,3000000,3500000,4000000,4500000,5000000,5500000
}

---@class Server_PropComponent:Server_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Server_PlayerComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)

    self.data = self.parent.save_data:GetData('prop')
    self.pay_data = self.parent.save_data:GetData('pay')

    local max = #player_lv_cfg
    local exp = player_lv_cfg[max].exp
    self.parent.save_data:Execut(function()
        if self.data.lv > max then
            self.data.lv = max
        end
        if self.data.exp > exp then
            self.data.exp = exp * 0.99
        end
    end)

    self.parent.learder_lv.Value = self.data.__real.lv
    self.parent.learder_rebirths.Value = self.data.__real.reborn

    local rebornValue = Instance.new('NumberValue',self.parent.main_inst)
    rebornValue.Name = 'reborn'
    rebornValue.Value = self.data.__real.reborn
    self.rebornValue = rebornValue

    self.parent.LVvalue.Value = self:GetLv()

    self:AddProcess(function()
        if not self.data.__real.login_time then
            self.parent.save_data:Execut(function()
                self.data.login_time = os.time()
            end)
        else
            self.parent.save_data:Execut(function()
                self.data.login_time = os.time()
            end)
        end
    end)
end

function c:GetGems()
    return self.data.__real.gems
end

function c:AddGems(gems)
    self.parent.save_data:Execut(function()
        self.data.gems = self.data.gems + gems
    end)

    self:Fire('add_gems',gems)

    return true
end

function c:CostGems(gems)
    if self:GetGems() < gems then
        return false
    end
    self.parent.save_data:Execut(function()
        self.data.gems = self.data.gems - gems
    end)

    self:Fire('cost_gems',gems)

    return true
end

function c:GetWins()
    return self.data.__real.wins
end

function c:AddWins(wins,not_sync)
    wins = wins * self:GetGoldPer()
    wins = math.floor(wins)
    self.parent.save_data:Execut(function()
        self.data.wins = self.data.wins + wins
    end)

    if not not_sync then
        self:Fire('add_wins',wins)
    end

    if self.parent.guide_cmp then
        if self.parent.guide_cmp:GetNum() == 0 and self:GetWins() >= 10 then
            self.parent.guide_cmp:ChangeNum(1)
        end
    end

    return true
end

function c:CostWins(wins)
    if self:GetWins() < wins then
        return false
    end
    self.parent.save_data:Execut(function()
        self.data.wins = self.data.wins - wins
    end)

    self:Fire('cost_wins',wins)

    return true
end

function c:AddExpByTeam(exp)
    -- self:AddExp(exp)
    if not self.parent.team_id then
        self:AddExp(exp)
    else
        server.team_manager:AddExpByTeam(self.parent,exp)
    end
end

function c:AddPvpCoin(coin)
    coin = math.floor(coin)
    self.parent.save_data:Execut(function()
        self.data.pvp_coin = self.data.pvp_coin + coin
    end)

    self:Fire('add_pvp_coin',coin)

    pcall(function()
        rank_manager:IncrementRankValue('pvp_score',self.parent.user_id,coin)
    end)

    return true
end

function c:CostPvpCoin(coin)
    if self.data.__real.pvp_coin < coin then
        return false
    end
    self.parent.save_data:Execut(function()
        self.data.pvp_coin = self.data.pvp_coin - coin
    end)

    self:Fire('cost_pvp_coin',coin)

    return true
end

function c:AddExp(exp)
    exp = exp * self:GetExpPer()
    exp = math.floor(exp)
    local now_exp = self.data.__real.exp
    local lv = self:GetLv()
    local max_lv = #player_lv_cfg
    local need_exp = player_lv_cfg[lv].exp

    if lv >= max_lv then
        now_exp = now_exp + exp
        if now_exp >= need_exp then
            now_exp = now_exp - exp
        end
    else
        now_exp = now_exp + exp
    end 

    local add_lv = 0
    while now_exp >= need_exp do
        now_exp = now_exp - need_exp
        add_lv = add_lv + 1
        if not player_lv_cfg[lv + add_lv] then
            break
        end
        need_exp = player_lv_cfg[lv + add_lv].exp
    end
    self.parent.save_data:Execut(function()
        self.data.exp = now_exp
    end)

    if add_lv + lv > max_lv then
        add_lv = 0
    end

    self:Fire('set_exp',self.data.__real.exp)
    
    self:AddLv(add_lv)

    return true
end

function c:AddLv(lv)
    if lv == 0 then
        return
    end
    local old = self.data.__real.lv
    self.parent.save_data:Execut(function()
        self.data.lv = self.data.lv + lv
    end)
    local new = self.data.__real.lv

    self.parent.LVvalue.Value = self:GetLv()

    if not player_lv_cfg[old] then
        return
    end
    if not player_lv_cfg[new] then
        return
    end

    local p1 = player_lv_cfg[old].reward
    local p2 = player_lv_cfg[new].reward
    if p2 then
        self.parent.character_cmp:UnLockCharacter(p1,p2)
    end

    self:Fire('add_lv',self.data.__real.lv,self.data.__real.exp)

    if new > old then
        --播放升级特效
        self:AddProcess(function()
            local character = self.parent.character
            if not character then
                return
            end
            local ParticleEmitter = 'ParticleEmitter'
            local pos = self.parent.character:GetPosition()
            local eff = hotpot:CloneInst_Loop(UpgradeEff)
            eff.Parent = workspace
            eff.Position = pos
            for k,v in ipairs(eff:GetDescendants())do
                if v:IsA(ParticleEmitter) then
                    local delay = v:GetAttribute('EmitDelay')
                    local count = v:GetAttribute('EmitCount')
                    delay = delay or 0
                    self:AddProcess(function()
                        self:Wait(delay)
                        v:Emit(count)
                    end)
                end
            end
        end)
        --漏斗打点
        local r,e = pcall(function()
            local data = self.parent.save_data:GetData('analytics')
            if not data then
                return
            end
            local upgrade = data.__real.upgrade
            if not upgrade then
                return
            end

            for i = upgrade + 1,new do
                local AnalyticsService = game:GetService("AnalyticsService")
                AnalyticsService:LogFunnelStepEvent(
                    self.parent.main_inst,
                    'levelUp',
                    funnelSessionId,
                    i, -- 步数
                    "levelUp"..i -- 步的名称
                )
            end

            self.parent.save_data:Execut(function()
                data.upgrade = new
            end)
        end)
        if not r then
            warn(e)
        end
        
    end
    --徽章打点
    pcall(function()
        self.parent.character:SetLv()

        spawn(function()
            if self.data.__real.newPlayer then
                for i = old,new do
                    if badgeCfg[i] then
                        local badgeId = badgeCfg[i].badgeId
                        if badgeId then
                            badgeHelper:AwardBadge(self.parent.main_inst,badgeId)
                        end
                    end
                end
            end
        end)
    end)

    self.parent.learder_lv.Value = self.data.__real.lv

    return true
end

function c:GetLv()
    local lv = self.data.__real.lv
    return math.min(lv,#player_lv_cfg)
end

function c:GetExp()
    return self.data.__real.exp
end

function c:Reborn()
    local now = self.data.__real.reborn
    local cfg = reborn_cfg[now + 1]
    if not cfg then
        return false
    end
    local need = cfg.need_lv
    if need > self:GetLv() then
        return false
    end
    self.parent.save_data:Execut(function()
        self.data.reborn = self.data.reborn + 1
    end)

    self.parent.learder_rebirths.Value = self.data.__real.reborn
    self.rebornValue.Value = self.data.__real.reborn

    if cfg.unlock == 'task' then
        self.parent.task_cmp:Unlock()
    end

    local save_lv = cfg.save_lv
    local now_lv = self:GetLv()
    self.parent.save_data:Execut(function()
        self.data.exp = 0
        self.data.lv = save_lv
    end)
    self.parent.guide_cmp:Reborn()
    
    self.parent.LVvalue.Value = self:GetLv()

    local stage_cfg = hotpot.config.stage
    for i = 2,#stage_cfg do
        self.parent.stage_cmp:LockStage(i)
    end

    local p1 = player_lv_cfg[2].reward
    local p2 = player_lv_cfg[now_lv].reward
    self.parent.character_cmp:LockCharacter(p1,p2)

    p1 = player_lv_cfg[2].reward
    p2 = player_lv_cfg[save_lv].reward
    self.parent.character_cmp:UnLockCharacter(p1,p2)

    pcall(function()
        self.parent.learder_lv.Value = self.data.__real.lv
        self.parent.character:SetLv()
    end)

    self.parent.stats_cmp:SyncAttack()

    return true,save_lv
end

function c:GetAttack()
    if self.parent.pk_state then
        return self:GetPKAtk()
    end
    if placeManager:GetIdByName('pvpsence') == game.PlaceId then
        return self:GetPKAtk()
    end

    local base = self.parent.character_cmp:GetAttack()--角色

    local relics = self.parent.relics_cmp:GetProp()
    local dmg = relics.DMG or 0

    local reborn = self.data.__real.reborn
    if reborn_cfg[reborn] then
        reborn = reborn_cfg[reborn].atk * 0.01
    else
        reborn = 0
    end

    local pet = self.parent.pet_cmp:GetAttack()--宠物
    local vip = self.pay_data.__real.pay_list[28]
    local upgrade = self.parent.upgrade_cmp:GetValue('atk')
    local double = self.pay_data.__real.pay_list[64]
    local friend = self.parent.friend_num or 0
    -- print(self.parent.title_cmp)
    local title = self.parent.title_cmp.prop
    local titleDmg = title.DMG or 0

    return base * (1+pet) * (vip and 1.5 or 1) * (dmg * 0.01 + 1) 
        * (1 + reborn) * (1 + upgrade) * (double and 2 or 1) * (1 + friend * 0.1) * (1 + titleDmg * 0.01)
end

function c:GetPKAtk()
    local atk = hotpot.config.character[1].value--基础

    local relics = self.parent.relics_cmp:GetProp()--遗物
    local dmg = relics.DMG or 0

    local pet = self.parent.pet_cmp:GetAttack()--宠物

    local title = self.parent.title_cmp.prop--称号
    local titleDmg = title.DMG or 0

    local pvp = self.parent.pvp_buff_cmp:GetAtkPer()

    return atk * (dmg * 0.01 + 1) * (1 + pet) * (1 + titleDmg * 0.01) * pvp
end

function c:GetHp()
    if self.parent.pk_state then
        return self:GetPKHp()
    end
    if placeManager:GetIdByName('pvpsence') == game.PlaceId then
        return self:GetPKHp()
    end

    local base = 0--初始值

    local character = self.parent.character_cmp:GetHP()--角色

    local vip = self.pay_data.__real.pay_list[28]
    local upgrade = self.parent.upgrade_cmp:GetValue('hp')

    local relics = self.parent.relics_cmp:GetProp()
    local maxHp = relics.MaxHp or 0

    local title = self.parent.title_cmp.prop
    local titleHp = title.MaxHp or 0

    return math.floor((base + character) * (1 + maxHp*0.01) * (vip and 1.5 or 1)) * (1 + upgrade) * (1 + titleHp * 0.01)
end

function c:GetPKHp()
    -- local hp = 5000000
    local lv = self:GetLv()
    local stage = math.ceil(lv / 7)
    local hp = hpList[stage] or hpList[10]

    local relics = self.parent.relics_cmp:GetProp()--遗物
    local maxHp = relics.MaxHp or 0

    local title = self.parent.title_cmp.prop
    local titleHp = title.MaxHp or 0

    local pvp = self.parent.pvp_buff_cmp:GetHPPer()

    return hp * (1 + maxHp*0.01) * (1 + titleHp * 0.01) * pvp
end

function c:GetPKSpeed()
    local base = 16--初始值
    local mount = self.parent.mount_cmp:GetSpeed()

    local pvp = self.parent.pvp_buff_cmp:GetMoveSpeedPer()
    
    return base * (1 + mount) * pvp
end

function c:GetExpPer()
    local base = 1

    local gamepass = self.pay_data.__real.pay_list[25]
    gamepass = gamepass and 2 or 1

    local reborn = self.data.__real.reborn
    if reborn_cfg[reborn] then
        reborn = reborn_cfg[reborn].exp * 0.01
    else
        reborn = 0
    end

    local relics = self.parent.relics_cmp:GetProp()
    local exp = relics.EXP or 0

    local primium = self.parent:IsPremium()
    primium = primium and 1.1 or 1

    local upgrade = self.parent.upgrade_cmp:GetValue('exp')

    local boost = self.parent.bag_cmp:GetBuff(1)
    boost = boost or 1

    local weekend = isWeekend.Value and 2 or 1

    local title = self.parent.title_cmp.prop
    local titleExp = title.EXP or 0

    -- print(base,(1 + exp * 0.01),gamepass,(1 + reborn),boost,(1 + upgrade),primium,weekend,(1 + titleExp * 0.01))
    -- print(base * (1 + exp * 0.01) * gamepass * (1 + reborn) * boost * (1 + upgrade) * primium * weekend * (1 + titleExp * 0.01))
    return base * (1 + exp * 0.01) * gamepass * (1 + reborn) * boost * (1 + upgrade) * primium * weekend * (1 + titleExp * 0.01)
end

function c:GetGoldPer()
    local base = 1

    local gamepass = self.pay_data.__real.pay_list[24]
    gamepass = gamepass and 2 or 1

    local boost = self.parent.bag_cmp:GetBuff(2)
    boost = boost or 1

    local primium = self.parent:IsPremium()
    primium = primium and 1.1 or 1

    return base * gamepass * boost * primium
end

function c:GetSpeed()
    if placeManager:GetIdByName('guildsence') == game.PlaceId then
        return self:GetPKSpeed()
    end
    if placeManager:GetIdByName('pvpsence') == game.PlaceId then
        return self:GetPKSpeed()
    end

    local base = 16--初始值

    local relics = self.parent.relics_cmp:GetProp()
    local speed = relics.Speed or 0

    local vip = self.pay_data.__real.pay_list[28]
    local upgrade = self.parent.upgrade_cmp:GetValue('speed')

    local mount = self.parent.mount_cmp:GetSpeed()

    local speed = base * (1 + speed * 0.01) * (vip and 1.5 or 1) * (1 + upgrade) * (1 + mount)

    self:Fire('stats_speed',speed)

    return speed
end

function c:GetFreeGems()
    local now = os.time()
    local mark = self.data.__real.free_gems.mark
    if mark + free_gems_cd > now then
        return false
    end
    self.parent.save_data:Execut(function()
        self.data.free_gems.mark = now
        self.data.free_gems.num = self.data.free_gems.num + 1
    end)
    self.parent.reward_cmp:AddReward({{1,2,100}})

    return true
end

function c:BuyRandomPotion()
    if self.data.__real.potion.num >= 4 then
        return false
    end
    local price = 500000 
    if not self:CostWins(price) then
        return false
    end
    self.parent.reward_cmp:AddReward({{1,8,1}})

    self.parent.save_data:Execut(function()
        self.data.potion.num = self.data.potion.num + 1
    end)

    return true
end

c:RegistFunction('get_free_gems',c.GetFreeGems)
c:RegistFunction('reborn',c.Reborn)
c:RegistFunction('BuyRandomPotion',c.BuyRandomPotion)

return c