-- Quick focused audit exporter.
-- Paste the whole file into Roblox Studio Command Bar, then press Enter.
-- Copy the Studio Output after running and save it as a markdown file.

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
local function addAsset(x, typ, propertyName)
	local v = prop(x, propertyName)
	if v then
		row({ typ, x.ClassName, "`" .. pathOf(x) .. "`", propertyName, "`" .. v .. "`" })
	end
end

local descendants = game:GetDescendants()
table.sort(descendants, function(a, b)
	return pathOf(a) < pathOf(b)
end)

add("# Roblox Quick Focused Audit Export")
add("")
add("## Project Context")
add("")
add("| Field | Value |")
add("|---|---|")
row({ "GameId", game.GameId })
row({ "PlaceId", game.PlaceId })
row({ "CreatorId", game.CreatorId })
row({ "CreatorType", game.CreatorType })
add("")

add("## Scripts")
add("")
add("| Type | Path |")
add("|---|---|")
for _, x in ipairs(descendants) do
	local kind = scriptType(x)
	if kind then
		row({ kind, "`" .. pathOf(x) .. "`" })
	end
end
add("")

add("## Remotes And Bindables")
add("")
add("| Type | Path |")
add("|---|---|")
for _, x in ipairs(descendants) do
	if
		x:IsA("RemoteEvent")
		or x:IsA("RemoteFunction")
		or x:IsA("UnreliableRemoteEvent")
		or x:IsA("BindableEvent")
		or x:IsA("BindableFunction")
	then
		row({ x.ClassName, "`" .. pathOf(x) .. "`" })
	end
end
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
	if x:IsA("Decal") or x:IsA("Texture") or x:IsA("ParticleEmitter") or x:IsA("Beam") or x:IsA("Trail") then
		addAsset(x, x.ClassName, "Texture")
	end
	if x:IsA("MeshPart") then
		addAsset(x, "Mesh", "MeshId")
		addAsset(x, "Mesh Texture", "TextureID")
	end
	if x:IsA("SpecialMesh") then
		addAsset(x, "Mesh", "MeshId")
		addAsset(x, "Mesh Texture", "TextureId")
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
end
add("")
add("## End")

print(table.concat(out, "\n"))
