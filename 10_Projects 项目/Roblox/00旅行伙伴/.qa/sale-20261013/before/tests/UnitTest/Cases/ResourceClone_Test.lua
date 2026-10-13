--!strict

-- 只检查独立模板与模块副本，不初始化生产 ResourceService，不修改共享日志器。
-- Client 入口在服务器测试模块行为；原生客户端资源复制时序仍需单独验收。
return function(testContext)
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local ResourceCloner = require(ReplicatedStorage.Framework.Shared.Resource.ResourceCloner)
	local expect = testContext.expect

	local function withCleanup(objects, callback)
		local ok, testError = pcall(callback)
		for index = #objects, 1, -1 do
			objects[index]:Destroy()
		end
		if not ok then
			error(testError, 0)
		end
	end

	local function newInstance(className, name, parent)
		local instance = Instance.new(className)
		instance.Name = name
		instance.Parent = parent
		return instance
	end

	local function snapshotTree(root)
		local snapshot = {}
		local nodes = root:GetDescendants()
		table.insert(nodes, 1, root)
		for _, node in ipairs(nodes) do
			table.insert(snapshot, {
				Node = node,
				Name = node.Name,
				Parent = node.Parent,
				Archivable = node.Archivable,
			})
		end
		return snapshot
	end

	local function expectUnchanged(root, snapshot)
		expect.equal(#root:GetDescendants() + 1, #snapshot)
		for _, item in ipairs(snapshot) do
			expect.equal(item.Node.Name, item.Name)
			expect.equal(item.Node.Parent, item.Parent)
			expect.equal(item.Node.Archivable, item.Archivable)
		end
	end

	-- 根、直接后代与深层后代都必须拒绝部分复制，检查不自动修改 Archivable。
	for _, depth in ipairs({ "root", "direct", "deep" }) do
		testContext.test("rejects a non-archivable " .. depth .. " node without changing the source", function()
			local library = newInstance("Folder", "Library")
			local runtime = newInstance("Folder", "Runtime")
			withCleanup({ library, runtime }, function()
				local template = newInstance("Model", "Rig", library)
				local body = newInstance("Part", "Body", template)
				body.Anchored = true
				template.PrimaryPart = body
				local nested = newInstance("Folder", "Nested", template)
				local deepNode = newInstance("ObjectValue", "Deep", nested)
				local problem = if depth == "root" then template elseif depth == "direct" then body else deepNode
				problem.Archivable = false
				local snapshot = snapshotTree(template)
				local failure = ResourceCloner.CheckTemplate(template, "Server", "Creature.Rig")
				local clone, cloneError, cloneFailure =
					ResourceCloner.Clone(template, "Server", "Creature.Rig", runtime)

				expect.equal(failure.Code, "RESOURCE_NOT_ARCHIVABLE")
				expect.equal(failure.Scope, "Server")
				expect.equal(failure.Path, "Creature.Rig")
				expect.equal(failure.Missing, problem.Name)
				expect.equal(failure.FoundParent, problem.Parent:GetFullName())
				expect.equal(clone, nil)
				expect.equal(cloneError, failure.Code)
				expect.equal(cloneFailure.Code, failure.Code)
				expect.equal(cloneFailure.Missing, failure.Missing)
				expect.equal(cloneFailure.FoundParent, failure.FoundParent)
				expect.equal(#runtime:GetChildren(), 0)
				expect.equal(template.PrimaryPart, body)
				expectUnchanged(template, snapshot)
			end)
		end)
	end

	-- 通用资源克隆不要求 UI 的 Template 标记，也允许没有 PrimaryPart 的普通模型。
	testContext.test("clones parts and unmarked folders without requiring a Template attribute", function()
		local library = newInstance("Folder", "Library")
		local runtime = newInstance("Folder", "Runtime")
		withCleanup({ library, runtime }, function()
			for _, className in ipairs({ "Part", "Folder", "Model" }) do
				local template = newInstance(className, className .. "Template", library)
				template:SetAttribute("Origin", className)
				if className == "Folder" then
					newInstance("StringValue", "Text", template).Value = "kept"
				end
				expect.equal(template:GetAttribute("Template"), nil)
				expect.equal(ResourceCloner.CheckTemplate(template, "Shared", className), nil)
				local clone, cloneError, failure = ResourceCloner.Clone(template, "Shared", className, runtime)
				expect.falsy(clone == template)
				expect.equal(cloneError, nil)
				expect.equal(failure, nil)
				expect.equal(clone.Parent, runtime)
				expect.equal(clone.ClassName, className)
				expect.equal(clone:GetAttribute("Origin"), className)
				expect.equal(#clone:GetDescendants(), #template:GetDescendants())
				if className == "Folder" then
					expect.equal(clone.Text.Value, "kept")
				end
			end
		end)
	end)

	-- 原生 Clone 重映射内部对象引用，并保留明确指向模板树外的引用；移动副本不得改源模型。
	testContext.test("preserves native rig reference mapping and leaves the original model untouched", function()
		local library = newInstance("Folder", "Library")
		local runtime = newInstance("Folder", "Runtime")
		withCleanup({ library, runtime }, function()
			local external = newInstance("Part", "External", library)
			local template = newInstance("Model", "Rig", library)
			local body = newInstance("Part", "Body", template)
			body.Anchored = true
			body.CFrame = CFrame.new(5, 2, 0)
			local arm = newInstance("Part", "Arm", template)
			arm.Anchored = true
			arm.CFrame = CFrame.new(7, 2, 0)
			template.PrimaryPart = body
			newInstance("Bone", "root.x", body)
			local weld = newInstance("WeldConstraint", "Link", body)
			weld.Part0 = body
			weld.Part1 = arm
			newInstance("ObjectValue", "Internal", template).Value = arm
			newInstance("ObjectValue", "External", template).Value = external
			local snapshot = snapshotTree(template)
			local originalPivot = template:GetPivot()
			local originalArm = arm.CFrame
			local clone, cloneError = ResourceCloner.Clone(template, "Server", "Creature.Rig", runtime)

			expect.equal(cloneError, nil)
			expect.equal(clone.PrimaryPart, clone.Body)
			expect.equal(clone.Body.Link.Part0, clone.Body)
			expect.equal(clone.Body.Link.Part1, clone.Arm)
			expect.equal(clone.Internal.Value, clone.Arm)
			expect.equal(clone.External.Value, external)
			expect.truthy(clone.Body:FindFirstChild("root.x"):IsA("Bone"))
			expect.equal(#clone:GetDescendants(), #template:GetDescendants())
			local destination = CFrame.new(20, 4, 0) * CFrame.Angles(0, math.rad(90), 0)
			clone:PivotTo(destination)
			expect.truthy((clone:GetPivot().Position - destination.Position).Magnitude < 0.001)
			expect.truthy((clone:GetPivot().LookVector - destination.LookVector).Magnitude < 0.001)
			expect.equal(template:GetPivot(), originalPivot)
			expect.equal(arm.CFrame, originalArm)
			expect.equal(template.Internal.Value, arm)
			expect.equal(template.External.Value, external)
			expectUnchanged(template, snapshot)
		end)
	end)

	testContext.test("clones dotted and duplicate internal names without treating them as resource paths", function()
		local template = newInstance("ScreenGui", "Window")
		local runtime = newInstance("Folder", "Runtime")
		withCleanup({ template, runtime }, function()
			for _ = 1, 2 do
				newInstance("TextLabel", "Label.x", template)
			end
			local clone, cloneError = ResourceCloner.Clone(template, "Shared", "UI.Window", runtime)
			expect.equal(cloneError, nil)
			expect.equal(#clone:GetChildren(), 2)
			for _, child in ipairs(clone:GetChildren()) do
				expect.equal(child.Name, "Label.x")
			end
			expect.equal(#template:GetChildren(), 2)
		end)
	end)

	-- 独立 Service 副本保留相对依赖结构；Client 副本使用同一份只读共享依赖。
	local function withWrapper(kind, callback)
		local holder = newInstance("Folder", "ResourceCloneTest")
		withCleanup({ holder }, function()
			local wrapper
			local warnings = {}
			if kind == "Service" then
				local services = newInstance("Folder", "Services", holder)
				local resource = newInstance("Folder", "Resource", holder)
				local validator = game.ServerScriptService.Server.Framework.Resource.ResourceValidator:Clone()
				validator.Parent = resource
				local module = game.ServerScriptService.Server.Framework.Services.ResourceService:Clone()
				module.Parent = services
				wrapper = require(module)
				wrapper._warnFailure = function(_, failure)
					table.insert(warnings, failure)
				end
			else
				local module = ReplicatedStorage.Framework.Shared.Resource.ResourceClient:Clone()
				module.Parent = holder
				wrapper = require(module)
			end
			local function clone(path, parent)
				if kind == "Service" then
					return wrapper:Clone("Server", path, parent)
				end
				return wrapper:Clone(path, parent)
			end
			callback(wrapper, clone, warnings)
		end)
	end

	for _, kind in ipairs({ "Service", "Client" }) do
		testContext.test(kind .. ": rejects an incomplete template through the common clone guard", function()
			local template = newInstance("Folder", "Template")
			local runtime = newInstance("Folder", "Runtime")
			withCleanup({ template, runtime }, function()
				local child = newInstance("Part", "Body", template)
				child.Archivable = false
				withWrapper(kind, function(wrapper, clone, warnings)
					local getCalls = 0
					wrapper.Get = function()
						getCalls += 1
						return template, nil, nil
					end
					local result, cloneError, failure = clone("Creature.Rig", runtime)
					expect.equal(result, nil)
					expect.equal(cloneError, "RESOURCE_NOT_ARCHIVABLE")
					expect.equal(failure.Code, cloneError)
					expect.equal(failure.Scope, if kind == "Service" then "Server" else "Shared")
					expect.equal(failure.Path, "Creature.Rig")
					expect.equal(failure.Missing, "Body")
					expect.equal(failure.FoundParent, template:GetFullName())
					expect.equal(getCalls, 1)
					expect.equal(#runtime:GetChildren(), 0)
					expect.equal(child.Archivable, false)
					if kind == "Service" then
						expect.equal(#warnings, 1)
						expect.equal(warnings[1], failure)
					end
				end)
			end)
		end)

		testContext.test(kind .. ": clones the resolved template and returns success without an error", function()
			local template = newInstance("Folder", "Template")
			local runtime = newInstance("Folder", "Runtime")
			withCleanup({ template, runtime }, function()
				newInstance("Part", "Body", template)
				withWrapper(kind, function(wrapper, clone, warnings)
					wrapper.Get = function()
						return template, nil, nil
					end
					local result, cloneError, failure = clone("Creature.Rig", runtime)
					expect.falsy(result == template)
					expect.equal(result.Parent, runtime)
					expect.equal(#result:GetDescendants(), 1)
					expect.equal(cloneError, nil)
					expect.equal(failure, nil)
					expect.equal(#warnings, 0)
				end)
			end)
		end)

		testContext.test(kind .. ": passes a Get failure through without attempting a clone", function()
			local runtime = newInstance("Folder", "Runtime")
			withCleanup({ runtime }, function()
				withWrapper(kind, function(wrapper, clone, warnings)
					local getCalls = 0
					local failure = { Code = "RESOURCE_NOT_FOUND", Path = "Creature.Missing" }
					wrapper.Get = function()
						getCalls += 1
						if kind == "Service" then
							wrapper:_warnFailure(failure)
						end
						return nil, failure.Code, failure
					end
					local result, cloneError, returnedFailure = clone("Creature.Missing", runtime)
					expect.equal(result, nil)
					expect.equal(cloneError, failure.Code)
					expect.equal(returnedFailure, failure)
					expect.equal(getCalls, 1)
					expect.equal(#runtime:GetChildren(), 0)
					if kind == "Service" then
						expect.equal(#warnings, 1)
					end
				end)
			end)
		end)
	end

	-- Get 只定位原始模板；完整复制限制仅属于 Clone，不改变原始读取入口。
	testContext.test("service Get still returns a non-archivable original template", function()
		local root = newInstance("Folder", "Resources")
		withCleanup({ root }, function()
			local template = newInstance("Folder", "Template", root)
			template.Archivable = false
			withWrapper("Service", function(service, _, warnings)
				service._roots = { Shared = root, Server = root }
				local result, getError, failure = service:Get("Server", "Template")
				expect.equal(result, template)
				expect.equal(getError, nil)
				expect.equal(failure, nil)
				expect.equal(#warnings, 0)
				expect.equal(template.Archivable, false)
			end)
		end)
	end)
end
