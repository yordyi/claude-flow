#!/usr/bin/env python3
"""
更新 Claude Desktop 配置，添加 Claude Code MCP Server
"""

import json
import os
from pathlib import Path

def main():
    # 配置文件路径
    config_path = Path.home() / "Library/Application Support/Claude/claude_desktop_config.json"
    claude_code_path = "/Users/guoshuaihao/claude-flow/claudia-deployment/claudia-deployment/claudia/src-tauri/binaries/claude-code-aarch64-apple-darwin"
    
    print("🔧 更新 Claude Desktop 配置...")
    print(f"配置文件: {config_path}")
    print(f"Claude Code 路径: {claude_code_path}")
    
    # 检查 Claude Code 二进制文件是否存在
    if not os.path.exists(claude_code_path):
        print(f"❌ Claude Code 二进制文件不存在: {claude_code_path}")
        return False
    
    # 确保二进制文件有执行权限
    os.chmod(claude_code_path, 0o755)
    print("✅ 设置执行权限")
    
    # 读取现有配置
    try:
        with open(config_path, 'r') as f:
            config = json.load(f)
    except Exception as e:
        print(f"❌ 读取配置文件失败: {e}")
        return False
    
    # 添加 Claude Code 配置
    if "mcpServers" not in config:
        config["mcpServers"] = {}
    
    config["mcpServers"]["claude-code"] = {
        "command": claude_code_path,
        "args": ["mcp", "serve"],
        "env": {}
    }
    
    # 写回配置文件
    try:
        with open(config_path, 'w') as f:
            json.dump(config, f, indent=4)
        print("✅ 配置文件更新成功")
        return True
    except Exception as e:
        print(f"❌ 写入配置文件失败: {e}")
        return False

if __name__ == "__main__":
    if main():
        print("\n🎉 Claude Code MCP Server 已添加到 Claude Desktop!")
        print("\n📋 下一步:")
        print("1. 重启 Claude Desktop 应用")
        print("2. 在对话中，你将看到 claude-code 工具可用")
        print("3. 可以使用文件操作、代码分析等功能")
        print("\n💡 提示:")
        print("- 输入文件路径让 Claude Code 读取文件")
        print("- 请求代码分析和修改")
        print("- 执行命令行操作")
    else:
        print("\n❌ 配置失败，请检查错误信息")