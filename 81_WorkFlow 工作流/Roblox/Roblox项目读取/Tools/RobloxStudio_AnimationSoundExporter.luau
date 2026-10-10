-- Generic animation/sound exporter.
-- Paste into Roblox Studio Command Bar while your own project is open.
-- It scans project services only and prints Animation/Sound object paths and IDs.

local SERVICE_NAMES = {
	"Workspace",
	"ReplicatedStorage",
	"ServerScriptService",
	"ServerStorage",
	"StarterGui",
	"StarterPlayer",
	"StarterPack",
	"ReplicatedFirst",
	"Lighting",
	"SoundService",
}

local out = {}
local function add(s)
	table.insert(out, s or "")
end
local function esc(v)
	return tostring(v or ""):gsub("\r", "\\r"):gsub("\n", "\\n"):gsub("|", "\\|")
end
local function pathOf(x)
	local t = {}
	while x and x ~= game do
		table.insert(t, 1, x.Name)
		x = x.Parent
	end
	return table.concat(t, "/")
end
local function prop(x, p)
	local ok, v = pcall(function()
		return x[p]
	end)
	if ok and v ~= nil and tostring(v) ~= "" then
		return tostring(v)
	end
	return ""
end
local function assetIdOf(value)
	local text = tostring(value or "")
	return text:match("rbxassetid://(%d+)") or text:match("asset%?id=(%d+)") or text:match("id=(%d+)") or ""
end
local function row(values)
	for i, v in ipairs(values) do
		values[i] = esc(v)
	end
	add("| " .. table.concat(values, " | ") .. " |")
end

local roots = {}
for _, serviceName in ipairs(SERVICE_NAMES) do
	local ok, service = pcall(function()
		return game:GetService(serviceName)
	end)
	if ok and service then
		table.insert(roots, service)
	end
end

local items = {}
for _, root in ipairs(roots) do
	for _, child in ipairs(root:GetDescendants()) do
		if child:IsA("Animation") or child:IsA("Sound") then
			table.insert(items, child)
		end
	end
end
table.sort(items, function(a, b)
	return pathOf(a) < pathOf(b)
end)

add("# Roblox Animation Sound Export")
add("")
add("## Project Context")
add("")
add("| Field | Value |")
add("|---|---|")
row({ "GameId", game.GameId })
row({ "PlaceId", game.PlaceId })
row({ "CreatorId", game.CreatorId })
row({ "CreatorType", game.CreatorType })
row({ "ScannedServices", table.concat(SERVICE_NAMES, ", ") })
row({ "AnimationOrSoundCount", #items })
add("")

add("## Animation And Sound References")
add("")
add("| Type | Name | Path | Property | Value | AssetId |")
add("|---|---|---|---|---|---:|")
for _, item in ipairs(items) do
	local propertyName = item:IsA("Animation") and "AnimationId" or "SoundId"
	local value = prop(item, propertyName)
	row({
		item.ClassName,
		item.Name,
		"`" .. pathOf(item) .. "`",
		propertyName,
		"`" .. value .. "`",
		assetIdOf(value),
	})
end
add("")
add("## End")

print(table.concat(out, "\n"))
