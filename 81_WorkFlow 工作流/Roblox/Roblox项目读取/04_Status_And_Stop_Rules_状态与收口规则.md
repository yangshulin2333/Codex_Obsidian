# 状态与收口规则

这个文件解决一个问题：用户不应该感觉 Codex 一直在来回导入信息。

Codex 每轮都要说明：

```text
当前阶段是什么
这轮为什么要导
输出保存到哪里
完成标准是什么
完成后下一步是什么
是否已经可以停止导入
```

## STATUS.md 模板

Bootstrap 会在项目根目录下创建：

```text
Project_Analysis_Package/STATUS.md
```

建议内容结构：

```text
# Roblox 项目读取状态

## 当前阶段
例如：脚本/Remote 导出、AssetId 搜索、目标源码导出、资源树导出、总接管报告。

## 已完成
- ...

## 本轮 Studio 操作
- 运行脚本：
- 保存到：
- 完成标准：

## 是否继续导入
- 是/否
- 原因：

## 下一步
- ...
```

## 每个导出的完成标准

| 导出 | 完成标准 |
|---|---|
| QuickFocused | 有项目上下文、脚本列表、Remote/Bindable 列表 |
| ProjectOnlyAsset | 有资源表；如果缺 `## End`，只能当样本 |
| AnimationSound | 有 `## End`，Animation/Sound 数量可统计 |
| SourceAssetSearch | 有 `## End`，AssetId 命中可统计 |
| TargetSource | 目标脚本全是 Found，文件有 `## End` |
| TargetExplorer | 目标路径 Found；如果缺 `## End`，切换 Compact |
| TargetExplorerCompact | 有 `## End`，补齐缺失资源细节 |

## 什么时候停止导入

满足以下条件就停止继续让用户跑 Studio 导出：

```text
1. 已掌握启动入口和 Rojo/Studio 基线。
2. 已掌握脚本数量、Remote/Bindable、主要服务边界。
3. 已掌握源码 AssetId 和动画/音频基线。
4. 已用 TargetSource 覆盖核心玩法链路和主要风险模块。
5. 已用 TargetExplorer/Compact 覆盖关键资源树。
6. 最后一轮关键导出有 ## End。
7. Codex 能写出“核心玩法链路、资源结构、风险清单、下一步决策”。
```

停止后 Codex 应明确说：

```text
资源导入阶段到这里收口。
下一步不是继续导入，而是生成总接管报告，并选择第一阶段目标。
```

## 什么时候允许继续导入

只有以下情况才继续导入：

- 某个关键输出缺少 `## End`，并且结论依赖缺失部分。
- 目标源码里出现新的关键脚本路径，必须追链。
- 用户明确要求继续深挖某个系统，例如支付、抽奖、升级、背包。
- 要修复/复刻某个功能，但缺少它的资源树或源码。

否则不要为了“更完整”无限导入。
