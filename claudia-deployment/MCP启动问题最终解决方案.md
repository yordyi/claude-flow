# MCP Server 启动问题最终解决方案

## 🚨 问题根源

从你的截图可以看到，当点击 "Start MCP Server" 按钮时出现了 "Failed to start Claude Code as MCP server" 错误。

### 核心问题
`mcp_serve` 函数没有正确处理 Tauri sidecar 的情况，导致启动失败。

## ✅ 已实施的修复

### 1. 修改了 `src-tauri/src/commands/mcp.rs` 中的 `mcp_serve` 函数

**原代码问题**：
```rust
// 原代码直接使用普通命令执行，不支持 sidecar
let mut cmd = create_command_with_env(&claude_path);
cmd.arg("mcp").arg("serve");
```

**修复后的代码**：
```rust
// 检查是否使用 sidecar
if claude_path == "claude-code" {
    // 使用 Tauri sidecar API
    use tauri_plugin_shell::ShellExt;
    
    let sidecar = app
        .shell()
        .sidecar("claude-code")
        .map_err(|e| format!("Failed to create sidecar command: {}", e))?
        .arg("mcp")
        .arg("serve");
    
    // 启动 sidecar 进程
    match sidecar.spawn() {
        Ok(mut child) => {
            info!("Successfully started Claude Code MCP server via sidecar");
            Ok("Claude Code MCP server started".to_string())
        }
        Err(e) => {
            error!("Failed to spawn MCP server sidecar: {}", e);
            Err(format!("Failed to start MCP server: {}", e))
        }
    }
} else {
    // 使用系统安装的 Claude Code
    // ...
}
```

### 2. 验证了 Claude Code 二进制文件支持 MCP serve

```bash
./claude-code-aarch64-apple-darwin mcp serve --help
# ✅ 命令存在且可用
```

## 🎯 测试步骤

### 1. 编译修复后的代码
```bash
./test-mcp-server.sh
```

### 2. 启动应用
```bash
./fix-and-run.sh
```

### 3. 测试 MCP Server 功能
1. 点击 "MCP Servers" 标签
2. 找到绿色的 "Use Claude Code as MCP Server" 卡片
3. 点击 "Start MCP Server" 按钮
4. 应该看到成功提示：**"Claude Code MCP server started. You can now connect to it from other applications."**

## 🔍 故障排除

如果仍然失败，检查：

### 1. 二进制文件权限
```bash
ls -la src-tauri/binaries/claude-code-aarch64-apple-darwin
# 应该有执行权限 (x)
```

### 2. 端口占用
```bash
lsof -i :8080  # 或其他 MCP 默认端口
```

### 3. 查看日志
在应用的开发者控制台中查看详细错误信息。

## 💡 MCP Server 功能说明

### 什么是 MCP Server？
MCP (Model Context Protocol) Server 允许 Claude Code 作为服务器运行，其他应用程序可以连接并使用其功能。

### 使用场景
- **集成开发**：其他应用通过 MCP 协议与 Claude Code 通信
- **自动化工作流**：编程方式使用 Claude Code 功能
- **第三方扩展**：允许其他工具利用 Claude Code 能力

### 技术细节
- **协议**：使用 stdio 或 HTTP/SSE 通信
- **进程**：作为独立后台进程运行
- **端口**：使用 Claude Code 的默认配置

## 🚧 待改进功能

1. **停止服务器**：目前只能启动，无法通过界面停止
2. **状态显示**：显示服务器是否正在运行
3. **配置选项**：端口、认证等设置

## 📋 验证清单

修复后，你应该能够：
- ✅ 成功启动 MCP Server 而不出现错误
- ✅ 看到成功提示消息
- ✅ 在进程列表中找到运行的 MCP Server 进程

```bash
# 验证 MCP Server 是否运行
ps aux | grep 'claude.*mcp.*serve'
```

## 🎉 总结

这个问题的核心是 Tauri sidecar API 的正确使用。通过修改 `mcp_serve` 函数来正确处理 sidecar 情况，MCP Server 功能现在应该可以正常工作了。

运行测试脚本编译项目，然后启动应用测试功能即可！

---

*更新时间：2025-07-19*