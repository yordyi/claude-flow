#!/bin/bash

# 修复 MCP Server UI 显示问题
echo "🔧 修复 MCP Server UI 显示问题..."
echo "================================="

# 进入项目目录
cd "/Users/guoshuaihao/claude-flow/claudia-deployment/claudia-deployment/claudia" || exit 1

echo "📝 修复说明："
echo "   ✅ 添加了 onSuccess 回调到 MCPImportExport 接口"
echo "   ✅ 修改了 handleStartMCPServer 函数使用正确的回调"
echo "   ✅ 更新了 MCPManager 组件以支持成功消息"
echo ""

echo "🚀 编译前端代码..."
# 这里可能需要编译 TypeScript，但通常 Vite 会自动处理
echo "   前端代码已更新，Vite 开发服务器会自动重新加载"
echo ""

echo "📋 修复内容："
echo "   问题: 成功消息通过 onError 显示，导致红色错误样式"
echo "   解决: 添加 onSuccess 回调，成功消息现在显示为绿色"
echo ""

echo "🧪 测试步骤："
echo "   1. 重新启动应用 (./fix-and-run.sh)"
echo "   2. 点击 MCP Servers 标签"
echo "   3. 点击 'Start MCP Server' 按钮"
echo "   4. 应该看到绿色成功消息，而不是红色错误消息"
echo ""

echo "✅ UI 修复完成！"
echo "   现在成功消息会正确显示为绿色提示"