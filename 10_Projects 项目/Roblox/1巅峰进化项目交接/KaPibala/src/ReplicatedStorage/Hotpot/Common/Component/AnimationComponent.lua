local _G = _G
local workspace = workspace
local script = script
local Instance = Instance
local hotpot = _G.CommonHotpot
local callback_manager = hotpot.load.CallBackManager()
---@class AnimationComponent:BaseComponent
---@field parent CharacterObject
---@field list table<string,AnimationTrack>
local c = hotpot.class.new(script,hotpot.files.BaseComponent())
function c:dtor()
    for name,animation in pairs(self.animation_list) do
        animation:Destroy()
    end
    self.animation_list = {}
    for name,track in pairs(self.track_list) do
        track:Destroy()
    end
    self.track_list = {}
    if self.main_inst then
        self.main_inst:Destroy()
    end
    c.super.dtor(self)
end
function c.new(parent)
    return c(parent)
end
---@param parent CharacterObject
function c:ctor(parent)
    c.super.ctor(self,parent)
    self:InitAnimationFolder()
    self:InitController()
    self:InitList()
    parent:AddHandleOnInWorkspace(function()
        self:InWorkspace()
    end)
end
function c:InitController()
    local parent = self.parent
    local controller = parent:GetHumanoid()
    if not controller then
        controller = Instance.new("AnimationController",parent.main_inst)
    end
    self.controller = controller
end
function c:InitAnimationFolder()
    local folder = Instance.new("Folder",self.parent.main_inst)
    folder.Name = "AniamtionComponent"
    self:SetMainInst(folder)
end
function c:CreateAnimation(name,id)
    local r,e = xpcall(function()
        local animation = Instance.new("Animation",self.main_inst)
        animation.Name = name
        animation.AnimationId = "http://www.roblox.com/asset/?id="..tostring(id)
        return animation
    end,debug.traceback)
    if not r then
        warn(e)
        return
    end
    return e
end
function c:LoadAnimation(animation)
    local track = self.controller:LoadAnimation(animation)
    track.Name = animation.Name
    return track
end
function c:InitList()
    ---@type table<string,Animation>
    local animation_list = {}
    ---@type table<string,AnimationTrack>
    local track_list = {}
    local meta = {}
    local cpnt = self
    self.animation_list = animation_list
    self.track_list = track_list
    function meta:__newindex(key,val)
        if val then
            --判断是否处于workspace下，如果不在那么就存字符串，等待进入场景后创建动画信息，如果存在，那么直接读取生成track
            local character = cpnt.parent
            local animation = cpnt:CreateAnimation(key,val)
            if not animation then
                return
            end
            animation_list[key] = animation
            if cpnt.controller:IsDescendantOf(workspace) then
                track_list[key] = cpnt:LoadAnimation(animation)
            end
        else
            ---注销动画
            ---@type Animation
            local animation = animation_list[key]
            if animation then
                animation:Destroy()
            end
            ---@type AnimationTrack
            local track = track_list[key]
            if track then
                track:Stop()
                track:Destroy()
            end
        end
    end
    function meta:__index(key)
        if animation_list[key] and not track_list[key] then
            warn("animation "..key.." havent be loaded!")
        end
        return track_list[key]
    end
    self.list = setmetatable({},meta)
end
---@return HotpotConnection
function c:AddHandleOnStop(name,handle,...)
    assert(self.animation_list[name],"no animation named "..name)
    local arg = {...}
    if not self.parent.main_inst:IsDescendantOf(workspace) then
        self.__on_stop_handles = self.__on_stop_handles or {}
        self.__on_stop_handles[name] = self.__on_stop_handles[name] or {}
        self.__on_stop_handles[name][handle] = arg
        warn("character is not in work space,no connection return")
    else
        local track = self.list[name]
        local cnnt = callback_manager:AddRbxConnect(self,track.Stopped,function()
            handle(table.unpack(arg))
        end)
        return cnnt
    end
end
---@return HotpotConnection
function c:AddHandleOnMark(name,mark,handle,...)
    assert(self.animation_list[name],"no animation named "..name)
    local arg = {...}
    if not self.parent.main_inst:IsDescendantOf(workspace) then
        self.__on_mark_handles = self.__on_mark_handles or {}
        self.__on_mark_handles[name] = self.__on_mark_handles[name] or {}
        self.__on_mark_handles[name][mark] = self.__on_mark_handles[name][mark] or {}
        self.__on_mark_handles[name][mark][handle] = arg
        warn("character is not in work space,no connection return")
    else
        local track = self.list[name]
        local cnnt = callback_manager:AddRbxConnect(self,track:GetMarkerReachedSignal(mark),function()
            handle(table.unpack(arg))
        end)
        return cnnt
    end
end
---@return HotpotConnection
function c:AddHandleOnLoop(name,handle,...)
    assert(self.animation_list[name],"no animation named "..name)
    local arg = {...}
    if not self.parent.main_inst:IsDescendantOf(workspace) then
        self.__on_looped_handles = self.__on_looped_handles or {}
        self.__on_looped_handles[name] = self.__on_looped_handles[name] or {}
        self.__on_looped_handles[name][handle] = arg
        warn("character is not in work space,no connection return")
    else
        local track = self.list[name]
        local cnnt = callback_manager:AddRbxConnect(self,track.DidLoop,function()
            handle(table.unpack(arg))
        end)
        return cnnt
    end
end
function c:InWorkspace()
    --先将所有的animation转换为track
    local track_list = self.track_list
    local animation_list = self.animation_list
    for name,animation in pairs(animation_list) do
        if not track_list[name] then
            track_list[name] = self:LoadAnimation(animation)
        end
    end
    --便利所有需要标记的事件，进行事件监听并返回
    local on_stop_handles = self.__on_stop_handles
    if on_stop_handles then
        for name,handles in pairs(on_stop_handles) do
            local track = track_list[name]
            for handle,arg in pairs(handles) do
                callback_manager:AddRbxConnect(self,track.Stopped,function()
                    handle(table.unpack(arg))
                end)
            end
        end
    end
    self.__on_stop_handles = nil
    local on_mark_handles = self.__on_mark_handles
    if on_mark_handles then
        for name,marks in pairs(on_mark_handles) do
            local track = track_list[name]
            for mark,handles in pairs(marks) do
                for handle,arg in pairs(handles) do
                    callback_manager:AddRbxConnect(self,track:GetMarkerReachedSignal(mark),function()
                        handle(table.unpack(arg))
                    end)
                end
            end
        end
    end
    self.__on_mark_handles = nil
    local on_looped_handles = self.__on_looped_handles
    if on_looped_handles then
        for name,handles in pairs(on_looped_handles) do
            local track = track_list[name]
            for handle,arg in pairs(handles) do
                callback_manager:AddRbxConnect(self,track.DidLoop,function()
                    handle(table.unpack(arg))
                end)
            end
        end
    end
    self.__on_looped_handles = nil
end
return c