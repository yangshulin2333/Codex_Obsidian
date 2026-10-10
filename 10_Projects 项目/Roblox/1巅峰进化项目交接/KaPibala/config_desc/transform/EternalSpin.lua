--dep: EternalSpin
--out: EternalSpin

local EternalSpin = Data.EternalSpin

for k,v in pairs(EternalSpin)do
    local reward = v.reward

    if reward then
        local temp = {}
        for num in string.gmatch(reward, "%d+") do
            table.insert(temp, tonumber(num))
        end
        v.reward = temp
    end
end

return EternalSpin