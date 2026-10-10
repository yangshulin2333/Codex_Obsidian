--dep: pvpshop
--out: pvpshop

local pvpshop = Data.pvpshop

for k,v in pairs(pvpshop)do
    local reward = v.reward

    if reward then
        local temp = {}
        for num in string.gmatch(reward, "%d+") do
            table.insert(temp, tonumber(num))
        end
        v.reward = temp
    end
end

return pvpshop