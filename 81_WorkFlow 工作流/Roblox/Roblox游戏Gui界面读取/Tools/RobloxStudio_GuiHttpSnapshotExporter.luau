-- Roblox generic GUI HTTP snapshot exporter.
-- Paste this file into Roblox Studio Command Bar after filling TARGET_JOBS.
--
-- Prerequisite:
-- 1. Enable Studio HTTP Requests.
-- 2. Start the local receiver:
--    python Tools/Receive-GuiSnapshotHttp.py --out-dir "<Project>/Project_Analysis_Package/GuiSnapshots" --name "<GuiName>_Current_Http"
--
-- TARGET_JOBS example:
-- local TARGET_JOBS = {
--     { name = "Root", path = "StarterGui/<ScreenGuiName>", maxDepth = 2 },
--     { name = "PageA", path = "StarterGui/<ScreenGuiName>/<PageName>" },
-- }

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local EXPORT_NAME = "Roblox GUI HTTP Snapshot"
local POST_URL = "http://127.0.0.1:18765/gui-snapshot"
local MAX_NODES_PER_JOB = 1200
local JOB_FILTER = ""
local AUTO_DISCOVER_GUI_ROOTS = true
local AUTO_INCLUDE_STARTERGUI = true
local AUTO_INCLUDE_REPLICATED_RESOURCE_UI = true
local AUTO_INCLUDE_PLAYERGUI = true
local AUTO_MAX_DEPTH = nil

local TARGET_JOBS = {
	-- { name = "Root", path = "StarterGui/<ScreenGuiName>", maxDepth = 2 },
	-- { name = "PageName", path = "StarterGui/<ScreenGuiName>/<PageName>" },
}

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

local function safeSegmentName(path)
	return tostring(path):gsub("[^%w_]+", "_")
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
			x = { scale = value.X.Scale, offset = value.X.Offset },
			y = { scale = value.Y.Scale, offset = value.Y.Offset },
		}
	elseif kind == "Vector2" then
		return { x = value.X, y = value.Y }
	elseif kind == "Vector3" then
		return { x = value.X, y = value.Y, z = value.Z }
	elseif kind == "Rect" then
		return {
			min = { x = value.Min.X, y = value.Min.Y },
			max = { x = value.Max.X, y = value.Max.Y },
		}
	elseif kind == "NumberSequence" or kind == "ColorSequence" or kind == "Font" then
		return tostring(value)
	elseif kind == "Instance" then
		return pathOf(value)
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
				"ScreenInsets",
				"ClipToDeviceSafeArea",
			})
		)
	end

	if inst:IsA("GuiObject") then
		mergeProps(
			props,
			readProps(inst, {
				"Visible",
				"Active",
				"Selectable",
				"Interactable",
				"AnchorPoint",
				"Position",
				"Size",
				"AbsolutePosition",
				"AbsoluteSize",
				"AbsoluteRotation",
				"AutomaticSize",
				"SizeConstraint",
				"BackgroundColor3",
				"BackgroundTransparency",
				"BorderColor3",
				"BorderMode",
				"BorderSizePixel",
				"ClipsDescendants",
				"LayoutOrder",
				"Rotation",
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
				"ImageRectOffset",
				"ImageRectSize",
				"ImageTransparency",
				"ResampleMode",
				"ScaleType",
				"SliceCenter",
				"SliceScale",
				"TileSize",
			})
		)
	end

	if inst:IsA("ImageButton") or inst:IsA("TextButton") then
		mergeProps(props, readProps(inst, { "AutoButtonColor", "Modal", "Selected" }))
	end

	if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
		mergeProps(
			props,
			readProps(inst, {
				"Text",
				"Font",
				"FontFace",
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
				"MaxVisibleGraphemes",
			})
		)
	end

	if inst:IsA("TextBox") then
		mergeProps(props, readProps(inst, { "PlaceholderText", "PlaceholderColor3", "ClearTextOnFocus", "MultiLine" }))
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
				"ScrollBarImageColor3",
				"ScrollBarImageTransparency",
				"ScrollBarThickness",
				"VerticalScrollBarInset",
				"HorizontalScrollBarInset",
			})
		)
	end

	if inst:IsA("ViewportFrame") then
		mergeProps(
			props,
			readProps(inst, { "Ambient", "ImageColor3", "ImageTransparency", "LightColor", "LightDirection" })
		)
	end

	if inst:IsA("UIStroke") then
		mergeProps(
			props,
			readProps(inst, { "Color", "Transparency", "Thickness", "ApplyStrokeMode", "LineJoinMode", "Enabled" })
		)
	end

	if inst:IsA("UICorner") then
		mergeProps(props, readProps(inst, { "CornerRadius" }))
	end

	if inst:IsA("UIAspectRatioConstraint") then
		mergeProps(props, readProps(inst, { "AspectRatio", "AspectType", "DominantAxis" }))
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
		mergeProps(props, readProps(inst, { "PaddingTop", "PaddingBottom", "PaddingLeft", "PaddingRight" }))
	end

	if inst:IsA("UIListLayout") then
		mergeProps(
			props,
			readProps(inst, { "FillDirection", "HorizontalAlignment", "VerticalAlignment", "SortOrder", "Padding" })
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
		mergeProps(props, readProps(inst, { "Color", "Enabled", "Offset", "Rotation", "Transparency" }))
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

local function childNames(inst)
	local names = {}
	for _, child in ipairs(sortedChildren(inst)) do
		table.insert(names, child.Name)
	end
	return names
end

local function nodeFor(inst, depth)
	local props = commonGuiProps(inst)
	mergeProps(props, classProps(inst))

	return {
		path = pathOf(inst),
		name = inst.Name,
		className = inst.ClassName,
		depth = depth,
		attributes = attributesToData(inst),
		props = props,
		children = childNames(inst),
	}
end

local function walk(inst, depth, maxDepth, nodes, state)
	if state.count >= MAX_NODES_PER_JOB then
		state.trimmed = true
		return
	end

	state.count = state.count + 1
	table.insert(nodes, nodeFor(inst, depth))

	if maxDepth and depth >= maxDepth then
		state.depthLimited = true
		return
	end

	for _, child in ipairs(sortedChildren(inst)) do
		walk(child, depth + 1, maxDepth, nodes, state)
		if state.trimmed then
			return
		end
	end
end

local function buildJobFilter()
	local map = {}
	for name in tostring(JOB_FILTER):gmatch("[^,%s]+") do
		map[name] = true
	end
	return map
end

local function shouldRunJob(job, filter)
	return JOB_FILTER == "" or filter[job.name] == true
end

local function addAutoJob(jobs, seen, root, maxDepth)
	local path = pathOf(root)
	local name = safeSegmentName(path)
	if seen[name] then
		return
	end
	seen[name] = true
	table.insert(jobs, {
		name = name,
		path = path,
		maxDepth = maxDepth,
	})
end

local function findResourceUi()
	local replicatedStorage = game:GetService("ReplicatedStorage")
	local resource = replicatedStorage:FindFirstChild("Resource")
	if not resource then
		return nil
	end
	return resource:FindFirstChild("ui") or resource:FindFirstChild("UI")
end

local function appendAutoDiscoveredJobs()
	local seen = {}
	for _, job in ipairs(TARGET_JOBS) do
		seen[job.name] = true
	end

	if AUTO_INCLUDE_STARTERGUI then
		local starterGui = game:GetService("StarterGui")
		for _, child in ipairs(sortedChildren(starterGui)) do
			if child:IsA("LayerCollector") then
				addAutoJob(TARGET_JOBS, seen, child, AUTO_MAX_DEPTH)
			end
		end
	end

	if AUTO_INCLUDE_REPLICATED_RESOURCE_UI then
		local resourceUi = findResourceUi()
		if resourceUi then
			for _, child in ipairs(sortedChildren(resourceUi)) do
				if child:IsA("LayerCollector") or child:IsA("GuiObject") then
					addAutoJob(TARGET_JOBS, seen, child, AUTO_MAX_DEPTH)
				end
			end
		end
	end

	if AUTO_INCLUDE_PLAYERGUI then
		for _, player in ipairs(Players:GetPlayers()) do
			local playerGui = player:FindFirstChildOfClass("PlayerGui") or player:FindFirstChild("PlayerGui")
			if playerGui then
				for _, child in ipairs(sortedChildren(playerGui)) do
					if child:IsA("LayerCollector") then
						addAutoJob(TARGET_JOBS, seen, child, AUTO_MAX_DEPTH)
					end
				end
			end
		end
	end
end

local function postPayload(payload)
	local ok, err = pcall(function()
		HttpService:PostAsync(POST_URL, HttpService:JSONEncode(payload), Enum.HttpContentType.ApplicationJson, false)
	end)
	if not ok then
		warn("[GuiHttpSnapshotExporter] HTTP POST failed; no JSON was printed to Output: " .. tostring(err))
		return false
	end
	return true
end

local exportedJobs = {}
local missingJobs = {}
local jobFilter = buildJobFilter()

if #TARGET_JOBS == 0 and AUTO_DISCOVER_GUI_ROOTS then
	appendAutoDiscoveredJobs()
	print(
		"[GuiHttpSnapshotExporter] TARGET_JOBS was empty; auto-discovered " .. tostring(#TARGET_JOBS) .. " GUI roots."
	)
end

if #TARGET_JOBS == 0 then
	print("[GuiHttpSnapshotExporter] TARGET_JOBS is empty and auto-discovery found no GUI roots.")
	return
end

for _, job in ipairs(TARGET_JOBS) do
	if shouldRunJob(job, jobFilter) then
		local root = resolvePath(job.path)
		if not root then
			table.insert(missingJobs, job)
		else
			local nodes = {}
			local state = {
				count = 0,
				trimmed = false,
				depthLimited = false,
			}
			walk(root, 0, job.maxDepth, nodes, state)

			local data = {
				exportName = EXPORT_NAME,
				exportedAt = os.date("!%Y-%m-%dT%H:%M:%SZ"),
				jobName = job.name,
				targetPath = job.path,
				maxDepth = job.maxDepth,
				nodeCount = #nodes,
				trimmed = state.trimmed,
				depthLimited = state.depthLimited,
				nodes = nodes,
			}

			local ok = postPayload({
				kind = "segment",
				exportName = EXPORT_NAME,
				segmentName = job.name,
				targetPath = job.path,
				data = data,
			})

			table.insert(exportedJobs, {
				name = job.name,
				path = job.path,
				nodeCount = #nodes,
				trimmed = state.trimmed,
				depthLimited = state.depthLimited,
				posted = ok,
			})

			print(
				"[GuiHttpSnapshotExporter] POSTED "
					.. job.name
					.. " nodes="
					.. tostring(#nodes)
					.. " trimmed="
					.. tostring(state.trimmed)
			)
		end
	end
end

postPayload({
	kind = "done",
	exportName = EXPORT_NAME,
	exportedAt = os.date("!%Y-%m-%dT%H:%M:%SZ"),
	exportedJobs = exportedJobs,
	missingJobs = missingJobs,
})

print("[GuiHttpSnapshotExporter] DONE")
