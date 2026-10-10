---
type: concept
domain: roblox
status: evergreen
owner: mixed
source: mixed
created: 2026-07-02
updated: 2026-07-02
---

# ProximityPrompt漂浮道具穿戴知识卡

## 这个功能要做什么

把已经能穿戴的 `Accessory` 模板，做成场景里漂浮旋转的道具。玩家靠近后按 `E`，服务器把装备穿到玩家角色身上。

本卡只教这个功能：

```text
已有 Accessory 模板
-> 场景里展示一个漂浮道具
-> 靠近后出现 E 提示
-> 按 E 后穿戴到角色身上
```

`Accessory` 本身怎么做、`Handle` 和 `Attachment` 怎么调，不在本卡里讲。前置知识看：

- [[Accessory挂到角色身体部位知识卡]]

下面用“左右鞋”举例。帽子、披风、武器也可以照这个结构改。

## 第 0 步：先确认你已经有可穿戴模板

在 `ReplicatedStorage` 下准备好真正要穿到角色身上的模板：

```text
ReplicatedStorage
├─ Left     -- Accessory，左鞋模板
└─ Right    -- Accessory，右鞋模板
```

检查 `Left.Handle` 和 `Right.Handle`：

```text
Anchored = false
CanCollide = false
Massless = true
```

## 第 1 步：创建场景交互点

### 1.1 创建总容器

1. 在 `Explorer` 里右键 `Workspace`。
2. 选择 `Insert Object`。
3. 选择 `Model`。
4. 把这个 `Model` 改名为：

```text
ShoePickup_01
```

### 1.2 创建透明交互范围

1. 右键 `ShoePickup_01`。
2. 选择 `Insert Object`。
3. 选择 `Part`。
4. 把这个 `Part` 改名为：

```text
Hitbox
```

选中 `Hitbox`，设置属性：

```text
Anchored = true
CanCollide = false
Transparency = 1
Size = 6, 4, 6
```

把 `Hitbox` 移动到你希望玩家靠近交互的位置。

### 1.3 创建按键提示

1. 右键 `Hitbox`。
2. 选择 `Insert Object`。
3. 选择 `ProximityPrompt`。

选中这个 `ProximityPrompt`，设置属性：

```text
ActionText = 穿戴
ObjectText = 鞋子
KeyboardKeyCode = E
MaxActivationDistance = 8
HoldDuration = 0
RequiresLineOfSight = false
Enabled = true
```

如果你想让玩家长按，就把：

```text
HoldDuration = 1
ActionText = 长按穿戴
```

如果你想按一下就穿戴，就保持：

```text
HoldDuration = 0
```

### 1.4 创建展示模型容器

1. 右键 `ShoePickup_01`。
2. 选择 `Insert Object`。
3. 选择 `Model`。
4. 把这个 `Model` 改名为：

```text
Visual
```

### 1.5 复制展示用鞋子

这里不要移动 `ReplicatedStorage` 里的模板，只复制一份出来展示。

1. 在 `ReplicatedStorage` 里选中 `Left`。
2. `Ctrl + C` 复制。
3. 选中 `Workspace > ShoePickup_01 > Visual`。
4. `Ctrl + V` 粘贴。
5. 把复制出来的对象改名为：

```text
LeftVisual
```

右鞋同样操作：

1. 复制 `ReplicatedStorage.Right`。
2. 粘贴到 `Visual` 下面。
3. 改名为：

```text
RightVisual
```

展开 `LeftVisual` 和 `RightVisual`，找到里面的 `Handle`，设置：

```text
Anchored = true
CanCollide = false
CanTouch = false
```

然后把 `Visual` 里的左右鞋移动到你希望展示的位置。

### 1.6 最终结构检查

最后结构应该是：

```text
Workspace
└─ ShoePickup_01              -- Model，总容器
   ├─ Hitbox                  -- Part，透明交互范围
   │  └─ ProximityPrompt      -- ProximityPrompt，按键提示
   └─ Visual                  -- Model，展示容器
      ├─ LeftVisual           -- Accessory，左鞋展示物
      └─ RightVisual          -- Accessory，右鞋展示物
```

## 第 2 步：创建服务器穿戴脚本

### 2.1 新建脚本

1. 右键 `ServerScriptService`。
2. 选择 `Insert Object`。
3. 选择 `Script`。
4. 把脚本改名为：

```text
ShoePickupEquip
```

### 2.2 粘贴代码

把 `ShoePickupEquip` 里的默认代码删掉，粘贴下面这段：

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- 找到场景里的交互点。
local pickup = workspace:WaitForChild("ShoePickup_01")
local hitbox = pickup:WaitForChild("Hitbox")

-- 按对象类型找 ProximityPrompt，不按 Name 找。
-- 所以 Prompt 的 Name 可以叫“穿戴”“领取”等。
local prompt = hitbox:FindFirstChildOfClass("ProximityPrompt")
if not prompt then
	warn("[ShoePickupEquip] Hitbox 下没有找到 ProximityPrompt")
	return
end

-- 拿到真正要穿到角色身上的 Accessory 模板。
local leftTemplate = ReplicatedStorage:WaitForChild("Left")
local rightTemplate = ReplicatedStorage:WaitForChild("Right")

local SHOE_ATTRIBUTE = "PickupShoeAccessory" -- 标记这双鞋是本交互系统穿上的。
local DISTANCE_BUFFER = 3 -- 服务器距离检查的容错值，避免网络延迟导致误判。

-- 穿到角色身上的 Accessory 不能 Anchored。
-- 这里做一次保险处理，防止模板或展示物复制时属性设错。
local function prepareAccessory(accessory)
	for _, descendant in ipairs(accessory:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.Anchored = false
			descendant.CanCollide = false
			descendant.CanTouch = false
			descendant.Massless = true
		end
	end
end

-- 删除角色身上已有的旧鞋，避免玩家反复按 E 后叠很多双鞋。
local function removeOldShoes(character)
	for _, child in ipairs(character:GetChildren()) do
		if child:IsA("Accessory") and (
			child.Name == "Left"
				or child.Name == "Right"
				or child:GetAttribute(SHOE_ATTRIBUTE)
			) then
			child:Destroy()
		end
	end
end

-- player 是 ProximityPrompt.Triggered 自动传进来的。
-- 哪个玩家触发 Prompt，player 就是谁。
local function equipShoes(player)
	local character = player.Character
	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoid or not rootPart then
		return
	end

	if humanoid.Health <= 0 then
		return
	end

	-- 服务器再检查一次距离。
	-- 两个 Position 相减得到方向向量，Magnitude 把向量变成距离数字。
	local distance = (rootPart.Position - hitbox.Position).Magnitude
	if distance > prompt.MaxActivationDistance + DISTANCE_BUFFER then
		return
	end

	-- 穿新鞋前先删除旧鞋。
	removeOldShoes(character)

	-- Clone 左鞋模板，打标记，然后放到角色下面完成穿戴。
	local leftClone = leftTemplate:Clone()
	leftClone.Name = "Left"
	leftClone:SetAttribute(SHOE_ATTRIBUTE, true)
	prepareAccessory(leftClone)
	leftClone.Parent = character

	-- Clone 右鞋模板，打标记，然后放到角色下面完成穿戴。
	local rightClone = rightTemplate:Clone()
	rightClone.Name = "Right"
	rightClone:SetAttribute(SHOE_ATTRIBUTE, true)
	prepareAccessory(rightClone)
	rightClone.Parent = character
end

-- 玩家完成 Prompt 交互后，调用 equipShoes(player)。
prompt.Triggered:Connect(equipShoes)
```

## 第 3 步：创建漂浮旋转脚本

### 3.1 新建 LocalScript

1. 展开 `StarterPlayer`。
2. 展开 `StarterPlayerScripts`。
3. 右键 `StarterPlayerScripts`。
4. 选择 `Insert Object`。
5. 选择 `LocalScript`。
6. 把脚本改名为：

```text
ShoePickupFloat
```

### 3.2 粘贴代码

把 `ShoePickupFloat` 里的默认代码删掉，粘贴下面这段：

```lua
local RunService = game:GetService("RunService")

local pickup = workspace:WaitForChild("ShoePickup_01")
local visual = pickup:WaitForChild("Visual")

-- 拿到 Visual 当前的整体位置和朝向。
-- basePivot 是动画的原始位置，后面每一帧都基于它重新计算。
local basePivot = visual:GetPivot()

-- 把 Visual 下面所有物理零件设置成纯展示物。
-- GetDescendants() 会遍历 Visual 下面所有后代对象。
for _, descendant in ipairs(visual:GetDescendants()) do
	-- 鞋子的 Handle 通常是 MeshPart，属于 BasePart。
	if descendant:IsA("BasePart") then
		descendant.Anchored = true -- 固定展示模型，避免被重力影响掉下去。
		descendant.CanCollide = false -- 关闭碰撞，玩家不会被展示鞋子挡住。
		descendant.CanTouch = false -- 关闭触碰事件，交互只交给 Hitbox + ProximityPrompt。
	end
end

-- 客户端每一帧渲染画面前执行一次，用来做视觉动画。
RunService.RenderStepped:Connect(function()
	local timeNow = os.clock() -- 当前程序已经运行了多少秒。

	-- 上下漂浮偏移量。
	-- timeNow * 2 控制漂浮速度，0.35 控制漂浮幅度。
	local floatOffset = math.sin(timeNow * 2) * 0.35

	-- CFrame.Angles(x, y, z) 用来创建旋转。
	-- Roblox 这里用弧度，所以角度要用 math.rad() 转换。
	local rotation = CFrame.Angles(
		math.sin(timeNow * 2.5) * math.rad(4), -- X 轴轻微前后摆动。
		timeNow * math.rad(35), -- Y 轴持续旋转，大约每秒 35 度。
		0 -- Z 轴不额外旋转。
	)

	-- 把整个 Visual 移动到新的位置和角度。
	-- basePivot 是原始位置，CFrame.new 负责上下漂浮，rotation 负责旋转。
	visual:PivotTo(basePivot * CFrame.new(0, floatOffset, 0) * rotation)
end)

--[[
可调参数：

timeNow * 2      上下漂浮速度
0.35             上下漂浮幅度
timeNow * 2.5    前后摆动速度
math.rad(4)      前后摆动角度
math.rad(35)     水平旋转速度

一句话记忆：
basePivot 是原始位置，floatOffset 是上下飘，rotation 是旋转，PivotTo 是应用到整个展示模型。
]]
```

## 第 4 步：Play 测试

1. 点击 Roblox Studio 上方的 `Play`。
2. 看场景里的鞋子是否在上下漂浮、缓慢旋转。
3. 走到鞋子旁边。
4. 看到 `E` 提示。
5. 如果 `HoldDuration = 0`，按一下 `E`。
6. 如果 `HoldDuration > 0`，长按 `E` 到进度完成。
7. 看角色脚上是否穿上左右鞋。
8. 展开运行时角色：

```text
Workspace
└─ 你的玩家名
   ├─ Left
   └─ Right
```

如果角色下面出现 `Left` 和 `Right`，说明穿戴成功。

## 第 5 步：最终对象结构

确认你最后有这些对象：

```text
ReplicatedStorage
├─ Left                         -- Accessory，真正穿戴模板
└─ Right                        -- Accessory，真正穿戴模板

Workspace
└─ ShoePickup_01                -- Model
   ├─ Hitbox                    -- Part
   │  └─ ProximityPrompt        -- ProximityPrompt
   └─ Visual                    -- Model
      ├─ LeftVisual             -- Accessory，只展示
      └─ RightVisual            -- Accessory，只展示

ServerScriptService
└─ ShoePickupEquip              -- Script

StarterPlayer
└─ StarterPlayerScripts
   └─ ShoePickupFloat           -- LocalScript
```

## 怎么换成其他道具

这套方法可以换成帽子、披风、武器、光环。

主要改这些名字：

| 道具 | 穿戴模板 | Pickup 模型 | 展示模型 | 标记名 |
|---|---|---|---|---|
| 鞋子 | `Left` / `Right` | `ShoePickup_01` | `LeftVisual` / `RightVisual` | `PickupShoeAccessory` |
| 帽子 | `Hat_01` | `HatPickup_01` | `HatVisual` | `PickupHatAccessory` |
| 披风 | `Cape_01` | `CapePickup_01` | `CapeVisual` | `PickupCapeAccessory` |
| 武器 | `Weapon_01` | `WeaponPickup_01` | `WeaponVisual` | `PickupWeaponAccessory` |

如果只有一个装备模板，比如帽子，穿戴部分可以改成：

```lua
local hatClone = hatTemplate:Clone()
hatClone.Name = "Hat_01"
hatClone:SetAttribute(HAT_ATTRIBUTE, true)
prepareAccessory(hatClone)
hatClone.Parent = character
```

## 知识点

### Visual 和穿戴模板要分开

```text
ReplicatedStorage 里的 Left / Right = 真正穿戴模板
Workspace.ShoePickup_01.Visual 里的 LeftVisual / RightVisual = 展示模型
```

展示模型可以 `Anchored = true`，因为它只是在场景里漂浮。

真正穿戴模板不能 `Anchored = true`，否则穿上后可能让角色无法移动。

### FindFirstChildOfClass 找的是类型

代码里用：

```lua
local prompt = hitbox:FindFirstChildOfClass("ProximityPrompt")
```

它找的是对象类型，不是对象名字。

所以你的 Prompt 名字可以叫：

```text
ProximityPrompt
穿戴
领取
ShoePrompt
```

只要类型还是 `ProximityPrompt`，脚本就能找到。

### Prompt 触发后由服务器穿戴

`ProximityPrompt.Triggered` 会把触发的玩家传给服务器脚本：

```text
玩家完成交互
-> equipShoes(player)
-> 服务器 Clone 模板
-> Parent 到 Character
```

## 必坑点

### 坑 1：把真正穿戴模板也设成 Anchored

错误：

```text
ReplicatedStorage.Left.Handle.Anchored = true
ReplicatedStorage.Right.Handle.Anchored = true
```

结果：

```text
鞋子能穿上，但玩家不能移动。
```

正确：

```text
ReplicatedStorage.Left.Handle.Anchored = false
ReplicatedStorage.Right.Handle.Anchored = false
```

### 坑 2：只复制 Visual，忘了 ReplicatedStorage 模板

服务器脚本找的是：

```text
ReplicatedStorage.Left
ReplicatedStorage.Right
```

如果这里只放了展示模型，脚本会找不到模板。

### 坑 3：Prompt 需要长按但你以为是按一下

检查：

```text
HoldDuration
```

如果它大于 `0`，就需要长按。

### 坑 4：ProximityPrompt 放错位置

推荐放在：

```text
ShoePickup_01
└─ Hitbox
   └─ ProximityPrompt
```

不要随手放到 `Visual.Handle` 下面，否则后面结构容易乱。

## 常见问题

### 按 E 没反应

先看 `Output`，再检查：

```text
ShoePickupEquip 是否 Enabled = true
ProximityPrompt 是否在 Hitbox 下面
ReplicatedStorage 是否有 Left / Right
HoldDuration 是否需要长按
```

### 穿上后角色不能移动

检查真正穿戴模板的 `Handle`：

```text
ReplicatedStorage.Left.Handle
ReplicatedStorage.Right.Handle

Anchored = false
CanCollide = false
Massless = true
```

### 地上的鞋为什么不会消失

这是当前设计。

```text
Visual 继续展示
Prompt 继续可用
玩家可以重复穿戴
```

如果要做一次性拾取，再额外关闭 `Prompt.Enabled` 或隐藏 `Visual`。

### 为什么现在不抽模块

一个道具点先用这张知识卡最快。

等你已经做了多个类似道具，比如帽子、披风、武器、光环，再考虑抽：

```text
PickupEquipService
FloatPickupController
```

## 最小原则

```text
Accessory 模板先做好。
Visual 只负责展示。
Hitbox 只负责交互范围。
ProximityPrompt 只负责按键触发。
Server Script 只负责校验和穿戴。
LocalScript 只负责漂浮动画。
```
