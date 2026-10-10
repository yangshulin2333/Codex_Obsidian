---@class Config_Party
---@field lv1Per table
---@field lv2Reward table
---@field lv3Per table
---@field lv3 number
---@field roomIcon2 string
---@field lv1 number
---@field id number
---@field lv1Reward table
---@field lv2Per table
---@field name string
---@field lv3Reward table
---@field roomIcon string
---@field lv2 number
---@field icon string
---@field bossIcon string
---@type Party[]
local module = {}
for __,cfg in ipairs(script:GetChildren()) do
	if cfg.ClassName == "ModuleScript" then
		local tab = require(cfg)
		for i,v in pairs(tab) do
			module[i] = v
		end
	end
end
return module
