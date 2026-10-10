local game = game
local setmetatable = setmetatable
---装载必要服务
---@type RunService
local RunService = game:GetService('RunService')
---@type PhysicsService
local PhysicsService = game:GetService("PhysicsService")
local meta = {}
local collider_names = {}
function meta:__index(key)
    return key
end

if RunService:IsServer() then
    function meta:__newindex(key,val)
        if val then
            if not collider_names[key]  then
                --collider_names[key] = PhysicsService:CreateCollisionGroup(key)
                collider_names[key] = PhysicsService:RegisterCollisionGroup(key)
            end
        else
            if collider_names[key] then
                --PhysicsService:RemoveCollisionGroup(key)
                PhysicsService:UnregisterCollisionGroup(key)
                collider_names[key] = nil
            end
        end
    end
end
---@class ColliderGroup
local c = setmetatable({Default="Default"},meta)
return c