--!strict

-- 验证 MemoryStorage 的公开读写契约，不访问真实 DataStore。
-- 返回的函数由 RunUnitTest 注入断言工具；每个用例新建后端，避免前一个用例的状态影响结果。
return function(testContext)
	local MemoryStorage = require(game.ReplicatedStorage.Framework.Shared.Storage.MemoryStorage)
	local expect = testContext.expect

	-- 构造含嵌套表的测试数据，并注入最小校验器；Counter 只服务于测试，不是框架业务字段。
	local function makeStorage()
		return MemoryStorage.new({
			Counter = 0,
			Nested = {
				Enabled = true,
			},
		}, function(data)
			if type(data.Counter) ~= "number" then
				return false, "Counter must be a number"
			end
			return true
		end)
	end

	-- 修改 Open 返回的顶层/嵌套字段后，再 Get 验证原值未变，以覆盖真正的深拷贝隔离。
	testContext.test("returns independent data copies", function()
		local storage = makeStorage()
		local opened = storage:Open("PlayerA")
		opened.Counter = 99
		opened.Nested.Enabled = false

		local stored = storage:Get("PlayerA")
		expect.equal(stored.Counter, 0)
		expect.truthy(stored.Nested.Enabled)
	end)

	-- Update 只更新指定的已打开 key，并返回更新后的副本。
	testContext.test("updates an opened key", function()
		local storage = makeStorage()
		storage:Open("PlayerA")

		local updated = storage:Update("PlayerA", function(data)
			data.Counter += 1
			return data
		end)

		expect.equal(updated.Counter, 1)
		expect.equal(storage:Get("PlayerA").Counter, 1)
	end)

	-- 此用例验证未打开的 key 读取会抛异常，不是返回 nil 或悄悄创建默认数据。
	testContext.test("rejects reads before open", function()
		local storage = makeStorage()
		expect.throws(function()
			storage:Get("Missing")
		end)
	end)

	testContext.test("can update after a rejected unopened update", function()
		local storage = makeStorage()
		local function increment(data)
			data.Counter += 1
			return data
		end
		expect.throws(function()
			storage:Update("PlayerA", increment)
		end)
		storage:Open("PlayerA")
		expect.equal(storage:Update("PlayerA", increment).Counter, 1)
	end)
end
