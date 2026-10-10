local hotpot = _G.ServerHotpot

---@class Server_RewardComponent:Server_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Server_PlayerComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)
end

--资源表奖励
local resource_funs = {}
---@param self Server_RewardComponent
resource_funs[1] = function(self,num)--exp
    return self.parent.prop_cmp:AddExp(num)
end
---@param self Server_RewardComponent
resource_funs[2] = function(self,num)--gems
    return self.parent.prop_cmp:AddGems(num)
end
---@param self Server_RewardComponent
resource_funs[3] = function(self,num)--wins
    return self.parent.prop_cmp:AddWins(num)
end
---@param self Server_RewardComponent
resource_funs[4] = function(self,num)--药水包
    for i = 1,3 do
        self.parent.bag_cmp:AddBuff(i,num)
    end
    return true
end
---@param self Server_RewardComponent
resource_funs[5] = function(self,num)--宠物最大装备数
    self.parent.pet_cmp:AddEquipedNum(1)
    return true
end
---@param self Server_RewardComponent
resource_funs[6] = function(self,num)--宠物最大装备数
    self.parent.eternal_cmp:AddTicket(num)
    return true
end
---@param self Server_RewardComponent
resource_funs[7] = function(self,num)--宠物最大装备数
    self.parent.eternal_cmp:AddCoins(num)
    return true
end
---@param self Server_RewardComponent
resource_funs[8] = function(self,num)--宠物最大装备数
    local ran = math.random(1,3)
    self:AddReward({{3,ran,num}})
    return true
end
---@param self Server_RewardComponent
resource_funs[10] = function(self,num)--称号激活数量
    self.parent.title_cmp:AddMaxActiveNum(num)
    return true
end
---@param self Server_RewardComponent
resource_funs[11] = function(self,num)--公会币
    self.parent.guild_cmp:AddCoin(num)
    return true
end
---@param self Server_RewardComponent
resource_funs[12] = function(self,num)--对战币
    self.parent.prop_cmp:AddPvpCoin(num)
    return true
end

--总奖励
local funs = {}
---@param self Server_RewardComponent
funs[1] = function(self,t_id,id,num)
    local fun = resource_funs[id]
    if fun then
        return fun(self,num)
    end
end
---@param self Server_RewardComponent
funs[2] = function(self,t_id,id,num)--宠物
    for i = 1,num do
        self.parent.pet_cmp:AddPet(id)
    end
    return true
end
---@param self Server_RewardComponent
funs[3] = function(self,t_id,id,num)--药水
    self.parent.bag_cmp:AddBuff(id,num)
    return true
end
---@param self Server_RewardComponent
funs[4] = function(self,t_id,id,num)--遗器
    for i = 1,num do
        self.parent.relics_cmp:AddRelics(id)
    end
    return true
end
---@param self Server_RewardComponent
funs[5] = function(self,t_id,id,num)--当前世界蛋的价格的金币
    local cfg = hotpot.config.gacha
    local stageCfg = hotpot.config.stage

    local stage = self.parent.stage_cmp:GetMaxStage()
    local cId = stageCfg[stage].egg_id
    local price = cfg[cId].price
    local coin = price * num
    self.parent.prop_cmp:AddWins(coin)
    return true
end
---@param self Server_RewardComponent
funs[6] = function(self,t_id,id,num)--遗器
    self.parent.bag_cmp:AddBox(id,num)
    return true
end
---@param self Server_RewardComponent
funs[7] = function(self,t_id,id,num)--角色
    self.parent.character_cmp:UnlockSecret(id)
    return true
end
---@param self Server_RewardComponent
funs[8] = function(self,t_id,id,num)--称号
    local cfg = hotpot.config.title
    local t = cfg[id].needType
    self.parent.title_cmp:AddPoint(t,num)
    return true
end
---@param self Server_RewardComponent
funs[9] = function(self,t_id,id,num)--技能碎片
    self.parent.skill_cmp:AddSkillChip(id,num)
    return true
end
---@param self Server_RewardComponent
funs[10] = function(self,t_id,id,num)--坐骑
    self.parent.mount_cmp:UnlockMount(id)
    return true
end
---@param self Server_RewardComponent
funs[11] = function(self,t_id,id,num)--锻造石
    self.parent.relics_cmp:AddForgeStone(id,num)
    return true
end
---@param self Server_RewardComponent
funs[12] = function(self,t_id,id,num)--幸运石
    self.parent.relics_cmp:AddLuckyStone(id,num)
    return true
end
---@param self Server_RewardComponent
funs[13] = function(self,t_id,id,num)--遗器滚动
    self.parent.relics_cmp:AddScroll(id,num)
    return true
end

--获取奖励
function c:AddReward(list,not_sync)
    for i,reward in ipairs(list)do
        local t_id = reward[1]
        local fun = funs[t_id]
        if fun then
            self:AddProcess(function()
                fun(self,table.unpack(reward))
            end)
        end
    end
    if not not_sync then
        self:Fire('add_reward',list)
    end
end

function c:GetIcon(reward)
    local t_id = reward[1]
    local cfg
    if t_id == 1 then
        cfg = hotpot.config.resource
    elseif t_id == 2 then
        cfg = hotpot.config.pet
    elseif t_id == 3 then
        cfg = hotpot.config.boosts
    elseif t_id == 4 then
        cfg = hotpot.config.relics
    elseif t_id == 5 then
        return hotpot.config.resource[3].icon
    elseif t_id == 6 then
        cfg = hotpot.config.relics_gacha
    elseif t_id == 7 then
        cfg = hotpot.config.character
    elseif t_id == 8 then
        cfg = hotpot.config.title
    elseif t_id == 9 then
        return hotpot.config.skill[reward[2]].shardsIcon
    elseif t_id == 10 then
        cfg = hotpot.config.mount
    elseif t_id == 11 then
        cfg = hotpot.config.forgeStone
    elseif t_id == 12 then
        cfg = hotpot.config.luckyStone
    end
    return cfg[reward[2]].icon or ''
end

return c