# 配置详解

本文档详细说明 Huobao Drama AI 短剧生成平台的配置文件结构、配置项含义以及不同场景下的配置方法。

## 配置文件准备

### 复制配置模板

项目提供了配置文件模板 `config.example.yaml`，首次使用时需要将其复制到项目根目录并重命名：

```bash
# 进入项目目录
cd huobao-drama

# 复制配置模板
cp ../Analysis-huobao-drama/build-guides/config/config.example.yaml ./config.yaml
```

ℹ️ **提示**: 配置文件 `config.yaml` 已添加到 `.gitignore`，不会被提交到版本控制系统，确保敏感信息安全。

### 配置文件位置

应用启动时会按以下顺序查找配置文件：

1. 命令行参数指定的路径: `./huobao-server --config=/path/to/config.yaml`
2. 当前工作目录: `./config.yaml`
3. 配置目录: `./configs/config.yaml`
4. 用户主目录: `~/.huobao/config.yaml`

## 配置加载优先级

配置系统支持多层级配置，优先级从高到低：

```
环境变量 > 配置文件 > 默认值
```

**示例**:
```yaml
# config.yaml 中配置
ai:
  api_key: ${AI_API_KEY}  # 引用环境变量
  endpoint: https://api.openai.com/v1
```

```bash
# 环境变量会覆盖配置文件中的值
export AI_API_KEY="sk-your-actual-api-key"
export AI_ENDPOINT="https://custom-endpoint.com"  # 覆盖配置文件
```

## 核心配置项详解

### 数据库配置

```yaml
database:
  path: ./data/huobao.db
```

**配置说明**:
- `path`: SQLite 数据库文件路径
  - 相对路径: 相对于应用工作目录
  - 绝对路径: 推荐用于生产环境
  - 确保目录存在且有读写权限

**开发环境示例**:
```yaml
database:
  path: ./data/dev.db
```

**生产环境示例**:
```yaml
database:
  path: /var/lib/huobao/production.db
```

⚠️ **注意**: 
- 首次启动时会自动创建数据库文件
- 确保数据库文件所在目录有写入权限
- 生产环境建议定期备份数据库文件

### 存储配置

```yaml
storage:
  upload_dir: ./uploads
  temp_dir: ./temp
```

**配置说明**:
- `upload_dir`: 用户上传文件的存储目录
  - 存储剧本、音频、图片等持久化文件
  - 需要足够的磁盘空间
- `temp_dir`: 临时文件目录
  - 存储视频生成过程中的中间文件
  - 可定期清理

**开发环境示例**:
```yaml
storage:
  upload_dir: ./uploads
  temp_dir: ./temp
```

**生产环境示例**:
```yaml
storage:
  upload_dir: /data/huobao/uploads
  temp_dir: /tmp/huobao
```

**Docker 环境示例**:
```yaml
storage:
  upload_dir: /app/uploads    # 映射到宿主机卷
  temp_dir: /app/temp         # 映射到宿主机卷
```

💡 **最佳实践**:
- 生产环境使用独立的数据分区
- 定期监控磁盘使用情况
- 配置临时文件自动清理策略

### AI 服务配置

```yaml
ai:
  provider: openai
  api_key: ${AI_API_KEY}
  endpoint: https://api.openai.com/v1
  model: gpt-4
  timeout: 60
  max_retries: 3
```

**配置说明**:
- `provider`: AI 服务提供商
  - `openai`: OpenAI GPT 系列
  - `gemini`: Google Gemini
  - `ollama`: 本地 Ollama 服务
- `api_key`: API 密钥（必需）
- `endpoint`: API 服务端点 URL
- `model`: 使用的模型名称
- `timeout`: 请求超时时间（秒）
- `max_retries`: 失败重试次数

**OpenAI 配置示例**:
```yaml
ai:
  provider: openai
  api_key: ${OPENAI_API_KEY}
  endpoint: https://api.openai.com/v1
  model: gpt-4
```

**Gemini 配置示例**:
```yaml
ai:
  provider: gemini
  api_key: ${GEMINI_API_KEY}
  endpoint: https://generativelanguage.googleapis.com/v1
  model: gemini-pro
```

**Ollama 本地服务示例**:
```yaml
ai:
  provider: ollama
  api_key: ""  # 本地服务不需要密钥
  endpoint: http://localhost:11434/v1
  model: llama2
```

**国内镜像服务示例**:
```yaml
ai:
  provider: openai
  api_key: ${AI_API_KEY}
  endpoint: https://api.openai-proxy.com/v1  # 使用代理服务
  model: gpt-3.5-turbo
```

### 图片生成服务配置

```yaml
image:
  provider: openai
  api_key: ${IMAGE_API_KEY}
  endpoint: https://api.openai.com/v1
  default_size: 1024x1024
  default_quality: standard
```

**配置说明**:
- `provider`: 图片生成服务提供商
  - `openai`: DALL-E
  - `gemini`: Imagen
  - `volcengine`: 火山引擎
- `default_size`: 默认图片尺寸
  - OpenAI: `1024x1024`, `1792x1024`, `1024x1792`
- `default_quality`: 图片质量
  - `standard`: 标准质量
  - `hd`: 高清质量

**不同提供商配置示例**:

```yaml
# OpenAI DALL-E
image:
  provider: openai
  api_key: ${OPENAI_API_KEY}
  endpoint: https://api.openai.com/v1
  default_size: 1024x1024
  default_quality: hd

# 火山引擎
image:
  provider: volcengine
  api_key: ${VOLC_API_KEY}
  endpoint: https://visual.volcengineapi.com
  default_size: 1024x1024
```

### 视频生成服务配置

```yaml
video:
  provider: minimax
  api_key: ${VIDEO_API_KEY}
  endpoint: https://api.minimax.chat/v1
  default_resolution: 1280x720
  default_duration: 5
```

**配置说明**:
- `provider`: 视频生成服务提供商
  - `minimax`: MiniMax 视频生成
  - `chatfire`: ChatFire
  - `openai_sora`: OpenAI Sora
  - `volces_ark`: 火山引擎方舟
- `default_resolution`: 默认视频分辨率
- `default_duration`: 默认视频时长（秒）

**不同提供商配置示例**:

```yaml
# MiniMax
video:
  provider: minimax
  api_key: ${MINIMAX_API_KEY}
  endpoint: https://api.minimax.chat/v1
  default_resolution: 1280x720

# OpenAI Sora
video:
  provider: openai_sora
  api_key: ${OPENAI_API_KEY}
  endpoint: https://api.openai.com/v1
  default_resolution: 1920x1080
```

### FFmpeg 配置

```yaml
ffmpeg:
  path: /usr/bin/ffmpeg
  ffprobe_path: /usr/bin/ffprobe
```

**配置说明**:
- `path`: FFmpeg 可执行文件的完整路径
- `ffprobe_path`: FFprobe 可执行文件路径（用于获取媒体信息）

**不同操作系统配置**:

```yaml
# Windows
ffmpeg:
  path: C:/ffmpeg/bin/ffmpeg.exe
  ffprobe_path: C:/ffmpeg/bin/ffprobe.exe

# macOS (Homebrew)
ffmpeg:
  path: /opt/homebrew/bin/ffmpeg
  ffprobe_path: /opt/homebrew/bin/ffprobe

# Linux (apt)
ffmpeg:
  path: /usr/bin/ffmpeg
  ffprobe_path: /usr/bin/ffprobe

# Docker
ffmpeg:
  path: /usr/local/bin/ffmpeg
  ffprobe_path: /usr/local/bin/ffprobe
```

**验证 FFmpeg 路径**:
```bash
# 查找 FFmpeg 安装位置
which ffmpeg
# 或
where ffmpeg  # Windows

# 验证 FFmpeg 可用性
ffmpeg -version
```

### 服务器配置

```yaml
server:
  port: 8080
  host: 0.0.0.0
  mode: development
  cors:
    enabled: true
    allowed_origins:
      - http://localhost:5173
```

**配置说明**:
- `port`: HTTP 服务监听端口
- `host`: 监听地址
  - `0.0.0.0`: 监听所有网络接口
  - `127.0.0.1`: 仅监听本地
- `mode`: 运行模式
  - `development`: 开发模式（详细日志、调试信息）
  - `production`: 生产模式（性能优化、错误处理）
- `cors`: 跨域资源共享配置

**开发环境配置**:
```yaml
server:
  port: 8080
  host: 127.0.0.1  # 仅本地访问
  mode: development
  cors:
    enabled: true
    allowed_origins:
      - http://localhost:5173  # 前端开发服务器
      - http://localhost:3000
```

**生产环境配置**:
```yaml
server:
  port: 8080
  host: 0.0.0.0  # 允许外部访问
  mode: production
  cors:
    enabled: true
    allowed_origins:
      - https://yourdomain.com
      - https://www.yourdomain.com
```

**Docker 环境配置**:
```yaml
server:
  port: 8080
  host: 0.0.0.0  # 容器内必须监听所有接口
  mode: production
```

### 日志配置

```yaml
logging:
  level: info
  format: text
  output: stdout
```

**配置说明**:
- `level`: 日志级别
  - `debug`: 调试信息（最详细）
  - `info`: 一般信息
  - `warn`: 警告信息
  - `error`: 错误信息（最简洁）
- `format`: 日志格式
  - `text`: 文本格式（易读）
  - `json`: JSON 格式（便于日志收集）
- `output`: 输出位置
  - `stdout`: 标准输出
  - `file`: 文件

**开发环境配置**:
```yaml
logging:
  level: debug
  format: text
  output: stdout
```

**生产环境配置**:
```yaml
logging:
  level: info
  format: json
  output: file
  file_path: /var/log/huobao/app.log
  max_size: 100
  max_backups: 10
  max_age: 30
```

## 敏感信息管理

### 使用环境变量

配置文件中的敏感信息（如 API 密钥）应使用环境变量引用：

**配置文件**:
```yaml
ai:
  api_key: ${AI_API_KEY}
  
image:
  api_key: ${IMAGE_API_KEY}
  
video:
  api_key: ${VIDEO_API_KEY}
```

**设置环境变量**:

```bash
# Linux/macOS
export AI_API_KEY="sk-your-openai-key"
export IMAGE_API_KEY="sk-your-image-key"
export VIDEO_API_KEY="your-video-key"

# 永久设置（添加到 ~/.bashrc 或 ~/.zshrc）
echo 'export AI_API_KEY="sk-your-openai-key"' >> ~/.bashrc
source ~/.bashrc

# Windows (PowerShell)
$env:AI_API_KEY="sk-your-openai-key"
$env:IMAGE_API_KEY="sk-your-image-key"

# Windows 永久设置
setx AI_API_KEY "sk-your-openai-key"
```

### 使用 .env 文件

创建 `.env` 文件存储环境变量（确保添加到 `.gitignore`）：

```bash
# .env
AI_API_KEY=sk-your-openai-key
IMAGE_API_KEY=sk-your-image-key
VIDEO_API_KEY=your-video-key
```

加载 .env 文件：
```bash
# 使用 source 命令
source .env

# 或使用 export
export $(cat .env | xargs)
```

### Docker 环境变量

**docker-compose.yml**:
```yaml
services:
  huobao:
    environment:
      - AI_API_KEY=${AI_API_KEY}
      - IMAGE_API_KEY=${IMAGE_API_KEY}
      - VIDEO_API_KEY=${VIDEO_API_KEY}
    env_file:
      - .env  # 从文件加载环境变量
```

**docker run 命令**:
```bash
docker run -d \
  -e AI_API_KEY="sk-your-key" \
  -e IMAGE_API_KEY="sk-your-image-key" \
  --env-file .env \
  huobao-drama
```

## 配置验证

### 启动时自动验证

应用启动时会自动验证配置的有效性：

```bash
./huobao-server

# 输出示例
[INFO] Loading configuration from: ./config.yaml
[INFO] Validating configuration...
[OK]   Database path is valid: ./data/huobao.db
[OK]   Storage directories exist
[OK]   FFmpeg is available: /usr/bin/ffmpeg
[OK]   AI service configuration is valid
[INFO] Configuration loaded successfully
[INFO] Server starting on http://0.0.0.0:8080
```

### 手动验证配置

**验证配置文件语法**:
```bash
# 使用 yamllint（需要安装）
yamllint config.yaml

# 或使用 Python
python -c "import yaml; yaml.safe_load(open('config.yaml'))"
```

**验证 FFmpeg 可用性**:
```bash
# 测试 FFmpeg 命令
ffmpeg -version

# 测试配置文件中的路径
/usr/bin/ffmpeg -version
```

**验证 AI 服务连接**:
```bash
# 测试 API 连接（使用 curl）
curl -H "Authorization: Bearer $AI_API_KEY" \
     https://api.openai.com/v1/models
```

**验证目录权限**:
```bash
# 检查目录是否存在且可写
test -w ./data && echo "Database directory is writable" || echo "Permission denied"
test -w ./uploads && echo "Upload directory is writable" || echo "Permission denied"
```

### 配置检查清单

启动应用前，确认以下配置项：

- [ ] 数据库路径存在且有读写权限
- [ ] 上传目录和临时目录存在且有写入权限
- [ ] AI 服务 API 密钥已设置且有效
- [ ] FFmpeg 路径正确且可执行
- [ ] 服务器端口未被占用
- [ ] 跨域配置包含前端地址
- [ ] 日志目录存在（如果使用文件日志）

## 不同场景配置示例

### 场景 1: 本地开发环境

```yaml
database:
  path: ./data/dev.db

storage:
  upload_dir: ./uploads
  temp_dir: ./temp

ai:
  provider: ollama
  api_key: ""
  endpoint: http://localhost:11434/v1
  model: llama2

ffmpeg:
  path: /usr/local/bin/ffmpeg

server:
  port: 8080
  host: 127.0.0.1
  mode: development

logging:
  level: debug
  format: text
  output: stdout
```

### 场景 2: 生产环境（云服务）

```yaml
database:
  path: /var/lib/huobao/production.db

storage:
  upload_dir: /data/huobao/uploads
  temp_dir: /tmp/huobao

ai:
  provider: openai
  api_key: ${AI_API_KEY}
  endpoint: https://api.openai.com/v1
  model: gpt-4

image:
  provider: openai
  api_key: ${IMAGE_API_KEY}
  endpoint: https://api.openai.com/v1

video:
  provider: minimax
  api_key: ${VIDEO_API_KEY}
  endpoint: https://api.minimax.chat/v1

ffmpeg:
  path: /usr/bin/ffmpeg

server:
  port: 8080
  host: 0.0.0.0
  mode: production
  cors:
    enabled: true
    allowed_origins:
      - https://yourdomain.com

logging:
  level: info
  format: json
  output: file
  file_path: /var/log/huobao/app.log
  max_size: 100
  max_backups: 10
```

### 场景 3: Docker 容器部署

```yaml
database:
  path: /app/data/huobao.db

storage:
  upload_dir: /app/uploads
  temp_dir: /app/temp

ai:
  provider: openai
  api_key: ${AI_API_KEY}
  endpoint: https://api.openai.com/v1
  model: gpt-4

ffmpeg:
  path: /usr/local/bin/ffmpeg

server:
  port: 8080
  host: 0.0.0.0
  mode: production

logging:
  level: info
  format: json
  output: stdout
```

### 场景 4: 国内网络环境

```yaml
ai:
  provider: openai
  api_key: ${AI_API_KEY}
  endpoint: https://api.openai-proxy.com/v1  # 使用代理
  model: gpt-3.5-turbo
  timeout: 120  # 增加超时时间
  max_retries: 5  # 增加重试次数

image:
  provider: volcengine  # 使用国内服务
  api_key: ${VOLC_API_KEY}
  endpoint: https://visual.volcengineapi.com

video:
  provider: minimax  # 使用国内服务
  api_key: ${MINIMAX_API_KEY}
  endpoint: https://api.minimax.chat/v1
```

## 常见配置问题

### 问题 1: 配置文件未找到

**错误信息**:
```
Error: configuration file not found: config.yaml
```

**解决方案**:
```bash
# 检查配置文件是否存在
ls -la config.yaml

# 如果不存在，从模板复制
cp ../Analysis-huobao-drama/build-guides/config/config.example.yaml ./config.yaml
```

### 问题 2: 环境变量未设置

**错误信息**:
```
Error: AI_API_KEY is required but not set
```

**解决方案**:
```bash
# 设置环境变量
export AI_API_KEY="your-api-key"

# 或在配置文件中直接设置（不推荐用于生产环境）
ai:
  api_key: "your-api-key"
```

### 问题 3: FFmpeg 路径错误

**错误信息**:
```
Error: ffmpeg not found at path: /usr/bin/ffmpeg
```

**解决方案**:
```bash
# 查找 FFmpeg 实际路径
which ffmpeg

# 更新配置文件中的路径
ffmpeg:
  path: /opt/homebrew/bin/ffmpeg  # 使用实际路径
```

### 问题 4: 端口被占用

**错误信息**:
```
Error: bind: address already in use
```

**解决方案**:
```bash
# 查找占用端口的进程
lsof -i :8080  # macOS/Linux
netstat -ano | findstr :8080  # Windows

# 修改配置文件使用其他端口
server:
  port: 8081
```

### 问题 5: 数据库权限错误

**错误信息**:
```
Error: unable to open database file: permission denied
```

**解决方案**:
```bash
# 创建数据库目录
mkdir -p ./data

# 设置正确的权限
chmod 755 ./data
chmod 644 ./data/huobao.db  # 如果文件已存在
```

## 配置更新和热重载

### 开发模式

开发模式下，某些配置项支持热重载（无需重启服务）：

- 日志级别
- CORS 配置
- 速率限制配置

修改配置后，应用会自动检测并重新加载。

### 生产模式

生产模式下，配置更改需要重启服务：

```bash
# systemd 服务
sudo systemctl restart huobao

# Docker
docker-compose restart

# 手动运行
# 停止当前进程（Ctrl+C）然后重新启动
./huobao-server
```

## 配置最佳实践

1. **使用环境变量管理敏感信息**: 永远不要在配置文件中硬编码 API 密钥
2. **区分环境配置**: 为开发、测试、生产环境维护不同的配置文件
3. **版本控制**: 将 `config.example.yaml` 纳入版本控制，但排除 `config.yaml`
4. **文档化自定义配置**: 记录项目特定的配置要求和推荐值
5. **定期审查配置**: 定期检查配置是否符合当前需求和最佳实践
6. **备份配置文件**: 在修改配置前备份当前配置
7. **验证后部署**: 在测试环境验证配置更改后再应用到生产环境

## 下一步

配置完成后，您可以：

- [启动开发模式](dev-mode.md) - 开始本地开发
- [数据库管理](database.md) - 了解数据库初始化和管理
- [生产构建](../03-deployment/production-build.md) - 准备生产部署
