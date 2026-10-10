---@class Config_audio
---@field volume number
---@field rid string
---@field group string
---@field id string
---@field desc string
---@type audio[]
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
