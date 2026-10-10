---@class HumanoidDescription:Instance @HumanoidDescription 是存储描述 Humanoid R6 和 R15 骨骼绑定的对象。可以 applied（应用）它来设定一个骨骼的比例、服装（Shirt、Pants、ShirtGraphic）、Accessories、Animations 和 BodyColors。
---@field BackAccessory string @以逗号分隔的资源 ID 列表，决定当描述被 applied（应用）至 Humanoid（人形对象）模型时该添加哪些 Accessories（饰品），通常是附加在背部的饰品（例如披风）
---@field BodyTypeScale string @决定一个人形对象绑定骨骼的形状从标准 R15 身形 (0) 插值到一个更高更苗条的身体类型 (1) 的因子（当 applied（应用）时，映射到 HumanoidDescription 的 “BodyTypeScale” NumberValue）
---@field ClimbAnimation number @当描述 applied（应用）至 Humanoid（人形对象）时，决定在 state（状态）为 Climbing（攀爬）时要播放的 Animation.AnimationId
---@field DepthScale number @决定一个 Humanoid（人形对象）模型的深度（从后到前的距离）缩放比例，当描述被 applied（应用）到人形对象上时，对应人形对象内的 “DepthScale” NumberValue
---@field Face number @决定要应用至 Humanoid（人形对象）的 Face（脸部）的资源 ID
---@field FaceAccessory string @以逗号分隔的资源 ID 列表，决定当描述被 applied（应用）至 Humanoid（人形对象）模型时该添加哪些 Accessories（饰品），通常是附加在面部的饰品（例如眼镜）
---@field FallAnimation number @当描述 applied（应用）至 Humanoid（人形对象）时，决定在 state（状态）为 Freefall（自由落体）时要播放的 Animation.AnimationId
---@field FrontAccessory string @以逗号分隔的资源 ID 列表，决定当描述被 applied（应用）时该添加哪些饰品，通常是附加在躯干前部的饰品（例如勋章或领带）
---@field GraphicTShirt number @决定当 ShirtGraphic applied（应用）时使用的 Graphic
---@field HairAccessory string @以逗号分隔的资源 ID 列表，决定当描述被 applied（应用）时该添加哪些饰品，通常是附加在头部的头发造型
---@field HatAccessory string @以逗号分隔的资源 ID 列表，决定当描述被 applied（应用）时该添加哪些饰品，通常是附加在头部的饰品
---@field Head number @决定要应用至 Humanoid（人形对象）的 Head（头部）的资源 ID
---@field HeadColor Color3 @在 applied（应用）时决定一个 Humanoid（人形对象）的 BodyColors.HeadColor3
---@field HeadScale number @决定一个 Humanoid（人形对象）的头部缩放比例，当描述被 applied（应用）到人形对象上时，对应人形对象内的 “HeadScale” NumberValue
---@field HeightScale number @决定一个 Humanoid（人形对象）的高度（从顶部到底部的距离）缩放比例，当描述被 applied（应用）到人形对象上时，对应人形对象内的 “BodyHeightScale” NumberValue
---@field IdleAnimation number @当描述 applied（应用）至 Humanoid（人形对象）时，决定在 state（状态）为接近零的速度 Running（跑步）时要播放的 Animation.AnimationId
---@field JumpAnimation number @当描述 applied（应用）至 Humanoid（人形对象）时，决定在 state（状态）为 Jumping（跳跃）时要播放的 Animation.AnimationId
---@field LeftArm number @决定要应用至 Humanoid（人形对象）的 LeftArm 的资源 ID
---@field LeftArmColor Color3 @应用时决定一个 Humanoid（人形对象）的 BodyColors.LeftArmColor3
---@field LeftLeg number @决定要应用至 Humanoid（人形对象）的 LeftLeg 的资源 ID
---@field LeftLegColor Color3 @应用时决定一个 Humanoid（人形对象）的 BodyColors.LeftLegColor3
---@field NeckAccessory string @以逗号分隔的资源 ID 列表，决定当描述被 applied（应用）时该添加哪些饰品，通常是附加在颈部的饰品（例如围巾或项链）
---@field Pants number @决定当 Pants applied（应用）时使用的 ShirtTemplate
---@field ProportionScale number @决定一个人形对象模型有多宽（0）或多窄（1），当 applied（应用）时，应用至人形对象内的 “BodyProportionScale” NumberValue。
---@field RightArm number @决定要应用至 Humanoid（人形对象）的 RightArm 的资源 ID
---@field RightArmColor Color3 @应用时决定一个 Humanoid（人形对象）的 BodyColors.RightArmColor3
---@field RightLeg number @决定要应用至 Humanoid（人形对象）的 RightLeg 的资源 ID
---@field RightLegColor Color3 @应用时决定一个 Humanoid（人形对象）的 BodyColors.RightLegColor3
---@field RunAnimation number @当描述 applied（应用）至 Humanoid（人形对象）时，决定在 state（状态）为中等速度 Running（跑步）时要播放的 Animation.AnimationId
---@field Shirt number @决定当 Shirt applied（应用）时使用的 ShirtTemplate
---@field ShouldersAccessory string @以逗号分隔的资源 ID 列表，决定当描述被 applied（应用）时该添加哪些饰品，通常是附加在肩部的饰品（例如坐在肩部的小宠物）
---@field SwimAnimation number @当描述 applied（应用）至 Humanoid（人形对象）时，决定在 state（状态）为 Swimming（游泳）时要播放的 Animation.AnimationId
---@field Torso number @决定要应用至 Humanoid（人形对象）的 Torso（躯干）的资源 ID
---@field TorsoColor Color3 @应用时决定一个 Humanoid（人形对象）的 BodyColors.TorsoColor3
---@field WaistAccessory string @以逗号分隔的资源 ID 列表，决定当描述被 applied（应用）至 Humanoid（人形对象）模型时该添加哪些 Accessories（饰品），通常是附加在腰部的饰品（例如腰带）
---@field WalkAnimation string @当描述 applied（应用）至 Humanoid（人形对象）时，决定在 state（状态）为较慢速度 Running（跑步）时要播放的 Animation.AnimationId
---@field WidthScale number @决定一个 Humanoid（人形对象）的宽度（从左到右的距离）缩放比例，当描述被 applied（应用）到人形对象上时，对应人形对象内的 “BodyWidthScale” NumberValue
---@field EmotesChanged RBXScriptSignal @在 set（设置）此描述上装备的表情动作时触发 ( Dictionary newEmotes ))
---@field EquippedEmotesChanged RBXScriptSignal @在 set（设置）此描述上装备的表情动作时触发( Array newEquippedEmotes )
local module = {}
---@type fun(name:string,assetId:number) @将一个拥有名称和资源 ID 的表情动作加入描述
---@param name string
---@param assetid number
function module:AddEmote(name,assetid)
end
---@type fun():table<string,number> @返回 added（添加）或 set（设置）至此描述的表情动作的字典
---@return table<string,number>
function module:GetEmote()
end
---@type fun():table<string,any>[] @GetEquippedEmotes 返回一个表的数组，表明由 SetEquippedEmotes 设置的每个装备表情动作的 Name（名称）和 Slot（槽位）。
---@return table<string,any>[]
function module:GetEquippedEmotes()
end
---@type fun(name:string) @移除给定名称的所有表情动作
---@param name string
function module:RemoveEmote(name)
end
---@type fun(emotes:table<string,number>) @SetEmotes 根据类似 GetEmotes 返回的表，设定所有在此描述上的表情动作。它会触发 EmotesChanged
---@param emotes table<string,number>
function module:SetEmotes(emotes)
end
---@type fun(equippedEmotes:table<string,any>) @SetEmotes 根据类似 GetEmotes 返回的表，设定所有在此描述上的表情动作。它会触发 EmotesChanged
---@param equippedEmotes table<string,any>[]
function module:SetEquippedEmotes(equippedEmotes)
end