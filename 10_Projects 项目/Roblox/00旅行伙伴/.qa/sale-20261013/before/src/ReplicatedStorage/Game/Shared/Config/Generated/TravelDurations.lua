--!strict
-- 此文件由 Excel Config 工具自动生成，请勿手动修改。
-- 来源：design/config/workbooks/TravelConfig.xlsx / TravelDurations

return {
	["shallow_short"] = {
		["Id"] = "shallow_short",
		["SeaId"] = "shallow",
		["Name"] = "短途 10 分钟",
		["Seconds"] = 600,
		["YieldMultiplier"] = 1,
		["Order"] = 1,
	},
	["shallow_long"] = {
		["Id"] = "shallow_long",
		["SeaId"] = "shallow",
		["Name"] = "长途 30 分钟",
		["Seconds"] = 1800,
		["YieldMultiplier"] = 3,
		["Order"] = 2,
	},
	["near_short"] = {
		["Id"] = "near_short",
		["SeaId"] = "near",
		["Name"] = "标准 30 分钟",
		["Seconds"] = 1800,
		["YieldMultiplier"] = 1,
		["Order"] = 3,
	},
	["near_long"] = {
		["Id"] = "near_long",
		["SeaId"] = "near",
		["Name"] = "长途 60 分钟",
		["Seconds"] = 3600,
		["YieldMultiplier"] = 2,
		["Order"] = 4,
	},
}
