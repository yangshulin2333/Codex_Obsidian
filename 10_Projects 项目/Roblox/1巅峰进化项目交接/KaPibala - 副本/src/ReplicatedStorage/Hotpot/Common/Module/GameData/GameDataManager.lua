local Hotpot = _G.ServerHotpot
local coroutine = coroutine
local wait = wait
---@type GameConfig
local GameConfig = Hotpot.load.GameDataConfig()
---@type HttpService
local HTTP = game:GetService("HttpService")
---@class GameDataManager
local module = Hotpot.class.new(script)

function module:AddQueue(data)
    assert(data,"function is nil")
    if self.stack_num < 500 and self.clock_num < 60 then
        table.insert(self.stack,data)
    else
        table.insert(self.pool,data)
    end
end
---@type fun(param:table,param:string):table @向服务器发送POST请求
---@param payload table @玩家数据表
---@param str string @ip地址的后缀
function module:HttpPost(payload,str)
    if not GameConfig.Switch then
        return nil
    end
	local res
	local success, err = pcall(function()
		res = HTTP:RequestAsync({
			Url = str,
			Method = "POST",
			Body = payload,
		})
	end)
	return success, err
end

function module:FireHttp(data)
    assert(data,"fire_fun is nil")
    local a,b = self:HttpPost(data[1],data[2])
    if not a then
        local co
        co = coroutine.create(function()
            local msg =   self:HTTPExceptionHand(data)
            if not msg then
                warn("Http 发送失败！")
            end
        end)
        coroutine.resume(co)
    end
end

---@type fun(param:boolean,param:table,param:string,param:table):boolean @数据发送异常处理函数
---@param success boolean @发生是否成功
---@param msg   table @发生返回信息
---@param url string @发生地址
---@param payload table @发送内容
---@return boolean
function module:HTTPExceptionHand(data)
	local res,err = false,nil
	local number = 0
    while true do
        ---如果发送次数大于10次就不发送
        if number > 10 then
            -- print("数据发送失败！")
            return false
        end
        res,err = self:HttpPost(data[1],data[2])
        ---判断数据发送失败重新发送
        if  res  then
            ---请求成功
            return true
        end
        ---发送计数
        number = number + 1
        ---等待
        wait(3)
    end
end


function module:Start()
    ---栈数量
    self.stack_num = 0
    self.clock_num = 60
    ---@type table<number,function> @栈
    self.stack = {}
    ---@type table<number,function> @暂存池
    self.pool = {}
    local co
    co = coroutine.create(function()
        local r,e = xpcall(function()
            local clock_mark = os.clock()
            local rbx
            while true do
                if self.stack_num < 500 and #self.stack > self.stack_num then
                    for i=self.stack_num+1,#self.stack do
                        self:FireHttp(self.stack[i])
                        self.stack_num = i
                        if self.stack_num >= 500 then
                            break
                        end
                    end
                end
                self.clock_num = os.clock() - clock_mark
                if self.clock_num > 60 then
                    clock_mark = os.clock()
                    self.stack_num = 0
                    self.stack = {}
                    self:UpdataStack()
                end
                wait()
            end
        end
        , debug.traceback)
        if not r then
            warn(e)
        end
    end)
    coroutine.resume(co)
end

function module:UpdataStack()
    if self.pool and #self.pool > 0 then
        local max_num = math.min(#self.pool,499)
        for i = max_num,1,-1  do
            table.insert(self.stack,self.pool[i])
            table.remove(self.pool,i)
        end
    end
end

module:Start()

return module