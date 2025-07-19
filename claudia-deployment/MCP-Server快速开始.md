# Claude Code MCP Server 快速开始

## 🚀 什么是 Claude Code MCP Server？

Claude Code MCP Server 让你可以将 Claude Code 的强大功能通过标准化的 MCP (Model Context Protocol) 协议暴露给其他应用程序使用。

**简单来说**：启动后，其他程序可以调用 Claude Code 的文件操作、代码分析、命令执行等功能。

## ⚡ 3 步快速启动

### 步骤 1：启动 MCP Server

**方法 A - 通过 Claudia 界面（推荐）**：
1. 打开 Claudia 应用
2. 点击 "MCP Servers" 标签
3. 点击绿色的 "Start MCP Server" 按钮
4. 看到绿色成功消息即可

**方法 B - 命令行启动**：
```bash
# 使用系统安装的 Claude Code
claude mcp serve

# 或使用内置二进制文件
./claudia-deployment/claudia/src-tauri/binaries/claude-code-aarch64-apple-darwin mcp serve
```

### 步骤 2：验证服务器运行

```bash
# 检查进程是否运行
ps aux | grep "claude.*mcp.*serve"
```

### 步骤 3：连接客户端

选择以下任一方式连接：

## 🎯 使用方式

### 方式 1：在 Claude Desktop 中使用

**配置文件位置**：`~/Library/Application Support/Claude/claude_desktop_config.json`

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

配置后重启 Claude Desktop，你就能在对话中使用 Claude Code 的工具了！

### 方式 2：Python 客户端

```bash
# 运行 Python 示例
python3 mcp-client-example.py
```

示例功能：
- 📋 列出可用工具
- 📁 浏览目录
- 📄 读取文件
- 💻 执行命令

### 方式 3：Node.js 客户端

```bash
# 运行 Node.js 示例
node mcp-client-example.js
```

### 方式 4：自定义集成

使用提供的示例代码，集成到你自己的应用中。

## 🛠️ 可用功能

Claude Code MCP Server 提供丰富的工具：

| 工具类别 | 功能 | 用途 |
|---------|------|------|
| **文件操作** | Read, Write, Edit, LS | 文件管理和编辑 |
| **搜索工具** | Grep, Glob | 内容搜索和文件查找 |
| **代码工具** | Bash, Git操作 | 命令执行和版本控制 |
| **项目管理** | 依赖管理, 构建工具 | 项目开发支持 |

## 🧪 测试示例

运行完整的测试脚本：

```bash
./test-mcp-examples.sh
```

这个脚本会：
- ✅ 检查环境配置
- 🐍 测试 Python 客户端
- 🟢 测试 Node.js 客户端
- 📖 提供配置指南

## 💡 实际使用场景

### 场景 1：IDE 集成
在 VSCode 等编辑器中集成 Claude Code 功能，实现智能代码分析和自动化操作。

### 场景 2：CI/CD 流水线
在自动化构建中使用 Claude Code 进行代码审查、测试生成等。

### 场景 3：开发工具链
将 Claude Code 作为后端服务，为开发工具提供 AI 能力。

### 场景 4：自动化脚本
编写脚本自动化执行复杂的文件操作和代码分析任务。

## 🔧 故障排除

### 常见问题

**Q: MCP Server 启动失败？**
```bash
# 检查 Claude Code 是否正确安装
claude --version

# 或使用完整路径
./claudia-deployment/claudia/src-tauri/binaries/claude-code-aarch64-apple-darwin --help
```

**Q: 客户端连接失败？**
- 确保 MCP Server 正在运行
- 检查命令路径是否正确
- 查看错误日志

**Q: 工具不可用？**
```bash
# 启用调试模式查看详细信息
claude mcp serve --debug
```

## 📚 更多资源

- **详细使用指南**：`Claude-Code-MCP-Server使用指南.md`
- **Python 客户端**：`mcp-client-example.py`
- **Node.js 客户端**：`mcp-client-example.js`
- **Claude Desktop 配置**：`claude-desktop-config-example.json`

## 🎉 总结

通过 Claude Code MCP Server，你可以：

- ✅ **轻松启动**：一键启动或命令行启动
- ✅ **标准协议**：兼容所有 MCP 客户端
- ✅ **功能丰富**：文件、代码、Git 等全方位支持
- ✅ **易于集成**：提供多种语言的客户端示例

现在就开始使用 Claude Code MCP Server，将 AI 能力集成到你的开发工作流中吧！

---

*更新时间：2025-07-19*