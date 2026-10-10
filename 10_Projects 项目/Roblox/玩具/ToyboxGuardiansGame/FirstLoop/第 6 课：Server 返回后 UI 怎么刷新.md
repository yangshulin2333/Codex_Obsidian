
这一课只讲客户端拿到服务器返回结果以后，怎么把界面上的文字和按钮状态改掉。

对应文件：

[D:\\AI\\Codex\\ToyBox\\ToyboxGuardiansGame\\src\\StarterPlayer\\StarterPlayerScripts\\Client\\Game\\Controllers\\FirstLoopController.lua](D:/AI/Codex/ToyBox/ToyboxGuardiansGame/src/StarterPlayer/StarterPlayerScripts/Client/Game/Controllers/FirstLoopController.lua)

**1. 这一课的核心链路**

```
服务器返回 NetResult
-> FirstLoopController 收到 result
-> 判断 result.Ok
-> 成功：刷新数量和成功提示
-> 失败：显示错误提示
```

更具体一点：

```
self._net.Request(...)
-> result
-> if result.Ok then
       _setCount(...)
       _setResult(...)
       _setError("")
   else
       _setResult("")
       _setError(...)
   end
```

**2. UI 节点先存在哪里**

在 `_mountGui()` 里，代码会把 UI 模板挂到 `PlayerGui`，然后把重要节点保存到 `self._ui`：

```
self._ui = {
    Gui = gui,
    GrantButton = resolved.Nodes.GrantButton,
    CloseButton = resolved.Nodes.CloseButton,
    CountText = resolved.Nodes.CountText,
    ResultText = resolved.Nodes.ResultText,
    ErrorText = resolved.Nodes.ErrorText,
}
```

你可以理解为：

```
self._ui.CountText   = 显示当前小齿轮数量的 TextLabel
self._ui.ResultText  = 显示成功/进行中提示的 TextLabel
self._ui.ErrorText   = 显示错误提示的 TextLabel
self._ui.GrantButton = “小齿轮 +1”按钮
```

所以后面刷新 UI，本质就是改这些 `TextLabel.Text` 和按钮状态。

**3. 最底层的三个 UI 刷新函数**

代码最后有三个很简单的函数：

```
function FirstLoopController:_setCount(value)
    self._ui.CountText.Text = "当前小齿轮：" .. tostring(value)
end

function FirstLoopController:_setResult(message)
    self._ui.ResultText.Text = message
end

function FirstLoopController:_setError(message)
    self._ui.ErrorText.Text = message
end
```

它们的职责很单纯：

```
_setCount  改数量文字
_setResult 改成功/处理中提示
_setError  改错误提示
```

比如：

```
self:_setCount(3)
```

界面显示：

```
当前小齿轮：3
```

比如：

```
self:_setError("操作太快了，请稍等")
```

错误区域显示这句话。

**4. 页面刚启动时怎么刷新**

`Start()` 里最后会调用：

```
self:_requestSnapshot()
```

这个函数的作用是：

```
进入游戏后，先问服务器：我现在有多少小齿轮？
```

它一开始先设置 UI 状态：

```
self:_setResult("读取中...")
self:_setError("")
```

界面含义是：

```
成功/状态区域：读取中...
错误区域：清空
```

然后请求服务器：

```
local result = self._net.Request(SNAPSHOT_REMOTE_NAME, {
    requestId = HttpService:GenerateGUID(false),
})
```

这里请求的是：

```
FirstLoop.GetSnapshot
```

服务器成功返回时，结果大概是：

```
{
    Ok = true,
    Data = {
        resources = {
            SmallGear = 0
        }
    }
}
```

客户端就会走：

```
if result.Ok then
    local data = result.Data or {}
    local resources = data.resources or {}
    self:_setCount(resources.SmallGear or 0)
    self:_setResult("")
    self:_setError("")
    return
end
```

这段的真实意思是：

```
拿到服务器返回的小齿轮数量
刷新 CountText
清空“读取中”
清空错误提示
```

**5. data or {} 是什么意思**

这一句你可能会卡：

```
local data = result.Data or {}
```

它是防御写法。

意思是：

```
如果 result.Data 有值，就用 result.Data。
如果 result.Data 是 nil，就用空表 {}。
```

为什么要这么写？

因为如果直接写：

```
local resources = result.Data.resources
```

一旦 `result.Data` 是 nil，就会报错。

所以：

```
local data = result.Data or {}
local resources = data.resources or {}
```

是为了让 UI 刷新更稳。

**6. 点击“小齿轮 +1”后的 UI 状态**

点击按钮后，进入：

```
function FirstLoopController:_requestGrantSmallGear()
```

第一段：

```
if self._isRequesting then
    return
end
```

意思是：

```
如果上一次请求还没结束，就不要再发一次。
```

防止玩家连续快速点击，客户端这里先挡一层。

然后：

```
self:_setRequesting(true)
self:_setResult("请求中...")
self:_setError("")
```

界面变化是：

```
按钮变成不可点
按钮文字变成“请求中...”
状态文字显示“请求中...”
错误提示清空
```

**7. _setRequesting 做什么**

```
function FirstLoopController:_setRequesting(isRequesting)
    self._isRequesting = isRequesting
    self._uiController:SetButtonEnabled(self._ui.GrantButton, not isRequesting)

    if isRequesting then
        self._ui.GrantButton.Text = "请求中..."
    else
        self._ui.GrantButton.Text = "小齿轮 +1"
    end
end
```

这里管两个东西：

```
1. 记录当前是否正在请求：self._isRequesting
2. 控制按钮能不能点、显示什么文字
```

当 `isRequesting = true`：

```
按钮禁用
按钮文字：请求中...
```

当 `isRequesting = false`：

```
按钮启用
按钮文字：小齿轮 +1
```

真正禁用按钮的函数在 `UIController`：

[D:\\AI\\Codex\\ToyBox\\ToyboxGuardiansGame\\src\\StarterPlayer\\StarterPlayerScripts\\Client\\Framework\\Controllers\\UIController.lua](D:/AI/Codex/ToyBox/ToyboxGuardiansGame/src/StarterPlayer/StarterPlayerScripts/Client/Framework/Controllers/UIController.lua)

```
button.Active = enabled
button.AutoButtonColor = enabled
button.Interactable = enabled
```

意思是：

```
Active 控制按钮是否参与交互
AutoButtonColor 控制按钮默认点击/悬停变色
Interactable 是新一些的 UI 可交互属性
```

**8. 服务器成功返回后怎么刷新**

点击加小齿轮成功后，服务器返回大概是：

```
{
    Ok = true,
    Data = {
        resources = {
            SmallGear = 1
        },
        added = {
            SmallGear = 1
        }
    }
}
```

客户端收到以后：

```
if result.Ok then
    local data = result.Data or {}
    local resources = data.resources or {}
    self:_setCount(resources.SmallGear or 0)
    self:_setResult("小齿轮 +1")
    self:_setError("")
    return
end
```

界面变化是：

```
数量文字：当前小齿轮：1
成功提示：小齿轮 +1
错误提示：清空
```

注意：客户端没有自己算 `当前数量 + 1`。  
它用的是服务器返回的 `resources.SmallGear`。

这是正确做法：

```
UI 显示服务器确认后的结果，而不是客户端自己猜结果。
```

**9. 服务器失败返回后怎么刷新**

如果服务器返回：

```
{
    Ok = false,
    Code = "COOLDOWN",
    Message = "FirstLoop request is cooling down"
}
```

客户端会走失败分支：

```
self:_setResult("")
self:_setError(ERROR_MESSAGES[result.Code] or "请求失败，请稍后再试")
```

`ERROR_MESSAGES` 是客户端给玩家看的中文文案表：

```
local ERROR_MESSAGES = {
    PROFILE_NOT_READY = "数据还没准备好，请稍等一秒再试",
    COOLDOWN = "操作太快了，请稍等",
    SERVER_ERROR = "服务器处理失败，请稍后再试",
    REMOTE_NOT_FOUND = "通信还没准备好，请稍后再试",
    INVOKE_FAILED = "通信请求失败，请稍后再试",
}
```

所以：

```
Code = "COOLDOWN"
```

最终显示：

```
操作太快了，请稍等
```

如果遇到一个没有配置过的错误码，就显示兜底文案：

```
请求失败，请稍后再试
```

**10. 为什么不用服务器的英文 Message 直接显示**

因为服务器返回的：

```
Message = "FirstLoop request is cooling down"
```

更偏技术信息。

玩家看到这个不友好，你也不容易读。  
所以客户端用 `Code` 映射成中文：

```
COOLDOWN -> 操作太快了，请稍等
```

这也是我们之前说过的方向：

```
日志和内部标识可以英文
玩家可见 UI 尽量中文
```

**11. 关闭按钮怎么刷新 UI**

关闭按钮绑定在 `Start()` 里：

```
self._ui.CloseButton.MouseButton1Click:Connect(function()
    self._ui.Gui.Enabled = false
end)
```

这不是销毁 UI，只是隐藏：

```
ScreenGui.Enabled = false
```

所以点 X 后，整个 `FirstLoopDebugGui` 不显示了。  
它还在 `PlayerGui` 里，只是关闭显示。

**12. 这一课的完整 UI 刷新链路**

点击按钮后：

```
玩家点击“小齿轮 +1”
-> _requestGrantSmallGear()
-> _setRequesting(true)
-> _setResult("请求中...")
-> NetClient.Request(...)
-> 等服务器返回
-> _setRequesting(false)
```

如果成功：

```
result.Ok == true
-> 读取 result.Data.resources.SmallGear
-> _setCount(服务器返回的小齿轮数量)
-> _setResult("小齿轮 +1")
-> _setError("")
```

如果失败：

```
result.Ok == false
-> 根据 result.Code 找中文错误
-> _setResult("")
-> _setError(中文错误)
```

**13. 这一课你需要掌握的最小结论**

```
Server 返回的是 NetResult。
FirstLoopController 根据 result.Ok 分成功和失败。
成功时刷新数量和成功提示。
失败时根据 result.Code 显示中文错误。
UI 真正变化的位置，就是 _setCount、_setResult、_setError、_setRequesting。
```

架构上再记一句：

```
服务器负责结果是否成立，客户端负责把结果显示清楚。
```

下一课第 7 课：**为什么 FirstLoop 算一个最小 Feature Pack**。  
这节会把你之前问的“Feature Pack 到底是什么”“FirstLoop 算不算 Feature Pack”“为什么现在看起来不够解耦”一次性讲清楚。