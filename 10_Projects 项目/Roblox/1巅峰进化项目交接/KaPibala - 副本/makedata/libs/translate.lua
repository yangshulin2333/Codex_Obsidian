local errors = require 'errors'
local crypt = require 'crypt'
local http = require 'http.client'
local fs = require 'fsystem'

local os = os
local table = table
local string = string
local pairs = pairs

local MAP_ENCODE = {
    ['%%s'] = '\1',
    ['%%q'] = '\2',
    ['"'] = '\3',
    ["'"] = '\4',
    ['“'] = '\5',
    ['”'] = '\6',
    ['<br/>'] = '\7',
    ['%%%%'] = '\8',
    ['%%d'] = '\9'
}

local MAP_DECODE = {
    ['\1'] = '%s',
    ['\2'] = '%q',
    ['\3'] = '"',
    ['\4'] = "'",
    ['\5'] = '“',
    ['\6'] = '”',
    ['\7'] = '<br/>',
    ['\8'] = '%%',
    ['\9'] = '%d'
}

local buffer = {}
for patt in pairs(MAP_DECODE) do
    table.insert(buffer, patt)
end
table.insert(buffer, 1, '[')
table.insert(buffer, ']')

local PATTERNS_IN_ANSWER = table.concat(buffer)

local function encode(q)
    for patt, repl in pairs(MAP_ENCODE) do
        q = string.gsub(q, patt, repl)
    end
    return q
end

local function decode(s)
    return string.gsub(s, PATTERNS_IN_ANSWER, MAP_DECODE)
end

local BAIDU_APPID= '20210512000824848'
local BAIDU_SECRET = 'SQOF0j_YCjU5PK9cbBj8'
-- local BAIDU_APPID = '20210514000827283'
-- local BAIDU_SECRET = 'vzKBhsNDXyC5AKom1014'
-- local BAIDU_LANGS = { en = 'en', ja = 'jp', ko = 'kor', ['zh-hant'] = 'cht' }
local BAIDU_LANGS = {
    ["de"] = "de",
    ["en"] = "en",
    ["es"] = "spa",
    ["fr"] = "fra",
    ["ja"] = "jp",
    ["ko"] = "kor",
    ["pt"] = "pt",
    ["zh-hant"] = "cht",
    ["bg"] = "bul",
    ["cs"] = "cs",
    ["da"] = "dan",
    ["el"] = "el",
    ["et"] = "est",
    ["fi"] = "fin",
    ["hu"] = "hu",
    ["nl"] = "nl",
    ["pl"] = "pl",
    ["ro"] = "rom",
    ["ru"] = "ru",
    ["sl"] = "slo",
    ["sv"] = "swe",
    ["th"] = "th",
    ["vi"] = "vie"
}

local PLATFORMS = {}

PLATFORMS.baidu = function(q, to)
    to = errors.try(BAIDU_LANGS[to], 'unsupported target language %q', to)
    q = encode(q)
    local salt = os.time()
    local ok, body = http.call {
        type = 'POST',
        url = 'http://api.fanyi.baidu.com/api/trans/vip/translate',
        body = {
            q = q,
            from = 'zh',
            to = to,
            appid = BAIDU_APPID,
            salt = salt,
            sign = crypt.md5(BAIDU_APPID, q, salt, BAIDU_SECRET)
        },
        timeout = 10
    }
    if not ok then
        return nil, body
    end
    local resp = body:decode 'json'
    if resp.error_msg then
        return nil, resp.error_msg
    end
    local dst = resp.trans_result[1].dst
    return decode(dst)
end

local function exec(type, q, to)
    local func = errors.try(PLATFORMS[type], 'invalid platform type: %s', type)
    errors.try(q, 'question not set')
    errors.try(to, 'target language type not set')
    -- succ: target language string
    -- failed: nil, error message
    return func(q, to)
end

return {
    exec = exec
}
