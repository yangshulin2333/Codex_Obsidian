--dep: sample                    罗列依赖文件名 以空格或tab分隔 若依赖文件都未发生变化 则跳过当前脚本


-- 引用需要校验的table 遍历每条记录 执行检查
for id, record in pairs(Data.sample) do
	-- 定势
	Start(id) 

	-- 检查到错误 压入错误信息
	if there_is_error then
		Push('错误信息模板: %s', '某某字段未配置')
	end

	-- 定势
	Stop()    
end