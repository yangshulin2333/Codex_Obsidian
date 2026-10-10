---@class Frame:GuiObject @框架是一个GuiObject，它呈现为没有其他内容的纯矩形。 它们是GuiObject的最简单的具体示例，因为它们提供的附加功能很少（Frame.FrameStyle）。 尽管如此，框架还是用作其他GuiObject（例如TextLabel，ImageLabel）的容器的。 将“文件夹上的框架”用作容器对象的主要好处是可以进一步操纵任何后代GuiObjects的GuiObject.Size和GuiObject.Position。
---@field Style FrameStyle @从一系列预定样式中设置框架的外观。
local module = {}