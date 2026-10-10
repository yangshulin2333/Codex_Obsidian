-- Read-only Roblox Studio audit exporter.
-- Paste this script into Studio Command Bar while OldProject_V0.0.1.rbxl is open.
-- It prints Markdown to the Output panel. Copy the output into Project_Analysis_Package docs.

local MAX_DEPTH = 6
local MAX_CHILDREN_PER_NODE = 80
local PRINT_SCRIPT_SOURCE = false

local SERVICES = {
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

local lines = {}

local function add(text)
	table.insert(lines, text or "")
end

local function clean(value)
	local text = tostring(value or "")
	text = text:gsub("\r", "\\r"):gsub("\n", "\\n")
	return text
end

local function pathOf(instance)
	local parts = {}
	local current = instance
	while current and current ~= game do
		table.insert(parts, 1, current.Name)
		current = current.Parent
	end
	return table.concat(parts, "/")
end

local function getProperty(instance, propertyName)
	local ok, value = pcall(function()
		return instance[propertyName]
	end)
	if ok and value ~= nil and tostring(value) ~= "" then
		return tostring(value)
	end
	return nil
end

local function sortByName(a, b)
	if a.Name == b.Name then
		return a.ClassName < b.ClassName
	end
	return a.Name < b.Name
end

local function addTree(instance, depth)
	if depth > MAX_DEPTH then
		return
	end

	local prefix = string.rep("  ", depth)
	add(prefix .. "- " .. instance.Name .. " (" .. instance.ClassName .. ")")

	local children = instance:GetChildren()
	table.sort(children, sortByName)

	local limit = math.min(#children, MAX_CHILDREN_PER_NODE)
	for index = 1, limit do
		addTree(children[index], depth + 1)
	end

	if #children > MAX_CHILDREN_PER_NODE then
		add(prefix .. "  - ... truncated " .. tostring(#children - MAX_CHILDREN_PER_NODE) .. " more children")
	end
end

local function scriptKind(instance)
	if instance:IsA("LocalScript") then
		return "LocalScript"
	end
	if instance:IsA("ModuleScript") then
		return "ModuleScript"
	end
	if instance:IsA("Script") then
		return "Script"
	end
	return nil
end

local function assetRowsFor(instance)
	local rows = {}
	local path = pathOf(instance)

	local function append(assetType, propertyName, value)
		if value and value ~= "" then
			table.insert(rows, {
				assetType = assetType,
				className = instance.ClassName,
				path = path,
				propertyName = propertyName,
				value = value,
			})
		end
	end

	if instance:IsA("Animation") then
		append("Animation", "AnimationId", getProperty(instance, "AnimationId"))
	end

	if instance:IsA("Sound") then
		append("Sound", "SoundId", getProperty(instance, "SoundId"))
	end

	if instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
		append("UI Image", "Image", getProperty(instance, "Image"))
	end

	if instance:IsA("Decal") then
		append("Decal", "Texture", getProperty(instance, "Texture"))
	end

	if instance:IsA("Texture") then
		append("Texture", "Texture", getProperty(instance, "Texture"))
	end

	if instance:IsA("ParticleEmitter") then
		append("VFX Particle", "Texture", getProperty(instance, "Texture"))
	end

	if instance:IsA("Beam") then
		append("VFX Beam", "Texture", getProperty(instance, "Texture"))
	end

	if instance:IsA("Trail") then
		append("VFX Trail", "Texture", getProperty(instance, "Texture"))
	end

	if instance:IsA("MeshPart") then
		append("Mesh", "MeshId", getProperty(instance, "MeshId"))
		append("Mesh Texture", "TextureID", getProperty(instance, "TextureID"))
	end

	if instance:IsA("SpecialMesh") then
		append("Mesh", "MeshId", getProperty(instance, "MeshId"))
		append("Mesh Texture", "TextureId", getProperty(instance, "TextureId"))
	end

	if instance:IsA("SurfaceAppearance") then
		append("SurfaceAppearance", "ColorMap", getProperty(instance, "ColorMap"))
		append("SurfaceAppearance", "MetalnessMap", getProperty(instance, "MetalnessMap"))
		append("SurfaceAppearance", "NormalMap", getProperty(instance, "NormalMap"))
		append("SurfaceAppearance", "RoughnessMap", getProperty(instance, "RoughnessMap"))
	end

	if instance:IsA("Shirt") then
		append("Clothing", "ShirtTemplate", getProperty(instance, "ShirtTemplate"))
	end

	if instance:IsA("Pants") then
		append("Clothing", "PantsTemplate", getProperty(instance, "PantsTemplate"))
	end

	if instance:IsA("ShirtGraphic") then
		append("Clothing", "Graphic", getProperty(instance, "Graphic"))
	end

	if instance:IsA("VideoFrame") then
		append("Video", "Video", getProperty(instance, "Video"))
	end

	return rows
end

add("# Roblox Project Audit Export")
add("")
add("Generated from the currently open Roblox Studio place.")
add("")

add("## Explorer Tree")
add("")
add("```text")
for _, serviceName in ipairs(SERVICES) do
	local ok, service = pcall(function()
		return game:GetService(serviceName)
	end)
	if ok and service then
		addTree(service, 0)
	end
end
add("```")
add("")

add("## Scripts")
add("")
add("| Type | Path | Can Read Source | Lines |")
add("|---|---|---:|---:|")

local allDescendants = game:GetDescendants()
table.sort(allDescendants, function(a, b)
	return pathOf(a) < pathOf(b)
end)

local readableSources = {}
for _, instance in ipairs(allDescendants) do
	local kind = scriptKind(instance)
	if kind then
		local canRead = false
		local lineCount = 0
		local sourceText = nil
		local ok, source = pcall(function()
			return instance.Source
		end)
		if ok and type(source) == "string" then
			canRead = true
			sourceText = source
			local _, newlineCount = source:gsub("\n", "\n")
			lineCount = newlineCount + 1
		end
		add(
			"| "
				.. kind
				.. " | `"
				.. clean(pathOf(instance))
				.. "` | "
				.. tostring(canRead)
				.. " | "
				.. tostring(lineCount)
				.. " |"
		)
		if PRINT_SCRIPT_SOURCE and sourceText then
			table.insert(readableSources, {
				kind = kind,
				path = pathOf(instance),
				source = sourceText,
			})
		end
	end
end
add("")

add("## Remotes And Bindables")
add("")
add("| Type | Path |")
add("|---|---|")
for _, instance in ipairs(allDescendants) do
	if
		instance:IsA("RemoteEvent")
		or instance:IsA("RemoteFunction")
		or instance:IsA("UnreliableRemoteEvent")
		or instance:IsA("BindableEvent")
		or instance:IsA("BindableFunction")
	then
		add("| " .. instance.ClassName .. " | `" .. clean(pathOf(instance)) .. "` |")
	end
end
add("")

add("## Asset References")
add("")
add("| Asset Type | Class | Path | Property | Value |")
add("|---|---|---|---|---|")
for _, instance in ipairs(allDescendants) do
	local rows = assetRowsFor(instance)
	for _, row in ipairs(rows) do
		add(
			"| "
				.. clean(row.assetType)
				.. " | "
				.. clean(row.className)
				.. " | `"
				.. clean(row.path)
				.. "` | "
				.. clean(row.propertyName)
				.. " | `"
				.. clean(row.value)
				.. "` |"
		)
	end
end
add("")

if PRINT_SCRIPT_SOURCE then
	add("## Script Sources")
	add("")
	for _, scriptInfo in ipairs(readableSources) do
		add("### " .. scriptInfo.kind .. ": `" .. clean(scriptInfo.path) .. "`")
		add("")
		add("```lua")
		add(scriptInfo.source)
		add("```")
		add("")
	end
end

print(table.concat(lines, "\n"))
