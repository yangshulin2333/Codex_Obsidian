local ANIMATE_FADE = 0.1
local WALK_SPEED = 8
local RUN_SPEED = 16

local _G = _G
local table = table
local script = script
local assert = assert
local ipairs = ipairs
local pairs = pairs
local tostring = tostring
local Instance = Instance
local hotpot = _G.CommonHotpot
---@class CharacterAnimationComponent:BaseComponent
local c = hotpot.class.new(script,hotpot.files.BaseComponent())
--本地函数定义
local lfunc = {}
---@type CharacterAnimationComponent
function lfunc.GetTrack(self,name)
    assert(name,"param name is nil")
    local animations = self.animations
    local info = animations[name]
    assert(info,"no animation info for "..name)
    local rnd_weight = hotpot:Random(1,info.weight)
    for idx,a_info in ipairs(info.tracks) do
        rnd_weight = rnd_weight - a_info.weight
        if rnd_weight <= 0 then
            return a_info.track
        end
    end
end
---@param self CharacterAnimationComponent
function lfunc.SwitchBaseAnimate(self,name)
    local old_name
    if self.__current_base_animation then
        old_name = self.__current_base_animation.name
    end
    if old_name ~= name then
        if old_name then
            self:Stop(old_name)
        end
        self:Play(name)
        self.__current_base_animation = self.__action_animtions[name]
        if self.__current_tool_hold then
            self:Play(self.__current_tool_hold)
        end
    end
end
---@param self CharacterAnimationComponent
function lfunc.SetBaseAnimateSpeed(self,speed)
    if self.__current_base_animation then
        local name = self.__current_base_animation.name
        self:SetSpeed(name,speed)
    end
end
--状态关联
---@param self CharacterAnimationComponent
function lfunc.OnRunning(self,speed)
    if speed == 0 then
        lfunc.SwitchBaseAnimate(self,"idle")
    elseif speed <= WALK_SPEED then
        lfunc.SwitchBaseAnimate(self,"walk")
        lfunc.SetBaseAnimateSpeed(self,speed/WALK_SPEED)
    else
        lfunc.SwitchBaseAnimate(self,"run")
        lfunc.SetBaseAnimateSpeed(self,speed/RUN_SPEED)
    end
end
---@param self CharacterAnimationComponent
function lfunc.OnJumping(self,active)
    if active then
        lfunc.SwitchBaseAnimate(self,"jump")
    end
end
---@param self CharacterAnimationComponent
function lfunc.OnClimbing(self,speed)
    lfunc.SwitchBaseAnimate(self,"climb")
    lfunc.SetBaseAnimateSpeed(self,speed/RUN_SPEED)
end
---@param self CharacterAnimationComponent
function lfunc.OnFallingDown(self,active)
    if active then
        lfunc.SwitchBaseAnimate(self,"fall")
    end
end
---@param self CharacterAnimationComponent
function lfunc.OnFreeFall(self,active)
    if active then
        lfunc.SwitchBaseAnimate(self,"fall")
    end
end
---@param self CharacterAnimationComponent
function lfunc.OnSeated(self,active,seat_part)
    if active then
        lfunc.SwitchBaseAnimate(self,"sit")
    end
end
---@param self CharacterAnimationComponent
function lfunc.OnSwimming(self,speed)
    if speed <= 0 then
        lfunc.SwitchBaseAnimate(self,"swimidle")
    else
        lfunc.SwitchBaseAnimate(self,"swim")
        lfunc.SetBaseAnimateSpeed(self,speed/RUN_SPEED)
    end
end
---@param self CharacterAnimationComponent
function lfunc.OnDied(self)
    self:StopAllAnimation()
end
---@param self CharacterAnimationComponent
function lfunc:OnGettingUp(self,active)
    if active then
        self:StopAllAnimation()
    end
end
---@param self CharacterAnimationComponent
function lfunc.OnPlatformStanding(self,active)
    if active then
        self:StopAllAnimation()
    end
end
function lfunc.OnHoldTool(self,active,tool)
    if active then
        --先尝试寻找tool下面的动画，一个是持有，一个是使用，如果没有，那么就使用默认的配置的动画
        if tool and tool:FindFirstChild("Handle") then
            local tool_hold = tool:FindFirstChild("tool_hold")
            if tool_hold then
                self:UninstallAnimation("new_tool_hold")
                self.animations.new_tool_hold = self:LoadAnimationWithInst(tool_hold)
                if #self.animations.new_tool_hold.tracks == 0 then
                    self.animations.new_tool_hold = nil
                end
            end
            local tool_action = tool:FindFirstChild("tool_action")
            if tool_action then
                self:UninstallAnimation("new_tool_action")
                self.animations.new_tool_action = self:LoadAnimationWithInst(tool_action)
                if #self.animations.new_tool_action == 0 then
                    self.animations.new_tool_action = nil
                end
            end
            self.__current_tool_hold = self.animations.new_tool_hold and "new_tool_hold" or "tool_hold"
            self.__current_tool_action = self.animations.new_tool_action and "new_tool_action" or "tool_action"
            self:Play(self.__current_tool_hold)
        end
    else
        self:UninstallAnimation("new_tool_hold")
        self:UninstallAnimation("new_tool_action")
        self:Stop(self.__current_tool_hold)
        self.__current_tool_hold = nil
        self.__current_tool_action = nil
    end
end
function lfunc.OnToolAction(self,active)
end
---@param self CharacterAnimationComponent
function lfunc.LinkStates(self)
    local humanoid = self.parent:GetHumanoid_Check()
    self.__state_rbxs = {}
    self.__state_rbxs.died = humanoid.Died:Connect(function()
        lfunc.OnDied(self)
    end)
    self.__state_rbxs.running = humanoid.Running:Connect(function(speed)
        lfunc.OnRunning(self,speed)
    end)
    self.__state_rbxs.jumping = humanoid.Jumping:Connect(function(active)
        lfunc.OnJumping(self,active)
    end)
    self.__state_rbxs.climbing = humanoid.Climbing:Connect(function(speed)
        lfunc.OnClimbing(self,speed)
    end)
    self.__state_rbxs.getting_up = humanoid.GettingUp:Connect(function(active)
        lfunc.OnGettingUp(self,active)
    end)
    self.__state_rbxs.free_falling = humanoid.FreeFalling:Connect(function(active)
        lfunc.OnFreeFall(self,active)
    end)
    self.__state_rbxs.falling_down = humanoid.FallingDown:Connect(function()
        lfunc.OnFallingDown(self)
    end)
    self.__state_rbxs.seated = humanoid.Seated:Connect(function(active,seat_part)
        lfunc.OnSeated(self,active,seat_part)
    end)
    self.__state_rbxs.platform_standing = humanoid.PlatformStanding:Connect(function(active)
        lfunc.OnPlatformStanding(self)
    end)
    self.__state_rbxs.swimming = humanoid.Swimming:Connect(function(speed)
        lfunc.OnSwimming(self,speed)
    end)
    self.__state_rbxs.tool_add = self.parent.main_inst.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            lfunc.OnHoldTool(self,true,child)
        end
    end)
    self.__state_rbxs.tool_remove = self.parent.main_inst.ChildRemoved:Connect(function(child)
        if child:IsA("Tool") then
            local tool = self.parent.main_inst:FindFirstAncestorOfClass("Tool")
            if tool then
                lfunc.OnHoldTool(self,true,tool)
            else
                lfunc.OnHoldTool(self,false)
            end
        end
    end)
end
---@param self CharacterAnimationComponent
function lfunc.DelHandleOnDidLoop(self,info)
    local animations = self.animations[info.name]
    if animations then
        local on_did_loop = animations.on_did_loop
        if on_did_loop then
            on_did_loop[info.handle] = nil
        end
    end
end
---@param self CharacterAnimationComponent
function lfunc.HandleOnDidLoopExist(self,info)
    local animations = self.animations[info.name]
    if animations then
        local on_did_loop = animations.on_did_loop
        if on_did_loop then
            return on_did_loop[info.handle]
        end
    end
end
---@param self CharacterAnimationComponent
function lfunc.DelHandleOnStopped(self,info)
    local animations = self.animations[info.name]
    if animations then
        local on_stopped = animations.on_stopped
        if on_stopped then
            on_stopped[info.handle] = nil
        end
    end
end
---@param self CharacterAnimationComponent
function lfunc.HandleOnStoppedExist(self,info)
    local animations = self.animations[info.name]
    if animations then
        local on_stopped = animations.on_stopped
        if on_stopped then
            return on_stopped[info.handle]
        end
    end
end
---@param self CharacterAnimationComponent
function lfunc.DelHandleOnMark(self,info)
    local animations = self.animations[info.name]
    if animations then
        local on_mark = animations.on_mark
        if on_mark then
            local handles = on_mark[info.mark]
            if handles then
                handles[info.handle] = nil
            end
        end
    end
end
---@param self CharacterAnimationComponent
function lfunc.HandleOnMarkExist(self,info)
    local animations = self.animations[info.name]
    if animations then
        local on_mark = animations.on_mark
        if on_mark then
            local handles = on_mark[info.mark]
            if handles then
                return handles[info.handle]
            end
        end
    end
end
---@param self CharacterAnimationComponent
---@param track AnimationTrack
function lfunc.Play(self,name,track,speed,action_time)
    self.__action_animtions[name] = self.__action_animtions[name] or {name=name,rbxs={},speed = speed,action_time = action_time}
    local anima_info = self.__action_animtions[name]
    if anima_info.track ~= track or not track.IsPlaying then
        speed = speed or anima_info.speed or 1
        action_time = action_time or anima_info.action_time
        if anima_info.track and anima_info.track.IsPlaying then
            anima_info.track:Stop(ANIMATE_FADE)
        end
        for rbx_name,rbx in pairs(anima_info.rbxs) do
            rbx:Disconnect()
            anima_info.rbxs[rbx_name] = nil
        end
        anima_info.track = track
        local animations = self.animations[name]
        if track.Looped and #animations.tracks > 1 then
            --因为是要重复播的，所以要监听循环，并尝试进行切换
            anima_info.rbxs.did_loop = track.DidLoop:Connect(function()
                self:Play(name,track.Speed)
            end)
        end
        local animations = self.animations[name]
        --如果注册了事件监听，那么就在这个地方进行关联
        if animations.on_did_loop then
            for handle,__ in pairs(animations.on_did_loop) do
                anima_info.rbxs[handle] = track.DidLoop:Connect(function()
                    handle(self.parent)
                end)
            end
        end
        if animations.on_stopped then
            for handle,__ in pairs(animations.on_stopped) do
                anima_info.rbxs[handle] = track.Stopped.Connect(function()
                    handle(self.parent)
                end)
            end
        end
        if animations.on_mark then
            for mark,handles in pairs(animations.on_mark) do
                for handle,__ in pairs(handles) do
                    local temp_rbx = track:GetMarkerReachedSignal(mark):Connect(function()
                        handle(self.parent)
                    end)
                    anima_info.rbxs[temp_rbx] = temp_rbx
                end
            end
        end
        track:Play(ANIMATE_FADE)
        if action_time then
            local anime_time = track.Length
            speed = anime_time/action_time
        end
        track:AdjustSpeed(speed)
        return track
    end
end
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)
    --创建相关示例
    local folder = Instance.new('Folder',parent.main_inst)
    folder.Name = "CharacterAnimationComponent"
    self:SetMainInst(folder)
    self.__action_animtions = {}
end
function c:dtor()
    c.super.dtor(self)
end
function c:UninstallAnimation(name)
    local animations = self.animations[name]
    if animations then
        for __,info in ipairs(animations.tracks) do
            if info.track.IsPlaying then
                info.track:Stop()
            end
            info.track:Destroy()
        end
        self.animations[name] = nil
    end
end
---@param inst Instance
function c:LoadAnimationWithInst(inst)
    local humanoid = self.parent:GetHumanoid_Check()
    local animations = {tracks={},weight=0}
    for __,val_inst in ipairs(inst:GetChildren()) do
        if val_inst:IsA("StringValue") then
            local name = val_inst.Name
            animations[name] = {}
            animations[name].weight = 0
            animations[name].tracks = {}
            for ___,animation in ipairs(val_inst:GetChildren()) do
                if animation:IsA("Animation") then
                    local track = humanoid:LoadAnimation(animation)
                    local weight_obj = animation:FindFirstChild("weight")
                    if not weight_obj or not weight_obj:IsA("NumberValue") then
                        weight_obj = nil
                    end
                    local weight = (weight_obj and weight_obj.Value) or 1
                    animations[name].weight = animations[name].weight + weight
                    table.insert(animations[name].tracks,{track=track,weight=animations[name].weight})
                end
            end
        end
    end
    self.animations = animations
    lfunc.LinkStates(self)
    return animations
end
function c:LoadAnimationsWithConfig(animations_config)
    if self.parent.main_inst.Parent then
        local humanoid = self.parent:GetHumanoid_Check()
        local animations = {}
        local animate_folder = Instance.new('Folder',self.main_inst)
        animate_folder.Name = "config_animates"
        self.animate_folder = animate_folder
        for name,anims in pairs(animations_config) do
            animations[name] = {}
            animations[name]["weight"] = 0
            animations[name]["tracks"] = {}
            local animate_obj = Instance.new('StringValue',self.animate_folder)
            animate_obj.Name = name
            for idx,info in ipairs(anims) do
                animations[name]["weight"] = animations[name]["weight"] + info.weight
                local temp_name = name..tostring(idx)
                ---@type Animation
                local animate = Instance.new('Animation',animate_obj)
                animate.Name = temp_name
                animate.AnimationId = info.id
                local weight_obj = Instance.new("NumberValue",animate)
                weight_obj.Name = "weight"
                weight_obj.Value = info.weight
                local track = humanoid:LoadAnimation(animate)
                track.Name = temp_name
                table.insert(animations[name]["tracks"],{track = track,weight=info.weight})
            end
        end
        self.animations = animations
        lfunc.LinkStates(self)
    else
        -- ---@type HotpotConnection
        -- local connect
        -- connect = self.parent:AddHandleOnParentInWorkspace(function()
        --     self:LoadAnimationsWithConfig(animations_config)
        --     connect:Disconnect()
        -- end)
        self.parent:AddHandleOnInWorkspace(function()
            self:LoadAnimationsWithConfig(animations_config)
        end,true)
    end
end
function c:StopAllAnimation()
    local humanoid = self.parent:GetHumanoid_Check()
    for __,track in ipairs(humanoid:GetPlayingAnimationTracks()) do
        track:Stop()
    end
end
function c:Play(name,speed,action_time)
    local animations = self.animations[name]
    if animations then
        ---@type AnimationTrack
        local track = lfunc.GetTrack(self,name)
        if track then
            return lfunc.Play(self,name,track,speed,action_time)
        end
    end
end
function c:SetSpeed(name,speed)
    speed = speed or 1
    local animat_info = self.__action_animtions[name] or {rbxs = {},name = name,speed = speed}
    ---@type AnimationTrack
    local track = animat_info.track
    if track then
        track:AdjustSpeed(speed)
    end
end
function c:Stop(name)
    local animat_info = self.__action_animtions[name] or {rbxs = {},name = name}
    ---@type AnimationTrack
    local track = animat_info.track
    if track then
        if track.IsPlaying then
            track:Stop(ANIMATE_FADE)
        end
    end
end
function c:Pause(name)
    local animat_info = self.__action_animtions[name] or {rbxs = {},name=name}
    ---@type AnimationTrack
    local track = animat_info.track
    if track then
        if track.IsPlaying then
            track:AdjustSpeed(0)
        end
    end
end
function c:IsPlaying(name)
    local action = self.action_animation[name]
    if action then
        ---@type AnimationTrack
        local track = action.track
        if track then
            return track.IsPlaying
        end
    end
end
return c