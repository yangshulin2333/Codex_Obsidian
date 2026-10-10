local fsystem = require 'fsystem'

local os = os
local table = table
local string = string
local next = next
local dofile = dofile

local REDIRECT_PREFIX = '__REDIRECT_'
local RECORDS_PER_FILE = 10

local INIT_SCRIPT_TEMPLATE = [[
local module = {}
	for __,cfg in ipairs(script:GetChildren()) do
		if cfg.ClassName == "ModuleScript" then
			local tab = require(cfg)
			for i,v in pairs(tab) do
				module[i] = v
			end
		end
	end
	return module
]]


local function is_redirect_file(path)
	return string.find(path, REDIRECT_PREFIX)
end

local function list_tempdir()
	local result = {}
	for _, path in next, fsystem.dir.list'TEMP' do
		if not is_redirect_file(path) then
			table.insert(result, path)
		end
	end
	return result
end

local function finalize(srcpath, dstpath)
	local batches = { {} }
	local amount = 0
	for k, v in next, dofile(srcpath) do
		batches[#batches][k] = v
		amount = amount + 1
		if amount == RECORDS_PER_FILE then
			amount = 0
			batches[#batches+1] = {}
		end
	end

	for i=1, #batches do
		local fn = string.format('%s/%s.lua', dstpath, i)
		fsystem.file.write(fn, 'return ', batches[i])
	end

	local path = string.format('%s/init.lua', dstpath)
	fsystem.file.write(path, INIT_SCRIPT_TEMPLATE)
end

local function exec(dstpath, mldstpath)
	for _, srcpath in next, list_tempdir() do
		local name = fsystem.file.name(srcpath)
		local outpath = dstpath
		if name == 'Localization' then
			outpath = mldstpath
		end
		fsystem.dir.make(outpath, name)
		fsystem.dir.clear(outpath, name)
		finalize(srcpath, string.format('%s/%s', outpath, name))
	end  

	os.exit()
end

return {
	exec = exec
}