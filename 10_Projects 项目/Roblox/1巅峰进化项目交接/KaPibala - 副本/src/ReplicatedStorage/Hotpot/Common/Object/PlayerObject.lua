local _G = _G
local print = print
local tostring = tostring
local game = game
local Enum = Enum
local warn = warn
local debug = debug
local Instance = Instance
local xpcall = xpcall
local script = script
local assert = assert
---@type Players
local Players = game:GetService("Players")
local hotpot = _G.CommonHotpot
---@class PlayerObject:GameObject
local c = hotpot.class.new(script,hotpot.files.GameObject())
local CameraMode = {
    Classic = 0,
    LockFirstPerson = 1,
    [0] = "Classic",
    [1] = "LockFirstPerson",
}
local DevCameraOcclusionMode = {
    UserChoice = 0,
    Classic = 1,
    Follow = 2,
    Orbital = 3,
    CameraToggle = 4,
    [0] = "UserChoice",
    [1] = "Classic",
    [2] = "Follow",
    [3] = "Orbital",
    [4] = "CameraToggle",
}
local DevTouchMovementMode = {
    UserChoice = 0,
    Thumbstick = 1,
    DPad = 2,
    Thumbpad = 3,
    ClickToMove = 4,
    Scriptable = 5,
    DynamicThumbstick = 6,
}
local DevComputerMovementMode = {
    UserChoice = 0,
    KeyboardMouse = 1,
    ClickToMove = 2,
    Scriptable = 3,
    [0] = "Scriptable"
}
local MembershipType = {
    None = 0,
    BuildersClub = 1,
    TurboBuildersClub = 2,
    OutrageousBuildersClub = 3,
    Premium = 4,
}
local ThumbnailType = {
    AvatarBust = Enum.ThumbnailType.AvatarBust,
    AvatarThumbnail = Enum.ThumbnailType.AvatarThumbnail,
    HeadShot = Enum.ThumbnailType.HeadShot,
}
local ThumbnailSize = {
    Size48x48 = Enum.ThumbnailSize.Size48x48,
    Size180x180 = Enum.ThumbnailSize.Size180x180,
    Size420x420 = Enum.ThumbnailSize.Size420x420,
    Size60x60 = Enum.ThumbnailSize.Size60x60,
    Size100x100 = Enum.ThumbnailSize.Size100x100,
    Size150x150 = Enum.ThumbnailSize.Size150x150,
    Size352x352 = Enum.ThumbnailSize.Size352x352,
}
---@type fun(player_instance:Player):PlayerObject
---@param player_instance Player
---@return PlayerObject
function c.new(player_instance)
    assert(player_instance,"param player instance is nil")
    return c(player_instance)
end
---@param player_instance Player
function c:ctor(player_instance)
    c.super.ctor(self,player_instance)
    self.user_id = player_instance.UserId
end
function c:dtor()
    c.super.dtor(self)
end
---@type fun():number @描述玩家的账户注册时长（以天为单位）。
---@return number @注册时长（天）
function c:GetAccountAge()
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    return self.main_inst.AccountAge
end
---@type fun(param:number) @设置玩家的账户注册时长
---@param age number
function c:SetAccountAge(age)
    assert(age,"param age is nil")
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    self.main_inst:SetAccountAge(age)
end
---@type fun():boolean @获得决定使用移动设备的玩家角色是否会在遇到障碍物时自动跳跃。
---@return boolean
function c:GetAutoJumpEnabeld()
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    return self.main_inst.AutoJumpEnabled
end
---@type fun(param:boolean) @设置决定使用移动设备的玩家角色是否会在遇到障碍物时自动跳跃。
---@param switch boolean
function c:SetAutoJumpEnabeld(switch)
    if switch == nil then
        switch = false
    end
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    self.main_inst.AutoJumpEnabled = switch
end
---@type fun():number @获得玩家镜头的最大拉近距离。
---@return number
function c:GetCameraMaxZoomDistance()
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    return self.main_inst.CameraMaxZoomDistance
end
---@type fun(param:number) @设置玩家镜头的最大拉近距离。
---@param distance number
function c:SetCameraMaxZoomDistance(distance)
    assert(distance,"param distance is nil")
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    self.main_inst.CameraMaxZoomDistance = distance
end
---@type fun():number @获得玩家镜头的最大拉近距离
---@return number
function c:GetCameraMinZoomDistance()
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    return self.main_inst.CameraMinZoomDistance
end
---@type fun(param:number) @设置玩家镜头的最大拉近距离
function c:SetCameraMinZoomDistance(distance)
    assert(distance,"param distance is nil")
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    self.main_inst.CameraMinZoomDistance = distance
end
---@type fun():string @获得当前镜头模式是第一人称或第三人称视角。
---@return string
function c:GetCameraMode()
    return CameraMode[self.main_inst.CameraMode]
end
---@type fun(param:string) @设置目前镜头模式为第一人称或者第三人称视角
---@param mode string | "'Classic'" | "'LockFirstPerson'"
function c:SetCameraMode(mode)
    assert(mode,"param mode is nil")
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    self.main_inst.CameraMode = CameraMode[mode]
end
---@type fun():boolean @获得玩家生成角色时是否加载玩家的角色外观。如果为false，则玩家生成的角色将会拥有默认外观
---@return boolean
function c:GetCanLoadCharacterAppearance()
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    return self.main_inst.CanLoadCharacterAppearance
end
---@type fun(switch:boolean) @设置玩家生成时是否加载玩家的角色外观，如果为false，则玩家生成的角色将会拥有默认外观
---@param switch boolean
function c:SetCanLoadCharacterAppearance(switch)
    if switch == nil then
        switch = false
    end
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    self.main_inst.CanLoadCharacterAppearance = switch
end
---@type fun():number @获得角色所使用的角色外观所属账户的用户ID
---@return number
function c:GetCharacterAppearanceId()
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    return self.main_inst.CharacterAppearanceId
end
---@type fun(id:number) @设置角色所使用的角色外观所属的用户ID
---@param id number
function c:SetCharacterAppearanceId(id)
    assert(id,"param id is nil")
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    self.main_inst.CharacterAppearanceId = id
end
---@type fun():string @获得当前默认镜头如何处理镜头与玩家之间的对象
---@return string
function c:GetDevComputerCameraMode()
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    return DevCameraOcclusionMode[self.main_inst.DevCameraOcclusionMode]
end
---@type fun(mode:string) @设置当前默认镜头如何处理镜头与玩家之间的对象
---@param mode string | "CameraToggle'" | "'Classic'" | "'Follow'" | "'Orbital'" | "'CameraToggle'"
function c:SetDevComputerCameraMode(mode)
    assert(mode,"param mode is nil")
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    self.main_inst.DevCameraOcclusionMode = DevCameraOcclusionMode[mode]
end
---@type fun():string @获得玩家的显示名称
---@return string
function c:GetDisplayName()
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    return self.main_inst.DisplayName
end
---@type fun(name:string) @设置玩家的显示名称
---@param name string
function c:SetDisplayName(name)
    assert(name,"param name is nil")
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    self.main_inst.DisplayName = name
end
---@type fun():number @描述了被另一名玩家跟随至游戏中的玩家用户 ID。
---@return number @用户ID
function c:GetFollowUserId()
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    return self.main_inst.FollowUserId
end
---@type fun():boolean @获得玩家客户端游戏是否正处于暂停状态
---@return boolean
function c:GetGameplayPaused()
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    return self.main_inst.GameplayPaused
end
---@type fun(switch:boolean) @设置玩家客户端游戏是正处于暂停状态
---@param switch boolean
function c:SetGameplayPaused(switch)
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    self.main_inst.GameplayPaused = switch
end
function c:GetDevTouchMovementMode()
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    return DevTouchMovementMode[self.main_inst.DevTouchMovementMode]
end
---@type fun(mode:string)
---@param mode string | "'UserChoice'" | "'Thumbstick'" | "'DPad'" | "'Thumbpad'" | "'ClickToMove'" | "'Scriptable'" | "'DynamicThumbstick'"
function c:SetDevTouchMovementMode(mode)
    assert(mode,"param mode is nil")
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    self.main_inst.DevTouchMovementMode = DevTouchMovementMode[mode]
end
function c:GetDevComputerMovementMode()
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    return DevComputerMovementMode[self.main_inst.DevComputerMovementMode]
end
---@type fun(mode:string)
---@param mode string | "'UserChoice'" | "'KeyboardMouse'" | "'ClickToMove'" | "'Scriptable'"
function c:SetDevComputerMovementMode(mode)
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    self.main_inst.DevComputerMovementMode = DevComputerMovementMode[mode]
end
function c:GetHealthDisplayDistance()
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    return self.main_inst.HealthDisplayDistance
end
---@type fun(distance:number)
---@param distance number
function c:SetHealthDisplayDistance(distance)
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    self.main_inst.HealthDisplayDistance = distance
end
---@type fun():number
---@return number
function c:GetLocaleId()
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    return self.main_inst.LocaleId
end
---@type fun():number
---@return number
function c:GetMaximumSimulationRadius()
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    return self.main_inst.MaximumSimulationRadius
end
---@type fun(raduis:number)
---@param radius number
function c:SetMaximumSimulationRadius(radius)
    assert(radius,"param radius is nil")
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    self.main_inst.MaximumSimulationRadius = radius
end
---@type fun():string
---@return string
function c:GetMemershipType()
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    return MembershipType[self.main_inst.MembershipType]
end
function c:IsPremium()
    return self.main_inst and (self.main_inst.MembershipType == Enum.MembershipType.Premium)
end
---@type fun():number
---@return number
function c:GetNameDisplayDistance()
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    return self.main_inst.NameDisplayDistance
end
function c:SetNameDisplayDistance(distance)
    assert(distance,"param distance is nil")
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    self.main_inst.NameDisplayDistance = distance
end
function c:GetNeutral()
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    return self.main_inst.Neutral
end
function c:GetReplicationFocus()
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    return self.main_inst.ReplicationFocus
end
function c:SetReplicationFocus(inst)
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    self.main_inst.ReplicationFocus = inst
end
function c:GetRespawnLocation()
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    return self.main_inst.RespawnLocation
end
function c:SetRespawnLocation(spawLocation)
    assert(spawLocation,"param spaw location is nil")
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    self.main_inst.RespawnLocation = spawLocation
end
function c:GetSimulationRadius()
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    return self.main_inst.SimulationRadius
end
function c:SetSimulationRadius(radius)
    assert(radius,"param radius is nil")
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    self.main_inst.SimulationRadius = radius
end
function c:GetTeam()
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    return self.main_inst.Team
end
function c:SetTeam(team)
    assert(team,"param team is nil")
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    self.main_inst.Team = team
end
function c:GetTeamColor()
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    return self.main_inst.TeamColor
end
function c:SetTeamColor(color)
    assert(color,"param color is nil")
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    self.main_inst.TeamColor = color
end
function c:GetUserId()
    -- assert(self.main_inst,"object main inst is nil class name = "..self.class)
    self.user_id = self.user_id or self.main_inst.UserId
    return self.user_id
end
---@type fun() @从玩家的 Character（角色）上移除所有配饰及其它角色外观对象。
function c:ClearCharacterAppearance()
    assert(self.main_inst,"object main inst is nil class name = "..self.class)
    self.main_inst:ClearCharacterAppearance()
end
function c:GetPlayerDescription(user_id)
    user_id = user_id or self:GetUserId()
    local result,desc = xpcall(function()
        return Players:GetHumanoidDescriptionFromUserId(user_id)
    end,debug.traceback)
    if result then
        return desc
    else
        warn(desc)
        return Instance.new("HumanoidDescription")
    end
end
---@type fun(thumbnail_type:string,thumbnail_size:string):string
---@param thumbnail_type string | " 'AvatarBust' " | " 'AvatarThumbnail' " | " 'HeadShot' "
---@param thumbnail_size string | " 'Size48x48' " | " 'Size180x180' " | " 'Size420x420' " | " 'Size60x60' " | " 'Size100x100' " | " 'Size150x150' " | " 'Size352x352' "
---@return string
function c:GetTumbnail(thumbnail_type,thumbnail_size)
    assert(thumbnail_type,"param thumbnail type is nil")
    assert(thumbnail_size,"param thumbnail size is nil")
    local t_type = ThumbnailType[thumbnail_type]
    assert(t_type,"not such type = "..tostring(thumbnail_type))
    local t_size = ThumbnailSize[thumbnail_size]
    assert(t_size,"not such size = "..tostring(thumbnail_size))
    return self:WaitForFunc(Players.GetUserThumbnailAsync,Players,self:GetUserId(),t_type,t_size)
end
function c:Kick(message)
    if self.main_inst then
        self.main_inst:Kick(message)
    end
end
function c:GetHumanoidDescription()
    local id = self:GetUserId()
    if not self.__default_humanoid_description then
        local r,e = xpcall(Players.GetHumanoidDescriptionFromUserId,debug.traceback,Players,id)
        if not r then
            warn(e)
            return Instance.new("HumanoidDescription")
        end
        self.__default_humanoid_description = e
    end
    return self.__default_humanoid_description
end
function c:GetJoinData()
    return self.main_inst:GetJoinData()
end
return c