---@class Config_skill
---@field need_lv number
---@field lv5_need number
---@field lv1_value number
---@field shardsIcon string
---@field lv4_value number
---@field icon string
---@field cold number
---@field lv3_value number
---@field lv3_need number
---@field id number
---@field desc string
---@field name string
---@field lv1_need number
---@field lv4_need number
---@field lv2_value number
---@field lv5_value number
---@field lv2_need number
---@type skill[]
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
