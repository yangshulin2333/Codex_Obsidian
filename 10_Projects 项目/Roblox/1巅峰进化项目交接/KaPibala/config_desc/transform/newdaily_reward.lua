--dep: newdaily_reward
--out: newdaily_reward

local newdaily_reward = Data.newdaily_reward

for k,v in pairs(newdaily_reward)do
    local reward = v.reward
    local result = {}

    if reward:find('#') then
        for str in reward:gmatch('([^#]+)')do
            local temp = {}
            for num in string.gmatch(str, "%d+") do
                table.insert(temp, tonumber(num))
            end
            table.insert(result,temp)
        end
    else
        local temp = {}
        for num in string.gmatch(reward, "%d+") do
            table.insert(temp, tonumber(num))
        end
        table.insert(result,temp)
    end
    v.reward = result
end

return newdaily_reward