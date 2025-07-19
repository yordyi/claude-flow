#!/bin/bash

# 验证 Claude Desktop 和 Claude Code 配置
echo "🔍 验证 Claude Desktop 和 Claude Code MCP 配置"
echo "=============================================="
echo ""

# 检查配置文件
CONFIG_FILE="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
CLAUDE_CODE_BINARY="/Users/guoshuaihao/claude-flow/claudia-deployment/claudia-deployment/claudia/src-tauri/binaries/claude-code-aarch64-apple-darwin"

echo "📋 检查配置文件..."
if [ -f "$CONFIG_FILE" ]; then
    echo "✅ Claude Desktop 配置文件存在"
    
    # 检查是否包含 claude-code 配置
    if grep -q "claude-code" "$CONFIG_FILE"; then
        echo "✅ claude-code MCP Server 已配置"
    else
        echo "❌ claude-code MCP Server 未找到在配置中"
    fi
else
    echo "❌ Claude Desktop 配置文件不存在"
fi

echo ""
echo "🔧 检查 Claude Code 二进制文件..."
if [ -f "$CLAUDE_CODE_BINARY" ]; then
    echo "✅ Claude Code 二进制文件存在"
    
    if [ -x "$CLAUDE_CODE_BINARY" ]; then
        echo "✅ 有执行权限"
    else
        echo "⚠️  设置执行权限..."
        chmod +x "$CLAUDE_CODE_BINARY"
    fi
    
    # 测试二进制文件
    echo "🧪 测试 Claude Code 功能..."
    if "$CLAUDE_CODE_BINARY" --version > /dev/null 2>&1; then
        echo "✅ Claude Code 二进制文件正常工作"
        echo "   版本: $("$CLAUDE_CODE_BINARY" --version)"
    else
        echo "❌ Claude Code 二进制文件无法运行"
    fi
else
    echo "❌ Claude Code 二进制文件不存在"
fi

echo ""
echo "🍎 检查 Claude Desktop 应用..."
if [ -d "/Applications/Claude.app" ]; then
    echo "✅ Claude Desktop 应用已安装"
    
    # 检查是否在运行
    if pgrep -f "Claude" > /dev/null; then
        echo "🔄 Claude Desktop 正在运行"
        echo "   需要重启应用以加载新配置"
    else
        echo "💤 Claude Desktop 未运行"
    fi
else
    echo "❌ Claude Desktop 应用未安装"
    echo "   请从 https://claude.ai/download 下载安装"
fi

echo ""
echo "📋 配置摘要:"
echo "   配置文件: $CONFIG_FILE"
echo "   Claude Code: $CLAUDE_CODE_BINARY"
echo ""

echo "🎯 使用步骤:"
echo "1. 重启 Claude Desktop 应用"
echo "2. 等待 MCP 服务器连接 (可能需要几秒钟)"
echo "3. 在对话中，你将看到新的工具可用"
echo ""

echo "💡 测试示例:"
echo "在 Claude Desktop 中尝试这些命令:"
echo "- '请读取我的 package.json 文件'"
echo "- '列出当前目录的文件'"
echo "- '运行 pwd 命令'"
echo "- '搜索包含 TODO 的文件'"
echo ""

echo "🔧 故障排除:"
echo "如果 claude-code 工具不出现:"
echo "1. 确保 Claude Desktop 完全重启"
echo "2. 检查配置文件语法是否正确"
echo "3. 查看 Claude Desktop 的开发者工具控制台"
echo ""

echo "✅ 验证完成！"