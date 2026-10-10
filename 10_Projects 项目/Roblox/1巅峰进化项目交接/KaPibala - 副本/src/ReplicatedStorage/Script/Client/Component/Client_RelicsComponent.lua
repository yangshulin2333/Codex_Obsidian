local hotpot = _G.ClientHotpot
---@type UIManager
local ui_manager = hotpot.load.UIManager()
---@type BigNumberHelper
local big_number = hotpot.load.BigNumberHelper()

local PropList_Order = {'DMG','EXP','MaxHp','Speed'}
local PropList = {DMG = true,EXP = true,MaxHp = true,Speed = true}
local relics_cfg = hotpot.config.relics
local box_cd = hotpot.pro_cfg.relice_box_cd
local prop_cfg = hotpot.config.prop
local showStr = '%s:%d%%'
local forge_str = '<font color="rgb(85, 255, 127)">%s:%d%%(+%d%%)</font>'
local guild_forge_str = '<font color="rgb(54, 147, 246)">%s:%d%%(+%d%%)</font>'
local guild_str = '<font color="rgb(54, 147, 246)">%s:%d%%</font>'
local unlockGoodsIds = {[4] = 69,[5] = 70,[6] = 71}
local scroll_cfg = hotpot.config.relicsScorll
local forgeCostCfg = hotpot.config.forgeCost
local forgeStoneCfg = hotpot.config.forgeStone
local luckyStoneCfg = hotpot.config.luckyStone
local suitCfg = hotpot.config.suit

---@class Client_RelicsComponent:Client_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Client_PlayerComponent())
function c.new(parent)
    return c(parent)
end

function c:ctor(parent)
    c.super.ctor(self,parent)

    self.data = self.parent.save_data:GetData('relics')
    self.ui = ui_manager.ui_list.relics_gui
    self.ui:BindItemMouseEnter(self,self.MouseEnterItem)
    self.ui:BindSoltMouseEnter(self,self.MouseEnterSolt)
    self.ui:BindItemClickHandle(self,self.ClickItem)
    self.ui:BindSoltClickHandle(self,self.ClickSolt)
    -- self.ui:BindUnlockAllBtnClickHandle(self,self.ClickUnlockAllBtn)
    self.ui:BindSoltUnlockBtnClickHandle(self,self.ClickUnlockSolt)

    ui_manager.ui_list.forge_relics_gui:BindRelicsItemClickHandle(self,self.ClickRelicsItem)
    ui_manager.ui_list.forge_relics_gui:BindScrollsItemClickHandle(self,self.ClickScrollItem)
    ui_manager.ui_list.forge_relics_gui:BindAddRelicsBtnClickHandle(self,self.ClickLeftRelicsBtn)
    ui_manager.ui_list.forge_relics_gui:BindAddScrollsBtnClickHandle(self,self.ClickLeftScrollBtn)
    ui_manager.ui_list.forge_relics_gui:BindForgeBtnClickHandle(self,self.ClickForgeBtn)
    ui_manager.ui_list.forge_relics_gui:BindSureBtnClickHandle(self,self.ClickSureBtn)
    ui_manager.ui_list.forge_relics_gui:BindCloseUiHandle(self,self.RefreshForgeGui)
    ui_manager.ui_list.forge_relics_gui:BindItemMouseEnter(self,self.MouseEnterForgeItem)
    ui_manager.ui_list.forge_relics_gui:BindScrollMouseEnter(self,self.MouseEnterScrollItem)

    ui_manager.ui_list.relics_smelter_gui:BindHideHandle(self,self.ClearSmeltGui)
    ui_manager.ui_list.relics_smelter_gui:BindLeftItemClickHandle(self,self.ClickSmeltLeftItem)
    ui_manager.ui_list.relics_smelter_gui:BindSmeltBtnClickHandle(self,self.ClickSmeltBtn)
    ui_manager.ui_list.relics_smelter_gui:BindRightItemClickHandle(self,self.ClickSmeltRightItem)
    ui_manager.ui_list.relics_smelter_gui:BindItemMouseEnter(self,self.MouseEnterSmeltItem)
    ui_manager.ui_list.relics_smelter_gui:BindDarkScrollBtnClickHandle(self,self.ClickDarkScrollBtn)

    ui_manager.ui_list.transfer_gui:BindSolt1ClickHandle(self,self.ClickTransferSolt1)
    ui_manager.ui_list.transfer_gui:BindSolt2ClickHandle(self,self.ClickTransferSolt2)
    ui_manager.ui_list.transfer_gui:BindItemClickHandle(self,self.ClickTransferItem)
    ui_manager.ui_list.transfer_gui:BindTransferClickHandle(self,self.ClickTransferBtn)
    ui_manager.ui_list.transfer_gui:MouseEnterItem(self,self.MouseEnterTransferItem)

    self:InitUi()
    self:InitBag()

    self.smelt_list = {}
end

function c:InitUi()
    for inst_id,v in pairs(self.data.newlist)do
        local id = v.relics_id
        local cfg = relics_cfg[id]
        self.ui:AddItemInFrame(
            inst_id,
            cfg.icon,
            self:GetScore(inst_id),
            cfg.quality,
            v.big or 0
        )
        self.ui:SetItemVisible(inst_id,not v.equip)

        ui_manager.ui_list.forge_relics_gui:AddItemInRelics(
            inst_id,
            cfg.icon,
            self:GetScore(inst_id),
            cfg.quality
        )

        ui_manager.ui_list.relics_smelter_gui:AddItemInRightScroll(
            inst_id,
            cfg.icon,
            cfg.quality,
            self:GetScore(inst_id)
        )

        ui_manager.ui_list.transfer_gui:AddItemInScroll(
            inst_id,
            cfg.icon,
            self:GetScore(inst_id),
            cfg.quality,
            v.big or 0
        )
    end

    for pos,tab in ipairs(self.data.equiped)do
        local state,relics_id
        if tab.unlock == false then
            if tab.buy == false then
                state = 4
            else
                state = 3
            end
        else
            if tab.inst_id then
                relics_id = self.data.newlist[tab.inst_id].relics_id
                state = 2
            else
                state = 1
            end
        end
        local infos = {}
        if relics_id then
            infos.icon = relics_cfg[relics_id].icon
            infos.value = relics_cfg[relics_id].atk
            infos.score = relics_cfg[relics_id].score
            infos.quality = relics_cfg[relics_id].quality
            infos.big = self.data.newlist[tab.inst_id].big or 0
        end
        self.ui:SetSoltInfo(
            pos,
            state,
            infos
        )
    end

    self:StartUpdate()

    local data = self.parent.save_data:GetData('pay').pay_list
    self.ui:SetUnlockAllBtnVisible(false)

    self:CheckRed()

    for id,num in pairs(self.data.scrolls)do
        if num > 0 then
            ui_manager.ui_list.forge_relics_gui:AddItemInScrolls(
                id,
                scroll_cfg[id].icon,
                scroll_cfg[id].quality
            )
            ui_manager.ui_list.forge_relics_gui:SetScrollsItemNum(id,num)
        end
    end

    ui_manager.ui_list.relics_smelter_gui:SetTotalCoinsNum(self.data.smelt_coin)
end

function c:InitBag()
    local stone = self.data.forgeStone.list
    for id,num in pairs(stone)do
        if num > 0 then
            ui_manager.ui_list.bag_gui:AddItemInItemFrame(
                'forgeStone',
                id,
                forgeStoneCfg[id].icon,
                forgeStoneCfg[id].quality,
                num
            )
        end
    end

    local luckyStone = self.data.luckyStone.list
    for id,num in pairs(luckyStone)do
        if num > 0 then
            ui_manager.ui_list.bag_gui:AddItemInItemFrame(
                'luckyStone',
                id,
                luckyStoneCfg[id].icon,
                luckyStoneCfg[id].quality,
                num
            )
        end
    end
end

function c:CheckRed()
    local red = false
    local isEmpty = false--是否有空位
    local isFree = false--是否有闲置遗物
    for k,v in ipairs(self.data.equiped)do
        if v.unlock == true and not v.inst_id then
            isEmpty = true
            break
        end
    end

    for k,v in pairs(self.data.newlist)do
        if not v.equip then
            isFree = true
            break
        end
    end

    red = isEmpty and isFree

    ui_manager.ui_list.hud_gui:SetRelicsRedVisible(red)
end

function c:RefreshUi()
    for inst_id,v in pairs(self.data.newlist)do
        local big = v.big or 0
        self.ui:SetItemBig(inst_id,big)
    end
    for pos,tab in ipairs(self.data.equiped)do
        local inst_id = tab.inst_id
        if inst_id then
            local tab = self.data.newlist[inst_id]
            self.ui:SetSoltBig(pos,tab.big or 0)
        end
    end
end

function c:AddRelics(relics_id,inst_id)
    self.data.newlist[inst_id] = {relics_id = relics_id,big = 0,small = 0}
    
    local cfg = relics_cfg[relics_id]

    self.ui:AddItemInFrame(
        inst_id,
        cfg.icon,
        self:GetScore(inst_id),
        cfg.quality,
        0
    )
    ui_manager.ui_list.forge_relics_gui:AddItemInRelics(
        inst_id,
        cfg.icon,
        self:GetScore(inst_id),
        cfg.quality
    )
    ui_manager.ui_list.relics_smelter_gui:AddItemInRightScroll(
        inst_id,
        cfg.icon,
        cfg.quality,
        self:GetScore(inst_id)
    )
    ui_manager.ui_list.guild_forge_gui:AddItemInLeft(
        inst_id,
        cfg.icon,
        cfg.name,
        0,
        0,
        cfg.quality,
        cfg.score
    )
    ui_manager.ui_list.transfer_gui:AddItemInScroll(
        inst_id,
        cfg.icon,
        self:GetScore(inst_id),
        cfg.quality,
        0
    )

    self:CheckRed()
end

function c:AddRelicsByStar(relics_id,inst_id,big,small)
    self.data.newlist[inst_id] = {relics_id = relics_id,big = big,small = small}
    
    local cfg = relics_cfg[relics_id]

    self.ui:AddItemInFrame(
        inst_id,
        cfg.icon,
        self:GetScore(inst_id),
        cfg.quality,
        0
    )
    ui_manager.ui_list.forge_relics_gui:AddItemInRelics(
        inst_id,
        cfg.icon,
        self:GetScore(inst_id),
        cfg.quality
    )
    ui_manager.ui_list.relics_smelter_gui:AddItemInRightScroll(
        inst_id,
        cfg.icon,
        cfg.quality,
        self:GetScore(inst_id)
    )
    ui_manager.ui_list.guild_forge_gui:AddItemInLeft(
        inst_id,
        cfg.icon,
        cfg.name,
        big,
        small,
        cfg.quality,
        cfg.score
    )
    ui_manager.ui_list.transfer_gui:AddItemInScroll(
        inst_id,
        cfg.icon,
        self:GetScore(inst_id),
        cfg.quality,
        big
    )

    self:CheckRed()
    self:RefreshUi()
end

function c:DelRelics(inst_id)
    self.data.newlist[inst_id] = nil
    ui_manager.ui_list.forge_relics_gui:DelItem(inst_id)
    ui_manager.ui_list.relics_smelter_gui:DelRightItem(inst_id)
    ui_manager.ui_list.relics_smelter_gui:DelLeftItem(inst_id)
    ui_manager.ui_list.guild_forge_gui:RemoveItemInLeft(inst_id)
    self.ui:DelItem(inst_id)
end

--计算评分
function c:GetScore(inst_id)
    local tab = self.data.newlist[inst_id]
    if not tab then
        return 0
    end
    local relics_id = tab.relics_id
    local forge = tab.forge
    local cfg = relics_cfg[relics_id]
    local score = cfg.score
    if forge then
        score = score + forge.val
    end
    return score
end

--玩家进入ReliceBox
function c:PlayerInReliceBox(part)
    local data = self.data.box.mark
    local now = workspace:GetServerTimeNow()

    if now < data + box_cd then
        ui_manager.ui_list.tips_gui:TipsMessage('It can be claimed only after the countdown ends!','fail')
        return
    end
    local re = self:Invoke('get_relics_box')
    if re then
        ui_manager.ui_list.tips_gui:TipsMessage('Claimed success!','success')
        self.data.box.mark = now
        self:StartUpdate()
        local stage = self.parent.stage_cmp.now_stage
        if stage then
            stage:SetReliceBoxGetVisible(false)
        end
    end
end

--开始倒计时
function c:StartUpdate()
    if self.__update_co then
        return
    end
    self.__update_co = self:AddUpdate(self.Update,1)
end

--结束倒计时
function c:StopUpdate()
    if self.__update_co then
        self.__update_co:Disconnect()
        self.__update_co = nil
    end
end

--更新倒计时
function c:Update()
    local now = workspace:GetServerTimeNow()
    local next_time = self.data.box.mark + box_cd
    local sub = next_time - now
    local stage = self.parent.stage_cmp.now_stage
    -- print(sub)
    if sub >= 0 then
        if stage then
            stage:SetReliceBoxCD(sub)
            stage:SetReliceBoxGetVisible(false)
        end
    else
        self:StopUpdate()
        if stage then
            stage:SetReliceBoxGetVisible(true)
        end
    end
end

--鼠标进入item
function c:MouseEnterItem(inst_id)
    local tab = self.data.newlist[inst_id]
    if not tab then
        return
    end
    local relics_id = tab.relics_id

    self:CheckSuit(relics_id)

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
                    if key == 'MaxHp' then
                        table.insert(list,string.format(forge_str,'HP',cfg[key],forge.val))
                    else
                        table.insert(list,string.format(forge_str,key,cfg[key],forge.val))
                    end
                end
            else
                if key == 'DMG' and bigVal > 0 then
                    table.insert(list,string.format(guild_str,key,cfg[key] * (1 + bigVal/100)))
                else
                    if key == 'MaxHp' then
                        table.insert(list,string.format(showStr,'HP',cfg[key]))
                    else
                        table.insert(list,string.format(showStr,key,cfg[key]))
                    end
                end
            end
        end
    end

    self.ui:SetTipsInfo(cfg.name,list,cfg.quality,tab.big or 0,tab.small or 0)
    self.ui:SetTipsFrameVisible(true)
end

--鼠标进入solt
function c:MouseEnterSolt(idx)
    local tab = self.data.equiped[idx]

    local inst_id = tab.inst_id

    if not inst_id then
        return
    end

    if not self.data.newlist[inst_id] then
        return
    end

    local tab = self.data.newlist[inst_id]
    if not tab then
        return
    end
    local relics_id = tab.relics_id

    self:CheckSuit(relics_id)

    local forge = tab.forge
    local cfg = relics_cfg[relics_id]
    local big = tab.big or 0
    local bigVal = forgeCostCfg[big] and (forgeCostCfg[big].big) or 0
    
    local list = {}
    for key,_ in pairs(PropList)do
        if cfg[key] then
            if forge and key == forge.key then
                if key == 'DMG' and bigVal > 0 then
                    table.insert(list,string.format(guild_forge_str,key,cfg[key] * (1 + bigVal/100),forge.val))
                else
                    if key == 'MaxHp' then
                        table.insert(list,string.format(forge_str,'HP',cfg[key],forge.val))
                    else
                        table.insert(list,string.format(forge_str,key,cfg[key],forge.val))
                    end
                end
            else
                if key == 'DMG' and bigVal > 0 then
                    table.insert(list,string.format(guild_str,key,cfg[key] * (1 + bigVal/100)))
                else
                    if key == 'MaxHp' then
                        table.insert(list,string.format(showStr,'HP',cfg[key]))
                    else
                        table.insert(list,string.format(showStr,key,cfg[key]))
                    end
                end
            end
        end
    end

    self.ui:SetTipsInfo(cfg.name,list,cfg.quality,tab.big or 0,tab.small or 0)
    self.ui:SetTipsFrameVisible(true)
end

--检查套装
function c:CheckSuit(relics_id)
    local cfg = relics_cfg[relics_id]
    if not cfg then
        self.ui:SetSuitFrameVisible(false)
        return
    end
    if not cfg.suit then
        self.ui:SetSuitFrameVisible(false)
        return
    end

    local sCfg = suitCfg[cfg.suit]

    local info = {}

    local activeNum = 0
    info.suitNameList = {}
    for k,rId in ipairs(sCfg.relics_id)do
        local isEquiped = false
        local name = relics_cfg[rId].name
        --检查是否已装备
        for _,v in ipairs(self.data.equiped)do
            local instId = v.inst_id
            if instId then
                local data = self.data.newlist[instId]
                if rId == data.relics_id then
                    isEquiped = true
                    activeNum = activeNum + 1
                    break
                end
            end
        end
        info.suitNameList[name] = isEquiped
    end

    info.title = sCfg.name..string.format('(%d/%d)',activeNum,sCfg.max)

    info.suitScroll = {}
    local set2 = sCfg.set2
    if set2 then
        table.insert(info.suitScroll,{
            is_title = true,
            text = '(2) Set',
            active = activeNum >= 2,
        })
        table.insert(info.suitScroll,{
            text = string.format('%s+%s%%',set2.prop,set2.value),
            active = activeNum >= 2,
        })
    end

    local set4 = sCfg.set4
    if set4 then
        table.insert(info.suitScroll,{
            is_title = true,
            text = '(4) Set',
            active = activeNum >= 4,
        })
        table.insert(info.suitScroll,{
            text = string.format('%s+%s%%',set4.prop,set4.value),
            active = activeNum >= 4,
        })
    end

    local set6 = sCfg.set6
    if set6 then
        table.insert(info.suitScroll,{
            is_title = true,
            text = '(6) Set',
            active = activeNum >= 6,
        })
        table.insert(info.suitScroll,{
            text = string.format('%s+%s%%',set6.prop,set6.value),
            active = activeNum >= 6,
        })
    end
    self.ui:SetSuitFrameInfo(info)
    self.ui:SetSuitFrameVisible(true)
end

--点击item
function c:ClickItem(inst_id)
    local empty
    for k,v in ipairs(self.data.equiped)do
        if v.unlock then
            if not v.inst_id then
                empty = k
                break
            end
        end
    end
    if not empty then
        ui_manager.ui_list.tips_gui:TipsMessage('The slot is full!','fail')
        return
    end

    local re = self:Invoke('equip_relics',inst_id,empty)
    if re then
        self.data.equiped[empty].inst_id = inst_id
        self.data.newlist[inst_id].equip = true
        self.ui:SetItemVisible(inst_id,false)
        local relics_id = self.data.newlist[inst_id].relics_id
        local cfg = relics_cfg[relics_id]
        self.ui:SetSoltInfo(empty,2,{
            icon = cfg.icon,
            value = cfg.atk,
            score = self:GetScore(inst_id),
            quality = cfg.quality,
            big = self.data.newlist[inst_id].big or 0,
        })
        self:CheckRed()
    end
end

--点击solt
function c:ClickSolt(idx)
    local re,inst_id = self:Invoke('unequip_relics',idx)
    if re then
        self.data.equiped[idx].inst_id = nil
        self.data.newlist[inst_id].equip = false
        self.ui:SetItemVisible(inst_id,true)
        self.ui:SetSoltInfo(idx,1)
        self:CheckRed()
    end
end

--点击解锁全部按钮
function c:ClickUnlockAllBtn()
    local data = self.parent.save_data:GetData('pay').pay_list
    if data[63] then
        return
    end
    local re = self:Invoke('buy_goods',63)
    if re then
        self.parent.shop_cmp:PlayPurchaseSound()
        ui_manager.ui_list.tips_gui:TipsMessage('Purchase successfully','success')
        data[63] = true
        self.ui:SetUnlockAllBtnVisible(false)

        self.data.equiped[4].unlock = true
        self.data.equiped[5].unlock = true
        self.data.equiped[6].unlock = true

        self.ui:SetSoltInfo(4,1)
        self.ui:SetSoltInfo(5,1)
        self.ui:SetSoltInfo(6,1)
    end
end

--点击解锁solt
function c:ClickUnlockSolt(idx)
    if self.data.equiped[idx].unlock then
        return
    end
    local re = self:Invoke('buy_goods',unlockGoodsIds[idx])
    if re then
        self.data.equiped[idx].unlock = true
        self.ui:SetSoltInfo(idx,1)
        ui_manager.ui_list.tips_gui:TipsMessage('Purchase successfully','success')
    end
end

--解锁solt
function c:UnlockSolt(idx)
    self.data.equiped[idx].unlock = true
    self.ui:SetSoltInfo(idx,1)
end

function c:CodeUnlockSolt(idx)
    self.data.equiped[idx].unlock = true
    self.ui:SetSoltInfo(idx,1)
end

--增加卷轴
function c:AddScroll(id,num)
    local old_num = self.data.scrolls[id]
    self.data.scrolls[id] = (self.data.scrolls[id] or 0) + num

    if not old_num or old_num == 0 then
        ui_manager.ui_list.forge_relics_gui:AddItemInScrolls(
            id,
            scroll_cfg[id].icon,
            scroll_cfg[id].quality
        )
    end
    
    ui_manager.ui_list.forge_relics_gui:SetScrollsItemNum(id,self.data.scrolls[id])
end

--使用卷轴
function c:UseScroll(id,num)
    self.data.scrolls[id] = self.data.scrolls[id] - num
end

--增加分解币
function c:AddSmeltCoin(num)
    self.data.smelt_coin = self.data.smelt_coin + num
    ui_manager.ui_list.relics_smelter_gui:SetTotalCoinsNum(self.data.smelt_coin)
end

--使用分解币
function c:UseSmeltCoin(num)
    self.data.smelt_coin = self.data.smelt_coin - num
    ui_manager.ui_list.relics_smelter_gui:SetTotalCoinsNum(self.data.smelt_coin)
end

--获取分解币
function c:GetSmeltCoin()
    return self.data.smelt_coin
end

--鼠标进入合成界面item
function c:MouseEnterForgeItem(inst_id)
    local tab = self.data.newlist[inst_id]
    if not tab then
        return
    end
    local relics_id = tab.relics_id
    local forge = tab.forge
    local cfg = relics_cfg[relics_id]
    local list = {}

    for key,_ in pairs(PropList)do
        if cfg[key] then
            if forge and key == forge.key then
                table.insert(list,string.format(forge_str,key,cfg[key],forge.val))
            else
                if key == 'MaxHp' then
                    table.insert(list,string.format(showStr,'HP',cfg[key]))
                else
                    table.insert(list,string.format(showStr,key,cfg[key]))
                end
            end
        end
    end

    ui_manager.ui_list.forge_relics_gui:SetTipsInfo(cfg.name,list,cfg.quality,tab.big or 0,tab.small or 0)
    ui_manager.ui_list.forge_relics_gui:SetTipsFrameVisible(true)
end

--鼠标进入合成界面卷轴
function c:MouseEnterScrollItem(id)
    local cfg = scroll_cfg[id]
    ui_manager.ui_list.forge_relics_gui:SetTips1Info(cfg.name,cfg.desc)
    ui_manager.ui_list.forge_relics_gui:SetTips1FrameVisible(true)
end

--刷新合成界面
function c:RefreshForgeGui()
    if self.forge_select_relics_id then
        ui_manager.ui_list.forge_relics_gui:SetRelicsItemVisible(self.forge_select_relics_id,true)
    end
    ui_manager.ui_list.forge_relics_gui:ClearLeftScrollsInfo()
    ui_manager.ui_list.forge_relics_gui:ClearLeftRelicsInfo()
    self.forge_select_scroll_id = nil
    self.forge_select_relics_id = nil
    for id,num in pairs(self.data.scrolls)do
        ui_manager.ui_list.forge_relics_gui:SetScrollsItemNum(id,num)
        ui_manager.ui_list.forge_relics_gui:SetScrollsItemVisible(id,num > 0)
    end
end

--点击合成界面遗物子项
function c:ClickRelicsItem(inst_id)
    local select_id = self.forge_select_relics_id 
    local relics_id = self.data.newlist[inst_id].relics_id
    if select_id then--左侧已有
        ui_manager.ui_list.forge_relics_gui:SetRelicsItemVisible(select_id,true)
        ui_manager.ui_list.forge_relics_gui:SetRelicsItemVisible(inst_id,false)
        ui_manager.ui_list.forge_relics_gui:SetLeftRelicsInfo(relics_cfg[relics_id].icon,relics_cfg[relics_id].quality)
    else--左侧无
        ui_manager.ui_list.forge_relics_gui:SetRelicsItemVisible(inst_id,false)
        ui_manager.ui_list.forge_relics_gui:SetLeftRelicsInfo(relics_cfg[relics_id].icon,relics_cfg[relics_id].quality)
    end
    self.forge_select_relics_id = inst_id
end

--点击合成界面卷轴子项
function c:ClickScrollItem(id)
    local select_id = self.forge_select_scroll_id

    if select_id then--左侧已有
        local old_num = self.data.scrolls[select_id] or 0
        ui_manager.ui_list.forge_relics_gui:SetScrollsItemVisible(select_id,true)
        ui_manager.ui_list.forge_relics_gui:SetScrollsItemNum(select_id,old_num)

        local num = self.data.scrolls[id] or 0
        num = num - 1
        ui_manager.ui_list.forge_relics_gui:SetLeftScrollsInfo(scroll_cfg[id].icon,scroll_cfg[id].quality)
        if num == 0 then
            ui_manager.ui_list.forge_relics_gui:SetScrollsItemVisible(id,false)
        else
            ui_manager.ui_list.forge_relics_gui:SetScrollsItemNum(id,num)
        end
    else--左侧无
        local num = self.data.scrolls[id] or 0
        num = num - 1
        ui_manager.ui_list.forge_relics_gui:SetLeftScrollsInfo(scroll_cfg[id].icon,scroll_cfg[id].quality)
        if num == 0 then
            ui_manager.ui_list.forge_relics_gui:SetScrollsItemVisible(id,false)
        else
            ui_manager.ui_list.forge_relics_gui:SetScrollsItemNum(id,num)
        end
    end
    self.forge_select_scroll_id = id
    ui_manager.ui_list.forge_relics_gui:SetTips1FrameVisible(false)
end

--点击左侧遗物按钮
function c:ClickLeftRelicsBtn()
    local select_id = self.forge_select_relics_id 
    if select_id then
        ui_manager.ui_list.forge_relics_gui:SetRelicsItemVisible(select_id,true)
        self.forge_select_relics_id = nil
        ui_manager.ui_list.forge_relics_gui:ClearLeftRelicsInfo()
    else
        ui_manager.ui_list.forge_relics_gui:SetRelicsScrollingFrameVisible(true)
        ui_manager.ui_list.forge_relics_gui:SetScrollsScrollingFrameVisible(false)
    end
    self.forge_select_scroll_id = nil
end

--点击左侧卷轴按钮
function c:ClickLeftScrollBtn()
    local select_id = self.forge_select_scroll_id 
    if select_id then
        ui_manager.ui_list.forge_relics_gui:SetScrollsItemVisible(select_id,true)
        ui_manager.ui_list.forge_relics_gui:ClearLeftScrollsInfo()
        ui_manager.ui_list.forge_relics_gui:SetScrollsItemNum(select_id,self.data.scrolls[select_id] or 0)
    else
        ui_manager.ui_list.forge_relics_gui:SetScrollsScrollingFrameVisible(true)
        ui_manager.ui_list.forge_relics_gui:SetRelicsScrollingFrameVisible(false)
    end
    self.forge_select_scroll_id = nil
end

--点击合成按钮
function c:ClickForgeBtn()
    local inst_id = self.forge_select_relics_id
    if not inst_id then
        return
    end
    local scroll_id = self.forge_select_scroll_id
    if not scroll_id then
        return
    end

    local tab = self.data.newlist[inst_id]
    if not tab then
        return
    end
    local forge = tab.forge
    if forge then
        ui_manager.ui_list.forge_relics_gui:SetLeftTopVisible(true)
        return
    end

    local re,random = self:Invoke('forge_relics',inst_id,scroll_id)
    if re then
        local list = {}
        local relics_id = tab.relics_id
        local cfg = relics_cfg[relics_id]
        for idx,key in ipairs(PropList_Order)do
            if cfg[key] then
                table.insert(list,{key = key,val = cfg[key]})
            end
        end
        ui_manager.ui_list.tips_gui:TipsMessage('Forge successfully','success')
        self.data.newlist[inst_id].forge = {
            idx = random,
            key = list[random].key,
            val = scroll_cfg[scroll_id].add,
        }

        self.ui:SetItemScore(inst_id,self:GetScore(inst_id))
        ui_manager.ui_list.forge_relics_gui:SetItemScore(inst_id,self:GetScore(inst_id))
        ui_manager.ui_list.relics_smelter_gui:SetRightItemScore(inst_id,self:GetScore(inst_id))

        wait(.5)
        self:RefreshForgeGui()
    end
end

--点击确定合成按钮
function c:ClickSureBtn()
    local inst_id = self.forge_select_relics_id
    if not inst_id then
        return
    end
    local scroll_id = self.forge_select_scroll_id
    if not scroll_id then
        return
    end
    local tab = self.data.newlist[inst_id]
    if not tab then
        return
    end
    local re,random = self:Invoke('forge_relics',inst_id,scroll_id)
    if re then
        ui_manager.ui_list.forge_relics_gui:SetLeftTopVisible(false)
        local list = {}
        local relics_id = tab.relics_id
        local cfg = relics_cfg[relics_id]
        for idx,key in ipairs(PropList_Order)do
            if cfg[key] then
                table.insert(list,{key = key,val = cfg[key]})
            end
        end
        ui_manager.ui_list.tips_gui:TipsMessage('Forge successfully','success')
        self.data.newlist[inst_id].forge = {
            idx = random,
            key = list[random].key,
            val = scroll_cfg[scroll_id].add,
        }

        wait(.5)
        self:RefreshForgeGui()
    end
end

--点击分解界面右侧item
function c:ClickSmeltRightItem(inst_id)
    local tab = self.data.newlist[inst_id]
    if not tab then
        return
    end
    if tab.equip then
        ui_manager.ui_list.tips_gui:TipsMessage('Equipped relics cannot be smelted','fail')
        return
    end

    local relics_id = tab.relics_id
    local cfg = relics_cfg[relics_id]
    ui_manager.ui_list.relics_smelter_gui:SetRightItemVisible(inst_id,false)
    ui_manager.ui_list.relics_smelter_gui:AddItemInLeftScroll(
        inst_id,    
        cfg.icon,
        cfg.quality,
        self:GetScore(inst_id)
    )
    self.smelt_list[inst_id] = true
    self:RefreshSmeltCoin()
    ui_manager.ui_list.relics_smelter_gui:SetTipsFrameVisible(false)
end

--点击分解界面左侧item
function c:ClickSmeltLeftItem(inst_id)
    ui_manager.ui_list.relics_smelter_gui:SetRightItemVisible(inst_id,true)
    ui_manager.ui_list.relics_smelter_gui:DelLeftItem(inst_id)
    self.smelt_list[inst_id] = nil
    self:RefreshSmeltCoin()
    ui_manager.ui_list.relics_smelter_gui:SetTipsFrameVisible(false)
end

--刷新分解界面分解币的数量
function c:RefreshSmeltCoin()
    local coin = 0
    for inst_id,val in pairs(self.smelt_list)do
        if val then
            coin = coin + self:GetScore(inst_id)
        end
    end
    ui_manager.ui_list.relics_smelter_gui:SetSmeltCoinNum(coin)
end

--点击分解按钮
function c:ClickSmeltBtn()
    if not next(self.smelt_list) then
        -- ui_manager.ui_list.tips_gui:TipsMessage('Please select the relics to smelt','fail')
        return
    end
    local re = self:Invoke('smelt_relics',self.smelt_list)
    if re then
        ui_manager.ui_list.tips_gui:TipsMessage('Smelt successfully','success')
        ui_manager.ui_list.relics_smelter_gui:SetSmeltCoinNum(0)
        self.smelt_list = {}
    end
end

--清除分解界面
function c:ClearSmeltGui()
    ui_manager.ui_list.relics_smelter_gui:SetSmeltCoinNum(0)
    for inst_id,val in pairs(self.smelt_list)do
        if val then
            ui_manager.ui_list.relics_smelter_gui:SetRightItemVisible(inst_id,true)
            ui_manager.ui_list.relics_smelter_gui:DelLeftItem(inst_id)
        end
    end
    self.smelt_list = {}
end

--鼠标进入分解界面item
function c:MouseEnterSmeltItem(inst_id)
    local tab = self.data.newlist[inst_id]
    if not tab then
        return
    end
    local relics_id = tab.relics_id
    local forge = tab.forge
    local cfg = relics_cfg[relics_id]
    local list = {}

    for key,_ in pairs(PropList)do
        if cfg[key] then
            if forge and key == forge.key then
                table.insert(list,string.format(forge_str,key,cfg[key],forge.val))
            else
                if key == 'MaxHp' then
                    table.insert(list,string.format(showStr,'HP',cfg[key]))
                else
                    table.insert(list,string.format(showStr,key,cfg[key]))
                end
            end
        end
    end

    ui_manager.ui_list.relics_smelter_gui:SetTipsInfo(cfg.name,list,cfg.quality,tab.big or 0,tab.small or 0)
    ui_manager.ui_list.relics_smelter_gui:SetTipsFrameVisible(true)
end

--点击购买超级卷轴
function c:ClickDarkScrollBtn()
    local re = self:Invoke('buy_goods',72)
    if re then
        ui_manager.ui_list.tips_gui:TipsMessage('Purchase successful','success')
    end
end

--点击转移界面的solt1
function c:ClickTransferSolt1()
    --big>0
    for inst_id,tab in pairs(self.data.newlist)do
        local big = tab.big or 0
        if big > 0 then
            ui_manager.ui_list.transfer_gui:SetItemVisible(inst_id,true)
        else
            ui_manager.ui_list.transfer_gui:SetItemVisible(inst_id,false)
        end
    end
    ui_manager.ui_list.transfer_gui:SetMainFrameVisible(false)
    ui_manager.ui_list.transfer_gui:SetListFrameVisible(true)
    self.click_state = 1
end

--点击转移界面的solt2
function c:ClickTransferSolt2()
    --big==0 and small == 0
    for inst_id,tab in pairs(self.data.newlist)do
        local big = tab.big or 0
        local small = tab.small or 0
        if big == 0 and small == 0 then
            ui_manager.ui_list.transfer_gui:SetItemVisible(inst_id,true)
        else
            ui_manager.ui_list.transfer_gui:SetItemVisible(inst_id,false)
        end
    end
    ui_manager.ui_list.transfer_gui:SetMainFrameVisible(false)
    ui_manager.ui_list.transfer_gui:SetListFrameVisible(true)
    self.click_state = 2
end

--点击转移界面的item
function c:ClickTransferItem(inst_id)
    if self.click_state == 1 then
        self.transfer_solt1 = inst_id
        local tab = self.data.newlist[inst_id]
        if not tab then
            return
        end
        local relics_id = tab.relics_id
        local big = tab.big or 0
        ui_manager.ui_list.transfer_gui:SetSolt1Info(
            relics_cfg[relics_id].icon,
            relics_cfg[relics_id].quality,
            big
        )
        ui_manager.ui_list.transfer_gui:SetMainFrameVisible(true)
        ui_manager.ui_list.transfer_gui:SetListFrameVisible(false)
        self:Fire('SetTransferSolt',1,inst_id)

        if big <= 6 then
            ui_manager.ui_list.transfer_gui:SetPrice(0)
        elseif big == 7 then
            ui_manager.ui_list.transfer_gui:SetPrice(20)
        elseif big == 8 then
            ui_manager.ui_list.transfer_gui:SetPrice(40)
        elseif big == 9 then
            ui_manager.ui_list.transfer_gui:SetPrice(60)
        elseif big == 10 then
            ui_manager.ui_list.transfer_gui:SetPrice(100)
        end

    elseif self.click_state == 2 then
        self.transfer_solt2 = inst_id
        local tab = self.data.newlist[inst_id]
        local relics_id = tab.relics_id
        ui_manager.ui_list.transfer_gui:SetSolt2Info(
            relics_cfg[relics_id].icon,
            relics_cfg[relics_id].quality
        )
        ui_manager.ui_list.transfer_gui:SetMainFrameVisible(true)
        ui_manager.ui_list.transfer_gui:SetListFrameVisible(false)
        self:Fire('SetTransferSolt',2,inst_id)
    end
    self.click_state = nil
end

--鼠标进入转移界面item
function c:MouseEnterTransferItem(inst_id)
    local tab = self.data.newlist[inst_id]
    if not tab then
        return
    end
    local relics_id = tab.relics_id
    local forge = tab.forge
    local cfg = relics_cfg[relics_id]
    local big = tab.big or 0
    local bigVal = forgeCostCfg[big] and (forgeCostCfg[big].big) or 0
    
    local list = {}
    for key,_ in pairs(PropList)do
        if cfg[key] then
            if forge and key == forge.key then
                if key == 'DMG' and bigVal > 0 then
                    table.insert(list,string.format(guild_forge_str,key,cfg[key] * (1 + bigVal/100),forge.val))
                else
                    if key == 'MaxHp' then
                        table.insert(list,string.format(forge_str,'HP',cfg[key],forge.val))
                    else
                        table.insert(list,string.format(forge_str,key,cfg[key],forge.val))
                    end
                end
            else
                if key == 'DMG' and bigVal > 0 then
                    table.insert(list,string.format(guild_str,key,cfg[key] * (1 + bigVal/100)))
                else
                    if key == 'MaxHp' then
                        table.insert(list,string.format(showStr,'HP',cfg[key]))
                    else
                        table.insert(list,string.format(showStr,key,cfg[key]))
                    end
                end
            end
        end
    end

    ui_manager.ui_list.transfer_gui:SetTipsInfo(cfg.name,list,cfg.quality,tab.big or 0,tab.small or 0)
    ui_manager.ui_list.transfer_gui:SetTipsFrameVisible(true)
end

--点击转移按钮
function c:ClickTransferBtn()
    if not self.transfer_solt1 or not self.transfer_solt2 then
        return
    end

    local inst1 = self.transfer_solt1
    local inst2 = self.transfer_solt2

    local tab1 = self.data.newlist[inst1]
    local big = tab1.big or 0
    if big <= 6 then
        local re = self:Invoke('transferRelics',inst1,inst2)
        if re then
            ui_manager.ui_list.tips_gui:TipsMessage('Transfer successfully','success')
            ui_manager.ui_list.transfer_gui:SetSolt1Info()
            ui_manager.ui_list.transfer_gui:SetSolt2Info()
            self.transfer_solt1 = nil
            self.transfer_solt2 = nil
        else
            ui_manager.ui_list.tips_gui:TipsMessage('Transfer failed','fail')
        end
        return
    end

    local goodsId = 0
    if big == 7 then
        goodsId = 116
    elseif big == 8 then
        goodsId = 117
    elseif big == 9 then
        goodsId = 118
    elseif big == 10 then
        goodsId = 119
    end

    local re = self:Invoke('buy_goods',goodsId)
    if re then
        self.parent.shop_cmp:PlayPurchaseSound()
        ui_manager.ui_list.tips_gui:TipsMessage('Transfer successfully','success')
        ui_manager.ui_list.transfer_gui:SetSolt1Info()
        ui_manager.ui_list.transfer_gui:SetSolt2Info()
        ui_manager.ui_list.transfer_gui:SetPrice(0)
        self.transfer_solt1 = nil
        self.transfer_solt2 = nil
    end
end

function c:TransferRelics(inst_id,big,small)
    local tab = self.data.newlist[inst_id]
    if not tab then
        return
    end
    tab.big = big
    tab.small = small
    self:RefreshUi()
    ui_manager.ui_list.guild_forge_gui:SetLeftItemLv(inst_id,big,small)
    ui_manager.ui_list.transfer_gui:SetItemBig(inst_id,big)
end

function c:ChangePower(old,new)
    if old == new then
        return
    end

    ui_manager.ui_list.stats_gui:SetRightPower(new)
    ui_manager.ui_list.power_change_gui:PlayPower(old,new)

    if new >= old then
        self.ui:PlayPower(new - old,true)
    else
        self.ui:PlayPower(old - new,false)
    end

    local sub = (new - old)
    sub = math.floor(sub / 4)
    for i = 1,4 do
        if i == 4 then
            self.ui:SetPower(new)
        else
            self.ui:SetPower(old + sub * i)
        end
        wait(.1)
    end
end

c:RegistEvent('add_relics',c.AddRelics)
c:RegistEvent('del_relics',c.DelRelics)
c:RegistEvent('unlockSolt',c.UnlockSolt)
c:RegistEvent('addScroll',c.AddScroll)
c:RegistEvent('useScroll',c.UseScroll)
c:RegistEvent('addSmeltCoin',c.AddSmeltCoin)
c:RegistEvent('useSmeltCoin',c.UseSmeltCoin)
c:RegistEvent('codeUnlockSolt',c.CodeUnlockSolt)
c:RegistEvent('add_relicsByStar',c.AddRelicsByStar)
c:RegistEvent('transferRelics',c.TransferRelics)
c:RegistEvent('changePower',c.ChangePower)

return c