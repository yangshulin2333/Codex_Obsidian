local _G = _G
local script = script
local assert = assert
local Enum = Enum
local RaycastParams = RaycastParams
local pairs = pairs
local Vector3 = Vector3
local math = math
local workspace = workspace
local hotpot = _G.CommonHotpot
--添加服务引用
local area_manager = hotpot.load.AreaManager()
local collider_manager = hotpot.load.ColliderManager()
--添加常量
local BOTTOM_CHECK_HIGH = 99999
---@class AreaCheckComponent:BaseComponent
local c = hotpot.class.new(script,hotpot.files.BaseComponent())
local Update
---@param self AreaCheckComponent
function Update(self)
    local object = self.parent
    if not object:IsExist() then
        self:Stop()
        return
    end
    if not object.GetPosition then
        return
    end
    --拿到坐标信息
    ---@type Vector3
    local start_pos = object:GetPosition()
    -- start_pos = Vector3.new(start_pos.X,math.huge,start_pos.Z)
    local bottom_check_high = BOTTOM_CHECK_HIGH
    --如果设置了地板检查，那么久先做地板检查
    local bp = self.__bottom_param
    if bp then
        local result = workspace:Raycast(start_pos,Vector3.new(0,-bottom_check_high,0),bp)
        if result then
            local pos = result.Position
            bottom_check_high = (pos - start_pos).Magnitude
        end
    end
    local check_params = self.__check_params
    local touched = self.__touched
    local check_high = self.__check_high
    --开始检查
    for collider_group,ray_cast_param in pairs(check_params) do
        --确定向下延展的长度
        local high = check_high[collider_group] or BOTTOM_CHECK_HIGH
        high = math.min(bottom_check_high,high)
        local result = workspace:Raycast(start_pos,Vector3.new(0,-high,0),ray_cast_param)
        ---@type Part
        local old_part = touched[collider_group]
        if result then
            ---@type Part
            local part = result.Instance
            if part ~= old_part then
                if old_part then
                    area_manager:OutArea(object,old_part)
                    local cid = old_part.CollisionGroupId
                    local handle = self.__out_handle[cid]
                    if handle then
                        handle(self,old_part)
                    end
                end
                touched[collider_group] = part
                if part then
                    area_manager:InArea(object,part)
                    local cid = part.CollisionGroupId
                    local handle = self.__in_handle[cid]
                    if handle then
                        handle(self,part)
                    end
                end
            end
        else
            if old_part then
                area_manager:OutArea(object,old_part)
                local cid = old_part.CollisionGroupId
                local handle = self.__out_handle[cid]
                if handle then
                    handle(self,old_part)
                end
                touched[collider_group] = nil
            end
        end
    end
end
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)
    self.__check_params = {}
    self.__touched = {}
    self.__check_high = {}
    self.__in_handle = {}
    self.__out_handle = {}
end
function c:dtor()
    self:Stop()
    local object = self.parent
    local touched = self.__touched
    for collider_group,part in pairs(touched) do
        area_manager:OutArea(object,part)
    end
    self.__touched = {}
    c.super.dtor(self)
end
---@type fun(collider_group:string) @设置底部的限制，如果需要避免射线穿透地板触发地板下的区域，那么请设置该项
---@param collider_group string @用于检查底板的碰撞组
function c:SetBottomCheck(collider_group)
    assert(collider_group,"param collider group is nil")
    local rp = RaycastParams.new()
    rp.CollisionGroup = collider_group
    rp.FilterDescendantsInstances = {self.parent.main_inst}
    rp.FilterType = Enum.RaycastFilterType.Blacklist
    self.__bottom_param = rp
end
---@type fun(collider_group:string,high:number) @设置需要检查的碰撞组，high是检查长度，如果不设置那么将按照最长的长度来进行检查，如果检测需要根据角色跳跃状态来检查的话，那么可以填写high
---@param collider_group string
---@param high number
function c:AddCheck(collider_group,high)
    assert(collider_group,"param collider group is nil")
    local rp = RaycastParams.new()
    rp.CollisionGroup = collider_group
    rp.FilterDescendantsInstances = {self.parent.main_inst}
    rp.FilterType = Enum.RaycastFilterType.Blacklist
    self.__check_params[collider_group] = rp
    self.__check_high[collider_group] = high
end
function c:DelCheck(collider_group)
    assert(collider_group,"param collider group is nil")
    self.__check_params[collider_group] = nil
    self.__touched[collider_group] = nil
end
function c:Start()
    if self.__update_cnnt then
        return
    end
    self.__update_cnnt = self:AddUpdate(Update)
end
function c:Stop()
    if self.__update_cnnt then
        self.__update_cnnt:Disconnect()
        self.__update_cnnt = nil
    end
end
function c:IsUpdating()
    return self.__update_cnnt
end
function c:AddInHandle(collider_group,handle)
    local collider_group_id = collider_manager:GetGroupIdWithName(collider_group)
    self.__in_handle[collider_group_id] = handle
end
function c:DelInHandle(collider_group)
    local collider_group_id = collider_manager:GetGroupIdWithName(collider_group)
    self.__in_handle[collider_group_id] = nil
end
function c:CleanInHandle()
    for collider_group,handle in pairs(self.__in_handle) do
        self.__in_handle[collider_group] = nil
    end
end
function c:AddOutHandle(collider_group,handle)
    local collider_group_id = collider_manager:GetGroupIdWithName(collider_group)
    self.__out_handle[collider_group_id] = handle
end
function c:DelOutHandle(collider_group)
    local collider_group_id = collider_manager:GetGroupIdWithName(collider_group)
    self.__out_handle[collider_group_id] = nil
end
function c:CleanOutHandle()
    for collider_group,handle in pairs(self.__out_handle) do
        self.__out_handle[collider_group] = nil
    end
end
function c:CleanAllHandle()
    self:CleanInHandle()
    self:CleanOutHandle()
end
return c