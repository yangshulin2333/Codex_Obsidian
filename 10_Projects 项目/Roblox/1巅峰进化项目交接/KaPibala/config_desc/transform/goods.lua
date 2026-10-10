--dep: goods
--out: goods

local goods = Data.goods

for k,v in pairs(goods)do
    local reward = v.reward

    if reward then
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

end

return goods