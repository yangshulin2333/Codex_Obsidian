local hotpot = _G.CommonHotpot
---@type RunService
local RunService = game:GetService('RunService')

local BASETIME = 1776038400
local INTERVAL = 86400 * 7

---@class ProjectConfig
local c = {}
c.guid = 0

function c:GetGuid()
    c.guid = c.guid + 1
    return c.guid
end

-- Basic
-- Rare
-- Epic
-- Legendary
-- Mythical
-- Exotic
-- Divine
-- Superior
-- Celestial
-- Exclusive
c.quality = {
    {color = Color3.fromRGB(255,255,255),board = 'rbxassetid://90742387445071',name = 'Basic'},
    {color = Color3.fromRGB(0,255,0),board = 'rbxassetid://84235868216981',name = 'Rare'},
    {color = Color3.fromRGB(0,170,255),board = 'rbxassetid://124705289887425',name = 'Epic'},
    {color = Color3.fromRGB(255,0,255),board = 'rbxassetid://75607100815599',name = 'Legendary'},
    {color = Color3.fromRGB(255,170,0),board = 'rbxassetid://116669719229846',name = 'Mythical'},
    {color = Color3.fromRGB(0,0,0),board = 'rbxassetid://87470256520854',name = 'Exotic'},
    {color = Color3.fromRGB(255,0,0),board = 'rbxassetid://87470256520854',name = 'Exotic'},
}

c.animas = {
    {'rbxassetid://98627363861793','rbxassetid://107782168392307','rbxassetid://130050755481137'},
    {'rbxassetid://133012950059842','rbxassetid://134228783679968','rbxassetid://139096410428474'},
    {'rbxassetid://76816351337028','rbxassetid://97827081054721','rbxassetid://124046174155273'},
    {'rbxassetid://87854456364288','rbxassetid://86065771396175','rbxassetid://123434795761719'},
}

c.relice_box_cd = 20 * 3600 --遗物宝箱冷却时间
c.free_gems_cd = 20 * 3600 --免费宝石冷却时间

c.PumpkinBossHp = 2400

c.christmas_box = {
    {
        per = 10000,
        total_weight = 9955,
        list = {
            {reward = {1,7,40},weight = 5000},
            {reward = {1,7,60},weight = 3650},
            {reward = {1,7,80},weight = 1150},
            {reward = {1,7,100},weight = 150},
            {reward = {1,7,180},weight = 5},
        },
    },--圣诞币
    {
        per= 10000,
        total_weight = 9950,
        list = {
            {reward = {1,3,20},weight = 5000},
            {reward = {1,3,100},weight = 3650},
            {reward = {1,3,150},weight = 1150},
            {reward = {1,3,200},weight = 150},

        },
    },--金币
    {
        per = 5000,
        total_weight = 9950,
        list = {
            {reward = {1,2,5},weight = 5000},
            {reward = {1,2,20},weight = 3650},
            {reward = {1,2,50},weight = 1150},
            {reward = {1,2,100},weight = 150},
        },
    },--钻石
    {
        per = 2000,
        total_weight = 10000,
        list = {
            {reward = {3,1,1},weight = 2000},
            {reward = {3,2,1},weight = 5000},
            {reward = {3,3,1},weight = 3000},
        },
    },--药水
    {
        per = 20,
        only = true,
        list = {
            {reward = {7,79,1},weight = 10000},
        },
    },--角色
}

c.guildFlag = {
    'rbxassetid://131838800290937',
    'rbxassetid://114804017409536',
    'rbxassetid://126684814193369',
    'rbxassetid://106983721719436',
}

c.guildIcon = {
    'rbxassetid://121901431336250',
    'rbxassetid://134196192734284',
    'rbxassetid://104284404541777',
    'rbxassetid://105549700147373',
}

c.guildLv = {800,2400,4800,8000,10000000000}
c.guildPlayerCount = {20,30,40,50,60}
c.guildNeedPower = {0,10000,100000000,1000000000000,10000000000000000}
c.guildPost = {'Member','Captain','Officer','Manager','Owner'}
c.guildType = {'No Verification Required','Verification Required'}
c.guildPublic = {'Public','Private'}
c.guildBossReward = {
    {
        {per = 1,reward = {1,11,10}},--公会币
        {per = 1,reward = {6,19,1}},--遗物箱
        {per = 1,reward = {11,1,3}},--锻造石
    },--第一个boss
    {
        {per = 1,reward = {1,11,10}},--公会币
        {per = 1,reward = {6,19,2}},--遗物箱
        {per = 1,reward = {11,1,3}},--锻造石
    },--第2个boss
    {
        {per = 1,reward = {1,11,10}},--公会币
        {per = 1,reward = {6,20,1}},--遗物箱
        {per = 1,reward = {11,1,3}},--锻造石
    },--第3个boss
    {
        {per = 1,reward = {1,11,15}},--公会币
        {per = 1,reward = {6,20,2}},--遗物箱
        {per = 0.5,reward = {11,2,1}},--锻造石
    },--第4个boss
    {
        {per = 1,reward = {1,11,15}},--公会币
        {per = 1,reward = {6,21,1}},--遗物箱
        {per = 0.5,reward = {11,2,1}},--锻造石
    },--第5个boss
    {
        {per = 1,reward = {1,11,15}},--公会币
        {per = 1,reward = {6,21,2}},--遗物箱
        {per = 0.5,reward = {11,2,2}},--锻造石
    },--第6个boss
    {
        {per = 1,reward = {1,11,20}},--公会币
        {per = 1,reward = {6,22,1}},--遗物箱
        {per = 0.3,reward = {11,2,3}},--锻造石
    },--第7个boss
    {
        {per = 1,reward = {1,11,20}},--公会币
        {per = 1,reward = {6,22,2}},--遗物箱
        {per = 0.3,reward = {11,2,3}},--锻造石
    },--第8个boss
    {
        {per = 1,reward = {1,11,20}},--公会币
        {per = 1,reward = {6,23,1}},--遗物箱
        {per = 0.3,reward = {11,2,4}},--锻造石
    },--第9个boss
    {
        {per = 1,reward = {1,11,30}},--公会币
        {per = 1,reward = {6,23,2}},--遗物箱
        {per = 1,reward = {11,1,3}},--锻造石
        {per = 0.3,reward = {11,2,2}},--锻造石
        {per = 0.5,reward = {11,3,1}}--锻造石
    },--第10个boss
}

c.GetWeek = function()
    local now = 0
    if RunService:IsClient() then
        now = workspace:GetServerTimeNow()
    else
        now = os.time()
    end
    local diff = now - BASETIME
    if diff < 0 then
        return 0
    end
    return math.floor(diff / INTERVAL)
end

-- 判断当前是否在公会战时间：周六 00:00 ~ 周日 00:00
c.IsInGuildBattleTime = function()
    local now = 0
    if RunService:IsClient() then
        now = workspace:GetServerTimeNow()
    else
        now = os.time()
    end
    local diff = now - BASETIME

    -- 计算本周已经过了多少秒
    local weekTime = diff % INTERVAL

    -- 一周 7 天，每天 86400 秒
    local day = 86400

    -- 周六 0点 是第 5 天结束（0~5是6天）
    local SATURDAY_0AM = day * 5
    -- 周日 0点 是第 6 天结束
    local SUNDAY_0AM = day * 6

    -- 判断是否在区间内
    return weekTime >= SATURDAY_0AM and weekTime < SUNDAY_0AM
end

-- 判断当前是否在公会报名时间：周1 00:00 ~ 周五 00:00
c.IsInGuildJoinTime = function()
    local now = 0
    if RunService:IsClient() then
        now = workspace:GetServerTimeNow()
    else
        now = os.time()
    end
    local diff = now - BASETIME

    -- 计算本周已经过了多少秒
    local weekTime = diff % INTERVAL

    -- 一周 7 天，每天 86400 秒
    local day = 86400

    -- 周六 0点 是第 5 天结束（0~5是6天）
    local MONDAY_0AM = 0
    -- 周日 0点 是第 6 天结束
    local FRIDAY_0AM = day * 5
    -- 判断是否在区间内
    return weekTime >= MONDAY_0AM and weekTime < FRIDAY_0AM
end

-- 获取当周最后一天的时间戳（周日 23:59:59）
c.GetLastDayTimeByWeek = function()
    -- 直接调用已有的方法获取当前周数
    local week = c.GetWeek()
    
    -- 计算当周开始时间戳
    local weekStartTime = BASETIME + week * INTERVAL
    
    -- 当周最后一天最后一秒 = 当周开始 + 整周时长 - 1秒
    local weekLastTime = weekStartTime + INTERVAL - 1

    return weekLastTime
end

-- 新增：判断当前是否**距离公会战刚好剩1小时**（严格等于1小时）
-- 改为：距离公会战 <= 1小时
c.IsGuildBattleIn1Hour = function()
    local now = RunService:IsClient() and workspace:GetServerTimeNow() or os.time()
    local diff = now - BASETIME
    local weekTime = diff % INTERVAL
    local day = 86400
    local SATURDAY_0AM = day * 5
    local ONE_HOUR = 3600

    local remain = SATURDAY_0AM - weekTime
    -- 关键修改：remain > 0 且 <= 3600
    return remain > 0 and remain <= ONE_HOUR
end

-- 新增：判断是否**距离公会战只剩10秒内**，返回 true + 剩余秒数
c.IsGuildBattleIn10Seconds = function()
    local now = 0
    if RunService:IsClient() then
        now = workspace:GetServerTimeNow()
    else
        now = os.time()
    end
    local diff = now - BASETIME
    local weekTime = diff % INTERVAL
    local day = 86400
    local SATURDAY_0AM = day * 5

    -- 剩余秒数
    local remain = SATURDAY_0AM - weekTime

    -- 条件：剩余时间在 0 ~ 10 秒之间
    local inTime = remain > 0 and remain <= 10
    return inTime, remain
end

return c  