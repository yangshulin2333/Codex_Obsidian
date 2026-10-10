**第六课：把 `001_FirstLoop` 串成完整闭环**

你现在“勉强能看懂”是正常的。前五课都比较抽象，第六课开始把它们连成一个真实功能。

这节只讲一件事：

```
玩家点一个按钮
-> Server 增加 SmallGear
-> UI 显示最新数量
```

对应 Feature Card：

[001_FirstLoop.md (line 1)](D:/AI/Codex/ToyBox/ToyboxGuardiansDemo/docs/feature-cards/001_FirstLoop.md:1)

**1. FirstLoop 是什么**

`FirstLoop` 不是正式玩法。

它不是：

```
打怪
掉落
强化
拼装
Boss
存档
```

它只是验证这条最小可信链路：

```
Client UI
-> Remote 请求
-> Server 校验
-> DataService 写数据
-> Server 返回结果
-> Client 刷新 UI
```

只要这条链路跑通，后面打怪掉落、强化、拼装，本质上都是这条链路的复杂版本。

**2. 完整流程**

玩家看到：

```
FirstLoopDebugGui
  GrantSmallGearButton
  SmallGearCountText
  ResultText
  ErrorText
```

玩家点击按钮后：

```
1. FirstLoopController 监听按钮点击

2. Client 发送请求：
   FirstLoop.GrantSmallGear
   payload = { requestId = "..." }

3. NetClient 找到 RemoteFunction 并 InvokeServer

4. NetService 收到请求，把请求交给 FirstLoopService

5. FirstLoopService 做校验：
   - 玩家数据是否准备好
   - requestId 是否存在
   - 是否 1 秒冷却
   - SmallGear 是否没超过上限

6. 校验通过后，FirstLoopService 调 DataService

7. DataService 修改：
   Resources.SmallGear += 1

8. Server 返回最新 ResourcesSnapshot

9. FirstLoopController 收到结果

10. UI 显示最新 SmallGear 数量
```

你可以先只记这个版本：

```
按钮只是“请求”
Server 才能“决定”
DataService 才能“写数据”
UI 只是“显示结果”
```

**3. 每一层负责什么**

|层|负责|不负责|
|---|---|---|
|`FirstLoopDebugGui`|显示按钮和文本|不判断奖励|
|`FirstLoopController`|绑定按钮、发请求、刷新 UI|不增加 SmallGear|
|`NetClient`|客户端发 Remote 请求|不判断玩法|
|`NetService`|创建/转发 Remote|不判断奖励数量|
|`FirstLoopService`|校验规则、决定是否给奖励|不直接乱写存档|
|`DataService`|修改玩家数据|不判断玩法是否成立|

**4. 对应前五课的位置**

第一课 Rojo 映射：

```
FirstLoopController 放 Client
FirstLoopService 放 Server
共享配置放 ReplicatedStorage/Game
```

第二课服务端启动：

```
FirstLoopService
-> 加进 ServiceList
-> ServiceRegistry 启动它
```

第三课客户端启动：

```
FirstLoopController
-> 加进 ControllerList
-> ControllerRegistry 启动它
```

第四课网络：

```
FirstLoopController
-> context.Net.Request("FirstLoop.GrantSmallGear", payload)
-> NetService:RegisterRequest("FirstLoop.GrantSmallGear", handler)
```

相关入口：

[NetClient.Request (line 57)](D:/AI/Codex/ToyBox/RobloxGameFramework/src/ReplicatedStorage/Framework/Shared/Net/NetClient.lua:57)  
[NetService:RegisterRequest (line 131)](D:/AI/Codex/ToyBox/RobloxGameFramework/src/ServerScriptService/Server/Framework/Services/NetService.lua:131)

第五课数据：

```
FirstLoopService
-> DataService:IsProfileReady(player)
-> DataService:UpdateProfile(player, "FirstLoop.GrantSmallGear", function(data)
      data.Resources.SmallGear += 1
   end)
```

相关入口：

[DataService:UpdateProfile (line 153)](D:/AI/Codex/ToyBox/RobloxGameFramework/src/ServerScriptService/Server/Framework/Services/DataService.lua:153)

**5. 伪代码理解**

客户端大概长这样：

```
button.Activated:Connect(function()
	local result = self._net.Request("FirstLoop.GrantSmallGear", {
		requestId = requestId,
	})

	if result.Ok then
		SmallGearCountText.Text = tostring(result.Data.resources.SmallGear)
		ResultText.Text = "小齿轮 +1"
	else
		ErrorText.Text = "操作失败"
	end
end)
```

服务端大概长这样：

```
NetService:RegisterRequest("FirstLoop.GrantSmallGear", function(player, payload)
	if not DataService:IsProfileReady(player) then
		return NetResult.Err("PROFILE_NOT_READY", "Profile not ready")
	end

	local ok = DataService:UpdateProfile(player, "FirstLoop.GrantSmallGear", function(data)
		data.Resources.SmallGear += 1
	end)

	if not ok then
		return NetResult.Err("SERVER_ERROR", "Update failed")
	end

	return {
		resources = DataService:GetDataSnapshot(player).Resources,
		added = {
			SmallGear = 1,
		},
	}
end)
```

先不用纠结语法细节，重点看责任：

```
Client 发请求。
Server 校验。
DataService 改数据。
Client 显示结果。
```

**6. 最容易混的点**

`NetService` 不是玩法系统。

它只是电话线：

```
负责把 Client 的请求送到 Server。
```

`FirstLoopService` 才是玩法裁判：

```
判断能不能加 SmallGear。
```

`DataService` 不是裁判。

它是账本管理员：

```
真正改玩家数据。
```

`FirstLoopController` 不是裁判。

它是前台界面：

```
按钮、文本、提示。
```

**7. 以后真正实现时放哪里**

不要放进 `RobloxGameFramework` 核心。

应该放进：

```
D:\AI\Codex\ToyBox\ToyboxGuardiansGame
```

大概会有：

```
ToyboxGuardiansGame
  src
    ServerScriptService
      Server
        Game
          Services
            FirstLoopService.lua

    StarterPlayer
      StarterPlayerScripts
        Client
          Game
            Controllers
              FirstLoopController.lua

    ReplicatedStorage
      Game
        Shared
          Config
            DataSchema.lua
            ResourceConfig.lua
            FirstLoopConfig.lua
```

**本课记住 4 句话**

```
FirstLoop 是第一个可信数据闭环。

Client 只请求，不发奖励数量。

Server 校验规则，DataService 修改数据。

UI 只显示 Server 返回的结果。
```

下一节建议补充讲：

```
Feature Pack 到底是什么，以及 FirstLoop 算不算 Feature Pack
```

这会帮你理解后面 Toybox 的战斗、强化、拼装为什么要一张张 Feature Card 做，而不是一口气全塞进去。