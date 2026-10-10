---@type ClientHotpot
local hotpot = _G.ClientHotpot
---@class DropTweenHelper
local c = {}

local Client_AudioManager = hotpot.load.Client_AudioManager() 
local hotpot = _G.ClientHotpot
local Debris = game:GetService("Debris")
local Drops_Obj = hotpot.load.Client_DropsObj()
local drop_cfg = {} 
local insts_id = 0

if not drop_cfg or not next(drop_cfg) then
    for k,v in pairs(hotpot.config.drop_disposition) do
        drop_cfg[v.type] = v
    end
end

c.coin_pfb = hotpot:GetPath_Loop("Perfabs.coin_pfb",_G.Resource)
c.eff = {
    gold = hotpot:GetPath_Loop("Effect.gold_eff",_G.Resource),
    diamond = hotpot:GetPath_Loop("Effect.dimd_eff",_G.Resource),
}   
local _str = {
    fol_name_str    = "DropsFolder",
    bag_fol_name_str= "BagDropsFolder",
    fol_type_str    = "Folder",
    sp_fol_name_str = "SpecialDropsFolder",
    splinter_fol_name_str = "SplinterDropsFolder",
    rune = "rune",
    eff = "drops_eff",
    splinter = "splinter",
}

local bag_str = {
    gold    = "gold_bag",
    diamond = "diamond_bag",
}

--符文颜色
local __rune_Coloer = {
   [1] = ColorSequence.new(Color3.fromRGB(255, 255, 255)), --白
   [2] = ColorSequence.new(Color3.fromRGB(0 ,  34 , 255)), --蓝
   [3] = ColorSequence.new(Color3.fromRGB(170, 0  , 255)), --紫
   [4] = ColorSequence.new(Color3.fromRGB(255, 101, 12 )), --橙
   [5] = ColorSequence.new(Color3.fromRGB(255, 0  , 0  )), --红
}

--符文光柱高度
local __rune_Hight = {
    Vector3.new(0, 25, 0),

    Vector3.new(0, 28, 0),

    Vector3.new(0, 32, 0),

    Vector3.new(0, 36, 0),
}

--符文光柱颜色
local __rune_Beam_Color = {
    [1] = ColorSequence.new(Color3.fromRGB(255, 255, 255)), --白
    [2] = ColorSequence.new(Color3.fromRGB(0 ,  34 , 255)), --蓝
    [3] = ColorSequence.new(Color3.fromRGB(191, 61 , 255)), --紫
    [4] = ColorSequence.new(Color3.fromRGB(255, 255, 0  )), --橙
}

--符文粒子数量
local __rune_Light_Num ={
    {15,1,5},
    {40,20,4},
    {50,16,6},
    {60,20,6}
}


-------------------------------------------------------------------------------------------------------------------
---掉落物存储文件夹操作
-- 清除
function c:CleanDropsFol()
    if self.fol then
        for _, v in pairs(self.fol:GetChildren()) do
            v:Destroy()
        end
    end
end

-- 创建掉落物文件夹
function c:CreateFloInWorKSpace()
    self.fol = workspace:FindFirstChild(_str.fol_name_str) or Instance.new(_str.fol_type_str, workspace)
    self.fol.Name = _str.fol_name_str

    self.bag_fol = workspace:FindFirstChild(_str.bag_fol_name_str) or Instance.new(_str.fol_type_str, workspace)
    self.bag_fol.Name = _str.bag_fol_name_str
end
-- -- 创建金币钻石掉落物文件夹
-- function c:CreateFloInWorKSpace()
--     self.fol = workspace:FindFirstChild(_str.fol_name_str) or Instance.new(_str.fol_type_str, workspace)
--     self.fol.Name = _str.fol_name_str
-- end
--创建特效文件夹
function c:CreateEffFloInWorKSpace()
    self.eff_fol = workspace:FindFirstChild(_str.eff) or Instance.new(_str.fol_type_str, workspace)
    self.eff_fol.Name = _str.eff
end

-- 创建特殊掉落物文件夹
function c:CreateSpecialFloInWorKSpace()
    self.sp_fol = workspace:FindFirstChild(_str.sp_fol_name_str) or Instance.new(_str.fol_type_str, workspace)
    self.sp_fol.Name = _str.sp_fol_name_str
end

-- 创建 红色碎片掉落物文件夹
function c:CreateSplinterFloInWorKSpace()
    self.splinter_fol = workspace:FindFirstChild(_str.splinter_fol_name_str) or Instance.new(_str.fol_type_str, workspace)
    self.splinter_fol.Name = _str.splinter_fol_name_str
end
-------------------------------------------------------------------------------------------------------------------
--普通掉落物 钻石 和 金币
---@param pos Vector3 or instance 坐标或者实例
---@param drop_name string 用你之前上传的那组图片 
---@param drop_num number 数量
---@param bag_num  number 钱袋价值
function c:ShowDropCoin(pos,drop_name,value,drop_num,bag_value)
    
    if typeof(pos) ~= "Vector3" then
        warn(value, "pos is not a Vector3")
        return
    end
    if typeof(value) ~= "number" then
        warn(value, "value is not a number")
        return
    end
    if typeof(drop_num) ~= "number" then
        warn(drop_num, "num is not a number")
        return
    end
    self:CreateFloInWorKSpace() -- 创建文件夹
    self:ManyDropsTween(pos, drop_name, value, drop_num)
    if bag_value  and bag_value > 0 then
        self:ShowBagDrops(pos,drop_name,bag_value,drop_num)
    end
end

--特殊掉落物 符文
function c:ShowSpecialDrops(pos,id,qul,img_id)
    img_id = img_id or "rbxassetid://9168275275"

    local pfb = self:PreparePfb(pos,img_id)
    if not pfb then
        return
    end
    if typeof(pos) ~= "Vector3" then
        return
    end

    --扔进文件夹
    self:CreateSpecialFloInWorKSpace()
    pfb.Parent = self.sp_fol

    --改变拖尾颜色
    local sp_trail = pfb:FindFirstChild("Trail")
    sp_trail.Color = __rune_Coloer[qul]

    --改变Beam高度
    local hight = hotpot:GetPath_Loop("hight",pfb)
    if hight then
        hight.Position = __rune_Hight[qul]
    end
    --打开光效
    ---@type ParticleEmitter
    local rune_eff = hotpot:GetPath_Loop("rune_eff", pfb)
    -- light.Enabled = true
    for _,v in pairs(rune_eff:GetChildren()) do
        if v.ClassName == "Beam" then
            v.Color = __rune_Beam_Color[qul]
            v.Enabled = true
            if qul == 1 then
                v.Enabled = false
            end
        else
            v.Color = __rune_Coloer[qul]  
            v.Enabled = true
            v.Rate = __rune_Light_Num[qul][tonumber(v.Name)]
            if qul ~= 1  and tonumber(v.Name) == 3 then
                v.LightEmission = 0.5
            elseif qul == 1 and tonumber(v.Name) == 3 then
                v.LightEmission = 0.5
            end
        end
    end
   
    local bb = pfb:FindFirstChild("bb")
    bb.Size = UDim2.fromScale(3,3)

    local ran_vel = Vector3.new(
        math.random(-drop_cfg[_str.rune].ridus, drop_cfg[_str.rune].ridus),
        math.random(drop_cfg[_str.rune].min_y_hight, drop_cfg[_str.rune].max_y_hight),
        math.random(-drop_cfg[_str.rune].ridus, drop_cfg[_str.rune].ridus))
    pfb.Velocity = ran_vel

    -- wait(2)
    pfb:SetAttribute(_str.rune, _str.rune)
    pfb:SetAttribute("qul", qul)
    pfb:SetAttribute("id", id)
    insts_id = insts_id + 1 
    pfb:SetAttribute("insts_id", insts_id)
    Client_AudioManager:PlayToInst("Bos_explosion",pfb)
    Client_AudioManager:PlayToInst("gold_coins",pfb)

end

--掉落红色碎片
function c:ShowSplinter(pos,num)
    for i = 1, num do
        if math.random() > 0.5 then 
            wait(0.1)
        end
        self:DropSingalSplinter(pos)
    end
end

--单个掉落红色碎片
function c:DropSingalSplinter(pos)
    local image_id = drop_cfg[_str.splinter].icon
    local pfb = self:PreparePfb(pos,image_id)
    self:CreateSplinterFloInWorKSpace()
    pfb.Parent = self.splinter_fol
    local splinter = hotpot:GetPath_Loop("splinter",pfb)
    for _,v in pairs(splinter:GetChildren()) do
        v.Enabled = true
    end
    -- if splinter then
    --     splinter.Enabled = true
    -- end
    --改变拖尾颜色
    local sp_trail = pfb:FindFirstChild("Trail")
    sp_trail.Color = __rune_Coloer[5]
    local ran_vel = Vector3.new(
        math.random(-drop_cfg[_str.splinter].ridus,       drop_cfg[_str.splinter].ridus      ),
        math.random( drop_cfg[_str.splinter].min_y_hight, drop_cfg[_str.splinter].max_y_hight),
        math.random(-drop_cfg[_str.splinter].ridus,       drop_cfg[_str.splinter].ridus      ))
    pfb.Velocity = ran_vel
    pfb:SetAttribute(_str.splinter, 1)
    -- insts_id = insts_id + 1 
    -- pfb:SetAttribute("insts_id", insts_id)
    -- Client_AudioManager:PlayToInst("Bos_explosion",pfb)
    Client_AudioManager:PlayToInst("Red_wu_fragments",part)
end

-------------------------------------------------流程依赖函数--------------------------------------------------------------------------
-- 多次调用单次掉落方法形成的多掉落方法
local pfb
local _img_tabel
function c:ManyDropsTween(pos, drop_name, value, drop_num)
    _img_tabel = self:DropIconWithNum(drop_name, value ,drop_num)
    if _img_tabel then
        for _, v in pairs(_img_tabel) do
            self:SingleDropsTween( pos,drop_name, v.img_id, v.value )
            if  math.random(1, 2) == 1 then
                wait(0.1)
            end
        end
    end
end
-- 单次掉落的方法，不适合直接调用 ***
local random_velocity
local max_y 
local min_y 
local r
function c:SingleDropsTween(pos,drop_name,img_id,value)
    pfb = self:PreparePfb(pos, img_id ,drop_cfg[drop_name].color) -- 准备好克隆体，为其设置好，和力的控件
    r = drop_cfg[drop_name].ridus
    min_y = drop_cfg[drop_name].min_y_hight 
    max_y = drop_cfg[drop_name].max_y_hight
    random_velocity = Vector3.new(math.random(-r,r),math.random(min_y,max_y),math.random(-r,r)) 
    pfb.Velocity = random_velocity
    -- wait(2)
    self:ShowEff(drop_name,pos)
    pfb:SetAttribute(drop_name, value)
    return true
end
--掉落 钱袋或者钻石袋
local image_id
local pfb_pre 
function c:ShowBagDrops(pos,drop_name,bag_value,drop_num)
    image_id = drop_cfg[drop_name].big
    pfb_pre = self:PreparePfb(pos,image_id,drop_cfg[drop_name].color,bag_value)
    r = drop_cfg[drop_name].ridus
    min_y = drop_cfg[drop_name].min_y_hight 
    max_y = drop_cfg[drop_name].max_y_hight
    random_velocity = Vector3.new(math.random(-r,r),math.random(min_y,max_y),math.random(-r,r)) 
    pfb_pre.Velocity = random_velocity
    -- wait(2)
    self:ShowEff(drop_name,pos)
    -- pfb_pre.Size = pfb_pre.Size*2
    pfb_pre:SetAttribute(bag_str[drop_name], bag_value)
    pfb_pre:SetAttribute("drop_num", drop_num)
end
--制备好预制体***
local pfb_pre
local coin
local emitter
local trail
---@type BillboardGui
local bb
function c:PreparePfb(pos, img_id,Color,bag_value)
    pfb_pre = self.coin_pfb:Clone() -- 克隆
    pfb_pre.Position = pos -- 设置坐标
    bb = hotpot:GetPath_Loop("bb",pfb_pre)
    if bag_value then
        pfb_pre.Parent = self.bag_fol -- 移入文件夹
        bb.Size = UDim2.fromScale(4,4)
        bb.SizeOffset = Vector2.new(0,0.35)
    else
        pfb_pre.Parent = self.fol -- 移入文件夹 
    end
    Drops_Obj.new(pfb_pre,bag_value)
    coin = hotpot:GetPath_Loop("bb.coin",pfb_pre)
    coin.Image = img_id
    if Color then
        emitter = hotpot:GetPath_Loop("light.Stars",pfb_pre)
        emitter.Enabled = true
        trail = hotpot:GetPath_Loop("Trail",pfb_pre)
        emitter.Color = ColorSequence.new(Color3.fromHex(Color))
        trail.Color   = ColorSequence.new(Color3.fromHex(Color))
    end

    return pfb_pre
end
--根据提供的数量和价值掉金币***
local left
local sg
local _img_tabel
local _img_id
function c:DropIconWithNum(drop_name, value ,drop_num )
    if not drop_cfg[drop_name] then
        return
    end
    if drop_num <= 0 or value <= 0  then
        return
    end

    _img_tabel = {}
    left = value -- 剩余价值
    if drop_num == 1 then
        table.insert(_img_tabel, {value = value, img_id = drop_cfg[drop_name].icon})
        return _img_tabel
    end
    _img_id =  drop_cfg[drop_name].icon

    while true do
        sg = value
        if sg > 10  then
            sg = math.ceil(value / drop_num * (math.random(7,13)/10)) 
        end

        if left > 0 and left > sg then
            table.insert(_img_tabel, {value = sg, img_id = _img_id})
            left = left - sg
        elseif left > 0 and left <= sg then
            table.insert(_img_tabel, {value = left, img_id = _img_id})
            return _img_tabel
        else
            return _img_tabel
        end
    end

end

local eff_part
function c:ShowEff(_type,pos)

    eff_part = self.eff[_type]:Clone()

    self:CreateEffFloInWorKSpace()
    eff_part.Parent = self.eff_fol

    eff_part.Position = pos

    for k,v in pairs(eff_part.Attachment:GetChildren()) do
        v:Emit(1) 
    end
    Client_AudioManager:PlayToInst("Bos_explosion",eff_part)
    Client_AudioManager:PlayToInst("gold_coins",eff_part)
    Debris:AddItem(eff_part,1.5)
end



-- --决定随机价值的出现的Icon
-- local left
-- local sg
-- local _img_tabel
-- local _group
-- local _img_id
-- local random
-- local _size_ratio
-- function c:RandomDropIcon(group_name, value ,num)
--     if not __Drops_Image_Table[group_name] then
--         return
--     end

--     if how_much then 
--        local range =  __Drops_Image_Table[group_name][how_much]
--     end

--     left = value -- 剩余价值

--     _img_tabel = {} -- 创建空表

--     _group = __Drops_Image_Table[group_name][how_much] -- 拿到想要的Icon组

--     for i = 1, 1000 do
--         random = math.random(1, #_group)

--         _size_ratio = _group[random].ratio / 100

--         _img_id = _group[random].img_id
--         sg = value * _size_ratio
--         if left > 0 and left > sg then
--             table.insert(_img_tabel, {value = sg, img_id = _img_id, size_ratio = _size_ratio})
--             left = left - sg
--         elseif left > 0 and left <= sg then
--             if left < value * _group[1].ratio / 100 then
--                 table.insert(_img_tabel, {value = left, img_id = _group[1].img_id, size_ratio = _size_ratio})
--             else
--                 table.insert(_img_tabel, {value = left, img_id = _img_id, size_ratio = _size_ratio})
--             end

--             return _img_tabel
--         end
--     end

-- end

-- -- 将某总价的随机拆分为占比10-20-...100的的金币，金币价值不超过总价
-- local random_ratio = 0
-- local left = 0 -- 剩余价值
-- local sg = 0 -- 单次算出的价值
-- local random_group

-- function c:PureRandomDividedValue(group_name, value)
--     if not __Drops_Image_Table[group_name] then
--         return
--     end

--     left = value -- 剩余价值

--     _img_tabel = {} -- 创建空表

--     _group = __Drops_Image_Table[group_name] -- 拿到想要的Icon组

--     for i = 1, 100 do
--         random_group = math.random(1, #_group) -- 随机拿一个组的图片
--         random_ratio = math.random(1, 100) / 100 -- 随机价值比

--         _size_ratio = _group[random_group].ratio / 100 -- 从表里拿比例

--         _img_id = _group[random_group].img_id -- 从表里拿图片

--         sg = value * random_ratio

--         if left > 0 and left > sg then
--             table.insert(_img_tabel, {value = sg, img_id = _img_id, size_ratio = _size_ratio})
--             left = left - sg
--         elseif left > 0 and left <= sg then
--             table.insert(_img_tabel, {value = left, img_id = _img_id, size_ratio = _size_ratio})
--             return _img_tabel
--         end
--     end

-- end

-- local _times
-- -- 按照给定的比例掉落
-- function c:RatioDropIcon(group_name, value)
--     if not __Drops_Image_Table[group_name] then
--         return
--     end

--     left = value -- 剩余价值

--     _img_tabel = {} -- 创建空表

--     _group = __Drops_Image_Table[group_name] -- 拿到想要的Icon组
--     _size_ratio = _group[1].ratio / 100
--     sg = value * _size_ratio
--     _times = value / sg
--     for i = 1, _times do
--         _img_id = _group[1].img_id
--         if left > 0 and left > sg then
--             table.insert(_img_tabel, {value = sg, img_id = _img_id, size_ratio = _size_ratio})
--             left = left - sg
--         elseif left > 0 and left <= sg then
--             table.insert(_img_tabel, {value = left, img_id = _img_id, size_ratio = _size_ratio})
--             return _img_tabel
--         end
--     end
-- end

-- -----------------------------------------------自用函数----------------------------------------------------------------------------------------------
-- -- 按照给予的百分比向下取整次数
-- local quotient = 0 -- 商
-- function c:PercentDividedValue(value, _times)
--     quotient = math.floor(value / _times)

--     return quotient
-- end



-- -- 创建碰撞组,并关闭其和默认组的碰撞
-- function c:CreateDropColliderGroup()
--     PhysicsService:CreateCollisionGroup(Drops_Group_str)
--     PhysicsService:CollisionGroupSetCollidable(Drops_Group_str, Default_str, false)
-- end
-- -- 将掉落物添加到Drop组里
-- function c:AddDropInToColliderGroup(inst)
--     PhysicsService:SetPartCollisionGroup(inst, Drops_Group_str)
-- end
-- -- 检查参数
-- function c:CheckAndWarn(pos, num)
--     if typeof(pos) ~= vector3_str then
--         assert(pos, "need a vector3, get a", typeof(pos))
--         return
--     end

--     if typeof(num) ~= num_str then
--         assert(num, "need a vector3, get a", typeof(num))
--         return
--     end
-- end

return c
