--[[
-- struct header {
--  uint16_t tid     # identifier assigned by the program that generates any kind of query.
--  uint16_t flags   # flags
--  uint16_t qdcount # the number of entries in the question section.
--  uint16_t ancount # the number of resource records in the answer section.
--  uint16_t nscount # the number of name server resource records in the authority records section.
--  uint16_t arcount # the number of resource records in the additional records section.
-- }
--
-- request body:
-- struct request {
--  string name
--  uint16_t atype
--  uint16_t class
-- }
--
-- response body:
-- struct response {
--  string name
--  uint16_t atype
--  uint16_t class
--  uint16_t ttl
--  uint16_t rdlength
--  string rdata
-- }
--]]

local lnet = require 'lnet'
local socket = require 'socket'

local os = os
local math = math
local table = table
local string = string

--!@brief: dns contants
local MAX_DOMAIN_LEN = 1024
local MAX_LABEL_LEN  = 63
local DNS_HEADER_LEN = 12
local HOSTPORT = socket.gethost'dns' .. ':' .. 53
local TIMEOUT = 10

local QTYPE = {
	A = 1,
	CNAME = 5,
	AAAA = 28,
}

local QCLASS = {
	IN = 1,
}

local CACHE = {
	[QTYPE.A] = {},
	[QTYPE.AAAA] = {},
}

local PENDING_CONTEXT = {
	[QTYPE.A] = {},
	[QTYPE.AAAA] = {},
}


local next_tid = 0
local function gen_tid()
	local tid = next_tid + 1
	if tid > 65535 then
		tid = 1
	end
	next_tid = tid
	return tid
end

local function verify_domain_name(name)
	if #name > MAX_DOMAIN_LEN then
		return false
	end
	if not name:match("^[_%l%d%-%.]+$") then
		return false
	end
	for w in name:gmatch("([_%w%-]+)%.?") do
		if #w > MAX_LABEL_LEN then
			return false
		end
	end
	return true
end

local function pack_request(name, qtype)
	local header = string.pack('>HHHHHH', gen_tid(), 0x100, 1, 0, 0, 0)
	local labels = {}
	for w in name:gmatch("([_%w%-]+)%.?") do
		table.insert(labels, string.pack("s1",w))
	end
	table.insert(labels, '\0')
	table.insert(labels, string.pack(">HH", qtype, QCLASS.IN))
	return header .. table.concat(labels)
end

local function unpack_header(chunk)
	local tid, flags, qdcount, ancount, nscount, arcount, left = string.unpack(">HHHHHH", chunk)
	return {
		tid = tid,
		flags = flags,
		qdcount = qdcount,
		ancount = ancount,
		nscount = nscount,
		arcount = arcount
	}, left
end

local function unpack_name(chunk, left)
	local t = {}
	local jump_pointer
	local tag, offset, label
	while true do
		tag, left = string.unpack("B", chunk, left)
		if tag & 0xc0 == 0xc0 then
			-- pointer
			offset,left = string.unpack(">H", chunk, left - 1)
			offset = offset & 0x3fff
			if not jump_pointer then
				jump_pointer = left
			end
			-- offset is base 0, need to plus 1
			left = offset + 1
		elseif tag == 0 then
			break
		else
			label, left = string.unpack("s1", chunk, left - 1)
			t[#t+1] = label
		end
	end
	return table.concat(t, "."), jump_pointer or left
end

local function unpack_question(chunk, left)
	local name, left = unpack_name(chunk, left)
	local atype, class, left = string.unpack(">HH", chunk, left)
	return {
		name = name,
		atype = atype,
		class = class
	}, left
end

local function unpack_answer(chunk, left)
	local name, left = unpack_name(chunk, left)
	local atype, class, ttl, rdata, left = string.unpack(">HHI4s2", chunk, left)
	return {
		name = name,
		atype = atype,
		class = class,
		ttl = ttl,
		rdata = rdata
	},left
end

local function unpack_rdata(qtype, chunk)
	if qtype == QTYPE.A then
		local a,b,c,d = string.unpack("BBBB", chunk)
		return string.format("%d.%d.%d.%d", a,b,c,d)
	elseif qtype == QTYPE.AAAA then
		local a,b,c,d,e,f,g,h = string.unpack(">HHHHHHHH", chunk)
		return string.format("%x:%x:%x:%x:%x:%x:%x:%x", a, b, c, d, e, f, g, h)
	end
end

local function is_numeric(name)
	return (name == 'localhost') or (not name:find'[^%d%.]')
end

local function lookup_cache(name, qtype)
	local cache = CACHE[qtype][name]
	if cache and os.time() <= cache.ttl then
		local answers = cache.answers
		local nonce = math.random(#answers)
		return answers[nonce], answers
	end
end

local function suspend(name, qtype)
	local list = PENDING_CONTEXT[qtype][name]
	if not list then
		list = {}
		PENDING_CONTEXT[qtype][name] = list
	end
	list[#list+1] = lnet.running()
	return (#list == 1)
end

local function wakeup(name, qtype, ...)
	local list = PENDING_CONTEXT[qtype][name]
	PENDING_CONTEXT[qtype][name] = nil
	for idx=1, #list do
		lnet.wakeup(list[idx], ...)
	end
end

local function parse(content)
	if #content < DNS_HEADER_LEN then
		return nil, "dns: recv an invalid packet"
	end

	-- verify answer
	local answer_header,left = unpack_header(content)
	if answer_header.qdcount ~= 1 then
		return nil, "dns: malformed answer packet"
	end

	local question,left = unpack_question(content, left)

	local ttl
	local answer
	local answers_ipv4
	local answers_ipv6

	for i=1, answer_header.ancount do
		answer, left = unpack_answer(content, left)
		local answers
		if answer.atype == QTYPE.A then
			answers_ipv4 = answers_ipv4 or {}
			answers = answers_ipv4
		elseif answer.atype == QTYPE.AAAA then
			answers_ipv6 = answers_ipv6 or {}
			answers = answers_ipv6
		end
		if answers then
			local ip = unpack_rdata(answer.atype, answer.rdata)
			ttl = ttl and math.min(ttl, answer.ttl) or answer.ttl
			answers[#answers+1] = ip
		end
	end

	local ttl_scale = 100
	if answers_ipv4 then
		CACHE[QTYPE.A][question.name] = { answers = answers_ipv4, ttl = os.time() + ttl * ttl_scale }
	end

	if answers_ipv6 then
		CACHE[QTYPE.AAAA][question.name] = { answers = answers_ipv6, ttl = os.time() + ttl * ttl_scale }
	end

	if answers_ipv4 or answers_ipv6 then
		return true
	end

	return nil, 'dns: query failed cause no result'
end

local function query(name, qtype)
	local fd = socket.udp'0'
	if not fd then
		lnet.yield()
		return nil, 'dns: create socket failed'
	end
	socket.setopt(fd, 'datatype', 1)
	socket.setopt(fd, 'recvtimeout', TIMEOUT)
	socket.sendto(fd, HOSTPORT, pack_request(name, qtype))
	local _, content = socket.recvfrom(fd)
	socket.close(fd)
	if not content then
		return nil, 'dns: socket error occurred when recv data'
	end
	local ok, err = parse(content)
	if not ok then
		return nil, err
	end
	return lookup_cache(name, qtype)
end


local M = {}

function M.resolve(name, ipv6)
	if is_numeric(name) then
		return name
	end
	local qtype = ipv6 and QTYPE.AAAA or QTYPE.A
	local one, answers = lookup_cache(name, qtype)
	if one then
		return one, answers 
	end
	if not verify_domain_name(name) then 
		return nil, 'dns: illegal domain name'
	end
	if suspend(name, qtype) then
		lnet.fork(function()
			wakeup(name, qtype, query(name, qtype))
		end)
	end
	return lnet.wait()
end

function M.flush()
	CACHE[QTYPE.A] = {}
	CACHE[QTYPE.AAAA] = {}
end

return M