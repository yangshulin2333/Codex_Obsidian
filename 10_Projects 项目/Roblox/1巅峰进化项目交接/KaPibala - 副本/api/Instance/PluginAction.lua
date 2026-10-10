---@class PluginAction:Instance
---@field ActionId string @唯一标识此操作的字符串。
---@field AllowBinding boolean @是否将从 Studio 的快捷窗口中隐藏
---@field StatusTip string @从 Roblox Studio 的键盘快捷键窗口查看操作时的操作描述。
---@field Text string @在 Roblox Studio 中查看此操作时显示的文本。
---@field Triggered RBXScriptSignal @触发动作时触发。可以通过从快捷工具栏激活动作实现，也可以通过使用与其绑定的键盘快捷键完成。
local c = {}