local hotpot = _G.ClientHotpot
---@type UIManager
local ui_manager = hotpot.load.UIManager()

local StartTime = 1739750400
local Interval = 86400
local daliy_cfg = hotpot.config.daily_reward

---@class Client_DailyComponent:Client_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Client_PlayerComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)

    self.data = self.parent.save_data:GetData('daily')
    self.ui = ui_manager.ui_list.daily_gui
    self.ui:BindItemClickHandle(self,self.ClickItem)
    ui_manager.ui_list.hud_gui:BindDailyHandle(self,self.CheckOpen)

    self:InitUi()
end

function c:InitUi()
    local info = {}
    for k,v in ipairs(daliy_cfg)do
        info[k] = {
            icon = self.parent.reward_cmp:GetIcon(v.reward[1]),
            quality = self.parent.reward_cmp:GetQulity(v.reward[1]),
            num = v.reward[1][3],
        }
    end
    self.ui:SetDailyGuiInfo(info)

    self:Refresh()
end

function c:Refresh()
    local can_get = self.data.can_get
    local get = self.data.get

    for k,v in ipairs(daliy_cfg)do
        if k <= get then
            self.ui:SetItemState(k,2)
        else
            if can_get then
                if k == get + 1 then
                    self.ui:SetItemState(k,3)
                    -- self.ui:Show()
                else
                    self.ui:SetItemState(k,1)
                end
            else
                self.ui:SetItemState(k,1)
                if k == get + 1 then
                    self:StartCD(k)
                end
            end
        end
    end
end

function c:StartCD(k)
    if self.__cd_co then
        return
    end
    self.__cd_co = self:AddUpdate(self.CD,1,k)
end

function c:StopCD()
    if self.__cd_co then
        self.__cd_co:Disconnect()
        self.__cd_co = nil
    end
end

function c:CD(_,_,id)
    local mark = self.data.mark
    local time_ = (mark + 1) * Interval + StartTime
    local now = workspace:GetServerTimeNow()
    self.ui:SetItemCD(id,time_ - now)
    if time_ - now <= 0 then
        self:StopCD()
        local re = self:Invoke('refreshDaily')
        if re then
            self.data = re
            self:Refresh()
        end
    end
end

function c:ClickItem(id)
    local get = self.data.get
    local can_get = self.data.can_get
    if id == get + 1 and can_get then
        local re = self:Invoke('get_daily_reward',id)
        if re then
            self.data.can_get = false
            self.data.get = id
            self:Refresh()
        end
    end
end

function c:CheckOpen()
    if self.data.get >= 7 then
        ui_manager.ui_list.new_daily_gui:Show()
    else
        self.ui:Show()
    end
end

return c