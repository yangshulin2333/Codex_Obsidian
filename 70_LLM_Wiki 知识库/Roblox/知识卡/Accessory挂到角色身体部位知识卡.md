---
type: concept
domain: roblox
status: evergreen
owner: mixed
source: mixed
created: 2026-06-30
updated: 2026-07-02
aliases:
  - 把武器挂到手上知识卡
---

# Accessory挂到角色身体部位知识卡

## 这个功能要做什么

把一个导入 Roblox Studio 的模型做成 `Accessory`，让它自动挂到角色指定身体部位上。

本卡用“武器挂到右手”举例，但同一套方法也可以用在：

```text
武器挂手上
鞋子挂脚上
帽子挂头上
披风挂背上
光环挂身体上
```

核心流程是：

```text
创建 R15 参考角色
-> 把模型整理成 Accessory
-> 让模型里有一个叫 Handle 的主零件
-> 从角色身体部位复制同名 Attachment
-> 手动摆好模型位置
-> 把两个 Attachment 的 WorldCFrame 对齐
-> 放到 ReplicatedStorage
-> 用脚本穿到角色身上测试
```

如果你已经做好了 `Accessory`，想把它做成地上漂浮、靠近按 `E` 穿戴的道具，看：

- [[ProximityPrompt漂浮道具穿戴知识卡]]

## 第 0 步：创建 R15 参考角色

你需要一个角色模板，用来对齐挂点。

### 0.1 创建 R15 模板

在 Roblox Studio 顶部菜单里操作：

```text
Avatar / 虚拟形象
-> Rig Builder / Build Rig
-> Rig Type 选 R15
-> 选择 Block Rig
```

创建后，`Workspace` 里会出现一个角色模型。把它改名为：

```text
R15_Template
```

它是一个 `Model`，大概结构是：

```text
Workspace
└─ R15_Template              -- Model，参考角色
   ├─ Humanoid               -- Humanoid，角色人形对象
   ├─ RightHand              -- MeshPart，右手身体部位
   │  └─ RightGripAttachment -- Attachment，右手握持挂点
   ├─ LeftHand
   ├─ Head
   ├─ UpperTorso
   ├─ RightFoot
   └─ LeftFoot
```

本卡用右手举例，所以后面会用：

```text
R15_Template
└─ RightHand
   └─ RightGripAttachment
```

### 0.2 先确定你要挂到哪里

不要硬背 Attachment 名字，优先看你的 `R15_Template` 里实际有什么。

常见选择：

| 目标 | 参考身体部位 | 常见 Attachment |
|---|---|---|
| 右手武器 | `RightHand` | `RightGripAttachment` |
| 左手武器 | `LeftHand` | `LeftGripAttachment` |
| 帽子 | `Head` | `HatAttachment` |
| 背部披风 | `UpperTorso` | `BodyBackAttachment` |
| 鞋子 / 脚部饰品 | `RightFoot` / `LeftFoot` | 以角色模板里实际存在的脚部 Attachment 为准 |

规则只有一句：

```text
模型 Handle 里的 Attachment 名字，必须和角色身体部位里的 Attachment 名字一样。
```

## 第 1 步：把模型整理成 Accessory

### 1.1 创建 Accessory 容器

1. 在 `Explorer` 里右键 `Workspace`。
2. 选择 `Insert Object`。
3. 选择 `Accessory`。
4. 把这个 `Accessory` 改名为：

```text
Weapon_01
```

这里的 `Weapon_01` 是示例名，你做帽子可以叫 `Hat_01`，做披风可以叫 `Cape_01`。

### 1.2 创建或整理 Handle

Roblox 的 `Accessory` 里必须有一个主零件叫：

```text
Handle
```

如果你导入后的模型是这样：

```text
Workspace
└─ ImportedWeapon            -- Model，导入模型外壳
   └─ MeshPart               -- MeshPart，真实武器网格
```

整理成：

```text
Workspace
└─ Weapon_01                 -- Accessory，饰品容器
   └─ Handle                 -- MeshPart，主零件，名字必须叫 Handle
```

操作：

1. 找到导入模型里的真实武器 `MeshPart`。
2. 把这个 `MeshPart` 改名为 `Handle`。
3. 把 `Handle` 拖到 `Weapon_01` 下面。
4. 删除多余的外层导入 `Model`。

完成后检查：

```text
Workspace
└─ Weapon_01                 -- Accessory
   └─ Handle                 -- MeshPart / BasePart
```

## 第 2 步：把模型摆到角色身上正确位置

先不要急着复制数值。

现在要用眼睛把 `Handle` 摆到 `R15_Template` 右手附近，让它看起来就是最终穿戴后的样子。

操作：

1. 选中 `Weapon_01.Handle`。
2. 用移动工具调整位置。
3. 用旋转工具调整方向。
4. 必要时调整大小。

目标是：

```text
武器在右手旁边
握持方向正确
大小看起来合适
角色移动时你希望它就保持这个相对位置
```

这一步必须人工肉眼判断。脚本无法替你判断“看起来是否合适”。

## 第 3 步：复制角色身体部位的 Attachment

现在从参考角色身上复制目标挂点。

本卡是右手武器，所以找到：

```text
Workspace
└─ R15_Template
   └─ RightHand
      └─ RightGripAttachment
```

操作：

1. 选中 `RightGripAttachment`。
2. `Ctrl + C` 复制。
3. 选中 `Weapon_01.Handle`。
4. `Ctrl + V` 粘贴。

粘贴后结构应该是：

```text
Workspace
└─ Weapon_01
   └─ Handle
      └─ RightGripAttachment
```

注意：

```text
这个 Attachment 的名字不要改。
角色身体部位里叫什么，Handle 下面就也叫什么。
```

## 第 4 步：用 WorldCFrame 对齐两个 Attachment

现在场景里有两个同名 Attachment：

```text
R15_Template.RightHand.RightGripAttachment
Weapon_01.Handle.RightGripAttachment
```

你要让 `Weapon_01.Handle.RightGripAttachment` 的世界位置和世界朝向，等于角色右手上的 `RightGripAttachment`。

### 4.1 复制角色 Attachment 的 WorldCFrame

1. 选中：

```text
R15_Template.RightHand.RightGripAttachment
```

2. 在 `Properties` 面板里找到：

```text
衍生世界数据
└─ WorldCFrame
   ├─ Position
   └─ Orientation
```

3. 记下或复制这里的：

```text
Position
Orientation
```

### 4.2 粘贴到模型 Handle 里的 Attachment

1. 选中：

```text
Weapon_01.Handle.RightGripAttachment
```

2. 在 `Properties` 面板里找到同样的位置：

```text
衍生世界数据
└─ WorldCFrame
   ├─ Position
   └─ Orientation
```

3. 把刚才角色 Attachment 的 `Position` 和 `Orientation` 填到这里。

完成后，两个 Attachment 的世界位置和世界朝向应该一样。

这一步的目的：

```text
你已经把武器摆到正确外观位置。
现在把武器 Handle 里的 Attachment 放到角色手部挂点上。
以后 Roblox 穿戴时会对齐这两个同名 Attachment。
对齐后，武器就会回到你刚才肉眼摆好的位置。
```

不要只复制本地 `Position` / `Orientation`。

本卡要复制的是：

```text
WorldCFrame.Position
WorldCFrame.Orientation
```

## 第 5 步：设置 Handle 属性

选中：

```text
Weapon_01.Handle
```

设置：

```text
Anchored = false
CanCollide = false
Massless = true
```

如果你的 `Accessory` 里有多个物理零件，所有 `BasePart` 都建议这样设置。

最重要的是：

```text
真正穿到角色身上的 Accessory，不能 Anchored = true。
```

否则可能出现：

```text
角色穿上后不能移动
装备卡住角色
装备掉落或不跟随角色
```

## 第 6 步：放到 ReplicatedStorage

现在把做好的模板放到 `ReplicatedStorage`，让脚本可以复制它。

### 6.1 创建模板文件夹

1. 右键 `ReplicatedStorage`。
2. 选择 `Insert Object`。
3. 选择 `Folder`。
4. 改名为：

```text
AccessoryAssets
```

### 6.2 移动 Accessory 模板

把 `Workspace` 里的 `Weapon_01` 拖到：

```text
ReplicatedStorage
└─ AccessoryAssets
```

最终结构：

```text
ReplicatedStorage
└─ AccessoryAssets            -- Folder，存放饰品模板
   └─ Weapon_01               -- Accessory，武器模板
      └─ Handle               -- MeshPart / BasePart，主零件
         └─ RightGripAttachment -- Attachment，和角色右手同名
```

## 第 7 步：创建测试脚本

这一步只是用来验证 `Accessory` 是否真的能挂到角色身上。

### 7.1 新建 Script

1. 右键 `ServerScriptService`。
2. 选择 `Insert Object`。
3. 选择 `Script`。
4. 改名为：

```text
GiveAccessory
```

### 7.2 粘贴代码

把 `GiveAccessory` 里的默认代码删掉，粘贴：

```lua
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- 找到 ReplicatedStorage 里的饰品模板文件夹。
local accessoryAssets = ReplicatedStorage:WaitForChild("AccessoryAssets")

-- 找到真正要穿到角色身上的 Accessory 模板。
local accessoryTemplate = accessoryAssets:WaitForChild("Weapon_01")

-- 给测试装备打标记，方便角色重生或反复测试时删除旧装备。
local ACCESSORY_ATTRIBUTE = "AutoGiveAccessory"

-- 穿到角色身上的 Accessory 不能 Anchored。
-- 这里做一次保险处理，防止手动设置时漏改属性。
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

-- 删除旧的测试装备，避免角色身上叠很多个 Weapon_01。
local function removeOldAccessory(character)
	for _, child in ipairs(character:GetChildren()) do
		if child:IsA("Accessory") and child:GetAttribute(ACCESSORY_ATTRIBUTE) then
			child:Destroy()
		end
	end
end

-- character 是玩家出生后的角色模型。
local function giveAccessory(character)
	local humanoid = character:WaitForChild("Humanoid")

	if humanoid.Health <= 0 then
		return
	end

	removeOldAccessory(character)

	-- 复制模板，打标记，最后交给 Humanoid:AddAccessory 穿戴。
	local accessory = accessoryTemplate:Clone()
	accessory:SetAttribute(ACCESSORY_ATTRIBUTE, true)
	prepareAccessory(accessory)

	-- AddAccessory 会根据 Handle 里的 Attachment 名字，
	-- 去角色身体上找同名 Attachment，然后自动焊接对齐。
	humanoid:AddAccessory(accessory)
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(giveAccessory)

	-- 如果脚本启动时角色已经存在，也补发一次。
	if player.Character then
		task.defer(giveAccessory, player.Character)
	end
end)
```

## 第 8 步：Play 测试

在 Roblox Studio 上方点击：

```text
Play
```

不要只点 `Run`。

成功后应该看到：

```text
玩家角色右手上出现 Weapon_01
角色移动时武器跟着走
武器位置和你在 R15_Template 上摆的位置一致
```

运行时可以展开角色检查：

```text
Workspace
└─ 你的玩家名
   └─ Weapon_01
      └─ Handle
         └─ RightGripAttachment
```

如果角色下面出现 `Weapon_01`，说明脚本已经把 `Accessory` 穿上了。

## 第 9 步：最终结构检查

确认你最后有这些对象：

```text
Workspace
└─ R15_Template                         -- Model，参考角色，只用来调位置

ReplicatedStorage
└─ AccessoryAssets                      -- Folder，饰品模板文件夹
   └─ Weapon_01                         -- Accessory，真正穿戴模板
      └─ Handle                         -- MeshPart / BasePart，必须叫 Handle
         └─ RightGripAttachment         -- Attachment，必须和角色右手同名

ServerScriptService
└─ GiveAccessory                        -- Script，测试穿戴脚本
```

如果要正式放进游戏，`R15_Template` 可以从 `Workspace` 删除或移到暂存区，因为它只是调位置用的参考角色。

## 怎么换成其他道具

这张卡的重点不是“武器”，而是：

```text
Accessory + Handle + 同名 Attachment
```

换道具时主要改这几个东西：

| 道具 | Accessory 示例名 | 目标身体部位 | Attachment 来源 | 模板文件夹 |
|---|---|---|---|---|
| 右手武器 | `Weapon_01` | `RightHand` | `RightGripAttachment` | `AccessoryAssets` |
| 左手武器 | `Weapon_Left_01` | `LeftHand` | `LeftGripAttachment` | `AccessoryAssets` |
| 帽子 | `Hat_01` | `Head` | `HatAttachment` | `AccessoryAssets` |
| 披风 | `Cape_01` | `UpperTorso` | `BodyBackAttachment` | `AccessoryAssets` |
| 鞋子 | `RightShoe_01` / `LeftShoe_01` | `RightFoot` / `LeftFoot` | 以角色脚部实际 Attachment 为准 | `AccessoryAssets` |

换成其他模板时，测试脚本里只需要改：

```lua
local accessoryTemplate = accessoryAssets:WaitForChild("Weapon_01")
```

比如帽子：

```lua
local accessoryTemplate = accessoryAssets:WaitForChild("Hat_01")
```

## 知识点

### Accessory 是 Roblox 的穿戴容器

Roblox 识别可穿戴外观时，核心看：

```text
Accessory
└─ Handle
   └─ Attachment
```

`Accessory` 是饰品容器。

`Handle` 是主物理零件，名字必须叫 `Handle`。

`Attachment` 是挂点，名字要和角色身体部位里的 Attachment 对上。

### 同名 Attachment 决定挂到哪里

Roblox 穿戴时会做这件事：

```text
读取 Handle 里的 Attachment 名字
-> 到角色身体里找同名 Attachment
-> 把两个 Attachment 对齐
-> 把 Handle 焊到角色身上
```

所以：

```text
名字一样，才能知道挂到哪里。
WorldCFrame 对齐，才能让姿势正确。
```

### WorldCFrame 是世界位置和世界朝向

`Attachment.Position` 是相对父对象的本地位置。

`Attachment.WorldCFrame.Position` 是它在整个世界里的位置。

调挂点时，本卡用的是：

```text
WorldCFrame.Position
WorldCFrame.Orientation
```

因为你是在 `Workspace` 里对着参考角色摆位置。

### Humanoid:AddAccessory 是测试穿戴的推荐方式

本卡测试脚本用：

```lua
humanoid:AddAccessory(accessory)
```

原因是语义最明确：

```text
把这个 Accessory 加到这个 Humanoid 身上。
```

如果你已有脚本用：

```lua
accessory.Parent = character
```

并且已经验证成功，也可以保留。新手测试时优先用 `Humanoid:AddAccessory` 更直观。

## 必坑点

### 坑 1：Handle 没叫 Handle

错误结构：

```text
Weapon_01
└─ MeshPart
```

正确结构：

```text
Weapon_01
└─ Handle
```

`Handle` 名字写错，Roblox 很可能不会按 Accessory 规则穿戴。

### 坑 2：Handle 下的 Attachment 名字和角色不一致

错误：

```text
角色右手：RightGripAttachment
模型 Handle：WeaponAttachment
```

正确：

```text
角色右手：RightGripAttachment
模型 Handle：RightGripAttachment
```

两个名字必须一样。

### 坑 3：只复制本地 Position，不复制 WorldCFrame

不要只看：

```text
CFrame
Position
Orientation
```

本卡需要对齐的是：

```text
衍生世界数据
└─ WorldCFrame
   ├─ Position
   └─ Orientation
```

如果复制错，常见结果是：

```text
能穿上，但位置歪
能穿上，但方向反了
能穿上，但离角色很远
```

### 坑 4：真正穿戴模板 Anchored = true

错误：

```text
ReplicatedStorage.AccessoryAssets.Weapon_01.Handle.Anchored = true
```

正确：

```text
Anchored = false
CanCollide = false
Massless = true
```

`Anchored = true` 只适合场景展示物，不适合真正穿到角色身上的模板。

### 坑 5：把 Accessory 又套在一个 Model 里

错误结构：

```text
ReplicatedStorage
└─ AccessoryAssets
   └─ SomeModel
      └─ Weapon_01
         └─ Handle
```

测试脚本找的是：

```text
AccessoryAssets.Weapon_01
```

所以推荐结构保持简单：

```text
ReplicatedStorage
└─ AccessoryAssets
   └─ Weapon_01
      └─ Handle
```

## 常见问题

### 为什么我穿上后位置不对

按顺序检查：

```text
1. 目标 Attachment 名字是否和角色身体部位同名
2. 是否复制的是 WorldCFrame.Position / WorldCFrame.Orientation
3. 复制数值前，模型是否已经在 R15_Template 上摆好位置
4. Handle 是否有缩放、旋转或多层父级导致你看错了对象
```

### 为什么穿不上

检查结构：

```text
Weapon_01 是否是 Accessory
Weapon_01 下面是否有 Handle
Handle 下面是否有 Attachment
Attachment 名字是否和角色身体部位同名
脚本里的 WaitForChild("Weapon_01") 名字是否和实际对象一致
```

### 为什么角色穿上后不能移动

检查真正穿戴模板：

```text
ReplicatedStorage.AccessoryAssets.Weapon_01.Handle

Anchored = false
CanCollide = false
Massless = true
```

如果有多个 `BasePart`，也要一起检查。

### 多个零件的模型怎么办

最小教程建议先做成一个 `Handle`。

如果确实有多个零件，原则是：

```text
一个主零件叫 Handle
其他零件焊到 Handle
所有零件 Anchored = false
所有零件 CanCollide = false
```

这属于进阶内容。第一次跑通时，优先用单个 `MeshPart` 做 `Handle`。

### R6 角色能不能用

本卡默认按 R15 讲。

R6 和 R15 的身体部位、Attachment 分布不一样。新项目建议先用 R15 跑通，再考虑 R6 兼容。

### 做好后怎么变成地上拾取道具

本卡只负责把模型做成可穿戴 `Accessory`。

如果要做成“地上漂浮、靠近按 E 穿戴”，下一步接：

- [[ProximityPrompt漂浮道具穿戴知识卡]]

## 最小原则

```text
Accessory 是容器。
Handle 是主零件。
Attachment 是挂点。
同名 Attachment 决定挂到哪里。
WorldCFrame 对齐决定穿上后的姿势。
真正穿戴模板不能 Anchored。
```
