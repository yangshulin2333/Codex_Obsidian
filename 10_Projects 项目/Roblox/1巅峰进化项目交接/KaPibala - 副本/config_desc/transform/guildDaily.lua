--dep: guildDaily
--out: guildDaily

local guildDaily = Data.guildDaily

for k,v in pairs(guildDaily)do
    local reward = v.reward

    if reward then
        local temp = {}
        for num in string.gmatch(reward, "%d+") do
            table.insert(temp, tonumber(num))
        end
        v.reward = temp
    end
end

return guildDaily