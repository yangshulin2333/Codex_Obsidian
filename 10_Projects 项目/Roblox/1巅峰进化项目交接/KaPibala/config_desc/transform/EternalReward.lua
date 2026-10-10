--dep: EternalReward
--out: EternalReward

local EternalReward = Data.EternalReward

for k,v in pairs(EternalReward)do
    local reward = v.reward1

    if reward then
        local temp = {}
        for num in string.gmatch(reward, "%d+") do
            table.insert(temp, tonumber(num))
        end
        v.reward1 = temp
    end

    local reward = v.reward2

    if reward then
        local temp = {}
        for num in string.gmatch(reward, "%d+") do
            table.insert(temp, tonumber(num))
        end
        v.reward2 = temp
    end 

end

return EternalReward