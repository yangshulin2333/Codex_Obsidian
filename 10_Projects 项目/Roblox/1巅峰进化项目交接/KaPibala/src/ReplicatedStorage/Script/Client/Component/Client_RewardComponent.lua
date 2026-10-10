local hotpot = _G.ClientHotpot
---@type UIManager
local ui_manager = hotpot.load.UIManager()
---@type BigNumberHelper
local big_number = hotpot.load.BigNumberHelper()
---@type Client_AudioManager
local audioManager = hotpot.load.Client_AudioManager()

---@class Client_RewardComponent:Client_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Client_PlayerComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)

    self.ui = ui_manager.ui_list.reward_gui

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
    elseif t_id == 13 then
        cfg = hotpot.config.relicsScorll
    end
    return cfg[reward[2]].icon or ''
end

function c:GetQulity(reward)
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
        return hotpot.config.resource[3].quality
    elseif t_id == 6 then
        cfg = hotpot.config.relics_gacha
    elseif t_id == 7 then
        cfg = hotpot.config.character
    elseif t_id == 8 then
        return 3
    elseif t_id == 9 then
        return 2
    elseif t_id == 10 then
        return 5
    elseif t_id == 11 then
        cfg = hotpot.config.forgeStone
    elseif t_id == 12 then
        cfg = hotpot.config.luckyStone
    elseif t_id == 13 then
        cfg = hotpot.config.relicsScorll
    end

    return cfg[reward[2]].quality or 1
end

function c:GetNum(reward)
    local t_id = reward[1]
    if t_id == 5 then
        local cfg = hotpot.config.gacha
        local stageCfg = hotpot.config.stage

        -- local idx = reward[2]
        local count = reward[3]

        local stage = self.parent.stage_cmp:GetMaxStage()
        local id = stageCfg[stage].egg_id
        local price = cfg[id].price
        return big_number:ToString(price * count)
    end
    return big_number:ToString(reward[3])
end

function c:GetName(reward)
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
        return hotpot.config.resource[3].name
    elseif t_id == 6 then
        cfg = hotpot.config.relics_gacha
    elseif t_id == 7 then
        cfg = hotpot.config.character
    elseif t_id == 8 then
        cfg = hotpot.config.title
    elseif t_id == 9 then
        cfg = hotpot.config.skill
    elseif t_id == 10 then
        cfg = hotpot.config.mount
    elseif t_id == 11 then
        cfg = hotpot.config.forgeStone
    elseif t_id == 12 then
        cfg = hotpot.config.luckyStone
    elseif t_id == 13 then
        cfg = hotpot.config.relicsScorll
    end

    return cfg[reward[2]].name or ''
end

function c:AddReward(list)
    pcall(function()
        audioManager:PlayGloble('getReward')
    end)
    for k,reward in ipairs(list)do
        if not (reward[1] == 1 and reward[2] == 8) then
            self.ui:PlayReward(
                self:GetIcon(reward),
                self:GetNum(reward),
                self:GetName(reward),
                self:GetQulity(reward)
            )
        end
    end
end

function c:AddRewardNew(list)
    pcall(function()
        audioManager:PlayGloble('getReward')
    end)
    for k,v in ipairs(list)do
        if not (v.reward[1] == 1 and v.reward[2] == 8) then
            self.ui:PlayReward(
                self:GetIcon(v.reward),
                self:GetNum(v.reward),
                self:GetName(v.reward),
                v.quality
            )
        end
    end
end

function c:GetChallengeReward(reward)
    self:AddReward({reward})
end

c:RegistEvent('add_reward',c.AddReward)
c:RegistEvent('getChallengeReward',c.GetChallengeReward)

return c