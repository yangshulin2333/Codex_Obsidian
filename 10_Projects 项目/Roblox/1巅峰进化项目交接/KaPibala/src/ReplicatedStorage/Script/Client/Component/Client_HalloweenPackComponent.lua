local hotpot = _G.ClientHotpot
---@type UIManager
local ui_manager = hotpot.load.UIManager()

local OVERTIME = 1762560000
local petId = 282--217
local relicsId = 181--133
local petCfg = hotpot.config.pet
local relicsCfg = hotpot.config.relics
local PropList = {DMG = true,EXP = true,MaxHp = true,Speed = true}
local showStr = '%s:%s%%'

---@class Client_HalloweenPackComponent:Client_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Client_PlayerComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)

    self.data = self.parent.save_data:GetData('pay').pay_list
    self.ui = ui_manager.ui_list.halloween_pack_gui
    self.ui:BindPetBtnMouseEnterHandle(self,self.MouseInPet)
    self.ui:BindRelicsBtnMouseEnterHandle(self,self.MouseInRelics)
    self.ui:BindMountBtnMouseEnterHandle(self,self.MouseInMount)
    self.ui:BindBtnClickHandle(self,self.ClickBuy)
    ui_manager.ui_list.shop_gui:BindHalloweenBtnClickHandle(self,self.ClickBuy)
    ui_manager.ui_list.hud_gui:BindHalloweenPackClickHandle(
        self.ui,
        self.ui.Show
    )

    if self.data[136] then
        ui_manager.ui_list.hud_gui:SetHalloweenPackVisible(false)
    else
        ui_manager.ui_list.hud_gui:SetHalloweenPackVisible(true)
    end

    self:AddUpdate(self.Update,1)
end

function c:MouseInPet()
    local cfg = petCfg[petId]

    self.ui:SetPetFrameTipsFrameInfo(
        cfg.name,
        cfg.value,
        cfg.quality
    )
    self.ui:SetPetFrameTipsFrameVisible(true)
end

function c:MouseInRelics()
    local cfg = relicsCfg[relicsId]
    local list = {}

    for key,_ in pairs(PropList)do
        if cfg[key] then
            table.insert(list,string.format(showStr,key,cfg[key]))
        end
    end

    self.ui:SetTipsInfo(cfg.name,list,cfg.quality)
    self.ui:SetRelicsFrameTipsFrameVisible(true)
end

function c:MouseInMount()
    local cfg = hotpot.config.mount[6]
    self.ui:SetTipsFrame1Info(
        cfg.name,
        cfg.speed
    )
    self.ui:SetTipsFrame1Visible(true)
end

function c:ClickBuy()
    if self.parent.shop_cmp.giftPlayer then
        local isHave = self:Invoke('check_goods',136)
        if isHave then
            local name = self.parent.shop_cmp.giftPlayer.Name
            ui_manager.ui_list.tips_gui:TipsMessage(name..' has purchased it!','fail')
            return
        end
    end
    local re = self:Invoke('buy_goods',136)
    if re then
        self.parent.shop_cmp:PlayPurchaseSound()
        ui_manager.ui_list.tips_gui:TipsMessage('Purchase successfully','success')
        if not self.parent.shop_cmp.giftPlayer then
            ui_manager.ui_list.hud_gui:SetHalloweenPackVisible(false)
            self.ui:Hide()
            ui_manager.ui_list.shop_gui:SetHalloweenPackOwned(true)
        end
    end
end

function c:Update()
    local now = workspace:GetServerTimeNow()
    self.ui:SetCD(math.max(OVERTIME - now,0))
end

return c