-- Generic project-only asset exporter.
-- Paste into Roblox Studio Command Bar while your own project is open.
-- It scans only project services and excludes PluginGuiService/CoreGui/plugin UI.

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
	return nil
end
local function row(values)
	for i, v in ipairs(values) do
		values[i] = esc(v)
	end
	add("| " .. table.concat(values, " | ") .. " |")
end
local function addAsset(x, typ, propertyName)
	local v = prop(x, propertyName)
	if v then
		row({ typ, x.ClassName, "`" .. pathOf(x) .. "`", propertyName, "`" .. v .. "`" })
	end
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

local descendants = {}
for _, root in ipairs(roots) do
	table.insert(descendants, root)
	for _, child in ipairs(root:GetDescendants()) do
		table.insert(descendants, child)
	end
end

table.sort(descendants, function(a, b)
	return pathOf(a) < pathOf(b)
end)

add("# Roblox Project-Only Asset Export")
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
add("")

add("## Asset References")
add("")
add("| Asset Type | Class | Path | Property | Value |")
add("|---|---|---|---|---|")
for _, x in ipairs(descendants) do
	if x:IsA("Animation") then
		addAsset(x, "Animation", "AnimationId")
	end
	if x:IsA("Sound") then
		addAsset(x, "Sound", "SoundId")
	end
	if x:IsA("ImageLabel") or x:IsA("ImageButton") then
		addAsset(x, "UI Image", "Image")
	end
	if x:IsA("Decal") then
		addAsset(x, "Decal", "Texture")
	end
	if x:IsA("Texture") then
		addAsset(x, "Texture", "Texture")
	end
	if x:IsA("ParticleEmitter") then
		addAsset(x, "VFX Particle", "Texture")
	end
	if x:IsA("Beam") then
		addAsset(x, "VFX Beam", "Texture")
	end
	if x:IsA("Trail") then
		addAsset(x, "VFX Trail", "Texture")
	end
	if x:IsA("MeshPart") then
		addAsset(x, "Mesh", "MeshId")
		addAsset(x, "Mesh Texture", "TextureID")
	end
	if x:IsA("SpecialMesh") then
		addAsset(x, "Mesh", "MeshId")
		addAsset(x, "Mesh Texture", "TextureId")
	end
	if x:IsA("SurfaceAppearance") then
		addAsset(x, "SurfaceAppearance", "ColorMap")
		addAsset(x, "SurfaceAppearance", "MetalnessMap")
		addAsset(x, "SurfaceAppearance", "NormalMap")
		addAsset(x, "SurfaceAppearance", "RoughnessMap")
	end
	if x:IsA("Shirt") then
		addAsset(x, "Clothing", "ShirtTemplate")
	end
	if x:IsA("Pants") then
		addAsset(x, "Clothing", "PantsTemplate")
	end
	if x:IsA("ShirtGraphic") then
		addAsset(x, "Clothing", "Graphic")
	end
	if x:IsA("VideoFrame") then
		addAsset(x, "Video", "Video")
	end
end
add("")
add("## End")

print(table.concat(out, "\n"))
