# 仓库协作指南

## 项目结构与模块组织

当前仓库以方案文档驱动开发，主规格在 `DEVELOPMENT_PLAN.md`。后续实现应遵循其中的 AppKit 菜单栏方案。

推荐目录结构：

- `Sources/MemoryRestartBar/`：应用入口、菜单栏控制器、主流程
- `Sources/MemoryRestartBar/Services/`：应用解析、持久化、重启服务
- `Sources/MemoryRestartBar/Models/`：轻量数据模型，如 `TrackedApp`
- `Tests/MemoryRestartBarTests/`：单元测试与集成测试
- `Assets/`：图标或静态资源

模块职责保持单一，已跟踪应用列表必须只有一个状态源。

## 构建、测试与开发命令

默认使用 Swift Package Manager：

- `swift build`：编译项目，检查类型和构建错误
- `swift run`：启动本地开发版本
- `swift test`：运行测试（测试目录建立后）

每次非微小改动后都要执行 `swift build`。涉及 UI 或重启链路时，必须再按 `DEVELOPMENT_PLAN.md` 做手工验证。

## 代码风格与命名约定

- 语言：Swift，优先使用原生 macOS API（`AppKit`、`Foundation`）
- 缩进：4 个空格
- 类型名：`UpperCamelCase`，如 `RestartService`
- 方法和属性：`lowerCamelCase`，如 `restartAll`
- 文件名应与主类型名一致

优先小而清晰的类型。除非方案变更，否则不要把 SwiftUI 用于菜单内容。注释只写不直观的行为，不写显而易见的描述。

## 测试规范

测试放在 `Tests/MemoryRestartBarTests/`。测试文件名应与目标类型对应，例如 `RestartServiceTests.swift`。测试命名建议：

- `test_<场景>_<预期结果>`

最低覆盖要求：

- 持久化读写往返
- 重复添加应用拦截
- 从存储状态重建菜单
- 重启流程的成功与失败分支

## 提交与合并请求规范

提交信息使用简短祈使句，例如：

- `Add status bar host`
- `Implement app persistence`
- `Fix restart timeout handling`

PR 应包含：

- 改了什么
- 如何验证（如 `swift build`、`swift test`、手工验证）
- 涉及菜单或 UI 时附截图或录屏
- 已知限制与后续待办

## 代理执行规则

- 默认用中文交流与汇报，除非用户明确要求英文。
- 每完成一轮开发，都必须同步三项内容：
  - 改了什么
  - 怎么验证
  - 当前还剩什么风险
- 不要一次堆积过多功能；按迭代逐步实现、逐步验证。
- 如果发现方案与运行结果冲突，先说明证据，再调整实现，不要继续猜测式修补。
- 每轮验证通过后必须立即提交 Git 记录；提交日志要准确描述“本轮开发内容”。
- 若一次提交包含多轮内容，提交日志需明确分段标注（如 Iteration 1 / Iteration 2）并分别说明改动与验证结果。
- 每轮变更完成后，需主动询问是否需要变更版本号；若需要，先确认目标版本再修改代码与文档中的版本信息。

## 安全与配置提示

不要硬编码仅适用于当前机器的应用路径，除非是测试场景必需。优先使用 `bundleId` 定位应用，`appPath` 只作为回退信息保存。
