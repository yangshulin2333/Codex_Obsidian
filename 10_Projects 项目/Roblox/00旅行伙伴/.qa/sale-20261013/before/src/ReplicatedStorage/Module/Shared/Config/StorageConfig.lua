--!strict

-- 当前存储模块的手写配置与整档校验；不是 Excel 生成文件，也不负责加载/保存数据。
-- Shared 配置会复制到客户端，不应放密钥；默认存档结构在此集中维护。
local StorageConfig = {}

-- Memory 仅当前服务器内存有效；ProfileStore 使用持久化会话，后端由 StorageService 选择。
StorageConfig.Backend = "ProfileStore"
-- 存储名称不是展示名；改名会切换到另一套存档，不能当作普通文案随意修改。
StorageConfig.ProfileStoreName = "TravelBuddy_PlayerData_V1"

-- 等待玩家数据就绪时的轮询间隔（秒）。
StorageConfig.PlayerDataReadyPollSeconds = 0.1

-- SchemaVersion 是数据结构版本，不是框架发行版本；当前仅检查相等，不做自动迁移。
StorageConfig.SchemaVersion = 1

-- 没有历史存档时使用的默认结构；重新打开已有持久化 key 不会用它覆盖整份历史数据。
-- Modules 为各业务模块预留独立子表；框架只校验外层，不在此添加货币/背包等具体玩法字段。
StorageConfig.DefaultData = {
	SchemaVersion = StorageConfig.SchemaVersion,
	Settings = {},
	Modules = {},
}

-- 检查整份数据的基础结构，成功返回 true，失败返回 false, message；不修复输入数据。
-- 只检查列出的字段，不拒绝其他字段，也不校验每个 Modules 子表的业务结构。
function StorageConfig.Validate(data)
	if type(data) ~= "table" then
		return false, "必须是table类型"
	end

	if data.SchemaVersion ~= StorageConfig.SchemaVersion then
		return false, "SchemaVersion不匹配"
	end

	if type(data.Settings) ~= "table" then
		return false, "Settings必须是table类型"
	end

	if type(data.Modules) ~= "table" then
		return false, "Modules必须是table类型"
	end

	return true
end

return StorageConfig
