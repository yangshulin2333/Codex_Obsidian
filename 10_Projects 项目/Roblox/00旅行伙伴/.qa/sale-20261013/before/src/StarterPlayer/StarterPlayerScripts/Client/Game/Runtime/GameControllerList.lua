--!strict

-- 在此显式登记本项目的业务模块；按列表顺序执行 Init 和 Start。
return {
	require(script.Parent.Parent.Controllers.TravelController),
}
