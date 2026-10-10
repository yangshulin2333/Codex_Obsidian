local hotpot = _G.ClientHotpot
---@type UIManager
local ui_manager = hotpot.load.UIManager()
---@type PlaceManager
local place_manager = hotpot.load.PlaceManager()

local skillCfg = hotpot.config.skill
local OpenSkillCfg = hotpot.config.skillBox
local total = 0
for _,v in ipairs(OpenSkillCfg)do
    total = total + v.weight
end

---@class Client_OpenSkillComponent:Client_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Client_PlayerComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)

    self.ui = ui_manager.ui_list.open_skill_gui
    self.ui:BindBtnClickHandle(self,self.ClickBuy)
    self.ui:BindBtnAllClickHandle(self,self.ClickBuy)

    self:InitUi()
end

function c:InitUi()
    for k,v in ipairs(OpenSkillCfg)do
        self.ui:AddItemInScroll(
            v.id,
            self.parent.reward_cmp:GetIcon(v.reward),
            string.format("%.2f%%",v.weight/total * 100),
            v.quality,
            self.parent.reward_cmp:GetNum(v.reward)
        )
    end
end

function c:ClickBuy(num)
    local goods_id = 0
    if num == 1 then
        goods_id = 90
    elseif num == 10 then
        goods_id = 91
    end

    local re = self:Invoke('buy_goods',goods_id)
    if re then
        -- self.ui:SetOpenBGVisible(false)
        local id = self.result_list[1]
    
        local list = {}
        for i = 1,100 do
            local ran = math.random(1,#OpenSkillCfg)
            local r_id = OpenSkillCfg[ran].reward[2]
            local icon = skillCfg[r_id].shardsIcon
            list[i] = {
                icon = icon,
                quality = OpenSkillCfg[ran].quality,
                num = OpenSkillCfg[ran].reward[3],
            }
        end
        local rId = OpenSkillCfg[id].reward[2]
        list[98] = {
            icon = skillCfg[rId].shardsIcon,
            quality = OpenSkillCfg[id].quality,
            num = OpenSkillCfg[id].reward[3],
        }

        self.ui:SetRewardList(list)
        self.ui:SetSureBgVisible(false)
        self.ui:SetOpenBGVisible(true)
        wait(.5)
        self.ui:Play(function()
            local reward_list = {}
            for k,v in ipairs(self.result_list)do
                table.insert(reward_list,{reward = OpenSkillCfg[v].reward,quality = OpenSkillCfg[v].quality})
            end
            self.parent.reward_cmp:AddRewardNew(reward_list)
        end)
        ui_manager.ui_list.hud_gui:Show()
        if place_manager:GetIdByName('pvpsence') == game.PlaceId then
            if self.parent.pvp_stage.__in_skill_box then
                self.ui:SetSureBgVisible(true)
            end
        else
            if self.parent.now_stage.__in_skill_box then
                self.ui:SetSureBgVisible(true)
            end
        end
    end
end

function c:OpenResult(list)
    self.result_list = list
end

c:RegistEvent('openResult',c.OpenResult)

return c