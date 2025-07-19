#!/bin/bash

# Claude Code MCP Server 一键演示脚本
echo "🎯 Claude Code MCP Server 演示"
echo "=============================="
echo ""

# 检查环境
CLAUDE_BINARY="./claudia-deployment/claudia/src-tauri/binaries/claude-code-aarch64-apple-darwin"

if [ ! -f "$CLAUDE_BINARY" ]; then
    echo "❌ Claude Code 二进制文件未找到"
    echo "   请先运行: ./test-mcp-server.sh"
    exit 1
fi

# 确保有执行权限
chmod +x "$CLAUDE_BINARY"

echo "🚀 启动 Claude Code MCP Server..."
echo "   进程将在后台运行，按 Ctrl+C 可以随时停止演示"
echo ""

# 启动 MCP Server
"$CLAUDE_BINARY" mcp serve --debug &
MCP_PID=$!

# 等待服务器启动
sleep 3

# 检查服务器是否启动成功
if kill -0 $MCP_PID 2>/dev/null; then
    echo "✅ MCP Server 启动成功 (PID: $MCP_PID)"
else
    echo "❌ MCP Server 启动失败"
    exit 1
fi

echo ""
echo "📋 现在可以用以下方式连接:"
echo ""

# 提供选项菜单
while true; do
    echo "请选择演示方式:"
    echo "  1) Python 客户端演示"
    echo "  2) Node.js 客户端演示"
    echo "  3) 查看 Claude Desktop 配置方法"
    echo "  4) 手动测试 (保持 MCP Server 运行)"
    echo "  5) 停止演示并退出"
    echo ""
    read -p "请输入选择 (1-5): " choice

    case $choice in
        1)
            if command -v python3 &> /dev/null; then
                echo ""
                echo "🐍 运行 Python 客户端演示..."
                python3 mcp-client-example.py "$CLAUDE_BINARY"
            else
                echo "❌ Python3 未安装"
            fi
            echo ""
            ;;
        2)
            if command -v node &> /dev/null; then
                echo ""
                echo "🟢 运行 Node.js 客户端演示..."
                node mcp-client-example.js "$CLAUDE_BINARY"
            else
                echo "❌ Node.js 未安装"
            fi
            echo ""
            ;;
        3)
            echo ""
            echo "🎨 Claude Desktop 配置方法:"
            echo ""
            echo "1. 打开配置文件:"
            echo "   ~/Library/Application Support/Claude/claude_desktop_config.json"
            echo ""
            echo "2. 添加以下配置:"
            cat claude-desktop-config-example.json
            echo ""
            echo "3. 将 'claude' 替换为完整路径:"
            echo "   \"command\": \"$(pwd)/$CLAUDE_BINARY\""
            echo ""
            echo "4. 重启 Claude Desktop"
            echo ""
            ;;
        4)
            echo ""
            echo "🔧 手动测试模式:"
            echo ""
            echo "MCP Server 正在运行，PID: $MCP_PID"
            echo "二进制文件路径: $(pwd)/$CLAUDE_BINARY"
            echo ""
            echo "你可以:"
            echo "- 配置 Claude Desktop"
            echo "- 运行自定义客户端"
            echo "- 集成到其他应用"
            echo ""
            echo "按任意键返回菜单..."
            read -n 1
            echo ""
            ;;
        5)
            break
            ;;
        *)
            echo "❌ 无效选择，请输入 1-5"
            echo ""
            ;;
    esac
done

# 清理
echo ""
echo "🛑 停止 MCP Server..."
kill $MCP_PID 2>/dev/null
wait $MCP_PID 2>/dev/null

echo "✅ 演示结束"
echo ""
echo "📖 更多信息请查看:"
echo "   - MCP-Server快速开始.md"
echo "   - Claude-Code-MCP-Server使用指南.md"