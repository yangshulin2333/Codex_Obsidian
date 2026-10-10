---@class Config_title
---@field needType number
---@field id number
---@field need string
---@field needNum number
---@field limitTime number
---@field rare number
---@field DMG number
---@field MaxHp number
---@field name string
---@field EXP number
---@field icon string
---@field order number
---@type title[]
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
