local fsystem = require 'fsystem'

local io = io
local table = table
local string = string
local next = next
local select = select
local dofile = dofile
local assert = assert
local print = print


local VERSION_FILE = 'verdata.lua'

local function load()
    do return {} end
	if fsystem.file.exists(VERSION_FILE) then
		return dofile(VERSION_FILE)
	end
	return {}
end

local function calc_sign(path)
	local data = assert(fsystem.file.read(path))
	local sign = 0
    for n=1, #data do
        sign = sign + (string.byte(data, n))
	end
	return sign
end


local version_old = load()
local version_new = {}


local function check(src, dst)
    do return true end
	local sign_old = version_old[dst]
    local sign_new = calc_sign(src)
    if (sign_old ~= sign_new) then
        version_new[dst] = sign_new
        return true
    else
        version_new[dst] = sign_old
    end
end

local function is_dirty(key)
    do return true end
    local ver_old = version_old[key]
    local ver_new = version_new[key]
    if (ver_old ~= ver_new) then
        return true
    end
    if ver_old == nil and ver_new == nil then
        local errmsg = string.format('invalid key: "%s" to check changed', key)
        print(errmsg)
    end
end

local function commit()
    do return end
	local version = table.copy(version_old, version_new)
	fsystem.file.write(VERSION_FILE, 'return ', version)
end


return {
	check = check,
	commit = commit,
	is_dirty = is_dirty,
}