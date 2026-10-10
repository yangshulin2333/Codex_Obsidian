local os = os
---@class PlayerData
local c = {}
local version_update = {}
c.version_update = version_update
function c.GetInitData()
    return {
        version = 0,
        regist_time = os.time(),
        version_num = {
            num = 0,
        },
        prop = {
            gems = 0,--钻石
            exp = 0,--经验值
            lv = 1,--等级
            wins = 0,--奖杯数量
            reborn = 0,--重生次数
            free_gems = {
                num = 0,
                mark = 0,
            },
            potion = {
                num = 0,
                mark = 0,
            },--药水
            newPlayer = true,
            pvp_coin = 0,--pvp币
        },--属性
        character = {
            list = {[1] = true},
            equiped = 1,--当前装备
        },--角色
        pet = {
            inst_id = 0,--宠物实例id
            list = {},
            equiped = {},--当前装备
            max_equip = 3,--最大装备数量
            max_capacity = 50,--最大容量
            index = {},--索引
        },--宠物
        relics = {
            inst_id = 0,--宠物实例id
            list = {},
            equiped = {
                {unlock = true,relics_id = nil,},
                {unlock = true,relics_id = nil,},
                {unlock = true,relics_id = nil,},
                {unlock = false,relics_id = nil,buy = false},
                {unlock = false,relics_id = nil,buy = false},
                {unlock = false,relics_id = nil,buy = false},
                {unlock = false,relics_id = nil},
                {unlock = false,relics_id = nil},
                {unlock = false,relics_id = nil},
            },--当前装备
            -- max_capacity = 50,--最大容量
            box = {
                num = 0,--已开启数量
                mark = 0,--上次开启时间
            },--箱子
            index = {},--索引
            scrolls = {},--卷轴
            mapScrollShop = {
                list = {},
                mark = 0,
            },
            smelt_coin = 0,--分解币
            smelt_shop = {
                mark = 0,
                list = {},
            },--分解商店
            luckyStone = {
                list = {},
            },--幸运石
            forgeStone = {
                list = {},
            },
        },--文物
        bag = {
            boosts = {
                list = {},
                used = {},
            },--药水
            res = {
                list = {},
            },--资源
            creates = {
                list = {},
            },--箱子
        },--item背包
        task = {
            list = {},
            unlock = false,
            mark = 0,
        },--任务
        shop = {
            gift_list = {
                version = 1,--期数
                get = 0,--领取
            },
            relice_box = {
                list = {}
            },
            lucky = {
                num = 0,--当前倍率
                time_ = 0,--使用时间
            },
        },--商店
        pay = {
            pay_list = {}
        },
        daily = {
            mark = 0,--标记
            get = 0,--已领取的
            can_get = false,--是否能领取
        },--每日
        upgrade = {
            list = {},
        },--升级
        stage = {
            list = {[1] = true},
        },
        free_pet = {
            num = 0,
        },
        battle_pass = {
            season = 1,
            lv = 0,
            exp = 0,
            is_primium = false,
            get = {
                free = {},
                primium = {},
            },
            mark = 0,
            task = {
                {done = false,num = 0},{done = false,num = 0},{done = false,num = 0},
                {done = false,num = 0},{done = false,num = 0},{done = false,num = 0},
            },
        },
        guide = {
            num = 0,
        },
        analytics = {
            upgrade = 1,
        },
        code = {
            list = {},
        },
        map_shop = {
            mark = 0,
            list = {},
        },
        eternal = {
            season = 1,--赛季
            daily_mark = 0,--每日标记
            hour_mark = 0,--小时标记
            lv = 0,--等级
            exp = 0,--经验值
            is_primium = false,--会员
            get = {
                free = {},
                primium = {},
            },--已领取
            task = {
                {done = false,num = 0},{done = false,num = 0},{done = false,num = 0},
                {done = false,num = 0},{done = false,num = 0},{done = false,num = 0},
                {done = false,num = 0},{done = false,num = 0},{done = false,num = 0},
            },--任务
            ticket = 0,--票据
            coin = 0,--金币
            shop = {
                list = {}
            },
        },
        stats = {
            eggs = 0,
            total_dmg = 0,
        },--统计
        free_potion = {
            mark = 0,
        },--免费药水
        title = {
            list = {},
            max = 5,
            equiped = 0,
        },--称号
        christmas = {
            friend_list = {},
        },--圣诞节
        skill = {
            list = {},
            equiped = {
                {unlock = true,skill_id = nil},
                {unlock = false,skill_id = nil},
                {unlock = false,skill_id = nil},
            },
            max_equiped = 1,
        },--技能
        mount = {
            equiped = 0,
            list = {},
            chip = {},
        },--坐骑
        guild = {
            id = nil,
            coin = 0,
            shop = {
                list = {},
                mark = 0,
            },
            daily = {
                mark = 0,--标记
                get = 0,--已领取的
                can_get = false,--是否能领取
            },
            getWarReward = -100,--已领取的周数
            worship = {
                mark = 0,
                get = false,
            },--膜拜
        },
        pvp_shop = {
            mark = 0,
            list = {},
        },
        gift_list = {},--赠送列表
        challenge = {
            list = {},--已领取
            mark = 0,--标记
        },--挑战
        guide2 = {
            stage = {},--已通过关卡
            first_send_skill = false,--是否第一次发送技能
        },--引导2
        setting = {
            close_music = false,
            close_sound = false,
        },--设置
        pvp_buff = {
            mark = 0,--标记
            list = {
                atk = {big = 0,small = 0},
                hp = {big = 0,small = 0},
                atkspeed = {big = 0,small = 0},
                speed = {big = 0,small = 0},
            },
            free = {},
        },--pvpBuff
        new_daily = {
            mark = 0,
            get_list = {},
            get = 0,--已领取的
            can_get = false,--是否能领取
        },--新每日
        continuous_login = {
            mark = 0,--标记
            day = 0,--连续登录天数
        },
    }
end

version_update[1] = function(data)
    data.guide = {
        num = 0,
    }
    data.analytics = {
        upgrade = 1,
    }
end

version_update[2] = function(data)
    data.code = {
        list = {},
    }
end

version_update[3] = function(data)
    data.map_shop = {
        mark = 0,
        list = {},
    }
end

version_update[4] = function(data)
    data.eternal = {
        season = 1,--赛季
        daily_mark = 0,--每日标记
        hour_mark = 0,--小时标记
        lv = 0,--等级
        exp = 0,--经验值
        is_primium = false,--会员
        get = {
            free = {},
            primium = {},
        },--已领取
        task = {
            {done = false,num = 0},{done = false,num = 0},{done = false,num = 0},
            {done = false,num = 0},{done = false,num = 0},{done = false,num = 0},
            {done = false,num = 0},{done = false,num = 0},{done = false,num = 0},
        },--任务
        ticket = 0,--票据
        coin = 0,--金币
        shop = {
            list = {}
        },
    }
end

version_update[5] = function(data)
    data.pet.index = {}
    data.relics.index = {}
end

version_update[6] = function(data)
    data.relics.scrolls = {}
end

version_update[7] = function(data)
    data.relics.mapScrollShop = {
        list = {},
        mark = 0,
    }
    data.relics.smelt_coin = 0
    data.relics.smelt_shop = {
        mark = 0,
        list = {},
    }
end

version_update[8] = function(data)
    data.prop.potion = {
        num = 0,
        mark = 0,
    }--药水
end

version_update[9] = function(data)
    data.stats = {
        eggs = 0,
        total_dmg = 0,
    }--统计
end

version_update[10] = function(data)
    data.free_potion = {
        mark = 0,
    }--免费药水
end

version_update[11] = function(data)
    data.title = {
        list = {},
        max = 5,
        equiped = 0,
    }--称号
end

version_update[12] = function(data)
    data.christmas = {
        friend_list = {},
    }
end

version_update[13] = function(data)
    data.skill = {
        list = {},
        equiped = {
            {unlock = true,skill_id = nil},
            {unlock = false,skill_id = nil},
            {unlock = false,skill_id = nil},
        },
        max_equiped = 1,
    }
end

version_update[14] = function(data)
    data.mount = {
        equiped = 0,
        list = {},
        chip = {},
    }
end

version_update[15] = function(data)
    data.guild = {
        id = nil,
        coin = 0,
        shop = {
            list = {},
            mark = 0,
        },
        daily = {
            mark = 0,--标记
            get = 0,--已领取的
            can_get = false,--可领取的
        },
    }
end

version_update[16] = function(data)
    data.relics.luckyStone = {
        list = {},
    }--强化石
    data.relics.forgeStone = {
        list = {},
    }
end

version_update[17] = function(data)
    data.prop.pvp_coin = 0--pvp币
end

version_update[18] = function(data)
    data.pvp_shop = {
        mark = 0,
        list = {},
    }
end

version_update[19] = function(data)
    data.gift_list = {}--赠送列表
end

version_update[20] = function(data)
    data.challenge = {
        list = {},--已领取
        mark = 0,--标记
    }--挑战
end

version_update[21] = function(data)
    data.guide2 = {
        stage = {},--已通过关卡
        first_send_skill = false,
    }--引导2
end

version_update[22] = function(data)
    data.setting = {
        close_music = false,
        close_sound = false,
    }--设置
end

version_update[23] = function(data)
    data.pvp_buff = {
        mark = 0,--标记
        list = {
            atk = {big = 0,small = 0},
            hp = {big = 0,small = 0},
            atkspeed = {big = 0,small = 0},
            speed = {big = 0,small = 0},
        },
        free = {},
    }--pvpBuff
end

version_update[24] = function(data)
    data.new_daily = {
        mark = 0,
        get_list = {},
        get = 0,--已领取的
        can_get = false,--是否能领取
    }--新每日
end

version_update[25] = function(data)
    data.continuous_login = {
        mark = 0,--标记
        day = 0,--连续登录天数
    }
end

version_update[26] = function(data)
    data.guild.getWarReward = -100
    data.guild.worship = {
        mark = 0,
        get = false,
    }--膜拜
end

return c
