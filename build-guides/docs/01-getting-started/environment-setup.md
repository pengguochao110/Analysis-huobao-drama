# 环境准备

在开始构建和运行 Huobao Drama AI 短剧生成平台之前，您需要准备好开发环境。本章节将指导您安装所有必需的软件依赖，并验证环境配置是否正确。

## 目录

- [必需软件](#必需软件)
- [版本要求](#版本要求)
- [安装说明](#安装说明)
  - [Windows 环境](#windows-环境)
  - [macOS 环境](#macos-环境)
  - [Linux 环境](#linux-环境)
- [环境验证](#环境验证)
- [国内网络优化](#国内网络优化)

---

## 必需软件

Huobao Drama 平台需要以下软件环境：

| 软件 | 最低版本 | 推荐版本 | 用途 |
|------|---------|---------|------|
| **Go** | 1.23.0 | 1.23+ | 后端服务开发和运行 |
| **Node.js** | 18.0.0 | 20.x LTS | 前端应用开发和构建 |
| **FFmpeg** | 4.4.0 | 6.0+ | 视频处理和合成 |
| **Git** | 2.30+ | 最新版 | 代码版本管理 |

ℹ️ **提示**: 推荐使用最新的稳定版本以获得更好的性能和安全性。

---

## 版本要求

### Go 1.23+

- **必需原因**: 项目使用了 Go 1.23 的新特性和标准库改进
- **CGO 支持**: 必须启用 CGO（`CGO_ENABLED=1`），因为 SQLite 驱动需要 C 编译器
- **编译器要求**: Windows 用户需要安装 MinGW 或 TDM-GCC

### Node.js 18+

- **必需原因**: 前端使用 Vue 3 和 Vite，需要 Node.js 18 或更高版本
- **包管理器**: 支持 npm（内置）或 pnpm（推荐，更快更节省空间）
- **兼容性**: 推荐使用 Node.js 20 LTS 版本以获得最佳稳定性

### FFmpeg 4.4+

- **必需原因**: 用于视频编码、转码、音频提取和视频合成
- **编解码器**: 需要支持 H.264、AAC 等常用编解码器
- **性能**: 推荐使用 FFmpeg 6.0+ 以获得更好的性能和新特性

---

## 安装说明

### Windows 环境

#### 方法一：使用 Chocolatey（推荐）

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

#### 方法二：手动安装

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

### macOS 环境

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

### Linux 环境

#### Ubuntu/Debian 系统

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

#### CentOS/RHEL/Fedora 系统

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

#### Arch Linux 系统

```bash
# 安装所有必需软件
sudo pacman -S go nodejs npm ffmpeg base-devel git
```

⚡ **Linux 提示**:
- 大多数 Linux 发行版已预装 GCC，CGO 可以直接使用
- 如果使用包管理器安装的 Go 版本过旧，建议手动安装最新版本
- FFmpeg 在某些发行版的官方仓库中可能不可用，需要启用第三方仓库

---

## 环境验证

安装完成后，请验证所有软件是否正确安装并可用。

### 验证 Go 安装

```bash
go version
```

**预期输出**（版本号可能不同）：
```
go version go1.23.0 windows/amd64
```

或

```
go version go1.23.0 darwin/arm64
```

或

```
go version go1.23.0 linux/amd64
```

### 验证 Node.js 和 npm 安装

```bash
node --version
npm --version
```

**预期输出**：
```
v20.11.0
10.2.4
```

ℹ️ **提示**: Node.js 版本应为 18.x 或更高，npm 版本通常随 Node.js 一起安装。

### 验证 FFmpeg 安装

```bash
ffmpeg -version
```

**预期输出**（前几行）：
```
ffmpeg version 6.0 Copyright (c) 2000-2023 the FFmpeg developers
built with gcc 12.2.0 (Rev10, Built by MSYS2 project)
configuration: --enable-gpl --enable-version3 ...
```

⚠️ **重要**: 确保输出显示版本号为 4.4 或更高。

### 验证 CGO 编译器（仅限 Go 项目）

```bash
# Windows
gcc --version

# macOS/Linux
gcc --version
# 或
clang --version
```

**预期输出**（Windows MinGW）：
```
gcc (tdm64-1) 10.3.0
```

**预期输出**（macOS Clang）：
```
Apple clang version 14.0.0
```

**预期输出**（Linux GCC）：
```
gcc (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0
```

### 验证 Git 安装

```bash
git --version
```

**预期输出**：
```
git version 2.40.0
```

### 完整验证脚本

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

### 验证成功标准

✅ **验证成功的标志**:
- 所有命令都能正常执行，没有"command not found"错误
- Go 版本 ≥ 1.23.0
- Node.js 版本 ≥ 18.0.0
- FFmpeg 版本 ≥ 4.4.0
- GCC 或 Clang 可用（用于 CGO 编译）

如果任何验证失败，请返回相应的安装步骤重新安装。

---

## 国内网络优化

由于网络环境的特殊性，国内开发者在下载依赖和 Docker 镜像时可能会遇到速度慢或连接失败的问题。以下配置可以显著提升下载速度。

### Go 模块代理配置

Go 模块代理可以加速 Go 依赖包的下载。

#### 临时设置（当前终端会话）

**Windows (PowerShell)**:
```powershell
$env:GOPROXY = "https://goproxy.cn,direct"
```

**macOS/Linux (Bash)**:
```bash
export GOPROXY=https://goproxy.cn,direct
```

#### 永久设置（推荐）

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

#### 验证 Go 代理配置

```bash
go env GOPROXY
```

**预期输出**:
```
https://goproxy.cn,direct
```

#### 其他可用的 Go 代理

- **七牛云**: `https://goproxy.cn,direct`（推荐）
- **阿里云**: `https://mirrors.aliyun.com/goproxy/,direct`
- **官方代理**: `https://goproxy.io,direct`

💡 **提示**: `direct` 表示如果代理不可用，则直接从源站下载。

### npm 镜像配置

npm 是 Node.js 的包管理器，配置镜像可以加速前端依赖下载。

#### 方法一：使用淘宝镜像（推荐）

**临时使用**:
```bash
npm install --registry=https://registry.npmmirror.com
```

**永久配置**:
```bash
npm config set registry https://registry.npmmirror.com
```

**验证配置**:
```bash
npm config get registry
```

**预期输出**:
```
https://registry.npmmirror.com/
```

#### 方法二：使用 nrm 管理镜像源

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

#### 恢复官方镜像源

如果需要恢复到官方镜像源：

```bash
npm config set registry https://registry.npmjs.org/
```

或使用 nrm：

```bash
nrm use npm
```

### pnpm 镜像配置

pnpm 是一个更快、更节省磁盘空间的包管理器，推荐使用。

#### 安装 pnpm

```bash
npm install -g pnpm
```

#### 配置 pnpm 镜像

```bash
pnpm config set registry https://registry.npmmirror.com
```

#### 验证 pnpm 配置

```bash
pnpm config get registry
```

**预期输出**:
```
https://registry.npmmirror.com/
```

#### pnpm 的优势

- **速度更快**: 使用硬链接和符号链接，安装速度比 npm 快 2-3 倍
- **节省空间**: 所有包只存储一次，多个项目共享
- **严格性**: 更严格的依赖管理，避免幽灵依赖

💡 **提示**: 本项目支持使用 npm 或 pnpm，推荐使用 pnpm 以获得更好的性能。

### Docker 镜像加速配置

Docker 镜像加速可以显著提升 Docker 镜像的拉取速度。

#### Linux 系统配置

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

#### macOS 系统配置

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

#### Windows 系统配置

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

#### 验证 Docker 镜像加速配置

```bash
docker info | grep -A 5 "Registry Mirrors"
```

**预期输出**:
```
Registry Mirrors:
  https://docker.mirrors.ustc.edu.cn/
  https://hub-mirror.c.163.com/
  https://mirror.baidubce.com/
```

#### 可用的 Docker 镜像加速服务

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

#### 测试 Docker 镜像加速

拉取一个测试镜像验证加速效果：

```bash
docker pull alpine:latest
```

如果配置成功，下载速度应该明显提升。

### 验证所有镜像配置

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

### 常见问题

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

## 下一步

环境准备完成后，请继续：

- [依赖安装](dependencies.md) - 安装后端和前端依赖
- [配置设置](../02-development/configuration.md) - 配置项目
- [开发模式](../02-development/dev-mode.md) - 启动开发环境

---

[返回主页](../../README.md)
