local lnet = require 'lnet'
local fsystem = require 'fsystem'
local translate = require 'translate'

local io = io
local os = os
local table = table
local string = string
local dofile = dofile
local pairs = pairs
local ipairs = ipairs
local error = error
local assert = assert

local DICT_MAIN_FILE = 'DictMain.xlsx'          			-- 主字典excel文件名
local DICT_EXTEND_FILE = 'DictExtend.xlsx'    			-- 扩展字典excel文件名
local DICT_TRANSLATE_FILE = 'DictTranslate.xlsx'     -- 翻译交回的 包含新翻译内容的excel文件名
local LOCALIZATION_FILE = 'Localization'       			-- 多语言lua表文件名

local SEP_ROW = '$ROW$'
local SEP_FIELD = '$FIELD$'
local EMPTY = {}

local DICT_TITLE = {'key', '备注','英文','日文','韩文','繁体','德语','西班牙语','法语','葡萄牙语','保加利亚语','捷克语','丹麦语','希腊语','爱沙尼亚语','芬兰语','匈牙利语','荷兰语','波兰语','罗马尼亚语','俄语','斯洛文尼亚语','瑞典语','泰语','越南语' }
local DICT_FIELDS = { 'key', 'remark','en','ja','ko','zh-hant','de','es','fr','pt','bg','cs-cz','da-dk','el','et','fi','hu','nl','pl','ro','ru','sl','sv','th','vi'} -- 字典文件包含的所有字段
local DICT_TYPES = table.rep('string', #DICT_FIELDS)
local DICT_MULTLANGS = { en = 1, ja = 1, ko = 1, ['zh-hant'] = 1, ["de"] = 1,["es"] = 1,	["fr"] = 1,	["pt"] = 1,	["bg"] = 1,	["cs"] = 1,	["da"] = 1,	["el"] = 1,	["et"] = 1,	["fi"] = 1,	["hu"] = 1,	["nl"] = 1,	["pl"] = 1,	["ro"] = 1,	["ru"] = 1,	["sl"] = 1,	["sv"] = 1,	["th"] = 1,	["vi"] = 1} -- 字典文件中 属于多语言的字段名

local key_zh = {}          -- 多语言key到中文文本的映射
local dict_main = {}     -- 主字典 key为中文
local dict_extend = {}  -- 扩展字典 key为多语言键
local dict_translate = {} -- 翻译交回的字典 key为中文

local dict_main_dirty


local function gen_ifrow(tb)
	return table.concat(tb, SEP_FIELD) .. SEP_ROW
end

local function read_excel(path, filename)
	path = string.format('%s/%s', path, filename)
	if fsystem.file.exists(path) then
		local tmpfile = 'temp.lua'
		local cmd = string.format('libs\\xlsreader --source %s --output %s', path, tmpfile)
		assert(os.execute(cmd))
		local data = dofile(tmpfile)
		os.remove(tmpfile)
		return data
	end
	return {}
end

local function write_excel(tmpfile, dstpath, dstfile)
	local cmd = string.format('libs\\xlswriter --source %s --output %s/%s --seprow %s --sepfield %s', tmpfile, dstpath, dstfile, SEP_ROW, SEP_FIELD)
	assert(os.execute(cmd))
	os.remove(tmpfile)
end

local function record_to_row(record)
	local row = {}
	local incomplete
	for i, field in ipairs(DICT_FIELDS) do
		row[#row+1] = record[field] or ''
		if DICT_MULTLANGS[field] and not record[field] then
			incomplete = true
		end
	end
	return row, incomplete
end

local function write_dict(dstpath, dstfile, dict, check_incomplete)
	local buffer = { gen_ifrow(DICT_TITLE), gen_ifrow(DICT_FIELDS), gen_ifrow(DICT_TYPES) }
	for _, record in pairs(dict) do
		local row, incomplete = record_to_row(record)
		if not check_incomplete or incomplete then
			buffer[#buffer+1] = gen_ifrow(row)
		end
	end
	local tmpfile = 'dict.if'
	fsystem.file.write(tmpfile, table.concat(buffer))
	write_excel(tmpfile, dstpath, dstfile)
end

local function update(key, zh)
	if key_zh[key] and key_zh[key] ~= zh then
		local err = string.format('key %q repeated with different zh content', key)
		error(err, 0)
	end

	key_zh[key] = zh
	if not dict_main[zh] then
		dict_main[zh] = { key = zh }
		dict_main_dirty = true
	end
end

local function append_space(str, width)
	width = width or 0
	local nspace = width - #str
	if nspace > 0 then
		return str .. string.rep(' ', nspace)
	end
	return str
end

local function translate_record(idx, zh, record)
	local title = string.sub(record.key, 1, 32)
	local log = string.format('KEY(%05s): %q ', idx, title)
	io.write(append_space(log, 48))

	local n = 0
	for lang in pairs(DICT_MULTLANGS) do
		if not record[lang] then
			io.write(' ', lang)
			local result = translate.exec('baidu', zh, lang)
			if result then
				record[lang] = result
			else
				io.write('(E)')
			end
			-- n = n + 1
			-- if n == 10 then
			-- 	lnet.sleep(1.1)
			-- 	n = 0
			-- end
			lnet.sleep(1.1)
		end
	end

	print()
end


local M = {}

function M.load(path)
	dict_main = read_excel(path, DICT_MAIN_FILE)
	dict_extend = read_excel(path, DICT_EXTEND_FILE)
	dict_translate = read_excel(path, DICT_TRANSLATE_FILE)
end

function M.update(xlsname, id, row, fields)
	if not fields then
		return
	end
	for _, field in ipairs(fields) do
		local zh = row[field]
		if zh then
			local key = string.format('%s_%s_%s', xlsname, id, field)
			row[field] = key -- 将中文文本替换为key
			update(key, zh) -- 插入条目
		end
	end
end

function M.save(path, forcely)
	if dict_main_dirty or forcely then
		write_dict(path, DICT_MAIN_FILE, dict_main)
	end
end

function M.localization_export()
	-- 按roblox格式输出多语言表
	local buffer = {}
	for key, zh in pairs(key_zh) do
		local record = {
			Key = key,
			Context = "",
			Example = "",
			Source = zh,
			Values = { ['zh-cn'] = zh,['zh-hans'] = zh },
		}
		table.copy(record.Values, dict_main[zh])
		table.copy(record.Values, dict_extend[key] or EMPTY)
		buffer[#buffer+1] = record
	end

	local path = fsystem.dir.temp(LOCALIZATION_FILE)
	fsystem.file.write(path, 'return ', buffer)
end

function M.translation_export(path)
	M.load(path)
	write_dict(path, DICT_TRANSLATE_FILE, dict_main, true)
end

function M.translation_merge(path)
	M.load(path)
	local warnings = {}
	local n = 0
	for zh, record_new in pairs(dict_translate) do
		local record_old = dict_main[zh]
		if record_old then
			n = n + 1
			table.copy(record_old, record_new)
		else
			warnings[#warnings+1] = string.format('record not exist in DictMain which key is: %q', string.sub(zh, 1, 64))
		end
	end
	print('DictTranslate => DictMain done')
	print('SUCCEED: ', n)
	if #warnings > 0 then
		print('WARNING:', #warnings)
		print(table.concat(warnings,'\n'))
	end
	M.save(path, true)
end

function M.translation_pull(path)
	local dict_xls = string.format('%s/%s', path, DICT_TRANSLATE_FILE)
	if not fsystem.file.exists(dict_xls) then
		M.translation_export(path)
	end
	local idx = 0
	local dict = read_excel(path, DICT_TRANSLATE_FILE)
	for zh, record in pairs(dict) do
		idx = idx + 1
		translate_record(idx, zh, record)
	end
	write_dict(path, DICT_TRANSLATE_FILE, dict)
end

return M
