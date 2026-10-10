-- Targeted Explorer exporter for legacy Roblox project audits.
-- Paste this file into Roblox Studio Command Bar while the project is open.
-- Save the printed output as Project_Analysis_Package/Audit_TargetExplorer_Output.md.

local TARGET_PATHS = {
	"ReplicatedStorage/Resource/Stage/stage1",
	"ReplicatedStorage/Resource/Stage/stage1/Gacha",
	"ReplicatedStorage/Resource/Stage/stage1/Upgrade",
	"ReplicatedStorage/Resource/Stage/stage1/gamepass",
	"ReplicatedStorage/Resource/Stage/stage1/Function",
	"ReplicatedStorage/Resource/Stage/stage1/monster",
	"ReplicatedStorage/Resource/Stage/stage1/monsterPos",
	"ReplicatedStorage/Resource/Stage/stage1/spawn",
	"ReplicatedStorage/Resource/skill",
	"ReplicatedStorage/Resource/pfb",
	"ReplicatedStorage/Resource/ui",
	"ReplicatedStorage/Resource/Potion",
}

local MAX_DEPTH = 5
local MAX_TREE_CHILDREN = 45
local MAX_DIRECT_CHILDREN = 120
local MAX_TREE_NODES_PER_TARGET = 420

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
		addKey(parts, "Material", prop(inst, "Material"))
		addKey(parts, "Color", prop(inst, "Color"))
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

	if inst:IsA("SurfaceAppearance") then
		addKey(parts, "ColorMap", prop(inst, "ColorMap"))
		addKey(parts, "NormalMap", prop(inst, "NormalMap"))
		addKey(parts, "RoughnessMap", prop(inst, "RoughnessMap"))
		addKey(parts, "MetalnessMap", prop(inst, "MetalnessMap"))
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

	if inst:IsA("Animation") then
		addKey(parts, "AnimationId", prop(inst, "AnimationId"))
	end

	if inst:IsA("Sound") then
		addKey(parts, "SoundId", prop(inst, "SoundId"))
		addKey(parts, "Volume", prop(inst, "Volume"))
		addKey(parts, "Looped", prop(inst, "Looped"))
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

	if inst:IsA("ValueBase") then
		addKey(parts, "Value", prop(inst, "Value"))
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

local function writeTree(inst, depth, state)
	if state.count >= MAX_TREE_NODES_PER_TARGET then
		if not state.truncated then
			add(string.rep("  ", depth) .. "- ... tree truncated at " .. tostring(MAX_TREE_NODES_PER_TARGET) .. " nodes")
			state.truncated = true
		end
		return
	end

	state.count = state.count + 1
	local details = keyProps(inst)
	local line = string.rep("  ", depth) .. "- " .. inst.Name .. " [" .. inst.ClassName .. "]"
	if details ~= "" then
		line = line .. " {" .. details .. "}"
	end
	add(line)

	if depth >= MAX_DEPTH then
		local childCount = #inst:GetChildren()
		if childCount > 0 then
			add(string.rep("  ", depth + 1) .. "- ... depth limit, children=" .. tostring(childCount))
		end
		return
	end

	local children = sortedChildren(inst)
	for i, child in ipairs(children) do
		if i > MAX_TREE_CHILDREN then
			add(string.rep("  ", depth + 1) .. "- ... " .. tostring(#children - MAX_TREE_CHILDREN) .. " more children")
			break
		end
		writeTree(child, depth + 1, state)
	end
end

add("# Roblox Target Explorer Export")
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
row({ "MaxDepth", MAX_DEPTH })
row({ "MaxTreeChildren", MAX_TREE_CHILDREN })
row({ "MaxTreeNodesPerTarget", MAX_TREE_NODES_PER_TARGET })
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
	add("| Field | Value |")
	add("|---|---|")
	row({ "ClassName", target.inst.ClassName })
	row({ "FullPath", pathOf(target.inst) })
	row({ "DirectChildren", #target.inst:GetChildren() })
	row({ "Descendants", #target.inst:GetDescendants() })
	row({ "KeyProps", keyProps(target.inst) })
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

	add("### Tree")
	add("")
	add("```text")
	writeTree(target.inst, 0, { count = 0, truncated = false })
	add("```")
end

add("")
add("## End")

print(table.concat(out, "\n"))
