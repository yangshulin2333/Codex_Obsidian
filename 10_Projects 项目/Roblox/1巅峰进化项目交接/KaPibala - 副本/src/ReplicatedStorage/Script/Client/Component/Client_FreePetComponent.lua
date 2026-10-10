local hotpot = _G.ClientHotpot
---@type UIManager
local ui_manager = hotpot.load.UIManager()
---@type Client_AudioManager
local audioManager = hotpot.load.Client_AudioManager()

local times = {300,3600}
local icons = {'rbxassetid://111560070222303','rbxassetid://79045603156129'}

---@class Client_FreePetComponent:Client_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Client_PlayerComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)

    self.data = self.parent.save_data:GetData('free_pet')
    self.ui = ui_manager.ui_list.free_pet_gui
    self.ui:BindFreeBtnClickHandle(self,self.ClickClaimBtn)
    self.ui:BindBuyBtnClickHandle(self,self.ClickBuyBtn)

    self.mark = 0

    self:ItinUi()
end

function c:ItinUi()
    if self.data.num == 2 then
        ui_manager.ui_list.hud_gui:SetFreePetVisible(false)
        return
    end
    -- print(self.data.num)
    if self.data.num == 0 then
        self.need_time = times[1]
        self.ui:SetPrice(19,self.need_time/60,icons[1])
    else
        self.need_time = times[2]
        self.ui:SetPrice(79,self.need_time/60,icons[2])
    end
    self.time = 0
    self:AddUpdate(self.Update,1)

    local IsInGroup = self.parent.main_inst:IsInGroup(714790418)
    self.ui:SetTask2Pro(IsInGroup and 1 or 0,1)
end

function c:Update()
    self.time = self.time + 1
    self.ui:SetTask1Pro(self.time,self.need_time)

    if self.data.num < 2 then
        ui_manager.ui_list.hud_gui:SetFreePetRedVisible(self.time >= self.need_time)
    end

    local IsInGroup = self.parent.main_inst:IsInGroup(714790418)
    self.ui:SetTask2Pro(IsInGroup and 1 or 0,1)
end

function c:ClickClaimBtn()
    if self.data.num == 2 then
        return
    end
    if self.time < self.need_time then
        return
    end
    if not self.parent.main_inst:IsInGroup(714790418) then
        return false
    end
    local re,num = self:Invoke('getFreePet')
    if re then
        ui_manager.ui_list.tips_gui:TipsMessage('Claim successfully','success')
        self.data.num = num
        if self.data.num == 0 then
            self.need_time = times[1]
        elseif self.data.num == 1 then
            self.need_time = times[2]
            self.ui:SetPrice(79,self.need_time/60,icons[2])

        else
            self.ui:Hide()
            ui_manager.ui_list.hud_gui:SetFreePetVisible(false)
        end
        self.time = 0
    end
end

function c:ClickBuyBtn()
    local cfg_id
    if self.data.num == 0 then
        cfg_id = 58
    else
        cfg_id = 59
    end
    local re = self:Invoke('buy_goods',cfg_id)
    if re then
        spawn(function()
            pcall(function()
                audioManager:PlayGloble('purchase1')
                audioManager:PlayGloble('purchase2')
                wait(0.6)
                audioManager:PlayGloble('purchase3')
            end)
        end)
        ui_manager.ui_list.tips_gui:TipsMessage('Purchase successfully','success')
    end
end

return c