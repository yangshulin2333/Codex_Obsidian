local hotpot = _G.ClientHotpot
---@type UIManager
local ui_manager = hotpot.load.UIManager()

local base_time = 1742774400
local interval = 24 * 3600
local task_cfg = hotpot.config.task

---@class Client_TaskComponent:Client_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Client_PlayerComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)

    self.data = self.parent.save_data:GetData('task')
    self.ui = ui_manager.ui_list.task_gui
    self.ui:BindBtnClickHandle(self,self.GetReward)

    self:InitUi()
    self:AddUpdate(self.RefreshTime,1)
end

function c:InitUi()
    self.red = false
    for id,tab in pairs(self.data.list)do
        local reward = {}
        for k,v in ipairs(task_cfg[id].reward)do
            reward[k] = {
                icon = self.parent.reward_cmp:GetIcon(v),
                num = self.parent.reward_cmp:GetNum(v),
                quality = self.parent.reward_cmp:GetQulity(v),
            }
        end
        self.ui:AddItemInScroll(
            id,
            task_cfg[id].name,
            reward
        )
        self.ui:SetItemPro(id,tab.num,task_cfg[id].need)
        if tab.get then--已领取
            self.ui:SetItemState(id,2)
        else
            if tab.num >= task_cfg[id].need then
                self.ui:SetItemState(id,1)
                self.red = true
            else
                self.ui:SetItemState(id,3)
            end
        end
    end
    ui_manager.ui_list.hud_gui:SetTaskRedVisible(self.red)
end

function c:CheckRed()
    self.red = false
    for id,tab in pairs(self.data.list)do
        if tab.get then--已领取
            -- self.ui:SetItemState(id,2)
        else
            if tab.num >= task_cfg[id].need then
                -- self.ui:SetItemState(id,1)
                self.red = true
            else
                -- self.ui:SetItemState(id,3)
            end
        end
    end
    ui_manager.ui_list.hud_gui:SetTaskRedVisible(self.red)
end

function c:RefreshReward()
    for id,tab in pairs(self.data.list)do
        if id > 1 then
            local reward = task_cfg[id].reward[1]
            local num = self.parent.reward_cmp:GetNum(reward)
            self.ui:SetItemRewardNum(id,num)
        end
    end
end

function c:RefreshTime()
    local mark = self.data.mark
    local now = workspace:GetServerTimeNow()
    local sub = (mark) * interval + base_time - now
    -- print(mark,now,sub)
    self.ui:SetCD((sub))
    if sub <= 0 then
        local data = self:Invoke('refresh_task')
        if data then
            self.data = data
            self.ui:RemoveAllItem()
            self:InitUi()
        end
    end
end

function c:AddPoint(id,num)
    local tab = self.data.list[id]
    if not tab then
        return
    end
    if tab.get then
        return
    end
    local need = task_cfg[id].need
    if tab.num >= need then
        return false
    end
    local now = self.data.list[id].num
    local need = task_cfg[id].need
    now = now + num
    self.data.list[id].num = now
    self.ui:SetItemPro(id,now,need)
    if now >= need then
        self.ui:SetItemState(id,1)
        ui_manager.ui_list.hud_gui:SetTaskRedVisible(true)
    end
end

function c:GetReward(id)
    local tab = self.data.list[id]
    if not tab then
        return
    end
    if tab.get then
        return
    end
    if tab.num < task_cfg[id].need then
        return
    end
    local re = self:Invoke('get_task_reward',id)
    if re then
        self.data.list[id].get = true
        self.ui:SetItemState(id,2)
        ui_manager.ui_list.tips_gui:TipsMessage('Claim Successful!','success')
        self:CheckRed()
    end
end

function c:Unlock(data)
    self.data = data
    self.ui:RemoveAllItem()
    self:InitUi()
end

c:RegistEvent('add_task_point',c.AddPoint)
c:RegistEvent('unlock_task',c.Unlock)

return c