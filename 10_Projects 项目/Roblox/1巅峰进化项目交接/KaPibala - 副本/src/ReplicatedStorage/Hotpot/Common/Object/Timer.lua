local _G = _G
local next = next
local pairs = pairs
local ipairs = ipairs
local script = script
local os = os
local math = math
local table = table
--常量
local TIME_STEP = 1000
local MIN_STEP = 1 / TIME_STEP
local hotpot = _G.CommonHotpot
local c = hotpot.class.new(script)
--本地变量
local pool = {}
--本地函数申明
--本地函数定义
---@class Timer
function c.new(time_out_handle)
	return c(time_out_handle)
end
function c:ctor(time_out_handle)
	self.tick = 0
	self.wheel = {}
	self.co_list = {}
	self.time_out_handle = time_out_handle
end
function c:dtor()
	self.wheel = {}
	self.co_list = {}
end
function c:Add(co,time)
	time = time or MIN_STEP
	if time == 0 then
		time = MIN_STEP
	end
	time = self.tick + math.ceil(time * TIME_STEP)
	local wheel = self.wheel
	wheel[time] = wheel[time] or (table.remove(pool) or {})
	local list = wheel[time]
	list[#list+1] = co
	self.co_list[co] = os.clock()
end
function c:Del(co)
	self.co_list[co] = nil
end
function c:Update(step)
	local time = math.ceil(step * TIME_STEP)
	local tick = self.tick
	local wheel = self.wheel
	local co_list = self.co_list
	local time_out_handle = self.time_out_handle
	local now = os.clock()
	self.tick = self.tick + time
	for i = tick,tick + time,1 do
		local list = wheel[i]
		if list then
			for idx = 1,#list,1 do
				local co = list[idx]
				local start_time = co_list[co]
				if start_time then
					co_list[co] = nil
					time_out_handle(co,now - start_time)
				end
				list[idx] = nil
			end
			wheel[i] = nil
			pool[#pool+1] = list
		end
		self.did_tick = i
	end
	return next(wheel)
end
return c