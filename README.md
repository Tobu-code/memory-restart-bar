# MemoryRestartBar

一个轻量、原生的 macOS 菜单栏工具，用于快速重启常用应用。

当前版本：`v1.0.1`

## 功能

- 从系统中添加任意 `.app`
- 持久化保存应用列表（`UserDefaults`）
- 在应用行内一键重启单个应用
- 在应用行内删除跟踪应用
- 串行执行 `Restart All` 批量重启
- 显示添加/重启/删除/批量执行状态

## 环境要求

- macOS 27+
- Xcode Command Line Tools / Swift 工具链

## 本地运行

```bash
swift build
swift run
```

## 编译为 `.app` 包

执行一个命令即可：

```bash
./scripts/build_app.sh
```

输出路径：`dist/MemoryRestartBar.app`
可以直接双击打开，或自行移动到 `/Applications` 目录使用。

## 签名不通过 / 无法打开时的处理

如果被 Gatekeeper 拦截，可执行：

```bash
xattr -dr com.apple.quarantine "dist/MemoryRestartBar.app"
spctl --assess -vv "dist/MemoryRestartBar.app"
```

然后在 Finder 里对应用右键 **打开** 一次，完成本机信任。

## 操作说明

1. 点击菜单栏图标打开菜单。
2. 点击 **Add Application...**，选择一个 `.app`。
3. 在应用行中使用图标操作：
   - **重启图标**：重启该应用
   - **垃圾桶图标**：删除该应用
4. 点击 **Restart All**，按顺序重启全部已添加应用。
5. 点击 **Quit** 退出程序。

## 状态提示说明

- `Added: <AppName>`：添加成功
- `Already added: <AppName>`：已存在重复应用
- `Restarted: <AppName>`：单应用重启成功
- `Quit timeout: <AppName>` / `Launch failed: <AppName>`：重启失败
- `Restart All done: x/y`：批量重启汇总

## 开发与测试

```bash
swift test
```

协作规范与提交规则见 `AGENTS.md`。

## 开源协议

本项目使用 MIT License 开源，详见 `LICENSE`。

##  致谢

感谢 [Linux Do](https://linux.do/) 提供社区氛围，L 站欢迎各位佬友
