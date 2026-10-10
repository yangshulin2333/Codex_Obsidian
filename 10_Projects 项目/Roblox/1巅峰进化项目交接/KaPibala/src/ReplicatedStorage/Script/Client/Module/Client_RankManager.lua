local hotpot = _G.ClientHotpot

---@class Client_RankManager:BaseObject
local c = hotpot.class.new(script,hotpot.files.BaseObject())
function c.new()
    return c()
end
function c:ctor()
    c.super.ctor(self)

    self.rank_data = {}
    self:AddProcess(self.GetRank)
    self:AddUpdate(self.GetRank,600)
end

function c:GetRank()
    local kill = hotpot.function_manager:Invoke('get_rank_data','kill')
    local time = hotpot.function_manager:Invoke('get_rank_data','time')
    local purchase = hotpot.function_manager:Invoke('get_rank_data','purchase')
    local christmas_kill = hotpot.function_manager:Invoke('get_rank_data','christmas_kill')
    local christmas_time = hotpot.function_manager:Invoke('get_rank_data','christmas_time')
    local christmas_friend = hotpot.function_manager:Invoke('get_rank_data','christmas_friend')
    local party_kill = hotpot.function_manager:Invoke('get_rank_data','party_kill')
    local continuous_login = hotpot.function_manager:Invoke('get_rank_data','continuous_login')
    self.rank_data.kill = kill
    self.rank_data.time = time
    self.rank_data.purchase = purchase
    self.rank_data.christmas_kill = christmas_kill
    self.rank_data.christmas_time = christmas_time
    self.rank_data.christmas_friend = christmas_friend
    self.rank_data.party_kill = party_kill
    self.rank_data.continuous_login = continuous_login
end

return c
