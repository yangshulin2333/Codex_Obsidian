local _G = _G
local script = script
---@type PathfindingService
local PathfindingService = game:GetService("PathfindingService")
local hotpot = _G.CommonHotpot
local hotpot_connection = hotpot.load.HotpotConnection()
local callback_manager = hotpot.load.CallBackManager()
---@class AutoMoveComponent:BaseComponent
local c = hotpot.class.new(script,hotpot.files.BaseComponent())
---@type Path[]
local path_cache = {}
---@type Part[]
local part_cache = {}
local lfunc = {}
---@param self AutoMoveComponent
---@param list PathWayPoint[]
function lfunc.ShowMark(self,list)
    lfunc.CleanMark(self)
    for i,point in ipairs(list) do
        --尝试去拿part，如果没有那么就创建
        local idx,part = next(part_cache)
        if not idx then
            part = Instance.new("Part")
            part.Shape = Enum.PartType.Ball
            part.Anchored = true
            part.CanCollide = false
            part.CanTouch = false
            part.Size = Vector3.new(1,1,1)
        else
            table.remove(part_cache,idx)
        end
        part.Parent = workspace
        part.Position = point.Position
        self.marks[part] = true
    end
end
---@param self AutoMoveComponent
function lfunc.CleanMark(self)
    --先清空上一次寻路的结果
    for p,b in pairs(self.marks) do
        table.insert(part_cache,p)
        p.Parent = nil
        self.marks[p] = nil
    end
end
---@param self AutoMoveComponent
function lfunc.FindPath(self,mark)
    --如果角色处于空中，那么需要等他落地以后再继续
    while self.target_pos do
        ---@type Humanoid
        local humanoid = self.humanoid
        if humanoid then
            local state = humanoid:GetState()
            if state ~= Enum.HumanoidStateType.Jumping
            and state ~= Enum.HumanoidStateType.Ragdoll
            and state ~= Enum.HumanoidStateType.FallingDown
            and state ~= Enum.HumanoidStateType.Freefall
            then
                local path = self.path
                local start_pos = self.parent:GetPosition()
                local pos = self.target_pos
                self.target_pos = nil
                self:WaitForFunc(path.ComputeAsync,path,start_pos,pos)
                if path.Status ~= Enum.PathStatus.Success then
                    self.points = nil
                    lfunc.CleanMark(self)
                else
                    self.points = path:GetWaypoints()
                    if self.points and self.points[1] then
                        if self.points[1].Action == Enum.PathWaypointAction.Jump then
                            humanoid.Jump = true
                        end
                    end
                    self.index = 1
                    if mark then
                        humanoid:MoveTo(self.parent:GetPosition())
                        lfunc.ShowMark(self,self.points)
                    end
                end
                if self.__update_co then
                    local co = self.__update_co
                    self.__update_co = nil
                    coroutine.resume(co,self.points)
                end
            else
                self:Wait()
            end
        end
    end
    self.__find_path_cnnt = nil
    -- if not self.__back_find then
    --     print("back")
    --     local back_pos = self.__back_find
    --     self.__back_find = nil
    --     lfunc.FindPath(self,back_pos,mark)
    --     -- self.__find_path_cnnt = self:AddProcess(lfunc.FindPath,pos,mark)
    -- end
    -- if self.__back_find then
    --     local pos = self.__back_find
    --     self.__back_find = nil
    --     lfunc.FindPath(self,pos)
    -- end
end
---@param self AutoMoveComponent
function lfunc.Update(self)
    while true do
        if self.__find_path_cnnt then
            if not self.points or not self.index or self.index > #self.points then
                self.__update_co = coroutine.running()
                if not coroutine.yield() then
                    break
                end
            end
        else
            if not self.points or not self.index then
                break
            end
            if self.index > #self.points then
                break
            end
        end
        self.index = self.index + 1
        local points = self.points
        local point = points[self.index]
        ---@type Humanoid
        local humanoid = self.humanoid
        if not humanoid then
            break
        end
        if point then
            -- while humanoid:GetState() == Enum.HumanoidStateType.Jumping
            -- or humanoid:GetState() == Enum.HumanoidStateType.Freefall
            -- or humanoid:GetState() == Enum.HumanoidStateType.FallingDown
            -- do
            --     self:Wait()
            -- end
            if point.Action == Enum.PathWaypointAction.Jump then
                humanoid.Jump = true
                self:Wait()
            end
            self.__move_to = true
            self.__move_failed = 0
            humanoid:MoveTo(point.Position)
            if self:WaitForFunc(humanoid.MoveToFinished.Wait,humanoid.MoveToFinished) then
                self.__move_to = false
            else
                self.__move_to = false
                break
            end
        else
            --没有路了
            self.points = nil
            self.index = nil
        end
    end
    self.__update_co = nil
    self.points = nil
    self.index = nil
    self.__update_cnnt = nil
    --执行移动完成
    for handle,arg in pairs(self.__on_move_over_handle) do
        self:AddProcess(handle,table.unpack(arg))
    end
end
---@param self AutoMoveComponent
function lfunc.AddHandleOnMoveOver(self,handle,...)
    assert(handle,"param handle is nil")
    self.__on_move_over_handle[handle] = {...}
end
---@param self AutoMoveComponent
function lfunc.DelhandleOnMoveOver(self,handle)
    assert(handle,"param handle is nil")
    self.__on_move_over_handle[handle] = nil
end
---@param self AutoMoveComponent
function lfunc.OnMoveOverHandleExist(self,handle)
    assert(handle,"param handle is nil")
    return self.__on_move_over_handle[handle]
end
---@param self AutoMoveComponent
function lfunc.CheckStop(self,v)
    if self.points and self.index >= #self.points then
        return
    end
    if self.__move_to and v == 0 then
        self.__move_failed = self.__move_failed + 1
        if self.__move_failed < 3
        and self.params.AgentCanJump ~= nil
        and self.params.AgentCanJump == true
        then
            ---@type Humanoid
            local humanoid = self.humanoid
            if humanoid then
                humanoid.Jump = true
            else
                self.__move_failed = 0
                self:StopMove()
            end
        else
            self.__move_failed = 0
            self:StopMove()
        end
    end
end
function c.new(parent)
    return c(parent)
end
---@param parent CharacterObject
function c:ctor(parent)
    c.super.ctor(self,parent)
    ---@type table<Part,boolean>
    self.marks = {}
    self.__on_move_over_handle = {}
    self.__move_failed = 0
    self.humanoid = parent:GetHumanoid_Check()
    self.root_part = parent:GetRootPart_Check()
    --获取外包矩形
    local size = parent:GetRootPart_Check().Size
    local height = size.Y + self.humanoid.HipHeight
    local radius = size.X
    self.params = {AgentRadius=radius,AgentHeight=height,AgentCanJump=true}
    self.path = PathfindingService:CreatePath(self.params)
    self.check_path = PathfindingService:CreatePath(self.params)
    callback_manager:AddRbxConnect(self,self.humanoid.Running,lfunc.CheckStop)
end

function c:SetCharacterHegiht(height)
    self.params.AgentHeight = height or self.parent:GetExtentsSize().Y
    self.path = PathfindingService:CreatePath(self.params)
    self.check_path = PathfindingService:CreatePath(self.params)
end
function c:SetCharacterRadius(radius)
    self.params.AgentRadius = radius or self.parent:GetExtentsSize().X
    self.path = PathfindingService:CreatePath(self.params)
    self.check_path = PathfindingService:CreatePath(self.params)
end
function c:SetCharacterCanJump(can_jump)
    if can_jump == nil then
        can_jump = false
    end
    self.params.AgentCanJump = can_jump
    self.path = PathfindingService:CreatePath(self.params)
end
function c:dtor()
    lfunc.CleanMark(self)
    c.super.dtor(self)
end
---@param pos Vector3
function c:MoveTo(pos,mark)
    if self.target_pos and (self.target_pos - pos).Magnitude <= 0.5 then
        return
    end
    if not self:IsExist() then
        return
    end
    self.target_pos = pos
    --如果之前有寻路的话，就把寻路给停了
    if not self.__find_path_cnnt then
        self.__find_path_cnnt = self:AddProcess(lfunc.FindPath,mark)
    end
    if not self.__update_cnnt then
        self.__update_cnnt = self:AddProcess(lfunc.Update)
    end
end
function c:GetPathLenght(pos)
    assert(pos,"param pos is nil")
    if not self.parent.main_inst then
        return -1
    end
    local path = self.check_path
    path:ComputeAsync(self.parent:GetPosition(),pos)
    if path.Status ~= Enum.PathStatus.Success then
        return -1
    else
        local len = 0
        local points = path:GetWaypoints()
        for i = 2,#points,1 do
            local pre_point = points[i-1]
            local next_point = points[i]
            if not next_point or not pre_point then
                break
            end
            len = len + (next_point.Position - pre_point.Position).Magnitude
        end
        if len == 0 then
            return -1
        else
            return len
        end
    end
end
function c:StopMove()
    if self.__find_path_cnnt then
        self.__find_path_cnnt:Disconnect()
        self.__find_path_cnnt = nil
    end
    if self.__update_cnnt then
        self.__update_cnnt:Disconnect()
        self.__update_cnnt = nil
    end
    ---@type CharacterObject
    local Character = self.parent
    local humanoid = self.humanoid
    local root_part = self.root_part
    if humanoid and root_part then
        humanoid:MoveTo(root_part.Position)
    end
    
end
function c:IsMoving()
    return self.__update_cnnt ~= nil
end
---@return HotpotConnection
function c:AddHandleOnMoveOver(handle,...)
    lfunc.AddHandleOnMoveOver(self,handle,...)
    local cnnt = hotpot_connection.new(self,lfunc.DelhandleOnMoveOver,lfunc.OnMoveOverHandleExist,handle)
    return cnnt
end
return c