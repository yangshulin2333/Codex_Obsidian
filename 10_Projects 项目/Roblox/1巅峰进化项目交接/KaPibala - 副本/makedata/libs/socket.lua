local lnet = require 'lnet'
local driver = require 'lnet.sockdriver'

local error = error
local traceback = debug.traceback
local coroutine_create = lnet.coroutine
local coroutine_wakeup = lnet.wakeup
local coroutine_yield = coroutine.yield
local coroutine_running = coroutine.running

local TYPE_ACCEPT = 1
local TYPE_CONNECT = 2
local TYPE_DATA = 3

local socket_context  = {}
local brdcst_context = {}
local socket_handler = {}
local tcp_status = {}
local udp_status = {}

----------------------------
--- C callback handler
----------------------------
socket_handler[TYPE_ACCEPT] = function(listenfd, clientfd)
    local co = coroutine_create(socket_context[listenfd])
    local ok = coroutine_wakeup(co, clientfd)
    if not ok then
        driver.close(clientfd)
	end
end

socket_handler[TYPE_CONNECT] = function(fd, succ)
    local co = socket_context[fd]
    socket_context[fd] = nil
    local ok = coroutine_wakeup(co, succ) 
    if not succ or not ok then
        driver.close(fd)
    end
end

socket_handler[TYPE_DATA] = function(fd, ...)
	local co = socket_context[fd]
	local ok = coroutine_wakeup(co, ...)
    if not ok then
        driver.close(fd)
	end
end

driver.dispatch(function(type, ...)
	socket_handler[type](...)
end)

----------------------
-- interface
----------------------
local socket = {}
socket.check = driver.check
socket.setopt = driver.setopt
socket.send = driver.send
socket.sendfin = driver.sendfin
socket.sendto = driver.sendto
socket.broadcast = driver.broadcast
socket.name = driver.name
socket.getlasterror = driver.getlasterror
socket.closefd = driver.closefd

function socket.listen(hostport, callback)
    local fd = driver.listen(hostport)
    if fd then
    	socket_context[fd] = callback
        return fd
    end
end

function socket.connect(hostport, ti)
    local fd = driver.connect(hostport, ti)
    if fd then
        socket_context[fd] = coroutine_running()
        if coroutine_yield() then
            return fd
        end
        return nil, driver.getlasterror(fd)
    end
    return nil, 'out of context'
end

function socket.udp(hostport)
    local fd = driver.udp(hostport)
    if fd then
        return fd
    end
end

function socket.gethost(type)
    if type == 'dns' then
        return driver.dnshost()
    elseif type == 'lan' then
        return driver.localhost()
    elseif type == 'wan' then
        local http = require 'http.client'
    	for try = 1, 15 do
    		local ok, body = http.call'http://pv.sohu.com/cityjson'
    		if ok then
                return body:match'(%d+.%d+.%d+.%d+)'
    		end
   			lnet.sleep(1)
        end
        error'get wan address failed'
    end
    error'invalid host type'
end

function socket.recv(fd, mode)
    local buffer, length = driver.recv(fd, mode)
    if buffer then
        return buffer, length
    end
    socket_context[fd] = coroutine_running()
    if coroutine_yield() then
        return socket.recv(fd, mode)
    end
end

function socket.recvfrom(fd)
    driver.recvfrom(fd)
    socket_context[fd] = coroutine_running()
    return coroutine_yield()
end

function socket.status(type)
    local tcp_fds
            , udp_fds
            , tcp_bytes_read
            , tcp_bytes_sent
            , udp_bytes_read
            , udp_bytes_sent = driver.status()

    tcp_status.fds = tcp_fds
    tcp_status.nread = tcp_bytes_read
    tcp_status.nsent = tcp_bytes_sent
    udp_status.fds = udp_fds
    udp_status.nread = udp_bytes_read
    udp_status.nsent = udp_bytes_sent

    return type == 'tcp' and tcp_status or udp_status
end

function socket.close(fd)
    driver.close(fd)
    socket_context[fd] = nil
end

return socket