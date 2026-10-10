-- Roblox focused GUI snapshot exporter.
-- Paste this file into Roblox Studio Command Bar while the project is open.
-- Save the printed output as Project_Analysis_Package/GuiSnapshots/<name>.md.
--
-- This exporter is intentionally compact. Full ScreenGui exports are easy to
-- trim in Studio Output, so target one page/panel whenever possible.

local HttpService = game:GetService("HttpService")

local TARGET_PATHS = {
	-- Fill this after running RobloxStudio_GuiOverviewExporter.luau.
	-- Examples:
	-- "StarterGui/<ScreenGuiName>/<PageOrPanelName>",
	-- "ReplicatedStorage/Resource/ui/<GuiTemplateName>",
}

local EXPORT_NAME = "Roblox Focused GUI Snapshot"
local MAX_NODES_PER_TARGET = 700
local JSON_CHUNK_SIZE = 12000

local out = {}

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

local function sortedChildren(inst)
	local children = inst:GetChildren()
	table.sort(children, function(a, b)
		local orderA = 0
		local orderB = 0
		pcall(function()
			orderA = a.LayoutOrder
		end)
		pcall(function()
			orderB = b.LayoutOrder
		end)

		if orderA ~= orderB then
			return orderA < orderB
		end
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

local function valueToData(value)
	local kind = typeof(value)

	if kind == "nil" or value == nil then
		return nil
	elseif kind == "boolean" or kind == "number" or kind == "string" then
		return value
	elseif kind == "EnumItem" then
		return value.Name
	elseif kind == "Color3" then
		return {
			r = math.floor(value.R * 255 + 0.5),
			g = math.floor(value.G * 255 + 0.5),
			b = math.floor(value.B * 255 + 0.5),
		}
	elseif kind == "UDim" then
		return {
			scale = value.Scale,
			offset = value.Offset,
		}
	elseif kind == "UDim2" then
		return {
			x = {
				scale = value.X.Scale,
				offset = value.X.Offset,
			},
			y = {
				scale = value.Y.Scale,
				offset = value.Y.Offset,
			},
		}
	elseif kind == "Vector2" then
		return {
			x = value.X,
			y = value.Y,
		}
	elseif kind == "Vector3" then
		return {
			x = value.X,
			y = value.Y,
			z = value.Z,
		}
	elseif kind == "Rect" then
		return {
			min = {
				x = value.Min.X,
				y = value.Min.Y,
			},
			max = {
				x = value.Max.X,
				y = value.Max.Y,
			},
		}
	elseif kind == "NumberSequence" or kind == "ColorSequence" then
		return tostring(value)
	elseif kind == "Font" then
		return tostring(value)
	end

	return tostring(value)
end

local function readProps(inst, propNames)
	local props = {}
	for _, name in ipairs(propNames) do
		local value = prop(inst, name)
		if value ~= nil then
			props[name] = valueToData(value)
		end
	end
	return props
end

local function mergeProps(target, source)
	for key, value in pairs(source) do
		target[key] = value
	end
end

local function commonGuiProps(inst)
	local props = {}

	if inst:IsA("LayerCollector") then
		mergeProps(
			props,
			readProps(inst, {
				"Enabled",
				"DisplayOrder",
				"IgnoreGuiInset",
				"ResetOnSpawn",
				"ZIndexBehavior",
			})
		)
	end

	if inst:IsA("GuiObject") then
		mergeProps(
			props,
			readProps(inst, {
				"Visible",
				"AnchorPoint",
				"Position",
				"Size",
				"AutomaticSize",
				"SizeConstraint",
				"BackgroundColor3",
				"BackgroundTransparency",
				"BorderSizePixel",
				"ClipsDescendants",
				"LayoutOrder",
				"ZIndex",
			})
		)
	end

	return props
end

local function classProps(inst)
	local props = {}

	if inst:IsA("ImageLabel") or inst:IsA("ImageButton") then
		mergeProps(
			props,
			readProps(inst, {
				"Image",
				"ImageColor3",
				"ImageTransparency",
				"ScaleType",
				"SliceCenter",
				"SliceScale",
			})
		)
	end

	if inst:IsA("ImageButton") or inst:IsA("TextButton") then
		mergeProps(
			props,
			readProps(inst, {
				"AutoButtonColor",
				"Modal",
			})
		)
	end

	if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
		mergeProps(
			props,
			readProps(inst, {
				"Text",
				"Font",
				"TextSize",
				"TextScaled",
				"TextWrapped",
				"TextColor3",
				"TextTransparency",
				"TextStrokeColor3",
				"TextStrokeTransparency",
				"TextXAlignment",
				"TextYAlignment",
				"TextTruncate",
				"LineHeight",
				"RichText",
			})
		)
	end

	if inst:IsA("TextBox") then
		mergeProps(
			props,
			readProps(inst, {
				"PlaceholderText",
				"PlaceholderColor3",
				"ClearTextOnFocus",
				"MultiLine",
			})
		)
	end

	if inst:IsA("ScrollingFrame") then
		mergeProps(
			props,
			readProps(inst, {
				"CanvasSize",
				"AutomaticCanvasSize",
				"CanvasPosition",
				"ScrollingDirection",
				"ScrollingEnabled",
				"ScrollBarThickness",
				"VerticalScrollBarInset",
			})
		)
	end

	if inst:IsA("UIStroke") then
		mergeProps(
			props,
			readProps(inst, {
				"Color",
				"Transparency",
				"Thickness",
				"ApplyStrokeMode",
				"LineJoinMode",
				"Enabled",
			})
		)
	end

	if inst:IsA("UICorner") then
		mergeProps(props, readProps(inst, { "CornerRadius" }))
	end

	if inst:IsA("UIAspectRatioConstraint") then
		mergeProps(
			props,
			readProps(inst, {
				"AspectRatio",
				"AspectType",
				"DominantAxis",
			})
		)
	end

	if inst:IsA("UIScale") then
		mergeProps(props, readProps(inst, { "Scale" }))
	end

	if inst:IsA("UISizeConstraint") then
		mergeProps(props, readProps(inst, { "MaxSize", "MinSize" }))
	end

	if inst:IsA("UITextSizeConstraint") then
		mergeProps(props, readProps(inst, { "MaxTextSize", "MinTextSize" }))
	end

	if inst:IsA("UIPadding") then
		mergeProps(
			props,
			readProps(inst, {
				"PaddingTop",
				"PaddingBottom",
				"PaddingLeft",
				"PaddingRight",
			})
		)
	end

	if inst:IsA("UIListLayout") then
		mergeProps(
			props,
			readProps(inst, {
				"FillDirection",
				"HorizontalAlignment",
				"VerticalAlignment",
				"SortOrder",
				"Padding",
			})
		)
	end

	if inst:IsA("UIGridLayout") then
		mergeProps(
			props,
			readProps(inst, {
				"CellPadding",
				"CellSize",
				"FillDirection",
				"FillDirectionMaxCells",
				"HorizontalAlignment",
				"VerticalAlignment",
				"SortOrder",
				"StartCorner",
			})
		)
	end

	if inst:IsA("UIGradient") then
		mergeProps(
			props,
			readProps(inst, {
				"Color",
				"Enabled",
				"Offset",
				"Rotation",
				"Transparency",
			})
		)
	end

	return props
end

local function attributesToData(inst)
	local data = {}
	for key, value in pairs(inst:GetAttributes()) do
		data[key] = valueToData(value)
	end
	return data
end

local function nodeFor(inst)
	local props = commonGuiProps(inst)
	mergeProps(props, classProps(inst))

	return {
		path = pathOf(inst),
		name = inst.Name,
		className = inst.ClassName,
		attributes = attributesToData(inst),
		props = props,
	}
end

local function addTreeLine(inst, depth)
	local indent = string.rep("  ", depth)
	local visible = prop(inst, "Visible")
	local text = prop(inst, "Text")
	local image = prop(inst, "Image")
	local extra = {}

	if visible ~= nil then
		table.insert(extra, "Visible=" .. tostring(visible))
	end
	if text ~= nil and text ~= "" then
		table.insert(extra, "Text=" .. tostring(text))
	end
	if image ~= nil and image ~= "" then
		table.insert(extra, "Image=" .. tostring(image))
	end

	local suffix = ""
	if #extra > 0 then
		suffix = " " .. table.concat(extra, "; ")
	end
	add(indent .. "- " .. inst.Name .. " [" .. inst.ClassName .. "]" .. suffix)
end

local function walk(inst, depth, nodes, treeLines, state)
	if state.count >= MAX_NODES_PER_TARGET then
		state.trimmed = true
		return
	end

	state.count = state.count + 1
	table.insert(nodes, nodeFor(inst))
	table.insert(treeLines, {
		inst = inst,
		depth = depth,
	})

	for _, child in ipairs(sortedChildren(inst)) do
		walk(child, depth + 1, nodes, treeLines, state)
		if state.trimmed then
			return
		end
	end
end

local allNodes = {}
local treeLines = {}
local missingTargets = {}
local trimmedTargets = {}

if #TARGET_PATHS > 0 then
	for _, targetPath in ipairs(TARGET_PATHS) do
		local root = resolvePath(targetPath)
		if not root then
			table.insert(missingTargets, targetPath)
		else
			local state = {
				count = 0,
				trimmed = false,
			}
			walk(root, 0, allNodes, treeLines, state)
			if state.trimmed then
				table.insert(trimmedTargets, targetPath)
			end
		end
	end
end

add("# " .. EXPORT_NAME)
add("")
add("ExportedAt: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"))
add("NodeCount: " .. tostring(#allNodes))
add("OutputStatus: COMPLETE only if END_ROBLOX_GUI_SNAPSHOT_JSON is present")
add("")

add("## Target Paths")
if #TARGET_PATHS == 0 then
	add("- none")
	add("")
	add("## Need Target Paths")
	add("- Run Tools/RobloxStudio_GuiOverviewExporter.luau first.")
	add("- Copy one candidate GUI path into TARGET_PATHS.")
	add("- Then run this focused exporter again.")
else
	for _, targetPath in ipairs(TARGET_PATHS) do
		add("- " .. targetPath)
	end
end
add("")

if #missingTargets > 0 then
	add("## Missing Targets")
	for _, targetPath in ipairs(missingTargets) do
		add("- " .. targetPath)
	end
	add("")
end

if #trimmedTargets > 0 then
	add("## Trimmed Targets")
	for _, targetPath in ipairs(trimmedTargets) do
		add("- " .. targetPath .. " exceeded MAX_NODES_PER_TARGET; export a smaller subtree.")
	end
	add("")
end

add("## Tree")
for _, item in ipairs(treeLines) do
	addTreeLine(item.inst, item.depth)
end
add("")

local data = {
	exportName = EXPORT_NAME,
	exportedAt = os.date("!%Y-%m-%dT%H:%M:%SZ"),
	targetPaths = TARGET_PATHS,
	nodeCount = #allNodes,
	missingTargets = missingTargets,
	trimmedTargets = trimmedTargets,
	nodes = allNodes,
}

local json = HttpService:JSONEncode(data)

add("## BEGIN_ROBLOX_GUI_SNAPSHOT_JSON")
for i = 1, #json, JSON_CHUNK_SIZE do
	add(string.sub(json, i, i + JSON_CHUNK_SIZE - 1))
end
add("## END_ROBLOX_GUI_SNAPSHOT_JSON")
add("")
add("## Notes")
add("- If Studio Output still ends with [trimmed], export a smaller subtree.")
add("- This exporter is generic. Project-specific paths must be supplied in TARGET_PATHS.")

print(table.concat(out, "\n"))
