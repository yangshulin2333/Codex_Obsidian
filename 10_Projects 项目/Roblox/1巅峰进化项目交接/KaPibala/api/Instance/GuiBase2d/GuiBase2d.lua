---@class GuiBase2d:Instance
---@field AbsolutePosition Vector2 @描述 UI 元素的实际屏幕位置（以像素为单位）。
---@field AbsoluteRotation number @描述 UI 元素在屏幕上的真实旋转角度，单位是度。
---@field AbsoluteSize Vector2 @描述 UI 元素的实际屏幕尺寸（以像素为单位）。
---@field AutoLocalize boolean @设置为 true 时，将根据为此 GuiBase2d 指定的 GuiBase2d.RootLocalizationTable 对此 GuiBase2d 及其子类进行本地化。
---@field RootLocalizationTable LocalizationTable @一个LocalizationTable中引用的作用就是对这个 GuiBase2d 及其子类进行自动本地化。
local module = {}
