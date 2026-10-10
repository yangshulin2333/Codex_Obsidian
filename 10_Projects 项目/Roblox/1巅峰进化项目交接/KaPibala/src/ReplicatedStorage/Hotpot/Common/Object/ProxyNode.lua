local table = table
local string = string
local type = type
local next = next
local ipairs = ipairs
local assert = assert
local setmetatable = setmetatable
local getmetatable = getmetatable
local tostring = tostring
local error = error
local _G = _G
local hotpot = _G.CommonHotpot

local NULL = {}

local path_cache = setmetatable({}, { __mode = 'kv', __index = function(left, lkey)
    local right = setmetatable({}, { __mode = 'kv', __index = function(right, rkey)
        local fmt = (lkey ~= '') and '%s.%s' or '%s%s'
        local path = string.format(fmt, lkey, rkey)
		right[rkey] = path
		return path
    end})
    left[lkey] = right
	return right
end})


-----------------------------
--- utilities
-----------------------------
local function is_visible(node)
    if node.__father == false then
        return true
    end
    local changes = node.__father.__changes
    if changes and changes[node.__key] ~= nil then
        return false
    end
    return is_visible(node.__father)
end

local function build_path(node)
	local list = {}
	while node.__father do
		table.insert(list, 1, node.__key)
		node = node.__father
	end
	return table.concat(list, '.')
end

local function dump_pair(path, value)
    if type(value) == 'table' then
        return string.format('[%s] = %s', path, hotpot.dump(value,false,16))
    else
        return string.format('%s = %s', path, tostring(value))
    end
end

local function check_pair(key, value)
	if type(key) ~= 'string' and type(key) ~= 'number' then
		error("proxy node: key必须是string or number")
	end

	if type(key) == 'string' then
		if key == '' then
			error("proxy node: 空字符串不能作为key")
		end
		if string.find(key, '%s') then
			error("proxy node: key包含空白字符")
		end
	end

	local valtype = type(value)
	assert(valtype ~= 'userdata' and valtype ~= 'thread' and valtype ~= 'function'
		, 'proxy node: value必须是string or number or table or boolean')

	if valtype == "table" then
		assert(not getmetatable(value), "proxy node: 带有元表的表不可用于赋值")
		for k, v in next, value, nil do
			check_pair(k, v)
		end
	end
end

local function do_revert(changes, real)
	for key, oldval in next, changes do
		if oldval == NULL then
			oldval = nil
		end
		real[key] = oldval
	end
end

-----------------------------
--- proxy node direct funcs
-----------------------------
local function node_iter(self, k)
	k = next(self.__real, k)
	return k, self[k]
end

local function node_pairs(self, on_real)
	if on_real then
		return next, self.__real, nil
	end
	return node_iter, self, nil
end

local function node_ipairs(self, on_real)
	return node_pairs(self, on_real)
end

local function node_len(self)
	return #self.__real
end

local function node_isdirty(self)
	return self.__dirty.yes
end

local function node_clean(self)
	self.__dirty.yes = false
end

local function node_revert(root)
	for real, child in next, root.__accessed do
        local changes = child.__changes
		if changes then
			do_revert(changes, real)
            child.__changes = false
        end
        root.__accessed[real] = nil
    end
end

local function node_update(root)
	local accessed = root.__accessed
	for real, child in next, accessed do
		child.__changes = false
		accessed[real] = nil
	end
end

local function node_log(root)
	local buffer = {}
	local accessed = root.__accessed
	for _, node in next, accessed do
        local changes = node.__changes
        if changes and is_visible(node) then
            local path = build_path(node)
            local real = node.__real
            for key in next, changes do
                table.insert(buffer, dump_pair(path_cache[path][key], real[key]))
            end
        end
    end

    if #buffer > 0 then
        return table.concat(buffer, '\n')
    end
end

local function node_ref(self)
	local cached = self.__cached
	local node = self
	while node do
		cached[node.__real] = node
		node = node.__father
	end
	return self
end

local function node_unref(self)
	self.__cached[self.__real] = nil
end

-----------------------------
--- proxy node metatable
-----------------------------
local node_meta = {}

local function __wrap(real, father, key, cached, accessed, dirty)
	return setmetatable({
		__father = father,
		__key = key,
		__real = real,
		__cached = cached,          -- tree共享 稳定node表
		__accessed = accessed,      -- tree共享 update前 被访问过的node
		__dirty = dirty,            -- tree共享 脏标记
		__changes = false,          -- node私有 update前 被改写过的key所对应的初值

		-- 直接成员函数
		Ref = node_ref,
		Unref = node_unref,
		Pairs = node_pairs,
		Ipairs = node_ipairs,
		Len = node_len,
		Isdirty = node_isdirty,
		Clean = node_clean,
		Revert = node_revert,
		Update = node_update,
		Log = node_log,
	}
	, node_meta)
end

function node_meta:__index(key)
	local value = self.__real[key]
	if type(value) ~= 'table' then
		return value
	end

	local child = self.__accessed[value] or self.__cached[value]
	if not child then
		child = __wrap(value, self, key, self.__cached, self.__accessed, self.__dirty)
		self.__accessed[value] = child
	end

	return child
end

function node_meta:__newindex(key, value)
	check_pair(key, value)

	local real = self.__real
	local changes = self.__changes
	if not changes then
		changes = {}
		self.__changes = changes
		self.__accessed[real] = self
		self.__dirty.yes = true
	end

	if changes[key] == nil then
		local oldval = real[key]
		if oldval == nil then
			oldval = NULL
		end
		changes[key] = oldval
	end

	real[key] = value
end

--------------------------------------
--- emmylua comment
--------------------------------------
---@class ProxyNode
---@field __real table real版本的table
local c = {}

--- 创建节点引用
--- 注意：必须保证 从根节点到创建引用的节点 整条路经上所有中间节点 都是“稳定的”
---            所谓稳定的 指若key对应的value是个table 那么不能用nil, table对key重新赋值
function c:Ref() end
function c:Update() end
--- 解除节点引用
function c:Unref() end

---@param on_real boolean 
--- 取值说明
--- nil:   value是table时 返回代理节点 默认为nil
--- true: value是table时 返回real版本 
function c:Pairs(on_real) end

---@param on_real boolean 同Pairs
function c:Ipairs(on_real) end

--- 取长度
function c:Len() end

--- 是否有变更
function c:Isdirty() end

--- 清除变更标记
function c:Clean() end

--- 回滚
function c:Revert() end

--- 返回变动日志
--- 	nil代表没有日志 否则为日志string
function c:Log() end

-----------------------------
--- interfaces
-----------------------------

return {
	new = function(real)
		---@type ProxyNode
		local root = __wrap(real, false, '', {}, {}, {})
		return root
	end,
}