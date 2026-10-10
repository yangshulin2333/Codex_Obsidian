local bitTab = {
    [0] = {
        bit = 3,
        name = "",
        code = ""
    },
    [1] = {
        bit = 3,
        name = "kilo",
        code = "K"
    },
    [2] = {
        bit = 6,
        name = "million",
        code = "M"
    },
    [3] = {
        bit = 9,
        name = "billion",
        code = "B"
    },
    [4] = {
        bit = 12,
        name = "trillion",
        code = "T"
    },
    [5] = {
        bit = 15,
        name = "quadrillion",
        code = "Qa"
    },
    [6] = {
        bit = 18,
        name = "quintillion",
        code = "Qi"
    },
    [7] = {
        bit = 21,
        name = "sextillion",
        code = "Sx"
    },
    [8] = {
        bit = 24,
        name = "septillion",
        code = "Sp"
    },
    [9] = {
        bit = 27,
        name = "octillion",
        code = "Oc"
    },
    [10] = {
        bit = 30,
        name = "nonillion",
        code = "No"
    },
    [11] = {
        bit = 33,
        name = "decillion",
        code = "Do"
    },
    [12] = {
        bit = 36,
        name = "undecillion",
        code = "Ud"
    },
    [13] = {
        bit = 39,
        name = "duodecillion",
        code = "D"
    },
    [14] = {
        bit = 42,
        name = "tredecillion",
        code = "tdD"
    },
    [15] = {
        bit = 45,
        name = "quattuordecillion",
        code = "QdD"
    },
    [16] = {
        bit = 48,
        name = "quindecillion",
        code = "QnD"
    },
    [17] = {
        bit = 51,
        name = "sexdecillion",
        code = "SxD"
    },
    [18] = {
        bit = 54,
        name = "septendecillion",
        code = "SpD"
    },
    [19] = {
        bit = 57,
        name = "octodecillion",
        code = "OcD"
    },
    [20] = {
        bit = 60,
        name = "novemdecillion",
        code = "NvD"
    },
    [21] = {
        bit = 63,
        name = "vigintillion",
        code = "Vgn"
    },
    [22] = {
        bit = 66,
        name = "unvigintillion",
        code = "Uvg"
    },
    [23] = {
        bit = 69,
        name = "duovigintillion",
        code = "DvD"
    },
    [24] = {
        bit = 72,
        name = "trevigintillion",
        code = "Tvg"
    },
    [25] = {
        bit = 75,
        name = "quattuorvigintillion",
        code = "QaV"
    },
    [26] = {
        bit = 78,
        name = "quinvigintillion",
        code = "QiV"
    },
    [27] = {
        bit = 81,
        name = "sexvigintillion",
        code = "SxV"
    },
    [28] = {
        bit = 84,
        name = "septenvigintillion",
        code = "SpV"
    },
    [29] = {
        bit = 87,
        name = "octovigintillion",
        code = "OcV"
    },
    [30] = {
        bit = 90,
        name = "novemvigintillion",
        code = "NvT"
    },
    [31] = {
        bit = 93,
        name = "trigintillion",
        code = "TT"
    },
    [32] = {
        bit = 96,
        name = "untrigintillion",
        code = "UG"
    },
    [33] = {
        bit = 99,
        name = "duotrigintillion",
        code = "DG"
    },
    [34] = {
        bit = 102,
        name = "tretrigintillion",
        code = "TG"
    },
    [35] = {
        bit = 105,
        name = "quattuortrigintillion",
        code = "QG"
    },
    [36] = {
        bit = 108,
        name = "quintrigintillion",
        code = "QuG"
    },
    [37] = {
        bit = 111,
        name = "sextrigintillion",
        code = "SxT"
    },
    [38] = {
        bit = 114,
        name = "septentrigintillion",
        code = "SpT"
    },
    [39] = {
        bit = 117,
        name = "octotrigintillion",
        code = "OgT"
    },
    [40] = {
        bit = 120,
        name = "novemtrigintillion",
        code = "NgT"
    },
    [41] = {
        bit = 123,
        name = "quadragintillion",
        code = "QgT"
    },
    [42] = {
        bit = 126,
        name = "unquadragintillion",
        code = "UgT"
    },
    [43] = {
        bit = 129,
        name = "duoquadragintillion",
        code = "DgT"
    },
    [44] = {
        bit = 132,
        name = "trequadragintillion",
        code = "TgT"
    },
    [45] = {
        bit = 135,
        name = "quattuorquadragintillion",
        code = ""
    },
    [46] = {
        bit = 138,
        name = "quinquadragintillion",
        code = ""
    },
    [47] = {
        bit = 141,
        name = "sexquadragintillion",
        code = ""
    },
    [48] = {
        bit = 144,
        name = "septenquadragintillion",
        code = ""
    },
    [49] = {
        bit = 147,
        name = "octoquadragintillion",
        code = ""
    },
    [50] = {
        bit = 150,
        name = "novemquadragintillion",
        code = ""
    },
    [51] = {
        bit = 153,
        name = "quinquagintillion",
        code = ""
    },
    [52] = {
        bit = 156,
        name = "unquinquagintillion",
        code = ""
    },
    [53] = {
        bit = 159,
        name = "duoquinquagintillion",
        code = ""
    },
    [54] = {
        bit = 162,
        name = "trequinquagintillion",
        code = ""
    },
    [55] = {
        bit = 165,
        name = "quattuorquinquagintillion",
        code = ""
    },
    [56] = {
        bit = 168,
        name = "quinquinquagintillion",
        code = ""
    },
    [57] = {
        bit = 171,
        name = "sexquinquagintillion",
        code = ""
    },
    [58] = {
        bit = 174,
        name = "septenquinquagintillion",
        code = ""
    },
    [59] = {
        bit = 177,
        name = "octoquinquagintillion",
        code = ""
    },
    [60] = {
        bit = 180,
        name = "novemquinquagintillion",
        code = ""
    },
    [61] = {
        bit = 183,
        name = "sexagintillion",
        code = ""
    },
    [62] = {
        bit = 186,
        name = "unsexagintillion",
        code = ""
    },
    [63] = {
        bit = 189,
        name = "duosexagintillion",
        code = ""
    },
    [64] = {
        bit = 192,
        name = "tresexagintillion",
        code = ""
    },
    [65] = {
        bit = 195,
        name = "quattuorsexagintillion",
        code = ""
    },
    [66] = {
        bit = 198,
        name = "quinsexagintillion",
        code = ""
    },
    [67] = {
        bit = 201,
        name = "sexsexagintillion",
        code = ""
    },
    [68] = {
        bit = 204,
        name = "septensexagintillion",
        code = ""
    },
    [69] = {
        bit = 207,
        name = "octosexagintillion",
        code = ""
    },
    [70] = {
        bit = 210,
        name = "novemsexagintillion",
        code = ""
    },
    [71] = {
        bit = 213,
        name = "septuagintillion",
        code = ""
    },
    [72] = {
        bit = 216,
        name = "unseptuagintillion",
        code = ""
    },
    [73] = {
        bit = 219,
        name = "duoseptuagintillion",
        code = ""
    },
    [74] = {
        bit = 222,
        name = "treseptuagintillion",
        code = ""
    },
    [75] = {
        bit = 225,
        name = "quattuorseptuagintillion",
        code = ""
    },
    [76] = {
        bit = 228,
        name = "quinseptuagintillion",
        code = ""
    },
    [77] = {
        bit = 231,
        name = "sexseptuagintillion",
        code = ""
    },
    [78] = {
        bit = 234,
        name = "septenseptuagintillion",
        code = ""
    },
    [79] = {
        bit = 237,
        name = "octoseptuagintillion",
        code = ""
    },
    [80] = {
        bit = 240,
        name = "novemseptuagintillion",
        code = ""
    },
    [81] = {
        bit = 243,
        name = "octogintillion",
        code = ""
    },
    [82] = {
        bit = 246,
        name = "unoctogintillion",
        code = ""
    },
    [83] = {
        bit = 249,
        name = "duooctogintillion",
        code = ""
    },
    [84] = {
        bit = 252,
        name = "treoctogintillion",
        code = ""
    },
    [85] = {
        bit = 255,
        name = "quattuoroctogintillion",
        code = ""
    },
    [86] = {
        bit = 258,
        name = "quinoctogintillion",
        code = ""
    },
    [87] = {
        bit = 261,
        name = "sexoctogintillion",
        code = ""
    },
    [88] = {
        bit = 264,
        name = "septenoctogintillion",
        code = ""
    },
    [89] = {
        bit = 267,
        name = "octooctogintillion",
        code = ""
    },
    [90] = {
        bit = 270,
        name = "novemoctogintillion",
        code = ""
    },
    [91] = {
        bit = 273,
        name = "nonagintillion",
        code = ""
    },
    [92] = {
        bit = 276,
        name = "unnonagintillion",
        code = ""
    },
    [93] = {
        bit = 279,
        name = "duononagintillion",
        code = ""
    },
    [94] = {
        bit = 282,
        name = "trenonagintillion",
        code = ""
    },
    [95] = {
        bit = 285,
        name = "quattuornonagintillion",
        code = ""
    },
    [96] = {
        bit = 288,
        name = "quinnonagintillion",
        code = ""
    },
    [97] = {
        bit = 291,
        name = "sexnonagintillion",
        code = ""
    },
    [98] = {
        bit = 294,
        name = "septennonagintillion",
        code = ""
    },
    [99] = {
        bit = 297,
        name = "octononagintillion",
        code = ""
    },
    [100] = {
        bit = 300,
        name = "novemnonagintillion",
        code = ""
    },
    [101] = {
        bit = 303,
        name = "centillion",
        code = ""
    }
}

local time_str = "%02d:%02d:%02d"

---@class BigNumberHelper
local c = {}
local ustart = 64
local uend = 90
local bit = 3
local function GetIn(num)
    local str = string.format('%c', num % 26 + 65)
    local nextNum = math.floor(num / 26)
    if nextNum > 0 then
        str = GetIn(nextNum - 1) .. str
    end
    return str
end
local function GetUnit(bit)
    local unitCount = math.floor((bit - 1) / 3)
    return GetIn(unitCount)
end
function c:SetBit(bit)
end
local NumCheck = {}
local GetThousandStr
local threeZerStr = "%03d"
function GetThousandStr(num)
    local front_num = math.floor(num / 1000)
    local over_num = math.floor(num % 1000)
    if front_num >= 1000 then
        return GetThousandStr(front_num) .. "," .. string.format(threeZerStr, over_num)
    elseif front_num >= 1 then
        return front_num .. "," .. string.format(threeZerStr, over_num)
    else
        return num
    end
end
-- 将数字转化成可以看的文本(10000->10,000)
---@type fun(num:number):string
function c:GetThousandStr(num)
    if num / 1000000000 > 1 then
        return self:ToString(num)
    else
        return GetThousandStr(num)
    end
end
function c:ToStringWithLetters(num)
    local str = tostring(num)
    local dotBit = string.find(str, '[.]')
    local ebit = string.find(str, '[e+]')
    local intStr = string.sub(str, 1, (dotBit or ebit or #str + 1) - 1)
    local floatStr = ""
    local bitStr = ""
    local bitNum = #intStr
    if dotBit then
        floatStr = string.sub(str, dotBit + 1, (ebit or #str + 1) - 1)
    end
    if ebit then
        bitStr = string.sub(str, ebit + 2, #str)
        bitNum = bitNum + tostring(bitStr)
    end
    local unitNum = math.floor((bitNum - 1) / 3)
    local bitNum = bitNum - unitNum * 3
    -- 判断需要移动多少整数到小数去
    if #intStr > bitNum then
        floatStr = string.sub(intStr, bitNum + 1, #intStr) .. floatStr
        intStr = string.sub(intStr, 1, bitNum)
    elseif #intStr < bitNum then
        local bbit = bitNum - #intStr
        intStr = intStr .. string.sub(floatStr, 1, bbit)
        floatStr = string.sub(floatStr, bbit + 1, #floatStr)
        if #intStr < bitNum then
            for i = 1, bbit, 1 do
                intStr = intStr .. "0"
            end
        end
    end
    if #floatStr > 3 then
        floatStr = string.sub(floatStr, 1, 3)
    end
    while #floatStr > 0 and string.sub(floatStr, #floatStr, #floatStr) == '0' do
        floatStr = string.sub(floatStr, 1, #floatStr - 1)
    end
    local result = intStr
    if floatStr ~= "" and floatStr ~= "000" then
        result = result .. "." .. floatStr
    end
    result = result .. GetIn(unitNum)
    return result
end
function c:GetNameStr(num)
    local str = tostring(num)
    local dotBit = string.find(str, '[.]')
    local ebit = string.find(str, '[e+]')
    local intStr = string.sub(str, 1, (dotBit or ebit or #str + 1) - 1)
    local floatStr = ""
    local bitStr = ""
    local bitNum = #intStr
    if dotBit then
        floatStr = string.sub(str, dotBit + 1, (ebit or #str + 1) - 1)
    end
    if ebit then
        bitStr = string.sub(str, ebit + 2, #str)
        bitNum = bitNum + tostring(bitStr)
    end
    local unitNum = math.floor((bitNum - 1) / 3)
    local bitNum = bitNum - unitNum * 3

    -- 判断需要移动多少整数到小数去
    if #intStr > bitNum then
        floatStr = string.sub(intStr, bitNum + 1, #intStr) .. floatStr
        intStr = string.sub(intStr, 1, bitNum)
    elseif #intStr < bitNum then
        local bbit = bitNum - #intStr
        intStr = intStr .. string.sub(floatStr, 1, bbit)
        floatStr = string.sub(floatStr, bbit + 1, #floatStr)
        if #intStr < bitNum then
            for i = 1, bbit, 1 do
                intStr = intStr .. "0"
            end
        end
    end
    if #floatStr > 3 then
        floatStr = string.sub(floatStr, 1, 3)
    elseif #floatStr < 3 then
        for i = 1, 3 - #floatStr, 1 do
            floatStr = floatStr .. "0"
        end
    end
    local result = intStr
    --[[
	if floatStr ~= "" and floatStr ~= "000" then
		result = result.."."..floatStr
	end
	]] --
    result = result .. floatStr
    result = GetIn(unitNum) .. result
    return result
end
function c:ToRoundString(num)
    local str = tostring(num)
    local dotBit = string.find(str, '[.]')
    local ebit = string.find(str, '[e+]')
    local intStr = string.sub(str, 1, (dotBit or ebit or #str + 1) - 1)
    local floatStr = ""
    local bitStr = ""
    local bitNum = #intStr
    if dotBit then
        floatStr = string.sub(str, dotBit + 1, (ebit or #str + 1) - 1)
    end
    if ebit then
        bitStr = string.sub(str, ebit + 2, #str)
        bitNum = bitNum + tostring(bitStr)
    end
    local unitNum = math.floor((bitNum - 1) / 3)
    local bitNum = bitNum - unitNum * 3

    -- 判断需要移动多少整数到小数去
    if #intStr > bitNum then
        floatStr = string.sub(intStr, bitNum + 1, #intStr) .. floatStr
        intStr = string.sub(intStr, 1, bitNum)
    elseif #intStr < bitNum then
        local bbit = bitNum - #intStr
        intStr = intStr .. string.sub(floatStr, 1, bbit)
        floatStr = string.sub(floatStr, bbit + 1, #floatStr)
        if #intStr < bitNum then
            for i = 1, bbit, 1 do
                intStr = intStr .. "0"
            end
        end
    end
    if #floatStr > 2 then
        floatStr = string.sub(floatStr, 1, 2)
    end
    while #floatStr > 0 and string.sub(floatStr, #floatStr, #floatStr) == '0' do
        floatStr = string.sub(floatStr, 1, #floatStr - 1)
    end
    local result = intStr
    if floatStr ~= "" and floatStr ~= "00" then
        result = result 
    end
    local unitstr = (bitTab[unitNum] and bitTab[unitNum]["code"]) or "???"
    result = result .. unitstr
    return result
end
function c:ToString(num)
    local str = tostring(num)
    local dotBit = string.find(str, '[.]')
    local ebit = string.find(str, '[e+]')
    local intStr = string.sub(str, 1, (dotBit or ebit or #str + 1) - 1)
    local floatStr = ""
    local bitStr = ""
    local bitNum = #intStr
    if dotBit then
        floatStr = string.sub(str, dotBit + 1, (ebit or #str + 1) - 1)
    end
    if ebit then
        bitStr = string.sub(str, ebit + 2, #str)
        bitNum = bitNum + tostring(bitStr)
    end
    local unitNum = math.floor((bitNum - 1) / 3)
    local bitNum = bitNum - unitNum * 3

    -- 判断需要移动多少整数到小数去
    if #intStr > bitNum then
        floatStr = string.sub(intStr, bitNum + 1, #intStr) .. floatStr
        intStr = string.sub(intStr, 1, bitNum)
    elseif #intStr < bitNum then
        local bbit = bitNum - #intStr
        intStr = intStr .. string.sub(floatStr, 1, bbit)
        floatStr = string.sub(floatStr, bbit + 1, #floatStr)
        if #intStr < bitNum then
            for i = 1, bbit, 1 do
                intStr = intStr .. "0"
            end
        end
    end
    if #floatStr > 2 then
        floatStr = string.sub(floatStr, 1, 2)
    end
    while #floatStr > 0 and string.sub(floatStr, #floatStr, #floatStr) == '0' do
        floatStr = string.sub(floatStr, 1, #floatStr - 1)
    end
    local result = intStr
    if string.len(result) > 3 then
        result = string.sub(result, 1, 3)
    end
    if floatStr ~= "" and floatStr ~= "00" then
        result = result .. "." .. floatStr
    end
    local unitstr = (bitTab[unitNum] and bitTab[unitNum]["code"]) or "???"
    result = result .. unitstr
    return result
end
function c:ToStringWithLen(num, len)
    len = len or 5
    local str = tostring(num)
    assert(tonumber(str), "input is not a number")
    if string.len(str) < len then
        return str
    else
        return self:ToString(num)
    end
end

function c:TransformDateToString(t)
    return string.format(time_str, t / 3600, t % 3600 / 60, t % 60)
end
local dayStr = "!%d"
local hourStr = "!%H"
local minStr = "!%M"
local secStr = "!%S"
-- local dayShowStr = "!%Hh%Mm%Ss"
local hourShowStr = "!%Hh:%Mm:%Ss"
local function CheckTime(time,str)
    return time>0 and time..str or ""
end
function c:GetTime(time)
    local timeStr = ""
    local hour = tonumber(os.date(hourStr,time))
    local min = tonumber(os.date(minStr,time))
    local sec = tonumber(os.date(secStr,time))
    if time >= 86400 then 
        timeStr = tostring((tonumber(os.date(dayStr,time)) - 1)).."d"
    end
    timeStr = timeStr..CheckTime(hour,"h")
    timeStr = timeStr..CheckTime(min,"m")
    timeStr = timeStr..CheckTime(sec,"s")
    return timeStr
end

-- 使用梯形法则进行数值积分
---@param a number @积分下限
---@param b number @积分上限
---@param n number @分隔数量
---@param f function @被积函数
function c:Trapezoidal_rule(a, b, n, f)
	local h = (b - a) / n
	local sum = 0.5 * (f(a) + f(b))
	for i = 1, n - 1 do
		sum = sum + f(a + i * h)
	end
	return sum * h
end

return c
