# UI 读懂报告模板

复制这个结构，写入：

```text
Project_Analysis_Package/Gui_Understanding_Report.md
```

## 1. 结论

```text
我已经确认当前 UI 的真实 Studio 结构。
本报告基于 <快照文件名>。
如果有 before / after，本报告同时基于 <before> 和 <after> 对比。
```

## 2. 当前显示状态

```text
当前页面：
当前标题：
当前选中 Tab：
当前隐藏页面：
```

## 3. UI 树结构

```text
ScreenGui
└─ Root
   └─ ...
```

## 4. 共用部分

```text
TopBar：
TabBar：
Body 外层：
```

## 5. 页面差异

```text
PointContent：
MagicContent：
RaceContent：
```

## 6. 素材与 Slice

```text
素材：
九宫格：
普通 Fit 图片：
```

## 7. 滚动区域

```text
ScrollingFrame：
Canvas 设置：
可能风险：
```

## 8. 用户手动改动

只有 after 快照时：

```text
只有当前状态，不能严格判断改动来源。
```

有 before / after 时：

```text
新增：
删除：
属性变化：
```

## 9. 后续接脚本建议

```text
正式切页脚本：
数据绑定入口：
按钮事件入口：
哪些 UI 名称必须保持稳定：
```

