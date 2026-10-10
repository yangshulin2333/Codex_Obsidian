local lnet = require 'lnet'
local sspi = require 'sspi'
local socket = require 'socket'

local pcall = pcall
local error = error
local assert = assert

local session_fd = {}
local token_coroutine = {}


sspi.dispatch(function(token, ...)
	local co = token_coroutine[token]
	token_coroutine[token] = nil
	lnet.wakeup(co, ...)
end)


local function suspend(token)
	token_coroutine[token] = lnet.running()
	return lnet.wait()
end

local function _open()
	local token = sspi.open()
	return suspend(token)
end

local function _hello(ss)
	local token = sspi.hello(ss)
	return assert(suspend(token))
end

local function _handshake(ss, ...)
	local token = sspi.handshake(ss, ...)
	return assert(suspend(token))
end


local function check_fd(ss)
	local fd = session_fd[ss]
	assert(fd, 'security context not exist')
	return fd
end

local function read(fd)
	local data, len = socket.recv(fd, '*')
	if data then
		return data, len
	end
    error(socket.getlasterror(fd))
end

local function do_handshake(fd, ss)
	socket.send(fd, _hello(ss))
	local ok, msg
	while ok ~= 0 do  -- lsspi.cpp #define OPCODE_OK 	0
		ok, msg = _handshake(ss, read(fd))
		if msg then
			socket.send(fd, msg)
		end
	end
end

local function ssl_open(fd)
	local ss, errmsg = _open()
	if not ss then
		return nil, errmsg
	end
	local ok, errmsg = pcall(do_handshake, fd, ss)
	if ok then
		session_fd[ss] = fd
		return ss
	end
	sspi.close(ss)
	return nil, errmsg
end

local function ssl_write(ss, ...)
	local fd = check_fd(ss)
	local data, errmsg = sspi.encrypt(ss, ...)
	if data then
		socket.send(fd, data)
		return true
	end
	return nil, errmsg
end

local function ssl_writefin(ss, ...)
	local fd = check_fd(ss)
	local data, errmsg = sspi.encrypt(ss, ...)
	if data then
		socket.sendfin(fd, data)
		return true
	end
	return nil, errmsg
end

local function ssl_read(ss, required)
	local fd = check_fd(ss)
	local data = sspi.read(ss, required)
	if data then
		return data
	end
	sspi.decrypt(ss, read(fd))
	return ssl_read(ss, required)
end

local function ssl_close(ss)
	local fd = session_fd[ss]
	if fd then
		session_fd[ss] = nil
		sspi.close(ss)
		socket.close(fd)
	end
end


return {
	open = ssl_open,
	read = ssl_read,
	write = ssl_write,
	writefin  = ssl_writefin,
	close = ssl_close
}