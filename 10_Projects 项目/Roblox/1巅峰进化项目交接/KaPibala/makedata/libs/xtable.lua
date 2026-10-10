local type    = type
local next    = next
local pairs   = pairs
local select  = select
local table   = table
local tremove = table.remove
local random = math.random
local setmetatable = setmetatable
local getmetatable = getmetatable


local meta_hotfix = {}
local meta_default = {
	__index = function(t, key)
		local nesting = {}
		t[key] = nesting
		return nesting
	end
}

local meta_reserve = {}
meta_reserve.__index = meta_reserve

function meta_reserve:get()
	local ptr = self.ptr + 1
	if ptr > self.cap then
		ptr = 1
	end
	self.ptr = ptr
	return self.cache[ptr]
end


local function clone(src)
	local dst = {}
	for key, value in pairs(src) do
		if type(value) ~= 'table' then
			dst[key] = value
		else
			dst[key] = clone(value)
		end
	end
	return dst
end


-------------------------------
---	extend interface for table
-------------------------------
function table.default()
	return setmetatable({}, meta_default)
end

function table.hotfix()
	return setmetatable({}, meta_hotfix)
end

function table.ishotfix(t)
	return (getmetatable(t) == meta_hotfix)
end

function table.reserve(capacity)
	return setmetatable({
		ptr = 0,
		cap = capacity,
		cache = table.default()
	}, meta_reserve)
end

function table.cache(f, mode)
	return setmetatable({}, {__index=f, __mode=mode})
end

function table.copy(dst, src, filter)
	if type(src) ~= 'table' then
        filter = src
        src = dst
        dst = {}
    end
	if not filter then
		for key, value in pairs(src) do
			dst[key] = value
		end
	else
		for key, value in pairs(src) do
			key, value = filter(key, value)
			dst[key] = value or true
		end
	end
	return dst
end

function table.clone(src)
	return clone(src)
end

function table.append(list, ...)
	for idx=1, select('#', ...) do
		list[#list+1] = select(idx, ...)
	end
	return list
end

function table.rep(value, rep, ...)
	local retval = {}
	if type(value) == 'function' then
		for idx=1, rep do
			retval[idx] = value(...)
		end
	else
		for idx=1, rep do
			retval[idx] = value
		end
	end
	return retval
end

function table.slice(t, gap)
	local retval ={}
	for idx=1, #t, gap do
		retval[#retval+1] = { 
			table.unpack(t, idx, idx+gap-1)
		}
	end
	return retval
end

function table.clear(t, is_array)
	if is_array then
		for idx=1, #t do
			t[idx] = nil
		end
	else
		for key in pairs(t) do
			t[key] = nil
		end
	end
	return t
end

function table.remove_if(list, filter, ...)
	for idx=1, #list do
		local value = list[idx]
		if filter(value, ...) then 
			return tremove(list, idx) 
		end
	end
end

function table.find(list, target)
	if type(target) == 'function' then
		for idx=1, #list do
			local value = list[idx]
			if target(value) then
				return idx
			end
		end
	else
		for idx=1, #list do
			local value = list[idx]
			if value == target then 
				return idx 
			end
		end
	end
end

function table.foreach(t, func)
	for key, value in pairs(t) do
		func(key, value)
	end
	return t
end

function table.count(t)
	local n = 0
	for _, _ in pairs(t) do
		n = n + 1
	end
	return n
end

function table.keys(t)
	local list = {}
	for key in pairs(t) do
		list[#list+1] = key
	end
	return list
end

function table.values(t)
	local list = {}
	for _, value in pairs(t) do
		list[#list+1] = value
	end
	return list
end

function table.swap(t, a, b)
	t[a], t[b] = t[b], t[a]
end

function table.shuffle(t)
	local len = #t
	for idx=1, len do
		local pos = random(len)
		t[idx], t[pos] = t[pos], t[idx]
	end
	return t
end

function table.dump(tb, dump_metatable, max_level)
    local lookup_table = {}
    local level = 0
    local rep = string.rep
    local dump_metatable = dump_metatable
	local max_level = max_level or 5
	
	if not next(tb) then
		return "{ }"
	end

    local function _dump(tb, level)
        local str = "\n" .. rep("\t", level) .. "{\n"
        for k,v in pairs(tb) do
            local k_is_str = type(k) == "string" and 1 or 0
            local v_is_str = type(v) == "string" and 1 or 0
            str = str..rep("\t", level + 1).."["..rep("\"", k_is_str)..(tostring(k) or type(k))..rep("\"", k_is_str).."]".." = "
            if type(v) == "table" then
                if not lookup_table[v] and ((not max_level) or level < max_level) then
					lookup_table[v] = true
					if next(v) then
						str = str.._dump(v, level + 1, dump_metatable).."\n"
					else
						str = str.."{ }".."\n"
					end
				else
					if next(v) then
						str = str..(tostring(v) or type(v))..",\n"
					else
						str = str.."{ }"..",\n"
					end
                end
            else
                str = str..rep("\"", v_is_str)..(tostring(v) or type(v))..rep("\"", v_is_str)..",\n"
            end
        end
        if dump_metatable then
            local mt = getmetatable(tb)
            if mt ~= nil and type(mt) == "table" then
                str = str..rep("\t", level + 1).."[\"__metatable\"]".." = "
                if not lookup_table[mt] and ((not max_level) or level < max_level) then
                    lookup_table[mt] = true
                    str = str.._dump(mt, level + 1, dump_metatable).."\n"
                else
                    str = str..(tostring(v) or type(v))..",\n"
                end
            end
        end
        str = str..rep("\t", level) .. "},"
        return str
    end

    return _dump(tb, level)
end

function table.project(tb)
	local result = {}
	for k, v in pairs(tb) do
		result[v] = k
	end
	return result
end

function table.intersection(a, b)
	local result = {}
	for k in pairs(a) do
		if b[k] then
			result[k] = true
		end
	end
	return result
end

return table