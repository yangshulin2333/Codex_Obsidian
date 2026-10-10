--dep: skillBox
--out: skillBox

local skillBox = Data.skillBox

for k,v in pairs(skillBox)do
    local reward = v.reward

    if reward then
        local temp = {}
        for num in string.gmatch(reward, "%d+") do
            table.insert(temp, tonumber(num))
        end
        v.reward = temp
    end
end

return skillBox
