local xml = require 'xml'
local json = require 'rapidjson'
local socket = require 'socket'
local dns = require 'dns'
local ssl = require 'ssl'
local utils = require 'http.utils'

local table = table
local string = string
local next = next
local pcall = pcall
local error = error
local assert = assert
local tonumber = tonumber
local setmetatable = setmetatable


local sock_meta = {}
sock_meta.__index = sock_meta

local ssl_meta = {}
ssl_meta.__index = ssl_meta

local body_meta = {}
body_meta.__index = body_meta 

local header_labels = {
    ["content-type"] = function(s)
		return {
			urlencoded = string.find(s, 'urlencoded'),
			charset = string.match(s, 'charset=(%C+)') or 'ansi'
		}
	end,

	["transfer-encoding"] = function(s)
        return string.gsub(s, '%s', '')
	end,

	["content-length"] = function(s)
		return tonumber(s)
	end,
}

----------------------------------
--- http body object
----------------------------------
function body_meta:match(...)
    if not (...) then
        return self.bytes
    end
    return string.match(self.bytes, ...)
end

function body_meta:decode(type)
    if not type then
        return self.bytes

    elseif type == 'json' then
        return json.decode(self.bytes)

    elseif type == 'xml' then
        return xml.decode(self.bytes)
    
    elseif type == 'urlencoded' or type == 'kv' then
        local keyvals = {}
        for k, v in string.gmatch(self.bytes, '([^=&]+)=([^&]+)') do
		    keyvals[k] = utils.decode(v)
        end
        return keyvals
    end

    error('invalid http body type to decode', 0)
end

----------------------------------
--- utility functions
----------------------------------
local function parse_header(line)
    local k, v = string.match(line, '(.-):%s+(.+)')
	if k then
		k = string.lower(k)
		local f = header_labels[k]
		return k, f and f(v) or v
	end
end

local function read_message(fd)
    local header = {}

    -- 收第一行
    local firstline = fd:__read'\r\n'

    -- 分析第一行
    local type = string.match(firstline, '(%w+)')
    if type == 'HTTP' then
        header.code = string.match(firstline, '%s(%d+)%s')
    else
        header.method = string.match(firstline, '([^%s%?]+)', #type+1)
    end

    -- 收包头
    while true do
        local line = fd:__read'\r\n'
        if #line > 0 then
            local k, v = parse_header(line)
            if k then
                header[k] = v
            end
        else
            break
        end
    end

    -- 收包体
    local bytes = ''
    if type == 'GET' then
        bytes = string.match(firstline, '%?(%S+)') or ''

    elseif type == 'POST' or header.code then
        if header['content-length'] then
            bytes = fd:__read(header['content-length'])
        elseif header['transfer-encoding'] == 'chunked' then
            local chunks = {}
            while true do
                local len = fd:__read'\r\n'
                len = tonumber(len, 16)
                assert(len, 'read chunk length failed')
                if len == 0 then
                    break
                end
                local data = fd:__read(len)
                table.insert(chunks, data)
                fd:__read'\r\n'
            end
            bytes = table.concat(chunks)
        end
    end

    return header, setmetatable({ bytes = bytes }, body_meta)
end

local function pread_message(fd)
    local ok, header, body = pcall(read_message, fd)
    if ok then
        return header, body
    end
    return nil, header 
end

----------------------------------
--- socket object
----------------------------------
function sock_meta:__read(required)
    local data = socket.recv(self.fd, required)
    if data then
        return data
    end
    error(socket.getlasterror(self.fd))
end

function sock_meta:read()
    return pread_message(self)
end

function sock_meta:write(data, fin)
    if fin then
        socket.sendfin(self.fd, data)
    else
        socket.send(self.fd, data)
    end
    return true
end

function sock_meta:close()
    socket.close(self.fd)
end

local function sock_open(fd)
    socket.setopt(fd, 'datatype', 1)
    return setmetatable({fd=fd}, sock_meta)
end

local function sock_accept(fd)
    socket.setopt(fd, 'datatype', 1)
    socket.setopt(fd, 'recvtimeout', 30)
    socket.setopt(fd, 'recvqueue', 4*1024*1024)
    return setmetatable({fd=fd}, sock_meta)
end

----------------------------------
--- ssl object
----------------------------------
function ssl_meta:__read(required)
    -- ssl.read will throw exception when reading or decrypting error
    return ssl.read(self.fd, required) 
end

function ssl_meta:read()
    return pread_message(self)
end

function ssl_meta:write(data, fin)
    if fin then
        return ssl.writefin(self.fd, data)
    else
        return ssl.write(self.fd, data)
    end
end

function ssl_meta:close()
    ssl.close(self.fd)
end

local function ssl_open(fd)
    local ssl_fd, errmsg = ssl.open(fd)
    if ssl_fd then
        return setmetatable({fd=ssl_fd}, ssl_meta)
    end
    return nil, errmsg
end

----------------------------------
--- interface
----------------------------------
local function create_connection(fd, ssl)
    if not ssl then
        return sock_open(fd)
    end
    local conn, errmsg = ssl_open(fd)
    if not conn then
        socket.close(fd)
    end
    return conn, errmsg
end

local function open(domain_port, proxy, ti, ssl)
    local domain, port = string.match(domain_port, '(.-):(.+)')
    domain = domain or domain_port
    if not port then
        port = ssl and 443 or 80
    end

    local fd, errmsg
    if proxy then
        fd, errmsg = socket.connect(proxy, ti) 
    else
        local host, dnserr = dns.resolve(domain)
        if not host then
            return nil, dnserr
        end
        fd, errmsg = socket.connect(host..':'..port, ti)
    end

    if not fd then
        return nil, errmsg
    elseif ti then
        socket.setopt(fd, 'recvtimeout', ti)
    end

    if proxy then
        local conn_req = string.format('CONNECT %s:%s HTTP/1.1\r\nUser-Agent: webclient\r\n\r\n', domain, port)
        socket.send(fd, conn_req)
        if not socket.recv(fd, '\r\n\r\n') then
            socket.close(fd)
            return nil, 'wait response from proxy server failed'
        end
    end

    return create_connection(fd, ssl)
end

local function listen(hostport, callback)
    local listenfd = socket.listen(hostport, function(fd)
        local conn = sock_accept(fd)
        local header, body = conn:read()
        if header then
            local resp = callback(header, body)
            conn:write(resp, true)
        end
        conn:close()
    end)
    if listenfd then
        return setmetatable({fd=listenfd}, sock_meta)
    end
end


return {
    open = open,
    listen = listen
}