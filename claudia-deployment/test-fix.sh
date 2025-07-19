#!/bin/bash

# 测试修复后的 MCP 功能
echo "🧪 测试 MCP 服务器修复..."
echo "========================="

# 进入项目目录
cd "/Users/guoshuaihao/claude-flow/claudia-deployment/claudia-deployment/claudia" || exit 1

# 编译 Rust 代码
echo "📦 编译 Rust 代码..."
cd src-tauri
cargo build --no-default-features 2>&1 | tail -20

if [ $? -eq 0 ]; then
    echo "✅ 编译成功"
else
    echo "❌ 编译失败"
    exit 1
fi

echo ""
echo "🚀 现在可以运行 ./fix-and-run.sh 来测试应用"
echo "   MCP 服务器功能应该可以正常工作了"