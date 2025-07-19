#!/bin/bash

# 测试 MCP 客户端示例
echo "🧪 测试 Claude Code MCP 客户端示例"
echo "==================================="

# 检查当前目录
cd "/Users/guoshuaihao/claude-flow/claudia-deployment" || exit 1

echo "📍 当前目录: $(pwd)"
echo ""

# 检查 Claude Code 二进制文件
CLAUDE_BINARY="./claudia-deployment/claudia/src-tauri/binaries/claude-code-aarch64-apple-darwin"

if [ -f "$CLAUDE_BINARY" ]; then
    echo "✅ 找到 Claude Code 二进制文件"
    echo "   路径: $CLAUDE_BINARY"
    
    # 检查执行权限
    if [ -x "$CLAUDE_BINARY" ]; then
        echo "✅ 二进制文件有执行权限"
    else
        echo "⚠️  设置执行权限..."
        chmod +x "$CLAUDE_BINARY"
    fi
else
    echo "❌ 未找到 Claude Code 二进制文件"
    echo "   请先运行: ./test-mcp-server.sh"
    exit 1
fi

echo ""
echo "📋 可用的示例客户端:"
echo "   1. Python 客户端: mcp-client-example.py"
echo "   2. Node.js 客户端: mcp-client-example.js"
echo "   3. Claude Desktop 配置: claude-desktop-config-example.json"
echo ""

# 检查 Python
if command -v python3 &> /dev/null; then
    echo "🐍 测试 Python 客户端..."
    echo "   运行: python3 mcp-client-example.py \"$CLAUDE_BINARY\""
    echo "   (按 Ctrl+C 可以随时中断)"
    echo ""
    
    # 给用户选择
    read -p "是否运行 Python 客户端示例? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        python3 mcp-client-example.py "$CLAUDE_BINARY"
    fi
    echo ""
fi

# 检查 Node.js
if command -v node &> /dev/null; then
    echo "🟢 测试 Node.js 客户端..."
    echo "   运行: node mcp-client-example.js \"$CLAUDE_BINARY\""
    echo "   (按 Ctrl+C 可以随时中断)"
    echo ""
    
    # 给用户选择
    read -p "是否运行 Node.js 客户端示例? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        node mcp-client-example.js "$CLAUDE_BINARY"
    fi
    echo ""
fi

# Claude Desktop 配置说明
echo "🎨 Claude Desktop 集成:"
echo "   1. 复制 claude-desktop-config-example.json 到 Claude Desktop 配置目录"
echo "   2. macOS 配置文件位置: ~/Library/Application Support/Claude/claude_desktop_config.json"
echo "   3. 修改 command 路径为您的 Claude Code 安装路径"
echo ""

echo "📖 详细使用指南:"
echo "   查看文件: Claude-Code-MCP-Server使用指南.md"
echo ""

echo "🎉 测试完成！"
echo "   您现在可以使用这些示例连接到 Claude Code MCP Server"