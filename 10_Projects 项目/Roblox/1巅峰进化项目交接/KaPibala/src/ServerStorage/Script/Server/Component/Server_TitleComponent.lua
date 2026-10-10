local hotpot = _G.ServerHotpot
---@type UIGradientHelper
local UIGradientHelper = hotpot.load.UIGradientHelper()

local titleCfg = hotpot.config.title
local eventStr = 'titleAddPoint'
local PropList = {DMG = true,EXP = true,MaxHp = true,Speed = true}

---@class Server_TitleComponent:Server_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Server_PlayerComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)

    self.data = self.parent.save_data:GetData('title')

    self:Init()

    self:SetSecretNum(self.parent.character_cmp:GetSecretNum())

    self:AddUpdate(self.Update,60)

    self:AddProcess(function()
        repeat self:Wait(1) until self.parent.character
        self:Wait(1)
        self.ui = hotpot:GetPath_Loop('TitleGui',self.parent.character.root_part)
        self.uiGradient = hotpot:GetPath_Loop('info.UIGradient',self.ui)
        UIGradientHelper:Add(self.uiGradient)
        self:SetUi()
    end)

    self:CheckLimitTimeTitle()
    self:RefreshProp()
    self:AddProcess(self.CheckRank)

    -- self:AddProcess(function()
    --     self:Wait(20)
    --     local lastTime = hotpot.pro_cfg.GetLastDayTimeByWeek()
    --     for i = 20,25 do
    --         self:UnlockLimitTimeTitle(i,lastTime)
    --     end
    -- end)
end

function c:Init()
    for k,v in ipairs(titleCfg)do
        if not self.data.__real.list[v.id] then
            self.parent.save_data:Execut(function()
                local overTime = nil
                if v.limitTime then
                    overTime = 0
                end

                self.data.list[v.id] = {
                    taskNum = 0,
                    isActive = false,--是否激活
                    unlock = false,--是否解锁
                    overTime = overTime,--结束时间
                }
            end)
        end
    end

    self:AddProcess(function()
        repeat self:Wait(1) until self.parent.pet_cmp

        local data = self.parent.pet_cmp.data

        self:AddPoint(9,data.__real.max_equip)
    end)
end

function c:CheckLimitTimeTitle()
    for id,v in ipairs(self.data.__real.list)do
        if v.overTime then
            if os.time() > v.overTime then

                self:DeactivateTitle(id)

                if self.data.__real.equiped == id then
                    self:SetUi(true)
                    self.parent.save_data:Execut(function()
                        self.data.equiped = 0
                    end)
                end

                self.parent.save_data:Execut(function()
                    self.data.list[id].unlock = false
                end)
            end
        end
    end
end

function c:ClientCheckTime(id)
    -- wait()
    self:CheckLimitTimeTitle()
    if self.data.__real.list[id].unlock then
        return false
    else
        return true
    end
end

function c:Update()
    self:AddPoint(8,1)

    self:CheckRank()
end

function c:CheckRank()
    self:Wait(10)
    local r,e = pcall(function()
        ---@type GameServer
        local server = _G.server

        if server.get_rank_mark then
            local ranks = server.ranks
            local times = ranks.time
            local kill = ranks.kill
            local purchase = ranks.purchase
            
            local myUid = tostring(self.parent.user_id)
            local uid = nil
            for i = 1,10 do
                if times[i] then
                    uid = times[i].key
                    if uid == myUid then
                        self:AddPoint(-1,1)
                    end
                end

                if kill[i] then
                    uid = kill[i].key
                    if uid == myUid then
                        self:AddPoint(-2,1)
                    end
                end

                if purchase[i] then
                    uid = purchase[i].key
                    if uid == myUid then
                        self:AddPoint(-3,1)
                    end
                end
            end

            local christmas_kill = ranks.christmas_kill
            local christmas_time = ranks.christmas_time
            local christmas_friend = ranks.christmas_friend

            for i = 1,10 do
                if christmas_kill[i] then
                    uid = christmas_kill[i].key
                    if uid == myUid then
                        self:AddPoint(-4,1)
                    end
                end

                if christmas_time[i] then
                    uid = christmas_time[i].key
                    if uid == myUid then
                        self:AddPoint(-4,1)
                    end
                end

                if christmas_friend[i] then
                    uid = christmas_friend[i].key
                    if uid == myUid then
                        self:AddPoint(-4,1)
                    end
                end
            end
        end
    end)
    if not r then
        warn(e)
    end
end

--刷新属性
function c:RefreshProp()
    local prop = {}
    
    for id,v in pairs(self.data.__real.list)do
        if v.isActive then
            for a,b in pairs(PropList)do
                if titleCfg[id][a] then
                    prop[a] = (prop[a] or 0) + titleCfg[id][a]
                end
            end
        end
    end

    self.prop = prop

    if self.parent.stats_cmp then
        self.parent.stats_cmp:SyncAttack()
    end

    if self.parent.character then
        self.parent.character:RefreshHp()
    end
end

function c:GetActiveNum()
    local num = 0
    for id,v in pairs(self.data.__real.list)do
        if v.isActive then
            num = num + 1
        end
    end
    return num
end

function c:AddMaxActiveNum(num)
    num = num or 1
    self.parent.save_data:Execut(function()
        self.data.max = self.data.max + num
    end)

    self:Fire('AddMaxActiveNum',num)
end

function c:AddPoint(type_,num)
    for id,v in pairs(self.data.__real.list)do
        if titleCfg[id] and titleCfg[id].needType == type_ then
            if type_ == 9 then
                self.parent.save_data:Execut(function()
                    self.data.list[id].taskNum = math.max(self.data.list[id].taskNum,num)
                end)
            else
                self.parent.save_data:Execut(function()
                    self.data.list[id].taskNum = math.min(self.data.list[id].taskNum + num,titleCfg[id].needNum)
                end)
            end
        end
    end

    self:Fire(eventStr,type_,num)
end

function c:UnlockTitle(id)
    if not self.data.__real.list[id] then
        return
    end
    if self.data.__real.list[id].unlock then
        return
    end
    if self.data.__real.list[id].taskNum < titleCfg[id].needNum then
        return
    end
    self.parent.save_data:Execut(function()
        self.data.list[id].unlock = true
    end)

    return true
end

function c:UnlockLimitTimeTitle(id,overTime)
    if not self.data.__real.list[id] then
        return
    end
    self.parent.save_data:Execut(function()
        self.data.list[id].unlock = true
        self.data.list[id].overTime = overTime
    end)

    self:Fire('unlockLimitTimeTitle',id,overTime)

    return true
end

function c:EquipTitle(id)
    if not self.data.__real.list[id] then
        return
    end
    if not self.data.__real.list[id].unlock then
        return
    end
    if self.data.__real.equiped == id then
        return
    end
    self.parent.save_data:Execut(function()
        self.data.equiped = id
    end)

    self:SetUi()

    return true
end

function c:SetUi(isNull)
    local equiped = self.data.__real.equiped

    if equiped == 0 then
        return
    end

    if not self.ui then
        return
    end
    local icon = self.ui:FindFirstChild('icon')
    if not icon then
        return
    end
    local info = self.ui:FindFirstChild('info')
    if not info then
        return
    end

    if isNull then
        icon.Image = ''
        info.Text = ''
        self.uiGradient.Enabled = false
    else
        icon.Image = titleCfg[equiped].icon
        info.Text = titleCfg[equiped].name
        self.uiGradient.Enabled = titleCfg[equiped].rare
    end


end

function c:ActivateTitle(id)
    if not self.data.__real.list[id] then
        return
    end
    if not self.data.__real.list[id].unlock then
        return
    end
    if self.data.__real.list[id].isActive then
        return
    end
    if self:GetActiveNum() >= self.data.__real.max then
        return
    end
    self.parent.save_data:Execut(function()
        self.data.list[id].isActive = true
    end)

    self:RefreshProp()
    if self.parent.relics_cmp then
        self.parent.relics_cmp:RefrehPower()
    end

    return true
end

function c:DeactivateTitle(id)
    if not self.data.__real.list[id] then
        return
    end
    if not self.data.__real.list[id].unlock then
        return
    end
    if not self.data.__real.list[id].isActive then
        return
    end
    self.parent.save_data:Execut(function()
        self.data.list[id].isActive = false
    end)

    self:RefreshProp()
    if self.parent.relics_cmp then
        self.parent.relics_cmp:RefrehPower()
    end

    return true
end

function c:SetSecretNum(num)
    for k,v in pairs(titleCfg)do
        if v.needType == 7 then
            self.parent.save_data:Execut(function()
                self.data.list[k].taskNum = num
            end)
        end
    end
    self:Fire('SetSecretNum',num)
end

c:RegistFunction('unlockTitle',c.UnlockTitle)
c:RegistFunction('equipTitle',c.EquipTitle)
c:RegistFunction('activateTitle',c.ActivateTitle)
c:RegistFunction('deactivateTitle',c.DeactivateTitle)
c:RegistFunction('checklimittimetitle',c.ClientCheckTime)

return c