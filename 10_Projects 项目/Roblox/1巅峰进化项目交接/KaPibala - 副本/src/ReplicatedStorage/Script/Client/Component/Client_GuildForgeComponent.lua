local hotpot = _G.ClientHotpot
---@type UIManager
local ui_manager = hotpot.load.UIManager()
---@type BigNumberHelper
local big_number = hotpot.load.BigNumberHelper()
---@type Client_AudioManager
local audio_manager = hotpot.load.Client_AudioManager()
---@type PlaceManager
local place_manager = hotpot.load.PlaceManager()

local relics_cfg = hotpot.config.relics
local lyckyStone_cfg = hotpot.config.luckyStone
local forgeCostCfg = hotpot.config.forgeCost
local forgeStoneCfg = hotpot.config.forgeStone
local mountCfg = hotpot.config.mount
local PropList = {DMG = true,EXP = true,MaxHp = true,Speed = true}
local showStr = '%s:%s%%'
local forge_str = '<font color="rgb(85, 255, 127)">%s:%s%%(+%s%%)</font>'
local guild_forge_str = '<font color="rgb(54, 147, 246)">%s:%s%%(+%s%%)</font>'
local guild_str = '<font color="rgb(54, 147, 246)">%s:%s%%</font>'

---@class Client_GuildForgeComponent:Client_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Client_PlayerComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)

    self.data = self.parent.save_data:GetData('relics')
    self.ui = ui_manager.ui_list.guild_forge_gui
    self.ui:BindLeftItemClickHandle(self,self.ClickLeftItem)
    self.ui:BindRightItemClickHandle(self,self.ClickRightItem)
    self.ui:BindCenterSoltClickHandle(self,self.ClickCenterSolt)
    self.ui:BindForgeBtnClickHandle(self,self.ClickForgeBtn)
    self.ui:BindCloseBtnClickHandle(self,self.ClearAll)
    self.ui:BindMouseEnterItemHandle(self,self.MouseEnterItem)
    self.ui:BindCenterMouseEnterHandle(self,self.MouseEnterCenterItem)

    self:InitUi()

    self.centerSoltList = {}
end

function c:InitUi()
    local Str = 'Success rate +%s%%'
    for k,v in ipairs(lyckyStone_cfg)do
        self.ui:AddItemInRight(
            k,
            v.icon,
            v.quality,
            v.name,
            string.format(Str,v.per),
            self.data.luckyStone.list[v.id] or 0
        )
    end

    self.ui:SetCenterGemsNum(big_number:ToString(self.parent.prop_cmp:GetWins()))
    self.ui:SetCenterForgeStoneNum(big_number:ToString(self.data.forgeStone.list[1] or 0))
    self.ui:SetCenterLv(0,0)

    self.ui:SetCenterSuccessRate('Success rate <font color="rgb(0,255,0)">0%</font>')
    self.ui:SetCenterOtherRate('Additional success rate <font color="rgb(0,255,0)">0%</font>')

    self.ui:SetCenterForgeStoneInfo(forgeStoneCfg[1].icon,forgeStoneCfg[1].quality)

    -- if place_manager:GetIdByName('pvpsence') == game.PlaceId then
    -- end
    self:InForgeRelics(true)
end

function c:InForgeRelics(bool)
    ui_manager.ui_list.guild_forge_gui:RemoveAllItemInLeft()
    for inst_id,v in pairs(self.data.newlist)do
        local relicsId = v.relics_id
        self.ui:AddItemInLeft(
            inst_id,
            relics_cfg[relicsId].icon,
            relics_cfg[relicsId].name,
            v.big or 0,
            v.small or 0,
            relics_cfg[relicsId].quality,
            relics_cfg[relicsId].score
        )
    end
    ui_manager.ui_list.guild_forge_gui:SetTitle('Relics')
    if not bool then
        ui_manager.ui_list.guild_forge_gui:Show()
    end
    self.parent.guild_in_mount = false
    self.parent.guild_in_relics = true
end

function c:ChangeLuckyStoneNum(id,num)
    if (not self.data.luckyStone.list[id]) or (self.data.luckyStone.list[id] and self.data.luckyStone.list[id] == 0) then
        ui_manager.ui_list.bag_gui:AddItemInItemFrame(
            'luckyStone',
            id,
            lyckyStone_cfg[id].icon,
            lyckyStone_cfg[id].quality,
            num
        )
    else
        ui_manager.ui_list.bag_gui:SetItemFrameItemNum('luckyStone',id,num)
    end 
    self.data.luckyStone.list[id] = num
    self.ui:SetRightItemNum(id,num)

    if num == 0 then
        ui_manager.ui_list.bag_gui:DelItemFrameItem('luckyStone',id)
    end
end

--改变锻造石数量
function c:ChangeForgeStoneNum(idx,num)
    if (not self.data.forgeStone.list[idx]) or (self.data.forgeStone.list[idx] and self.data.forgeStone.list[idx] == 0) then
        ui_manager.ui_list.bag_gui:AddItemInItemFrame(
            'forgeStone',
            idx,
            forgeStoneCfg[idx].icon,
            forgeStoneCfg[idx].quality,
            num
        )
    else
        ui_manager.ui_list.bag_gui:SetItemFrameItemNum('forgeStone',idx,num)
    end 
    self.data.forgeStone.list[idx] = num

    if num == 0 then
        ui_manager.ui_list.bag_gui:DelItemFrameItem('forgeStone',idx)
    end
end

function c:ClickLeftItem(inst_id)
    self.now_click = inst_id
    if self.parent.guild_in_mount then
        self.parent.mount_cmp:ClickLeftItem(inst_id)
        return
    end
    local relicsId = self.data.newlist[inst_id].relics_id
    if not relicsId then
        return 
    end

    local big = self.data.newlist[inst_id].big or 0
    local small = self.data.newlist[inst_id].small or 0

    if small == 10 then
        ui_manager.ui_list.tips_gui:TipsMessage('Forge Max!','success')
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

    self.ui:SetCenterLv(big_str,small_str)

    self.ui:SetCenterRelics(
        relics_cfg[relicsId].icon,
        relics_cfg[relicsId].quality
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

    local stoneNum = self.data.forgeStone.list[stoneIdx] or 0
    -- print(stoneIdx,stoneNum)

    local stonestr = big_number:ToString(costforge) .. '/' .. big_number:ToString(stoneNum)
    local goldStr = big_number:ToString(costGold) .. '/' .. big_number:ToString(self.parent.prop_cmp:GetWins())

    self.ui:SetCenterForgeStoneInfo(forgeStoneCfg[stoneIdx].icon,forgeStoneCfg[stoneIdx].quality)
    self.ui:SetCenterForgeStoneNum(stonestr)
    self.ui:SetCenterGemsNum(goldStr)
    self.ui:SetCenterSuccessRate(string.format('Success rate <font color="rgb(0,255,0)">%s%%</font>',forgeCostCfg[small + 1].per))
end

function c:ClickRightItem(id)
    local num = self.data.luckyStone.list[id] or 0
    if num <= 0 then
        ui_manager.ui_list.tips_gui:TipsMessage('Not Enough','fail')
        return
    end
    self.useList = self.useList or {}
    local useNum = self.useList[id] or 0
    if useNum >= num then
        ui_manager.ui_list.tips_gui:TipsMessage('Not Enough','fail')
        return
    end

    local idx = nil
    for i = 1,4 do
        if not self.centerSoltList[i] then
            idx = i
            break
        end
    end
    if not idx then
        ui_manager.ui_list.tips_gui:TipsMessage('Select Full','fail')
        return
    end
    self.centerSoltList[idx] = id
    self.ui:SetCenterSoltInfo(
        idx,
        lyckyStone_cfg[id].icon,
        lyckyStone_cfg[id].quality
    )
    self:CalculateAddPer()
end

function c:ClickCenterSolt(pos)
    local id = self.centerSoltList[pos]
    if not id then
        return
    end
    self.centerSoltList[pos] = nil
    self.ui:SetCenterSoltInfo(
        pos,
        '',
        1
    )
    self:CalculateAddPer()
end

function c:CalculateAddPer()
    local addPer = 0
    self.useList = {}
    for i = 1,4 do
        local id = self.centerSoltList[i]
        if id then
            self.useList[id] = self.useList[id] or 0
            self.useList[id] = self.useList[id] + 1
            addPer = addPer + lyckyStone_cfg[id].per
        end
    end
    self.ui:SetCenterOtherRate(string.format('Additional success rate:<font color="rgb(0,255,0)">%s%%</font>',addPer))

    for k,v in ipairs(lyckyStone_cfg)do
        local now = self.data.luckyStone.list[v.id] or 0
        self.ui:SetRightItemNum(k,now - (self.useList[v.id] or 0))
    end
end

function c:ClearAll()
    self.useList = {}
    self.centerSoltList = {}
    self.ui:SetCenterGemsNum(big_number:ToString(self.parent.prop_cmp:GetWins()))
    self.ui:SetCenterForgeStoneNum(self.data.forgeStone.list[1] or 0)
    self.ui:SetCenterLv(0,0)
    self.ui:SetCenterForgeStoneInfo(forgeStoneCfg[1].icon,forgeStoneCfg[1].quality)

    self.ui:SetCenterSuccessRate('Success rate <font color="rgb(0,255,0)">0%</font>')
    self.ui:SetCenterOtherRate('Additional success rate <font color="rgb(0,255,0)">0%</font>')

    self.ui:SetCenterRelics('',1)
    for i = 1,4 do
        self.ui:SetCenterSoltInfo(
            i,
            '',
            1
        )
    end

    for k,v in ipairs(lyckyStone_cfg)do
        self.ui:SetRightItemNum(k,self.data.luckyStone.list[v.id] or 0)
    end

    -- self.now_click = nil
end

function c:ClickForgeBtn()
    if self.parent.guild_in_mount then
        self.parent.mount_cmp:ClickForgeBtn()
        return
    end
    if self.__click then
        return
    end
    self.__click = true
    local inst_id = self.now_click
    if not inst_id then
        self.__click = false
        return
    end
    local relicsId = self.data.newlist[inst_id].relics_id
    if not relicsId then
        self.__click = false
        return
    end

    local rCfg = relics_cfg[relicsId]
    if not rCfg.DMG then
        ui_manager.ui_list.tips_gui:TipsMessage('This relic cannot be forged.','fail')
        self.__click = false
        return
    end

    local small = self.data.newlist[inst_id].small or 0
    local big = self.data.newlist[inst_id].big or 0
    if small >= 10 then
        ui_manager.ui_list.tips_gui:TipsMessage('Forge Max!','fail')
        self.__click = false
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
    local stoneNum = self.data.forgeStone.list[stoneIdx] or 0
    if stoneNum < costforge then
        ui_manager.ui_list.tips_gui:TipsMessage('Not Enough Forge Stone','fail')
        self.__click = false
        return
    end
    local costGold = forgeCostCfg[small + 1].gold
    if self.parent.prop_cmp:GetWins() < costGold then
        ui_manager.ui_list.tips_gui:TipsMessage('Not Enough Coins','fail')
        self.__click = false
        return
    end
    local list = {}
    for i = 1,4 do
        local id = self.centerSoltList[i]
        if id then
            list[id] = list[id] or 0
            list[id] = list[id] + 1
        end
    end
    self.ui:PlayForgeAnimation()
    wait(1.5)
    local re,su,newBig,newSmall = self:Invoke('forgeGuildRelics',inst_id,list)
    if re then
        if su then
            local oldBig = big
            pcall(function()
                audio_manager:PlayGloble('forgeSuc')
            end)
            self.data.newlist[inst_id].big = newBig
            self.data.newlist[inst_id].small = newSmall

            if newBig > oldBig then
                local oldper = forgeCostCfg[oldBig] and forgeCostCfg[oldBig].big or 0
                local newper = forgeCostCfg[newBig] and forgeCostCfg[newBig].big or 0
                local dmg = relics_cfg[relicsId].DMG
                local addDmg = dmg * (newper - oldper)/100
                self.ui:PlayValueTips(string.format('DMG +%.1f%%',addDmg))
            end
            
            self.ui:PlayTips(true)
            self.parent.relics_cmp:RefreshUi()
        else
            pcall(function()
                audio_manager:PlayGloble('forgeFai')
            end)
            self.ui:PlayTips(false)
            self.data.newlist[inst_id].small = 0
        end

        small = self.data.newlist[inst_id].small or 0
        big = self.data.newlist[inst_id].big or 0

        self.ui:SetLeftItemLv(inst_id,big,small)

        wait(0.5)
        self:ClearAll()
        self.__click = false
        self:ClickLeftItem(inst_id)
    end

    self.__click = false
end

function c:RefreshRelicsTips(inst_id)
    local tab = self.data.newlist[inst_id]
    if not tab then
        return
    end
    local relics_id = tab.relics_id
    local forge = tab.forge
    local cfg = relics_cfg[relics_id]
    local list = {}
    local big = tab.big or 0
    local bigVal = forgeCostCfg[big] and (forgeCostCfg[big].big) or 0

    for key,_ in pairs(PropList)do
        if cfg[key] then
            if forge and key == forge.key then
                if key == 'DMG' and bigVal > 0 then
                    table.insert(list,string.format(guild_forge_str,key,cfg[key] * (1 + bigVal/100),forge.val))
                else
                    table.insert(list,string.format(forge_str,key,cfg[key],forge.val))
                end
            else
                if key == 'DMG' and bigVal > 0 then
                    table.insert(list,string.format(guild_str,key,cfg[key] * (1 + bigVal/100)))
                else
                    table.insert(list,string.format(showStr,key,cfg[key]))
                end
            end
        end
    end

    self.ui:SetRelicsTipsFrameInfo(cfg.name,list,cfg.quality,tab.big or 0,tab.small or 0)
    self.ui:SetRelicsTipsFrameVisible(true)
    self.ui:SetMountTipsFrameVisible(false)
end

function c:RefreshMountTips(id)
    local tab = self.parent.mount_cmp.data.list[id]

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

    self.ui:SetMountTipsFrameInfo(
        mountCfg[id].name,
        big,
        small,
        speed
    )

    self.ui:SetMountTipsFrameVisible(true)
    self.ui:SetRelicsTipsFrameVisible(false)
end

function c:MouseEnterItem(id)
    if self.parent.guild_in_relics then
        self:RefreshRelicsTips(id)
    elseif self.parent.guild_in_mount then
        self:RefreshMountTips(id)   
    end
end

function c:MouseEnterCenterItem()
    if self.parent.guild_in_relics then
        if self.now_click then
            local id = self.now_click
            self:RefreshRelicsTips(id)
        end
    elseif self.parent.guild_in_mount then
        if self.now_click then
            local id = self.now_click
            print(id,'*************')
            self:RefreshMountTips(id)
        end
    end
end

c:RegistEvent('changeLuckyStone',c.ChangeLuckyStoneNum)
c:RegistEvent('changeForgeStone',c.ChangeForgeStoneNum)

return c
