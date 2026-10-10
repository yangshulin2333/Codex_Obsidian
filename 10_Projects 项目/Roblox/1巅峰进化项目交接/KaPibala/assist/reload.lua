require("lfs")
local io = io
local lfs = lfs
local pairs = pairs
local ipairs = ipairs
local string = string

local file_root_path = "./src"
local client_root_path = "ReplicatedStorage"
local server_root_path = "ServerStorage"

local list_folder_path = "_FileData"
local resc_folder_path = "Resource"
local file_paths = {}
local types1 = {
    "Hotpot",
    "Script"
}
local types2 = {
    "Server",
    "Client",
    "Common",
}
local type3 = {
    "Component",
    "Module",
    "Object"
}
local root_path = {
    Server = server_root_path,
    Client = client_root_path,
    Common = client_root_path,
}
---@type fun(file_name:string):string @给待后缀名的文件名，如果文件是lua文件，则返回文件名
local function GetFileName(file_name)
    --从后面截取4位，如果这4位字符串是.lua，那么久返回去掉.lua的字符串，否则返回空
    local exname = string.sub(file_name,string.len(file_name)-3)
    if exname == ".lua" then
        local name = string.gsub(file_name,exname,"")
        return name
    end
end
local function GetRescName(file_name)
    local rbxm = string.find(file_name,".rbxm")
    local rbxmx = string.find(file_name,".rbxmx")
    if rbxmx then
        return string.gsub(file_name,".rbxmx","")
    elseif rbxm then
        return string.gsub(file_name,".rbxm","")
    end
end
local function ChangePath(path)
    -- print(path,file_root_path,client_root_path)
    path = string.gsub(path,file_root_path.."/","")
    path = string.gsub(path,"/",".")
    return path
end
---@type fun(path:string,tab:table) @获取指定目录下的所有文件，并以文件名=文件目录的形式添加到给定的表中去
local function GetFolderFilePath(path,list,name_list)
    for file_name in lfs.dir(path) do
        if file_name ~= "." and file_name ~= ".." then
            local file_path = path.."/"..file_name
            local att = lfs.attributes(file_path)
            local mode = att and att.mode
            if mode == "directory" then
                GetFolderFilePath(file_path,list,name_list)
            elseif mode == "file" then
                local name = GetFileName(file_name)
                if name then
                    --检查是否存在，如果存在就报错
                    assert(not name_list[name],string.format("%s and %s repeated!",tostring(name_list[name]),file_path))
                    local game_path = ChangePath(path).."."..name
                    list[name] = game_path
                    name_list[name] = game_path
                end
            end
        end
    end
end
---@type fun(folder_path:string) @尝试创建目录
local function TryCreateFolder(folder_path)
    local file_test,err = io.open(folder_path)
    if err == folder_path..": No such file or directory" then
        lfs.mkdir(folder_path)
    end
    if file_test then
        file_test:close()
    end
end
---@type fun() @返回当前框架中的所有文件
local function GetFrameFiles()
    local client_file_path_list = {}
    local server_file_path_list = {}
    local name_list = {}
    for _,path1 in ipairs(types1) do
        for __,path2 in ipairs(types2) do
            local tag_path = root_path[path2]
            TryCreateFolder(file_root_path.."/"..tag_path.."/"..path1)
            if path2 == "Server" then
                server_file_path_list[path2] = server_file_path_list[path2] or {}
            else
                client_file_path_list[path2] = client_file_path_list[path2] or {}
            end
            local scan_path = file_root_path.."/"..tag_path.."/"..path1.."/"..path2
            TryCreateFolder(scan_path)
            for ___,path3 in ipairs(type3) do
                TryCreateFolder(scan_path.."/"..path3)
            end
            if path2 == "Server" then
                GetFolderFilePath(scan_path,server_file_path_list[path2],name_list)
            else
                GetFolderFilePath(scan_path,client_file_path_list[path2],name_list)
            end
        end
    end
    return client_file_path_list,server_file_path_list
end
local function CreateFileList(ftype,cfg_path,...)
    local class_name = ftype.."FileList"
    local file_list = {}
    for __,list in ipairs({...}) do
        for name,path in pairs(list) do
            path = ChangePath(path)
            file_list[name] = path
        end
    end
    --生成配置文件
    cfg_path = cfg_path.."/"
    local file_io = io.open(cfg_path..ftype.."FileList.lua","w+")
    --生成类名
    file_io:write("---@class "..ftype.."FileList\n")
    --生成成员变量
    for name,path in pairs(file_list) do
        file_io:write("---@field "..name.." "..name.."\n")
    end
    --生成路径
    file_io:write("local c = {}\n")
    for name,path in pairs(file_list) do
        file_io:write("c."..name.." = \""..path.."\"\n")
    end
    file_io:write("return c")
    file_io:close()
end
--更新脚本配置
local function UpdateScriptCfg()
    local client_file_path_list,server_file_path_list = GetFrameFiles()
    --生成配置文件,客户端
    local client_cfg_path = file_root_path.."/"..client_root_path.."/"..list_folder_path
    TryCreateFolder(client_cfg_path)
    --创建客户端
    for name,list in pairs(client_file_path_list) do
        CreateFileList(name,client_cfg_path,list,client_file_path_list.Common)
    end
    --创建服务器
    local server_cfg_path = file_root_path.."/"..server_root_path.."/"..list_folder_path
    TryCreateFolder(server_cfg_path)
    for name,list in pairs(server_file_path_list) do
        CreateFileList(name,server_cfg_path,list,client_file_path_list.Common)
    end

end
local function GetFileTable(name,path,list,parent)
    if not parent then
        table.insert(list,"local "..name.." = ".."{}")
        parent = name
    end
    for file_name in lfs.dir(path) do
        if file_name ~= ".." and file_name ~= "." then
            local file_path = path.."/"..file_name
            local att = lfs.attributes(file_path)
            local mode = att and att.mode
            if mode == "directory" then
                local name = tonumber(file_name) or file_name
                if type(name) == "string" then
                    name = "[\""..name.."\"]"
                else
                    name = "["..name.."]"
                end
                path = path.."/"..file_name
                table.insert(list,parent..name.." = ".."{}")
                parent = parent..name
                GetFileTable(file_name,path,list,parent)
            else
                local name = GetRescName(file_name)
                if name then
                    local key_name = tonumber(name) or name
                    if type(key_name) == "string" then
                        key_name = "[\""..key_name.."\"]"
                    else
                        key_name = "["..key_name.."]"
                    end
                    file_path = ChangePath(path.."."..name)
                    table.insert(list,parent..key_name.." = \""..file_path.."\"")
                end
            end
        end
    end
end
local function UpdateRescource()
    local cfg_path = file_root_path.."/"..list_folder_path
    TryCreateFolder(cfg_path)
    local list = {}
    GetFileTable("resource",file_root_path.."/"..resc_folder_path,list)
    local file_io = io.open(cfg_path.."/ResourceList.lua","w+")
    file_io:write("---@class ResourceList\n")
    for i,v in ipairs(list) do
        file_io:write(v.."\n")
    end
    file_io:write("return resource")
    file_io:close()
end
--更新脚本配置
UpdateScriptCfg()
--更新配置文件描述
-- UpdateRescource()