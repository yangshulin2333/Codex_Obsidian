local hotpot = _G.ServerHotpot
---@type Server_StageObj
local stage_obj = hotpot.load.Server_StageObj()
---@type Server_ChristmasStageObj
local christmas_stage_obj = hotpot.load.Server_ChristmasStageObj()

local stage_cfg = hotpot.config.stage

---@class Server_StageManager:BaseObject
local c = hotpot.class.new(script,hotpot.files.BaseObject())
function c.new()
    return c()
end
function c:ctor()
    c.super.ctor(self)

    self:LoadStage()
end

--加载场景
function c:LoadStage()
    self.stage_list = {}

    local fol = hotpot:GetPath_Loop('Stage',hotpot.Resource)
    for k,v in pairs(stage_cfg)do
        local name = v.model
        local model = fol:FindFirstChild(name)
        if model then
            local obj = stage_obj.new(model,v.id)
            self.stage_list[v.id] = obj
        end
    end

    local model = fol:WaitForChild('baseStage')
    if model then
        local obj = christmas_stage_obj.new(model,'base')
        self.stage_list['base'] = obj
    end
end

--获取场景信息
function c:GetStageData(id)
    ---@type Server_StageObj
    local obj = self.stage_list[id]
    if not id then
        return false
    end

    local info = {}
    local monster_list = {}
    for part,tab in pairs(obj.point_list)do
        local monster = tab.obj
        local max_hp,hp
        if monster then
            max_hp = monster.max_hp
            hp = monster.hp
        end
        local is_alive = tab.is_alive
        table.insert(monster_list,{
            part = part,
            guid = monster and monster.guid or nil,
            is_alive = is_alive,
            max_hp = max_hp,
            hp = hp,
        })
    end

    local weatherMonster = {}
    for k,v in pairs(obj.guid_to_monster)do
        if v.weather_id then
            table.insert(weatherMonster,{
                guid = v.guid,
                weather_id = v.weather_id,
                max_hp = v.max_hp,
                hp = v.hp,
                part = v.part,
            })
        end
    end
    info.weather_monster = weatherMonster
    info.monster_list = monster_list
    return info
end

return c