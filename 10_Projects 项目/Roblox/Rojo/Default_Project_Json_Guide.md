# default.project.json 入门说明

## 它是干什么的

`default.project.json` 是 Rojo 的同步配置文件。

它不运行游戏。

它只告诉 Rojo：

```text
本地文件夹 A
同步到 Roblox Studio 里的位置 B
```

可以把它理解成一张“同步路线图”。

## 先分清楚：哪些是固定写法，哪些是自己起的名字

看 Rojo 配置时，先不要把所有单词都当成同一种东西。

它里面混着 4 类内容：

| 类型 | 例子 | 谁规定的 | 能不能随便改 |
|---|---|---|---|
| Rojo 固定字段 | `name`、`tree`、`$className`、`$path` | Rojo 规定 | 不要随便改字段名 |
| Roblox 类名 | `DataModel`、`ReplicatedStorage`、`ServerScriptService`、`StarterPlayer` | Roblox 规定 | 不能乱写 |
| Studio 服务/对象名字 | `ReplicatedStorage`、`ServerScriptService`、`StarterPlayerScripts`、`Shared` | Roblox 或我们项目决定 | Roblox 服务名不能改，项目文件夹名可以改但不建议乱改 |
| 本地文件夹路径 | `src/ServerScriptService`、`src/ReplicatedStorage/Shared` | 我们项目自己定 | 可以改，但改了要同步改目录结构 |

所以：

```json
"tree": {
  "$className": "DataModel"
}
```

这里：

```text
tree        = Rojo 固定字段
$className  = Rojo 固定字段
DataModel   = Roblox 固定类名
```

`DataModel` 不是我自己定义的。

它是 Roblox 引擎里的根对象类型，可以理解成“整个游戏工程本身”。

你在 Studio 里平时看不到一个直接叫 `DataModel` 的对象，但你看到的这些服务：

```text
Workspace
Players
Lighting
ReplicatedStorage
ServerScriptService
StarterGui
StarterPlayer
SoundService
TextChatService
```

都挂在 `DataModel` 下面。

用更直白的话说：

```text
DataModel = Roblox 游戏项目的最顶层容器
```

Rojo 需要知道“我要往哪个 Roblox 根对象里同步”，所以最外层要写：

```json
"$className": "DataModel"
```

这基本是 Rojo 项目的固定写法。

你现在不用记 API，只要记：

```text
Rojo 项目最外层一般就是 DataModel。
它代表整个 Roblox 游戏。
不要把 DataModel 改成别的名字。
```

## 当前项目的配置

```json
{
  "name": "EatDemoReplica",
  "tree": {
    "$className": "DataModel",
    "ReplicatedStorage": {
      "Shared": {
        "$path": "src/ReplicatedStorage/Shared"
      },
      "Packages": {
        "$path": "Packages"
      }
    },
    "ServerScriptService": {
      "$path": "src/ServerScriptService"
    },
    "StarterPlayer": {
      "StarterPlayerScripts": {
        "$path": "src/StarterPlayer/StarterPlayerScripts"
      }
    }
  }
}
```

## 逐句解释

### name

```json
"name": "EatDemoReplica"
```

项目名字。

这个名字主要给 Rojo 显示用，不影响游戏逻辑。

这一行里：

```text
name = Rojo 固定字段
EatDemoReplica = 我们自己起的项目名
```

所以你可以改 `EatDemoReplica`，但不要把 `name` 这个字段改成别的。

### tree

```json
"tree": {
  "$className": "DataModel"
}
```

`DataModel` 就是 Roblox Studio 里的整个游戏根对象。

这一段里：

```text
tree = Rojo 固定字段
$className = Rojo 固定字段
DataModel = Roblox 固定类名
```

固定理解：

```text
tree 下面描述 Studio Explorer 里要出现什么结构。
最外层 className 写 DataModel，意思是整个 Roblox 游戏。
```

你在 Explorer 里看到的：

```text
Workspace
Players
ReplicatedStorage
ServerScriptService
StarterPlayer
StarterGui
...
```

这些都在 `DataModel` 下面。

## 当前真正同步了哪些地方

下面这些名字也要分清：

```json
"ReplicatedStorage": {
  "Shared": {
    "$path": "src/ReplicatedStorage/Shared"
  }
}
```

这里：

```text
ReplicatedStorage = Roblox 固定服务名
Shared = 我们项目里的文件夹名
$path = Rojo 固定字段
src/ReplicatedStorage/Shared = 本地文件夹路径
```

所以这段不是“随便写 JSON”。

它的意思是：

```text
在 Studio 的 ReplicatedStorage 下面创建/同步一个 Shared 文件夹。
这个 Shared 文件夹的内容来自本地 src/ReplicatedStorage/Shared。
```

### ReplicatedStorage/Shared

```json
"ReplicatedStorage": {
  "Shared": {
    "$path": "src/ReplicatedStorage/Shared"
  }
}
```

意思是：

```text
本地:
D:\AI\Codex\Codex_ProjectFixed\Replica_Demo_RojoKnit\src\ReplicatedStorage\Shared

同步到 Studio:
ReplicatedStorage/Shared
```

所以这些文件会同步：

```text
src/ReplicatedStorage/Shared/EatDemoConfig.luau
src/ReplicatedStorage/Shared/InstanceUtil.luau
src/ReplicatedStorage/Shared/RemoteNames.luau
```

### ServerScriptService

```json
"ServerScriptService": {
  "$path": "src/ServerScriptService"
}
```

意思是：

```text
本地:
D:\AI\Codex\Codex_ProjectFixed\Replica_Demo_RojoKnit\src\ServerScriptService

同步到 Studio:
ServerScriptService
```

所以这些文件会同步：

```text
src/ServerScriptService/EatDemoServer.server.luau
src/ServerScriptService/Services/DataService.luau
src/ServerScriptService/Services/EatService.luau
src/ServerScriptService/Services/ShopService.luau
```

### StarterPlayer/StarterPlayerScripts

```json
"StarterPlayer": {
  "StarterPlayerScripts": {
    "$path": "src/StarterPlayer/StarterPlayerScripts"
  }
}
```

意思是：

```text
本地:
D:\AI\Codex\Codex_ProjectFixed\Replica_Demo_RojoKnit\src\StarterPlayer\StarterPlayerScripts

同步到 Studio:
StarterPlayer/StarterPlayerScripts
```

所以这些文件会同步：

```text
src/StarterPlayer/StarterPlayerScripts/EatDemoClient.client.luau
src/StarterPlayer/StarterPlayerScripts/ClientModules/UIController.luau
src/StarterPlayer/StarterPlayerScripts/ClientModules/ScanController.luau
```

## 为什么 test.lua 没同步

判断一个文件会不会同步，只看两个条件：

```text
1. 文件有没有保存到磁盘
2. 文件路径是不是在 default.project.json 的 $path 下面
```

### 不会同步的例子

```text
src/ReplicatedStorage/test.lua
```

不会同步。

原因：

```text
当前配置没有映射 src/ReplicatedStorage 整个目录。
当前只映射了 src/ReplicatedStorage/Shared。
```

### 会同步的例子

```text
src/ReplicatedStorage/Shared/test.luau
```

会同步。

它会出现在 Studio：

```text
ReplicatedStorage
└─ Shared
   └─ test
```

### 项目里建议用 luau

Roblox 新项目建议统一用：

```text
.luau
```

不要一会儿 `.lua`，一会儿 `.luau`。

当前项目统一用 `.luau`。

## 文件名怎么决定 Script 类型

| 本地文件名 | Studio 对象类型 |
|---|---|
| `Test.server.luau` | Script |
| `Test.client.luau` | LocalScript |
| `Test.luau` | ModuleScript |

例子：

```text
src/ServerScriptService/Test.server.luau
```

会变成：

```text
ServerScriptService/Test
类型：Script
```

```text
src/StarterPlayer/StarterPlayerScripts/Test.client.luau
```

会变成：

```text
StarterPlayer/StarterPlayerScripts/Test
类型：LocalScript
```

```text
src/ReplicatedStorage/Shared/Test.luau
```

会变成：

```text
ReplicatedStorage/Shared/Test
类型：ModuleScript
```

## 以后你新建文件怎么判断放哪里

| 目的 | 放哪里 |
|---|---|
| 服务端功能 | `src/ServerScriptService/Services/xxx.luau` |
| 服务端入口 Script | `src/ServerScriptService/xxx.server.luau` |
| 客户端功能 | `src/StarterPlayer/StarterPlayerScripts/ClientModules/xxx.luau` |
| 客户端入口 LocalScript | `src/StarterPlayer/StarterPlayerScripts/xxx.client.luau` |
| 双端共享配置 | `src/ReplicatedStorage/Shared/xxx.luau` |
| 地图和模型 | 现在先在 Roblox Studio 里做 |

## 正常启动流程

每次重新打开 Studio 前，先启动 Rojo server：

```powershell
cd D:\AI\Codex\Codex_ProjectFixed\Replica_Demo_RojoKnit
rojo serve default.project.json --address 127.0.0.1 --port 34872
```

然后：

```text
1. 打开 Roblox Studio
2. 打开项目
3. 打开 Rojo 插件
4. 点 Connect
5. 如果弹出同步列表，确认是当前项目后点 Accept
6. Play 测试
```
