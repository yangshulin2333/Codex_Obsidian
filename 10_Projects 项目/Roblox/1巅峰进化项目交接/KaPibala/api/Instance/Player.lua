---@class Player:Instance @引擎玩家类
---@field DisplayName string
---@field AccountAge number @描述玩家的帐户年龄（以天为单位）
---@field AutoJumpEnabled boolean @确定使用移动设备的玩家的角色是否会在撞到障碍物后自动跳起来。
---@field CameraMaxZoomDistance number @玩家的相机可以缩小的最大距离
---@field CameraMinZoomDistance number @玩家的相机可以放大的最小距离
---@field CameraMode CameraMode @将镜头模式改变至第一人称或第三人称视角。
---@field CanLoadCharacterAppearance boolean @确定在玩家生成时是否加载角色的外观。如果为false，则播放器将以默认外观生成
---@field Character Model @由玩家控制的模型，其中包含人形生物，身体部位，脚本和其他对象
---@field CharacterAppearanceId string @确定其角色外观用于玩家角色的帐户的用户ID
---@field DevCameraOcclusionMode DevCameraOcclusionMode @设置默认相机如何处理相机和播放器之间的对象
---@field DevComputerCameraMode DevComputerCameraMovementMode @确定使用台式机版Roblox时玩家的摄像机移动模式
---@field DevComputerMovementMode DevComputerMovementMode @确定使用桌面版Roblox时玩家的角色移动模式
---@field DevEnableMouseLock boolean @确定玩家是否可以切换鼠标锁定
---@field DevTouchCameraMode DevTouchCameraMovementMode @确定使用触摸设备时玩家的相机移动模式
---@field DevTouchMovementMode DevTouchMovementMode @确定使用触摸设备时玩家的角色移动模式
---@field FollowUserId string @描述玩家跟随游戏的玩家的用户ID
---@field GameplayPaused boolean @玩家客户端游戏当前是否已暂停
---@field HealthDisplayDistance number @设置该玩家看到其他人形生物的健康条的距离。如果设置为0，则不会显示健康栏
---@field LocaleId string @此属性显示本地玩家为其Roblox帐户设置的语言环境ID
---@field MaximumSimulationRadius number @玩家的玩家的最大值。SimulationRadius可以增长到
---@field MembershipType MembershipType @描述帐户的会员类型（NBC，BC，TBC或OBC）
---@field NameDisplayDistance number @设置该玩家看到其他人形生物名称的距离。如果设置为0，则隐藏名称
---@field Neutral boolean @确定玩家是否在特定团队中
---@field ReplicationFocus Instance @设置零件以集中复制
---@field RespawnLocation SpawnLocation @如果设置，则玩家将在给定的SpawnLocation处重生
---@field SimulationRadius number @玩家的玩家的模拟半径。角色
---@field Team Team @确定与玩家相关联的团队
---@field TeamColor BrickColor @确定与玩家相关联的团队
---@field UserId string @分配给所有用户帐户的唯一标识整数
---@field CharacterAdded RBXScriptSignal @参数为角色，当玩家的角色产生或重新产生时触发
---@field CharacterAppearanceLoaded RBXScriptSignal @插入玩家的Player.Character的完整外观时触发
---@field CharacterRemoving RBXScriptSignal @在移除玩家角色之前立即触发
---@field Chatted  RBXScriptSignal @当玩家使用Roblox提供的聊天栏在游戏中聊天时触发
---@field Idled RBXScriptSignal @通常在游戏引擎将玩家归类为闲置状态后两分钟触发。时间是此点以来的秒数
---@field OnTeleport RBXScriptSignal @玩家的传送状态改变时触发
---@field SimulationRadiusChanged RBXScriptSignal @当 Player 的 Player.SimulationRadius 更改后触发
local module = {}
---@type fun() @从玩家的角色中移除所有配件和其他角色外观对象。
function module:ClearCharacterAppearance()
end
---@type fun(param:Vector3):number @返回角色头部和给定Vector3点之间的距离。如果玩家没有角色，则返回0
---@param point Vector3 @距玩家的距离的测量位置
---@return number @玩家与位置之间的螺柱距离
function module:DistanceFromCharacter()
end
---@type fun(param:number):table<string,any> @GetFriendsOnline Player函数返回maxFriends指定的在线朋友表。
---@param maxFriends number @返回的在线好友数上限。默认值为200
---@return table[] @某些字段仅适用于某些位置类型。例如，当位置类型为（移动）网站时，PlaceId将不会显示
function module:GetFriendsOnline()
end
---@type fun():table<string,any> @返回包含有关玩家如何加入游戏的信息的字典
---@return table<string,any> @包含PlaceId和UserId值的字典（请参见说明中的表）
function module:GetJoinData()
end
---@type fun():Instance @返回客户端使用的鼠标
---@return Instance @玩家的鼠标实例
function module:GetMouse()
end
---@type fun(param:string):number @以0到255之间的整数返回玩家在组中的排名，其中0是非会员，而255是组的所有者
---@param groupid string @指定组的groupId
---@return number @玩家在组中的排名
function module:GetRankInGroup()
end
---@type fun(param:string):number @以字符串形式返回玩家在组中的角色，如果玩家不属于组，则返回“ Guest”
---@param groupid string @指定组的groupId
---@return string @该玩家在指定组中的角色，或该玩家的访客不是成员
function module:GetRoleInGroup()
end
---@type fun():boolean @返回玩家角色的外观是否已加载
---@return boolean @指示玩家角色的外观是否已加载的布尔值
function module:HasAppearanceLoaded()
end
---@type fun(param:string):boolean @检查玩家是否是具有给定Player.UserId的用户的朋友
---@param userId string @指定玩家的Player.UserId
---@return boolean @指示玩家是否为指定用户的朋友的布尔值
function module:IsFriendsWith()
end
---@type fun(param:string):boolean @检查玩家是否是具有给定ID的组的成员
---@param groupId string @指定组的groupId
---@return boolean @指示玩家是否在指定组中的布尔值
function module:IsInGroup()
end
---@type fun(param:string) @强制断开玩家与游戏的连接，并选择提供一条消息。
---@param message string @踢球时显示球员的信息
function module:Kick()
end
---@type fun() @为玩家创建一个新角色，删除旧角色。同时清除玩家的背包和PlayerGui
function module:LoadCharacter()
end
---@type fun() @与 Player:LoadCharacter 功能相似，但其请求将会同步处理，而非异步处理
function module:LoadCharacterBlocking()
end
---@type fun(param:Instance) @
function module:LoadCharacterWithHumanoidDescription()
end
---@type fun(param:Vector3,param:boolean) @“移动播放器”功能使播放器的角色朝着给定的方向行走，直到停止或被播放器打断（通过使用其控件）
---@param walkDirection Vector3 @玩家应该移动的Vector3方向
---@param relativeToCamera boolean @一个布尔值，指示玩家是否应该相对于玩家的相机移动
function module:Move()
end
---@type fun() @移除玩家的角色
function module:RemoveCharacter()
end
---@type fun(param:number) @设置玩家的AccountAge
---@param accountAge number @帐户的使用天数
function module:SetAccountAge()
end
---@type fun(param:boolean) @设置玩家是否看到过滤后的聊天，而不是普通聊天
---@param value boolean @指示玩家是否看到过滤后的聊天的布尔值
function module:SetSuperSafeChat()
end