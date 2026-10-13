--!strict

-- 独立模块验证启动清单、预检和阶段保护；不调用真实 Storage、Net 或游戏逻辑。
-- 客户端注册器在服务器测试其模块行为，不代表真实客户端界面已经完成验收。
return function(testContext)
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Lifecycle = require(ReplicatedStorage.Framework.Shared.App.Lifecycle)
	local ServiceRegistry = require(game.ServerScriptService.Server.Framework.Runtime.ServiceRegistry)
	local ControllerRegistry =
		require(game.StarterPlayer.StarterPlayerScripts.Client.Framework.Runtime.ControllerRegistry)
	local expect = testContext.expect
	local registryTypes = {
		{ Registry = ServiceRegistry, Kind = "Service", Index = "Services", Get = "GetService" },
		{ Registry = ControllerRegistry, Kind = "Controller", Index = "Controllers", Get = "GetController" },
	}

	local function contains(message, fragment)
		expect.truthy(string.find(tostring(message), fragment, 1, true))
	end

	local function expectRejectedCalls(registry)
		expect.throws(function()
			registry:Init()
		end)
		expect.throws(function()
			registry:Start()
		end)
	end

	testContext.test("copies a dense list without copying its modules", function()
		local first = { Name = "First" }
		local source = { first }
		local copy = Lifecycle.CopyList(source, "TestList")
		expect.falsy(copy == source)
		expect.equal(copy[1], first)
		source[1] = { Name = "Replacement" }
		source[2] = { Name = "Late" }
		expect.equal(copy[1], first)
		expect.equal(#copy, 1)
		expect.equal(#Lifecycle.CopyList({}, "EmptyList"), 0)
	end)

	-- 原清单必须完整检查，不能把 ipairs 遇空洞时的截断结果当成合法列表。
	local invalidLists = {
		{ Name = "missing first item", Value = { [2] = { Name = "Late" } } },
		{ Name = "middle hole", Value = { [1] = { Name = "First" }, [3] = { Name = "Late" } } },
		{ Name = "zero key", Value = { [0] = { Name = "Zero" } } },
		{ Name = "negative key", Value = { [-1] = { Name = "Negative" } } },
		{ Name = "fractional key", Value = { [1.5] = { Name = "Fraction" } } },
		{ Name = "named key", Value = { [1] = { Name = "First" }, Extra = { Name = "Extra" } } },
		{ Name = "numeric string key", Value = { ["1"] = { Name = "StringKey" } } },
		{ Name = "boolean list", Value = false },
		{ Name = "number list", Value = 1 },
		{ Name = "string list", Value = "First" },
		{ Name = "nil list" },
	}
	for _, invalid in ipairs(invalidLists) do
		testContext.test("rejects list shape: " .. invalid.Name, function()
			local message = expect.throws(function()
				Lifecycle.CopyList(invalid.Value, "TestList")
			end)
			contains(message, "TestList")
			for _, variant in ipairs(registryTypes) do
				expect.throws(function()
					variant.Registry.new(invalid.Value)
				end)
			end
		end)
	end

	for _, variant in ipairs(registryTypes) do
		local function test(name, callback)
			testContext.test(variant.Kind .. ": " .. name, callback)
		end

		test("allows an empty list", function()
			local registry = variant.Registry.new({})
			registry:Init()
			registry:Start()
			expect.equal(registry[variant.Get](registry, "Missing"), nil)
		end)

		test("keeps a snapshot of list membership and order", function()
			local calls = {}
			local first = {
				Name = "First",
				Init = function()
					table.insert(calls, "first")
				end,
			}
			local second = {
				Name = "Second",
				Init = function()
					table.insert(calls, "second")
				end,
			}
			local source = { first, second }
			local registry = variant.Registry.new(source)
			source[1] = { Name = "Replacement" }
			source[2] = nil
			source[3] = { Name = "Late" }
			registry:Init()
			registry:Start()
			expect.equal(table.concat(calls, ","), "first,second")
			expect.equal(registry[variant.Get](registry, "First"), first)
			expect.equal(registry[variant.Get](registry, "Second"), second)
			expect.equal(registry[variant.Get](registry, "Replacement"), nil)
			expect.equal(registry[variant.Get](registry, "Late"), nil)
		end)

		test("indexes all modules before ordered Init and Start calls", function()
			local calls = {}
			local first = { Name = "First" }
			local second = { Name = "Second" }
			local sharedContext = nil
			local registry = variant.Registry.new({ first, second })
			function first:Init(context)
				expect.equal(self, first)
				expect.equal(context[variant.Index].Second, second)
				expect.equal(registry[variant.Get](registry, "Second"), second)
				expect.truthy(context.Logger)
				if variant.Kind == "Controller" then
					expect.truthy(context.Net)
				end
				sharedContext = context
				table.insert(calls, "first:init")
			end
			function second:Init(context)
				expect.equal(self, second)
				expect.equal(context, sharedContext)
				table.insert(calls, "second:init")
			end
			function first:Start()
				expect.equal(self, first)
				table.insert(calls, "first:start")
			end
			function second:Start()
				expect.equal(self, second)
				table.insert(calls, "second:start")
			end
			registry:Init()
			registry:Start()
			expect.equal(table.concat(calls, ","), "first:init,second:init,first:start,second:start")
		end)

		test("allows missing optional lifecycle methods", function()
			local calls = {}
			local registry = variant.Registry.new({
				{ Name = "Empty" },
				{
					Name = "InitOnly",
					Init = function()
						table.insert(calls, "init")
					end,
				},
				{
					Name = "StartOnly",
					Start = function()
						table.insert(calls, "start")
					end,
				},
			})
			registry:Init()
			registry:Start()
			expect.equal(table.concat(calls, ","), "init,start")
		end)

		test("rejects Start before Init without running a module", function()
			local calls = 0
			local registry =
				variant.Registry.new({ {
					Name = "First",
					Start = function()
						calls += 1
					end,
				} })
			expect.throws(function()
				registry:Start()
			end)
			expect.equal(calls, 0)
			registry:Init()
			registry:Start()
			expect.equal(calls, 1)
		end)

		test("rejects completed stages without repeating side effects", function()
			local initCalls = 0
			local startCalls = 0
			local registry = variant.Registry.new({
				{
					Name = "First",
					Init = function()
						initCalls += 1
					end,
					Start = function()
						startCalls += 1
					end,
				},
			})
			registry:Init()
			expect.throws(function()
				registry:Init()
			end)
			registry:Start()
			expectRejectedCalls(registry)
			expect.equal(initCalls, 1)
			expect.equal(startCalls, 1)
		end)

		local invalidModules = {
			{ Name = "non-table module", Value = false },
			{ Name = "missing Name", Value = {} },
			{ Name = "empty Name", Value = { Name = "" } },
			{ Name = "non-string Name", Value = { Name = 1 } },
			{ Name = "invalid Init", Value = { Name = "BadInit", Init = true } },
			{ Name = "invalid Start", Value = { Name = "BadStart", Start = true } },
		}
		for _, invalid in ipairs(invalidModules) do
			test("preflights " .. invalid.Name .. " before any Init", function()
				local calls = 0
				local first = {
					Name = "First",
					Init = function()
						calls += 1
					end,
				}
				local registry = variant.Registry.new({ first, invalid.Value })
				local message = expect.throws(function()
					registry:Init()
				end)
				contains(message, variant.Kind)
				contains(message, "Init")
				expect.equal(calls, 0)
				expect.equal(registry[variant.Get](registry, "First"), nil)
				expectRejectedCalls(registry)
				expect.equal(calls, 0)
			end)
		end

		test("preflights duplicate names before any Init", function()
			local calls = 0
			local first = {
				Name = "Same",
				Init = function()
					calls += 1
				end,
			}
			local registry = variant.Registry.new({ first, { Name = "Same" } })
			local message = expect.throws(function()
				registry:Init()
			end)
			contains(message, variant.Kind)
			contains(message, "Init")
			contains(message, "Same")
			expect.equal(calls, 0)
			expect.equal(registry[variant.Get](registry, "Same"), nil)
			expectRejectedCalls(registry)
		end)

		for _, phase in ipairs({ "Init", "Start" }) do
			test("stops and locks after " .. phase .. " fails", function()
				local calls = {}
				local first = { Name = "First" }
				local broken = { Name = "Broken" }
				local last = { Name = "Last" }
				first[phase] = function()
					table.insert(calls, "first")
				end
				broken[phase] = function()
					table.insert(calls, "broken")
					error("EXPECTED_STAGE_FAILURE", 0)
				end
				last[phase] = function()
					table.insert(calls, "last")
				end
				local registry = variant.Registry.new({ first, broken, last })
				if phase == "Start" then
					registry:Init()
				end
				local message = expect.throws(function()
					registry[phase](registry)
				end)
				contains(message, variant.Kind)
				contains(message, phase)
				contains(message, "Broken")
				contains(message, "EXPECTED_STAGE_FAILURE")
				expect.equal(table.concat(calls, ","), "first,broken")
				expectRejectedCalls(registry)
				expect.equal(table.concat(calls, ","), "first,broken")
			end)

			test("keeps diagnostic context when an error cannot be stringified in " .. phase, function()
				local calls = 0
				local problem = setmetatable({}, {
					__tostring = function()
						error("EXPECTED_TOSTRING_FAILURE", 0)
					end,
				})
				local broken = { Name = "Broken" }
				broken[phase] = function()
					calls += 1
					error(problem, 0)
				end
				local registry = variant.Registry.new({ broken })
				if phase == "Start" then
					registry:Init()
				end
				local message = expect.throws(function()
					registry[phase](registry)
				end)
				contains(message, variant.Kind)
				contains(message, phase)
				contains(message, "Broken")
				expectRejectedCalls(registry)
				expect.equal(calls, 1)
			end)

			test("locks after uncaught synchronous reentry during " .. phase, function()
				local calls = {}
				local registry = nil
				local first = { Name = "First" }
				local last = { Name = "Last" }
				first[phase] = function()
					table.insert(calls, "first")
					registry[phase](registry)
				end
				last[phase] = function()
					table.insert(calls, "last")
				end
				registry = variant.Registry.new({ first, last })
				if phase == "Start" then
					registry:Init()
				end
				local message = expect.throws(function()
					registry[phase](registry)
				end)
				contains(message, variant.Kind)
				contains(message, phase)
				contains(message, "First")
				expect.equal(table.concat(calls, ","), "first")
				expectRejectedCalls(registry)
				expect.equal(table.concat(calls, ","), "first")
			end)

			test("rejects captured synchronous reentry during " .. phase, function()
				local calls = 0
				local registry = nil
				local first = { Name = "First" }
				first[phase] = function()
					calls += 1
					expectRejectedCalls(registry)
				end
				registry = variant.Registry.new({ first })
				registry:Init()
				registry:Start()
				expect.equal(calls, 1)
			end)

			-- 手动推进协程，确定阶段停在 yield；不依赖 task.wait 或网络响应的时间。
			test("rejects concurrent calls while " .. phase .. " is suspended", function()
				local calls = 0
				local first = { Name = "First" }
				first[phase] = function()
					calls += 1
					coroutine.yield("STAGE_WAITING")
				end
				local registry = variant.Registry.new({ first })
				if phase == "Start" then
					registry:Init()
				end
				local thread = coroutine.create(function()
					registry[phase](registry)
				end)
				local ok, message = coroutine.resume(thread)
				expect.equal(ok, true)
				expect.equal(message, "STAGE_WAITING")
				expect.equal(coroutine.status(thread), "suspended")
				expectRejectedCalls(registry)
				local completed, completionError = coroutine.resume(thread)
				expect.equal(completed, true)
				expect.equal(completionError, nil)
				expect.equal(coroutine.status(thread), "dead")
				if phase == "Init" then
					registry:Start()
				end
				expect.equal(calls, 1)
			end)

			test("locks after " .. phase .. " yields and then fails", function()
				local calls = {}
				local broken = { Name = "Broken" }
				local last = { Name = "Last" }
				broken[phase] = function()
					table.insert(calls, "broken")
					coroutine.yield("STAGE_WAITING")
					error("EXPECTED_YIELD_FAILURE", 0)
				end
				last[phase] = function()
					table.insert(calls, "last")
				end
				local registry = variant.Registry.new({ broken, last })
				if phase == "Start" then
					registry:Init()
				end
				local thread = coroutine.create(function()
					registry[phase](registry)
				end)
				local ok, message = coroutine.resume(thread)
				expect.equal(ok, true)
				expect.equal(message, "STAGE_WAITING")
				local completed, failure = coroutine.resume(thread)
				expect.equal(completed, false)
				contains(failure, variant.Kind)
				contains(failure, phase)
				contains(failure, "Broken")
				contains(failure, "EXPECTED_YIELD_FAILURE")
				expect.equal(coroutine.status(thread), "dead")
				expect.equal(table.concat(calls, ","), "broken")
				expectRejectedCalls(registry)
				expect.equal(table.concat(calls, ","), "broken")
			end)
		end
	end
end
