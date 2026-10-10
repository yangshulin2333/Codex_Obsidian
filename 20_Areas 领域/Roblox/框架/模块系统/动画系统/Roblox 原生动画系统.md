# Roblox 原生动画系统知识操作手册

> 范围：本文只整理 Roblox Studio 自带的 `Avatar / 虚拟形象 -> Clip Editor / Animation Editor` 动画系统。Moon Animator 单独学习，不混在本手册里。

## 1. 学习目标

学完本手册后，你应该能独立完成这条链路：

```text
创建或导入 Rig 动画
-> 在 Clip Editor 中编辑关键帧
-> 设置 Loop / Priority / Events
-> Publish to Roblox
-> 拿到 AnimationId
-> 用 Script 或 LocalScript 播放
-> 处理权限、优先级冲突和运行时排错
```

重点不是记按钮位置，而是理解 Roblox 动画的三层结构：

| 层级  | 你在做什么                  | 关键对象                                        |
| --- | ---------------------- | ------------------------------------------- |
| 编辑层 | 在时间轴上摆姿势、打关键帧          | Rig、Track、Keyframe、Easing                   |
| 资产层 | 保存本地编辑数据或发布成 Roblox 资产 | KeyframeSequence、CurveAnimation、AnimationId |
| 运行层 | 用脚本加载并播放动画             | Animation、Animator、AnimationTrack           |

## 2. 核心概念

### 2.1 Rig

`Rig` 是能被动画控制的模型。常见类型：

| Rig 类型 | 说明 |
|---|---|
| `R15` | Roblox 现代角色骨架，身体分 15 个主要部件，推荐学习优先用它 |
| `R6` | 老角色骨架，部件更少，很多旧游戏还会用 |
| 自定义 Rig | NPC、怪物、武器、机关等，需要有正确的关节或骨骼结构 |

常见 R15 身体部位包括：

```text
HumanoidRootPart
LowerTorso
UpperTorso
Head
LeftUpperArm / LeftLowerArm / LeftHand
RightUpperArm / RightLowerArm / RightHand
LeftUpperLeg / LeftLowerLeg / LeftFoot
RightUpperLeg / RightLowerLeg / RightFoot
```

### 2.2 Keyframe

`Keyframe` 是时间轴上的关键帧。它记录某个时间点的姿势。

例如：

```text
0:00 右手自然下垂
0:15 右手抬到胸前
0:30 右手举高
```

Roblox 默认动画时间轴通常按 30 FPS 理解：

```text
0:15 = 0.5 秒
1:00 = 1 秒
```
  重要结论：

```text
动画只会影响它有关键帧的关节 

如果攻击动画只给右手打了关键帧，那么它不会自动控制腿部。角色走路时，腿部仍然可能继续播放默认走路动画。

```

### 2.4 Animation

`Animation` 是脚本里创建的对象，主要用来保存 `AnimationId`。

```lua
local animation = Instance.new("Animation")
animation.AnimationId = "rbxassetid://0000000000"
```

它本身不是正在播放的动画，只是“动画资产引用”。

### 2.5 Animator

`Animator` 是真正负责加载和播放动画的对象。

常见位置：

```text
Character
└─ Humanoid
   └─ Animator
```

脚本通常这样拿：

```lua
local humanoid = character:WaitForChild("Humanoid")
local animator = humanoid:WaitForChild("Animator")
```

### 2.6 AnimationTrack

`AnimationTrack` 是 `Animator:LoadAnimation(animation)` 返回的播放控制对象。

```lua
local track = animator:LoadAnimation(animation)
track:Play()
```

你以后控制播放、停止、循环、速度、权重、事件，主要都是操作 `AnimationTrack`。

常用 API：

| API | 用途 |
|---|---|
| `track:Play(fadeTime, weight, speed)` | 播放动画 |
| `track:Stop(fadeTime)` | 停止动画 |
| `track.IsPlaying` | 判断是否正在播放 |
| `track.Looped` | 是否循环 |
| `track.Priority` | 动画优先级 |
| `track:AdjustSpeed(speed)` | 调整速度 |
| `track:AdjustWeight(weight, fadeTime)` | 调整混合权重 |
| `track.TimePosition` | 跳到动画的某个时间点 |
| `track.Stopped` | 动画停止时触发 |
| `track.Ended` | 动画彻底结束影响后触发 |
| `track:GetMarkerReachedSignal(name)` | 监听动画事件点 |

## 3. Clip Editor 菜单操作

你截图里的菜单可以这样理解：

| 菜单项 | 作用 | 什么时候用 |
|---|---|---|
| `加载` | 加载当前 Rig 保存过的本地动画数据 | 继续编辑旧动画 |
| `保存` | 保存当前编辑进度到本地动画数据 | 每次阶段性修改后 |
| `另存为` | 保存成一个新版本 | 做版本分支，例如 `Attack_v02` |
| `导入` | 导入外部或已有动画数据 | 从 FBX、已有动画资产导入 |
| `发布至 Roblox` | 上传成 Roblox 动画资产，生成 `AnimationId` | 要用脚本播放时必须做 |
| `新建` | 新建一条动画剪辑 | 开始做新动画 |
| `设置动画优先级` | 设置动画覆盖规则 | 攻击、技能、移动、待机都要设置 |
| `优化关键帧` | 删除冗余关键帧 | 导入 FBX 后关键帧过多时 |

## 4. Save 和 Publish 的区别

这是新手最容易混的地方。

| 操作 | 结果 | 能不能直接脚本播放 |
|---|---|---|
| `保存 / Save` | 保存本地编辑数据，通常在 `ServerStorage` 生成 `KeyframeSequence` 或相关本地数据 | 不推荐直接用于正式脚本 |
| `发布至 Roblox / Publish to Roblox` | 上传成 Roblox 云端动画资产，生成 `AnimationId` | 可以 |

正确心智模型：

```text
Save 是保存工程文件。
Publish 是生成可运行资产 ID。
```

如果你只是想以后继续改，点 `保存`。

如果你要在脚本里这样写：

```lua
animation.AnimationId = "rbxassetid://1234567890"
```

那就必须 `发布至 Roblox`。

## 5. 发布窗口字段说明

发布窗口通常会出现这些字段：

| 字段 | 说明 | 建议 |
|---|---|---|
| `标题` | 动画资产名称 | 不要用默认名，写清用途 |
| `描述` | 动画说明 | 写 Rig、用途、优先级、是否循环、来源 |
| `创作者` | 动画资产归属 | 个人游戏选自己，群组游戏选群组 |
| `删除本地实例` | 发布后删除本地编辑数据 | 学习阶段先关掉 |
| `在工作间中创建动画对象` | 在 Workspace 创建 `Animation` 对象 | 学习可开，项目中更推荐统一放配置表 |

### 5.1 推荐命名规则

```text
角色或对象_动作名_Rig类型_版本
```

例子：

```text
Player_Attack_Light01_R15_v001
TrainingDummy_Wave_RightArm_R15_v001
NPC_Idle_Sleepy_R15_v001
Boss_HitReact_Backward_R15_v003
```

### 5.2 推荐描述模板

```text
Rig: R15
Use: light attack
Priority: Action
Loop: false
Source: Roblox Clip Editor
Owner: Group project animation
```

## 6. 创作者权限和归属

最稳规则：

```text
动画资产 owner 要和游戏 experience owner 保持一致。
```

| 游戏归属 | 动画发布时 Creator 应该选 |
|---|---|
| 个人账号游戏 | `我` |
| 群组游戏 | 对应群组 |
| 团队长期项目 | 项目所属群组 |

### 6.1 为什么要选对 Creator

如果动画发布在你个人账号下，但游戏属于群组，可能出现：

```text
你自己 Studio 里能播
别人不能播
Team Create 里有人看不到
正式服务器加载失败
Output 报权限错误
```

所以，群组游戏里的正式动画，优先发布到群组名下。

### 6.2 如果下拉框里没有群组

常见原因：

```text
你还不在该群组
你没有该群组的资产创建或配置权限
你没有编辑该群组 experience 的权限
Studio 登录账号不对
```

处理方式：

```text
让群组 owner 在 Creator Dashboard 里检查你的角色权限。
至少需要能编辑目标 experience，并能创建或配置该类开发资产。
```

### 6.3 已经发布错 owner 怎么办

推荐做法：

```text
重新用正确 Creator 发布一份新动画。
```

不推荐长期依赖“个人动画给群组游戏用”，后期协作和交接会变麻烦。

如果必须复用旧动画，可以到 Creator Dashboard 的动画资产配置中检查权限，把目标协作者、群组或 experience 加入权限范围。实际项目里仍建议最终迁移到正确 owner。

## 7. 导入动画

### 7.1 从 FBX 导入

常见流程：

```text
Blender / Maya 做动画
-> 导出 FBX
-> Roblox Studio 打开 R15 Rig
-> Avatar / 虚拟形象 -> Clip Editor
-> 选择 Rig
-> 菜单 ... -> Import -> From FBX Animation
-> 检查动作是否正确
-> 设置优先级
-> Publish to Roblox
```

### 7.2 FBX 导入前检查

| 检查项 | 说明 |
|---|---|
| Rig 类型 | R15 动画导入 R15，R6 动画导入 R6 |
| 骨骼命名 | 名称不匹配会导致动作丢失或错位 |
| 帧范围 | 导出 Start / End 要覆盖完整动画 |
| Bake Animation | 外部软件导出时通常要烘焙动画 |
| Root Motion | Roblox 角色移动一般由 Humanoid 或脚本控制，不建议动画本身推动角色位移 |
| Scale | 缩放单位错误会导致模型或动作比例异常 |

### 7.3 导入后必须做的检查

导入后不要立刻发布，先检查：

```text
动作是否完整
身体有没有扭曲
脚有没有明显滑动
第一帧和最后一帧是否适合循环
是否需要删除多余关键帧
Priority 是否正确
Loop 是否正确
```

## 8. 动画优先级

Roblox 优先级从高到低：

| 优先级 | 用途 |
|---|---|
| `Action4` | 最高，强制动作、Cutscene、死亡、硬控 |
| `Action3` | 强技能、受击、控制状态 |
| `Action2` | 技能、攻击连段、重要交互 |
| `Action` | 普通攻击、挥手、拾取、开门 |
| `Movement` | 走路、跑步、游泳、攀爬 |
| `Idle` | 待机 |
| `Core` | Roblox 默认动画，最低 |

实战建议：

| 动画类型 | 推荐优先级 |
|---|---|
| 默认待机 | `Idle` |
| 自定义走路 / 跑步 | `Movement` |
| 挥手 / 拾取 / 交互 | `Action` |
| 普通攻击 | `Action` 或 `Action2` |
| 技能释放 | `Action2` 或 `Action3` |
| 受击 / 眩晕 | `Action2` 或 `Action3` |
| 死亡 / 强制表演 | `Action3` 或 `Action4` |

### 8.1 关键理解：按关节覆盖

优先级不是简单地“整个动画覆盖整个角色”。

如果一个 `Action` 动画只包含右手关键帧，那么它只会强控制右手相关关节。腿部如果没有关键帧，仍然可能继续播放 `Movement` 走路动画。

所以做攻击动画时，如果希望上半身更稳定，通常需要给这些部位也打关键帧：

```text
UpperTorso
LowerTorso
RightUpperArm
RightLowerArm
RightHand
LeftUpperArm
LeftLowerArm
LeftHand
```

### 8.2 编辑器和脚本双保险

可以在 Clip Editor 里设置优先级，也可以在脚本里设置：

```lua
local track = animator:LoadAnimation(animation)
track.Priority = Enum.AnimationPriority.Action
track:Play()
```

项目里建议关键动画脚本再设置一次，避免资产被别人改动后行为变化。

## 9. 本地玩家动画教学代码

位置：

```text
StarterPlayer
└─ StarterPlayerScripts
   └─ LocalScript
```

用途：

```text
按 F 播放动画
按 R 停止动画
```

代码：

```lua
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")

local ANIMATION_ID = "rbxassetid://0000000000"

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local animator = humanoid:WaitForChild("Animator")

local animation = Instance.new("Animation")
animation.AnimationId = ANIMATION_ID

local track = animator:LoadAnimation(animation)
track.Priority = Enum.AnimationPriority.Action
track.Looped = false

local function handleAnimation(actionName, inputState, inputObject)
	if inputState ~= Enum.UserInputState.Begin then
		return
	end

	if inputObject.KeyCode == Enum.KeyCode.F then
		if not track.IsPlaying then
			track:Play(0.1, 1, 1)
		end
	elseif inputObject.KeyCode == Enum.KeyCode.R then
		if track.IsPlaying then
			track:Stop(0.1)
		end
	end
end

ContextActionService:BindAction(
	"TestAnimation",
	handleAnimation,
	false,
	Enum.KeyCode.F,
	Enum.KeyCode.R
)
```

参数解释：

```lua
track:Play(0.1, 1, 1)
```

| 参数 | 含义 |
|---|---|
| `0.1` | 淡入时间，越小越快进入动作 |
| `1` | 权重，越高影响越强 |
| `1` | 速度，`2` 是两倍速，`0.5` 是半速 |

## 10. NPC / Dummy 动画教学代码

如果是 NPC、训练假人、怪物，不要默认用 `LocalScript` 播。为了让所有玩家都看到，通常由服务端播放。

位置示例：

```text
Workspace
└─ TrainingDummyR15
   ├─ Humanoid
   │  └─ Animator
   └─ Script
```

代码：

```lua
local rig = script.Parent
local humanoid = rig:WaitForChild("Humanoid")
local animator = humanoid:WaitForChild("Animator")

local animation = Instance.new("Animation")
animation.AnimationId = "rbxassetid://0000000000"

local track = animator:LoadAnimation(animation)
track.Priority = Enum.AnimationPriority.Idle
track.Looped = true
track:Play(0.2, 1, 1)
```

适合：

```text
NPC 待机
训练假人循环动作
怪物巡逻动作
场景角色表演
```

## 11. 非 Humanoid 模型播放动画

有些模型没有 `Humanoid`，例如自定义机械臂、宠物、机关。此时使用：

```text
AnimationController
└─ Animator
```

模型结构：

```text
Workspace
└─ RobotArm
   ├─ AnimationController
   │  └─ Animator
   └─ Script
```

代码：

```lua
local rig = script.Parent
local animationController = rig:WaitForChild("AnimationController")
local animator = animationController:WaitForChild("Animator")

local animation = Instance.new("Animation")
animation.AnimationId = "rbxassetid://0000000000"

local track = animator:LoadAnimation(animation)
track.Priority = Enum.AnimationPriority.Action
track.Looped = true
track:Play()
```

如果模型没有 `AnimationController`，可以手动创建：

```lua
local rig = script.Parent

local animationController = rig:FindFirstChildOfClass("AnimationController")
if not animationController then
	animationController = Instance.new("AnimationController")
	animationController.Parent = rig
end

local animator = animationController:FindFirstChildOfClass("Animator")
if not animator then
	animator = Instance.new("Animator")
	animator.Parent = animationController
end
```

## 12. 循环、速度、暂停和跳帧

### 12.1 循环播放

```lua
track.Looped = true
track:Play()
```

如果循环不顺：

```text
复制第一帧到最后一帧
确认最后一帧姿势能无缝接回第一帧
避免 root 或 torso 位置突变
```

### 12.2 调整速度

```lua
track:Play()
track:AdjustSpeed(2)
```

含义：

```text
2 = 两倍速
1 = 原速
0.5 = 半速
0 = 冻结在当前帧
```

### 12.3 冻结到某一时间点

```lua
track:Play()
track:AdjustSpeed(0)
track.TimePosition = 0.5
```

注意：

```text
TimePosition 通常要在 track 正在播放时设置。
```

## 13. 动画事件 Markers

动画事件适合在动画播放到某一帧时触发逻辑。

常见用途：

```text
脚落地时播放脚步声
武器挥到命中帧时打开 hitbox
技能动画中间生成特效
拾取动作到手碰到物体时隐藏物体
```

### 13.1 编辑器操作

```text
打开 Animation Events 显示
拖动时间轴到目标帧
添加事件，例如 Hit、FootStep、Cast
可选填写 Parameter，例如 Left、Right、LightAttack
保存并发布动画
```

### 13.2 脚本监听

```lua
track:GetMarkerReachedSignal("Hit"):Connect(function(param)
	print("Hit marker reached:", param)
end)
```

### 13.3 战斗逻辑注意事项

教学时可以直接打印。

正式战斗中不要让客户端一句“我到 Hit 帧了”就造成伤害。服务端必须验证：

```text
玩家状态是否合法
技能冷却是否结束
距离是否合理
目标是否可被攻击
本次攻击是否已经结算过
```

推荐边界：

```text
客户端：播放动画、特效、镜头反馈
服务端：决定是否命中、扣血、发奖励
```

## 14. 替换默认角色动画

Roblox 角色默认有这些动画：

```text
Idle
Walk
Run
Jump
Fall
Swim
Climb
```

如果要替换默认动画，通常改角色里的 `Animate` 脚本引用。

服务端示例：

位置：

```text
ServerScriptService
└─ Script
```

代码：

```lua
local Players = game:GetService("Players")

local RUN_ANIMATION_ID = "rbxassetid://0000000000"
local WALK_ANIMATION_ID = "rbxassetid://0000000000"

local function onCharacterAdded(character)
	local humanoid = character:WaitForChild("Humanoid")
	local animator = humanoid:WaitForChild("Animator")

	for _, playingTrack in animator:GetPlayingAnimationTracks() do
		playingTrack:Stop(0)
	end

	local animateScript = character:WaitForChild("Animate")
	animateScript.run.RunAnim.AnimationId = RUN_ANIMATION_ID
	animateScript.walk.WalkAnim.AnimationId = WALK_ANIMATION_ID
end

local function onPlayerAdded(player)
	player.CharacterAppearanceLoaded:Connect(onCharacterAdded)
end

Players.PlayerAdded:Connect(onPlayerAdded)
```

注意：

```text
替换默认跑步、跳跃等动画时，如果用于 Roblox 默认角色状态，最后关键帧有时需要命名为 End。
```

## 15. AnimationId 管理表

项目中不要把 ID 散落在很多脚本里。建议建立统一记录。

示例：

| 名称 | AnimationId | Owner | Priority | Loop | 用途 |
|---|---|---|---|---|---|
| Player_Attack_Light01_R15_v001 | rbxassetid://0000000000 | Group | Action | false | 玩家轻攻击 |
| NPC_Idle_Sleepy_R15_v001 | rbxassetid://0000000000 | Group | Idle | true | NPC 待机 |
Lua 配置表示例：

```lua
local Animations = {
	PlayerAttackLight01 = {
		Id = "rbxassetid://0000000000",
		Priority = Enum.AnimationPriority.Action,
		Looped = false,
	},

	NpcIdleSleepy = {
		Id = "rbxassetid://0000000000",
		Priority = Enum.AnimationPriority.Idle,
		Looped = true,
	},
}

return Animations
```

## 16. 简单动画播放器模块示例

项目中可以把加载和播放封装起来，避免重复写。

`AnimationPlayer.lua`：

```lua
local AnimationPlayer = {}

function AnimationPlayer.load(animator, config)
	local animation = Instance.new("Animation")
	animation.AnimationId = config.Id

	local track = animator:LoadAnimation(animation)
	track.Priority = config.Priority or Enum.AnimationPriority.Action
	track.Looped = config.Looped == true

	return track
end

function AnimationPlayer.playOnce(track, fadeTime)
	if track.IsPlaying then
		track:Stop(fadeTime or 0.1)
	end

	track:Play(fadeTime or 0.1, 1, 1)
end

function AnimationPlayer.stop(track, fadeTime)
	if track.IsPlaying then
		track:Stop(fadeTime or 0.1)
	end
end

return AnimationPlayer
```

使用示例：

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AnimationPlayer = require(ReplicatedStorage.AnimationPlayer)

local humanoid = character:WaitForChild("Humanoid")
local animator = humanoid:WaitForChild("Animator")

local attackTrack = AnimationPlayer.load(animator, {
	Id = "rbxassetid://0000000000",
	Priority = Enum.AnimationPriority.Action,
	Looped = false,
})

AnimationPlayer.playOnce(attackTrack)
```

## 17. 客户端和服务端边界

| 对象或场景 | 推荐播放位置 | 原因 |
|---|---|---|
| 本地玩家自己的角色表现 | `LocalScript` | 输入响应快，适合本地反馈 |
| NPC / Dummy / 怪物 | 服务端 `Script` | 所有人都要看到同样表现 |
| 攻击命中、扣血、奖励 | 服务端决定 | 防止客户端作弊 |
| 纯视觉特效、镜头抖动 | 客户端 | 不影响权威状态 |

经验规则：

```text
动画可以在客户端先播，结果必须由服务端决定。
```

## 18. 常见问题排查

### 18.1 动画完全不播放

检查：

```text
AnimationId 是否写成 rbxassetid://数字
动画是否已经 Publish to Roblox
Animator 是否存在
脚本位置是否正确
Output 是否有权限或加载错误
Rig 类型是否匹配
```

### 18.2 我能看见，别人看不见

常见原因：

```text
NPC 动画只在 LocalScript 播放
动画 owner 和 experience owner 不一致
群组权限没配好
Animator 是客户端本地创建的，没从服务端复制
```

处理：

```text
NPC / Dummy 改服务端播放
群组游戏动画重新发布到群组
检查 Creator Dashboard 权限
确保 Animator 由服务端存在并复制
```

### 18.3 优先级设置了但没覆盖

可能原因：

```text
动画没有给目标关节打关键帧
另一个动画优先级更高
两个同优先级动画在混合
脚本里又覆盖了 Priority
```

处理：

```text
检查时间轴里是否有对应身体部位轨道
提高 Priority
播放前 Stop 冲突动画
在脚本里明确设置 track.Priority
```

### 18.4 循环动作卡一下

原因：

```text
最后一帧和第一帧姿势不一致
Loop 不会自动帮你把末尾平滑接回开头
```

处理：

```text
复制第一帧到最后一帧
检查 torso / root / 手脚位置是否连续
```

### 18.5 FBX 导入后身体扭曲

检查：

```text
R15 / R6 是否匹配
骨骼命名是否符合 Roblox 识别要求
外部软件导出是否 Bake Animation
缩放和坐标轴是否正确
是否有多余骨骼或控制器被导出
```

### 18.6 群组动画发布失败或找不到群组

检查：

```text
Studio 登录账号是否正确
你是否在该群组
你是否有编辑目标 experience 的权限
你是否有创建 / 配置开发资产的权限
```

## 19. 推荐练习顺序

### 练习 1：右手挥手

目标：

```text
用 R15 Dummy 做一个右手挥手动画。
```

要求：

```text
长度 1 秒
Priority = Action
Loop = false
发布到个人账号
用 LocalScript 按 F 播放
```

### 练习 2：NPC 循环待机

目标：

```text
给 TrainingDummyR15 做一个循环待机动作。
```

要求：

```text
Priority = Idle
Loop = true
服务端 Script 播放
所有玩家都能看见
```

### 练习 3：攻击命中帧

目标：

```text
在攻击动画中加入 Hit 事件。
```

要求：

```text
0.25 秒处添加 Hit marker
脚本监听 GetMarkerReachedSignal("Hit")
先 print，再理解正式战斗应交给服务端验证
```

### 练习 4：导入 FBX

目标：

```text
从 Blender / Maya 导入一个短动作。
```

要求：

```text
确认 Rig 匹配
确认动作没扭曲
确认 Priority
发布后用脚本播放
```

## 20. 项目交接模板

每做完一组动画，建议记录：

## Animation Handoff

| 字段 | 内容 |
|---|---|
| 动画名称 | Player_Attack_Light01_R15_v001 |
| AnimationId | rbxassetid://0000000000 |
| Creator | Group / Personal |
| Rig | R15 |
| Priority | Action |
| Loop | false |
| Markers | Hit at 0.25s |
| 用途 | 玩家轻攻击第一段 |
| 播放位置 | LocalScript for visual, server validates damage |
| 验证结果 | Studio Play 测试通过 |
| 注意事项 | 只控制上半身，腿部仍可走路 |
## 21. 快速决策表

| 问题 | 选择 |
|---|---|
| 我要继续编辑动画 | `保存` |
| 我要脚本播放动画 | `发布至 Roblox` |
| 个人游戏使用 | Creator 选 `我` |
| 群组游戏使用 | Creator 选群组 |
| 本地玩家按键播放 | `StarterPlayerScripts` 里的 `LocalScript` |
| NPC 给所有人看 | 服务端 `Script` |
| 攻击动作盖过走路 | `Action` 或更高 |
| 自定义跑步 | `Movement` |
| 待机动作 | `Idle` |
| 需要某一帧触发逻辑 | Animation Event Marker |
| 导入外部动画 | FBX / glTF，先检查 Rig 和 Bake |

## 22. 官方参考

- Roblox Creator Hub: Animation Editor  
  https://create.roblox.com/docs/animation/editor
- Roblox Creator Hub: Use animations  
  https://create.roblox.com/docs/animation/using
- Roblox Creator Hub: Animation events  
  https://create.roblox.com/docs/animation/events
- Roblox Creator Hub: AnimationPriority  
  https://create.roblox.com/docs/reference/engine/enums/AnimationPriority
- Roblox Creator Hub: Animator  
  https://create.roblox.com/docs/reference/engine/classes/Animator
- Roblox Creator Hub: AnimationTrack  
  https://create.roblox.com/docs/reference/engine/classes/AnimationTrack
- Roblox Creator Hub: Import and configure animations  
  https://create.roblox.com/docs/avatar/emotes/import
- Roblox Creator Hub: Animation export settings  
  https://create.roblox.com/docs/avatar/emotes/export
- Roblox Creator Hub: Asset permissions  
  https://create.roblox.com/docs/projects/assets/privacy
- Roblox Creator Hub: Groups and permissions  
  https://create.roblox.com/docs/projects/groups
