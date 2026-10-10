local hotpot = _G.ServerHotpot
local base_time = 1742774400
local interval = 24 * 3600

local task_cfg = hotpot.config.task

---@class Server_TaskComponent:Server_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Server_PlayerComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)

    self.data = self.parent.save_data:GetData('task')

    self:Check()

    -- self:AddProcess(function()
    --     self:Wait(5)
    --     self:AddPoint(4,900)
    -- end)
end

function c:Unlock()
    -- print('unlock')
    self.parent.save_data:Execut(function()
        self.data.unlock = true
    end)
    self:Check()
    self:Fire('unlock_task',self.data.__real)
end

function c:Check()
    if not self.data.__real.unlock then
        return false
    end
    local mark = self.data.__real.mark
    local now = os.time()
    local val = math.ceil((now - base_time) / interval)
    if val > mark then
        self.parent.save_data:Execut(function()
            self.data.mark = val
        end)
        self:RefreshTask()
    end 

    return self.data.__real
end

--洗牌算法
function c:Stuff(list)
    local len = #list
    for i = len, 2, -1 do
        -- 生成一个1到i之间的随机整数
        local j = math.random(i)
        -- 交换list[i]和list[j]
        list[i], list[j] = list[j], list[i]
    end
    return list
end

--刷新任务
function c:RefreshTask()
    local list = {}
    list[1] = {id = 1,get = false,num = 0}

    local temp = {}
    for k,v in pairs(task_cfg)do
        if v.id ~= 1 then
            table.insert(temp,v.id)
        end
    end
    self:Stuff(temp)

    for i = 1,3 do
        local id = temp[i]
        list[id] = {id = id,get = false,num = 0}
    end

    self.parent.save_data:Execut(function()
        self.data.list = list
    end)
end

--打点
function c:AddPoint(id,num)
    if not self.data.__real.unlock then
        return
    end
    local tab = self.data.__real.list[id]
    if not tab then
        return
    end
    if tab.get then
        return
    end
    local need = task_cfg[id].need
    if tab.num > need then
        return false
    end
    self.parent.save_data:Execut(function()
        self.data.list[id].num = self.data.list[id].num + num
    end)
    
    self:Fire('add_task_point',id,num)
end

--领取奖励
function c:GetReward(id)
    if not self.data.__real.unlock then
        return
    end
    local tab = self.data.__real.list[id]
    if not tab then
        return
    end
    if tab.get then
        return
    end
    if tab.num < task_cfg[id].need then
        return
    end

    self.parent.save_data:Execut(function()
        self.data.list[id].get = true
    end)

    self.parent.reward_cmp:AddReward(task_cfg[id].reward)

    if id ~= 1 then
        self:AddPoint(1,1)
    end

    return true
end

c:RegistFunction('refresh_task',c.Check)
c:RegistFunction('get_task_reward',c.GetReward)

return c