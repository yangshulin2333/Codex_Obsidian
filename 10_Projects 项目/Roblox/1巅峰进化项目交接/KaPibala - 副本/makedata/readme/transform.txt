--dep: sample account dungeon      罗列依赖文件名 以空格或tab分隔 若依赖文件都未发生变化 则跳过当前脚本
--out: sample						可以不指定 缺省用custom脚本的名字作为输出文件的名字



-- 引用依赖的table
local sample = Data.sample
local account = Data.account
local dungeon = Data.dungeon

local result = {}

for key, value in pairs(sample) do
	-- 在这里做一些转换
	-- 将转换后的key, value写入result
end


-- 将保存转换结果的table作为返回值
return result