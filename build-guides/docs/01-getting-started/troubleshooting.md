# 常见依赖安装错误

在安装后端和前端依赖时，您可能会遇到一些常见错误。本文档列出了这些错误及其解决方案，帮助您快速排查和解决问题。

---

## 后端依赖安装错误

### 错误 1: Go 模块下载失败（网络问题）

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

💡 **预防措施**: 在开始项目前先配置 Go 代理，参见 [environment-setup.md](environment-setup.md#国内网络优化) 章节。

---

### 错误 2: Go 模块校验和不匹配

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

### 错误 3: CGO 编译错误（Windows 环境常见）

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

### 错误 4: 权限错误（Linux/macOS）

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

## 前端依赖安装错误

### 错误 5: npm 安装失败（网络超时）

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

### 错误 6: npm 权限错误（Linux/macOS）

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

### 错误 7: 依赖版本冲突

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

### 错误 8: 磁盘空间不足

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

### 错误 9: package-lock.json 冲突

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

## CGO 相关错误（跨平台）

### 错误 10: CGO 编译失败（通用）

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

## 通用排查步骤

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

## 预防措施总结

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

---

[返回主页](../../README.md) | [环境准备](environment-setup.md) | [依赖安装](dependencies.md)
