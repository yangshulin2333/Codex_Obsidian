-- Compact targeted Explorer exporter for legacy Roblox project audits.
-- Paste this file into Roblox Studio Command Bar while the project is open.
-- Save the printed output as Project_Analysis_Package/Audit_TargetExplorer_Compact_Output.md.

local TARGET_PATHS = {
	"ReplicatedStorage/Resource/Stage/stage1/teleport",
	"ReplicatedStorage/Resource/Stage/stage1/bossArea",
	"ReplicatedStorage/Resource/pfb",
	"ReplicatedStorage/Resource/ui",
	"ReplicatedStorage/Resource/ui/BagGui",
	"ReplicatedStorage/Resource/ui/HudGui",
	"ReplicatedStorage/Resource/ui/TipsGui",
	"ReplicatedStorage/Resource/ui/LoadingGui",
	"ReplicatedStorage/Resource/ui/IndexGui",
	"ReplicatedStorage/Resource/ui/TeleportGui",
	"ReplicatedStorage/Resource/Potion",
	"ReplicatedStorage/Resource/Potion/1",
	"ReplicatedStorage/Resource/Potion/2",
}

local MAX_DIRECT_CHILDREN = 120
local MAX_KEY_ROWS_PER_TARGET = 55

local IMPORTANT_CLASSES = {
	Attachment = true,
	Beam = true,
	BillboardGui = true,
	ClickDetector = true,
	Frame = true,
	ImageButton = true,
	ImageLabel = true,
	MeshPart = true,
	Model = true,
	ParticleEmitter = true,
	ProximityPrompt = true,
	ScrollingFrame = true,
	Sound = true,
	SpecialMesh = true,
	SurfaceGui = true,
	TextButton = true,
	TextLabel = true,
	Texture = true,
	Trail = true,
	ViewportFrame = true,
}

local out = {}

local function add(s)
	table.insert(out, s or "")
end

local function esc(v)
	return tostring(v or ""):gsub("\r", "\\r"):gsub("\n", "\\n"):gsub("|", "\\|")
end

local function row(values)
	for i, v in ipairs(values) do
		values[i] = esc(v)
	end
	add("| " .. table.concat(values, " | ") .. " |")
end

local function splitPath(path)
	local parts = {}
	for part in tostring(path):gmatch("[^/]+") do
		table.insert(parts, part)
	end
	return parts
end

local function pathOf(inst)
	local parts = {}
	while inst and inst ~= game do
		table.insert(parts, 1, inst.Name)
		inst = inst.Parent
	end
	return table.concat(parts, "/")
end

local function relativePath(root, inst)
	local parts = {}
	while inst and inst ~= root do
		table.insert(parts, 1, inst.Name)
		inst = inst.Parent
	end
	return table.concat(parts, "/")
end

local function resolvePath(path)
	local parts = splitPath(path)
	if #parts == 0 then
		return nil
	end

	local ok, current = pcall(function()
		return game:GetService(parts[1])
	end)
	if not ok or not current then
		return nil
	end

	for i = 2, #parts do
		current = current:FindFirstChild(parts[i])
		if not current then
			return nil
		end
	end

	return current
end

local function sortedChildren(inst)
	local children = inst:GetChildren()
	table.sort(children, function(a, b)
		if a.ClassName == b.ClassName then
			return a.Name < b.Name
		end
		return a.ClassName < b.ClassName
	end)
	return children
end

local function prop(inst, name)
	local ok, value = pcall(function()
		return inst[name]
	end)
	if ok then
		return value
	end
	return nil
end

local function fmtVector3(v)
	if typeof(v) ~= "Vector3" then
		return tostring(v)
	end
	return string.format("%.2f,%.2f,%.2f", v.X, v.Y, v.Z)
end

local function fmtColor3(v)
	if typeof(v) ~= "Color3" then
		return tostring(v)
	end
	return string.format("%.2f,%.2f,%.2f", v.R, v.G, v.B)
end

local function addKey(parts, key, value)
	if value == nil then
		return
	end
	if typeof(value) == "Vector3" then
		value = fmtVector3(value)
	elseif typeof(value) == "Color3" then
		value = fmtColor3(value)
	else
		value = tostring(value)
	end
	if value ~= "" then
		table.insert(parts, key .. "=" .. value)
	end
end

local function keyProps(inst)
	local parts = {}

	if inst:IsA("BasePart") then
		addKey(parts, "Size", prop(inst, "Size"))
		addKey(parts, "Pos", prop(inst, "Position"))
		addKey(parts, "Anchored", prop(inst, "Anchored"))
		addKey(parts, "CanCollide", prop(inst, "CanCollide"))
		addKey(parts, "Transparency", prop(inst, "Transparency"))
	end

	if inst:IsA("MeshPart") then
		addKey(parts, "MeshId", prop(inst, "MeshId"))
		addKey(parts, "TextureID", prop(inst, "TextureID"))
	end

	if inst:IsA("SpecialMesh") then
		addKey(parts, "MeshId", prop(inst, "MeshId"))
		addKey(parts, "TextureId", prop(inst, "TextureId"))
		addKey(parts, "Scale", prop(inst, "Scale"))
	end

	if inst:IsA("Decal") or inst:IsA("Texture") then
		addKey(parts, "Texture", prop(inst, "Texture"))
	end

	if inst:IsA("ParticleEmitter") then
		addKey(parts, "Texture", prop(inst, "Texture"))
		addKey(parts, "Rate", prop(inst, "Rate"))
		addKey(parts, "Enabled", prop(inst, "Enabled"))
		addKey(parts, "Lifetime", prop(inst, "Lifetime"))
		addKey(parts, "Speed", prop(inst, "Speed"))
	end

	if inst:IsA("Beam") or inst:IsA("Trail") then
		addKey(parts, "Texture", prop(inst, "Texture"))
		addKey(parts, "Enabled", prop(inst, "Enabled"))
	end

	if inst:IsA("ImageLabel") or inst:IsA("ImageButton") then
		addKey(parts, "Image", prop(inst, "Image"))
		addKey(parts, "Visible", prop(inst, "Visible"))
		addKey(parts, "Size", prop(inst, "Size"))
	end

	if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
		addKey(parts, "Text", prop(inst, "Text"))
		addKey(parts, "Visible", prop(inst, "Visible"))
		addKey(parts, "Size", prop(inst, "Size"))
	end

	if inst:IsA("ProximityPrompt") then
		addKey(parts, "ActionText", prop(inst, "ActionText"))
		addKey(parts, "ObjectText", prop(inst, "ObjectText"))
		addKey(parts, "MaxActivationDistance", prop(inst, "MaxActivationDistance"))
	end

	if inst:IsA("ClickDetector") then
		addKey(parts, "MaxActivationDistance", prop(inst, "MaxActivationDistance"))
	end

	if inst:IsA("Sound") then
		addKey(parts, "SoundId", prop(inst, "SoundId"))
		addKey(parts, "Volume", prop(inst, "Volume"))
		addKey(parts, "Looped", prop(inst, "Looped"))
	end

	return table.concat(parts, "; ")
end

local function classCounts(root)
	local counts = {}
	for _, inst in ipairs(root:GetDescendants()) do
		counts[inst.ClassName] = (counts[inst.ClassName] or 0) + 1
	end

	local rows = {}
	for className, count in pairs(counts) do
		table.insert(rows, { className = className, count = count })
	end
	table.sort(rows, function(a, b)
		if a.count == b.count then
			return a.className < b.className
		end
		return a.count > b.count
	end)

	return rows
end

local function isImportant(inst)
	if IMPORTANT_CLASSES[inst.ClassName] then
		return true
	end
	if inst:IsA("BasePart") then
		return #inst:GetChildren() > 0
	end
	return false
end

add("# Roblox Target Explorer Compact Export")
add("")
add("## Project Context")
add("")
add("| Field | Value |")
add("|---|---|")
row({ "GameId", game.GameId })
row({ "PlaceId", game.PlaceId })
row({ "CreatorId", game.CreatorId })
row({ "CreatorType", game.CreatorType })
row({ "TargetCount", #TARGET_PATHS })
row({ "MaxDirectChildren", MAX_DIRECT_CHILDREN })
row({ "MaxKeyRowsPerTarget", MAX_KEY_ROWS_PER_TARGET })
add("")

add("## Target Summary")
add("")
add("| Status | TargetPath | ClassName | DirectChildren | Descendants | KeyProps |")
add("|---|---|---|---:|---:|---|")

local targets = {}
for _, targetPath in ipairs(TARGET_PATHS) do
	local inst = resolvePath(targetPath)
	if not inst then
		row({ "Missing", targetPath, "", "", "", "" })
	else
		row({ "Found", targetPath, inst.ClassName, #inst:GetChildren(), #inst:GetDescendants(), keyProps(inst) })
		table.insert(targets, { path = targetPath, inst = inst })
	end
end

for _, target in ipairs(targets) do
	add("")
	add("## Target: " .. target.path)
	add("")
	add("### Direct Children")
	add("")
	add("| Name | ClassName | Children | Descendants | KeyProps |")
	add("|---|---|---:|---:|---|")
	local children = sortedChildren(target.inst)
	for i, child in ipairs(children) do
		if i > MAX_DIRECT_CHILDREN then
			row({ "...", "MoreChildren", #children - MAX_DIRECT_CHILDREN, "", "" })
			break
		end
		row({ child.Name, child.ClassName, #child:GetChildren(), #child:GetDescendants(), keyProps(child) })
	end

	add("")
	add("### Descendant Class Counts")
	add("")
	add("| ClassName | Count |")
	add("|---|---:|")
	for _, item in ipairs(classCounts(target.inst)) do
		row({ item.className, item.count })
	end

	add("")
	add("### Key Descendants")
	add("")
	add("| RelPath | ClassName | Children | KeyProps |")
	add("|---|---|---:|---|")
	local printed = 0
	for _, inst in ipairs(target.inst:GetDescendants()) do
		if isImportant(inst) then
			printed += 1
			if printed > MAX_KEY_ROWS_PER_TARGET then
				row({ "...", "MoreKeyDescendants", "", "truncated" })
				break
			end
			row({ relativePath(target.inst, inst), inst.ClassName, #inst:GetChildren(), keyProps(inst) })
		end
	end
end

add("")
add("## End")

print(table.concat(out, "\n"))
