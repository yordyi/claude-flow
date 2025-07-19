# Claude Code MCP Server 功能说明

## 问题分析

MCP Server 启动失败的原因是 `mcp_serve` 函数没有正确处理 sidecar 二进制文件的情况。

### 原始代码问题

```rust
// 原代码直接使用 create_command_with_env，不支持 sidecar
let mut cmd = create_command_with_env(&claude_path);
cmd.arg("mcp").arg("serve");
```

当 `claude_path` 是 "claude-code"（表示使用内置的 sidecar）时，这种方式会失败。

## 解决方案

修改 `mcp_serve` 函数以支持 sidecar：

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
}
```

## 功能说明

### MCP Server 是什么？

MCP (Model Context Protocol) Server 允许 Claude Code 作为一个服务器运行，其他应用程序可以连接到它并使用其功能。这对于：

1. **集成开发**：其他应用可以通过 MCP 协议与 Claude Code 通信
2. **自动化工作流**：可以编程方式使用 Claude Code 的功能
3. **扩展功能**：第三方工具可以利用 Claude Code 的能力

### 使用方法

1. 在 Claudia 应用中点击 "MCP Servers" 标签
2. 找到绿色的 "Use Claude Code as MCP Server" 卡片
3. 点击 "Start MCP Server" 按钮
4. 服务器将在后台启动

### 技术细节

- **默认端口**：MCP Server 通常在默认端口运行（具体端口由 Claude Code 决定）
- **协议**：使用 stdio 或 HTTP/SSE 进行通信
- **进程管理**：服务器作为独立进程运行

## 待改进功能

### 1. 停止服务器功能

目前还没有实现停止 MCP Server 的功能。建议添加：

```typescript
// 前端添加停止按钮
const handleStopMCPServer = async () => {
  try {
    await api.mcpStopServer();
    setServerRunning(false);
  } catch (error) {
    onError("Failed to stop MCP server");
  }
};
```

### 2. 服务器状态显示

显示服务器是否正在运行：

```typescript
const [serverRunning, setServerRunning] = useState(false);

// 检查服务器状态
const checkServerStatus = async () => {
  const status = await api.mcpGetServerStatus();
  setServerRunning(status.running);
};
```

### 3. 配置选项

允许用户配置：
- 监听端口
- 认证选项
- 日志级别

## 测试步骤

1. 运行编译脚本：
   ```bash
   ./test-mcp-server.sh
   ```

2. 启动应用：
   ```bash
   ./fix-and-run.sh
   ```

3. 测试功能：
   - 点击 "Start MCP Server"
   - 应该看到成功消息，而不是错误

4. 验证服务器运行：
   ```bash
   ps aux | grep 'claude.*mcp.*serve'
   ```

## 注意事项

- MCP Server 会持续运行直到手动停止
- 如果端口被占用，启动可能失败
- 确保防火墙允许相关端口访问

---

*更新时间：2025-07-19*