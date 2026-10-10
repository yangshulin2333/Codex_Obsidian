---@class UserInfo
---@field Id number
---@field Username string
---@field DisplayName string

---@class UserService:Instance
local c = {}
---@type fun(user_ids:number[]):UserInfo[]
---@param user_ids number[]
---@return UserInfo[]
function c:GetUserInfosByUserIdsAsync(user_ids)
end