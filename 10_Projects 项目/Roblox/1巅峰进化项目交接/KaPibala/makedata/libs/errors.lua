local string = string
local error = error

local function try(testval, patt, ...)
    if not testval then
        local err = string.format(patt, ...)
        error(err, 0)
    end
    return testval
end

return {
    try = try
}