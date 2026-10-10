--dep: online_reward
--out: online_reward

local online_reward = Data.online_reward

for k,v in pairs(online_reward)do
    local reward = v.reward
    local result = {}
    for num in string.gmatch(reward, "%d+") do
        table.insert(result, tonumber(num))
    end
    v.reward = result
end

return online_reward