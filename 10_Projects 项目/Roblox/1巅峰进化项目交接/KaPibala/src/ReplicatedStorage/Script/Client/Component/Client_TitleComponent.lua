local hotpot = _G.ClientHotpot
---@type UIManager
local ui_manager = hotpot.load.UIManager()

local titleCfg = hotpot.config.title
local PropList = {DMG = true,EXP = true,MaxHp = true,Speed = true}

---@class Client_TitleComponent:Client_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Client_PlayerComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)

    self.data = self.parent.save_data:GetData('title')
    self.ui = ui_manager.ui_list.title_gui
    self.ui:BindScrollItemClickHandle(self,self.ClickScrollItem)
    self.ui:BindScrollItemUnlockBtnClickHandle(self,self.ClickScrollItemUnlockBtn)
    self.ui:BindEquipBtnClickHandle(self,self.ClickEquipBtn)
    self.ui:BindDeactivateBtnClickHandle(self,self.ClickDeactivateBtn)
    self.ui:BindActivateBtnClickHandle(self,self.ClickActivateBtn)

    self:InitGui()
    self:RefreshTotalProp()
    self:ClickScrollItem(1)
    self:CheckRed()
    self:AddUpdate(self.UpdateLimitTime,1)
end

function c:InitGui()
    for k,v in ipairs(titleCfg)do
        local props = {}
        for a,b in pairs(PropList)do
            if v[a] then
                table.insert(props,a..' +'..v[a] .. '%')
            end
        end
        self.ui:AddItemInScroll(
            v.id,
            v.icon,
            v.name,
            props,
            v.rare,
            v.order
        )
        local data = self.data.list[v.id]
        self.ui:SetScrollItemNeed(v.id,v.need,data.taskNum,v.needNum)
        self.ui:SetScrollItemActiveVisible(v.id,data.isActive)
        self.ui:SetScrollItemUnlockVisible(v.id,not data.unlock)
    end

    if self.data.equiped == 0 then
        self.ui:SetRightInfo('','')
    else
        local cfg = titleCfg[self.data.equiped]
        self.ui:SetRightInfo(cfg.icon,cfg.name,cfg.rare)
    end
end

function c:UpdateLimitTime()
    for id,tab in pairs(self.data.list)do
        if tab.unlock and tab.overTime then
            local now = workspace:GetServerTimeNow()
            local sub = tab.overTime - now
            if sub >= 0 then
                self.ui:SetScrollItemTime(id,sub)
            else
                self:CheckLimitTimeTitle(id)
                self.ui:SetScrollItemTime(id,0)
            end
        end
    end
end

function c:CheckLimitTimeTitle(id)
    local re = self:Invoke('checklimittimetitle',id)
    if re then
        self.data.list[id].unlock = false
        local cfg = titleCfg[id]
        self.ui:SetScrollItemNeed(id,cfg.need,0,cfg.needNum)
        self.ui:SetScrollItemUnlockVisible(id,true)

        if self.data.list[id].isActive then
            self.data.list[id].isActive = false
            self.ui:SetScrollItemActiveVisible(id,false)
            self.ui:SetActivateBtnVisible(true)
            self.ui:SetDeactivateBtnVisible(false)
            self:RefreshTotalProp()
        end
        if self.data.equiped == id then
            self.data.equiped = 0
            self.ui:SetRightInfo('','',false)
        end
    end
end

function c:RefreshTotalProp()
    local prop = {}
    local aNum = 0
    for id,tab in pairs(self.data.list)do
        if tab.isActive then
            local cfg = titleCfg[id]
            for a,b in pairs(PropList)do
                if cfg[a] then
                    prop[a] = (prop[a] or 0) + cfg[a]
                end
            end
            aNum = aNum + 1
        end
    end
    self.ui:RemoveAllItemInLeft()
    for k,v in pairs(prop)do
        self.ui:AddItemInLeft(k..'+'..v..'%')
    end
    self.activeNum = aNum
    self.ui:SetActivatedTxt(string.format('Activated:  (%d/%d)',aNum,self.data.max))
end

function c:CheckRed()
    self.red = false
    for id,v in pairs(self.data.list)do
        if not v.unlock then
            if titleCfg[id] then
                if v.taskNum >= titleCfg[id].needNum then
                    self.red = true
                end
            end
        end
    end

    ui_manager.ui_list.relics_gui:SetTitleRedVisible(self.red)
    ui_manager.ui_list.hud_gui:SetRelicsRedVisible(self.red)
end

function c:AddPoint(type_,num)
    for k,v in pairs(titleCfg)do
        if titleCfg[v.id].needType == type_ then
            if type_ == 9 then
                self.data.list[v.id].taskNum = math.max(self.data.list[v.id].taskNum,num)
            else
                self.data.list[v.id].taskNum = math.min(self.data.list[v.id].taskNum + num,titleCfg[v.id].needNum)
            end
            self.ui:SetScrollItemNeed(v.id,v.need,self.data.list[v.id].taskNum,v.needNum)
        end
    end

    self:CheckRed()
end

function c:SetSecretNum(num)
    for id,v in pairs(self.data.list)do
        if titleCfg[id].needType == 7 then
            self.data.list[id].taskNum = num
            self.ui:SetScrollItemNeed(id,titleCfg[id].need,v.taskNum,titleCfg[id].needNum)
        end
    end

    self:CheckRed()
end

function c:AddMaxActiveNum(num)
    self.data.max = self.data.max + (num or 1)
    self.ui:SetActivatedTxt(string.format('Activated:  (%d/%d)',self.activeNum,self.data.max))
end

function c:ClickScrollItem(id)
    if self.click_scroll_id == id then
        return
    end
    if self.click_scroll_id then
        self.ui:SetScrollItemSelectVisible(self.click_scroll_id,false)
    end
    self.click_scroll_id = id
    self.ui:SetScrollItemSelectVisible(id,true)

    local data = self.data.list[id]
    self.ui:SetActivateBtnVisible(not data.isActive)
    self.ui:SetDeactivateBtnVisible(data.isActive)
end

function c:ClickScrollItemUnlockBtn(id)
    self:ClickScrollItem(id)
    local data = self.data.list[id]
    if data.unlock then
        return
    end
    if data.taskNum < titleCfg[id].needNum then
        ui_manager.ui_list.tips_gui:TipsMessage('Unfulfilled conditions!','fail')
        return
    end
    local re = self:Invoke('unlockTitle',id)
    if re then
        self.data.list[id].unlock = true
        self.ui:SetScrollItemUnlockVisible(id,false)
        ui_manager.ui_list.tips_gui:TipsMessage('Unlock success!','success')

        self:CheckRed()
    end
end

function c:ClickEquipBtn()
    local id = self.click_scroll_id
    if not id then
        return
    end
    local data = self.data.list[id]
    if not data.unlock then
        ui_manager.ui_list.tips_gui:TipsMessage('Unlocked first!','fail')
        return
    end
    if data.equiped == id then
        return
    end
    local re = self:Invoke('equipTitle',id)
    if re then
        self.data.equiped = id
        self.ui:SetRightInfo(titleCfg[id].icon,titleCfg[id].name,titleCfg[id].rare)
        ui_manager.ui_list.tips_gui:TipsMessage('Equip success!','success')
    end
end

function c:ClickActivateBtn()
    local id = self.click_scroll_id
    if not self.data.list[id].unlock then
        ui_manager.ui_list.tips_gui:TipsMessage('Unlocked first!','fail')
        return
    end
    if self.activeNum >= self.data.max then
        ui_manager.ui_list.tips_gui:TipsMessage('Activated number exceeds the limit!','fail')
        return
    end
    if self.data.list[id].isActive then
        ui_manager.ui_list.tips_gui:TipsMessage('Already activated!','fail')
        return
    end
    local re = self:Invoke('activateTitle',id)
    if re then
        self.data.list[id].isActive = true
        self.ui:SetScrollItemActiveVisible(id,true)
        self.ui:SetActivateBtnVisible(false)
        self.ui:SetDeactivateBtnVisible(true)
        self:RefreshTotalProp()
        ui_manager.ui_list.tips_gui:TipsMessage('Activate success!','success')
    end
end

function c:ClickDeactivateBtn()
    local id = self.click_scroll_id
    if not id then
        return
    end
    local data = self.data.list[id]
    if not data.isActive then
        return
    end
    local re = self:Invoke('deactivateTitle',id)
    if re then
        self.data.list[id].isActive = false
        self.ui:SetScrollItemActiveVisible(id,false)
        self.ui:SetActivateBtnVisible(true)
        self.ui:SetDeactivateBtnVisible(false)
        self:RefreshTotalProp()
        ui_manager.ui_list.tips_gui:TipsMessage('Deactivate success!','success')
    end
end

function c:UnlockLimitTimeTitle(id,overTime)
    self.data.list[id].overTime = overTime
    self.data.list[id].unlock = true

    local cfg = titleCfg[id]
    self.ui:SetScrollItemNeed(id,cfg.need,cfg.needNum,cfg.needNum)
    self.ui:SetScrollItemUnlockVisible(id,false)

    print('unlock')
end

c:RegistEvent('titleAddPoint',c.AddPoint)
c:RegistEvent('SetSecretNum',c.SetSecretNum)
c:RegistEvent('AddMaxActiveNum',c.AddMaxActiveNum)
c:RegistEvent('unlockLimitTimeTitle',c.UnlockLimitTimeTitle)

return c