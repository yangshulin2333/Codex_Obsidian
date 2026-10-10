# Hotpot UI 框架速览：self.insts 和 UI 控制类

你现在不需要把所有细节背下来。为了尽快开始写 `MainGui` 控制类，先抓住这一条：

```text
c.insts 先登记 UI 路径
HotpotScreenBase 把路径转成真实节点
MainGui.lua 再用这些节点封装方法给外部调用
```

## 1. self.insts 是什么

在 `BagGui.lua` 里有：

```lua
local function GetInst()
    c.insts = {}

    ---@type Frame
    c.insts.Frame = "Frame"

    ---@type ImageLabel
    c.insts.bg = "Frame.bg"

    ---@type TextLabel
    c.insts.potion_capacity = "Frame.bg.PotionFrame.capacity"

    ---@type ImageButton
    c.insts.potion_Right_equipBtn = "Frame.bg.PotionFrame.Right.equipBtn"
end

GetInst()
```

这里的 `c.insts` 一开始只是“路径登记表”。

比如：

```lua
c.insts.potion_capacity = "Frame.bg.PotionFrame.capacity"
```

意思是：

```text
等 UI 克隆出来以后，
从整个 ScreenGui 下面找到：
Frame -> bg -> PotionFrame -> capacity
然后把它保存成 potion_capacity。
```

## 2. 路径什么时候变成真实节点

`HotpotScreenBase:ctor()` 里面有：

```lua
if self.insts then
    self.insts = lfunc.GetInst(self, self.insts)
end
```

这一步会把字符串路径转成真实 Roblox Instance。

所以构造前：

```lua
c.insts.potion_capacity = "Frame.bg.PotionFrame.capacity"
```

构造后：

```lua
self.insts.potion_capacity = TextLabel实例
```

于是后面才能写：

```lua
self.insts.potion_capacity.Text = "Capacity:1/10"
```

你可以这样记：

```text
c.insts 是图纸
self.insts 是真正找到的 UI 节点
```

## 3. 路径是相对谁的

这个很关键。

路径：

```lua
"Frame.bg.PotionFrame.capacity"
```

不是从 `game` 开始找，也不是从 `ReplicatedStorage` 开始找。

它是从：

```lua
self.main_inst
```

开始找。

而 `self.main_inst` 是什么？

在 `BagGui` 里，`self.main_inst` 就是克隆出来的整个 `ScreenGui`。

所以：

```text
self.main_inst
└─ Frame
   └─ bg
      └─ PotionFrame
         └─ capacity
```

路径就写：

```lua
"Frame.bg.PotionFrame.capacity"
```

## 4. 路径命名要注意

这个项目的路径查找底层用了类似这种拆分：

```lua
string.gmatch(path_str, "[%a%d_]+")
```

你不用记正则，只记规则：

```text
节点名最好只用英文、数字、下划线
不要用中文
不要用空格
不要用横杠 -
```

所以 `MainGui` 里像这些名字是好的：

```text
Root
Pages
AttrPage
AttrWindow
WindowBg
CloseButton
PointText
```

如果以后 UI 节点叫：

```text
属性窗口
close-button
Point Text
```

就不适合放进 `self.insts` 路径表。

## 5. 注释里的 @type 是什么

比如：

```lua
---@type TextLabel
c.insts.potion_capacity = "Frame.bg.PotionFrame.capacity"
```

这个：

```lua
---@type TextLabel
```

不是运行时代码。它只是给编辑器看的类型注释。

作用是：

```text
提醒你这个节点应该是 TextLabel
方便自动补全
方便人读代码
```

真正运行时只看这一句：

```lua
c.insts.potion_capacity = "Frame.bg.PotionFrame.capacity"
```

## 6. UI 控制类应该怎么写

`MainGui.lua` 不应该直接写业务逻辑。它应该做这几类事：

```text
1. 注册 UI 节点
2. 克隆 UI 模板
3. 显示 / 隐藏页面
4. 设置文本、图片、进度条
5. 绑定按钮事件
6. 管理列表 item 的增删
```

不应该做：

```text
1. 调用 RemoteEvent / RemoteFunction
2. 判断玩家金币够不够
3. 决定属性升级是否合法
4. 直接处理商店购买结果
```

这些应该交给 Controller 或 Component。

## 7. MainGui 控制类最小骨架

后面我们写的时候，大概会是这种结构：

```lua
local hotpot = _G.ClientHotpot

---@class MainGui:HotpotScreenBase
local c = hotpot.class.new(script, hotpot.files.HotpotScreenBase())

local function GetInst()
    c.insts = {}

    ---@type Frame
    c.insts.Root = "Root"

    ---@type Frame
    c.insts.Pages = "Root.Pages"

    ---@type Frame
    c.insts.MainPage = "Root.Pages.MainPage"

    ---@type Frame
    c.insts.AttrPage = "Root.Pages.AttrPage"

    ---@type Frame
    c.insts.AttrWindow = "Root.Pages.AttrPage.AttrWindow"

    ---@type ImageButton
    c.insts.AttrCloseButton = "Root.Pages.AttrPage.AttrWindow.TopBar.CloseButton"

    ---@type TextLabel
    c.insts.AttrTitleText = "Root.Pages.AttrPage.AttrWindow.TopBar.TitleText"
end

GetInst()

function c.new()
    return c()
end

function c:ctor()
    local uiInst = hotpot:GetPath("ui.MainGui", _G.Resource)
    uiInst = hotpot:CloneInst_Loop(uiInst)
    c.super.ctor(self, uiInst)

    self.pages = {
        MainPage = self.insts.MainPage,
        AttrPage = self.insts.AttrPage,
    }
end

function c:ShowPage(pageName)
    for name, page in pairs(self.pages) do
        page.Visible = name == pageName
    end
end

function c:SetAttrTitle(text)
    self.insts.AttrTitleText.Text = text
end

function c:BindAttrCloseClick(obj, handle)
    self.insts.AttrCloseButton.MouseButton1Click:Connect(function()
        handle(obj)
    end)
end

return c
```

这个就是 `BagGui` 模式的 `MainGui` 版本。

## 8. 外部逻辑应该怎么调用

以后外部不要这样写：

```lua
mainGui.insts.AttrPage.Visible = true
mainGui.insts.AttrTitleText.Text = "属性"
```

而是这样写：

```lua
mainGui:ShowPage("AttrPage")
mainGui:SetAttrTitle("属性")
```

原因是：

```text
如果以后 UI 层级变了，
只改 MainGui.lua 里面的路径和方法，
外部逻辑不用改。
```

这就是“UI 和逻辑分离”。

## 9. 你现在要先记住的版本

```text
self.insts 是 MainGui.lua 操作 UI 的入口。

外部逻辑不要直接碰 UI 节点。
外部逻辑只调用 MainGui 暴露的方法。

MainGui.lua 负责“怎么显示”。
Controller / Component 负责“为什么显示、什么时候显示”。
```

下一步真要开始写 `MainGui` 控制类时，我建议先做第一版“节点清单”，不用一次性暴露全部 500 个节点。先按页面做：

```text
MainPage：入口按钮、顶部信息
AttrPage：关闭按钮、tab、属性文本、升级按钮
ShopPage：tab、商品列表、购买按钮
GachaPage：抽卡按钮、结果区
```

先把这些核心节点跑通，再逐步补细节。