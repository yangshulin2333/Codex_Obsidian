--dep: guildShop
--out: guildShop

local guildShop = Data.guildShop

for k,v in pairs(guildShop)do
    local reward = v.reward

    if reward then
        local temp = {}
        for num in string.gmatch(reward, "%d+") do
            table.insert(temp, tonumber(num))
        end
        v.reward = temp
    end
end

return guildShop