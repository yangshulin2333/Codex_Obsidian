local hotpot = _G.ServerHotpot
---@type DataStoreService
local DataStoreService = game:GetService('DataStoreService')

local BASETIME = 1769644800
local INTERVAL = 86400 * 7

---@class Server_ChallengeComponent:Server_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Server_PlayerComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)

    self.data = self.parent.save_data:GetData('challenge')

    self:InitData()
end

function c:InitData()
    if not self.data.__real.get then
        self.parent.save_data:Execut(function()
            self.data.get = {}
        end)
    end

    local now = os.time()
    local mark = math.floor((now - BASETIME) / INTERVAL)
    if mark > self.data.__real.mark then
        self.parent.save_data:Execut(function()
            self.data.mark = mark
            self.data.list = {}
        end)
    end
end

function c:SaveRank(num)
    num = num or 1
    local now = os.time()
    local mark = math.floor((now - BASETIME) / INTERVAL)
    local sortName = 'challenge_stage_' .. mark
    local DataStore = DataStoreService:GetOrderedDataStore(sortName)
    local uid = self.parent.user_id

    DataStore:UpdateAsync(uid,function(old)
        if not old then
            return num
        end
        if old >= num then
            return nil
        end
        return num
    end)
end

function c:CheckCanReward(idx)
    if self.data.__real.list[idx] then
        return false
    end
    return true
end

function c:PassStage(num)
    if not num then
        return
    end
    if self.data.__real.list[num] then--已领取
        return
    end
    self:AddProcess(self.SaveRank)

    self.parent.save_data:Execut(function()
        self.data.list[num] = true
    end)

    local r,e = pcall(function()
        self:SaveRank(num)
    end)
    if not r then
        warn(e)
    end
end

function c:GetMaxPassNum()
    local max = 0
    for k,v in pairs(self.data.__real.list)do
        if v then
            max = math.max(max,k)
        end
    end
    return max
end

function c:CanClaimRank(num)
    if not num then
        return false
    end
    if self.data.__real.get[num] then
        return false
    end

    self.parent.save_data:Execut(function()
        self.data.get[num] = true
    end)

    return true
end

function c:GetRankReward()
    self.parent.relics_cmp:AddRelicsWithStar(143,7,7)
    self:Fire('getChallengeReward',{4,143,1})
end

return c