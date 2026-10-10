require("lfs")
local lfs = lfs
local pairs = pairs
local ipairs = ipairs
local string = string
package.path = package.path..";"..lfs.currentdir()

local config_path = "./src/ReplicatedStorage/Config"

local function GetFileName(file_name)
    --从后面截取4位，如果这4位字符串是.lua，那么久返回去掉.lua的字符串，否则返回空
    local exname = string.sub(file_name,string.len(file_name)-3)
    if exname == ".lua" then
        local name = string.gsub(file_name,exname,"")
        return name
    end
end
local function LoadConfig(config_name,path)
    local init_path
    local param_list = {}
    for file_name in lfs.dir(path) do
        if file_name ~= "." and file_name ~= ".." then
            if file_name == "init.lua" then
                init_path = path.."/"..file_name
            else
                local name = GetFileName(file_name)
                if name then
                    local require_file = require(path.."/"..name)
                    for id,info in pairs(require_file) do
                        if type(info) == "table" then
                            for param,value in pairs(info) do
                                if not param_list[param] then
                                    param_list[param] = type(value)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    local file_io = io.open(init_path,"w+")
    file_io:write("---@class Config_"..config_name.."\n")
    for i,v in pairs(param_list) do
        file_io:write("---@field "..i.." "..v.."\n")
    end
    file_io:write("---@type "..config_name.."[]\n")
    file_io:write("local module = {}\n")
    file_io:write("for __,cfg in ipairs(script:GetChildren()) do\n")
    file_io:write("	if cfg.ClassName == \"ModuleScript\" then\n")
    file_io:write("		local tab = require(cfg)\n")
    file_io:write("		for i,v in pairs(tab) do\n")
    file_io:write("			module[i] = v\n")
    file_io:write("		end\n")
    file_io:write("	end\n")
    file_io:write("end\n")
    file_io:write("return module\n")
    file_io:close()
    return "Config_"..config_name
end
local function UpdateConfig()
    --先更新config的描述文件
    local file_io = io.open(config_path.."/init.lua","w+")
    file_io:write("---@class Config\n")
    for file_name in lfs.dir(config_path) do
        if file_name ~= "." and file_name ~= ".." then
            local file_path = config_path.."/"..file_name
            local att = lfs.attributes(file_path)
            local mode = att and att.mode
            if mode == "directory" then
                local class_name = LoadConfig(file_name,file_path)
                file_io:write("---@field "..file_name.." "..class_name.."[]\n")
            end
        end
    end
    file_io:write("local module = {}\n")
    file_io:write("for __,cfg in ipairs(script:GetChildren()) do\n")
    file_io:write("	if cfg.ClassName == \"ModuleScript\"then\n")
    file_io:write("		module[cfg.Name] = require(cfg)\n")
    file_io:write("	end\n")
    file_io:write("end\n")
    file_io:write("return module\n")
end
local r,e = xpcall(UpdateConfig,debug.traceback)
if not r then
    print(e)
end