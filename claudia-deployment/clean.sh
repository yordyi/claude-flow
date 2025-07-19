#!/bin/bash

# Claudia 清理脚本
# 清理所有运行产生的垃圾文件和进程

echo "🧹 开始清理 Claudia 运行垃圾..."
echo "================================="

# 1. 终止所有相关进程
echo "🔄 清理残留进程..."
pkill -f "claudia" 2>/dev/null
pkill -f "vite" 2>/dev/null
pkill -f "tauri" 2>/dev/null
pkill -f "cargo.*claudia" 2>/dev/null
sleep 1

# 2. 清理 Rust 构建缓存
echo "🗑️  清理 Rust 构建缓存..."
cd "/Users/guoshuaihao/claude-flow/claudia-deployment/claudia-deployment/claudia" 2>/dev/null || {
    echo "⚠️  警告: 无法进入项目目录"
}

if [ -d "src-tauri/target" ]; then
    echo "   - 清理 target 目录..."
    rm -rf src-tauri/target/debug/incremental/*
    rm -rf src-tauri/target/debug/deps/*
    rm -f src-tauri/target/debug/claudia
    rm -f src-tauri/target/debug/.fingerprint/*
fi

# 3. 清理临时文件
echo "📄 清理临时文件..."
find . -name "*.tmp" -delete 2>/dev/null
find . -name "*.log" -delete 2>/dev/null
find . -name "anthropic-ai-claude-code-*.tgz" -delete 2>/dev/null
rm -rf temp-claude-package 2>/dev/null
rm -f cli-native-bundled.js 2>/dev/null

# 4. 清理 node_modules 缓存（可选）
# echo "📦 清理 node_modules 缓存..."
# rm -rf node_modules/.cache 2>/dev/null
# rm -rf node_modules/.vite 2>/dev/null

# 5. 清理 Vite 缓存
echo "⚡ 清理 Vite 缓存..."
rm -rf .vite 2>/dev/null
rm -rf dist 2>/dev/null

# 6. 清理系统临时目录中的相关文件
echo "🗑️  清理系统临时文件..."
rm -rf /tmp/claudia* 2>/dev/null
rm -rf /tmp/tauri* 2>/dev/null
rm -rf /tmp/vite* 2>/dev/null

# 7. 检查端口占用
echo "🔍 检查端口占用..."
lsof -i :1420 | grep LISTEN | awk '{print $2}' | xargs kill -9 2>/dev/null

# 8. 清理 cargo 注册表缓存（可选，慎用）
# echo "📦 清理 Cargo 缓存..."
# cargo clean 2>/dev/null

echo ""
echo "✅ 清理完成！"
echo ""
echo "🔄 清理统计："
echo "   - 进程已终止"
echo "   - 构建缓存已清理"
echo "   - 临时文件已删除"
echo "   - 端口已释放"
echo ""
echo "💡 提示: 现在可以安全地运行 ./start-claudia.sh"
echo "================================="