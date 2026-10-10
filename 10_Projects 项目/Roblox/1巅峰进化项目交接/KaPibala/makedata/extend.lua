-- add extra loading path
package.path = package.path .. ';./libs/?.lua'
package.cpath = package.cpath .. ';./libs/?.dll'

local lnet = require 'lnet'
local errors = require 'errors'
local multlang = require 'multlang'

local mode = assert(lnet.env'mode', '--mode not set')
local srcpath = assert(lnet.env'srcpath', '--srcpath not set')
local func = assert(multlang[mode], 'invalid mode: ' .. mode)
func(srcpath)
os.exit()