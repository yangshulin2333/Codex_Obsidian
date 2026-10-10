-- Generic target source exporter.
-- Paste into Roblox Studio Command Bar while your own project is open.
-- Fill TARGET_PATHS with script paths from the quick audit output when you need full source.

local TARGET_PATHS = {
	-- Example:
	-- "StarterPlayer/StarterPlayerScripts/MainClient",
	-- "ServerScriptService/MainServer",
	-- "ReplicatedStorage/Modules/SomeModule",
}

local SERVICE_NAMES = {
	"Workspace",
	"ReplicatedStorage",
	"ReplicatedFirst",
	"ServerScriptService",
	"ServerStorage",
	"StarterGui",
	"StarterPlayer",
	"StarterPack",
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
local function lineCount(source)
	local count = 0
	for _ in (tostring(source) .. "\n"):gmatch("(.-)\n") do
		count = count + 1
	end
	return count
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

local scriptsByPath = {}
local scriptList = {}
for _, root in ipairs(roots) do
	for _, child in ipairs(root:GetDescendants()) do
		if scriptType(child) then
			local scriptPath = pathOf(child)
			scriptsByPath[scriptPath] = child
			table.insert(scriptList, child)
		end
	end
end
table.sort(scriptList, function(a, b)
	return pathOf(a) < pathOf(b)
end)

add("# Roblox Target Source Export")
add("")
add("## Project Context")
add("")
add("| Field | Value |")
add("|---|---|")
row({ "GameId", game.GameId })
row({ "PlaceId", game.PlaceId })
row({ "CreatorId", game.CreatorId })
row({ "CreatorType", game.CreatorType })
row({ "ScriptCount", #scriptList })
row({ "TargetCount", #TARGET_PATHS })
add("")

if #TARGET_PATHS == 0 then
	add("## No Target Paths Configured")
	add("")
	add(
		"`TARGET_PATHS` is empty. Copy script paths from the table below, paste them into TARGET_PATHS, then run this exporter again."
	)
	add("")
	add("## Available Scripts")
	add("")
	add("| ScriptType | ScriptPath |")
	add("|---|---|")
	for _, scriptObj in ipairs(scriptList) do
		row({ scriptType(scriptObj), pathOf(scriptObj) })
	end
	add("")
	add("## End")
	print(table.concat(out, "\n"))
	return
end

add("## Target Source Summary")
add("")
add("| Status | ScriptType | ScriptPath | Lines | SourceLength |")
add("|---|---|---|---:|---:|")

local foundItems = {}
for _, targetPath in ipairs(TARGET_PATHS) do
	local scriptObj = scriptsByPath[targetPath]
	if not scriptObj then
		row({ "Missing", "", targetPath, "", "" })
	else
		local ok, source = pcall(function()
			return scriptObj.Source
		end)
		if not ok then
			row({ "Unreadable", scriptType(scriptObj), targetPath, "", tostring(source) })
		else
			row({ "Found", scriptType(scriptObj), targetPath, lineCount(source), #source })
			table.insert(foundItems, {
				path = targetPath,
				kind = scriptType(scriptObj),
				source = tostring(source),
			})
		end
	end
end

add("")
add("## Sources")
for _, item in ipairs(foundItems) do
	add("")
	add("### " .. item.path)
	add("")
	add("| Field | Value |")
	add("|---|---|")
	row({ "ScriptType", item.kind })
	row({ "Lines", lineCount(item.source) })
	row({ "SourceLength", #item.source })
	add("")
	add("```luau")
	local lineNumber = 0
	for line in (item.source .. "\n"):gmatch("(.-)\n") do
		lineNumber = lineNumber + 1
		add(string.format("%04d: %s", lineNumber, line))
	end
	add("```")
end

add("")
add("## End")

print(table.concat(out, "\n"))
