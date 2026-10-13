--!strict

-- 验证 ProfileStore 会话打开后的准备阶段失败时不会遗留活动会话。
-- 也覆盖 Update 期间会话被替换的保护；使用假会话/替身存储，不调用真实存档加载或保存。
return function(testContext)
	local ProfileStoreStorage = require(game.ServerScriptService.Server.Framework.Storage.ProfileStoreStorage)
	local expect = testContext.expect

	-- 人为让 AddUserId 抛异常，验证准备阶段异常分支会调用一次 EndSession。
	testContext.test("ends a session when profile preparation crashes", function()
		local storage = ProfileStoreStorage.new("YanzoFrame_UnitTest", {
			SchemaVersion = 1,
		})
		local endSessionCount = 0
		local fakeProfile = {
			Data = {
				SchemaVersion = 1,
			},
		}

		-- 只实现当前失败路径会用到的方法；错误标记用于模拟准备失败，不是实际玩家数据。
		function fakeProfile:AddUserId(_userId)
			error("TEST_PROFILE_PREPARE_FAILED")
		end

		function fakeProfile:EndSession()
			endSessionCount += 1
		end

		-- 覆盖后端入口，让 Open 得到假会话；创建适配器本身不会执行真实 StartSessionAsync。
		storage._store = {
			StartSessionAsync = function(_self, _key, _options)
				return fakeProfile
			end,
		}

		expect.throws(function()
			storage:Open("PlayerA", {
				UserId = 1,
			})
		end)
		expect.equal(endSessionCount, 1)
	end)

	-- Update 回调期间会话被替换时，旧快照不能写入新会话。
	testContext.test("rejects an update after the storage session changes", function()
		local storage = ProfileStoreStorage.new("YanzoFrame_UnitTest", {
			SchemaVersion = 1,
			Value = 0,
		})
		local key = "PlayerA"

		-- 用闭包保存 active，模拟 IsActive/EndSession；没有自动保存或真实会话锁。
		local function makeProfile(value)
			local active = true
			local profile = {
				Data = {
					SchemaVersion = 1,
					Value = value,
				},
			}

			function profile:IsActive()
				return active
			end

			function profile:EndSession()
				active = false
			end

			return profile
		end

		local oldProfile = makeProfile(1)
		local newProfile = makeProfile(2)
		storage._profilesByKey[key] = oldProfile

		local callbackStarted = false
		local releaseCallback = false
		local updateDone = false
		local updateOk = false
		local updateError = nil

		-- 故意挂起更新回调，制造“读到旧会话 -> 会话被替换 -> 尝试提交”的竞态。
		-- 这是测试故障场景，正常业务 Update 回调应避免主动等待。
		task.spawn(function()
			updateOk, updateError = pcall(function()
				storage:Update(key, function(data)
					callbackStarted = true
					while not releaseCallback do
						task.wait()
					end
					data.Value = 99
					return data
				end)
			end)
			updateDone = true
		end)

		while not callbackStarted do
			task.wait()
		end

		-- 在回调恢复前安装新会话；旧副本中的 99 不得覆盖新会话原本的 2。
		storage:Close(key)
		storage._profilesByKey[key] = newProfile
		releaseCallback = true

		while not updateDone do
			task.wait()
		end

		expect.falsy(updateOk)
		expect.truthy(string.find(tostring(updateError), "storage session changed", 1, true))
		expect.equal(newProfile.Data.Value, 2)
	end)
end
