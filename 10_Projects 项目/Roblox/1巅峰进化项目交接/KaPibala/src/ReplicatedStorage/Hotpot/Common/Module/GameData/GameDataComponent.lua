local hotpot = _G.CommonHotpot
local ServerHotpot = _G.ServerHotpot
---@type GameDataConfig
local GameDataConfig = ServerHotpot.load.GameDataConfig()
---@type GameDataManager
local game_data_manager = hotpot.load.GameDataManager()
---@type RunService
local RunService = game:GetService("RunService")
---@type ScriptContext
local ScriptContext = game:GetService("ScriptContext")
---@type HttpService
local HTTP = game:GetService("HttpService")
---@class GameDataComponent:BaseComponent
local c = hotpot.class.new(script,hotpot.files.BaseComponent())
---玩家信息创建
function c:CreationPlayer(extend_1,extend_2)
    local initTab = {
		["game_id"] = tostring(self.gameKey),
		["gaid"] = "",
		["uuid"] = tostring(self.playerId),
		["name"] = tostring(self.playerName),
		["language"] = 0 ,
		["country"] = "" ,
		["ip"] = "",
		["created_at"] = os.time(),
		["app_version"] = self.bulid,
		["at_type"] = 0,
		["ab_value"] = 0,
		["device_id"] = "",
		["channel"] = "",
		["platform"] = "",
		["device_language"] = "",
		["extend_1"] = extend_1 or	"",
		["extend_2"] = extend_2 or  ""
    }
    return initTab
end
---玩家在线时长
function c:PlayGameTime(extend_1,extend_2)
    local time = os.time() - self.playerTime
    local initTab = {
		["game_id"] = tostring(self.gameKey),
		["device_id"]= "",
		["role_name"]= tostring(self.playerName),
		["role_id"]= tostring(self.playerId),
		["secs"]= time,
		["event_time"]= os.time(),
		["game_version"] = self.bulid,
		["app_version"] = self.bulid,
		["extend_1"] = extend_1 or	"",
		["extend_2"] = extend_2 or  ""
	}
    return initTab
end
---玩家登录
function c:PlayerLogin(number,extend_1,extend_2)
    local initTab = {
		["name"]= tostring(self.playerName),
		["uid"]= tostring(self.playerId),
		["device_id"]= "",
		["language"] = 0,
		["country"] = "",
		["game_id"] = tostring(self.gameKey),
		["ip"] = "",
		["extend"] = tostring(number) or " ",
		["app_version"]= self.bulid,
		["created_at"]= os.time(),
		["device_language"] = "",
		["extend_1"] = extend_1 or	"",
		["extend_2"] = extend_2 or  ""
	}
    return initTab
end
---玩家行为日志
function c:PlayerAction(action,extend,extend_1,extend_2)
    local initTab = {
		["player_id"]= tostring(self.playerId),
		["action_id"]= tonumber(action),
        ["extend"]= tostring(extend) or "",
        ["game_id"]= tostring(self.gameKey),
        ["created_at"]= os.time(),
        ["uuid"]= "",
		["extend_1"] = extend_1 or	"",
		["extend_2"] = extend_2 or  ""
	}
    return initTab
end  
---漏斗日志
function c:Funnel(stage,extend_1,extend_2)
    local initTab = {
		["game_id"]= tostring(self.gameKey),
		["uid"]= tostring(self.playerId),
        ["game_step_id"]= tonumber(stage),
        ["created_at"]= os.time(),
		["extend_1"] = extend_1 or	"",
		["extend_2"] = extend_2 or  ""
	}
    return initTab
end
---玩家资源日志
function c:PlayerResources(id,name,type,number,extend_1,extend_2)
    local initTab = {
		["player_id"]= tostring(self.playerId),
		["id"]= tonumber(id),
		["change_amount"] = tonumber(number),
		["new_amount"] = tonumber(number),
		["reason"] = tonumber(type),
        ["extend"]= name or "",
        ["game_id"]= tostring(self.gameKey),
        ["created_at"]= os.time(),
        ["uuid"]= tostring(self.playerId),
		["extend_1"] = extend_1 or	"",
		["extend_2"] = extend_2 or  ""
	}
    return initTab
end

function c.new(parent)
	if not parent or not parent.main_inst then
		warn("player main_inst  is  nil")
		return false
	end
    return c(parent)
end

---@param parent Server_Player
function c:ctor(parent)
    c.super.ctor(self,parent)
	--初始化
	self:Init()
end
---@type fun()
function c:Init()
	---玩家注册时常
	self.account_age = self.parent.main_inst.AccountAge
	---RobloxVip
	self.vip = self:TestVIP()
	---群组成员
	self.group = self:TestGroup()
	---玩家登录时间
	self.playerTime = os.time()
    ---玩家语言
    self.language = self.parent.main_inst.LocaleId
	---玩家id
	self.playerId  = self.parent.main_inst.UserId
	---玩家名字
	self.playerName = self.parent.main_inst.Name --"test"..
	---游戏键
	self.gameKey = GameDataConfig.GameKey ---c1qhoogtqiubk9fth8j0
	---游戏版本
	self.bulid = GameDataConfig.Building
	---游戏ip地址
	self.ip = GameDataConfig.Ip
	self.player_msg = {
		["AccountAge"] = self.account_age ,
		["Premium"] = self.vip ,
		["Language"] = self.language ,
		["Group"] = self.group
	}
end
---@type fun() @玩家登录打点函数
function c:PlayerLoginGame()
    local data_component = self.parent:GetComponent(ServerHotpot.load.Server_PlayerDataComponent())
    local prop_data = data_component:GetData("prop")
    local stage_data = data_component:GetData("stage")
    local stage_list = stage_data.__real.list 
    ---玩家数据信息表
    local tab = {
        stage = stage_list[#stage_list] ,
        gold = prop_data.__real.gold ,
        diamond = prop_data.__real.diamond ,
        reborn = prop_data.__real.reborn ,
        svip = prop_data.__real.svip ,
        vip =prop_data.__real.vip
    }
    ---玩家第一次登录判断
    if not prop_data.__real.first then
        data_component:Execut(function()
            prop_data.first = true
        end)
        self:FireCreatePlayer()
    end
    ---玩家登录打点
    self:FirePlayerAction(15,nil,tab)
end
---@type fun() @玩家登录打点函数
function c:PlayerOutGame()
    local data_component = self.parent:GetComponent(ServerHotpot.load.Server_PlayerDataComponent())
    local prop_data = data_component:GetData("prop")
    local stage_data = data_component:GetData("stage")
    local stage_list = stage_data.list 
    ---玩家数据信息表
    local tab = {
        stage = stage_list[#stage_list] ,
        gold = prop_data.gold ,
        diamond = prop_data.diamond ,
        reborn = prop_data.reborn ,
        svip = prop_data.svip ,
        vip =prop_data.vip
    }
    ---玩家登录打点
    self:FirePlayerAction(16,nil,tab)
	---玩家在线时长
	self:FirePlayerTime()
end
---@type fun():boolean @检测是否是群组成员
---@return boolean
function c:TestGroup()
	if self.parent.main_inst:IsInGroup(GameDataConfig.GroupId) then
		return  true
	end
	return false
end	


---@type fun():boolean @检测是否是RobloxVIP
---@return boolean
function c:TestVIP()
	if self.parent.main_inst.MembershipType == Enum.MembershipType.Premium then
		return true 
	end
	return false
end


---@type fun(param:boolean,param:table,param:string,param:table):boolean @数据发送异常处理函数
---@param success boolean @发生是否成功
---@param msg   table @发生返回信息
---@param url string @发生地址
---@param payload table @发送内容
---@return boolean
function c:HTTPExceptionHand(success,msg,url,payload)
	local res,err
	local number = 0
	---如果数据发送失败或者没有成功就重新发送
	if not success or not msg["Success"] then
		self:AddProcess(function()
			self:AddCo()
			while true do
				---如果发送出售大于10次就不发送
				if number > 10 then
					-- print("数据发送失败！")
					return false
				end
				---判断数据发送失败重新发送
				if not success or not res["Success"] then
					success, err = pcall(function()
						res = HTTP:RequestAsync({
							Url = url,
							Method = "POST",
							Body = payload,
						})
					end)
				else
					---请求成功
					return true
				end
				---发送计数
				number = number + 1
				---等待
				self:Wait(3)
			end
		end)
	end
	return true
end


---@type fun():boolean @Studio开关服务和检验数据有效性
---@return boolean
function c:StudioSwichHTTP()
	if  RunService:IsStudio()  then
        return GameDataConfig.Studio
    end
	if not self.playerId and tostring(self.playerId) <= 0  then
        return false 
    end
	return true
end


---@type fun(param:table,param:string):table @向服务器发送POST请求
---@param payload table @玩家数据表
---@param str string @ip地址的后缀
function c:HttpPost(payload,str)
	local res
	local success, err = pcall(function()
		res = HTTP:RequestAsync({
			Url = self.ip..str,
			Method = "POST",
			Body = payload,
		})
	end)
	return success
end


---@type fun(param:string,param:string):boolean @向服务器发送玩家游戏时常
---@param extend_1 string @额外字段，可不传
---@param extend_2 string @额外字段，可不传
---@return boolean 
function c:FirePlayerTime(extend_1,extend_2)
    -- if not self:StudioSwichHTTP() then
	-- 	return false
	-- end
	local str1
	if extend_1 then
		str1 = tostring(HTTP:JSONEncode(extend_1))
	end
    local payload = HTTP:JSONEncode(self:PlayGameTime(str1,extend_2))
	local data_tab = {
		[1] = payload,
		[2] = self.ip..GameDataConfig.PlayerTime
	}
	game_data_manager:AddQueue(data_tab)
	--print(res,payload)
end


---@type fun(param:number,param:string,param:string,param:string):boolean @向服务器发送玩家行为
---@param action number @行为id
---@param extend string @行为参数
---@param extend_1 string @额外字段，可不传参
---@param extend_2 string @额外字段，可不传参
---@return boolean
function c:FirePlayerAction(action,extend,extend_1,extend_2)
    -- if not self:StudioSwichHTTP() then
	-- 	return false
	-- end
	local str1
	if extend_1 then
		str1 = tostring(HTTP:JSONEncode(extend_1))
	end
    local payload = HTTP:JSONEncode(self:PlayerAction(action,extend,str1,extend_2))
	local data_tab = {
		[1] = payload,
		[2] = self.ip..GameDataConfig.PlayerAction
	}
	game_data_manager:AddQueue(data_tab)
	--print("向服务器发送玩家行为",payload,res,action,extend)
end


---@type fun(param:string,param:string):boolean @向服务器发送玩家创建
---@param extend_1 string @额外字段，可不传参
---@param extend_2 string @额外字段，可不传参
---@return boolean
function c:FireCreatePlayer(extend_1)
    -- if not self:StudioSwichHTTP() then
	-- 	return false
	-- end
	local str1
	if extend_1 then
		str1 = tostring(HTTP:JSONEncode(extend_1))
	end
	local str2 = HTTP:JSONEncode(self.player_msg)
    local payload = HTTP:JSONEncode(self:CreationPlayer(str1,str2))
	
	local data_tab = {
		[1] = payload,
		[2] = self.ip..GameDataConfig.PlayerCreat
	}
	game_data_manager:AddQueue(data_tab)
end


---@type fun(param:number,param:string,param:string):boolean @向服务器发送玩家登录日志
---@param num number @玩家资源数量	
---@param extend_1 string @额外字段，可不传参
---@param extend_2 string @额外字段，可不传参
---@return boolean
function c:FirePlayerLogin(num,extend_1,extend_2)
    -- if not self:StudioSwichHTTP() then
	-- 	return false
	-- end
	local str1
	if extend_1 then
		str1 = tostring(HTTP:JSONEncode(extend_1))
	end
    local payload = HTTP:JSONEncode(self:PlayerLogin(num,str1,extend_2))
	local data_tab = {
		[1] = payload,
		[2] = self.ip..GameDataConfig.PlayerLogin
	}
	game_data_manager:AddQueue(data_tab)
end


---@type fun(param:number,param:string,param:string,param:number,param:string,param:string):boolean @向服务器发送玩家资源变化日志
---@param id number @资源id
---@param name string @资源名字
---@param type string @资源类型
---@param num number @资源数量	
---@param extend_1 string @额外字段，可不传参
---@param extend_2 string @额外字段，可不传参
---@return boolean
function c:FirePlayerResources(id,name,type,num,extend_1,extend_2)
    -- if not self:StudioSwichHTTP() then
	-- 	return false
	-- end
	local str1
	if extend_1 then
		str1 = tostring(HTTP:JSONEncode(extend_1))
	end
    local payload = HTTP:JSONEncode(self:PlayerResources(id,name,type,num,str1,extend_2))
	local data_tab = {
		[1] = payload,
		[2] = self.ip..GameDataConfig.PlayerRes
	}
	game_data_manager:AddQueue(data_tab)
	--print("向服务器发送玩家资源变化日志",payload)
end


---@type fun(param:string,param:string,param:string):boolean @向服务器发送玩家场景开始
---@param stage string  @场景名
---@param extend_1 string @额外字段，可不传参
---@param extend_2 string @额外字段，可不传参
---@return boolean
function c:GameFunnel(stage,extend_1,extend_2)
    -- if not self:StudioSwichHTTP() then
	-- 	return false
	-- end
	local str1
	if extend_1 then
		str1 = tostring(HTTP:JSONEncode(extend_1))
	end
    --print(stage,player)
    local payload = HTTP:JSONEncode(self:Funnel(stage,str1,extend_2))
	local data_tab = {
		[1] = payload,
		[2] = self.ip..GameDataConfig.PlayerGameStart
	}
	game_data_manager:AddQueue(data_tab)
end

function c:dtor()
    c.super.dtor(self)
end

return c