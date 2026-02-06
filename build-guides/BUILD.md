# Huobao Drama AI 短剧生成平台 - 构建指南

> 📖 **文档导航**: 本文档提供完整的项目构建、开发和部署指南。建议按顺序阅读，或使用目录快速跳转到所需章节。

## 目录

- [1. 环境准备](#1-环境准备)
  - [1.1 必需软件](#11-必需软件)
  - [1.2 版本要求](#12-版本要求)
  - [1.3 安装说明](#13-安装说明)
    - [Windows 环境](#windows-环境)
    - [macOS 环境](#macos-环境)
    - [Linux 环境](#linux-环境)
  - [1.4 环境验证](#14-环境验证)
  - [1.5 国内网络优化](#15-国内网络优化)

- [2. 快速开始](#2-快速开始)
  - [2.1 后端依赖安装](#21-后端依赖安装)
  - [2.2 前端依赖安装](#22-前端依赖安装)
  - [2.3 常见依赖安装错误](#23-常见依赖安装错误)

- [3. 配置详解](#3-配置详解)
  - [3.1 配置文件模板](#31-配置文件模板)
  - [3.2 数据库配置](#32-数据库配置)
  - [3.3 存储配置](#33-存储配置)
  - [3.4 AI 服务配置](#34-ai-服务配置)
  - [3.5 FFmpeg 配置](#35-ffmpeg-配置)
  - [3.6 服务器配置](#36-服务器配置)
  - [3.7 敏感信息管理](#37-敏感信息管理)

- [4. 开发指南](#4-开发指南)
  - [4.1 后端开发模式](#41-后端开发模式)
  - [4.2 前端开发模式](#42-前端开发模式)
  - [4.3 并行启动](#43-并行启动)
  - [4.4 热重载配置](#44-热重载配置)
  - [4.5 调试技巧](#45-调试技巧)

- [5. 数据库初始化](#5-数据库初始化)
  - [5.1 自动初始化](#51-自动初始化)
  - [5.2 手动迁移](#52-手动迁移)
  - [5.3 权限设置](#53-权限设置)
  - [5.4 Docker 环境配置](#54-docker-环境配置)
  - [5.5 数据库管理](#55-数据库管理)

- [6. 生产构建](#6-生产构建)
  - [6.1 后端构建](#61-后端构建)
  - [6.2 前端构建](#62-前端构建)
  - [6.3 构建优化](#63-构建优化)
  - [6.4 跨平台编译](#64-跨平台编译)
  - [6.5 构建验证](#65-构建验证)
  - [6.6 部署包打包](#66-部署包打包)

- [7. Docker 部署](#7-docker-部署)
  - [7.1 Dockerfile 说明](#71-dockerfile-说明)
  - [7.2 多阶段构建](#72-多阶段构建)
  - [7.3 docker-compose 配置](#73-docker-compose-配置)
  - [7.4 数据持久化](#74-数据持久化)
  - [7.5 网络配置](#75-网络配置)
  - [7.6 容器管理](#76-容器管理)
  - [7.7 镜像加速](#77-镜像加速)

- [8. 传统服务器部署](#8-传统服务器部署)
  - [8.1 Linux 服务器部署](#81-linux-服务器部署)
  - [8.2 systemd 服务配置](#82-systemd-服务配置)
  - [8.3 Nginx 反向代理](#83-nginx-反向代理)
  - [8.4 SSL/TLS 配置](#84-ssltls-配置)
  - [8.5 日志管理](#85-日志管理)
  - [8.6 Windows 服务器部署](#86-windows-服务器部署)

- [9. 问题排查](#9-问题排查)
  - [9.1 构建错误](#91-构建错误)
  - [9.2 运行时错误](#92-运行时错误)
  - [9.3 FFmpeg 问题](#93-ffmpeg-问题)
  - [9.4 数据库问题](#94-数据库问题)
  - [9.5 网络问题](#95-网络问题)
  - [9.6 日志分析](#96-日志分析)
  - [9.7 性能优化](#97-性能优化)

---

## 1. 环境准备

在开始构建和运行 Huobao Drama AI 短剧生成平台之前，您需要准备好开发环境。本章节将指导您安装所有必需的软件依赖，并验证环境配置是否正确。

### 1.1 必需软件

Huobao Drama 平台需要以下软件环境：

| 软件 | 最低版本 | 推荐版本 | 用途 |
|------|---------|---------|------|
| **Go** | 1.23.0 | 1.23+ | 后端服务开发和运行 |
| **Node.js** | 18.0.0 | 20.x LTS | 前端应用开发和构建 |
| **FFmpeg** | 4.4.0 | 6.0+ | 视频处理和合成 |
| **Git** | 2.30+ | 最新版 | 代码版本管理 |

ℹ️ **提示**: 推荐使用最新的稳定版本以获得更好的性能和安全性。

### 1.2 版本要求

> ⚡ **重要提示**: 请确保安装的软件版本满足以下最低要求，否则可能导致编译或运行时错误。

#### Go 1.23+

- **必需原因**: 项目使用了 Go 1.23 的新特性和标准库改进
- **CGO 支持**: 必须启用 CGO（`CGO_ENABLED=1`），因为 SQLite 驱动需要 C 编译器
- **编译器要求**: Windows 用户需要安装 MinGW 或 TDM-GCC

#### Node.js 18+

- **必需原因**: 前端使用 Vue 3 和 Vite，需要 Node.js 18 或更高版本
- **包管理器**: 支持 npm（内置）或 pnpm（推荐，更快更节省空间）
- **兼容性**: 推荐使用 Node.js 20 LTS 版本以获得最佳稳定性

#### FFmpeg 4.4+

- **必需原因**: 用于视频编码、转码、音频提取和视频合成
- **编解码器**: 需要支持 H.264、AAC 等常用编解码器
- **性能**: 推荐使用 FFmpeg 6.0+ 以获得更好的性能和新特性

### 1.3 安装说明

#### Windows 环境

##### 方法一：使用 Chocolatey（推荐）

Chocolatey 是 Windows 的包管理器，可以简化软件安装过程。

1. **安装 Chocolatey**（如果尚未安装）

   以管理员身份打开 PowerShell，执行：

   ```powershell
   Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
   ```

2. **安装 Go**

   ```powershell
   choco install golang --version=1.23.0 -y
   ```

3. **安装 Node.js**

   ```powershell
   choco install nodejs-lts -y
   ```

4. **安装 FFmpeg**

   ```powershell
   choco install ffmpeg -y
   ```

5. **安装 Git**

   ```powershell
   choco install git -y
   ```

6. **安装 MinGW（CGO 编译器）**

   ```powershell
   choco install mingw -y
   ```

7. **重启终端**以使环境变量生效

##### 方法二：手动安装

1. **安装 Go**
   - 访问 [Go 官方下载页面](https://go.dev/dl/)
   - 下载 Windows 安装包（如 `go1.23.0.windows-amd64.msi`）
   - 运行安装程序，按照向导完成安装
   - 默认安装路径：`C:\Program Files\Go`

2. **安装 Node.js**
   - 访问 [Node.js 官方网站](https://nodejs.org/)
   - 下载 LTS 版本的 Windows 安装包
   - 运行安装程序，确保勾选"Add to PATH"选项
   - 默认安装路径：`C:\Program Files\nodejs`

3. **安装 FFmpeg**
   - 访问 [FFmpeg 官方网站](https://ffmpeg.org/download.html)
   - 下载 Windows 构建版本（推荐使用 [gyan.dev](https://www.gyan.dev/ffmpeg/builds/) 的完整版本）
   - 解压到目录（如 `C:\ffmpeg`）
   - 将 `C:\ffmpeg\bin` 添加到系统环境变量 PATH 中

4. **安装 MinGW（CGO 编译器）**
   - 访问 [TDM-GCC 官网](https://jmeubank.github.io/tdm-gcc/)
   - 下载并安装 TDM-GCC（推荐 64 位版本）
   - 或者下载 [MinGW-w64](https://www.mingw-w64.org/)

⚠️ **Windows 用户注意**: 
- 安装完成后需要重启终端或重新登录以使环境变量生效
- 确保 `gcc` 命令可用，这是 CGO 编译所必需的

---

#### macOS 环境

macOS 用户推荐使用 Homebrew 包管理器进行安装。

1. **安装 Homebrew**（如果尚未安装）

   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. **安装 Go**

   ```bash
   brew install go@1.23
   ```

3. **安装 Node.js**

   ```bash
   brew install node@20
   ```

4. **安装 FFmpeg**

   ```bash
   brew install ffmpeg
   ```

5. **安装 Git**（通常已预装，如未安装）

   ```bash
   brew install git
   ```

6. **验证安装**

   ```bash
   go version
   node --version
   npm --version
   ffmpeg -version
   ```

💡 **macOS 提示**:
- Homebrew 会自动处理依赖关系和环境变量配置
- 如果使用 Apple Silicon（M1/M2/M3），所有软件都会安装 ARM64 原生版本
- CGO 编译器（Clang）已随 Xcode Command Line Tools 预装

---

#### Linux 环境

##### Ubuntu/Debian 系统

1. **更新包索引**

   ```bash
   sudo apt update
   ```

2. **安装 Go**

   ```bash
   # 方法一：使用 apt（可能不是最新版本）
   sudo apt install golang-go -y
   
   # 方法二：手动安装最新版本（推荐）
   wget https://go.dev/dl/go1.23.0.linux-amd64.tar.gz
   sudo rm -rf /usr/local/go
   sudo tar -C /usr/local -xzf go1.23.0.linux-amd64.tar.gz
   echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
   source ~/.bashrc
   ```

3. **安装 Node.js**

   ```bash
   # 使用 NodeSource 仓库安装最新 LTS 版本
   curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
   sudo apt install -y nodejs
   ```

4. **安装 FFmpeg**

   ```bash
   sudo apt install ffmpeg -y
   ```

5. **安装构建工具（CGO 编译器）**

   ```bash
   sudo apt install build-essential -y
   ```

##### CentOS/RHEL/Fedora 系统

1. **安装 Go**

   ```bash
   # 手动安装最新版本
   wget https://go.dev/dl/go1.23.0.linux-amd64.tar.gz
   sudo rm -rf /usr/local/go
   sudo tar -C /usr/local -xzf go1.23.0.linux-amd64.tar.gz
   echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
   source ~/.bashrc
   ```

2. **安装 Node.js**

   ```bash
   # 使用 NodeSource 仓库
   curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
   sudo yum install -y nodejs
   ```

3. **安装 FFmpeg**

   ```bash
   # 启用 RPM Fusion 仓库
   sudo yum install -y epel-release
   sudo yum install -y https://download1.rpmfusion.org/free/el/rpmfusion-free-release-$(rpm -E %rhel).noarch.rpm
   
   # 安装 FFmpeg
   sudo yum install -y ffmpeg
   ```

4. **安装开发工具**

   ```bash
   sudo yum groupinstall "Development Tools" -y
   ```

##### Arch Linux 系统

```bash
# 安装所有必需软件
sudo pacman -S go nodejs npm ffmpeg base-devel git
```

⚡ **Linux 提示**:
- 大多数 Linux 发行版已预装 GCC，CGO 可以直接使用
- 如果使用包管理器安装的 Go 版本过旧，建议手动安装最新版本
- FFmpeg 在某些发行版的官方仓库中可能不可用，需要启用第三方仓库

---

### 1.4 环境验证

安装完成后，请验证所有软件是否正确安装并可用。

#### 验证 Go 安装

```bash
# 检查 Go 版本
go version
```

**预期输出**（版本号可能不同）：
```text
go version go1.23.0 windows/amd64
```

或

```text
go version go1.23.0 darwin/arm64
```

或

```text
go version go1.23.0 linux/amd64
```

#### 验证 Node.js 和 npm 安装

```bash
# 检查 Node.js 版本
node --version

# 检查 npm 版本
npm --version
```

**预期输出**：
```text
v20.11.0
10.2.4
```

ℹ️ **提示**: Node.js 版本应为 18.x 或更高，npm 版本通常随 Node.js 一起安装。

#### 验证 FFmpeg 安装

```bash
# 检查 FFmpeg 版本和配置信息
ffmpeg -version
```

**预期输出**（前几行）：
```text
ffmpeg version 6.0 Copyright (c) 2000-2023 the FFmpeg developers
built with gcc 12.2.0 (Rev10, Built by MSYS2 project)
configuration: --enable-gpl --enable-version3 ...
```

⚠️ **重要**: 确保输出显示版本号为 4.4 或更高。

#### 验证 CGO 编译器（仅限 Go 项目）

```bash
# Windows - 检查 GCC 版本
gcc --version

# macOS/Linux - 检查 GCC 或 Clang 版本
gcc --version
# 或
clang --version
```

**预期输出**（Windows MinGW）：
```text
gcc (tdm64-1) 10.3.0
```

**预期输出**（macOS Clang）：
```text
Apple clang version 14.0.0
```

**预期输出**（Linux GCC）：
```text
gcc (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0
```

#### 验证 Git 安装

```bash
# 检查 Git 版本
git --version
```

**预期输出**：
```text
git version 2.40.0
```

#### 完整验证脚本

您可以使用以下脚本一次性验证所有环境：

**Windows (PowerShell)**:
```powershell
Write-Host "=== 环境验证 ===" -ForegroundColor Green
Write-Host "`n检查 Go..." -ForegroundColor Yellow
go version
Write-Host "`n检查 Node.js..." -ForegroundColor Yellow
node --version
Write-Host "`n检查 npm..." -ForegroundColor Yellow
npm --version
Write-Host "`n检查 FFmpeg..." -ForegroundColor Yellow
ffmpeg -version 2>&1 | Select-Object -First 1
Write-Host "`n检查 GCC..." -ForegroundColor Yellow
gcc --version 2>&1 | Select-Object -First 1
Write-Host "`n检查 Git..." -ForegroundColor Yellow
git --version
Write-Host "`n=== 验证完成 ===" -ForegroundColor Green
```

**macOS/Linux (Bash)**:
```bash
#!/bin/bash
echo "=== 环境验证 ==="
echo ""
echo "检查 Go..."
go version
echo ""
echo "检查 Node.js..."
node --version
echo ""
echo "检查 npm..."
npm --version
echo ""
echo "检查 FFmpeg..."
ffmpeg -version | head -n 1
echo ""
echo "检查 GCC/Clang..."
gcc --version 2>/dev/null | head -n 1 || clang --version | head -n 1
echo ""
echo "检查 Git..."
git --version
echo ""
echo "=== 验证完成 ==="
```

✅ **验证成功标准**:
- 所有命令都能正常执行，没有"command not found"错误
- Go 版本 ≥ 1.23.0
- Node.js 版本 ≥ 18.0.0
- FFmpeg 版本 ≥ 4.4.0
- GCC 或 Clang 可用（用于 CGO 编译）

> ⚠️ **重要**: 如果任何验证失败，请返回相应的安装步骤重新安装。

---

### 1.5 国内网络优化

> 💡 **优化建议**: 由于网络环境的特殊性，国内开发者在下载依赖和 Docker 镜像时可能会遇到速度慢或连接失败的问题。以下配置可以显著提升下载速度。

---

#### Go 模块代理配置

> ℹ️ **说明**: Go 模块代理可以加速 Go 依赖包的下载，特别是在国内网络环境下。

---

##### 临时设置（当前终端会话）

**Windows (PowerShell)**:
```powershell
$env:GOPROXY = "https://goproxy.cn,direct"
```

**macOS/Linux (Bash)**:
```bash
export GOPROXY=https://goproxy.cn,direct
```

##### 永久设置（推荐）

**Windows (PowerShell)**:
```powershell
# 设置用户环境变量
[System.Environment]::SetEnvironmentVariable("GOPROXY", "https://goproxy.cn,direct", "User")

# 或者使用 go env 命令
go env -w GOPROXY=https://goproxy.cn,direct
```

**macOS/Linux (Bash)**:
```bash
# 添加到 shell 配置文件
echo 'export GOPROXY=https://goproxy.cn,direct' >> ~/.bashrc
source ~/.bashrc

# 或者使用 go env 命令（推荐）
go env -w GOPROXY=https://goproxy.cn,direct
```

##### 验证 Go 代理配置

```bash
# 查看当前 Go 代理配置
go env GOPROXY
```

**预期输出**:
```text
https://goproxy.cn,direct
```

##### 其他可用的 Go 代理

- **七牛云**: `https://goproxy.cn,direct`（推荐）
- **阿里云**: `https://mirrors.aliyun.com/goproxy/,direct`
- **官方代理**: `https://goproxy.io,direct`

💡 **提示**: `direct` 表示如果代理不可用，则直接从源站下载。

#### npm 镜像配置

> ℹ️ **说明**: npm 是 Node.js 的包管理器，配置镜像可以加速前端依赖下载。

---

##### 方法一：使用淘宝镜像（推荐）

**临时使用**:
```bash
npm install --registry=https://registry.npmmirror.com
```

**永久配置**:
```bash
# 设置 npm 镜像为淘宝源
npm config set registry https://registry.npmmirror.com
```

**验证配置**:
```bash
# 查看当前 npm 镜像配置
npm config get registry
```

**预期输出**:
```text
https://registry.npmmirror.com/
```

##### 方法二：使用 nrm 管理镜像源

nrm 是一个 npm 镜像源管理工具，可以快速切换镜像源。

1. **安装 nrm**:
   ```bash
   npm install -g nrm
   ```

2. **查看可用镜像源**:
   ```bash
   nrm ls
   ```

   输出示例：
   ```
   * npm ---------- https://registry.npmjs.org/
     yarn --------- https://registry.yarnpkg.com/
     tencent ------ https://mirrors.cloud.tencent.com/npm/
     cnpm --------- https://r.cnpmjs.org/
     taobao ------- https://registry.npmmirror.com/
     npmMirror ---- https://skimdb.npmjs.com/registry/
   ```

3. **切换到淘宝镜像**:
   ```bash
   nrm use taobao
   ```

4. **测试镜像速度**:
   ```bash
   nrm test taobao
   ```

##### 恢复官方镜像源

如果需要恢复到官方镜像源：

```bash
npm config set registry https://registry.npmjs.org/
```

或使用 nrm：

```bash
nrm use npm
```

#### pnpm 镜像配置

> ℹ️ **说明**: pnpm 是一个更快、更节省磁盘空间的包管理器，推荐使用。

---

##### 安装 pnpm

```bash
npm install -g pnpm
```

##### 配置 pnpm 镜像

```bash
# 设置 pnpm 镜像为淘宝源
pnpm config set registry https://registry.npmmirror.com
```

##### 验证 pnpm 配置

```bash
# 查看当前 pnpm 镜像配置
pnpm config get registry
```

**预期输出**:
```text
https://registry.npmmirror.com/
```

##### pnpm 的优势

- **速度更快**: 使用硬链接和符号链接，安装速度比 npm 快 2-3 倍
- **节省空间**: 所有包只存储一次，多个项目共享
- **严格性**: 更严格的依赖管理，避免幽灵依赖

💡 **提示**: 本项目支持使用 npm 或 pnpm，推荐使用 pnpm 以获得更好的性能。

#### Docker 镜像加速配置

> ℹ️ **说明**: Docker 镜像加速可以显著提升 Docker 镜像的拉取速度。

---

##### Linux 系统配置

1. **创建或编辑 Docker 配置文件**:
   ```bash
   sudo mkdir -p /etc/docker
   sudo nano /etc/docker/daemon.json
   ```

2. **添加镜像加速配置**:
   ```json
   {
     "registry-mirrors": [
       "https://docker.mirrors.ustc.edu.cn",
       "https://hub-mirror.c.163.com",
       "https://mirror.baidubce.com"
     ]
   }
   ```

3. **重启 Docker 服务**:
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl restart docker
   ```

##### macOS 系统配置

1. 打开 Docker Desktop
2. 点击右上角的设置图标（齿轮）
3. 选择 "Docker Engine"
4. 在 JSON 配置中添加：
   ```json
   {
     "registry-mirrors": [
       "https://docker.mirrors.ustc.edu.cn",
       "https://hub-mirror.c.163.com",
       "https://mirror.baidubce.com"
     ]
   }
   ```
5. 点击 "Apply & Restart"

##### Windows 系统配置

1. 打开 Docker Desktop
2. 点击右上角的设置图标（齿轮）
3. 选择 "Docker Engine"
4. 在 JSON 配置中添加：
   ```json
   {
     "registry-mirrors": [
       "https://docker.mirrors.ustc.edu.cn",
       "https://hub-mirror.c.163.com",
       "https://mirror.baidubce.com"
     ]
   }
   ```
5. 点击 "Apply & Restart"

##### 验证 Docker 镜像加速配置

```bash
# 查看 Docker 镜像加速配置
docker info | grep -A 5 "Registry Mirrors"
```

**预期输出**:
```text
Registry Mirrors:
  https://docker.mirrors.ustc.edu.cn/
  https://hub-mirror.c.163.com/
  https://mirror.baidubce.com/
```

##### 可用的 Docker 镜像加速服务

| 服务商 | 镜像地址 | 说明 |
|--------|---------|------|
| **中国科技大学** | `https://docker.mirrors.ustc.edu.cn` | 稳定可靠 |
| **网易云** | `https://hub-mirror.c.163.com` | 速度快 |
| **百度云** | `https://mirror.baidubce.com` | 国内访问快 |
| **阿里云** | `https://<your-id>.mirror.aliyuncs.com` | 需要注册获取专属地址 |
| **腾讯云** | `https://mirror.ccs.tencentyun.com` | 腾讯云用户推荐 |

⚠️ **注意**: 
- 阿里云镜像需要登录[阿里云容器镜像服务](https://cr.console.aliyun.com/)获取专属加速地址
- 配置多个镜像源可以提高可用性，Docker 会自动尝试下一个源

---

##### 测试 Docker 镜像加速

拉取一个测试镜像验证加速效果：

```bash
# 拉取 Alpine Linux 测试镜像
docker pull alpine:latest
```

**预期行为**: 如果配置成功，下载速度应该明显提升（通常可达到 MB/s 级别）。

#### 验证所有镜像配置

您可以使用以下命令验证所有镜像配置是否生效：

**验证脚本 (Bash)**:
```bash
#!/bin/bash
echo "=== 镜像配置验证 ==="
echo ""
echo "1. Go 代理配置:"
go env GOPROXY
echo ""
echo "2. npm 镜像配置:"
npm config get registry
echo ""
echo "3. pnpm 镜像配置 (如果已安装):"
pnpm config get registry 2>/dev/null || echo "pnpm 未安装"
echo ""
echo "4. Docker 镜像加速:"
docker info 2>/dev/null | grep -A 3 "Registry Mirrors" || echo "Docker 未运行或未配置"
echo ""
echo "=== 验证完成 ==="
```

**验证脚本 (PowerShell)**:
```powershell
Write-Host "=== 镜像配置验证 ===" -ForegroundColor Green
Write-Host ""
Write-Host "1. Go 代理配置:" -ForegroundColor Yellow
go env GOPROXY
Write-Host ""
Write-Host "2. npm 镜像配置:" -ForegroundColor Yellow
npm config get registry
Write-Host ""
Write-Host "3. pnpm 镜像配置 (如果已安装):" -ForegroundColor Yellow
try { pnpm config get registry } catch { Write-Host "pnpm 未安装" }
Write-Host ""
Write-Host "4. Docker 镜像加速:" -ForegroundColor Yellow
docker info 2>$null | Select-String -Pattern "Registry Mirrors" -Context 0,3
Write-Host ""
Write-Host "=== 验证完成 ===" -ForegroundColor Green
```

#### 常见问题

> ❓ **常见疑问解答**

**Q: 配置镜像后仍然很慢怎么办？**

A: 尝试以下方法：
1. 切换到其他镜像源
2. 检查网络连接是否稳定
3. 使用 VPN 或代理（如果可用）
4. 清除缓存后重试：
   ```bash
   # Go 模块缓存
   go clean -modcache
   
   # npm 缓存
   npm cache clean --force
   
   # pnpm 缓存
   pnpm store prune
   ```

**Q: 如何临时禁用镜像配置？**

A: 
- **Go**: `GOPROXY=direct go mod download`
- **npm**: `npm install --registry=https://registry.npmjs.org/`
- **Docker**: 临时删除 `/etc/docker/daemon.json` 中的配置并重启 Docker

**Q: 镜像源不可用怎么办？**

A: 镜像源可能会临时维护或失效，建议：
1. 配置多个镜像源作为备选
2. 定期检查镜像源的可用性
3. 关注镜像源的官方公告

---

✅ **配置完成**: 完成以上配置后，您的开发环境已经优化完毕，可以开始下载依赖和构建项目了。

[返回目录](#目录)

---

## 2. 快速开始

> 📦 **本章内容**: 本章节将指导您快速安装项目依赖并启动开发环境。在开始之前，请确保您已经完成了[环境准备](#1-环境准备)章节中的所有步骤。

---

### 2.1 后端依赖安装

> 🔧 **技术栈**: 后端使用 Go 语言开发，依赖管理通过 Go Modules 实现。以下步骤将帮助您下载和安装所有后端依赖。

---

#### 进入后端目录

首先，克隆项目仓库（如果尚未克隆）并进入后端目录：

```bash
# 克隆项目仓库
git clone https://github.com/your-repo/huobao-drama.git

# 进入项目根目录（后端代码在根目录）
cd huobao-drama
```

ℹ️ **提示**: Huobao Drama 项目的后端代码位于项目根目录，前端代码位于 `web/` 子目录。

#### 下载 Go 依赖

使用 `go mod download` 命令下载所有依赖包：

```bash
# 下载 go.mod 中声明的所有依赖
go mod download
```

**命令说明**:
- `go mod download`: 下载 `go.mod` 文件中声明的所有依赖包
- 依赖包会被下载到 Go 的模块缓存目录（通常是 `$GOPATH/pkg/mod`）
- 此命令不会修改 `go.mod` 或 `go.sum` 文件

**预期输出**:

如果配置了 Go 代理（如 goproxy.cn），您会看到类似以下的输出：

```text
go: downloading github.com/gin-gonic/gin v1.9.1
go: downloading gorm.io/gorm v1.30.0
go: downloading gorm.io/driver/sqlite v1.6.0
go: downloading github.com/spf13/viper v1.17.0
go: downloading go.uber.org/zap v1.26.0
...
```

下载过程可能需要几分钟，具体时间取决于网络速度。

⚡ **加速提示**: 如果下载速度很慢，请确保已配置 Go 代理，参见[国内网络优化](#15-国内网络优化)章节。

#### 验证依赖完整性

下载完成后，使用 `go mod verify` 命令验证依赖的完整性：

```bash
# 验证所有依赖的校验和
go mod verify
```

**命令说明**:
- `go mod verify`: 验证依赖包的校验和是否与 `go.sum` 文件中记录的一致
- 这可以确保依赖包没有被篡改或损坏

**预期输出**:

如果所有依赖都正确下载且完整，您会看到：

```text
all modules verified
```

如果验证失败，您会看到类似以下的错误信息：

```text
github.com/some/package v1.0.0: checksum mismatch
```

⚠️ **验证失败处理**: 如果验证失败，请尝试以下步骤：
1. 清除模块缓存：`go clean -modcache`
2. 重新下载依赖：`go mod download`
3. 再次验证：`go mod verify`

#### 检查依赖安装状态

您可以使用以下命令检查依赖安装是否成功：

##### 方法一：查看依赖列表

```bash
go list -m all
```

**预期输出**（部分）:
```
github.com/drama-generator/backend
github.com/gin-gonic/gin v1.9.1
gorm.io/gorm v1.30.0
gorm.io/driver/sqlite v1.6.0
github.com/spf13/viper v1.17.0
go.uber.org/zap v1.26.0
...
```

此命令会列出当前模块及其所有依赖（包括间接依赖）。

##### 方法二：尝试编译项目

```bash
go build -v ./...
```

**命令说明**:
- `go build`: 编译 Go 代码
- `-v`: 显示详细的编译过程
- `./...`: 编译当前目录及所有子目录中的包

**预期输出**:

如果依赖安装正确，编译过程会顺利进行，您会看到各个包的编译信息：

```
github.com/drama-generator/backend/pkg/config
github.com/drama-generator/backend/pkg/logger
github.com/drama-generator/backend/domain/models
github.com/drama-generator/backend/infrastructure/database
...
```

编译成功后，不会有错误信息输出。

##### 方法三：检查 go.sum 文件

```bash
# Windows (PowerShell)
Get-Content go.sum | Measure-Object -Line

# macOS/Linux
wc -l go.sum
```

**预期输出**:

`go.sum` 文件应该包含数百行校验和记录（通常 200-500 行），表示依赖已正确下载。

#### 依赖安装成功标志

✅ **安装成功的标志**:
- `go mod download` 命令执行完成，没有错误
- `go mod verify` 输出 "all modules verified"
- `go list -m all` 能够列出所有依赖
- `go build ./...` 编译成功，没有"package not found"错误
- `go.sum` 文件存在且包含大量校验和记录

#### 常见后端依赖问题

如果在安装过程中遇到问题，请参考[常见依赖安装错误](#23-常见依赖安装错误)章节。

💡 **下一步**: 完成后端依赖安装后，继续进行[前端依赖安装](#22-前端依赖安装)。

### 2.2 前端依赖安装

> 🎨 **技术栈**: 前端使用 Vue 3 + TypeScript 开发，依赖管理支持 npm 或 pnpm。本节将指导您使用这两种包管理器安装前端依赖。

---

#### 进入前端目录

从项目根目录进入前端目录：

```bash
cd web
```

ℹ️ **提示**: 前端代码位于 `web/` 子目录，包含 Vue 3 应用的所有源代码和配置文件。

#### 选择包管理器

Huobao Drama 前端支持两种包管理器：

| 包管理器 | 优势 | 适用场景 |
|---------|------|---------|
| **npm** | Node.js 内置，无需额外安装 | 首次使用、简单项目、团队标准 |
| **pnpm** | 速度快 2-3 倍，节省磁盘空间 | 大型项目、多项目开发、追求性能 |

💡 **推荐**: 如果您追求更快的安装速度和更少的磁盘占用，推荐使用 pnpm。

#### 方法一：使用 npm 安装（推荐新手）

npm 是 Node.js 的默认包管理器，随 Node.js 一起安装，无需额外配置。

##### 安装依赖

```bash
npm install
```

**命令说明**:
- `npm install`: 读取 `package.json` 文件并安装所有依赖
- 依赖会被安装到 `node_modules/` 目录
- 会生成或更新 `package-lock.json` 文件以锁定依赖版本

**预期输出**:

```
npm WARN deprecated @humanwhocodes/config-array@0.11.14: Use @eslint/config-array instead
npm WARN deprecated @humanwhocodes/object-schema@2.0.2: Use @eslint/object-schema instead

added 523 packages, and audited 524 packages in 2m

89 packages are looking for funding
  run `npm fund` for details

found 0 vulnerabilities
```

安装过程可能需要 2-5 分钟，具体时间取决于网络速度和机器性能。

⚡ **加速提示**: 如果安装速度很慢，请确保已配置 npm 镜像，参见[国内网络优化](#15-国内网络优化)章节。

##### 验证 npm 安装

安装完成后，检查 `node_modules/` 目录是否存在：

**Windows (PowerShell)**:
```powershell
Test-Path node_modules
```

**macOS/Linux**:
```bash
ls -ld node_modules
```

**预期输出**:
- Windows: `True`
- macOS/Linux: `drwxr-xr-x ... node_modules`

您还可以检查已安装的包数量：

```bash
# 查看直接依赖
npm list --depth=0

# 查看所有依赖（包括间接依赖）
npm list
```

**预期输出**（部分）:
```
drama-generator-frontend@1.0.0 /path/to/huobao-drama/web
├── @element-plus/icons-vue@2.3.0
├── @ffmpeg/ffmpeg@0.12.15
├── axios@1.6.0
├── element-plus@2.5.0
├── pinia@2.1.0
├── vue@3.4.0
├── vue-router@4.2.0
└── ...
```

#### 方法二：使用 pnpm 安装（推荐进阶用户）

pnpm 是一个更快、更高效的包管理器，特别适合大型项目和多项目开发。

##### 安装 pnpm（如果尚未安装）

如果您还没有安装 pnpm，首先需要全局安装它：

```bash
npm install -g pnpm
```

验证 pnpm 安装：

```bash
pnpm --version
```

**预期输出**:
```
8.15.0
```

ℹ️ **提示**: pnpm 版本应为 8.x 或更高。

##### 配置 pnpm 镜像（可选但推荐）

如果在国内网络环境，建议配置 pnpm 镜像：

```bash
pnpm config set registry https://registry.npmmirror.com
```

##### 安装依赖

```bash
pnpm install
```

**命令说明**:
- `pnpm install`: 读取 `package.json` 文件并安装所有依赖
- 依赖会被安装到全局存储，并通过硬链接或符号链接到 `node_modules/`
- 会生成或更新 `pnpm-lock.yaml` 文件以锁定依赖版本

**预期输出**:

```
Packages: +523
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Progress: resolved 523, reused 523, downloaded 0, added 523, done

dependencies:
+ @element-plus/icons-vue 2.3.0
+ @ffmpeg/ffmpeg 0.12.15
+ axios 1.6.0
+ element-plus 2.5.0
+ pinia 2.1.0
+ vue 3.4.0
+ vue-router 4.2.0

devDependencies:
+ @vitejs/plugin-vue 5.0.0
+ typescript 5.3.0
+ vite 5.0.0
+ ...

Done in 45s
```

⚡ **性能对比**: pnpm 通常比 npm 快 2-3 倍，特别是在重复安装时。

##### 验证 pnpm 安装

检查 `node_modules/` 目录是否存在：

```bash
ls -ld node_modules
```

查看已安装的包：

```bash
pnpm list --depth=0
```

**预期输出**（部分）:
```
drama-generator-frontend@1.0.0 /path/to/huobao-drama/web

dependencies:
@element-plus/icons-vue 2.3.0
@ffmpeg/ffmpeg 0.12.15
axios 1.6.0
element-plus 2.5.0
pinia 2.1.0
vue 3.4.0
vue-router 4.2.0
...
```

#### npm vs pnpm 对比

> 📊 **选择指南**: 以下表格对比了 npm 和 pnpm 的主要特性，帮助您选择合适的包管理器。

| 特性 | npm | pnpm |
|------|-----|------|
| **安装速度** | 标准 | 快 2-3 倍 ⚡ |
| **磁盘占用** | 每个项目独立存储 | 全局存储，硬链接共享 💾 |
| **依赖管理** | 扁平化 node_modules | 严格的依赖树 🌳 |
| **幽灵依赖** | 可能存在 ⚠️ | 不存在 ✅ |
| **学习曲线** | 低（内置） 📚 | 中（需要学习） |
| **兼容性** | 最广泛 🌍 | 良好 |

💡 **选择建议**:
- **首次使用或团队标准**: 使用 npm
- **追求性能和磁盘空间**: 使用 pnpm
- **多项目开发**: 强烈推荐 pnpm

---

#### 依赖安装验证方法

无论使用哪种包管理器，都可以通过以下方法验证依赖安装是否成功：

##### 方法一：检查 node_modules 目录

```bash
# Windows (PowerShell)
(Get-ChildItem node_modules).Count

# macOS/Linux
ls node_modules | wc -l
```

**预期输出**: 应该有数百个目录（通常 400-600 个），表示依赖已安装。

##### 方法二：检查关键依赖

验证核心依赖是否存在：

```bash
# Windows (PowerShell)
Test-Path node_modules/vue
Test-Path node_modules/element-plus
Test-Path node_modules/vite

# macOS/Linux
ls node_modules/vue
ls node_modules/element-plus
ls node_modules/vite
```

所有命令都应该返回成功（Windows 返回 `True`，Linux/macOS 显示目录内容）。

##### 方法三：尝试运行开发服务器

最可靠的验证方法是尝试启动开发服务器：

**使用 npm**:
```bash
npm run dev
```

**使用 pnpm**:
```bash
pnpm dev
```

**预期输出**:

```
  VITE v5.0.0  ready in 1234 ms

  ➜  Local:   http://localhost:5173/
  ➜  Network: use --host to expose
  ➜  press h + enter to show help
```

如果看到此输出，说明依赖安装成功！按 `Ctrl+C` 停止开发服务器。

ℹ️ **提示**: 关于如何启动和使用开发服务器的详细说明，请参见[开发指南](#4-开发指南)章节。

#### 依赖安装成功标志

✅ **安装成功的标志**:
- `npm install` 或 `pnpm install` 命令执行完成，没有错误
- `node_modules/` 目录存在且包含数百个子目录
- `package-lock.json`（npm）或 `pnpm-lock.yaml`（pnpm）文件已生成或更新
- 核心依赖（vue, element-plus, vite）存在于 `node_modules/` 中
- `npm run dev` 或 `pnpm dev` 能够成功启动开发服务器

#### 包管理器切换

如果您想从 npm 切换到 pnpm（或反之），请按以下步骤操作：

##### 从 npm 切换到 pnpm

```bash
# 1. 删除 npm 相关文件
rm -rf node_modules package-lock.json

# 2. 使用 pnpm 安装
pnpm install
```

##### 从 pnpm 切换到 npm

```bash
# 1. 删除 pnpm 相关文件
rm -rf node_modules pnpm-lock.yaml

# 2. 使用 npm 安装
npm install
```

⚠️ **注意**: 切换包管理器后，请确保团队成员都使用相同的包管理器，以避免锁文件冲突。

#### 常见前端依赖问题

如果在安装过程中遇到问题，请参考[常见依赖安装错误](#23-常见依赖安装错误)章节。

💡 **下一步**: 完成前后端依赖安装后，您可以继续进行[配置设置](#3-配置详解)或直接查看[开发指南](#4-开发指南)开始开发。

### 2.3 常见依赖安装错误

> 🔍 **故障排查**: 在安装后端和前端依赖时，您可能会遇到一些常见错误。本节列出了这些错误及其解决方案，帮助您快速排查和解决问题。

---

---

#### 后端依赖安装错误

> 🐛 **Go 相关错误**

---

##### 错误 1: Go 模块下载失败（网络问题）

**错误信息**:
```
go: github.com/gin-gonic/gin@v1.9.1: Get "https://proxy.golang.org/github.com/gin-gonic/gin/@v/v1.9.1.mod": dial tcp: i/o timeout
```

或

```
go: downloading github.com/gin-gonic/gin v1.9.1: Get "https://proxy.golang.org/...": dial tcp: lookup proxy.golang.org: no such host
```

**原因**: 
- 网络连接问题
- 无法访问 Go 官方代理服务器
- 防火墙或代理设置阻止了连接

**解决方案**:

1. **配置 Go 代理（推荐）**

   使用国内镜像加速下载：

   ```bash
   # 方法一：使用 go env 命令（推荐）
   go env -w GOPROXY=https://goproxy.cn,direct
   
   # 方法二：设置环境变量
   # Windows (PowerShell)
   $env:GOPROXY = "https://goproxy.cn,direct"
   
   # macOS/Linux (Bash)
   export GOPROXY=https://goproxy.cn,direct
   ```

2. **验证代理配置**

   ```bash
   go env GOPROXY
   ```

   应该输出：`https://goproxy.cn,direct`

3. **清除缓存并重试**

   ```bash
   go clean -modcache
   go mod download
   ```

4. **尝试其他代理**

   如果 goproxy.cn 不可用，尝试其他镜像：

   ```bash
   # 阿里云镜像
   go env -w GOPROXY=https://mirrors.aliyun.com/goproxy/,direct
   
   # 官方代理
   go env -w GOPROXY=https://goproxy.io,direct
   ```

💡 **预防措施**: 在开始项目前先配置 Go 代理，参见[国内网络优化](#15-国内网络优化)章节。

---

##### 错误 2: Go 模块校验和不匹配

**错误信息**:
```
verifying github.com/gin-gonic/gin@v1.9.1: checksum mismatch
        downloaded: h1:abc123...
        go.sum:     h1:def456...
```

**原因**:
- 依赖包被篡改或损坏
- 网络传输错误
- 代理服务器缓存问题

**解决方案**:

1. **清除模块缓存**

   ```bash
   go clean -modcache
   ```

2. **重新下载依赖**

   ```bash
   go mod download
   ```

3. **验证依赖完整性**

   ```bash
   go mod verify
   ```

4. **如果问题持续，更新 go.sum**

   ```bash
   # 删除 go.sum 文件
   rm go.sum
   
   # 重新生成
   go mod tidy
   ```

⚠️ **安全提示**: 只有在确认依赖来源可信的情况下才删除 `go.sum` 文件。

---

##### 错误 3: CGO 编译错误（Windows 环境常见）

**错误信息**:
```
# github.com/mattn/go-sqlite3
exec: "gcc": executable file not found in %PATH%
```

或

```
cgo: C compiler "gcc" not found: exec: "gcc": executable file not found in %PATH%
```

**原因**:
- Windows 系统缺少 C 编译器（GCC）
- SQLite 驱动需要 CGO 支持，而 CGO 需要 C 编译器

**解决方案**:

1. **安装 MinGW 或 TDM-GCC**

   **方法一：使用 Chocolatey（推荐）**

   以管理员身份运行 PowerShell：

   ```powershell
   choco install mingw -y
   ```

   **方法二：手动安装 TDM-GCC**

   - 访问 [TDM-GCC 官网](https://jmeubank.github.io/tdm-gcc/)
   - 下载并安装 64 位版本
   - 安装时确保勾选"Add to PATH"选项

   **方法三：手动安装 MinGW-w64**

   - 访问 [MinGW-w64 官网](https://www.mingw-w64.org/)
   - 下载并安装
   - 手动将 `bin` 目录添加到系统 PATH

2. **验证 GCC 安装**

   重启终端后，运行：

   ```bash
   gcc --version
   ```

   **预期输出**:
   ```
   gcc (tdm64-1) 10.3.0
   Copyright (C) 2020 Free Software Foundation, Inc.
   ```

3. **重新尝试安装依赖**

   ```bash
   go mod download
   go build ./...
   ```

💡 **macOS/Linux 用户**: 这些系统通常已预装 GCC 或 Clang，不会遇到此问题。

---

##### 错误 4: 权限错误（Linux/macOS）

**错误信息**:
```
go: could not create module cache: mkdir /go/pkg/mod: permission denied
```

**原因**:
- Go 模块缓存目录没有写入权限
- 使用 sudo 安装了 Go，导致权限问题

**解决方案**:

1. **修复缓存目录权限**

   ```bash
   sudo chown -R $USER:$USER $(go env GOPATH)
   ```

2. **或者更改 GOPATH**

   ```bash
   # 设置 GOPATH 到用户目录
   export GOPATH=$HOME/go
   echo 'export GOPATH=$HOME/go' >> ~/.bashrc
   source ~/.bashrc
   ```

3. **重新下载依赖**

   ```bash
   go mod download
   ```

⚠️ **避免使用 sudo**: 不要使用 `sudo go mod download`，这会导致权限问题。

---

#### 前端依赖安装错误

> 🐛 **npm/pnpm 相关错误**

---

##### 错误 5: npm 安装失败（网络超时）

**错误信息**:
```
npm ERR! code ETIMEDOUT
npm ERR! errno ETIMEDOUT
npm ERR! network request to https://registry.npmjs.org/vue/-/vue-3.4.0.tgz failed, reason: connect ETIMEDOUT
```

或

```
npm ERR! network This is a problem related to network connectivity.
npm ERR! network In most cases you are behind a proxy or have bad network settings.
```

**原因**:
- 网络连接不稳定
- npm 官方源访问速度慢
- 防火墙或代理设置问题

**解决方案**:

1. **配置 npm 镜像（推荐）**

   ```bash
   npm config set registry https://registry.npmmirror.com
   ```

2. **验证镜像配置**

   ```bash
   npm config get registry
   ```

   应该输出：`https://registry.npmmirror.com/`

3. **清除 npm 缓存**

   ```bash
   npm cache clean --force
   ```

4. **重新安装依赖**

   ```bash
   npm install
   ```

5. **增加超时时间**

   如果网络较慢，可以增加超时时间：

   ```bash
   npm install --timeout=60000
   ```

💡 **替代方案**: 使用 pnpm 代替 npm，通常速度更快且更稳定。

---

##### 错误 6: npm 权限错误（Linux/macOS）

**错误信息**:
```
npm ERR! code EACCES
npm ERR! syscall mkdir
npm ERR! path /usr/local/lib/node_modules
npm ERR! errno -13
npm ERR! Error: EACCES: permission denied, mkdir '/usr/local/lib/node_modules'
```

**原因**:
- 尝试全局安装包时没有权限
- npm 全局目录的所有者不是当前用户

**解决方案**:

1. **方法一：更改 npm 全局目录（推荐）**

   ```bash
   # 创建用户级全局目录
   mkdir -p ~/.npm-global
   
   # 配置 npm 使用新目录
   npm config set prefix '~/.npm-global'
   
   # 添加到 PATH
   echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
   source ~/.bashrc
   ```

2. **方法二：修复全局目录权限**

   ```bash
   sudo chown -R $USER:$USER /usr/local/lib/node_modules
   sudo chown -R $USER:$USER /usr/local/bin
   ```

3. **方法三：使用 nvm 管理 Node.js（推荐）**

   nvm 会将 Node.js 安装到用户目录，避免权限问题：

   ```bash
   # 安装 nvm
   curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
   
   # 安装 Node.js
   nvm install 20
   nvm use 20
   ```

⚠️ **避免使用 sudo**: 不要使用 `sudo npm install`，这会导致权限和安全问题。

---

##### 错误 7: 依赖版本冲突

**错误信息**:
```
npm ERR! code ERESOLVE
npm ERR! ERESOLVE unable to resolve dependency tree
npm ERR! Found: vue@3.4.0
npm ERR! Could not resolve dependency:
npm ERR! peer vue@"^2.6.0" from some-package@1.0.0
```

**原因**:
- 某个依赖包要求的 Vue 版本与项目使用的版本不兼容
- package.json 中的依赖版本冲突

**解决方案**:

1. **使用 --legacy-peer-deps 标志**

   ```bash
   npm install --legacy-peer-deps
   ```

   这会忽略 peer dependencies 的版本冲突。

2. **使用 --force 标志（不推荐）**

   ```bash
   npm install --force
   ```

   ⚠️ **警告**: 这可能导致运行时错误，仅在了解风险的情况下使用。

3. **更新冲突的依赖**

   检查 package.json，更新冲突的依赖到兼容版本：

   ```bash
   npm update some-package
   ```

4. **切换到 pnpm**

   pnpm 对依赖管理更严格，可以避免很多冲突问题：

   ```bash
   rm -rf node_modules package-lock.json
   npm install -g pnpm
   pnpm install
   ```

---

##### 错误 8: 磁盘空间不足

**错误信息**:
```
npm ERR! code ENOSPC
npm ERR! syscall write
npm ERR! errno -28
npm ERR! nospc ENOSPC: no space left on device
```

**原因**:
- 磁盘空间不足
- node_modules 目录占用大量空间

**解决方案**:

1. **检查磁盘空间**

   ```bash
   # Windows (PowerShell)
   Get-PSDrive C
   
   # macOS/Linux
   df -h
   ```

2. **清理 npm 缓存**

   ```bash
   npm cache clean --force
   ```

3. **删除旧的 node_modules**

   ```bash
   # 查找并删除所有 node_modules 目录（谨慎使用）
   # macOS/Linux
   find ~ -name "node_modules" -type d -prune -exec rm -rf '{}' +
   ```

4. **使用 pnpm 节省空间**

   pnpm 使用硬链接共享依赖，可以节省大量磁盘空间：

   ```bash
   npm install -g pnpm
   pnpm install
   ```

💡 **预防措施**: 定期清理不用的项目和缓存，或使用 pnpm 管理依赖。

---

##### 错误 9: package-lock.json 冲突

**错误信息**:
```
npm ERR! code ELOCKVERIFY
npm ERR! Verification failed while extracting package-lock.json
```

**原因**:
- package-lock.json 文件损坏
- 多人协作时锁文件冲突
- npm 版本不一致

**解决方案**:

1. **删除锁文件并重新生成**

   ```bash
   rm package-lock.json
   npm install
   ```

2. **或者使用 npm ci（推荐）**

   ```bash
   rm -rf node_modules
   npm ci
   ```

   `npm ci` 会严格按照 package-lock.json 安装，更适合 CI/CD 环境。

3. **统一团队 npm 版本**

   确保团队成员使用相同的 npm 版本：

   ```bash
   npm --version
   ```

   如果版本不同，更新到最新版本：

   ```bash
   npm install -g npm@latest
   ```

---

#### CGO 相关错误（跨平台）

> 🐛 **CGO 编译错误**

---

##### 错误 10: CGO 编译失败（通用）

**错误信息**:
```
# github.com/mattn/go-sqlite3
cgo: exec gcc: gcc failed: exit status 1
```

**原因**:
- C 编译器未正确安装或配置
- 缺少必要的开发库

**解决方案**:

**Windows**:
```powershell
# 安装 MinGW
choco install mingw -y

# 验证安装
gcc --version
```

**macOS**:
```bash
# 安装 Xcode Command Line Tools
xcode-select --install

# 验证安装
gcc --version
# 或
clang --version
```

**Linux (Ubuntu/Debian)**:
```bash
# 安装构建工具
sudo apt update
sudo apt install build-essential -y

# 验证安装
gcc --version
```

**Linux (CentOS/RHEL)**:
```bash
# 安装开发工具
sudo yum groupinstall "Development Tools" -y

# 验证安装
gcc --version
```

---

#### 通用排查步骤

> 🔧 **系统性排查方法**

如果上述解决方案都不能解决您的问题，请尝试以下通用排查步骤：

1. **检查网络连接**

   ```bash
   # 测试网络连接
   ping google.com
   
   # 测试 DNS 解析
   nslookup registry.npmjs.org
   ```

2. **更新包管理器**

   ```bash
   # 更新 npm
   npm install -g npm@latest
   
   # 更新 Go
   # 访问 https://go.dev/dl/ 下载最新版本
   ```

3. **检查防火墙和代理设置**

   确保防火墙或代理没有阻止包管理器的网络请求。

4. **查看详细错误日志**

   ```bash
   # Go 详细日志
   go mod download -x
   
   # npm 详细日志
   npm install --verbose
   ```

5. **搜索错误信息**

   将错误信息复制到搜索引擎，通常能找到类似问题的解决方案。

6. **寻求帮助**

   - 查看项目的 GitHub Issues
   - 在开发者社区提问（Stack Overflow, Reddit 等）
   - 联系项目维护者

---

#### 预防措施总结

> 💡 **最佳实践建议**

为了避免依赖安装问题，建议：

✅ **环境准备**:
- 安装正确版本的 Go、Node.js 和 FFmpeg
- 配置国内镜像加速（Go 代理、npm 镜像）
- 确保有足够的磁盘空间

✅ **最佳实践**:
- 使用稳定的网络连接
- 定期更新包管理器
- 使用版本管理工具（nvm, gvm）
- 团队统一开发环境和工具版本

✅ **问题排查**:
- 仔细阅读错误信息
- 查看详细日志
- 搜索类似问题的解决方案
- 保持冷静，逐步排查

💡 **提示**: 大多数依赖安装问题都与网络配置有关，配置好镜像加速可以解决 80% 的问题。

[返回目录](#目录)

---

## 3. 配置详解

### 3.1 配置文件模板

### 3.2 数据库配置

### 3.3 存储配置

### 3.4 AI 服务配置

### 3.5 FFmpeg 配置

### 3.6 服务器配置

### 3.7 敏感信息管理

[返回目录](#目录)

---

## 4. 开发指南

### 4.1 后端开发模式

### 4.2 前端开发模式

### 4.3 并行启动

### 4.4 热重载配置

### 4.5 调试技巧

[返回目录](#目录)

---

## 5. 数据库初始化

### 5.1 自动初始化

### 5.2 手动迁移

### 5.3 权限设置

### 5.4 Docker 环境配置

### 5.5 数据库管理

[返回目录](#目录)

---

## 6. 生产构建

### 6.1 后端构建

### 6.2 前端构建

### 6.3 构建优化

### 6.4 跨平台编译

### 6.5 构建验证

### 6.6 部署包打包

[返回目录](#目录)

---

## 7. Docker 部署

### 7.1 Dockerfile 说明

### 7.2 多阶段构建

### 7.3 docker-compose 配置

### 7.4 数据持久化

### 7.5 网络配置

### 7.6 容器管理

### 7.7 镜像加速

[返回目录](#目录)

---

## 8. 传统服务器部署

### 8.1 Linux 服务器部署

### 8.2 systemd 服务配置

### 8.3 Nginx 反向代理

### 8.4 SSL/TLS 配置

### 8.5 日志管理

### 8.6 Windows 服务器部署

[返回目录](#目录)

---

## 9. 问题排查

### 9.1 构建错误

### 9.2 运行时错误

### 9.3 FFmpeg 问题

### 9.4 数据库问题

### 9.5 网络问题

### 9.6 日志分析

### 9.7 性能优化

[返回目录](#目录)

---

## 附录

### 相关资源

- [项目 GitHub 仓库](https://github.com/your-repo/huobao-drama)
- [问题反馈](https://github.com/your-repo/huobao-drama/issues)
- [贡献指南](https://github.com/your-repo/huobao-drama/blob/main/CONTRIBUTING.md)

### 更新日志

- **2026-02-05**: 初始版本创建

---

**注意**: 本文档持续更新中，如有问题或建议，欢迎提交 Issue 或 Pull Request。
