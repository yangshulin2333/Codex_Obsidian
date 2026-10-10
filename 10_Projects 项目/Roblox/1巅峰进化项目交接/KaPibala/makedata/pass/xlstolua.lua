local fsystem = require 'fsystem'
local parser = require 'parser'
local version = require 'version'
local multlang = require 'multlang'

local os = os
local io = io
local table = table
local string = string
local debug = debug
local type = type
local next = next
local xpcall = xpcall
local assert = assert
local dofile = dofile
local tonumber = tonumber
local setmetatable = setmetatable
local print = print


local empty = {}

local function make_cache(f)
	return setmetatable({}, {__index = f})
end

-- n-tuple capture pattern. seperator in content must be "," or ";"
local capture_cache = make_cache(function(t, n)
	local buffer = {}
	for idx=1, n do
		buffer[#buffer+1] = '([^,;]+)'
	end
	local pattern = table.concat(buffer, '.')
	t[n] = pattern
	return pattern
end)

local indent_cache = make_cache(function(t, n)
	local indent = string.rep('\t', n)
	t[n] = indent
	return indent
end)

local format_cache = make_cache(function(t, depth)
	local indent = indent_cache[depth]
	t[depth] = make_cache(function(t, base_fmt)
		local final_fmt = indent .. base_fmt .. ','
		t[base_fmt] = final_fmt
		return final_fmt
	end)
	return t[depth]
end)

-- field convertor funcs
local field_conv = {}

field_conv['$raw'] = function(value)
	return value
end

field_conv['$array'] = function(value)
	return string.format('{%s}', value)
end

field_conv['$struct'] = function(value, rule, depth)
	local c_patt = capture_cache[rule.n]
	local f_patt = format_cache[depth+1][rule.f]
	local buffer = {}

	string.gsub(value, c_patt, function(...)
		buffer[#buffer+1] = string.format(f_patt, ...)
	end)

	table.insert(buffer, 1, '{')
	table.insert(buffer, indent_cache[depth] .. '}')
	return table.concat(buffer, '\n')
end

field_conv['$weight'] = function(value, rule, depth)
	local c_patt = capture_cache[rule.n]
	local f_patt = format_cache[depth+1][rule.f]

	local g = 0
	local buffer = {}

	-- constraint: last one of ... must be weight value
	string.gsub(value, c_patt, function(...)
		local args = {...}
		g = g + tonumber(table.remove(args))
		args[#args+1] = g
		buffer[#buffer+1] = string.format(f_patt, table.unpack(args))
	end)

	table.insert(buffer, 1, '{')
	table.insert(buffer, indent_cache[depth] .. '}')
	return table.concat(buffer, '\n')
end

---------------------------------
-- utilities
---------------------------------
local function dump_field(value, rule, depth)
	local func = field_conv[rule] or field_conv[rule.type]
	assert(func, 'invalid field convertor rule')
	return func(value, rule, depth)
end

local function dump(id, row, desc)
	local depth = 2
	if desc.unique then
		depth = 1
	end

	-- field formatting pattern
	local indent = indent_cache[depth]
	local direct = indent .. '%s=%s,'
	local quote = indent .. '%s=%q,'

	local buffer = {}
	local rules = desc.conv or empty

	-- there are two situations if value type is string:
	-- 1 value is a field need to be converted with customize rule
	-- 2 value is a pure string
	for key, value in next, row do
		local fmt = direct
		local rule = rules[key]
		if rule then
			value = dump_field(value, rule, depth)
		elseif type(value) == 'string' then
			fmt = quote
		end
		table.insert(buffer, string.format(fmt, key, value))
	end

	-- formatting row(record)
	if desc.unique then
		table.insert(buffer, '')
	else
		local record_head = '\t[%s]={'
		if type(id) == 'string' then
			record_head = '\t[%q]={'
		end
		table.insert(buffer, 1, string.format(record_head, id))
		table.insert(buffer,  '\t},\n')
	end

	return table.concat(buffer, '\n')
end

local function clip(row, fields)
	-- 全量保留
	if fields == '*' then
		return row

	-- 排除指定
	elseif fields.exclude then
		for idx=1, #fields do
			local field = fields[idx]
			row[field] = nil
		end

		return row
	end

	-- 保留指定
	local retval = {}
	for idx=1, #fields do
		local field = fields[idx]
		retval[field] = row[field]
	end

	return retval
end

local function export(srcfile, dstfile, desc)
	-- 调用xlsreader 转换器 将xls文件转换为粗略的lua源文件
	-- 粗略是指 除明确声明的number, string类型外的其他字段 以string类型暂存 留待下阶段执行自定义转换
	local tmpfile = 'temp.lua'
	local cmd = string.format('libs\\xlsreader --source %s --output %s', srcfile, tmpfile)
	assert(os.execute(cmd))
	
	-- 载入粗略文件
    local data = dofile(tmpfile)
    os.remove(tmpfile)

	-- 裁剪字段 并对每条记录的某些字段应用自定义转换规则
	local f = io.open(dstfile, 'w+')
	f:write('return {\n')
	for id, row in next, data do
		multlang.update(desc.name, id, row, desc.multlang)
		row = clip(row, desc.cols)
		f:write(dump(id, row, desc))
	end
	f:write('}\n')
	f:close()
end

---------------------------------
-- interface
---------------------------------
local function exec(xlspath)
	multlang.load(xlspath)

	local descriptors = {}
	for _, path in next, fsystem.dir.list'DESC' do
		table.copy(descriptors, parser.descriptor(path))
	end

	for xlsname, desc in next, descriptors do
		local xlsfile = string.format('%s/%s.xlsx', xlspath, xlsname)
		local luafile = fsystem.dir.temp(desc.out)
		if version.check(xlsfile, desc.out) then
			print('exporting...', xlsfile)
			local ok, err = xpcall(export, debug.traceback, xlsfile, luafile, desc)
			assert(ok, err)
		end
	end

	-- 写回主字典
	multlang.save(xlspath)

	-- 导出多语言lua表
	multlang.localization_export()
end

return {
	exec = exec
}