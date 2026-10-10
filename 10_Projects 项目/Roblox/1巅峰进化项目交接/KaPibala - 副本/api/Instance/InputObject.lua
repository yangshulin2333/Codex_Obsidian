---@class InputObject:Instance @输入开始时创建的、描述特定用户输入的对象，如鼠标的移动、触控、键盘操作等等。
---@field Delta Vector3 @描述鼠标/游戏手柄移动之间 Delta 的 Vector3
---@field KeyCode KeyCode @包含描述使用的输入类型的 Enum (枚举)
---@field Position Vector3 @描述此项输入的位置值
---@field UserInputState UserInputState @用户输入的状态
---@field UserInputType UserInputType @用户输入的类型
local module = {}
---@type fun(param:ModifierKey):boolean
function module:IsModifierKeyDown(modifierKey)
end