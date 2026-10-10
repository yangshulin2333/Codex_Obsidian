local hotpot = _G.ClientHotpot
---@type UIManager
local ui_manager = hotpot.load.UIManager()
---@type ContextActionService
local ContextActionService = game:GetService('ContextActionService')
---@type PlaceManager
local place_manager = hotpot.load.PlaceManager()
---@type BigNumberHelper
local big_number = hotpot.load.BigNumberHelper()
---@type Client_AudioManager
local audio_manager = hotpot.load.Client_AudioManager()

local rideCold = 0
local mountCfg = hotpot.config.mount
local lyckyStone_cfg = hotpot.config.luckyStone
local forgeCostCfg = hotpot.config.forgeCost
local forgeStoneCfg = hotpot.config.forgeStone

---@class Client_MountComponent:Client_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Client_PlayerComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)

    self.data = self.parent.save_data:GetData('mount')
    self.ui = ui_manager.ui_list.mount_gui
    self.ui:BindItemEquipBtnClickHandle(self,self.ClickEquipBtn)
    self.ui:BindItemUnequipBtnClickHandle(self,self.ClickUnEquipBtn)
    self.ui:BindItemUnlockBtnClickHandle(self,self.ClickUnlockBtn)
    self.ui:BindItemUnlockRobuxBtnClickHandle(self,self.ClickUnlockRobuxBtn)
    ui_manager.ui_list.hud_gui:BindSkillMountBtnClickHandle(self,self.ClickRideBtn)
    self.ui:BindMouseEnterHandle(self,self.MouseEnterItem)

    self:InitUi()

    ContextActionService:BindAction('MountG',function(actionName,inputState,inputObject)
        if inputState == Enum.UserInputState.Begin then
            self:ClickRideBtn()
        end
    end,false,Enum.KeyCode.G)

    ContextActionService:BindAction('MountG1',function(actionName,inputState,inputObject)
        if inputState == Enum.UserInputState.Begin then
            self:ClickRideBtn()
        end
    end,false,Enum.KeyCode.ButtonL1)

    self:CheckRed()
end

function c:CheckRed()
    self.red = false
    if self.data.list[2] then
        self.ui:SetUnlockBtnRedVisible(2,false)
        ui_manager.ui_list.hud_gui:SetMountRedVisible(false)
        ui_manager.ui_list.hud_gui:SetOpenRedVisible(false)
    else
        if self.parent.prop_cmp:GetLv() < 22 then
            self.red = false
            self.ui:SetUnlockBtnRedVisible(2,false)
            ui_manager.ui_list.hud_gui:SetMountRedVisible(false)
            ui_manager.ui_list.hud_gui:SetOpenRedVisible(false)
        else
            self.red = true
            self.ui:SetUnlockBtnRedVisible(2,true)
            ui_manager.ui_list.hud_gui:SetMountRedVisible(true)
            ui_manager.ui_list.hud_gui:SetOpenRedVisible(true)
        end
    end
end

function c:InitUi()
    for k,v in ipairs(mountCfg)do
        self.ui:AddItemInScroll(
            v.id,
            v.icon,
            v.name,
            v.speed,
            v.lockNum,
            v.args,
            v.order
        )
        if self.data.list[v.id] then
            self.ui:SetItemUnlockBtnVisible(v.id,false)
            self.ui:SetItemUnlockRobuxBtnVisible(v.id,false)
            self.ui:SetItemEquipBtnVisible(v.id,self.data.equiped ~= v.id)
            self.ui:SetItemUnequipBtnVisible(v.id,self.data.equiped == v.id)
        else
            self.ui:SetItemEquipBtnVisible(v.id,false)
            self.ui:SetItemUnequipBtnVisible(v.id,false)
            if v.lockCondition == 1 then
                self.ui:SetItemUnlockBtnVisible(v.id,false)
                self.ui:SetItemUnlockRobuxBtnVisible(v.id,true)
            else
                self.ui:SetItemUnlockBtnVisible(v.id,true)
                self.ui:SetItemUnlockRobuxBtnVisible(v.id,false)
            end
        end
    end

    ui_manager.ui_list.hud_gui:SetSkillMountBtnVisible(self.data.equiped ~= 0)
    self:AddProcess(function()
        self:Wait(11)
        ui_manager.ui_list.hud_gui:SetSkillMountBtnVisible(self.data.equiped ~= 0)
    end)

    self:RefreshUi()
end

function c:ClickUnlockBtn(id)
    if self.data.list[id] then
        return
    end
    local cfg = mountCfg[id]
    if not cfg then
        return
    end
    if cfg.lockCondition == 3 then
        local str = cfg.args
        ui_manager.ui_list.tips_gui:TipsMessage(str,'fail')
        return
    elseif cfg.lockCondition == 2 then
        local lv = self.parent.prop_cmp:GetLv()
        if lv < 22 then
            ui_manager.ui_list.tips_gui:TipsMessage('You need to upgrade to level 22 to unlock this mount','fail')
            return
        end 
        local re = self:Invoke('unlockMount',id)
        if re then
            ui_manager.ui_list.tips_gui:TipsMessage('Unlock successfully','success')
            delay(0.5,function()
                self:CheckRed()
            end)
        end
    end
end

function c:ClickUnlockRobuxBtn(id)
    local goods_id = mountCfg[id].goods_id
    local re = self:Invoke('buy_goods',goods_id)
    if re then
        ui_manager.ui_list.tips_gui:TipsMessage('Purchase successfully','success')
        self.parent.shop_cmp:PlayPurchaseSound()
    end
end

function c:ClickEquipBtn(id)
    if self.data.equiped == id then
        return
    end
    if self.data.equiped ~= 0 then
        ui_manager.ui_list.tips_gui:TipsMessage('You have already equipped a mount','fail')
        return
    end
    local re,mount = self:Invoke('equipMount',id)
    if re then
        self.mount = mount
        self.ui:SetItemEquipBtnVisible(id,false)
        self.ui:SetItemUnequipBtnVisible(id,true)
        self.data.equiped = id

        local bottom_att = hotpot:GetPath_Loop('HumanoidRootPart.bottom',mount)
        self.bottom_att = bottom_att

        ui_manager.ui_list.hud_gui:SetSkillMountBtnVisible(true)
        self.parent.character.sit_anima:Play()
    end
end

function c:ClickUnEquipBtn(id)
    if self.data.equiped ~= id then
        return
    end
    local re = self:Invoke('unEquipMount')
    if re then
        self.mount = nil
        self.bottom_att = nil
        self.ui:SetItemEquipBtnVisible(id,true)
        self.ui:SetItemUnequipBtnVisible(id,false)
        self.data.equiped = 0

        ui_manager.ui_list.hud_gui:SetSkillMountBtnVisible(false)
        self.parent.character.sit_anima:Stop()
    end
end

function c:UnlockMount(id)
    self.data.list[id] = {
        big = 0,
        small = 0,
    }
    self.ui:SetItemUnlockBtnVisible(id,false)
    self.ui:SetItemUnlockRobuxBtnVisible(id,false)
    self.ui:SetItemEquipBtnVisible(id,self.data.equiped ~= id)
    self.ui:SetItemUnequipBtnVisible(id,self.data.equiped == id)
end

function c:ClickRideBtn()
    -- if place_manager:GetIdByName('partysence') == game.PlaceId then
    --     return
    -- end
    if os.clock() - rideCold < 1 then
        return
    end
    rideCold = os.clock()
    if self.data.equiped == 0 then
        return
    end
    if self.mount then
        local re = self:Invoke('unrideMount')
        if re then
            self.mount = nil
            self.bottom_att = nil
            ui_manager.ui_list.hud_gui:SetSkillMountBtnIcon('rbxassetid://96546244262902')

            self.parent.character.sit_anima:Stop()
        end
    else
        local re,mount = self:Invoke('rideMount')
        if re then
            self.mount = mount
            self.bottom_att = hotpot:GetPath_Loop('HumanoidRootPart.bottom',mount)
            ui_manager.ui_list.hud_gui:SetSkillMountBtnIcon('rbxassetid://70590209664376')

            self.parent.character.sit_anima:Play()
        end
    end
end

function c:InForgeMount()
    ui_manager.ui_list.guild_forge_gui:RemoveAllItemInLeft()

    for k,v in pairs(self.data.list)do
        ui_manager.ui_list.guild_forge_gui:AddItemInLeft(
            k,
            mountCfg[k].icon,
            mountCfg[k].name,
            v.big or 0,
            v.small or 0,
            mountCfg[k].quality,
            1
        )
    end

    ui_manager.ui_list.guild_forge_gui:Show()
    ui_manager.ui_list.guild_forge_gui:SetTitle('Mount')

    self.parent.guild_in_mount = true
    self.parent.guild_in_relics = false
end

function c:ClickLeftItem(k)
    self.now_click = k
    local big = self.data.list[k].big or 0
    local small = self.data.list[k].small or 0
    if small == 10 then
        ui_manager.ui_list.tips_gui:TipsMessage('Forge Max!','fail')
        return
    end

    local big_str = ''
    local small_str = ''
    if small >= big then
        small_str = string.format('+%d<font color="rgb(0,255,0)">+1</font>',small)
        big_str = string.format('+%d<font color="rgb(0,255,0)">+1</font>',big)
    else
        small_str = string.format('+%d<font color="rgb(0,255,0)">+1</font>',small)
        big_str = string.format('+%d',big)
    end

    ui_manager.ui_list.guild_forge_gui:SetCenterLv(big_str,small_str)

    ui_manager.ui_list.guild_forge_gui:SetCenterRelics(
        mountCfg[k].icon,
        mountCfg[k].quality
    )

    local costforge = forgeCostCfg[small + 1].forgeStone
    local costGold = forgeCostCfg[small + 1].gold

    local stoneIdx = 0
    if small <= 3 then
        stoneIdx = 1
    elseif small <= 6 then
        stoneIdx = 2
    else
        stoneIdx = 3
    end

    local stoneNum = self.parent.guild_forge_cmp.data.forgeStone.list[stoneIdx] or 0
    -- print(stoneIdx,stoneNum)

    local stonestr = big_number:ToString(costforge) .. '/' .. big_number:ToString(stoneNum)
    local goldStr = big_number:ToString(costGold) .. '/' .. big_number:ToString(self.parent.prop_cmp:GetWins())

    ui_manager.ui_list.guild_forge_gui:SetCenterForgeStoneInfo(forgeStoneCfg[stoneIdx].icon,forgeStoneCfg[stoneIdx].quality)
    ui_manager.ui_list.guild_forge_gui:SetCenterForgeStoneNum(stonestr)
    ui_manager.ui_list.guild_forge_gui:SetCenterGemsNum(goldStr)
    ui_manager.ui_list.guild_forge_gui:SetCenterSuccessRate(string.format('Success rate <font color="rgb(0,255,0)">%s%%</font>',forgeCostCfg[small + 1].per))
end

function c:ClickForgeBtn()
    local id = self.now_click
    if not id then
        return
    end
    local small = self.data.list[id].small or 0
    local big = self.data.list[id].big or 0
    if small >= 10 then
        ui_manager.ui_list.tips_gui:TipsMessage('Forge Max!','fail')
        return
    end
    local costforge = forgeCostCfg[small + 1].forgeStone
    local stoneIdx = 0
    if small <= 3 then
        stoneIdx = 1
    elseif small <= 6 then
        stoneIdx = 2
    else
        stoneIdx = 3
    end
    local stoneNum = self.parent.guild_forge_cmp.data.forgeStone.list[stoneIdx] or 0
    if stoneNum < costforge then
        ui_manager.ui_list.tips_gui:TipsMessage('Not Enough Forge Stone','fail')
        return
    end
    local costGold = forgeCostCfg[small + 1].gold
    if self.parent.prop_cmp:GetWins() < costGold then
        ui_manager.ui_list.tips_gui:TipsMessage('Not Enough Coins','fail')
        return
    end
    local list = {}
    for i = 1,4 do
        local id = self.parent.guild_forge_cmp.centerSoltList[i]
        if id then
            list[id] = list[id] or 0
            list[id] = list[id] + 1
        end
    end
    ui_manager.ui_list.guild_forge_gui:PlayForgeAnimation()
    wait(1.5)
    local re,su = self:Invoke('forgeGuildMount',id,list)
    if re then
        if su then
            local oldBig = big
            pcall(function()
                audio_manager:PlayGloble('forgeSuc')
            end)
            ui_manager.ui_list.guild_forge_gui:PlayTips(true)
            if small == big then
                self.data.list[id].big = big + 1
            end
            self.data.list[id].small = small + 1

            local newBig = self.data.list[id].big
            if newBig > oldBig then
                local oldper = forgeCostCfg[oldBig] and forgeCostCfg[oldBig].big or 0
                local newper = forgeCostCfg[newBig] and forgeCostCfg[newBig].big or 0
                local spd = mountCfg[id].speed
                spd = spd * (1 + newper/100)
                local addSpd = spd * (newper - oldper)/100
                ui_manager.ui_list.guild_forge_gui:PlayValueTips(string.format('Speed +%.1f%%',addSpd))
            end

            self:ClickLeftItem(id)

            self:RefreshUi()
        else
            pcall(function()
                audio_manager:PlayGloble('forgeFai')
            end)
            ui_manager.ui_list.guild_forge_gui:PlayTips(false)
            self.data.list[id].small = 0
        end

        small = self.data.list[id].small or 0
        big = self.data.list[id].big or 0

        ui_manager.ui_list.guild_forge_gui:SetLeftItemLv(id,big,small)

        wait(.05)
        self.parent.guild_forge_cmp:ClearAll()
        self:ClickLeftItem(id)
    end
end

function c:MouseEnterItem(id)
    local tab = self.data.list[id]

    local big = 0
    local small = 0

    if tab then
        big = tab.big or 0
        small = tab.small or 0
    end

    local speed = mountCfg[id].speed

    if big > 0 then
        local per = forgeCostCfg[big].big
        speed = speed * (1 + per/100)
    end

    self.ui:SetTipsFrameInfo(
        mountCfg[id].name,
        big,
        small,
        speed
    )

    self.ui:SetTipsFrameVisible(true)
end

function c:RefreshUi()
    for id, tab in pairs(self.data.list)do
        local big = tab.big or 0
        local small = tab.small or 0
        local speed = mountCfg[id].speed
        if big > 0 then
            local per = forgeCostCfg[big].big
            speed = speed * (1 + per/100)
        end
        self.ui:SetItemSpeed(id,speed)
    end
end

c:RegistEvent('unlock_mount',c.UnlockMount)

return c