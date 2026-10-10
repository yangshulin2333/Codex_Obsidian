---@class Config_reborn
---@field need_lv number
---@field atk number
---@field exp number
---@field id number
---@field unlock string
---@field unlock_icon string
---@field name string
---@field unlock_title string
---@field mark string
---@field unlock_desc string
---@field save_lv number
---@type reborn[]
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
