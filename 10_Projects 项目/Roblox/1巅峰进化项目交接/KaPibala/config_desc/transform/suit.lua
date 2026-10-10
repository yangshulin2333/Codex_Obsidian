--dep: suit
--out: suit

local suit = Data.suit

for k,v in pairs(suit)do
    local set2 = v.set2
    local part1, part2 = string.match(set2, "^(.*)_(.*)$")
    v.set2 = {
        prop = part1,value = tonumber(part2)
    }

    local set4 = v.set4
    local part1, part2 = string.match(set4, "^(.*)_(.*)$")
    v.set4 = {
        prop = part1,value = tonumber(part2)
    }

    local set6 = v.set6
    local part1, part2 = string.match(set6, "^(.*)_(.*)$")
    v.set6 = {
        prop = part1,value = tonumber(part2)
    }
end

return suit