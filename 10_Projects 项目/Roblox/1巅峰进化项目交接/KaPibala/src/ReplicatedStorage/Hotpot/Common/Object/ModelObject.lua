local _G = _G
local math = math
local ipairs = ipairs
local Vector3 = Vector3
local Vector2 = Vector2
local script = script
local assert = assert
local warn = warn
local hotpot = _G.CommonHotpot
local CFrame = CFrame
---@class ModelObject:GameObject
---@field main_inst Model
local c = hotpot.class.new(script,hotpot.files.GameObject())
function c.new(model)
    assert(model,"param model is nil")
    return c(model)
end
function c:ctor(model)
    c.super.ctor(self,model)
    self.__scale = 1
    self.__org_att = {}
    self.__org_size = {}
    self:GetRootPart_Check()
end
function c:dtor()
    c.super.dtor(self)
end
---@type fun(time_out:number):Part
---@param time_out number
---@return Part
function c:GetRootPart(time_out)
    if self.root_part then
        return self.root_part
    end
    local time_out = time_out or hotpot:GetDefaultTimeLimit()
    while not self.main_inst.PrimaryPart do
        time_out = time_out - wait()
        if time_out <= 0 then
            warn("model "..self.main_inst.Name.." wait complete time out,please check!")
            return
        end
    end
    self.root_part = self.main_inst.PrimaryPart
    return self.root_part
end
---@type fun(time_out:number):Part
---@param time_out number
---@return Part
function c:GetRootPart_Check(time_out)
    local root_part = self:GetRootPart()
    assert(root_part,"get root part faild")
    return root_part
end
---@type fun(time_out:number):Part
---@param time_out number
---@return Part
function c:GetRootPart_Loop(time_out)
    local root_part = self:GetRootPart(time_out)
    if not root_part then
        return self:GetRootPart_Loop(time_out)
    end
    return root_part
end
---@type fun():CFrame
---@return CFrame
function c:GetCenterCFrame()
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    local cframe,size = self.main_inst:GetBoundingBox()
    return cframe
end
---@type fun(cframe:CFrame)
---@param cframe CFrame
function c:SetCenterCFrame(cframe)
    assert(cframe,"param cframe is nil")
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    local pos = self:GetPosition()
    self:SetCFrame(CFrame.new(pos,pos+cframe.LookVector))
    self:SetCenterPosition(cframe.Position)
end
---@type fun():Vector3
---@return Vector3
function c:GetPosition()
    -- assert(self.main_inst,"object main inst is nil class name = "..self.class)
    return self:GetRootPart().Position
end
---@type fun(position:Vector3)
---@param position Vector3
function c:SetPosition(position)
    assert(position,"param position is nil")
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    self.main_inst:TranslateBy(position-self:GetPosition())
end
---@type fun(vect3:Vector3) @将模型偏移指定向量
---@param vect3 Vector3
function c:Offset(vect3)
    assert(vect3,"param offset vect3 is nil")
    local now_pos = self:GetPosition()
    self:SetPosition(now_pos+vect3)
end
---@type fun():Vector3
---@return Vector3
function c:GetCenterPosition()
    return self:GetCenterCFrame().Position
end
---@type fun(position:Vector3)
---@param position Vector3
function c:SetCenterPosition(position)
    assert(position,"param position is nil")
    local offset = self:GetPosition() - self:GetCenterPosition()
    self:SetPosition(position+offset)
end
---@type fun():Vector2
---@return Vector2
function c:GetPosition2D()
    local pos = self:GetPosition()
    local v2 = Vector2.new(pos.X,pos.Z)
    return v2
end
---@type fun():Vector3
---@return Vector3
function c:GetBottomPosition()
    local cf,size = self:GetBoundingBox()
    return cf.Position - Vector3.new(0,0.5*size.Y,0)
end
---@type fun(position:Vector2)
---@param position Vector2
function c:SetPosition2D(position)
    assert(position,"param position 2d is nil")
    local selfpos = self:GetPosition()
    self:SetPosition(Vector3.new(position.X,selfpos.Y,position.Z))
end
---@type fun(param:Vector3) @将rootPart移动指定向量位置
---@param position Vector3
function c:TranslateBy(position)
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    self.main_inst:TranslateBy(position)
end
---@type fun(param:Vector3) @将模型传送到指定位置，可能会因为附近有阻挡而将模型传送值目标点上方
---@param position Vector3
function c:TryMoveTo(position)
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    self.main_inst:MoveTo(position)
end
---@type fun():CFrame @获得模型的CFrame
---@return CFrame
function c:GetCFrame()
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    return self.main_inst:GetPrimaryPartCFrame()
end
---@type fun(param:CFrame) @设置模型的CFrame
---@param cframe CFrame
function c:SetCFrame(cframe)
    assert(cframe,"param cframe is nil")
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    self.main_inst:SetPrimaryPartCFrame(cframe)
end
---@type fun(param:CFrame) @以模型锚点设置CFrame，没有PrimaryPart会用默认锚点（中心）
---@param cframe CFrame
function c:PivotTo(cframe)
    assert(cframe,"param cframe is nil")
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    self.main_inst:PivotTo(cframe)
end

---@type fun() @获取模型锚点CFrame
function c:GetPivot()
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    return self.main_inst:GetPivot()
end

---@type fun(model_object:ModelObject):number
---@param model_object ModelObject
---@return number
function c:DistanceToModelObject(model_object)
    assert(model_object,"param model object is nil")
    return (self:GetPosition() - model_object:GetPosition()).Magnitude
end
---@type fun(position:Vector3):number
---@param position Vector3
---@return number
function c:DistanceToPosition(position)
    assert(position,"param position is nil")
    return (self:GetPosition() - position).Magnitude
end
---@type fun(position:Vector3):number
---@param position Vector3
---@return number
function c:DistanceToPosition2D(position)
    assert(position,"param position is nil")
    local self_vect_2d = self:GetPosition()
    self_vect_2d = Vector2.new(self_vect_2d.X,self_vect_2d.Z)
    local tag_vect_2d = Vector2.new(position.X,position.Z)
    return ( self_vect_2d - tag_vect_2d ).Magnitude
end
---@type fun(model_object:ModelObject):number
---@param model_object ModelObject
---@return number
function c:DistanceToModelObject2D(model_object)
    assert(model_object,"param model object is nil")
    local self_vect_2d = self:GetPosition()
    self_vect_2d = Vector2.new(self_vect_2d.X,self_vect_2d.Z)
    local tag_vect_2d = model_object:GetPosition()
    tag_vect_2d = Vector2.new(tag_vect_2d.X,tag_vect_2d.Z)
    return ( self_vect_2d - tag_vect_2d ).Magnitude
end
---@type fun():Vector3 @获得外包矩形的尺寸
---@return Vector3
function c:GetExtentsSize()
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    return self.main_inst:GetExtentsSize()
end
---@type fun() @破坏模型所有链接
function c:BreakJoints()
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    self.main_inst:BreakJoints()
end
---@type fun():CFrame,Vector3 @获得外包矩形的尺寸和位置
---@return CFrame,Vector3
function c:GetBoundingBox()
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    return self.main_inst:GetBoundingBox()
end
---@type fun():number
---@return number
function c:GetExtentsRadius2D()
    local size = self:GetExtentsSize()
    return (size.X+size.Z)/4
end
---@type fun(player_object:PlayerObject)
---@param player_object PlayerObject
function c:SetNetworkOwner(player_object)
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    local owner = player_object and player_object.main_inst
    if self.main_inst.Parent then
        for __,inst in ipairs(self.main_inst:GetDescendants()) do
            if inst:IsA("BasePart") then
                inst.Anchored = false
                inst:SetNetworkOwner(owner)
            end
        end
    else
        self:AddHandleOnInWorkspace(self.SetNetworkOwner,true,player_object)
    end
end
---@type fun():number
---@return number
function c:GetMass()
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    local mass = 0
    for __,inst in ipairs(self.main_inst:GetDescendants()) do
        if inst:IsA("BasePart") then
            mass = mass + inst:GetMass()
        end
    end
    return mass
end
---@type fun(switch:boolean)
---@param switch boolean
function c:SetCanCollide(switch)
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    if switch == nil then
        switch = false
    end
    for __,inst in ipairs(self.main_inst:GetDescendants()) do
        if inst:IsA("BasePart") then
            inst.CanCollide =  switch
        end
    end
end
---@type fun(pos:Vector3):Vector3
---@return Vector3
function c:GetPosDir2D(pos)
    local self_pos = self:GetPosition()
    return Vector3.new(pos.X - self_pos.X,0,pos.Z-self_pos.Z).Unit
end
---@type fun(scale:number)
---@param scale number
function c:SetScale(scale)
    self.__scale = scale
    local center_pos = self:GetCenterPosition()
    local root_part = self:GetRootPart_Check()
    local org_att = self.__org_att
    local org_size = self.__org_size
    for __,inst in ipairs(self.main_inst:GetDescendants()) do
        if inst:IsA("BasePart") then
            ---@type Attachment
            local mark_att = org_att[inst]
            if not mark_att then
                mark_att = Instance.new("Attachment",root_part)
                mark_att.Name = "__org_size"
                mark_att.WorldPosition = inst.Position
                mark_att:SetAttribute("size",inst.Size)
                org_att[inst] = mark_att
            end
            inst.Size = mark_att:GetAttribute("size") * scale
            inst.Position = root_part.Position:Lerp(mark_att.WorldPosition,scale)
        elseif inst:IsA("FileMesh") then
            if inst.MeshId and inst.MeshId ~= "" then
                local mark_scale = org_size[inst]
                if not mark_scale then
                    mark_scale = Instance.new("Vector3Value",root_part)
                    mark_scale.Name = "__org_scale"
                    mark_scale.Value = inst.Scale
                    org_size[inst] = mark_scale
                end
                inst.Scale = mark_scale.Value * scale
            end
        elseif inst:IsA("Bone") then
            local mark_att = org_att[inst]
            if not mark_att then
                mark_att = Instance.new("Attachment",root_part)
                mark_att.Name = "__org_pos"
                mark_att.Position = inst.Position
                org_att[inst] = mark_att
            end
            inst.Position = Vector3.zero:Lerp(mark_att.Position,scale)
        end
    end
    --位移
    self:SetCenterPosition(center_pos)
end
function c:CleanInvalidScaleMarks()
    local org_att = self.__org_att
    local org_size = self.__org_size
    for inst,mark_att in pairs(org_att) do
        if not inst.Parent then
            mark_att:Destroy()
            org_att[inst] = nil
        end
    end
    for inst,mark_scale in pairs(org_size) do
        if not inst.Parent then
            mark_scale:Destroy()
            org_size[inst] = nil
        end
    end
end
---@type fun(size:Vector3)
---@param size Vector3
function c:ScaleToSize(size)
    local min_tag = math.min(size.X,size.Y,size.X)
    local ex_size = self:GetExtentsSize() / self:GetScale()
    local max_self = math.max(ex_size.X,ex_size.Y,ex_size.Z)
    local scale = min_tag/max_self
    self:SetScale(scale)
end
---@type fun():number
---@return number
function c:GetScale()
    return self.__scale
end
---@type fun(transparency:number):number
---@return number
function c:SetTransparency(transparency)
    for __,inst in ipairs(self.main_inst:GetDescendants()) do
        if inst:IsA("BasePart") 
        or inst:IsA("Textture")
        then
            inst.Transparency = transparency
        end
    end
end
return c