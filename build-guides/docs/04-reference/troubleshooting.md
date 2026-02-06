# 问题排查指南

本文档提供了 Huobao Drama AI 短剧生成平台在构建、运行和部署过程中可能遇到的常见问题及其解决方案。

---

## 目录

- [构建错误排查](#构建错误排查)
- [运行时错误排查](#运行时错误排查)
- [日志分析和性能优化](#日志分析和性能优化)

---

## 构建错误排查

### 错误 1: Go 模块下载失败（网络超时）

**错误信息**:
```
go: github.com/gin-gonic/gin@v1.9.1: Get "https://proxy.golang.org/...": dial tcp: i/o timeout
```

**原因**:
- 网络连接问题或无法访问 Go 官方代理服务器
- 防火墙或代理设置阻止了连接

**解决方案**:

1. **配置 Go 代理（推荐使用国内镜像）**

   ```bash
   # 使用 goproxy.cn（推荐）
   go env -w GOPROXY=https://goproxy.cn,direct
   
   # 或使用阿里云镜像
   go env -w GOPROXY=https://mirrors.aliyun.com/goproxy/,direct
   ```

2. **验证代理配置**

   ```bash
   go env GOPROXY
   ```

3. **清除缓存并重试**

   ```bash
   go clean -modcache
   go mod download
   ```

💡 **提示**: 在项目开始前配置好 Go 代理可以避免大部分网络问题。

---

### 错误 2: CGO 编译错误（Windows 环境）

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

**方法一：使用 Chocolatey 安装 MinGW（推荐）**

以管理员身份运行 PowerShell：

```powershell
choco install mingw -y
```

**方法二：手动安装 TDM-GCC**

1. 访问 [TDM-GCC 官网](https://jmeubank.github.io/tdm-gcc/)
2. 下载并安装 64 位版本
3. 安装时确保勾选 "Add to PATH" 选项

**方法三：手动安装 MinGW-w64**

1. 访问 [MinGW-w64 官网](https://www.mingw-w64.org/)
2. 下载并安装
3. 手动将 `bin` 目录添加到系统 PATH

**验证安装**:

重启终端后运行：

```bash
gcc --version
```

**预期输出**:
```
gcc (tdm64-1) 10.3.0
Copyright (C) 2020 Free Software Foundation, Inc.
```

**重新尝试构建**:

```bash
cd huobao-drama
go mod download
go build ./...
```

💡 **macOS/Linux 用户**: 这些系统通常已预装 GCC 或 Clang，不会遇到此问题。

---

### 错误 3: 前端依赖安装失败（npm ERR!）

**错误信息**:
```
npm ERR! code ETIMEDOUT
npm ERR! errno ETIMEDOUT
npm ERR! network request to https://registry.npmjs.org/vue/-/vue-3.4.0.tgz failed
```

或

```
npm ERR! code ERESOLVE
npm ERR! ERESOLVE unable to resolve dependency tree
```

**原因**:
- 网络连接不稳定或 npm 官方源访问速度慢
- 依赖版本冲突
- npm 缓存损坏

**解决方案**:

**1. 配置 npm 镜像（推荐）**

```bash
# 使用淘宝镜像
npm config set registry https://registry.npmmirror.com

# 验证配置
npm config get registry
```

**2. 清除 npm 缓存**

```bash
npm cache clean --force
```

**3. 删除 node_modules 和 package-lock.json 重新安装**

```bash
# Windows (PowerShell)
Remove-Item -Recurse -Force node_modules
Remove-Item package-lock.json
npm install

# macOS/Linux
rm -rf node_modules package-lock.json
npm install
```

**4. 使用 --legacy-peer-deps 解决依赖冲突**

```bash
npm install --legacy-peer-deps
```

**5. 增加超时时间**

```bash
npm install --timeout=60000
```

💡 **替代方案**: 使用 pnpm 代替 npm，通常速度更快且更稳定：

```bash
npm install -g pnpm
cd huobao-drama/web
pnpm install
```

---

### 错误 4: 构建脚本权限错误（Linux/macOS）

**错误信息**:
```
bash: ./build.sh: Permission denied
```

或

```
-bash: ./scripts/setup.sh: Permission denied
```

**原因**:
- 脚本文件没有执行权限
- 从 Windows 系统复制的脚本可能丢失执行权限

**解决方案**:

**1. 添加执行权限**

```bash
# 为单个脚本添加执行权限
chmod +x build.sh

# 为 scripts 目录下所有脚本添加执行权限
chmod +x scripts/*.sh
```

**2. 验证权限**

```bash
ls -l build.sh
```

**预期输出**:
```
-rwxr-xr-x 1 user user 1234 Jan 01 12:00 build.sh
```

注意第一列的 `x` 表示可执行权限。

**3. 执行脚本**

```bash
./build.sh
```

💡 **Windows 用户**: Windows 系统不需要设置执行权限，可以直接运行脚本：

```powershell
.\build.ps1
# 或
bash build.sh
```

---

## 运行时错误排查

### 错误 5: FFmpeg 不可用错误

**错误信息**:
```
Error: ffmpeg: command not found
```

或

```
Error: exec: "ffmpeg": executable file not found in $PATH
```

或应用日志中显示：

```
[ERROR] Failed to process video: ffmpeg not available
```

**原因**:
- FFmpeg 未安装
- FFmpeg 未添加到系统 PATH
- 配置文件中 FFmpeg 路径不正确

**解决方案**:

**1. 验证 FFmpeg 是否已安装**

```bash
ffmpeg -version
```

如果显示 "command not found"，需要安装 FFmpeg。

**2. 安装 FFmpeg**

**Windows**:
```powershell
# 使用 Chocolatey
choco install ffmpeg -y

# 或使用 Scoop
scoop install ffmpeg
```

**macOS**:
```bash
brew install ffmpeg
```

**Linux (Ubuntu/Debian)**:
```bash
sudo apt update
sudo apt install ffmpeg -y
```

**Linux (CentOS/RHEL)**:
```bash
sudo yum install epel-release -y
sudo yum install ffmpeg -y
```

**3. 验证安装**

```bash
ffmpeg -version
```

**预期输出**:
```
ffmpeg version 4.4.2 Copyright (c) 2000-2021 the FFmpeg developers
built with gcc 11.2.0 (Ubuntu 11.2.0-19ubuntu1)
...
```

**4. 配置 FFmpeg 路径**

如果 FFmpeg 已安装但应用仍然找不到，需要在配置文件中指定路径。

编辑 `config.yaml`:

```yaml
ffmpeg:
  # Windows 示例
  path: "C:\\Program Files\\ffmpeg\\bin\\ffmpeg.exe"
  
  # macOS 示例
  # path: "/usr/local/bin/ffmpeg"
  
  # Linux 示例
  # path: "/usr/bin/ffmpeg"
```

**5. 查找 FFmpeg 路径**

```bash
# Windows (PowerShell)
where.exe ffmpeg

# macOS/Linux
which ffmpeg
```

将输出的路径填入配置文件。

💡 **Docker 环境**: 如果使用 Docker 部署，确保 Dockerfile 中已安装 FFmpeg。

---

### 错误 6: 数据库权限错误

**错误信息**:
```
Error: unable to open database file
```

或

```
Error: attempt to write a readonly database
```

或

```
[ERROR] Failed to initialize database: unable to open database file: ./data/huobao.db
```

**原因**:
- SQLite 数据库文件没有读写权限
- 数据库文件所在目录没有写入权限
- Docker 容器中的权限问题

**解决方案**:

**1. 检查数据库文件权限（Linux/macOS）**

```bash
ls -l data/huobao.db
```

**2. 修复 SQLite 文件权限**

```bash
# 给予读写权限
chmod 644 data/huobao.db

# 如果文件不存在，确保目录有写入权限
chmod 755 data/
```

**3. 修复数据库目录权限**

```bash
# 确保应用运行用户对目录有写入权限
sudo chown -R $USER:$USER data/
chmod 755 data/
```

**4. Windows 权限设置**

在 Windows 上，右键点击 `data` 文件夹：
1. 选择 "属性" → "安全"
2. 确保当前用户有 "完全控制" 权限
3. 如果没有，点击 "编辑" 添加权限

**5. Docker 环境权限问题**

如果在 Docker 中运行，确保卷挂载的权限正确：

```yaml
# docker-compose.yml
services:
  huobao:
    volumes:
      - ./data:/app/data
    user: "${UID}:${GID}"  # 使用宿主机用户 ID
```

或在启动前设置权限：

```bash
mkdir -p data
chmod 777 data  # 开发环境可以使用，生产环境需要更严格的权限
```

**6. 验证权限**

重启应用并检查日志，确认数据库可以正常访问。

⚠️ **安全提示**: 生产环境中不要使用 `chmod 777`，应该使用最小权限原则。

---

### 错误 7: 端口冲突错误

**错误信息**:
```
Error: listen tcp :8080: bind: address already in use
```

或

```
[ERROR] Failed to start server: listen tcp 0.0.0.0:8080: bind: address already in use
```

或前端开发服务器：

```
Error: Port 5173 is already in use
```

**原因**:
- 指定的端口已被其他程序占用
- 之前的应用实例没有正确关闭
- 多个实例同时运行

**解决方案**:

**1. 检查端口占用（Windows）**

```powershell
# 查看占用 8080 端口的进程
netstat -ano | findstr :8080

# 输出示例：
# TCP    0.0.0.0:8080    0.0.0.0:0    LISTENING    12345

# 根据 PID 查看进程详情
tasklist | findstr 12345

# 结束进程
taskkill /PID 12345 /F
```

**2. 检查端口占用（macOS/Linux）**

```bash
# 查看占用 8080 端口的进程
lsof -i :8080

# 输出示例：
# COMMAND   PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
# huobao  12345 user    3u  IPv4  0x123      0t0  TCP *:8080 (LISTEN)

# 结束进程
kill -9 12345

# 或使用 fuser（Linux）
fuser -k 8080/tcp
```

**3. 修改配置文件中的端口**

如果不想结束占用端口的进程，可以修改应用使用的端口。

编辑 `config.yaml`:

```yaml
server:
  port: 8081  # 改为其他未占用的端口
```

或使用环境变量：

```bash
# 后端
export PORT=8081
go run main.go

# 前端（修改 vite.config.ts 或使用命令行参数）
npm run dev -- --port 5174
```

**4. 确保之前的实例已关闭**

```bash
# 查找所有 huobao 相关进程
ps aux | grep huobao

# 或在 Windows 上
tasklist | findstr huobao

# 结束所有相关进程
pkill huobao  # Linux/macOS
```

💡 **开发建议**: 使用不同的端口进行开发和生产部署，避免冲突。

---

### 错误 8: AI 服务连接错误

**错误信息**:
```
Error: Failed to connect to AI service: invalid API key
```

或

```
[ERROR] AI request failed: 401 Unauthorized
```

或

```
Error: dial tcp: lookup api.openai.com: no such host
```

**原因**:
- API 密钥无效或过期
- API 密钥未正确配置
- 网络无法访问 AI 服务端点
- API 配额已用完

**解决方案**:

**1. 验证 API 密钥**

检查配置文件中的 API 密钥是否正确：

```yaml
# config.yaml
ai:
  api_key: "sk-xxxxxxxxxxxxxxxxxxxxx"  # 确保密钥正确
  endpoint: "https://api.openai.com/v1"
```

**2. 使用环境变量管理密钥**

不要将 API 密钥硬编码在配置文件中，使用环境变量：

```yaml
# config.yaml
ai:
  api_key: "${AI_API_KEY}"  # 从环境变量读取
```

设置环境变量：

```bash
# Windows (PowerShell)
$env:AI_API_KEY = "sk-xxxxxxxxxxxxxxxxxxxxx"

# macOS/Linux
export AI_API_KEY="sk-xxxxxxxxxxxxxxxxxxxxx"

# 或添加到 .env 文件
echo "AI_API_KEY=sk-xxxxxxxxxxxxxxxxxxxxx" >> .env
```

**3. 测试 API 连接**

使用 curl 测试 API 是否可访问：

```bash
curl -H "Authorization: Bearer YOUR_API_KEY" \
     https://api.openai.com/v1/models
```

如果返回 401 错误，说明 API 密钥无效。

**4. 检查网络连接**

```bash
# 测试能否访问 AI 服务端点
ping api.openai.com

# 测试 HTTPS 连接
curl -I https://api.openai.com
```

**5. 配置代理（如果需要）**

如果网络需要通过代理访问：

```bash
# 设置 HTTP 代理
export HTTP_PROXY=http://proxy.example.com:8080
export HTTPS_PROXY=http://proxy.example.com:8080
```

或在配置文件中配置：

```yaml
ai:
  api_key: "${AI_API_KEY}"
  endpoint: "https://api.openai.com/v1"
  proxy: "http://proxy.example.com:8080"  # 如果应用支持
```

**6. 检查 API 配额**

登录 AI 服务提供商的控制台，检查：
- API 密钥是否有效
- 账户余额是否充足
- 是否达到速率限制

**7. 使用国内 AI 服务**

如果无法访问国外 AI 服务，可以使用国内替代方案：

```yaml
ai:
  # 使用阿里云通义千问
  api_key: "${ALIYUN_API_KEY}"
  endpoint: "https://dashscope.aliyuncs.com/api/v1"
  
  # 或使用百度文心一言
  # api_key: "${BAIDU_API_KEY}"
  # endpoint: "https://aip.baidubce.com/rpc/2.0/ai_custom/v1"
```

💡 **安全提示**: 永远不要将 API 密钥提交到版本控制系统，使用 `.gitignore` 忽略包含密钥的文件。

---

## 日志分析和性能优化

### 查看应用日志

**1. 控制台输出**

开发模式下，应用日志直接输出到控制台：

```bash
# 后端
cd huobao-drama
go run main.go

# 前端
cd huobao-drama/web
npm run dev
```

**2. 日志文件**

生产环境中，日志通常写入文件：

```bash
# 查看日志文件（如果配置了日志文件）
tail -f logs/huobao.log

# 或使用 less 查看
less logs/huobao.log
```

**3. Docker 容器日志**

```bash
# 查看容器日志
docker logs huobao-drama

# 实时跟踪日志
docker logs -f huobao-drama

# 查看最近 100 行日志
docker logs --tail 100 huobao-drama
```

**4. systemd 服务日志**

```bash
# 查看服务日志
sudo journalctl -u huobao

# 实时跟踪日志
sudo journalctl -u huobao -f

# 查看最近 100 行日志
sudo journalctl -u huobao -n 100

# 查看特定时间范围的日志
sudo journalctl -u huobao --since "2024-01-01" --until "2024-01-02"
```

---

### 日志级别说明

应用日志通常包含以下级别：

| 级别 | 说明 | 示例 |
|------|------|------|
| **DEBUG** | 详细的调试信息，仅用于开发 | `[DEBUG] Processing frame 123` |
| **INFO** | 一般信息，记录正常操作 | `[INFO] Server started on port 8080` |
| **WARN** | 警告信息，可能的问题 | `[WARN] API rate limit approaching` |
| **ERROR** | 错误信息，需要关注 | `[ERROR] Failed to generate video` |

**配置日志级别**:

在配置文件中设置日志级别：

```yaml
# config.yaml
logging:
  level: "INFO"  # 可选: DEBUG, INFO, WARN, ERROR
  format: "json"  # 可选: json, text
```

开发环境使用 DEBUG 级别，生产环境使用 INFO 或 WARN 级别。

---

### 日志过滤和搜索技巧

**1. 使用 grep 过滤日志**

```bash
# 查找包含 "ERROR" 的日志
grep "ERROR" logs/huobao.log

# 查找包含 "ERROR" 或 "WARN" 的日志
grep -E "ERROR|WARN" logs/huobao.log

# 忽略大小写
grep -i "error" logs/huobao.log

# 显示匹配行的前后 3 行上下文
grep -C 3 "ERROR" logs/huobao.log
```

**2. 使用 tail 实时监控**

```bash
# 实时查看日志文件
tail -f logs/huobao.log

# 实时查看并过滤 ERROR
tail -f logs/huobao.log | grep "ERROR"

# 查看最近 100 行
tail -n 100 logs/huobao.log
```

**3. 使用 awk 提取特定字段**

```bash
# 提取时间戳和错误信息
awk '/ERROR/ {print $1, $2, $NF}' logs/huobao.log

# 统计错误数量
grep "ERROR" logs/huobao.log | wc -l
```

**4. 使用 less 浏览大文件**

```bash
# 使用 less 打开日志文件
less logs/huobao.log

# 在 less 中搜索（按 / 然后输入搜索词）
# 按 n 跳到下一个匹配，按 N 跳到上一个匹配
# 按 q 退出
```

**5. Windows PowerShell 日志查看**

```powershell
# 查看日志文件
Get-Content logs\huobao.log

# 实时监控日志
Get-Content logs\huobao.log -Wait

# 过滤包含 ERROR 的行
Get-Content logs\huobao.log | Select-String "ERROR"

# 查看最后 100 行
Get-Content logs\huobao.log -Tail 100
```

---

### 启用详细日志

当需要诊断问题时，可以启用详细日志：

**1. 修改配置文件**

```yaml
# config.yaml
logging:
  level: "DEBUG"  # 启用详细日志
```

**2. 使用环境变量**

```bash
# 临时启用 DEBUG 日志
export LOG_LEVEL=DEBUG
go run main.go
```

**3. 命令行参数（如果应用支持）**

```bash
./huobao-server --log-level=debug
```

⚠️ **注意**: DEBUG 日志会产生大量输出，可能影响性能，仅在需要时启用。

---

### 常见性能问题

#### 症状 1: API 响应慢

**表现**:
- 前端请求超时
- 接口响应时间超过 5 秒
- 用户体验差

**可能原因**:
- 数据库查询效率低
- AI 服务响应慢
- 视频处理任务阻塞主线程
- 并发请求过多

**诊断方法**:

1. **查看应用日志**，找出慢请求：

```bash
grep "took.*ms" logs/huobao.log | grep -E "[0-9]{4,}"
```

2. **使用浏览器开发者工具**:
   - 打开 Chrome DevTools (F12)
   - 切换到 Network 标签
   - 查看请求耗时和瀑布图

3. **检查数据库查询**:

```bash
# 如果启用了查询日志
grep "SELECT" logs/huobao.log | grep -E "[0-9]{3,}ms"
```

**优化建议**:

1. **数据库优化**:
   - 为常用查询字段添加索引
   - 优化复杂查询，避免 N+1 问题
   - 使用分页减少数据量

2. **异步处理**:
   - 将耗时任务（视频生成、图片处理）放入后台队列
   - 使用 goroutine 并发处理
   - 返回任务 ID，前端轮询状态

3. **缓存策略**:
   - 缓存 AI 生成结果
   - 使用 Redis 缓存热点数据
   - 启用 HTTP 缓存头

---

#### 症状 2: 内存占用高

**表现**:
- 应用内存使用持续增长
- 系统内存不足
- 应用被 OOM Killer 终止

**可能原因**:
- 内存泄漏
- 大文件处理未释放
- goroutine 泄漏
- 缓存未设置过期时间

**诊断方法**:

1. **查看内存使用**:

```bash
# Linux
top -p $(pgrep huobao)

# 或使用 htop
htop -p $(pgrep huobao)

# Docker 容器
docker stats huobao-drama
```

2. **使用 Go pprof 分析**:

在代码中启用 pprof（开发环境）：

```go
import _ "net/http/pprof"

go func() {
    log.Println(http.ListenAndServe("localhost:6060", nil))
}()
```

访问 pprof 端点：

```bash
# 查看堆内存分配
go tool pprof http://localhost:6060/debug/pprof/heap

# 生成内存分析图
go tool pprof -http=:8081 http://localhost:6060/debug/pprof/heap
```

**优化建议**:

1. **及时释放资源**:
   - 处理完大文件后立即关闭
   - 使用 `defer` 确保资源释放
   - 避免在循环中创建大对象

2. **限制并发数**:
   - 使用 worker pool 限制 goroutine 数量
   - 设置最大并发任务数

3. **设置缓存过期**:
   - 为缓存数据设置 TTL
   - 定期清理过期数据

---

### 性能分析工具

#### 1. Go pprof（后端性能分析）

**启用 pprof**:

```go
// main.go
import _ "net/http/pprof"

func main() {
    // 启动 pprof 服务器
    go func() {
        log.Println(http.ListenAndServe("localhost:6060", nil))
    }()
    
    // 应用主逻辑
    // ...
}
```

**使用 pprof**:

```bash
# CPU 性能分析（采样 30 秒）
go tool pprof http://localhost:6060/debug/pprof/profile?seconds=30

# 内存分析
go tool pprof http://localhost:6060/debug/pprof/heap

# goroutine 分析
go tool pprof http://localhost:6060/debug/pprof/goroutine

# 生成可视化报告
go tool pprof -http=:8081 http://localhost:6060/debug/pprof/profile
```

**分析结果**:
- 查找 CPU 热点函数
- 识别内存分配过多的代码
- 检测 goroutine 泄漏

---

#### 2. Chrome DevTools（前端性能分析）

**使用步骤**:

1. 打开 Chrome DevTools (F12)
2. 切换到 **Performance** 标签
3. 点击录制按钮，执行操作
4. 停止录制，分析结果

**关注指标**:
- **FCP (First Contentful Paint)**: 首次内容绘制时间
- **LCP (Largest Contentful Paint)**: 最大内容绘制时间
- **TTI (Time to Interactive)**: 可交互时间
- **TBT (Total Blocking Time)**: 总阻塞时间

**优化建议**:
- 减少 JavaScript 包大小
- 使用代码分割和懒加载
- 优化图片和视频资源
- 启用浏览器缓存

---

#### 3. Lighthouse（网站性能评估）

**使用方法**:

1. 打开 Chrome DevTools
2. 切换到 **Lighthouse** 标签
3. 选择分析类型（性能、可访问性等）
4. 点击 "Generate report"

**评分标准**:
- **90-100**: 优秀
- **50-89**: 需要改进
- **0-49**: 差

**优化建议**:
- 按照 Lighthouse 建议逐项优化
- 关注性能、可访问性、最佳实践、SEO

---

### 数据库查询优化

#### 1. 添加索引

**识别慢查询**:

```sql
-- 启用 SQLite 查询分析
EXPLAIN QUERY PLAN SELECT * FROM dramas WHERE user_id = 123;
```

**添加索引**:

```sql
-- 为常用查询字段添加索引
CREATE INDEX idx_dramas_user_id ON dramas(user_id);
CREATE INDEX idx_scenes_drama_id ON scenes(drama_id);
CREATE INDEX idx_assets_type ON assets(type);
```

**验证索引效果**:

```sql
EXPLAIN QUERY PLAN SELECT * FROM dramas WHERE user_id = 123;
-- 应该显示 "SEARCH TABLE dramas USING INDEX idx_dramas_user_id"
```

---

#### 2. 查询优化

**避免 SELECT ***:

```go
// 不好的做法
db.Find(&dramas)

// 好的做法：只查询需要的字段
db.Select("id, title, created_at").Find(&dramas)
```

**使用分页**:

```go
// 分页查询
page := 1
pageSize := 20
offset := (page - 1) * pageSize

db.Limit(pageSize).Offset(offset).Find(&dramas)
```

**预加载关联数据**:

```go
// 避免 N+1 查询
db.Preload("Scenes").Preload("Characters").Find(&dramas)
```

---

### 静态资源优化

#### 1. 使用 CDN

**配置 CDN**:

```javascript
// vite.config.ts
export default defineConfig({
  base: process.env.NODE_ENV === 'production' 
    ? 'https://cdn.example.com/' 
    : '/',
  build: {
    assetsDir: 'assets',
  }
})
```

**优势**:
- 减少服务器带宽
- 加快资源加载速度
- 提高全球访问速度

---

#### 2. 启用缓存

**Nginx 缓存配置**:

```nginx
# nginx.conf
location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}

location /api/ {
    # API 不缓存
    add_header Cache-Control "no-cache, no-store, must-revalidate";
}
```

**应用层缓存**:

```go
// 设置响应缓存头
c.Header("Cache-Control", "public, max-age=3600")
c.Header("ETag", generateETag(content))
```

---

#### 3. 图片优化

**压缩图片**:

```bash
# 使用 ImageMagick 压缩
convert input.jpg -quality 85 output.jpg

# 使用 FFmpeg 压缩
ffmpeg -i input.png -compression_level 9 output.png
```

**使用现代格式**:
- WebP: 比 JPEG 小 25-35%
- AVIF: 比 WebP 更小

**响应式图片**:

```html
<picture>
  <source srcset="image.webp" type="image/webp">
  <source srcset="image.jpg" type="image/jpeg">
  <img src="image.jpg" alt="描述">
</picture>
```

---

#### 4. 代码分割和懒加载

**Vue 路由懒加载**:

```javascript
// router/index.ts
const routes = [
  {
    path: '/drama',
    component: () => import('@/views/drama/DramaList.vue')
  }
]
```

**组件懒加载**:

```vue
<script setup>
import { defineAsyncComponent } from 'vue'

const HeavyComponent = defineAsyncComponent(() =>
  import('./HeavyComponent.vue')
)
</script>
```

---

### 并发处理优化

#### 1. 使用连接池

**数据库连接池**:

```go
// 配置数据库连接池
db.DB().SetMaxOpenConns(25)      // 最大打开连接数
db.DB().SetMaxIdleConns(10)      // 最大空闲连接数
db.DB().SetConnMaxLifetime(5 * time.Minute)  // 连接最大生命周期
```

**HTTP 客户端连接池**:

```go
// 配置 HTTP 客户端
client := &http.Client{
    Transport: &http.Transport{
        MaxIdleConns:        100,
        MaxIdleConnsPerHost: 10,
        IdleConnTimeout:     90 * time.Second,
    },
    Timeout: 30 * time.Second,
}
```

---

#### 2. Goroutine 管理

**使用 Worker Pool**:

```go
// 创建 worker pool
type WorkerPool struct {
    tasks   chan Task
    workers int
}

func NewWorkerPool(workers int) *WorkerPool {
    pool := &WorkerPool{
        tasks:   make(chan Task, 100),
        workers: workers,
    }
    
    // 启动 workers
    for i := 0; i < workers; i++ {
        go pool.worker()
    }
    
    return pool
}

func (p *WorkerPool) worker() {
    for task := range p.tasks {
        task.Execute()
    }
}

func (p *WorkerPool) Submit(task Task) {
    p.tasks <- task
}
```

**使用 context 控制超时**:

```go
ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
defer cancel()

result, err := processWithContext(ctx, data)
if err == context.DeadlineExceeded {
    log.Println("处理超时")
}
```

---

#### 3. 限流和熔断

**使用 rate limiter**:

```go
import "golang.org/x/time/rate"

// 创建限流器：每秒 10 个请求
limiter := rate.NewLimiter(10, 20)

// 在处理请求前检查
if !limiter.Allow() {
    c.JSON(429, gin.H{"error": "Too many requests"})
    return
}
```

**熔断器模式**:

```go
// 使用 hystrix 或类似库
import "github.com/afex/hystrix-go/hystrix"

hystrix.ConfigureCommand("ai_service", hystrix.CommandConfig{
    Timeout:               10000,  // 超时时间
    MaxConcurrentRequests: 100,    // 最大并发
    ErrorPercentThreshold: 50,     // 错误率阈值
})

err := hystrix.Do("ai_service", func() error {
    return callAIService()
}, func(err error) error {
    // 降级逻辑
    return useCachedResult()
})
```

---

## 总结

### 问题排查流程

1. **收集信息**:
   - 查看错误信息和日志
   - 确定问题发生的环境和条件
   - 记录复现步骤

2. **定位问题**:
   - 使用日志分析工具
   - 启用详细日志
   - 使用性能分析工具

3. **解决问题**:
   - 参考本文档的解决方案
   - 搜索类似问题
   - 咨询社区或维护者

4. **验证修复**:
   - 测试修复方案
   - 监控应用状态
   - 记录解决方案

### 性能优化检查清单

✅ **后端优化**:
- [ ] 数据库查询添加索引
- [ ] 使用连接池
- [ ] 异步处理耗时任务
- [ ] 启用缓存
- [ ] 限制并发数

✅ **前端优化**:
- [ ] 代码分割和懒加载
- [ ] 压缩和优化图片
- [ ] 使用 CDN
- [ ] 启用浏览器缓存
- [ ] 减少 HTTP 请求

✅ **部署优化**:
- [ ] 使用反向代理
- [ ] 启用 gzip 压缩
- [ ] 配置缓存策略
- [ ] 监控和告警
- [ ] 定期备份

💡 **最佳实践**: 性能优化是一个持续的过程，需要定期监控和调整。

---

[返回主页](../../README.md) | [部署指南](../03-deployment/docker.md)

