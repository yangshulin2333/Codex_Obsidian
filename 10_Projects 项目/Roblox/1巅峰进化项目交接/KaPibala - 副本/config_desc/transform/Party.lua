--dep: Party
--out: Party

local Party = Data.Party

for k,v in ipairs(Party)do
    for i = 1,3 do
        local str = 'lv'..i..'Reward'
        local reward = v[str]
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
        v[str] = result
    end
end

return Party