local _G = _G
local script = script
local assert = assert
local print = print
local type = type
local next = next
local pairs = pairs
local ipairs = ipairs
local pcall = pcall
local table = table
local warn = warn
local hotpot = _G.ClientHotpot
local pool_rescource_pool = hotpot.load.PoolRescourcePathCfg
local Resource_Path = "ReplicatedStorage.Resource."
---@class InstancePool
local c = hotpot.class.new(script,hotpot.files.BaseObject())
function c.new()
    return c()
end
---@type fun()
function c:ctor()
    c.super.ctor(self)
    --已加载的资源表
    self.load_ui_list = {}
    self.load_other_list = {}
    self:AddProcess(self.LoadAllResource)
end
---@type fun():table
---@return table
function c:InitResourcePath()
    if not pool_rescource_pool then
        return 
    end
    if not next(pool_rescource_pool) then
        return
    end
    local list = {}
    for name,path_tab in pairs(pool_rescource_pool) do
        if path_tab and next(path_tab) then
            for b_type,str in pairs(path_tab) do
                local id = name.."_"..b_type
                list[id] = Resource_Path..str
            end
        end
    end
    return list
end
---@type fun(c_type:string,inst:Instance)
---@param c_type string
---@param inst Instance
function c:AddPoolList(c_type,inst)
    assert(c_type,"c_type is nil")
    assert(inst,"inst is nil")
    local name = inst.Name
    if not name then
        return
    end  
    if not self.resource_pool[c_type] then
        self.resource_pool[c_type] = {}
    end
    if self.resource_pool[c_type][name] then
        return
    end
    self.resource_pool[c_type][name] = {}
end
---@type fun(c_type:string,folder:Instance)
---@param c_type string
---@param folder Instance
function c:TraverseFolder(c_type,folder)
    assert(c_type,"c_type is nil")
    assert(folder,"folder is nil")
    for _,inst in ipairs(folder:GetChildren()) do
       self:AddPoolList(c_type,inst)
    end
end
---@type fun()
function c:InitResourcePool()
    self.resource_path_list = self:InitResourcePath()
    if not self.resource_path_list or not next(self.resource_path_list) then
        return  
    end
    --实例表
    self.resource_pool = {}
    --资源文件夹
    local folder,r,e
    for c_type,path in pairs(self.resource_path_list) do
        folder = nil
        r,e = pcall(function()
            folder = hotpot:GetPath_Loop(path)
        end)
        if not r then
            warn(e..c_type)
        end
        if folder then
            self:TraverseFolder(c_type,folder)
        end
    end
end
---@type fun(c_type:string,name:string):boolean|Instance
---@param c_type string
---@param name string
---@return boolean|Instance
function c:GetResourceInstance(c_type,name)
    assert(type(c_type)=="string","传入的参数不是字符串！")
    assert(type(name)=="string","传入的参数不是字符串！")
    local inst
    if not self.resource_pool[c_type] or not self.resource_pool[c_type][name]  then
        print("传入的名字找不到模型！:"..c_type..name)
        return false
    end
    if next(self.resource_pool[c_type][name]) then
        inst = self.resource_pool[c_type][name][1]
        table.remove(self.resource_pool[c_type][name],1)
        return inst
    end
    if not self.resource_path_list[c_type] then
        print("该类型未加入到路径表中！")
        return false
    end
    inst = hotpot:GetPath_Check(name,self.resource_path_list[c_type])
    if not inst then
        warn("not "..name.."in "..c_type)
        return false
    end
    local model = hotpot:CloneInst_Loop(inst)
    if not model then
        return false
    end
    return model
end
---@type fun(c_type:string,inst:Instance)
---@param c_type string
---@param inst Instance
function c:DelInstance(c_type,inst)
    assert(type(c_type)== "string","传入错误的参数！")
    assert(type(inst)== "userdata","传入错误的参数！")
    local name = inst.Name
    if not self.resource_pool[c_type] or not self.resource_pool[c_type][name] then
        self:AddPoolList(c_type,inst)
    end
    table.insert(self.resource_pool[c_type][name],inst)
    inst.Parent = nil
end
---@type fun(folder:Folder)
---@param folder Folder
function c:LoadResource(folder)
    assert(folder,"folder is nil")
    local folder_list = folder:GetDescendants()
    if not folder_list or not next(folder_list) then
        return
    end
    for _,inst in ipairs(folder_list) do
        local baseurl
        if inst:IsA("ImageLabel") or inst:IsA("ImageButton") then
            baseurl = inst.Image
        elseif inst:IsA("MeshPart") then
            baseurl = inst.MeshId
        elseif inst:IsA("Trail") or inst:IsA("Beam") or inst:IsA("ParticleEmitter") then
            baseurl = inst.Texture
        end
        if baseurl then
            if baseurl and not self.load_ui_list[baseurl] then
               self:AddProcess(function()
                    local r,e = pcall(function()
                        game:Load(baseurl)
                    end)
                    if not r then
                        warn(e,baseurl)
                    end
                    self.load_ui_list[baseurl] = true
                end)
            end
        end
    end
end
---@type fun()
function c:LoadAllResource()
    local resource_folder = hotpot:GetPath("ReplicatedStorage.Resource")
    for _,folder in ipairs(resource_folder:GetChildren()) do
        for _,folder_mark in ipairs(folder:GetChildren()) do
            self:AddProcess(self.LoadResource,folder_mark)
        end
    end
end
return c