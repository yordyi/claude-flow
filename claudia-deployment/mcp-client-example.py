#!/usr/bin/env python3
"""
Claude Code MCP Client 示例
演示如何连接到 Claude Code MCP Server 并使用其功能
"""

import subprocess
import json
import sys
import time

class ClaudeCodeMCPClient:
    def __init__(self, claude_path="claude"):
        """初始化 MCP 客户端"""
        self.claude_path = claude_path
        self.process = None
        self.request_id = 0
    
    def start_server(self):
        """启动 Claude Code MCP Server"""
        print("🚀 启动 Claude Code MCP Server...")
        try:
            self.process = subprocess.Popen(
                [self.claude_path, "mcp", "serve"],
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                bufsize=1  # 行缓冲
            )
            # 等待服务器启动
            time.sleep(2)
            print("✅ MCP Server 启动成功")
            return True
        except Exception as e:
            print(f"❌ 启动失败: {e}")
            return False
    
    def send_request(self, method, params=None):
        """发送 MCP 请求"""
        if not self.process:
            raise Exception("MCP Server 未启动")
        
        self.request_id += 1
        request = {
            "jsonrpc": "2.0",
            "id": self.request_id,
            "method": method,
            "params": params or {}
        }
        
        print(f"📤 发送请求: {method}")
        try:
            # 发送请求
            request_json = json.dumps(request) + "\n"
            self.process.stdin.write(request_json)
            self.process.stdin.flush()
            
            # 读取响应
            response_line = self.process.stdout.readline()
            if response_line:
                response = json.loads(response_line.strip())
                return response
            else:
                raise Exception("没有收到响应")
        except Exception as e:
            print(f"❌ 请求失败: {e}")
            return None
    
    def list_tools(self):
        """获取可用工具列表"""
        print("\n📋 获取可用工具...")
        response = self.send_request("tools/list")
        if response and "result" in response:
            tools = response["result"]["tools"]
            print(f"✅ 找到 {len(tools)} 个工具:")
            for tool in tools:
                print(f"   - {tool['name']}: {tool.get('description', '无描述')}")
            return tools
        else:
            print("❌ 获取工具列表失败")
            return []
    
    def list_directory(self, path="."):
        """列出目录内容"""
        print(f"\n📁 列出目录: {path}")
        response = self.send_request("tools/call", {
            "name": "LS",
            "arguments": {"path": path}
        })
        if response and "result" in response:
            print("✅ 目录内容:")
            content = response["result"]["content"]
            for item in content:
                print(f"   {item}")
            return content
        else:
            print("❌ 列出目录失败")
            return []
    
    def read_file(self, file_path):
        """读取文件"""
        print(f"\n📄 读取文件: {file_path}")
        response = self.send_request("tools/call", {
            "name": "Read",
            "arguments": {"file_path": file_path}
        })
        if response and "result" in response:
            content = response["result"]["content"][0]["text"]
            print(f"✅ 文件内容 ({len(content)} 字符):")
            # 显示前 200 字符
            preview = content[:200] + "..." if len(content) > 200 else content
            print(f"   {preview}")
            return content
        else:
            print("❌ 读取文件失败")
            return None
    
    def execute_command(self, command):
        """执行命令"""
        print(f"\n💻 执行命令: {command}")
        response = self.send_request("tools/call", {
            "name": "Bash",
            "arguments": {"command": command}
        })
        if response and "result" in response:
            output = response["result"]["content"][0]["text"]
            print(f"✅ 命令输出:")
            print(f"   {output}")
            return output
        else:
            print("❌ 执行命令失败")
            return None
    
    def stop_server(self):
        """停止 MCP Server"""
        if self.process:
            print("\n🛑 停止 MCP Server...")
            self.process.terminate()
            self.process.wait()
            print("✅ MCP Server 已停止")

def main():
    """主函数 - 演示 MCP 客户端使用"""
    print("🎯 Claude Code MCP Client 示例")
    print("=" * 50)
    
    # 检查命令行参数
    claude_path = sys.argv[1] if len(sys.argv) > 1 else "claude"
    
    # 创建客户端
    client = ClaudeCodeMCPClient(claude_path)
    
    try:
        # 启动服务器
        if not client.start_server():
            sys.exit(1)
        
        # 获取工具列表
        tools = client.list_tools()
        
        # 如果有 LS 工具，列出当前目录
        if any(tool["name"] == "LS" for tool in tools):
            client.list_directory(".")
        
        # 如果有 Read 工具，读取一个文件
        if any(tool["name"] == "Read" for tool in tools):
            # 尝试读取 README.md 或 package.json
            for filename in ["README.md", "package.json", "requirements.txt"]:
                client.read_file(filename)
                break
        
        # 如果有 Bash 工具，执行一个简单命令
        if any(tool["name"] == "Bash" for tool in tools):
            client.execute_command("pwd")
            client.execute_command("date")
        
        print("\n🎉 示例演示完成！")
        
    except KeyboardInterrupt:
        print("\n⏹️  用户中断")
    except Exception as e:
        print(f"\n❌ 发生错误: {e}")
    finally:
        client.stop_server()

if __name__ == "__main__":
    main()