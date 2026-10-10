local hotpot = _G.ServerHotpot

local OpenSkillCfg = hotpot.config.skillBox
local total = 0
for k,v in ipairs(OpenSkillCfg)do
    total = total + v.weight
end

---@class Server_OpenSkillComponent:Server_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Server_PlayerComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)
end

function c:GachaSkill()
    local num = math.random(1,total)
    local id = 0
    for k,v in ipairs(OpenSkillCfg)do
        num = num - v.weight
        if num <= 0 then
            id = v.id
            break
        end
    end
    if id == 0 then
        id = 15
    end
    return id
end

function c:OpenSkill(num)
    local list = {}
    for i = 1,num do
        local id = self:GachaSkill()

        self.parent.reward_cmp:AddReward({OpenSkillCfg[id].reward},true)

        table.insert(list,id)
    end

    self:Fire('openResult',list)

    return true
end

return c