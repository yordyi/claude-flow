#!/usr/bin/env node
/**
 * Claude Code MCP Client 示例 (Node.js)
 * 演示如何连接到 Claude Code MCP Server 并使用其功能
 */

const { spawn } = require('child_process');
const readline = require('readline');

class ClaudeCodeMCPClient {
    constructor(claudePath = 'claude') {
        this.claudePath = claudePath;
        this.process = null;
        this.requestId = 0;
        this.pendingRequests = new Map();
    }

    async startServer() {
        console.log('🚀 启动 Claude Code MCP Server...');
        try {
            this.process = spawn(this.claudePath, ['mcp', 'serve']);
            
            // 设置输出处理
            this.rl = readline.createInterface({
                input: this.process.stdout,
                crlfDelay: Infinity
            });

            // 处理响应
            this.rl.on('line', (line) => {
                try {
                    const response = JSON.parse(line);
                    if (response.id && this.pendingRequests.has(response.id)) {
                        const resolve = this.pendingRequests.get(response.id);
                        this.pendingRequests.delete(response.id);
                        resolve(response);
                    }
                } catch (e) {
                    console.error('解析响应失败:', e);
                }
            });

            // 错误处理
            this.process.stderr.on('data', (data) => {
                console.error('MCP Server 错误:', data.toString());
            });

            // 等待服务器启动
            await new Promise(resolve => setTimeout(resolve, 2000));
            console.log('✅ MCP Server 启动成功');
            return true;
        } catch (e) {
            console.error('❌ 启动失败:', e);
            return false;
        }
    }

    async sendRequest(method, params = {}) {
        if (!this.process) {
            throw new Error('MCP Server 未启动');
        }

        this.requestId++;
        const request = {
            jsonrpc: "2.0",
            id: this.requestId,
            method: method,
            params: params
        };

        console.log(`📤 发送请求: ${method}`);
        
        return new Promise((resolve, reject) => {
            // 存储 promise resolver
            this.pendingRequests.set(this.requestId, resolve);
            
            // 发送请求
            const requestJson = JSON.stringify(request) + '\n';
            this.process.stdin.write(requestJson);
            
            // 设置超时
            setTimeout(() => {
                if (this.pendingRequests.has(this.requestId)) {
                    this.pendingRequests.delete(this.requestId);
                    reject(new Error('请求超时'));
                }
            }, 10000);
        });
    }

    async listTools() {
        console.log('\n📋 获取可用工具...');
        try {
            const response = await this.sendRequest('tools/list');
            if (response.result) {
                const tools = response.result.tools;
                console.log(`✅ 找到 ${tools.length} 个工具:`);
                tools.forEach(tool => {
                    console.log(`   - ${tool.name}: ${tool.description || '无描述'}`);
                });
                return tools;
            }
        } catch (e) {
            console.error('❌ 获取工具列表失败:', e);
        }
        return [];
    }

    async listDirectory(path = '.') {
        console.log(`\n📁 列出目录: ${path}`);
        try {
            const response = await this.sendRequest('tools/call', {
                name: 'LS',
                arguments: { path: path }
            });
            if (response.result) {
                console.log('✅ 目录内容:');
                const content = response.result.content;
                content.forEach(item => {
                    console.log(`   ${item.text || item}`);
                });
                return content;
            }
        } catch (e) {
            console.error('❌ 列出目录失败:', e);
        }
        return [];
    }

    async readFile(filePath) {
        console.log(`\n📄 读取文件: ${filePath}`);
        try {
            const response = await this.sendRequest('tools/call', {
                name: 'Read',
                arguments: { file_path: filePath }
            });
            if (response.result && response.result.content) {
                const content = response.result.content[0].text;
                console.log(`✅ 文件内容 (${content.length} 字符):`);
                // 显示前 200 字符
                const preview = content.length > 200 ? 
                    content.substring(0, 200) + '...' : content;
                console.log(`   ${preview}`);
                return content;
            }
        } catch (e) {
            console.error('❌ 读取文件失败:', e);
        }
        return null;
    }

    async executeCommand(command) {
        console.log(`\n💻 执行命令: ${command}`);
        try {
            const response = await this.sendRequest('tools/call', {
                name: 'Bash',
                arguments: { command: command }
            });
            if (response.result && response.result.content) {
                const output = response.result.content[0].text;
                console.log('✅ 命令输出:');
                console.log(`   ${output}`);
                return output;
            }
        } catch (e) {
            console.error('❌ 执行命令失败:', e);
        }
        return null;
    }

    async searchFiles(pattern, path = '.') {
        console.log(`\n🔍 搜索文件: ${pattern} in ${path}`);
        try {
            const response = await this.sendRequest('tools/call', {
                name: 'Glob',
                arguments: { pattern: pattern, path: path }
            });
            if (response.result && response.result.content) {
                const files = response.result.content;
                console.log(`✅ 找到 ${files.length} 个文件:`);
                files.forEach(file => {
                    console.log(`   ${file.text || file}`);
                });
                return files;
            }
        } catch (e) {
            console.error('❌ 搜索文件失败:', e);
        }
        return [];
    }

    stopServer() {
        if (this.process) {
            console.log('\n🛑 停止 MCP Server...');
            this.process.kill();
            console.log('✅ MCP Server 已停止');
        }
    }
}

async function main() {
    console.log('🎯 Claude Code MCP Client 示例 (Node.js)');
    console.log('='.repeat(50));

    // 检查命令行参数
    const claudePath = process.argv[2] || 'claude';
    
    // 创建客户端
    const client = new ClaudeCodeMCPClient(claudePath);

    try {
        // 启动服务器
        if (!await client.startServer()) {
            process.exit(1);
        }

        // 获取工具列表
        const tools = await client.listTools();
        const toolNames = tools.map(t => t.name);

        // 演示各种功能
        if (toolNames.includes('LS')) {
            await client.listDirectory('.');
        }

        if (toolNames.includes('Glob')) {
            await client.searchFiles('*.json');
        }

        if (toolNames.includes('Read')) {
            // 尝试读取一些常见文件
            const filesToTry = ['package.json', 'README.md', 'requirements.txt', '.gitignore'];
            for (const file of filesToTry) {
                const content = await client.readFile(file);
                if (content) break; // 找到一个就够了
            }
        }

        if (toolNames.includes('Bash')) {
            await client.executeCommand('pwd');
            await client.executeCommand('ls -la | head -5');
            await client.executeCommand('date');
        }

        console.log('\n🎉 示例演示完成！');

    } catch (e) {
        if (e.message === 'SIGINT') {
            console.log('\n⏹️  用户中断');
        } else {
            console.error('\n❌ 发生错误:', e);
        }
    } finally {
        client.stopServer();
    }
}

// 处理 Ctrl+C
process.on('SIGINT', () => {
    console.log('\n⏹️  接收到中断信号...');
    process.exit(0);
});

// 运行主函数
if (require.main === module) {
    main().catch(console.error);
}