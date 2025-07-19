#!/bin/bash

# Claudia 启动脚本
# 自动设置环境并启动应用程序

echo "🚀 正在启动 Claudia..."
echo "=================="

# 先执行清理
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/clean.sh" ]; then
    echo "🧹 执行清理脚本..."
    "$SCRIPT_DIR/clean.sh"
    echo ""
fi

# 设置必要的环境变量
export PATH="$HOME/.cargo/bin:$PATH"

# 检查依赖
echo "📋 检查依赖..."

if ! command -v cargo &> /dev/null; then
    echo "❌ 错误: cargo 未找到，请确保 Rust 已正确安装"
    exit 1
fi

if ! command -v bun &> /dev/null; then
    echo "❌ 错误: bun 未找到，请安装 Bun"
    exit 1
fi

if ! command -v claude &> /dev/null; then
    echo "❌ 错误: claude 未找到，请安装 Claude Code CLI"
    exit 1
fi

echo "✅ 所有依赖检查通过"

# 进入项目目录
cd "/Users/guoshuaihao/claude-flow/claudia-deployment/claudia-deployment/claudia" || {
    echo "❌ 错误: 无法找到项目目录"
    exit 1
}

echo "📁 当前目录: $(pwd)"

# 检查项目文件
if [ ! -f "package.json" ]; then
    echo "❌ 错误: package.json 未找到"
    exit 1
fi

if [ ! -d "src-tauri" ]; then
    echo "❌ 错误: src-tauri 目录未找到"
    exit 1
fi

echo "✅ 项目文件检查通过"

# 检查并修复 sidecar 二进制文件
echo "🔧 检查 Claude Code 二进制文件..."
if [ -f "src-tauri/binaries/claude-code-aarch64-apple-darwin" ]; then
    echo "✅ Claude Code 二进制文件存在"
    # 确保文件有执行权限
    chmod +x "src-tauri/binaries/claude-code-aarch64-apple-darwin"
else
    echo "❌ 错误: Claude Code 二进制文件未找到"
    echo "   请运行: bun run build:executables:current"
    exit 1
fi

# 显示版本信息
echo "🔧 工具版本:"
echo "  - Rust: $(rustc --version 2>/dev/null || echo '未安装')"
echo "  - Cargo: $(cargo --version 2>/dev/null || echo '未安装')"
echo "  - Bun: $(bun --version 2>/dev/null || echo '未安装')"
echo "  - Claude: $(claude --version 2>/dev/null || echo '未安装')"

echo ""
echo "🎯 启动 Claudia 开发模式..."
echo "这将启动:"
echo "  - Vite 开发服务器 (前端): http://localhost:1420"
echo "  - Tauri 桌面应用 (后端)"
echo ""
echo "注意: 首次启动可能需要几分钟来编译 Rust 代码"
echo "请等待应用程序窗口出现..."
echo ""

# 启动应用程序
echo "▶️  执行: bun run tauri dev"
echo "=================="

exec bun run tauri dev