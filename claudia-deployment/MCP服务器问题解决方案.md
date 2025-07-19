# MCP 服务器加载问题解决方案

## 问题根本原因

MCP（Model Context Protocol）服务器加载失败的原因是 Tauri 应用在调用 Claude Code 二进制文件时的方式不正确。

### 具体问题：

1. **Sidecar 调用问题**：当使用内置的 Claude Code 二进制文件（sidecar）时，原代码使用了同步的命令执行方式，而 Tauri 的 sidecar API 是异步的。

2. **异步处理不当**：原始的 `execute_claude_mcp_command` 函数是同步的，但需要调用异步的 sidecar API。

3. **错误的命令构建**：使用 `fold` 方法构建命令参数时可能导致所有权问题。

## 已实施的修复

### 1. 修改了 `execute_claude_mcp_command` 函数

```rust
// 将函数改为异步
async fn execute_claude_mcp_command(app_handle: &AppHandle, args: Vec<&str>) -> Result<String>

// 正确处理 sidecar 调用
if claude_path == "claude-code" {
    use tauri_plugin_shell::ShellExt;
    
    let mut sidecar_cmd = app_handle
        .shell()
        .sidecar("claude-code")
        .map_err(|e| anyhow::anyhow!("Failed to create sidecar command: {}", e))?
        .arg("mcp");
    
    // 逐个添加参数
    for arg in args {
        sidecar_cmd = sidecar_cmd.arg(arg);
    }
    
    // 异步执行命令
    let output = sidecar_cmd
        .output()
        .await
        .map_err(|e| anyhow::anyhow!("Failed to execute sidecar: {}", e))?;
}
```

### 2. 更新所有调用点

所有调用 `execute_claude_mcp_command` 的地方都添加了 `.await`：

```rust
// 例如在 mcp_list 函数中
match execute_claude_mcp_command(&app, vec!["list"]).await {
    // ...
}
```

## 为什么出现这个问题？

1. **Tauri 的设计**：Tauri 的 sidecar 功能设计为异步操作，这样可以避免阻塞主线程。
2. **Claude Code 集成**：将 Claude Code 作为 sidecar 集成需要特殊处理其异步特性。
3. **开发环境差异**：可能在开发时使用了系统安装的 Claude Code，而打包后使用 sidecar，导致问题未被及时发现。

## 验证修复

1. **检查二进制文件**：
   ```bash
   ./claude-code-aarch64-apple-darwin mcp list
   # 输出: No MCP servers configured. Use `claude mcp add` to add a server.
   ```

2. **编译项目**：
   ```bash
   cd src-tauri
   cargo build --no-default-features
   ```

3. **运行应用**：
   ```bash
   ./fix-and-run.sh
   ```

## 后续优化建议

1. **错误处理改进**：
   - 添加更详细的错误信息，区分是找不到二进制文件还是执行失败
   - 在 UI 上提供更友好的错误提示

2. **性能优化**：
   - 考虑缓存 sidecar 命令的创建，避免重复创建
   - 对频繁调用的命令（如 list）添加缓存

3. **功能增强**：
   - 支持取消正在执行的 MCP 命令
   - 添加超时机制防止命令挂起

## 总结

这个问题的核心是同步/异步调用的不匹配。通过将 `execute_claude_mcp_command` 改为异步函数，并正确使用 Tauri 的 sidecar API，成功解决了 MCP 服务器加载失败的问题。

修复后，Claudia 应用可以正常：
- ✅ 加载 MCP 服务器列表
- ✅ 添加新的 MCP 服务器
- ✅ 管理和配置 MCP 服务器
- ✅ 与 Claude Code 正确集成

---

*更新时间：2025-07-19*