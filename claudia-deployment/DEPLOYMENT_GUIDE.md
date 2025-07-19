# Claudia Deployment Guide

## 📋 Overview

Claudia是一个强大的桌面应用程序，为Claude Code提供图形用户界面。本指南将帮助您在系统上成功部署和运行Claudia。

## 🎯 System Requirements

### 最低系统要求

- **操作系统**: 
  - Windows 10/11 (64-bit)
  - macOS 11.0+ (Big Sur或更新版本)
  - Linux Ubuntu 20.04+ / Debian 11+ / CentOS 8+
- **内存**: 最少4GB RAM (推荐8GB)
- **存储空间**: 至少1GB可用空间
- **网络**: 互联网连接 (用于Claude API访问)

### 推荐系统配置

- **内存**: 8GB+ RAM
- **存储**: 2GB+ 可用空间
- **处理器**: 现代多核CPU (2013年后的CPU获得最佳性能)

## 🛠️ Prerequisites (前置要求)

在安装Claudia之前，请确保已安装以下工具：

### 1. Claude Code CLI (必需)

```bash
# 从Claude官方网站下载并安装
# https://claude.ai/code

# 验证安装
claude --version
```

### 2. 构建工具 (从源码构建时需要)

#### Rust (1.70.0+)
```bash
# 使用rustup安装Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source ~/.cargo/env

# 验证安装
rustc --version
cargo --version
```

#### Bun (最新版本)
```bash
# 安装Bun
curl -fsSL https://bun.sh/install | bash

# 验证安装
bun --version
```

#### Git
```bash
# 通常已预装，如果没有：
# Ubuntu/Debian: sudo apt install git
# macOS: brew install git
# Windows: 从 https://git-scm.com 下载

# 验证安装
git --version
```

## 🚀 Installation Methods

### 方法1: 预编译二进制文件 (推荐)

> **注意**: 预编译的可执行文件即将发布。当前需要从源码构建。

```bash
# 下载最新版本 (即将可用)
# https://github.com/getAsterisk/claudia/releases

# 解压并运行
# ./claudia  # Linux/macOS
# claudia.exe  # Windows
```

### 方法2: 从源码构建

#### 第一步: 克隆仓库

```bash
git clone https://github.com/getAsterisk/claudia.git
cd claudia
```

#### 第二步: 安装平台特定依赖

**Linux (Ubuntu/Debian)**
```bash
sudo apt update
sudo apt install -y \
  libwebkit2gtk-4.1-dev \
  libgtk-3-dev \
  libayatana-appindicator3-dev \
  librsvg2-dev \
  patchelf \
  build-essential \
  curl \
  wget \
  file \
  libssl-dev \
  libxdo-dev \
  libsoup-3.0-dev \
  libjavascriptcoregtk-4.1-dev
```

**macOS**
```bash
# 安装Xcode命令行工具
xcode-select --install

# 可选: 通过Homebrew安装额外依赖
brew install pkg-config
```

**Windows**
```bash
# 安装Microsoft C++ Build Tools
# https://visualstudio.microsoft.com/visual-cpp-build-tools/

# 安装WebView2 (Windows 11通常已预装)
# https://developer.microsoft.com/microsoft-edge/webview2/
```

#### 第三步: 安装前端依赖

```bash
bun install
```

#### 第四步: 构建应用程序

**开发构建 (带热重载)**
```bash
bun run tauri dev
```

**生产构建**
```bash
# 构建应用程序
bun run tauri build

# 构建后的可执行文件位于:
# - Linux: src-tauri/target/release/bundle/
# - macOS: src-tauri/target/release/bundle/
# - Windows: src-tauri/target/release/bundle/
```

**特定平台构建选项**
```bash
# 调试构建 (编译更快，文件更大)
bun run tauri build --debug

# 不打包构建 (仅创建可执行文件)
bun run tauri build --no-bundle

# macOS通用二进制 (Intel + Apple Silicon)
bun run tauri build --target universal-apple-darwin
```

## ⚙️ Configuration

### 第一次启动配置

1. **启动Claudia**: 安装后首次打开应用程序
2. **自动检测**: Claudia会自动检测您的`~/.claude`目录
3. **权限设置**: 如需要，授予文件系统访问权限
4. **Claude API**: 确保已配置Claude Code CLI的API密钥

### 高级配置

#### Tauri配置 (开发者选项)

编辑 `src-tauri/tauri.conf.json` 进行高级配置:

```json
{
  "app": {
    "windows": [
      {
        "title": "Claudia",
        "width": 1200,    // 调整窗口大小
        "height": 800,
        "resizable": true,
        "fullscreen": false
      }
    ]
  },
  "plugins": {
    "fs": {
      "scope": ["$HOME/**"],  // 文件系统访问范围
      "allow": [
        "readFile", "writeFile", "readDir",
        "copyFile", "createDir", "removeDir",
        "removeFile", "renameFile", "exists"
      ]
    }
  }
}
```

#### 环境变量

```bash
# 设置Claude API密钥 (如果未通过CLI配置)
export ANTHROPIC_API_KEY="your-api-key-here"

# 设置日志级别
export RUST_LOG=debug  # debug, info, warn, error

# 设置自定义Claude目录
export CLAUDE_HOME="/path/to/custom/claude"
```

## 🏃‍♂️ Running the Application

### 启动应用程序

**从二进制文件启动**
```bash
# Linux/macOS
./claudia

# Windows
claudia.exe
```

**从源码启动 (开发模式)**
```bash
# 在项目目录中
bun run tauri dev
```

### 验证安装

1. **检查Claude Code CLI**: 
   ```bash
   claude --version
   # 应该显示版本信息
   ```

2. **测试文件访问**: 
   - 在Claudia中导航到CC Projects
   - 检查是否能看到`~/.claude/projects/`中的项目

3. **测试API连接**:
   - 尝试创建或打开一个项目
   - 检查是否能与Claude API正常通信

### 应用程序功能

#### CC Projects (项目管理)
- 浏览`~/.claude/projects/`中的所有项目
- 查看和恢复历史会话
- 启动新的编码会话

#### CC Agents (自定义代理)
- 创建专用AI代理
- 配置自定义系统提示
- 在后台执行任务

#### Usage Dashboard (使用分析)
- 监控Claude API使用情况和成本
- 按模型、项目和时间段分析token使用
- 导出使用数据

#### MCP Server Management (MCP服务器管理)
- 管理Model Context Protocol服务器
- 从Claude Desktop导入配置
- 测试服务器连接

## 🔧 Troubleshooting

### 常见问题及解决方案

#### 1. "claude命令未找到" 错误
```bash
# 确保Claude Code CLI已安装并在PATH中
which claude
echo $PATH

# 如果需要，添加到PATH
export PATH=$PATH:/path/to/claude
```

#### 2. "cargo未找到" 错误
```bash
# 确保Rust已安装
source ~/.cargo/env
# 或重启终端

# 验证安装
cargo --version
```

#### 3. Linux: "webkit2gtk未找到" 错误
```bash
# 安装WebKit依赖
sudo apt install libwebkit2gtk-4.1-dev

# 对于较新的Ubuntu版本，可能需要:
sudo apt install libwebkit2gtk-4.0-dev
```

#### 4. Windows: "MSVC未找到" 错误
```bash
# 安装Visual Studio Build Tools (带C++支持)
# 安装后重启终端
```

#### 5. 构建时"内存不足"错误
```bash
# 减少并行作业数量
cargo build -j 2

# 关闭其他应用程序释放内存
```

#### 6. Tauri构建失败
```bash
# 清理构建缓存
cargo clean
rm -rf node_modules dist
bun install

# 重新构建
bun run tauri build
```

#### 7. 权限拒绝错误 (macOS)
```bash
# 在系统偏好设置中授予权限
# 系统偏好设置 > 安全性与隐私 > 隐私 > 文件和文件夹
```

#### 8. 应用程序无法启动
```bash
# 检查依赖
ldd ./claudia  # Linux
otool -L ./claudia  # macOS

# 检查日志
RUST_LOG=debug ./claudia
```

### 性能优化

#### 减少内存使用
```bash
# 限制并发进程数量
export TAURI_MAX_WORKERS=2

# 使用更小的WebView窗口
# 在tauri.conf.json中调整窗口大小
```

#### 提高响应速度
```bash
# 启用硬件加速 (如果可用)
export WEBKIT_DISABLE_GPU_SANDBOX=1

# 增加V8堆大小
export NODE_OPTIONS="--max-old-space-size=4096"
```

### 日志和诊断

#### 启用详细日志
```bash
# 设置日志级别
export RUST_LOG=claudia=debug,tauri=debug

# 启动应用程序
./claudia 2>&1 | tee claudia.log
```

#### 收集系统信息
```bash
# 系统信息
uname -a
lscpu  # Linux
system_profiler SPHardwareDataType  # macOS

# 依赖版本
rustc --version
bun --version
claude --version
```

## 🏗️ Build Instructions for Production

### 优化构建设置

#### 1. 发布模式构建
```bash
# 完整优化构建
bun run tauri build --release

# 启用链接时优化 (LTO)
export CARGO_PROFILE_RELEASE_LTO=true
bun run tauri build
```

#### 2. 跨平台构建
```bash
# 为所有支持的平台构建Claude Code执行文件
bun run build:executables

# 为特定平台构建
bun run build:executables:linux
bun run build:executables:macos
bun run build:executables:windows
```

#### 3. 构建输出

构建过程会创建以下文件:

**可执行文件**: 主要的Claudia应用程序
**安装程序** (使用`tauri build`时):
- `.deb`包 (Linux)
- `.AppImage` (Linux)
- `.dmg`安装程序 (macOS)
- `.msi`安装程序 (Windows)
- `.exe`安装程序 (Windows)

所有构建产物位于`src-tauri/target/release/bundle/`目录中。

### 分发准备

#### 代码签名 (生产环境)

**macOS**
```bash
# 配置代码签名证书
export APPLE_CERTIFICATE_PASSWORD="your-cert-password"
export APPLE_SIGNING_IDENTITY="Developer ID Application: Your Name"

# 签名和公证
bun run tauri build
```

**Windows**
```bash
# 配置代码签名证书
export WINDOWS_CERTIFICATE_THUMBPRINT="your-cert-thumbprint"

# 签名
bun run tauri build
```

#### 创建便携版本
```bash
# 创建无需安装的版本
bun run tauri build --no-bundle

# 压缩为便携包
tar -czf claudia-portable-linux.tar.gz -C src-tauri/target/release claudia
```

## 📊 Performance Monitoring

### 内置性能监控

Claudia包含内置的性能监控功能:

1. **使用分析面板**: 监控Claude API使用情况和成本
2. **会话指标**: 跟踪会话性能和响应时间
3. **内存使用**: 监控应用程序内存使用情况

### 自定义监控
```bash
# 启用性能分析
export RUST_LOG=claudia::performance=debug

# 监控内存使用
export CLAUDIA_MEMORY_TRACKING=true

# 启用网络请求日志
export CLAUDIA_NETWORK_LOG=true
```

## 🔐 Security Considerations

### 安全功能

1. **进程隔离**: 代理在独立进程中运行
2. **权限控制**: 每个代理可配置文件和网络访问权限
3. **本地存储**: 所有数据保存在本地机器上
4. **无遥测**: 无数据收集或跟踪
5. **开源透明**: 完全开源，代码可审查

### 安全配置

```bash
# 限制文件系统访问
export CLAUDIA_FS_SCOPE="$HOME/projects/**"

# 禁用网络访问 (如果不需要)
export CLAUDIA_NETWORK_DISABLED=true

# 启用沙盒模式
export CLAUDIA_SANDBOX_MODE=true
```

## 📚 Additional Resources

### 文档和支持

- **项目主页**: https://claudiacode.com
- **GitHub仓库**: https://github.com/getAsterisk/claudia
- **问题报告**: https://github.com/getAsterisk/claudia/issues
- **功能请求**: https://github.com/getAsterisk/claudia/issues
- **Claude Code文档**: https://claude.ai/code

### 社区和贡献

- **贡献指南**: 查看项目中的CONTRIBUTING.md
- **开发讨论**: GitHub Discussions
- **更新通知**: 关注 [@getAsterisk](https://x.com/getAsterisk)

### 技术栈信息

- **前端**: React 18 + TypeScript + Vite 6
- **后端**: Rust + Tauri 2
- **UI框架**: Tailwind CSS v4 + shadcn/ui
- **数据库**: SQLite (via rusqlite)
- **包管理器**: Bun

---

## 🚨 Important Notes

1. **Claude Code CLI是必需的**: Claudia依赖Claude Code CLI来运行
2. **API密钥**: 确保已配置有效的Anthropic API密钥
3. **系统权限**: 根据需要授予文件系统访问权限
4. **网络连接**: 需要互联网连接来访问Claude API
5. **定期更新**: 保持Claudia和Claude Code CLI为最新版本

## ✅ 安装验证清单

安装完成后，请验证以下项目：

- [ ] Claude Code CLI已安装并可用 (`claude --version`)
- [ ] Claudia应用程序可以启动
- [ ] 可以访问`~/.claude/projects/`目录
- [ ] 可以创建和管理CC Agents
- [ ] 使用分析面板正常显示
- [ ] MCP服务器管理功能正常
- [ ] 可以启动新的Claude Code会话

如果遇到任何问题，请参考故障排除部分或在GitHub上报告问题。

---

*此部署指南涵盖了Claudia的完整安装、配置和故障排除流程。如有疑问或需要帮助，请访问项目的GitHub页面。*