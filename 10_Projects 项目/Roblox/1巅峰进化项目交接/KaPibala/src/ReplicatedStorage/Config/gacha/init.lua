---@class Config_gacha
---@field p_type number
---@field pet_id table
---@field weight table
---@field id number
---@field price number
---@field icon string
---@field stage number
---@type gacha[]
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
