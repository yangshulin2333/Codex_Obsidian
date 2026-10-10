-- Roblox GUI overview exporter.
-- Use this first when taking over an unknown project.
-- Paste into Roblox Studio Command Bar and save the Output as a markdown file.

local SEARCH_ROOTS = {
	"StarterGui",
	"ReplicatedStorage/Resource/ui",
	"ReplicatedStorage/Resource",
	"ReplicatedStorage/ui",
}

local MAX_CANDIDATES = 60
local MAX_TREE_DEPTH = 4
local MAX_CHILDREN_PER_NODE = 24

local GUI_CLASSES = {
	BillboardGui = true,
	Frame = true,
	ImageButton = true,
	ImageLabel = true,
	ScreenGui = true,
	ScrollingFrame = true,
	SurfaceGui = true,
	TextBox = true,
	TextButton = true,
	TextLabel = true,
	ViewportFrame = true,
}

local out = {}
local classCounts = {}

local function add(line)
	table.insert(out, line or "")
end

local function splitPath(path)
	local parts = {}
	for part in tostring(path):gmatch("[^/]+") do
		table.insert(parts, part)
	end
	return parts
end

local function resolvePath(path)
	local parts = splitPath(path)
	if #parts == 0 then
		return nil
	end

	if parts[1] == "game" then
		table.remove(parts, 1)
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

local function pathOf(inst)
	local parts = {}
	while inst and inst ~= game do
		table.insert(parts, 1, inst.Name)
		inst = inst.Parent
	end
	return table.concat(parts, "/")
end

local function isGui(inst)
	return GUI_CLASSES[inst.ClassName] == true
end

local function isGuiRoot(inst, searchRoot)
	if inst:IsA("LayerCollector") then
		return true
	end

	if not inst:IsA("GuiObject") then
		return false
	end

	local parent = inst.Parent
	while parent and parent ~= searchRoot do
		if parent:IsA("GuiObject") or parent:IsA("LayerCollector") then
			return false
		end
		parent = parent.Parent
	end

	return true
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

local function smallProps(inst)
	local props = {}
	local okVisible, visible = pcall(function()
		return inst.Visible
	end)
	local okText, text = pcall(function()
		return inst.Text
	end)
	local okImage, image = pcall(function()
		return inst.Image
	end)

	if okVisible then
		table.insert(props, "Visible=" .. tostring(visible))
	end
	if okText and text ~= "" then
		table.insert(props, "Text=" .. tostring(text))
	end
	if okImage and image ~= "" then
		table.insert(props, "Image=" .. tostring(image))
	end

	if #props == 0 then
		return ""
	end
	return " " .. table.concat(props, "; ")
end

local function addTree(inst, depth)
	add(string.rep("  ", depth) .. "- " .. inst.Name .. " [" .. inst.ClassName .. "]" .. smallProps(inst))

	if depth >= MAX_TREE_DEPTH then
		return
	end

	local shown = 0
	local children = sortedChildren(inst)
	for _, child in ipairs(children) do
		if
			isGui(child)
			or child:IsA("UIConstraint")
			or child:IsA("UILayout")
			or child:IsA("UIStroke")
			or child:IsA("UICorner")
			or child:IsA("UIGradient")
		then
			shown = shown + 1
			if shown > MAX_CHILDREN_PER_NODE then
				add(string.rep("  ", depth + 1) .. "- ... more children")
				return
			end
			addTree(child, depth + 1)
		end
	end
end

local foundRoots = {}
local missingRoots = {}
local seenGuiPaths = {}
local seenRootPaths = {}

for _, rootPath in ipairs(SEARCH_ROOTS) do
	local root = resolvePath(rootPath)
	if not root then
		table.insert(missingRoots, rootPath)
	else
		for _, inst in ipairs(root:GetDescendants()) do
			if isGui(inst) then
				local instPath = pathOf(inst)
				if not seenGuiPaths[instPath] then
					seenGuiPaths[instPath] = true
					classCounts[inst.ClassName] = (classCounts[inst.ClassName] or 0) + 1
				end
				if isGuiRoot(inst, root) and not seenRootPaths[instPath] then
					seenRootPaths[instPath] = true
					table.insert(foundRoots, inst)
					if #foundRoots >= MAX_CANDIDATES then
						break
					end
				end
			end
		end
	end
	if #foundRoots >= MAX_CANDIDATES then
		break
	end
end

table.sort(foundRoots, function(a, b)
	return pathOf(a) < pathOf(b)
end)

add("# Roblox GUI Overview")
add("")
add("ExportedAt: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"))
add("Purpose: first pass only; run focused snapshot exporter after choosing a target path.")
add("")

add("## Search Roots")
for _, rootPath in ipairs(SEARCH_ROOTS) do
	add("- " .. rootPath)
end
add("")

if #missingRoots > 0 then
	add("## Missing Search Roots")
	for _, rootPath in ipairs(missingRoots) do
		add("- " .. rootPath)
	end
	add("")
end

add("## Candidate GUI Roots")
if #foundRoots == 0 then
	add("- none")
else
	for _, inst in ipairs(foundRoots) do
		add("- " .. pathOf(inst) .. " [" .. inst.ClassName .. "]")
	end
end
add("")

add("## Class Counts")
local classNames = {}
for className in pairs(classCounts) do
	table.insert(classNames, className)
end
table.sort(classNames)
for _, className in ipairs(classNames) do
	add("- " .. className .. ": " .. tostring(classCounts[className]))
end
if #classNames == 0 then
	add("- none")
end
add("")

add("## Compact Tree")
for _, inst in ipairs(foundRoots) do
	add("- ROOT " .. pathOf(inst) .. " [" .. inst.ClassName .. "]")
	addTree(inst, 1)
end
add("")
add("## END_ROBLOX_GUI_OVERVIEW")

print(table.concat(out, "\n"))
