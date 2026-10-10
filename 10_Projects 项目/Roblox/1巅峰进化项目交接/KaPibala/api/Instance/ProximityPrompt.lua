---@class ProximityPrompt:Instance @ProximityPrompt 一个交互组件
---@field ActionText string @对用户显示的动作文本
---@field ClickablePrompt boolean @是否启用交互
---@field Enabled boolean @是否显示
---@field Exclusivity number
---@field HoldDuration float @长按的时间
---@field GamepadKeyCode KeyCode @发起交互的手柄按钮
---@field KeyboardKeyCode KeyCode @发起交互的按键
---@field MaxActivationDistance float @最大可交互的距离
---@field ObjectText string @名称title
---@field RequiresLineOfSight boolean @是否能在视野外进行交互(穿墙)
---@field UIOffset Vector2 @交互ui像素偏移量
---@field PromptButtonHoldBegan RBXScriptSignal @玩家发起交互时触发,第一个参数是player
---@field PromptButtonHoldEnded RBXScriptSignal @玩家发起交互时触发,第一个参数是player
---@field PromptHidden RBXScriptSignal @玩家离开交互范围/视野触发ui隐藏
---@field PromptShown RBXScriptSignal @玩家进入交互范围,ui出现,第一个参数是player
---@field TriggerEnded RBXScriptSignal @在 key 或按钮被释放时触发，用于需要玩家长按按钮的事件
---@field Triggered RBXScriptSignal @在按下提示的 key（键）或按钮时触发。如果使用了 ProximityPrompt.HoldDuration，则在按住按钮指定时间后触发
local module = {}
---@type fun() @触发一个信号，表示用户开始按下提示的 GUI 按钮
function module:InputHoldBegin()
end
function module:InputHoldEnd()
end
