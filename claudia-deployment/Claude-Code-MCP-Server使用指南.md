# Claude Code MCP Server 使用指南

## 🎯 什么是 Claude Code MCP Server？

Claude Code 可以作为 MCP (Model Context Protocol) Server 运行，允许其他应用程序通过标准化协议连接并使用 Claude Code 的功能。

### 核心优势
- 🔧 **丰富的工具集**：文件操作、代码分析、Git 操作等
- 🔌 **标准化接口**：遵循 MCP 协议，兼容各种客户端
- 🚀 **高性能**：原生二进制，响应快速
- 🛡️ **安全可靠**：权限控制和沙箱环境

## 🚀 启动 MCP Server

### 方法 1：通过 Claudia GUI
1. 打开 Claudia 应用
2. 点击 "MCP Servers" 标签
3. 找到 "Use Claude Code as MCP Server" 卡片
4. 点击 "Start MCP Server" 按钮
5. 看到绿色成功消息即启动成功

### 方法 2：通过命令行
```bash
# 基本启动
claude mcp serve

# 调试模式启动
claude mcp serve --debug

# 或使用内置二进制
./claude-code-aarch64-apple-darwin mcp serve
```

## 🔗 连接到 MCP Server

Claude Code MCP Server 使用 **stdio 协议**，这意味着它通过标准输入输出与客户端通信。

### 连接配置

在其他应用中配置 MCP 服务器：

```json
{
  "mcpServers": {
    "claude-code": {
      "command": "claude",
      "args": ["mcp", "serve"],
      "env": {}
    }
  }
}
```

或者使用完整路径：

```json
{
  "mcpServers": {
    "claude-code": {
      "command": "/path/to/claude-code-aarch64-apple-darwin",
      "args": ["mcp", "serve"],
      "env": {}
    }
  }
}
```

### 在 Claude Desktop 中使用

如果你有 Claude Desktop，可以在配置文件中添加：

**macOS 配置文件位置**：`~/Library/Application Support/Claude/claude_desktop_config.json`

```json
{
  "mcpServers": {
    "claude-code": {
      "command": "claude",
      "args": ["mcp", "serve"]
    }
  }
}
```

## 🛠️ 可用工具和功能

Claude Code MCP Server 提供以下工具类别：

### 文件操作工具
- **Read**: 读取文件内容
- **Write**: 写入文件
- **Edit**: 编辑文件
- **LS**: 列出目录内容
- **Glob**: 文件模式匹配

### 代码工具
- **Bash**: 执行命令行操作
- **Grep**: 搜索文件内容
- **Task**: 生成代理任务

### 项目管理
- **Git 操作**: 版本控制
- **依赖管理**: npm, pip 等
- **构建工具**: 编译、测试等

## 📋 实际使用示例

### 示例 1：在 VSCode 中使用

安装 MCP 扩展后，配置：

```json
{
  "mcp.servers": {
    "claude-code": {
      "command": "claude",
      "args": ["mcp", "serve"],
      "cwd": "${workspaceFolder}"
    }
  }
}
```

### 示例 2：在自定义应用中使用

**Python 客户端示例**：

```python
import subprocess
import json

# 启动 Claude Code MCP Server
process = subprocess.Popen(
    ["claude", "mcp", "serve"],
    stdin=subprocess.PIPE,
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE,
    text=True
)

# 发送 MCP 请求
request = {
    "jsonrpc": "2.0",
    "id": 1,
    "method": "tools/list",
    "params": {}
}

process.stdin.write(json.dumps(request) + "\n")
process.stdin.flush()

# 读取响应
response = process.stdout.readline()
print(json.loads(response))
```

**Node.js 客户端示例**：

```javascript
const { spawn } = require('child_process');

// 启动 MCP Server
const mcpServer = spawn('claude', ['mcp', 'serve']);

// 发送请求
const request = {
  jsonrpc: "2.0",
  id: 1,
  method: "tools/list",
  params: {}
};

mcpServer.stdin.write(JSON.stringify(request) + '\n');

// 处理响应
mcpServer.stdout.on('data', (data) => {
  const response = JSON.parse(data.toString());
  console.log('Available tools:', response.result);
});
```

## 🔧 高级配置

### 环境变量配置

```bash
# 设置工作目录
export CLAUDE_WORKSPACE="/path/to/your/project"

# 启用调试模式
export CLAUDE_DEBUG=true

# 启动 MCP Server
claude mcp serve
```

### 权限控制

```bash
# 限制允许的工具
claude mcp serve --allowed-tools "Read,Write,LS"

# 禁用某些工具
claude mcp serve --disallowed-tools "Bash"
```

## 🐛 故障排除

### 常见问题

1. **连接失败**
   ```bash
   # 检查 Claude Code 是否正确安装
   claude --version
   
   # 测试 MCP Server 启动
   claude mcp serve --debug
   ```

2. **权限错误**
   ```bash
   # 确保 Claude Code 有必要权限
   chmod +x /path/to/claude-code-binary
   ```

3. **工具不可用**
   ```bash
   # 检查可用工具列表
   claude mcp list-tools
   ```

### 调试技巧

```bash
# 启用详细日志
claude mcp serve --debug --verbose

# 查看进程状态
ps aux | grep "claude.*mcp.*serve"

# 监控资源使用
top -p $(pgrep -f "claude.*mcp.*serve")
```

## 🔄 与其他工具集成

### 集成到 CI/CD

```yaml
# GitHub Actions 示例
- name: Start Claude Code MCP Server
  run: |
    claude mcp serve &
    sleep 2
    
- name: Run automated tasks
  run: |
    # 使用 MCP 客户端调用 Claude Code 功能
    python scripts/mcp_client.py
```

### 集成到开发工具

```javascript
// 在开发工具中集成
class ClaudeCodeMCP {
  constructor() {
    this.server = spawn('claude', ['mcp', 'serve']);
  }
  
  async listFiles(directory) {
    return await this.sendRequest('tools/call', {
      name: 'LS',
      arguments: { path: directory }
    });
  }
  
  async editFile(file, changes) {
    return await this.sendRequest('tools/call', {
      name: 'Edit',
      arguments: { file_path: file, ...changes }
    });
  }
}
```

## 📊 性能优化

### 最佳实践

1. **复用连接**：避免频繁启动/停止 MCP Server
2. **批量操作**：合并多个小请求
3. **异步处理**：使用异步 I/O 避免阻塞
4. **资源监控**：定期检查内存和 CPU 使用

### 监控指标

```bash
# 监控 MCP Server 性能
while true; do
  ps aux | grep "claude.*mcp.*serve" | grep -v grep
  sleep 5
done
```

## 🎉 总结

Claude Code MCP Server 为开发者提供了强大的集成能力：

- ✅ **易于启动**：一键启动或命令行启动
- ✅ **标准协议**：兼容 MCP 生态系统
- ✅ **功能丰富**：涵盖文件、代码、Git 等操作
- ✅ **高度可配置**：支持权限控制和环境定制

通过 MCP Server，你可以将 Claude Code 的强大功能集成到任何支持 MCP 的应用中，实现工作流的自动化和智能化。

---

*更新时间：2025-07-19*