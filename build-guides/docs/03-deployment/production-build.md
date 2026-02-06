# 生产构建指南

本文档介绍如何为生产环境构建 Huobao Drama AI 短剧生成平台的后端和前端应用。

## 📋 目录

- [后端生产构建](#后端生产构建)
- [前端生产构建](#前端生产构建)
- [构建优化](#构建优化)
- [构建验证](#构建验证)
- [部署打包](#部署打包)

---

## 后端生产构建

### 基本构建步骤

#### 1. 进入后端目录

```bash
cd huobao-drama
```

#### 2. 执行生产构建

```bash
CGO_ENABLED=1 go build -o huobao-server main.go
```

### 构建命令说明

**CGO_ENABLED=1 的必要性**:
- 本项目使用 SQLite 数据库，SQLite 的 Go 驱动（`github.com/mattn/go-sqlite3`）依赖 CGO
- CGO 允许 Go 代码调用 C 语言库，SQLite 是用 C 编写的
- 如果不启用 CGO，构建将失败并提示缺少 SQLite 驱动

**构建产物**:
- **文件名**: `huobao-server`（Linux/macOS）或 `huobao-server.exe`（Windows）
- **位置**: `huobao-drama/` 目录下
- **类型**: 可执行二进制文件
- **大小**: 约 30-50 MB（包含所有依赖）

### 跨平台编译

如果需要在一个平台上为另一个平台构建可执行文件，可以使用 `GOOS` 和 `GOARCH` 环境变量。

#### 为 Linux 构建（在任意平台）

```bash
CGO_ENABLED=1 GOOS=linux GOARCH=amd64 go build -o huobao-server-linux main.go
```

#### 为 Windows 构建（在任意平台）

```bash
CGO_ENABLED=1 GOOS=windows GOARCH=amd64 go build -o huobao-server.exe main.go
```

#### 为 macOS 构建（在任意平台）

```bash
CGO_ENABLED=1 GOOS=darwin GOARCH=amd64 go build -o huobao-server-macos main.go
```

#### 为 macOS ARM64 构建（Apple Silicon）

```bash
CGO_ENABLED=1 GOOS=darwin GOARCH=arm64 go build -o huobao-server-macos-arm64 main.go
```

⚠️ **跨平台编译注意事项**:

由于 SQLite 依赖 CGO，跨平台编译需要目标平台的 C 编译器：

- **在 Linux 上为 Windows 编译**: 需要安装 `mingw-w64`
  ```bash
  # Ubuntu/Debian
  sudo apt-get install gcc-mingw-w64
  
  # 然后使用
  CC=x86_64-w64-mingw32-gcc CGO_ENABLED=1 GOOS=windows GOARCH=amd64 go build -o huobao-server.exe main.go
  ```

- **在 macOS 上为 Linux 编译**: 需要安装交叉编译工具链
  ```bash
  brew install FiloSottile/musl-cross/musl-cross
  ```

- **推荐方式**: 在目标平台上直接构建，或使用 Docker 多阶段构建

### 构建优化选项

#### 减小二进制文件大小

```bash
CGO_ENABLED=1 go build -ldflags="-s -w" -o huobao-server main.go
```

**参数说明**:
- `-s`: 去除符号表（symbol table）
- `-w`: 去除 DWARF 调试信息
- 可减小约 30% 的文件大小
- ⚠️ 注意：这会使调试变得困难，仅用于生产环境

#### 添加版本信息

```bash
VERSION=$(git describe --tags --always --dirty)
BUILD_TIME=$(date -u '+%Y-%m-%d_%H:%M:%S')
CGO_ENABLED=1 go build \
  -ldflags="-X main.Version=${VERSION} -X main.BuildTime=${BUILD_TIME}" \
  -o huobao-server main.go
```

---

## 前端生产构建

### 基本构建步骤

#### 1. 进入前端目录

```bash
cd huobao-drama/web
```

#### 2. 执行生产构建

使用 npm:
```bash
npm run build
```

或使用 pnpm（推荐，速度更快）:
```bash
pnpm build
```

### 构建产物说明

**构建产物位置**: `huobao-drama/web/dist/` 目录

**构建产物内容**:
```
dist/
├── index.html              # 主 HTML 文件
├── assets/                 # 静态资源目录
│   ├── index-[hash].js    # 主 JavaScript 文件（已压缩）
│   ├── index-[hash].css   # 主 CSS 文件（已压缩）
│   ├── vendor-[hash].js   # 第三方库（已分离）
│   └── ...                # 其他资源文件
└── favicon.ico            # 网站图标
```

**文件特点**:
- 所有 JavaScript 和 CSS 文件都经过压缩和混淆
- 文件名包含内容哈希值（如 `index-a1b2c3d4.js`），便于缓存管理
- 第三方库代码已分离到独立的 vendor 文件
- 图片和字体等静态资源已优化

### 配置生产环境 API 端点

#### 方法 1: 使用环境变量（推荐）

在构建前设置环境变量：

```bash
# Linux/macOS
export VITE_API_BASE_URL=https://api.yourdomain.com
npm run build

# Windows (CMD)
set VITE_API_BASE_URL=https://api.yourdomain.com
npm run build

# Windows (PowerShell)
$env:VITE_API_BASE_URL="https://api.yourdomain.com"
npm run build
```

#### 方法 2: 创建 .env.production 文件

在 `huobao-drama/web/` 目录下创建 `.env.production` 文件：

```env
# .env.production
VITE_API_BASE_URL=https://api.yourdomain.com
```

然后执行构建：
```bash
npm run build
```

#### 方法 3: 修改 vite.config.ts

编辑 `huobao-drama/web/vite.config.ts`，在 `define` 部分设置：

```typescript
export default defineConfig({
  // ...
  define: {
    'import.meta.env.VITE_API_BASE_URL': JSON.stringify('https://api.yourdomain.com')
  }
})
```

💡 **最佳实践**: 使用方法 1 或方法 2，这样可以在不修改代码的情况下为不同环境构建。

---

## 构建优化

### 生产环境配置优化

#### 后端配置优化

编辑 `config.yaml`，确保生产环境使用优化配置：

```yaml
app:
  debug: false              # 禁用调试模式
  log_level: "info"         # 设置日志级别为 info 或 warn

server:
  port: 8080
  mode: "release"           # 使用 release 模式

# 启用缓存
cache:
  enabled: true
  ttl: 3600                 # 缓存时间（秒）
```

**优化效果**:
- 禁用调试日志可减少 I/O 开销
- Release 模式下 Gin 框架性能更好
- 启用缓存可减少数据库查询

#### 前端构建优化

Vite 默认已启用以下优化，无需额外配置：

- ✅ **代码压缩**: JavaScript 和 CSS 自动压缩
- ✅ **Tree Shaking**: 自动移除未使用的代码
- ✅ **代码分割**: 按路由自动分割代码
- ✅ **资源优化**: 图片和字体自动优化
- ✅ **Gzip 压缩**: 生成 .gz 文件（需服务器支持）

### 减小构建产物大小

#### 后端优化

1. **使用编译标志去除调试信息**:
   ```bash
   CGO_ENABLED=1 go build -ldflags="-s -w" -o huobao-server main.go
   ```

2. **使用 UPX 压缩**（可选）:
   ```bash
   # 安装 UPX
   # Ubuntu/Debian: sudo apt-get install upx
   # macOS: brew install upx
   
   # 压缩可执行文件
   upx --best --lzma huobao-server
   ```
   
   ⚠️ **注意**: UPX 压缩会增加启动时间，且某些系统可能将其识别为恶意软件。

#### 前端优化

1. **分析构建产物大小**:
   ```bash
   npm run build -- --mode production
   npx vite-bundle-visualizer
   ```

2. **移除未使用的依赖**:
   ```bash
   # 检查未使用的依赖
   npx depcheck
   
   # 移除未使用的包
   npm uninstall <package-name>
   ```

3. **启用 Brotli 压缩**（比 Gzip 更高效）:
   
   编辑 `vite.config.ts`:
   ```typescript
   import viteCompression from 'vite-plugin-compression'
   
   export default defineConfig({
     plugins: [
       viteCompression({
         algorithm: 'brotliCompress',
         ext: '.br'
       })
     ]
   })
   ```

---

## 构建验证

### 后端构建验证

#### 1. 检查可执行文件是否生成

```bash
ls -lh huobao-server
# 或 Windows
dir huobao-server.exe
```

**预期输出**:
```
-rwxr-xr-x 1 user user 45M Feb  5 10:30 huobao-server
```

#### 2. 验证可执行文件可以运行

```bash
./huobao-server --version
# 或简单测试启动
./huobao-server
```

**预期输出**:
```
Starting Drama Generator API Server...
Database connected successfully
Database tables migrated successfully
🚀 Server starting...
   port: 8080
   mode: release
✅ Server is ready!
```

按 `Ctrl+C` 停止服务器。

#### 3. 检查依赖是否完整

```bash
# Linux
ldd huobao-server

# macOS
otool -L huobao-server
```

确保所有依赖库都能找到。

### 前端构建验证

#### 1. 检查 dist 目录是否生成

```bash
ls -lh dist/
```

**预期输出**:
```
total 2.5M
-rw-r--r-- 1 user user  1.2K Feb  5 10:35 index.html
drwxr-xr-x 2 user user  4.0K Feb  5 10:35 assets/
-rw-r--r-- 1 user user  15K  Feb  5 10:35 favicon.ico
```

#### 2. 检查关键文件是否存在

```bash
# 检查主 HTML 文件
cat dist/index.html | grep -o '<script.*src="[^"]*"' | head -1

# 检查 assets 目录
ls dist/assets/ | grep -E '\.js$|\.css$'
```

**预期输出**:
```
index-a1b2c3d4.js
index-e5f6g7h8.css
vendor-i9j0k1l2.js
```

#### 3. 本地测试生产构建

使用简单的 HTTP 服务器测试：

```bash
# 使用 Python
cd dist
python -m http.server 8000

# 或使用 Node.js serve
npx serve dist -p 8000

# 或使用 Go
cd dist
go run -m http.server 8000
```

然后在浏览器中访问 `http://localhost:8000`，验证应用是否正常运行。

#### 4. 检查 API 端点配置

在浏览器开发者工具中检查网络请求，确认 API 请求指向正确的端点：

```javascript
// 在浏览器控制台执行
console.log(import.meta.env.VITE_API_BASE_URL)
```

---

## 部署打包

### 创建部署包

#### 方法 1: 手动打包

```bash
# 创建部署目录
mkdir -p huobao-drama-deploy

# 复制后端可执行文件
cp huobao-drama/huobao-server huobao-drama-deploy/

# 复制前端构建产物
cp -r huobao-drama/web/dist huobao-drama-deploy/web

# 复制配置文件模板
cp Analysis-huobao-drama/build-guides/config/config.example.yaml huobao-drama-deploy/config.yaml

# 创建必要的目录
mkdir -p huobao-drama-deploy/data
mkdir -p huobao-drama-deploy/uploads
mkdir -p huobao-drama-deploy/temp

# 打包
tar -czf huobao-drama-v1.0.0.tar.gz huobao-drama-deploy/

# 或使用 zip（Windows 友好）
zip -r huobao-drama-v1.0.0.zip huobao-drama-deploy/
```

#### 方法 2: 使用构建脚本

使用提供的构建脚本自动化打包过程：

```bash
# 使脚本可执行
chmod +x Analysis-huobao-drama/build-guides/scripts/build.sh

# 执行构建脚本
./Analysis-huobao-drama/build-guides/scripts/build.sh
```

构建脚本会自动：
1. 构建后端和前端
2. 验证构建产物
3. 创建部署目录结构
4. 打包为压缩文件

### 部署包内容

完整的部署包应包含：

```
huobao-drama-deploy/
├── huobao-server           # 后端可执行文件
├── web/                    # 前端静态文件
│   └── dist/
│       ├── index.html
│       └── assets/
├── config.yaml             # 配置文件（需根据环境修改）
├── data/                   # 数据库目录（空）
├── uploads/                # 上传文件目录（空）
├── temp/                   # 临时文件目录（空）
└── README.txt              # 部署说明
```

### 部署包大小估算

| 组件 | 大小 |
|------|------|
| 后端可执行文件 | ~40-50 MB |
| 前端静态文件 | ~2-5 MB |
| 配置和文档 | <1 MB |
| **总计** | **~45-60 MB** |

### 部署前检查清单

在部署到生产环境前，请确认：

- [ ] 后端可执行文件已构建并可运行
- [ ] 前端静态文件已构建到 dist/ 目录
- [ ] 配置文件已根据生产环境修改
- [ ] API 端点配置正确
- [ ] 数据库目录权限正确（755）
- [ ] 上传目录权限正确（755）
- [ ] FFmpeg 已安装并配置路径
- [ ] 所有敏感信息（API 密钥）已设置
- [ ] 已在测试环境验证构建产物

---

## 下一步

构建完成后，您可以选择以下部署方式：

- **[Docker 部署](docker.md)** - 推荐，简化部署和环境管理
- **[传统服务器部署](traditional.md)** - 直接在服务器上运行

如果遇到问题，请查看：
- **[问题排查指南](../04-reference/troubleshooting.md)**
- **[性能优化指南](../04-reference/optimization.md)**

---

**最后更新**: 2026-02-05
