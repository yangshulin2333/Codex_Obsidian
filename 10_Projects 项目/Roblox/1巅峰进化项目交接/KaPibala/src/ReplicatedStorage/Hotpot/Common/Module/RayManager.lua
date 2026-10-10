local hotpot = _G.CommonHotpot
local collider_group = hotpot.load.ColliderGroup()
local collider_manager = hotpot.load.ColliderManager()

---@class RayManager
local c = hotpot.class.new(script)

c.ray_cast_list = {}

function c:AddRayCast(part,obj,in_handle,out_handle)
    part.CanQuery = true
    collider_manager:SetPartGroup(part,collider_group.ray_cast_part)
    self.ray_cast_list[part] = {obj = obj,in_handle = in_handle,out_handle = out_handle}
end

function c:RemoveRayCast(part)
    if self.ray_cast_list[part] then
        self.ray_cast_list[part] = nil
    end
end

function c:GetRayCastList()
    return self.ray_cast_list
end

return c