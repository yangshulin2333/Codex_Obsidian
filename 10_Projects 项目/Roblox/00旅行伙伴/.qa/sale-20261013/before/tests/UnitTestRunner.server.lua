--!strict

-- 人工入口：默认 Disabled。需要时临时启用并在 Studio 中 Play。
-- Disabled 属性由 default.project.json 配置，不是这条注释在控制；验收结束必须恢复禁用。
-- 本脚本只负责执行套件并让“未发现用例/有失败”明确报错，不启动框架服务。
local ServerStorage = game:GetService("ServerStorage")

local totals = require(ServerStorage.UnitTest.RunUnitTest)()
-- require 返回运行函数，后面的 () 立即执行；零用例不算测试通过。
if totals.run == 0 then
	error("Unit test suite did not discover any cases", 0)
end
if totals.failed > 0 then
	error(string.format("Unit test suite failed: %d of %d cases failed", totals.failed, totals.run), 0)
end
