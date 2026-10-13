--!strict

-- 验证点分路径、诊断信息、重名拒绝、目录映射及共享模板克隆；不下载或修改外部资源。
-- 多数用例使用临时 Instance；两个映射相关用例依赖当前 Place 已同步的 Game.Resources。
return function(testContext)
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local ResourceClient = require(ReplicatedStorage.Framework.Shared.Resource.ResourceClient)
	local ResourceResolver = require(ReplicatedStorage.Framework.Shared.Resource.ResourceResolver)
	local ResourceValidator = require(game.ServerScriptService.Server.Framework.Resource.ResourceValidator)
	local expect = testContext.expect

	-- 创建未挂到 DataModel 的独立根；Resolver 允许这样查找，Validator 会报告实际位置不符。
	local function newRoot()
		local root = Instance.new("Folder")
		root.Name = "Resources"
		return root
	end

	-- 构造 Resources/Egg/Basic，确认点分字符串逐层命中同一个模板，而不是创建副本。
	testContext.test("resolves a dotted relative resource path", function()
		local root = newRoot()
		local eggFolder = Instance.new("Folder")
		eggFolder.Name = "Egg"
		eggFolder.Parent = root
		local basic = Instance.new("Model")
		basic.Name = "Basic"
		basic.Parent = eggFolder

		local resolved, resolveError = ResourceResolver.Resolve(root, "Shared", "Egg.Basic")

		expect.equal(resolved, basic)
		expect.equal(resolveError, nil)
		root:Destroy()
	end)

	-- 已有 Stage 但缺 Stage01，诊断必须指出失败节点，而非笼统报告整条路径错误。
	testContext.test("reports the exact missing path segment", function()
		local root = newRoot()
		local stageFolder = Instance.new("Folder")
		stageFolder.Name = "Stage"
		stageFolder.Parent = root

		local resolved, resolveError, failure = ResourceResolver.Resolve(root, "Server", "Stage.Stage01")

		expect.equal(resolved, nil)
		expect.equal(resolveError, "RESOURCE_NOT_FOUND")
		expect.equal(failure.Scope, "Server")
		expect.equal(failure.Path, "Stage.Stage01")
		expect.equal(failure.Missing, "Stage01")
		root:Destroy()
	end)

	-- 分别覆盖路径中连续点号产生的空节点，以及 Shared/Server 以外的范围名。
	testContext.test("rejects empty nodes and unknown scopes", function()
		local root = newRoot()

		local _, pathError = ResourceResolver.Resolve(root, "Shared", "Egg..Basic")
		local _, scopeError = ResourceResolver.Resolve(root, "Private", "Egg.Basic")

		expect.equal(pathError, "INVALID_RESOURCE_PATH")
		expect.equal(scopeError, "INVALID_RESOURCE_SCOPE")
		root:Destroy()
	end)

	-- Roblox 允许同级重名；解析器必须拒绝歧义，不能恰好返回遍历到的第一个对象。
	testContext.test("rejects duplicate names instead of choosing one", function()
		local root = newRoot()
		for _ = 1, 2 do
			local duplicate = Instance.new("Folder")
			duplicate.Name = "Egg"
			duplicate.Parent = root
		end

		local resolved, resolveError = ResourceResolver.Resolve(root, "Shared", "Egg")

		expect.equal(resolved, nil)
		expect.equal(resolveError, "RESOURCE_DUPLICATE_NAME")
		root:Destroy()
	end)

	-- 一次扫描应收集多个问题；转成 code 集合断言，不依赖 GetChildren 的遍历顺序。
	testContext.test("validator finds duplicate and dotted node names", function()
		local root = newRoot()
		for _ = 1, 2 do
			local duplicate = Instance.new("Folder")
			duplicate.Name = "Egg"
			duplicate.Parent = root
		end
		local dotted = Instance.new("Folder")
		dotted.Name = "Bad.Name"
		dotted.Parent = root

		local issues = ResourceValidator.ValidateRoot("Shared", root)
		local codes = {}
		for _, issue in ipairs(issues) do
			codes[issue.Code] = true
		end

		expect.truthy(codes.RESOURCE_DUPLICATE_NAME)
		expect.truthy(codes.RESOURCE_NAME_CONTAINS_DOT)
		expect.truthy(codes.RESOURCE_SCOPE_MISMATCH)
		root:Destroy()
	end)

	-- 模型是整体模板；内部骨骼名称及同级内部对象不属于资源目录命名规则。
	testContext.test("validator preserves imported model internals", function()
		local root = newRoot()
		local category = Instance.new("Folder")
		category.Name = "Creature"
		category.Parent = root
		local model = Instance.new("Model")
		model.Name = "Rig"
		model.Parent = category
		local body = Instance.new("Part")
		body.Parent = model
		for _ = 1, 2 do
			local bone = Instance.new("Bone")
			bone.Name = "root.x"
			bone.Parent = body
		end

		local issues = ResourceValidator.ValidateRoot("Server", root)
		root:Destroy()
		-- 独立测试根未放入 ServerStorage，位置错误应仍保留，内部名称不应额外报错。
		expect.equal(#issues, 1)
		expect.equal(issues[1].Code, "RESOURCE_SCOPE_MISMATCH")
	end)

	-- 停止扫描模型内部不能放宽模型自身的名称和同级唯一性约束。
	testContext.test("validator still rejects invalid and duplicate model template names", function()
		local root = newRoot()
		for _, name in ipairs({ "Bad.Name", " Rig", "Rig ", "Same", "Same" }) do
			local model = Instance.new("Model")
			model.Name = name
			model.Parent = root
		end
		local issues = ResourceValidator.ValidateRoot("Server", root)
		local counts = {}
		for _, issue in ipairs(issues) do
			counts[issue.Code] = (counts[issue.Code] or 0) + 1
		end
		root:Destroy()
		expect.equal(counts.RESOURCE_NAME_CONTAINS_DOT, 1)
		expect.equal(counts.INVALID_RESOURCE_PATH, 2)
		expect.equal(counts.RESOURCE_DUPLICATE_NAME, 1)
	end)

	-- GUI 根是资源路径节点；其内部标签重名、带点号或空白不会成为资源目录错误。
	testContext.test("validator preserves GUI template internals", function()
		local root = newRoot()
		for _, className in ipairs({ "ScreenGui", "Frame" }) do
			local template = Instance.new(className)
			template.Name = className
			template.Parent = root
			for _, name in ipairs({ "Label.Text", "Label.Text", " Title " }) do
				local label = Instance.new("TextLabel")
				label.Name = name
				label.Parent = template
			end
		end

		local issues = ResourceValidator.ValidateRoot("Shared", root)
		root:Destroy()
		expect.equal(#issues, 1)
		expect.equal(issues[1].Code, "RESOURCE_SCOPE_MISMATCH")
	end)

	-- GUI 内部免检不能放宽 GUI 根名称及根的同级唯一性要求。
	testContext.test("validator still rejects invalid and duplicate GUI template names", function()
		local root = newRoot()
		for _, name in ipairs({ "Bad.Name", " Window", "Window ", "Same", "Same" }) do
			local template = Instance.new("ScreenGui")
			template.Name = name
			template.Parent = root
		end

		local issues = ResourceValidator.ValidateRoot("Shared", root)
		local counts = {}
		for _, issue in ipairs(issues) do
			counts[issue.Code] = (counts[issue.Code] or 0) + 1
		end
		root:Destroy()
		expect.equal(counts.RESOURCE_SCOPE_MISMATCH, 1)
		expect.equal(counts.RESOURCE_NAME_CONTAINS_DOT, 1)
		expect.equal(counts.INVALID_RESOURCE_PATH, 2)
		expect.equal(counts.RESOURCE_DUPLICATE_NAME, 1)
		expect.equal(#issues, 5)
	end)

	-- 分类目录继续逐层检查；既不把 Folder 当成默认模板，也不忽略更深的目录错误。
	testContext.test("validator keeps checking ordinary Folder categories", function()
		local root = newRoot()
		local category = Instance.new("Folder")
		category.Name = "UI"
		category.Parent = root
		local nested = Instance.new("Folder")
		nested.Name = "Windows"
		nested.Parent = category
		for _, name in ipairs({ "Bad.Name", "Same", "Same" }) do
			local child = Instance.new("Folder")
			child.Name = name
			child.Parent = nested
		end

		local issues = ResourceValidator.ValidateRoot("Shared", root)
		local found = {}
		for _, issue in ipairs(issues) do
			found[issue.Code] = issue.Path
		end
		root:Destroy()
		expect.equal(#issues, 3)
		expect.equal(found.RESOURCE_SCOPE_MISMATCH, "<root>")
		expect.equal(found.RESOURCE_NAME_CONTAINS_DOT, "UI.Windows.Bad.Name")
		expect.equal(found.RESOURCE_DUPLICATE_NAME, "UI.Windows.Same")
	end)

	-- Folder 只有显式 Template=true 才停止内部路径命名检查。
	testContext.test("validator preserves explicit Folder template internals", function()
		local root = newRoot()
		local template = Instance.new("Folder")
		template.Name = "Bundle"
		template:SetAttribute("Template", true)
		template.Parent = root
		for _ = 1, 2 do
			local internal = Instance.new("Folder")
			internal.Name = "Parts.Inner"
			internal.Parent = template
			local nested = Instance.new("Folder")
			nested.Name = " Deep "
			nested.Parent = internal
		end

		local issues = ResourceValidator.ValidateRoot("Server", root)
		root:Destroy()
		expect.equal(#issues, 1)
		expect.equal(issues[1].Code, "RESOURCE_SCOPE_MISMATCH")
	end)

	-- 显式 Folder 模板根仍参与分类层的名称和唯一性检查。
	testContext.test("validator checks explicit Folder template root names", function()
		local root = newRoot()
		for _, name in ipairs({ "Bad.Name", "Same", "Same" }) do
			local template = Instance.new("Folder")
			template.Name = name
			template:SetAttribute("Template", true)
			template.Parent = root
		end

		local issues = ResourceValidator.ValidateRoot("Server", root)
		local codes = {}
		for _, issue in ipairs(issues) do
			codes[issue.Code] = true
		end
		root:Destroy()
		expect.equal(#issues, 3)
		expect.truthy(codes.RESOURCE_SCOPE_MISMATCH)
		expect.truthy(codes.RESOURCE_NAME_CONTAINS_DOT)
		expect.truthy(codes.RESOURCE_DUPLICATE_NAME)
	end)

	-- 非 Folder 根统一作为整体模板；Part、Attachment、样式也不把内部对象当资源目录。
	testContext.test("validator preserves other non Folder template internals", function()
		local root = newRoot()
		for _, className in ipairs({ "Part", "Attachment", "StyleSheet" }) do
			local template = Instance.new(className)
			template.Name = className
			template.Parent = root
			for _ = 1, 2 do
				local internal = Instance.new("Folder")
				internal.Name = "Inner.Name"
				internal.Parent = template
			end
		end

		local issues = ResourceValidator.ValidateRoot("Server", root)
		root:Destroy()
		expect.equal(#issues, 1)
		expect.equal(issues[1].Code, "RESOURCE_SCOPE_MISMATCH")
	end)

	-- 根不可复制时只报告根，不继续为同模板中的不可复制后代追加错误。
	testContext.test("validator reports the non archivable template root once", function()
		local root = newRoot()
		local template = Instance.new("ScreenGui")
		template.Name = "Window"
		template.Archivable = false
		template.Parent = root
		local internal = Instance.new("TextLabel")
		internal.Name = "Hidden.Label"
		internal.Archivable = false
		internal.Parent = template

		local issues = ResourceValidator.ValidateRoot("Shared", root)
		local cloneIssue = nil
		for _, issue in ipairs(issues) do
			if issue.Code == "RESOURCE_NOT_ARCHIVABLE" then
				cloneIssue = issue
			end
		end
		expect.equal(template.Archivable, false)
		expect.equal(internal.Archivable, false)
		expect.equal(template.Parent, root)
		root:Destroy()
		expect.equal(#issues, 2)
		expect.truthy(cloneIssue)
		expect.equal(cloneIssue.Scope, "Shared")
		expect.equal(cloneIssue.Path, "Window")
		expect.equal(cloneIssue.Missing, "Window")
	end)

	-- 内部命名免检仍遍历整个复制树，发现深层不可复制节点；每个模板只收集首个。
	testContext.test("validator finds deep non archivable descendants across template types", function()
		local root = newRoot()
		for _, className in ipairs({ "Model", "ScreenGui", "Folder" }) do
			local template = Instance.new(className)
			template.Name = className
			if className == "Folder" then
				template:SetAttribute("Template", true)
			end
			template.Parent = root
			local internal = Instance.new("Folder")
			internal.Name = "Inner.Nodes"
			internal.Parent = template
			for _ = 1, 2 do
				local hidden = Instance.new("Folder")
				hidden.Name = "Hidden.Node"
				hidden.Archivable = false
				hidden.Parent = internal
			end
		end

		local issues = ResourceValidator.ValidateRoot("Server", root)
		local paths = {}
		for _, issue in ipairs(issues) do
			if issue.Code ~= "RESOURCE_SCOPE_MISMATCH" then
				expect.equal(issue.Code, "RESOURCE_NOT_ARCHIVABLE")
				expect.equal(issue.Scope, "Server")
				expect.equal(issue.Missing, "Hidden.Node")
				expect.falsy(paths[issue.Path])
				paths[issue.Path] = true
			end
		end
		root:Destroy()
		expect.equal(#issues, 4)
		expect.truthy(paths.Model)
		expect.truthy(paths.ScreenGui)
		expect.truthy(paths.Folder)
	end)

	-- 分类 Folder 的 Archivable 不影响其子模板单独复制，因此不能据此误报子模板。
	testContext.test("validator ignores category Archivable when checking child templates", function()
		local root = newRoot()
		root.Archivable = false
		local category = Instance.new("Folder")
		category.Name = "Creature"
		category.Archivable = false
		category.Parent = root
		local template = Instance.new("Model")
		template.Name = "Rig"
		template.Parent = category
		local body = Instance.new("Part")
		body.Parent = template

		local issues = ResourceValidator.ValidateRoot("Server", root)
		expect.equal(root.Archivable, false)
		expect.equal(category.Archivable, false)
		expect.equal(template.Archivable, true)
		root:Destroy()
		expect.equal(#issues, 1)
		expect.equal(issues[1].Code, "RESOURCE_SCOPE_MISMATCH")
	end)

	-- 分类 Folder 本身不要求可复制，仍须检查其下每个整体模板的可复制性。
	testContext.test("validator checks templates beneath a non archivable category", function()
		local root = newRoot()
		local category = Instance.new("Folder")
		category.Name = "Creature"
		category.Archivable = false
		category.Parent = root
		local template = Instance.new("Model")
		template.Name = "Rig"
		template.Archivable = false
		template.Parent = category

		local issues = ResourceValidator.ValidateRoot("Server", root)
		root:Destroy()
		expect.equal(#issues, 2)
		expect.equal(issues[1].Code, "RESOURCE_SCOPE_MISMATCH")
		expect.equal(issues[2].Code, "RESOURCE_NOT_ARCHIVABLE")
		expect.equal(issues[2].Path, "Creature.Rig")
		expect.equal(issues[2].Missing, "Rig")
	end)

	-- 非布尔 true 的 Template 属性仍是分类目录，不能意外跳过后代路径检查。
	testContext.test("validator requires boolean true for a Folder template boundary", function()
		local root = newRoot()
		local category = Instance.new("Folder")
		category.Name = "Bundle"
		category:SetAttribute("Template", "true")
		category.Parent = root
		local internal = Instance.new("Folder")
		internal.Name = "Bad.Name"
		internal.Parent = category

		local issues = ResourceValidator.ValidateRoot("Shared", root)
		root:Destroy()
		expect.equal(#issues, 2)
		expect.equal(issues[1].Code, "RESOURCE_SCOPE_MISMATCH")
		expect.equal(issues[2].Code, "RESOURCE_NAME_CONTAINS_DOT")
		expect.equal(issues[2].Path, "Bundle.Bad.Name")
	end)

	-- 两仓库同路径的带骨骼模板应按 Scope 分开克隆；移动副本不改变模板或骨骼名称。
	testContext.test("service clones rigged models by scope without changing templates", function()
		local serverStorage = game:GetService("ServerStorage")
		local roots = { Shared = ReplicatedStorage.Game.Resources, Server = serverStorage.Game.Resources }
		for _, root in pairs(roots) do
			expect.equal(root:FindFirstChild("ResourceRigTest"), nil)
		end
		local folders = {}
		local templates = {}
		local runtime = Instance.new("Folder")
		local module = game.ServerScriptService.Server.Framework.Services.ResourceService:Clone()
		module.Name = "ResourceRigTestService"
		module.Parent = game.ServerScriptService.Server.Framework.Services
		local ok, testError = pcall(function()
			for scope, root in pairs(roots) do
				local folder = Instance.new("Folder")
				folder.Name = "ResourceRigTest"
				folder.Parent = root
				table.insert(folders, folder)
				local model = Instance.new("Model")
				model.Name = "Rig"
				model:SetAttribute("Origin", scope)
				model.Parent = folder
				local body = Instance.new("Part")
				body.Name = "Body"
				body.Anchored = true
				body.Parent = model
				model.PrimaryPart = body
				local bone = Instance.new("Bone")
				bone.Name = "root.x"
				bone.Parent = body
				templates[scope] = model
			end

			-- 使用独立模块状态与空日志器，不重复初始化游戏正在使用的服务。
			local service = require(module)
			service:Init({ Logger = { Info = function() end, Warn = function() end } })
			for scope, template in pairs(templates) do
				local originalPivot = template:GetPivot()
				local clone, cloneError = service:Clone(scope, "ResourceRigTest.Rig", runtime)
				expect.equal(cloneError, nil)
				expect.truthy(clone ~= template)
				expect.equal(clone.Parent, runtime)
				expect.equal(clone:GetAttribute("Origin"), scope)
				expect.equal(#clone:GetDescendants(), #template:GetDescendants())
				expect.equal(clone.PrimaryPart, clone.Body)
				expect.truthy(clone.Body:FindFirstChild("root.x"):IsA("Bone"))
				local destination = CFrame.new(8, 3, 0) * CFrame.Angles(0, math.rad(90), 0)
				clone:PivotTo(destination)
				expect.truthy((clone:GetPivot().Position - destination.Position).Magnitude < 0.001)
				expect.truthy((clone:GetPivot().LookVector - destination.LookVector).Magnitude < 0.001)
				expect.equal(template:GetPivot(), originalPivot)
				expect.equal(template.Parent, roots[scope].ResourceRigTest)
				expect.truthy(template.Body:FindFirstChild("root.x"):IsA("Bone"))
			end
		end)
		runtime:Destroy()
		module:Destroy()
		for _, folder in ipairs(folders) do
			folder:Destroy()
		end
		if not ok then
			error(testError, 0)
		end
	end)

	-- 检查实际 Rojo 映射的两份根目录；目录与模板名称错误仍会让这个用例失败。
	testContext.test("mapped resource roots pass Studio validation", function()
		local sharedRoot = ReplicatedStorage.Game.Resources
		local serverRoot = game:GetService("ServerStorage").Game.Resources
		local issues = ResourceValidator.ValidateRoots(sharedRoot, serverRoot)

		expect.equal(#issues, 0)
	end)

	-- 从服务器测试环境直接调用 ResourceClient，验证固定 Shared 根与克隆行为；不验证客户端复制时序。
	testContext.test("client gets and clones only from the shared root", function()
		local sharedRoot = ReplicatedStorage.Game.Resources
		local category = Instance.new("Folder")
		category.Name = "ResourceClientTest"
		category.Parent = sharedRoot
		local template = Instance.new("Folder")
		template.Name = "Template"
		template.Parent = category
		local runtimeParent = Instance.new("Folder")

		-- 暂时写入测试专用分类；捕获断言异常后也要清理，以免污染下一次资源目录检查。
		local ok, testError = pcall(function()
			local found, getError = ResourceClient:Get("ResourceClientTest.Template")
			local clone, cloneError = ResourceClient:Clone("ResourceClientTest.Template", runtimeParent)

			expect.equal(found, template)
			expect.equal(getError, nil)
			expect.equal(cloneError, nil)
			expect.truthy(clone ~= template)
			expect.equal(clone.Parent, runtimeParent)
		end)

		category:Destroy()
		runtimeParent:Destroy()
		if not ok then
			error(testError, 0)
		end
	end)
end
