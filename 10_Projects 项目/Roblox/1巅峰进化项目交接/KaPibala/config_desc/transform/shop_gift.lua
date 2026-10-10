--dep: shop_gift
--out: shop_gift

local shop_gift = Data.shop_gift

for k,v in pairs(shop_gift)do
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

return shop_gift