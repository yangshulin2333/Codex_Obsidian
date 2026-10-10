---@class Atmosphere:Instance
---@field Color Color3 @改变氛围的色调，以营造微妙的环境情绪。
---@field Decay Color3 @当与增加的大气/烟雾|烟雾和大气/眩光|眩光一起使用时，定义了远离太阳的大气色调，逐渐从大气/颜色|颜色下降到这个值。 有关属性比较和示例环境，请参阅文章/大气|大气控制文章。
---@field Density number @定义大气中的粒子数量，并基本上控制游戏中的物体/地形将被它们遮挡的程度。
---@field Glare number @当与增加的大气/烟雾|烟雾一起使用时，请指定太阳周围的大气的辉光/眩光。更多的眩光导致阳光照射在天空和世界上的效果增加。
---@field Haze number @定义大气的模糊度，在地平线上和远处都有可见效果。
---@field Offset number @控制光线在相机和天空背景之间的传输方式。
local c = {}