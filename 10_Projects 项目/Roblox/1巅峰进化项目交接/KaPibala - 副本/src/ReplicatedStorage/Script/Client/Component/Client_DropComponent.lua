local hotpot = _G.ClientHotpot
---@type TweenHelper
local TweenHelper = hotpot.load.TweenHelper()
---@type ParticleHelper
local ParticleHelper = hotpot.load.ParticleHelper()

local dropFol = hotpot:GetPath_Loop('Drop',_G.Resource)
local Drop = workspace:WaitForChild('Drop')
local tweenInfo = TweenInfo.new(
    0.5,  -- 持续时间
    Enum.EasingStyle.Quad,  -- 缓动样式
    Enum.EasingDirection.In  -- 缓动方向
)

---@class Client_DropComponent:Client_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Client_PlayerComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)

    for k,v in ipairs(dropFol:GetChildren())do
        ParticleHelper:ReSizeParticle(v,0.5)
    end
end

function c:PlayDrop(type_,position)
    local part = dropFol:FindFirstChild(type_)
    for i = 1,math.random(1,3),1  do
        local angle 
        if type_ == 'Exp' then
            angle = ((i - 1)) * 60  
        elseif type_ == 'Gems' then
            angle = ((i - 1)) * 45
        else
            angle = (i+3 - 1) * 60
        end
        local radians = math.rad(angle)  -- 转换为弧度
        local direction = Vector3.new(math.cos(radians), 0, math.sin(radians))  -- XZ平面方向
        local dropOffset = direction * 2  -- 掉落偏移量（从中心向外）
        local ActivityDrop = part:Clone()
        ActivityDrop.Parent = Drop
        ActivityDrop.Position = position + Vector3.new(0,math.random(-3,5),0)
        ActivityDrop.Velocity = direction * 20 + Vector3.new(0, 40, 0)
        -- delay(0.3,function()
        --     ActivityDrop.Anchored = true
        -- end)

        local delayTime = type_ == 'Gems' and 2 or 1

        delay(delayTime,function()
            self:AbsorbToPlayer(ActivityDrop)
        end)
    end
end

function c:AbsorbToPlayer(drop)
    -- local pos = self.parent.character:GetPosition()
    -- TweenHelper:PlayTween(
    --     drop,
    --     tweenInfo,
    --     {Position = pos},
    --     function()
    --         drop:Destroy()
    --     end
    -- )
    -- TweenHelper:PlayTween(
    --     drop.a,
    --     tweenInfo,
    --     {Size = UDim2.fromScale(0.1,0.1)}
    -- )

    self:AddRenderProcess('render',function()
        local interval = 0
        local time_len = 2
        local chaPos = self.parent.character:GetPosition()
        local dir = (chaPos - drop.Position).Unit
        local speed = 100

        drop.CanCollide = false
        drop.Anchored = true

        while true do
            interval = self:Wait()
            time_len = time_len - interval
            chaPos = self.parent.character:GetPosition()
            dir = (chaPos - drop.Position).Unit
            drop.Position = drop.Position + dir * interval * speed
            if (drop.Position - chaPos).Magnitude < 1 then
                break
            end
            if time_len <= 0 then
                break
            end
        end

        drop:Destroy()
    end)

end

return c