-- Generic source asset search exporter.
-- Paste into Roblox Studio Command Bar while your own project is open.
-- It scans Script/LocalScript/ModuleScript source for asset IDs and asset-loading keywords.

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

local KEYWORDS = {
	"rbxassetid://",
	"asset/?id=",
	"asset?id=",
	"assetdelivery.roblox.com",
	"AnimationId",
	"SoundId",
	"MeshId",
	"TextureID",
	"TextureId",
	"Image",
	"LoadAnimation",
	'Instance.new("Animation")',
	"Instance.new('Animation')",
	'Instance.new("Sound")',
	"Instance.new('Sound')",
	'Instance.new("ParticleEmitter")',
	"Instance.new('ParticleEmitter')",
	"MarketplaceService",
	"InsertService",
}

local MAX_ASSET_ROWS = 400
local MAX_KEYWORD_ROWS = 220
local MAX_KEYWORD_ROWS_PER_SCRIPT = 10
local MAX_SUMMARY_ROWS = 180
local MAX_SNIPPET_LEN = 180

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
local function row(values)
	for i, v in ipairs(values) do
		values[i] = esc(v)
	end
	add("| " .. table.concat(values, " | ") .. " |")
end
local function scriptType(x)
	if x:IsA("LocalScript") then
		return "LocalScript"
	elseif x:IsA("ModuleScript") then
		return "ModuleScript"
	elseif x:IsA("Script") then
		return "Script"
	end
	return nil
end
local function snippet(line)
	line = tostring(line or ""):gsub("^%s+", ""):gsub("%s+$", "")
	if #line > MAX_SNIPPET_LEN then
		return line:sub(1, MAX_SNIPPET_LEN) .. "..."
	end
	return line
end
local function collectAssetIds(line)
	local ids = {}
	local seen = {}
	local function addId(id)
		if id and id ~= "" and not seen[id] then
			seen[id] = true
			table.insert(ids, id)
		end
	end
	for id in tostring(line):gmatch("rbxassetid://(%d+)") do
		addId(id)
	end
	for id in tostring(line):gmatch("asset%?id=(%d+)") do
		addId(id)
	end
	for id in tostring(line):gmatch("[Ii][Dd]=(%d+)") do
		addId(id)
	end
	return ids
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

local scripts = {}
for _, root in ipairs(roots) do
	for _, child in ipairs(root:GetDescendants()) do
		local kind = scriptType(child)
		if kind then
			table.insert(scripts, child)
		end
	end
end
table.sort(scripts, function(a, b)
	return pathOf(a) < pathOf(b)
end)

local assetRows = {}
local keywordRows = {}
local summaryRows = {}
local unreadableRows = {}

for _, scriptObj in ipairs(scripts) do
	local ok, source = pcall(function()
		return scriptObj.Source
	end)
	local scriptPath = pathOf(scriptObj)
	local kind = scriptType(scriptObj)
	if not ok then
		table.insert(unreadableRows, { kind, scriptPath, tostring(source) })
	else
		local assetHitCount = 0
		local keywordCount = 0
		local keywordAddedForThisScript = 0
		local lineNumber = 0
		for line in (tostring(source) .. "\n"):gmatch("(.-)\n") do
			lineNumber = lineNumber + 1
			local lowerLine = line:lower()

			for _, assetId in ipairs(collectAssetIds(line)) do
				assetHitCount = assetHitCount + 1
				if #assetRows < MAX_ASSET_ROWS then
					table.insert(assetRows, { assetId, kind, scriptPath, lineNumber, snippet(line) })
				end
			end

			for _, keyword in ipairs(KEYWORDS) do
				if lowerLine:find(keyword:lower(), 1, true) then
					keywordCount = keywordCount + 1
					if #keywordRows < MAX_KEYWORD_ROWS and keywordAddedForThisScript < MAX_KEYWORD_ROWS_PER_SCRIPT then
						table.insert(keywordRows, { keyword, kind, scriptPath, lineNumber, snippet(line) })
						keywordAddedForThisScript = keywordAddedForThisScript + 1
					end
					break
				end
			end
		end

		if assetHitCount > 0 or keywordCount > 0 then
			table.insert(summaryRows, { kind, scriptPath, assetHitCount, keywordCount })
		end
	end
end

table.sort(summaryRows, function(a, b)
	if a[3] ~= b[3] then
		return a[3] > b[3]
	end
	if a[4] ~= b[4] then
		return a[4] > b[4]
	end
	return a[2] < b[2]
end)

add("# Roblox Source Asset Search Export")
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
row({ "ScriptCount", #scripts })
row({ "AssetRowsPrinted", #assetRows })
row({ "KeywordRowsPrinted", #keywordRows })
row({ "CandidateScriptCount", #summaryRows })
row({ "CandidateRowsPrinted", math.min(#summaryRows, MAX_SUMMARY_ROWS) })
add("")

add("## AssetId Matches")
add("")
add("| AssetId | ScriptType | ScriptPath | Line | Snippet |")
add("|---:|---|---|---:|---|")
for _, r in ipairs(assetRows) do
	row(r)
end
add("")

add("## Candidate Scripts Summary")
add("")
add("| ScriptType | ScriptPath | AssetIdHits | KeywordHits |")
add("|---|---|---:|---:|")
for i, r in ipairs(summaryRows) do
	if i > MAX_SUMMARY_ROWS then
		break
	end
	row(r)
end
add("")

add("## Keyword Matches")
add("")
add("| Keyword | ScriptType | ScriptPath | Line | Snippet |")
add("|---|---|---|---:|---|")
for _, r in ipairs(keywordRows) do
	row(r)
end
add("")

add("## Unreadable Scripts")
add("")
add("| ScriptType | ScriptPath | Error |")
add("|---|---|---|")
for _, r in ipairs(unreadableRows) do
	row(r)
end
add("")
add("## End")

print(table.concat(out, "\n"))
