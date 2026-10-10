---@type ServerHotpot
local hotpot = _G.ServerHotpot

local cfg = hotpot.config.UpdateLog

---@class Server_UpdateLogComponent:Server_PlayerComponent
local c = hotpot.class.new(script, hotpot.files.Server_PlayerComponent())
function c.new(parent)
    return c(parent)
end
---@param parent Server_Player
function c:ctor(parent)
    c.super.ctor(self, parent)
    ---@type Server_PlayerDataComponent
    self.data_cpt = self.parent:GetComponent(hotpot.load.Server_PlayerDataComponent())
    if not self.data_cpt then
        warn("玩家数据出错！")
        return
    end
    self.data = self.data_cpt:GetData("version_num")
end
function c:dtor()
    c.super.dtor(self)
end

function c:ChangeData()
    if self.data.__real.num == cfg[1].version then
        return false
    end
    self.data_cpt:Execut(function()
        self.data.num = cfg[1].version
    end)
    return true
end

c:RegistFunction("update_log",c.ChangeData)

return c
