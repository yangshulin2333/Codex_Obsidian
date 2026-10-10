local xml = require 'xml'
local json = require 'rapidjson'
local utils = require 'http.utils'
local gateway = require 'http.gateway'

local table = table
local string = string
local type = type
local next = next
local error = error
local assert = assert
local tostring = tostring

local  CONTENT_TYPE = {
	text = 'Content-Type: application/text\r\n',
	xml = 'Content-Type: application/xml\r\n',
	json = 'Content-Type: application/json\r\n',
	urlencoded = 'Content-Type: application/x-www-form-urlencoded\r\n',
}

local function parse(url)
	local ssl
	local first, last = string.find(url, '^http://')
	if not first then
		first, last = string.find(url, '^https://')
		ssl = (first ~= nil)
	end
	assert(first, 'not http or https url')

	local _, last, domain_port = string.find(url, '([^/]+)', last+1)
	assert(domain_port, 'can not parse domain:port')

	local _, last, method = string.find(url, '([^%?]+)', last+1) 

	local body
	if last then
		body = string.sub(url, last+2)
	end

	return {
		domain_port = domain_port,
		method = method or '/',
		body = body or '',
		ssl = ssl
	}
end

local function encode_headers(headers)
	if not headers then
		return ''
	end
	local buffer = {}
	for key, value in next, headers do
		buffer[#buffer+1] = string.format('%s: %s\r\n', key, value)
	end
	return table.concat(buffer)
end

local function encode_body(content_type, body)
	content_type = CONTENT_TYPE[(content_type or 'urlencoded')]
	if not content_type then
		error('unknown content type', 0)
	end

	if type(body) == 'string' then
		return content_type, body
	elseif type(body) ~= 'table' then
		error('invalid body type, table or string expected', 0)
	end

	local retval
	if content_type == CONTENT_TYPE.text then 
		retval = body
		
	elseif  content_type == CONTENT_TYPE.xml then
		retval = xml.encode(body, true)

	elseif content_type == CONTENT_TYPE.json then
		retval = json.encode(body)

	elseif content_type == CONTENT_TYPE.urlencoded then
		local keyvals = {}
		for key, value in next,  body do
			keyvals[#keyvals+1] = string.format('%s=%s', key, utils.encode(tostring(value)))
		end
		retval = table.concat(keyvals, '&')
	end

	return content_type, retval
end

local function compose_request(req_type, url, args)
	local headers = encode_headers(args.headers)
	local content_type, body = encode_body(args.content_type, args.body or url.body)

	local buffer
	if req_type == 'GET' then
		buffer = {
			'GET ', url.method, '?', body, ' HTTP/1.1\r\n',
			'HOST: ', url.domain_port, '\r\n',
			content_type,
			headers,
			'\r\n',
		}
	elseif req_type == 'POST' then
		buffer = {
			'POST ', url.method, ' HTTP/1.1\r\n',
			'HOST: ', url.domain_port, '\r\n',
			content_type,
			headers,
			'Content-Length: ', #body, '\r\n\r\n',
			body
		}
	end

	return table.concat(buffer)
end

--[[
@params
args:
	* canbe a string of url, in this case, GET is the default method. sample: http.call("http://www.baidu.com"),
	* a table with following fields:
		type<optional>:  GET or POST, GET is default
		url:
		content_type<optional>: text, xml, json, urlencoded, urlencoded is default
		headers<optional>: table
		body<optional>: string or table
		timeout<optional>: integer, in seconds
		proxy<optional>: ipaddr:port

		sample:
		http.call{
			type = 'POST',
			url = 'http://www.baidu.com/query.do',
			content_type = 'json',
			body = { key = 1 },
			timeout = 10,
			proxy = 'localhost:1080'
		}

@return:
	* nil, errmsg
	* header(table), body(table)

@return.body
	using body:decode(type) to get decoded data
	type can be:
		nil: means get original bytes
		xml: do decode as xml
		json: do decode as json
		urlencoded: do decode as urlencoded
--]]
local function call(args)
	if type(args) == 'string' then
		args = { type = 'GET', url = args }
	end

	local req_type = args.type or 'GET'
	assert(req_type == 'GET' or req_type == 'POST', 'invalid http method, GET or POST expected')

	local url = assert(args.url, 'url not set')
	url = parse(url)

	local request = compose_request(req_type, url, args)
	local conn, errmsg = gateway.open(url.domain_port, args.proxy, args.timeout, url.ssl)
	if not conn then
		return nil, errmsg
	end

	local ok, errmsg = conn:write(request)
	if not ok then
		conn:close()
		return nil, errmsg
	end

	local  header, body = conn:read()
	conn:close()
	return header, body
end

return {
	call = call
}