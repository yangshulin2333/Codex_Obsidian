local os = os
local math = math
local print = print
local error = error
local tonumber = tonumber

-- clib
-- inject following functions into _G.os
-- @now() 
--	return current time in float number
-- @list({path}, .file_type)
--	scan specificed pathes in array
-- @pid()
--	return current process id
-- @spawn(cmd_args, working_dir)
--	launcher new process
-- @unspawn(handle)
--	kill process

require 'lnet.system'

-- time conversion
local key_time = { } 


local next_daytime = function(uth, utm, uts)
	uth = uth or 0
	utm = utm or 0
	uts = uts or 0

	local cur = os.time()
	local key = (uth<<16) | (utm<<8) | uts
	local value = key_time[key]

	if not value or cur > value then
		local tm = os.date'*t'
		tm.hour = uth
		tm.min = utm
		tm.sec = uts
		value = os.time(tm)
		if value <= cur then
			value = value + 86400
		end
		key_time[key] = value
	end

	return value
end

local next_weektime = function(wday, uth, utm, uts)
	wday = wday or 1
	uth = uth or 0
	utm = utm or 0
	uts = uts or 0

	local cur = os.time()
	local key = (wday<<24) | (uth<<16) | (utm<<8) | uts
	local value = key_time[key]

	if not value or cur > value then
		local tm = os.date'*t'
		tm.hour = uth
		tm.min = utm
		tm.sec = uts
		local tag = os.time(tm)
		local isToday = tag > cur
		local omd = isToday and 0 or 1
		local day = math.fmod( (7-(tonumber(os.date'%w') + omd - wday)) , 7 )
		value = next_daytime(uth, utm, uts) + day*86400
		key_time[key] = value
	end

	return value
end

local next_monthtime = function(day, uth, utm, uts)
	day = day or 1
	uth = uth or 0
	utm = utm or 0
	uts = uts or 0

	local now = os.time()
	local key = (day<<32) | (uth<<16) | (utm<<8) | uts
	local value = key_time[key]

	if not value or now > value then
		local t = os.date'*t'
		if t.month == 12 then
			t.year = t.year + 1
			t.month = 1
		else
			t.month = t.month + 1
		end
		t.day = day
		t.hour = uth
		t.min = utm
		t.sec = uts
		value = os.time(t)
		key_time[key] = value
	end

	return value
end

-- get next time
os.nxtime = function(type, ...)
	if type == 'day' then
		return next_daytime(...)
	elseif type == 'week' then
		return next_weektime(...)
	elseif type == 'month' then
		return next_monthtime(...)
	end
	error('invalid time convertion type, "day" or "week" expected', 2)
end

-- test elapsed time during executing f
function profile(f, ...)
	local st = os.now()
	local result = f(...)
	local str = ('elapsed: %.9f'):format(os.now() - st)
	print(str)
	return result
end