#!/bin/bash

# 测试 MCP Server 修复
echo "🧪 测试 MCP Server 功能..."
echo "========================="

# 进入项目目录
cd "/Users/guoshuaihao/claude-flow/claudia-deployment/claudia-deployment/claudia" || exit 1

# 编译项目
echo "📦 编译项目..."
cd src-tauri
cargo build --no-default-features

if [ $? -eq 0 ]; then
    echo "✅ 编译成功"
else
    echo "❌ 编译失败"
    exit 1
fi

echo ""
echo "🚀 项目已编译完成"
echo "   现在可以运行 ./fix-and-run.sh 来测试应用"
echo ""
echo "📋 测试步骤："
echo "   1. 点击 MCP Servers 标签"
echo "   2. 找到 'Use Claude Code as MCP Server' 卡片"
echo "   3. 点击 'Start MCP Server' 按钮"
echo "   4. 应该看到成功提示，而不是错误信息"
echo ""
echo "⚠️  注意事项："
echo "   - MCP 服务器会在后台运行"
echo "   - 目前还没有实现停止服务器的功能"
echo "   - 如需停止，可以使用 ps aux | grep 'claude.*mcp.*serve' 找到进程并手动终止"