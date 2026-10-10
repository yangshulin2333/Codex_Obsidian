---@class remodel
remodel = {}
---@type fun(param:string):Instance @从文件系统加载rbxlx文件。
---@param path string @读取路径
---@return Instance @返回一个DataModel实例，等效于Roblox中的游戏。
function remodel.readPlaceFile(path)
end
---@type fun(param:string):Instance[] @从文件系统加载rbxmx或rbxm（0.4.0+）文件
---@param path string @读取路径
---@return Instance[] 请注意，此函数返回实例列表，而不是单个实例！这是因为模型可以包含多个顶级实例。
function remodel.readModelFile(path)
end
---@type fun(param:string):Instance @上传到Roblox.com的大此方法需要对私有资产进行Web身份验证！有关更多信息，请参见身份验证。
---@param assetId string
---@return Instance
function remodel.readPlaceAsset(assetId)
end
---@type fun(param:string):Instance[] @从Roblox此方法需要对私有资产进行Web身份验证！有关更多信息，请参见身份验证。
---@param assetId string
---@return Instance[]
function remodel.readModelAsset(assetId)
end
---@type fun(param:Instance,param:string) @从给定的DataModel实例中保存一个r如果实例不是DataModel，则将抛出此方法。模型应改为使用writeModelFile保存。
---@param instance DataModel
---@param path string
function remodel.writePlaceFile(instance,path)
end
---@type fun(param:Instance,param:string) @从给定实例中保存rbxmx或rbxm（0.4.0+）文件。
---@param instace Instance
---@param path string
function remodel.writeModelFile(instace,path)
end
---@type fun(param:Instance,param:string) @在现有位置上将给定的DataM此方法始终需要Web身份验证！有关更多信息，请参见身份验证。
---@param instace Instance
---@param path string
function remodel.writeExistingPlaceAsset(instace,assetId)
end
---@type fun(param:Instance,param:string) @将给定实例通过现有位置上传到Roblox.com如果实例是DataModel，则将抛出此方法。位置应改为使用writeExistingPlaceAsset上传。此方法始终需要Web身份验证！有关更多信息，请参见身份验证。
---@param instace Instance
---@param assetId string
function remodel.writeExistingModelAsset(instace,assetId)
end
---@type fun(param:Instance,param:string):any @从给定实例中获取具有给定名称的属性，绕过所有验证。它旨在实现简单但功能非常强大的API，而Remodel则增加了符合人体工程学的功能。如果尚未通过Remodel表示实例上存储的值类型，则抛出该异常。有关更多详细信息，请参见支持的Roblox类型。
---@param instace Instance
---@param name string
---@return any
function remodel.getRawProperty(instace,name)
end
---@type fun(param:Instance,param:string,param:string,param:any) @使用给定的名称，类型和值在给定实例上设置属性。类型的有效值在项目符号列表左半部分的“支持的Roblox类型”中定义。它旨在实现简单但功能非常强大的API，而Remodel则增加了符合人体工程学的功能。如果值类型不能用Remodel表示，则抛出该异常。有关更多详细信息，请参见支持的Roblox类型。
---@param instace Instance
---@param name string
---@param type string
---@param value any
function remodel.setRawProperty(instace,name,type,value)
end
---@type fun(param:string):string @读取给定路径下的文件。抛出错误，就像文件不存在一样。
---@param path string
---@return string
function remodel.readFile(path)
end
---@type fun(param:string):string[] @返回目录中所有子文件名的列表抛出错误，例如目录不存在。
---@param path string
---@return string[]
function remodel.readDir(path)
end
---@type fun(param:string,param:string) @将文件写入给定路径。
---@param path string
---@param contents string
function remodel.writeFile(path,contents)
end
---@type fun(param:string) @在给定路径下创建目录，以及所有尚不存在的父目录。这是Rust的fs :: create_dir_all函数的一个简单包装。与Unix中的mkdir -p相似。
---@param path string
function remodel.createDirAll(path)
end
---@type fun(param:string):boolean @告诉给定的路径是否是文件。这是Rust的fs :: metadata函数的一个瘦包装。
---@param path string
---@return boolean
function remodel.isFile(path)
end
---@type fun(param:string):boolean @说明给定路径是否为目录这是Rust的fs :: metadata函数的一个瘦包装
function remodel.isDir(path)
end