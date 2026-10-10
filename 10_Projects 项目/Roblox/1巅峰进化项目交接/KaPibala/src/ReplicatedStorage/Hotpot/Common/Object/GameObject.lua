local _G = _G
local workspace = workspace
local table = table
local ipairs = ipairs
local script = script
local pairs = pairs
local assert = assert
local wait = wait
local next = next
local hotpot = _G.CommonHotpot
local instance_manager = hotpot.load.InstanceManager()
local callback_manager = hotpot.load.CallBackManager()
local object_manager = hotpot.load.ObjectManager()
---@class GameObject:BaseObject
---@field main_inst Instance
local c = hotpot.class.new(script,hotpot.files.BaseObject())
function c:ctor(inst,parent)
    assert(inst,"param inst is nil")
    c.super.ctor(self)
    self:SetMainInst(inst)
    ---@type table<string,BaseComponent>
    self.__components = {}
end
function c:dtor()
    --析构所有的组件
    for component_name,component in pairs(self.__components) do
        -- component:AddProcess(component.dtor)
        -- component:AddProcess(function()
        local co = coroutine.create(function()
            local r,e = xpcall(component.dtor,debug.traceback,component)
            if not r then
                warn(e)
                component[component_name] = nil
                object_manager:DelObject(component)
            end
        end)
        local cr,ce = coroutine.resume(co)
        if not cr then
            warn(ce)
        end
        -- end)
    end
    --等待所有组件析构结束
    local start_clock = os.clock()
    while next(self.__components) and os.clock() - start_clock <= 10 do
        -- self:Wait()
        wait()
    end
    self:DelMainInst()
    --检查是否所有组件都析构完毕
    c.super.dtor(self)
end
---@type fun(component_class:BaseComponent):BaseComponent
---@param component_class BaseComponent
---@return BaseComponent
function c:AddComponent(component_class)
    if not self:IsExist() then
        return
    end
    local component_name = component_class.class
    local component = self.__components[component_name]
    if not component then
        component = component_class.new(self)
    end
    return component
end
function c:GetComponent(component_class)
    local component = self.__components[component_class.class]
    return component
end
---@type fun():GameObject[]
---@return GameObject[]
function c:GetChildrenObjects()
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    local insts = self.main_inst:GetChildren()
    local objects = {}
    for __,inst in ipairs(insts) do
        local object = instance_manager:FindObject(inst)
        table.insert(objects,object)
    end
    return objects
end
---@type fun():GameObject
---@return GameObject
function c:GetParentObject()
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    local parent_inst = self.main_inst.Parent
    if parent_inst then
        return instance_manager:FindObject(parent_inst)
    end
end
---@type fun():string
---@return string
function c:GetName()
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    return self.main_inst.Name
end
---@type fun(name:string)
---@param name string
function c:SetName(name)
    assert(name,"param name is nil")
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    self.main_inst.Name = name
end
---@type fun(object:GameObject)
---@param object GameObject
function c:SetParentObject(object)
    assert(object,"param object is nil")
    assert(object.main_inst,"parent object main inst is nil class name = "..object.class)
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    self.main_inst.Parent = object.main_inst
end
---@type fun(inst:Instance)
---@param inst Instance
function c:SetParentInstance(inst)
    -- assert(inst,"param object is nil")
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    self.main_inst.Parent = inst
end
---@type fun(handle:function,onece:boolean,...):HotpotConnection
---@param handle function
---@param onece boolean
---@return HotpotConnection
function c:AddHandleOnParentChange(handle,onece,...)
    assert(handle,"param handle is ni")
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    local args = {...}
    local cnnt
    cnnt = callback_manager:AddRbxConnect(self,self.main_inst.Changed,function(game_object,prop_name)
        if prop_name == "Parent" then
            if onece then
                cnnt:Disconnect()
            end
            handle(game_object,game_object.main_inst.Parent,table.unpack(args))
        end
    end)
    -- local cnnt
    -- local rbx_cnnt = self.main_inst.Changed:Connect(function(param_name)
    --     if param_name == "Parent" then
    --         handle(self,table.unpack(args))
    --         if onece then
    --             cnnt:Disconnect()
    --         end
    --     end
    -- end)
    -- cnnt = hotpot_connection.new(rbx_cnnt,rbx_cnnt.Disconnect,function()
    --     return rbx_cnnt.Connected
    -- end)
    return cnnt
end
---@type fun(handle:function,onece:boolean,...):HotpotConnection
---@param handle function
---@param onece boolean
---@return HotpotConnection
function c:AddHandleOnInWorkspace(handle,onece,...)
    assert(handle,"param handle is nil")
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    local args = {...}
    local cnnt
    cnnt = self:AddHandleOnParentChange(function(__,parent)
        if parent and parent:IsDescendantOf(workspace) then
            handle(self,parent,table.unpack(args))
        end
    end,onece,table.unpack(args))
    return cnnt
end
return c