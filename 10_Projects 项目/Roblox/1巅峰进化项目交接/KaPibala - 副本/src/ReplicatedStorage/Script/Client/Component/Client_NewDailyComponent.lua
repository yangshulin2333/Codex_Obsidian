local hotpot = _G.ClientHotpot
---@type UIManager
local ui_manager = hotpot.load.UIManager()

local StartTime = 1739750400
local Interval = 86400
local daliy_cfg = hotpot.config.newdaily_reward
local PropList = {DMG = true,EXP = true,MaxHp = true,Speed = true}
local showStr = '%s:%d%%'

local testAdd = 0

---@class Client_NewDailyComponent:Client_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Client_PlayerComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)

    self.data = self.parent.save_data:GetData('new_daily')
    self.ui = ui_manager.ui_list.new_daily_gui
    if self.parent.daily_cmp.data.get < 7 then
        self.ui:Hide()
        return
    end

    self.ui:BindLostBtnClickHandle(self,self.ClickLostBtn)
    self.ui:BindRecoverBtnClickHandle(self,self.ClickRecoverBtn)
    self.ui:BindItemClickHandle(self,self.ClickClaimBtn)
    self.ui:BindMouseEnterHandle(self,self.MouseEnter)

    self:InitUi()
    self:RefreshUi()
end

function c:InitUi()
    for k,v in ipairs(daliy_cfg)do
        local reward = v.reward[1]
        local title = nil
        if reward[1] == 8 then
            title = hotpot.config.title[reward[2]].name
        end
        self.ui:AddItemInScroll(
            v.id,
            self.parent.reward_cmp:GetIcon(reward),
            reward[3],
            self.parent.reward_cmp:GetQulity(reward),
            title
        )
    end

    self.ui:SetTips(self.data.get)
    self.ui:SetScrollCenter(self.data.get)  

    if self.data.can_get then
        self.ui:Show()
    else
        self.ui:Hide()
    end
end

function c:RefreshUi()
    local get = self.data.get--已经领取的
    for k,v in ipairs(daliy_cfg)do
        if k <= get then
            self.ui:SetItemState(v.id,1)
        elseif k == get + 1 then
            if self.data.can_get then
                self.ui:SetItemState(v.id,2)
            else
                self.ui:SetItemState(v.id,3)
            end
        else
            self.ui:SetItemState(v.id,3)
        end
    end

    local mark = self.data.mark
    local now = math.floor(workspace:GetServerTimeNow() + testAdd)
    local sub = now - StartTime
    local day = math.floor(sub / Interval)

    if day > mark then
        if get == 0 then
            self.ui:SetTopVisible(false)
        else
            if day - mark > 1 then--隔天
                self.ui:SetTopVisible(true)
                self.ui:SetTopDay(get)

                local price = 0
                if get <= 3 then
                    price = 0
                elseif get <= 10 then
                    price = 10
                elseif get <= 20 then
                    price = 20
                else
                    price = 30
                end

                self.ui:SetTopPrice(price)

                self.ui:Show()
            end
        end
    end

    self.ui:SetScrollCenter(self.data.get + 1)  
    self.ui:SetTips(self.data.get)
    self.ui:SetTopDoneVisible(self.data.get >= 30)
end

function c:ClickLostBtn()
    local re = self:Invoke('daily_lost')
    if re then
        self.data.get = 0
        self:RefreshUi()
    end
end

function c:ClickRecoverBtn()
    local get = self.data.get

    if get <= 3 then
        local re = self:Invoke('recover_daily')
        if re then
            ui_manager.ui_list.tips_gui:TipsMessage('Recovery success','success')
        end
        return
    end

    local goodsId = 0
    if get <= 10 then
        goodsId = 120
    elseif get <= 20 then
        goodsId = 121
    else
        goodsId = 122
    end

    local re = self:Invoke('buy_goods',goodsId)
    if re then
        ui_manager.ui_list.tips_gui:TipsMessage('Recovery success','success')
    end
end

function c:SetDailyNewDay(day)
    self.data.mark = day
    self.data.can_get = true
    self:RefreshUi()
    self.ui:SetTopVisible(false)
end

function c:ClickClaimBtn(id)
    if not self.data.can_get then
        return
    end
    local re,day = self:Invoke('claim_daily',id)
    if re then
        self.data.can_get = false
        self.data.get = id
        self.data.mark = day
        self:RefreshUi()
    end
end

function c:MouseEnter(id)
    local cfg = daliy_cfg[id]
    if not cfg then
        return
    end
    local reward = cfg.reward[1]
    if reward[1] == 2 then
        local pCfg = hotpot.config.pet[reward[2]]
        if pCfg.value_per then
            self.ui:SetPetTips2Visible(true)
            self.ui:SetPetTipsVisible(false)
            self.ui:SetRelicsTipsVisible(false)

            self.ui:SetPetFrameTipsFrame2Info(pCfg.name,pCfg.value,pCfg.quality,pCfg.value_per * 100)
        else
            self.ui:SetPetTips2Visible(false)
            self.ui:SetPetTipsVisible(true)
            self.ui:SetRelicsTipsVisible(false)

            self.ui:SetPetFrameTipsFrameInfo(pCfg.name,pCfg.value,pCfg.quality)
        end
    elseif reward[1] == 4 then
        local rCfg = hotpot.config.relics[reward[2]]
        self.ui:SetPetTips2Visible(false)
        self.ui:SetPetTipsVisible(false)
        self.ui:SetRelicsTipsVisible(true)

        local cfg = rCfg
        local list = {}
        local big = 0
        local bigVal = 0

        for key,_ in pairs(PropList)do
            if cfg[key] then
                if key == 'MaxHp' then
                    table.insert(list,string.format(showStr,'HP',cfg[key]))
                else
                    table.insert(list,string.format(showStr,key,cfg[key]))
                end
            end
        end

        self.ui:SetRelicsTipsInfo(cfg.name,list,cfg.quality, 0, 0)
    end
end

c:RegistEvent('set_daily_new_day',c.SetDailyNewDay)

return c