local workspace = workspace
local _G = _G
local script = script
local Vector3 = Vector3
local pow = math.pow
local DEFUALT_GRAVITY = workspace.Gravity
local hotpot = _G.CommonHotpot
---@class CurveHelper
local c = hotpot.class.new(script)
function c:ParaCurveWithAlpha(p0,i,a,G)
    G = G or DEFUALT_GRAVITY
    local limit_t = 2 * (i.Y/G)
    local t = limit_t * a
    return self:ParaCurveRealTime(p0,i,t,G)
end
function c:ParaCurveRealTime(p0,i,t,G)
    G = G or DEFUALT_GRAVITY
    local v_x,v_z = i.X,i.Z
    local v_y = i.Y
    return p0 + Vector3.new(v_x*t,v_y*t - pow(t,2) * G / 2,v_z * t)
end
function c:BezierCurve(p0,p1,p2,t)
    return pow(1-t,2)*p0 + 2 * t * (1 - t) * p1 + pow(t,2) * p2
end
---@param p0 Vector3
---@param dir Vector3
function c:BezierCurveWithDir(p0,dir,h,l,t)
    local dir_2d = Vector3.new(dir.X,0,dir.Z).Unit * l
    local p1 = p0 + dir_2d/2 + Vector3.new(0,h,0)
    local p2 = p0 + dir_2d
    return self:BezierCurve(p0,p1,p2,t)
end
function c:BezierCurveToPosition(p0,pt,h,t)
    local p_m = (pt - p0)/2 + p0 + Vector3.new(0,h,0)
    return self:BezierCurve(p0,p_m,pt,t)
end
function c:StraightLine(p0,i,t)
end
return c