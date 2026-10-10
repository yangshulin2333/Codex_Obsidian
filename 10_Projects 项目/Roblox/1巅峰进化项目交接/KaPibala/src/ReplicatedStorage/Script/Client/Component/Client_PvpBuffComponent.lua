local hotpot = _G.ClientHotpot
---@type BigNumberHelper
local bigNumber = hotpot.load.BigNumberHelper()
---@type RayManager
local rayManager = hotpot.load.RayManager()
---@type UIManager
local ui_manager = hotpot.load.UIManager()

local BASETIME = 1769904000
local titles = {
    atk = 'Attack Boost',
    hp = 'HP Boost',
    atkspeed = 'Attack Speed Boost',
    speed = 'Move Speed Boost',
}
local desc = {
    atk = 'Increase the damage to players. It is free once a day and lasts for 30 minutes each time.',
    hp = 'Increase your maximum health points. It is free once a day and lasts for 30 minutes each time.',
    atkspeed = 'Increase your attack frequency. It is free once a day and lasts for 30 minutes each time.',
    speed = 'Increase your move speed. It is free once a day and lasts for 30 minutes each time.',
}
local goods = {
    {atk = 107,hp = 109,atkspeed = 111,speed = 113},
    {atk = 108,hp = 110,atkspeed = 112,speed = 114},
}

---@class Client_PvpBuffComponent:Client_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Client_PlayerComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)

    self.data = self.parent.save_data:GetData('pvp_buff')
    self.ui = ui_manager.ui_list.pvp_buff_gui
    self.ui:BindFreeBtnClickHandle(self,self.ClickFree)
    self.ui:BindBtn1ClickHandle(self,self.ClickBtn1)
    self.ui:BindBtn2ClickHandle(self,self.ClickBtn2)

    self:InitScene()
    self:AddUpdate(self.UpdateUi,1)
end

--加载场景
function c:InitScene()
    local atk = hotpot:GetPath_Loop('Stage.buff.atk',workspace)
    local hp = hotpot:GetPath_Loop('Stage.buff.hp',workspace)
    local atkspeed = hotpot:GetPath_Loop('Stage.buff.atkspeed',workspace)
    local speed = hotpot:GetPath_Loop('Stage.buff.speed',workspace)

    rayManager:AddRayCast(
        atk,
        self,
        self.InAtk,
        self.LeavePart
    )
    rayManager:AddRayCast(
        hp,
        self,
        self.InHp,
        self.LeavePart
    )
    rayManager:AddRayCast(
        atkspeed,
        self,
        self.InAtkSpeed,
        self.LeavePart
    )
    rayManager:AddRayCast(
        speed,
        self,
        self.InSpeed,
        self.LeavePart
    )

    self.atk = atk
    self.hp = hp
    self.atkspeed = atkspeed
    self.speed = speed

    local atkUi = hotpot:GetPath_Loop('BillboardGui',atk)
    local hpUi = hotpot:GetPath_Loop('BillboardGui',hp)
    local atkspeedUi = hotpot:GetPath_Loop('BillboardGui',atkspeed)
    local speedUi = hotpot:GetPath_Loop('BillboardGui',speed)

    self.atkUi = atkUi
    self.hpUi = hpUi
    self.atkspeedUi = atkspeedUi
    self.speedUi = speedUi
end

function c:UpdateUi()
    local now = math.floor(workspace:GetServerTimeNow())
    local mark = self.data.mark
    local over = BASETIME + (mark + 1) * 86400

    if now >= over then
        local mark = self:Invoke('refreshPvpTime')
        if mark then
            self.data.mark = mark
        end
    end

    if self.data.free.atk then--已领取
        self.atkUi.cd.Text = bigNumber:TransformDateToString(over - now)
        self.atkUi.cd.Visible = true
        self.atkUi.free.Visible = false
    else
        self.atkUi.cd.Visible = false
        self.atkUi.free.Visible = true
    end

    if self.data.free.hp then--已领取
        self.hpUi.cd.Text = bigNumber:TransformDateToString(over - now)
        self.hpUi.cd.Visible = true
        self.hpUi.free.Visible = false
    else
        self.hpUi.cd.Visible = false
        self.hpUi.free.Visible = true
    end

    if self.data.free.atkspeed then--已领取
        self.atkspeedUi.cd.Text = bigNumber:TransformDateToString(over - now)
        self.atkspeedUi.cd.Visible = true
        self.atkspeedUi.free.Visible = false
    else
        self.atkspeedUi.cd.Visible = false
        self.atkspeedUi.free.Visible = true
    end

    if self.data.free.speed then--已领取
        self.speedUi.cd.Text = bigNumber:TransformDateToString(over - now)
        self.speedUi.cd.Visible = true
        self.speedUi.free.Visible = false
    else
        self.speedUi.cd.Visible = false
        self.speedUi.free.Visible = true
    end
end

function c:InAtk()
    self.now_buff = 'atk'
    self.ui:SetTitle(titles.atk)
    self.ui:SetDesc(desc.atk)
    self.ui:Show()
end

function c:InHp()
    self.now_buff = 'hp'
    self.ui:SetTitle(titles.hp)
    self.ui:SetDesc(desc.hp)
    self.ui:Show()
end

function c:InAtkSpeed()
    self.now_buff = 'atkspeed'
    self.ui:SetTitle(titles.atkspeed)
    self.ui:SetDesc(desc.atkspeed)
    self.ui:Show()
end

function c:InSpeed()
    self.now_buff = 'speed'
    self.ui:SetTitle(titles.speed)
    self.ui:SetDesc(desc.speed)
    self.ui:Show()
end

function c:LeavePart()
    self.now_buff = nil
    self.ui:Hide()
end

function c:ClickFree()
    local now_buff = self.now_buff
    if not now_buff then
        return
    end
    local re,t = self:Invoke('getFreePvpBuff',now_buff)
    if re then
        ui_manager.ui_list.tips_gui:TipsMessage('Claimed success!','success')
        self.data.free[now_buff] = true
        self.data.list[now_buff].small = t
    else
        if t == 1 then
            ui_manager.ui_list.tips_gui:TipsMessage('You have claimed this buff!','fail')
        end
    end
end

function c:ClickBtn1()
    local now_buff = self.now_buff
    if not now_buff then
        return
    end
    local goodsId = goods[1][now_buff]
    local re = self:Invoke('buy_goods',goodsId)
    if re then
        ui_manager.ui_list.tips_gui:TipsMessage('Purchase success!','success')
        self.parent.shop_cmp:PlayPurchaseSound()
    end
end

function c:ClickBtn2()
    local now_buff = self.now_buff
    if not now_buff then
        return
    end
    local goodsId = goods[2][now_buff]
    local re = self:Invoke('buy_goods',goodsId)
    if re then
        ui_manager.ui_list.tips_gui:TipsMessage('Purchase success!','success')
        self.parent.shop_cmp:PlayPurchaseSound()
    end
end

function c:SyncPvpBuff(data)
    self.data.list = data
end

function c:GetAtkSpeedPer()
    local now = workspace:GetServerTimeNow()
    local big = self.data.list.atkspeed.big
    if big >= now then
        return 2
    end
    local small = self.data.list.atkspeed.small
    if small >= now then
        return 1.5
    end
    return 1
end

c:RegistEvent('syncPvpBuff',c.SyncPvpBuff)

return c
