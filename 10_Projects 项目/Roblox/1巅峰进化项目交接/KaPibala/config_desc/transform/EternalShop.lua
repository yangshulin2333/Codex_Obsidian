--dep: EternalShop
--out: EternalShop

local EternalShop = Data.EternalShop

for k,v in pairs(EternalShop)do
    local reward = v.reward

    if reward then
        local temp = {}
        for num in string.gmatch(reward, "%d+") do
            table.insert(temp, tonumber(num))
        end
        v.reward = temp
    end
end

return EternalShop