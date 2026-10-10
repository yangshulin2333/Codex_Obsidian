local hotpot = _G.ClientHotpot
---@type UIManager
local ui_manager = hotpot.load.UIManager()

local online_cfg = hotpot.config.online_reward

---@class Client_OnlineComponent:Client_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Client_PlayerComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)

    self.get_list = {}
    self.time = 0
    self.red = false

    self.ui = ui_manager.ui_list.online_gui
    self.ui:BindItemClickHandle(self,self.ClickItem)
    self.ui:BindJumpBtnClickHandle(self,self.ClickJumpBtn)

    self:InitUi()
end

function c:InitUi()
    local info = {}
    for k,v in ipairs(online_cfg)do
        info[k] = {
            icon = self.parent.reward_cmp:GetIcon(v.reward),
            quality = self.parent.reward_cmp:GetQulity(v.reward),
            num = v.reward[3],
        }
    end
    self.ui:SetOnlineInfo(info)
end

function c:Update(time_)
    self.time = time_
    self.red = false
    local minTime = 10000000
    for k,v in ipairs(online_cfg)do
        if v.times < self.time then
            if self.get_list[v.id] then
                self.ui:SetItemState(v.id,1)
            else
                self.ui:SetItemState(v.id,2)
                self.red = true
            end
        else
            self.ui:SetItemState(v.id,3,v.times - self.time)
            minTime = math.min(minTime,v.times - self.time)
        end
    end
    ui_manager.ui_list.hud_gui:SetOnlineRedVisible(self.red)
    if self.red then
        ui_manager.ui_list.hud_gui:SetOpenRedVisible(true)
    else
        if self.parent.mount_cmp and self.parent.mount_cmp.red then
            ui_manager.ui_list.hud_gui:SetOpenRedVisible(true)
        else
            ui_manager.ui_list.hud_gui:SetOpenRedVisible(false)
        end
    end
    if minTime == 10000000 then
        ui_manager.ui_list.hud_gui:SetOnlineCD(0)
    else
        if minTime > 0 then
            ui_manager.ui_list.hud_gui:SetOnlineCD(minTime)
        else
            ui_manager.ui_list.hud_gui:SetOnlineCD(0)
        end
    end
end

function c:ClickItem(id)
    if self.get_list[id] then
        return
    end
    local cfg = online_cfg[id]
    if self.time < cfg.times then
        return
    end
    local re = self:Invoke('get_online_reward',id)
    if re then
        self.get_list[id] = true
        ui_manager.ui_list.tips_gui:TipsMessage('Success!','success')
    end
end

function c:ClickJumpBtn()
    local re = self:Invoke('buy_goods',138)
    if re then
        self.parent.shop_cmp:PlayPurchaseSound()
        ui_manager.ui_list.tips_gui:TipsMessage('Purchase successfully','success')
    end
end

c:RegistEvent('online_time',c.Update)

return c