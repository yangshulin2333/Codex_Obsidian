require 'xtable'
require 'xsystem'

local core = require 'lnet.core'
local seri = require 'lnet.seri'

local load = load
local traceback = debug.traceback
local tremove = table.remove
local coroutine_create = coroutine.create
local coroutine_resume = coroutine.resume
local coroutine_yield = coroutine.yield
local coroutine_running = coroutine.running

local TYPE_CHANNEL = 1
local TYPE_WAKEUP = 2
local TYPE_CONSOLE = 3
local TYPE_TIMEOUT = 4

local _env = {}
local channels = {}
local suspend_coroutine = {}
local timerfd_coroutine = {}
local pooled_coroutine = setmetatable({}, {__mode='kv'})
local channel_id = 0
local console_callback

---------------------------
--- coroutine pool
---------------------------
local function coroutine_return(co, ...)
	pooled_coroutine[#pooled_coroutine+1] = co
	return coroutine_yield(...)
end

local function coroutine_get(f)
	local co = tremove(pooled_coroutine)
	if co then
		coroutine_resume(co, f)
	else
		co = coroutine_create(function()
			while 1 do
				f = coroutine_return(co, f(coroutine_yield()))
			end
		end)
		coroutine_resume(co)
	end
	return co
end

---------------------------
--- utilities
---------------------------
local function coroutine_wakeup(co, ...)
	local ok, errmsg = coroutine_resume(co, ...)
	if not ok then
		errmsg = traceback(co, errmsg)
		core.error(errmsg)
	end
	return ok, errmsg
end

local function coroutine_timer(fd, func)
	while coroutine_yield() and func() do
		core.reset(fd)
		timerfd_coroutine[fd] = coroutine_running()
	end
	core.kill(fd)
end

---------------------------
--- module: lnet
---------------------------
local lnet = {
	coroutine  = coroutine_get,
	wait       = coroutine_yield,
	wakeup     = coroutine_wakeup,
	pack       = seri.pack,
	packstring = seri.packstring,
	binary     = seri.binary,
	unpack     = seri.unpack,
	logmask    = core.logmask,
	info       = core.info,
	warn       = core.warn,
	error      = core.error,
	fatal      = core.fatal,
	tostring   = core.tostring,
	trash      = core.trash,
}

---------------------------
--- C callback handler
---------------------------
local handler = {}

handler[TYPE_CHANNEL] = function(id, ...) 
	local chan = channels[id]
	chan:dispatch(lnet.unpack(...))
end

handler[TYPE_WAKEUP] = function()
	for idx=1, #suspend_coroutine do
		local co = suspend_coroutine[idx] 
		suspend_coroutine[idx] = nil
		coroutine_wakeup(co)
	end
end

handler[TYPE_CONSOLE] = function(_, ...) 
	if console_callback then
		lnet.fork(console_callback, ...)
	else
		local chunk, errmsg = load(...)
		if not chunk then
			lnet.error('console.compile', errmsg)
			return
		end
		lnet.fork(chunk)
	end
end

handler[TYPE_TIMEOUT] = function(fd) 
	local co = timerfd_coroutine[fd]
	timerfd_coroutine[fd] = nil
	coroutine_wakeup(co, 'TIMEOUT')
end

core.dispatch(function(type, session, ...)
	handler[type](session, ...)
end)

---------------------------
--- channel
---------------------------
local channel_meta = {}

function channel_meta:add(cb)
	local callback = self.callback
	callback[#callback+1] = cb
end

function channel_meta:dispatch(...)
	for _, cb in pairs(self.callback) do
		lnet.fork(cb, ...)
	end
end

local function channel_create()
	local id = channel_id + 1
	channel_id = id

	return setmetatable({
		id = id,
		callback = {}
	}, {
		__index = channel_meta
	})
end

---------------------------
--- interface
---------------------------
function lnet.init()
end

function lnet.is_release()
	return (lnet.env'mode' == 'release')
end

function lnet.urgent(subject, content)
	local smtp = require 'smtp'
    lnet.fork(smtp.send, {
        server = 'smtp.163.com',
        username = 'bitmaze_global@163.com',
        password = 'IBONSOIMIZFQDRZR',
        receiver = 'bitmaze_global@163.com',
        subject = subject,
        content = content,
    })
end

function lnet.env(key)
	if key == '*' then
		return _env
	end
	local value = _env[key] or os.parse(key)
	_env[key] = value
	return value
end

function lnet.setenv(key, value)
	assert(key ~= '*', '* can not be used as key')
	_env[key] = value
end

function lnet.fork(f, ...)
	local co = coroutine_get(f)
	local ok, errmsg = coroutine_wakeup(co, ...)
	if ok then
		return co
	end
	return false, errmsg
end

function lnet.running()
	local co = coroutine_running()
	return co
end

function lnet.yield()
	if #suspend_coroutine == 0 then
		core.send(TYPE_WAKEUP, 0)
	end
	suspend_coroutine[#suspend_coroutine+1] = coroutine_running()
	coroutine_yield()
end

function lnet.sleep(ti, fallthrough)
	local fd = core.timeout(ti)
	timerfd_coroutine[fd] = coroutine_running()
	if not fallthrough then
		coroutine_yield()
		core.kill(fd)
	end
	return fd
end

function lnet.timeout(ti, func)
	local fd = core.timeout(ti)
	local co = coroutine_get(coroutine_timer)
	timerfd_coroutine[fd] = co
	coroutine_resume(co, fd, func)
	return fd
end

function lnet.kill(fd)
	local co = timerfd_coroutine[fd]
	if co then
		core.kill(fd)
		timerfd_coroutine[fd] = nil
	end
end

function lnet.subscribe(topic, callback)
	local chan = channels[topic]
	if not chan then
		chan = channel_create()
		channels[topic] = chan
		channels[chan.id] = chan
	end
	chan:add(callback)
end

function lnet.publish(topic, ...)
	local chan = channels[topic]
	if chan then
		core.send(TYPE_CHANNEL, chan.id, lnet.packstring(...))
	end
end

function lnet.console(cb)
	console_callback = cb
end

return lnet