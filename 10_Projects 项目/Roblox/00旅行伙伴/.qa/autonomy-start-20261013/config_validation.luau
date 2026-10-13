local fs = require("@lune/fs")
local luau = require("@lune/luau")
local root = "F:/HunyueRoblox/TravelBuddy/"
local generated = {}
for _, name in ipairs({"TravelSettings", "TravelItems", "TravelSeas", "TravelDurations", "TravelUpgrades", "TravelPostcards"}) do
	generated[name] = root .. "src/ReplicatedStorage/Game/Shared/Config/Generated/" .. name .. ".lua"
end
local settingsPath = generated.TravelSettings
local weightsPath = root .. "src/ServerScriptService/Server/Game/Config/Generated/TravelWeights.lua"
local configPath = root .. "src/ServerScriptService/Server/Game/Config/TravelConfig.lua"
local function loadConfig(overrides)
	local cache = {}
	local loadModule
	loadModule = function(path)
		if cache[path] then return cache[path] end
		local module = luau.load(fs.readFile(path), {
			injectGlobals = true,
			environment = {
				require = loadModule,
				script = { Parent = { Generated = { TravelWeights = weightsPath } } },
				game = { GetService = function() return { Game = { Shared = { Config = { Generated = generated } } } } end },
			},
		})()
		if path == settingsPath then
			for key, value in pairs(overrides or {}) do
				module[key] = {Id = key, Value = value}
			end
		end
		cache[path] = module
		return module
	end
	return loadModule(configPath)
end
local config = loadConfig()
assert(config.Settings.PrepareMinSeconds == 60 and config.Settings.PrepareMaxSeconds == 180)
assert(config.Settings.FirstPrepareSeconds == 30)
assert(config.Settings.StudioPrepareMinSeconds == 15 and config.Settings.StudioPrepareMaxSeconds == 30)
assert(config.Settings.RestSeconds == 180)
assert(config.Settings.StudioTimeScale == 0.05 and config.Settings.ProductionTimeScale == 1)
assert(config.Settings.MaxPlayers == 4)
assert(config.SeaChoiceWeights.shallow == 1 and config.SeaChoiceWeights.near == 1)
local failures = {
	{PrepareMinSeconds = 0},
	{PrepareMinSeconds = -1},
	{PrepareMinSeconds = 1.5},
	{PrepareMinSeconds = 181},
	{StudioPrepareMinSeconds = 31},
	{StudioPrepareMaxSeconds = 0},
	{FirstPrepareSeconds = 0},
	{FirstPrepareSeconds = 0 / 0},
	{FirstPrepareSeconds = math.huge},
	{RestSeconds = 0},
	{ShortChoiceWeight = -1},
	{LongChoiceWeight = 0.5},
	{ShortChoiceWeight = 0, LongChoiceWeight = 0},
	{ShortChoiceWeight = math.huge},
	{SeaChoiceWeight_shallow = 0},
	{SeaChoiceWeight_near = -1},
	{SeaChoiceWeight_near = 0.5},
	{SeaChoiceWeight_unknown = 1},
}
for index, overrides in ipairs(failures) do
	local success = pcall(loadConfig, overrides)
	assert(not success, "Invalid config accepted at case " .. index)
end
assert(loadConfig({LongChoiceWeight = 0}).Settings.LongChoiceWeight == 0)
assert(loadConfig({ShortChoiceWeight = 0}).Settings.ShortChoiceWeight == 0)
assert(loadConfig({SeaChoiceWeight_near = 0}).SeaChoiceWeights.near == 0)
print("TRAVEL_CONFIG_OK: baseline, 18 invalid boundaries rejected, 3 legal zero exclusions accepted")
