local xml = require 'xml'
local json = require 'rapidjson'
local utils = require 'http.utils'
local gateway = require 'http.gateway'

local table = table
local string = string
local type = type
local next = next
local pcall = pcall
local assert = assert
local tostring = tostring

local OPCODE_OK = 200
local OPCODE_ERROR = 500
local OPCODE_TEXT = {
	[OPCODE_OK] = 'OK',
	[OPCODE_ERROR] = 'Internal Server Error',
}

local  CONTENT_TYPE = {
	text = 'Content-Type: application/text',
	xml = 'Content-Type: application/xml',
	json = 'Content-Type: application/json',
	urlencoded = 'Content-Type: application/x-www-form-urlencoded',
}

local function encode_body(content_type, body)
	content_type = CONTENT_TYPE[(content_type or 'urlencoded')]
	if not content_type then
		return nil, 'unknown content type'
	end

	if type(body) == 'string' then
		return content_type, body
	elseif type(body) ~= 'table' then
		return nil, 'invalid body type, table or string expected'
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

local function compose_response(ok, content_type, body)
	local opcode = OPCODE_OK
	if not ok then
		-- ok = false, content_type = errstr, body = nil
		opcode = OPCODE_ERROR
		body = content_type
		content_type = CONTENT_TYPE.text
	else
		content_type, body = encode_body(content_type, body)
		if not content_type then
			opcode = OPCODE_ERROR
			content_type = CONTENT_TYPE.text
		end
	end

	local buffer = {
		string.format('HTTP/1.1 %s %s', opcode, OPCODE_TEXT[opcode]),
		'Server: LNET',
		'Access-Control-Allow-Origin: *',
		content_type,
		string.format('Content-Length: %d', #body),
		'',
		body
	}

	return table.concat(buffer, '\r\n')
end

local function start(t)
	local hostport = assert(t.hostport, 'hostport not set')
	local dispatch = assert(t.dispatch, 'dispatch not set')
	local listener = gateway.listen(hostport, function(header, body)
		local ok, content_type, body = pcall(dispatch, header, body)
		return compose_response(ok, content_type, body)


	end)
	assert(listener, 'start http service failed on: ' .. hostport)
	return listener
end


return {
	start = start
}