---@class Humanoid:Instance @人形机器人是一个特殊的对象，它使模型具有角色的功能。它使模型具有在Roblox级别的各个组件上进行物理行走并与之交互的能力
---@field AutoJumpEnabled boolean @设置角色在移动设备上作为玩家撞到障碍物时是否会自动跳跃。
---@field AutoRotate boolean @AutoRotate设置“人形机器人”是否将自动旋转以面向其移动方向
---@field AutomaticScalingEnabled boolean
---@field BreakJointsOnDeath boolean @确定类人动物的关节在死亡状态下是否断裂
---@field CameraOffset Vector3 @当将CameraSubject设置为此Humanoid时，将应用于相机主题位置的偏移量。
---@field CollisionType HumanoidCollisionType @为R15和Rthro非玩家角色选择HumanoidCollisionType
---@field DisplayDistanceType HumanoidDisplayDistanceType @控制 Humanoid 的名称和生命值显示的距离行为。
---@field Health number @描述人形对象的当前生命值，区间是 [0, Humanoid.MaxHealth]。
---@field MaxHealth number @描述人形对象最大生命值
---@field HealthDisplayDistance number @与Humanoid的Humanoid.DisplayDistanceType属性一起使用，可以确定控制此Humanoid的玩家可以看到多人类动物的健康条的距离，或此Humanoid的健康向其他观看者显示的距离。
---@field DisplayName string @
---@field HipHeight number @确定Humanoid.RootPart应该离地面的距离。
---@field RootPart Part @根部件
---@field JumpHeight number
---@field Jump boolean
---@field SeatPart Part
---@field MaxSlopeAngle number
---@field RequiresNeck boolean
---@field JumpPower number @确定在跳跃时向人形生物施加多少向上的力。
---@field NameDisplayDistance number @与类人动物的DisplayDistanceType属性结合使用，可以确定控制此类人动物的玩家可以看到多人类动物的名字，或者该类人动物的名字可以显示给其他观看者。
---@field NameOcclusion NameOcclusion @控制是否可以在墙壁或其他物体后面看到类人动物的名字。
---@field PlatformStand boolean @确定类人动物当前是否在PlatformStanding HumanoidStateType中。
---@field TargetPoint Vector3 @描述控制人形机器人的玩家在使用工具时在世界上最后单击的3D位置。
---@field UseJumpPower boolean 
---@field WalkSpeed number @描述人形生物的最大移动速度（以螺柱/秒为单位）
---@field WalkToPart BasePart @对人型对象尝试到达其位置的部件的引用
---@field AnimationPlayed RBXScriptSignal @当AnimationTrack开始在人形生物上播放时触发
---@field Climbing RBXScriptSignal @当类人生物攀爬速度发生变化时触发
---@field Died RBXScriptSignal @人形生物死亡时触发
---@field FallingDown RBXScriptSignal @当类人动物进入或离开FallingDown HumanoidStateType时触发
---@field FreeFalling RBXScriptSignal @当类人生物进入或离开Freefall HumanoidStateType时触发
---@field GettingUp RBXScriptSignal @当类人动物进入或离开GettingUp HumanoidStateType时触发
---@field HealthChanged RBXScriptSignal @当Humanoid.Health变化时触发
---@field Jumping RBXScriptSignal @当类人动物进入并离开Jumping HumanoidStateType时触发
---@field MoveToFinished RBXScriptSignal @当类人动物完成步行到类人动物声明的目标时触发：MoveTo
---@field PlatformStanding RBXScriptSignal @当类人动物进入或离开PlatformStanding HumanoidStateType时触发
---@field Ragdoll RBXScriptSignal @当类人动物进入或离开布娃娃HumanoidStateType时触发
---@field Running RBXScriptSignal @当类人动物的跑步速度发生变化时触发
---@field Seated RBXScriptSignal @当类人动物坐在座椅或车辆座椅上或起床时触发
---@field StateChanged RBXScriptSignal @当类人动物的状态改变时触发
---@field StateEnabledChanged RBXScriptSignal @在Humanoid上调用Humanoid：SetStateEnabled时触发
---@field Strafing RBXScriptSignal @当类人动物进入或离开StrafingNoPhysics HumanoidStateType时触发
---@field Swimming RBXScriptSignal @当人形生物在地形水中游泳的速度发生变化时触发
---@field Touched RBXScriptSignal @当类人动物的四肢之一与另一BasePart接触时触发
---@field MoveDirection Vector3 @走进的方向
local module = {}
---@type fun(humanoidDescription:Instance) @使角色的外观与在HumanoidDescription中传递的外观相匹配
---@param humanoidDescription Instance @您想要设置字符以匹配的HumanoidDescription实例
function module:ApplyDescription(humanoidDescription)
end
---@type fun(position:Vector3)
---@param position Vector3
function module:MoveTo(position)
end
---@type fun() @通过将类人物体中的附着对象附着在一起来组装Motor6D关节树
function module:BuildRigFromAttachments()
end
---@type fun(param:HumanoidStateType) @将Humanoid设置为输入给定的HumanoidStateType
---@param state HumanoidStateType @用于跟踪和设置类人动物的活动。当前，此Enum与Humanoid：GetState和Humanoid：ChangeState方法以及Humanoid.StateChanged事件一起使用
function module:ChangeState()
end
---@type fun(param:Instance) @使类人动物装备给定的工具
---@param tool Instance @装备工具
function module:EquipTool()
end
---@type fun():Accessory[] @返回类人动物的父母当前正在佩戴的一系列配件
---@return Accessory[] @仿制人形的父项的一系列附件
function module:GetAccessories()
end
---@type fun():Instance @返回Humanoid的缓存HumanoidDescription的副本，该副本描述其当前外观
---@return Instance @实例化和初始化的HumanoidDescription实例，是Humanoid中当前缓存的一个副本，代表其当前外观
function module:GetAppliedDescription()
end
---@type fun(param:Instance):BodyPartR15
---@param part Part
---@return BodyPartR15 @BodyPartR15 是与 Humanoid:GetBodyPartR15 和 Humanoid:ReplaceBodyPartR15 一起使用，用于查找和替换 R15 角色的特定身体部位的 enum
function module:GetBodyPartR15()
end
---@type fun(param:Part):Limb @返回与给定Part关联的Limb枚举
---@param part Instance @要为其检索Enum.Limb的部分
---@return Limb @肢体对应的肢体
function module:GetLimb()
end
---@type fun():AnimationTrack[] @返回当前在人形机器人上播放的所有AnimationTracks的数组
---@return AnimationTrack[] @当前正在播放的AnimationTracks数组
function module:GetPlayingAnimationTracks()
end
---@type fun():HumanoidStateType @返回类人动物的当前HumanoidStateType
---@return HumanoidStateType @类人动物的当前HumanoidStateType
function module:GetState()
end
---@type fun(param:GetStateEnabled):boolean @返回是否为Humanoid启用HumanoidStateType
---@param state HumanoidStateType @给定的HumanoidStateType
---@return boolean @给定的HumanoidStateType是否启用
function module:GetStateEnabled()
end
---@type fun(param:Animation):Instance @将动画加载到人形机器人上，返回可用于播放的AnimationTrack
---@param animation Instance @要加载的动画
---@return Instance @创建了AnimationTrack
function module:LoadAnimation()
end
---@type fun(param:Vector3,param:boolean) @使人形生物沿给定方向行走
---@param moveDirection Vector3 @走进的方向
---@param relativeToCamera boolean @如果将direction参数视为相对于Workspace.CurrentCamera的，则为True
function module:Move()
end
---@type fun(param:string):boolean @
---@param emoteName string
function module:PlayEmote()
end
---@type fun() @删除类人动物父母佩戴的所有配件 
function module:RemoveAccessories()
end
---@type fun(param:BodyPartR15,param:Instance):boolean @动态地将人形人体部分替换为其他部分。
---@param bodyPart BodyPartR15 @
---@param part Instance @
---@return boolean @
function module:ReplaceBodyPartR15()
end
---@type fun(param:HumanoidStateType,param:enabled) @设置是否为Humanoid启用给定的HumanoidStateType
---@param state HumanoidStateType @要启用或禁用的Enum / HumanoidStateType
---@param enabled boolean @如果要启用此状态，则为true；如果要禁用，则为false
function module:SetStateEnabled()
end
---@type fun(param:number) @如果不受ForceField保护，则使类人生物的生命值降低给定数量
---@param amount number @伤害或从类人动物推断出的金额。
function module:TakeDamage(number)
end