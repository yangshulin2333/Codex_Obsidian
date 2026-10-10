-- add extra loading path
package.path = package.path .. ';./libs/?.lua'
package.cpath = package.cpath .. ';./libs/?.dll'

local lnet = require 'lnet'
local srcpath = assert(lnet.env'srcpath', '--srcpath not set')
local dstpath = assert(lnet.env'dstpath', '--dstpath not set')
local mldstpath = assert(lnet.env'mldstpath', '--mldstpath not set')

require 'pass.xlstolua'.exec(srcpath)
require 'pass.transform'.exec()
require 'pass.guard'.exec()
require 'pass.finalize'.exec(dstpath, mldstpath)