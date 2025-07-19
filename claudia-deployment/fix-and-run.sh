#!/bin/bash

# Claudia 修复并运行脚本
# 解决所有已知问题并启动应用

echo "🔧 Claudia 问题修复脚本"
echo "========================"
echo ""
echo "此脚本将："
echo "  1. 清理所有残留进程和文件"
echo "  2. 修复 MCP 服务器加载问题"
echo "  3. 确保二进制文件正确配置"
echo "  4. 启动应用程序"
echo ""
echo "按 Enter 继续，或 Ctrl+C 取消..."
read

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit 1

# 1. 执行清理
echo "步骤 1/4: 清理环境..."
if [ -f "./clean.sh" ]; then
    ./clean.sh
else
    echo "⚠️  清理脚本不存在，跳过清理步骤"
fi
echo ""

# 2. 确保在正确的项目目录
echo "步骤 2/4: 进入项目目录..."
cd "claudia-deployment/claudia" || {
    echo "❌ 错误: 无法进入项目目录"
    exit 1
}
echo "✅ 当前目录: $(pwd)"
echo ""

# 3. 检查并修复二进制文件
echo "步骤 3/4: 检查 Claude Code 二进制文件..."

# 检查是否需要构建二进制文件
if [ ! -f "src-tauri/binaries/claude-code-aarch64-apple-darwin" ]; then
    echo "⚠️  二进制文件不存在，正在构建..."
    bun run build:executables:current
fi

# 确保二进制文件有执行权限
if [ -f "src-tauri/binaries/claude-code-aarch64-apple-darwin" ]; then
    chmod +x "src-tauri/binaries/claude-code-aarch64-apple-darwin"
    echo "✅ Claude Code 二进制文件已准备就绪"
else
    echo "❌ 错误: 无法构建二进制文件"
    exit 1
fi
echo ""

# 4. 检查 Claude Code CLI 是否安装
echo "步骤 4/4: 检查 Claude Code CLI..."
if command -v claude &> /dev/null; then
    echo "✅ Claude Code CLI 已安装: $(claude --version)"
else
    echo "⚠️  Claude Code CLI 未安装"
    echo "   MCP 功能将不可用，但应用可以正常运行"
    echo "   要安装 Claude Code CLI，请访问: https://claude.ai/code"
fi
echo ""

# 5. 启动应用
echo "🚀 启动 Claudia..."
echo "=================="
echo "注意事项："
echo "  - 首次启动可能需要几分钟编译"
echo "  - 应用窗口会自动打开"
echo "  - 开发服务器运行在: http://localhost:1420"
echo "  - 按 Ctrl+C 停止应用"
echo ""

# 设置环境变量并启动
export PATH="$HOME/.cargo/bin:$PATH"
export RUST_LOG=info

# 使用 exec 替换当前进程，确保信号正确传递
exec bun run tauri dev