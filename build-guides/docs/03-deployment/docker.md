# Docker 容器化部署

本文档介绍如何使用 Docker 和 Docker Compose 部署 Huobao Drama AI 短剧生成平台。

## Docker 部署的优势

使用 Docker 进行容器化部署具有以下优势：

- **环境一致性**: 开发、测试、生产环境完全一致，避免"在我机器上能运行"的问题
- **简化部署**: 一条命令即可启动完整应用，无需手动配置环境
- **隔离性**: 应用运行在独立容器中，不影响宿主机环境
- **可移植性**: 可以在任何支持 Docker 的平台上运行
- **易于扩展**: 方便进行水平扩展和负载均衡
- **版本管理**: 通过镜像标签管理不同版本

## 前置要求

在开始之前，请确保已安装：

- **Docker**: 20.10+ 版本
- **Docker Compose**: 2.0+ 版本（Docker Desktop 已包含）

验证安装：

```bash
docker --version
docker-compose --version
```

## 准备工作

### 1. 复制 Docker 配置文件

将构建指南中的 Docker 配置文件复制到项目根目录：

```bash
# 进入项目根目录
cd huobao-drama

# 复制 Dockerfile
cp ../Analysis-huobao-drama/build-guides/docker/Dockerfile .

# 复制 docker-compose.yml
cp ../Analysis-huobao-drama/build-guides/docker/docker-compose.yml .

# 复制 .dockerignore
cp ../Analysis-huobao-drama/build-guides/docker/.dockerignore .
```

### 2. 创建环境变量文件

创建 `.env` 文件存储敏感配置信息：

```bash
# 在项目根目录创建 .env 文件
cat > .env << 'EOF'
# AI 服务配置
AI_API_KEY=your_openai_api_key_here
AI_ENDPOINT=https://api.openai.com/v1

# 图像生成服务配置
IMAGE_API_KEY=your_image_api_key_here
IMAGE_ENDPOINT=https://api.example.com

# 视频生成服务配置
VIDEO_API_KEY=your_video_api_key_here
VIDEO_ENDPOINT=https://api.example.com
EOF
```

⚠️ **重要**: 不要将 `.env` 文件提交到版本控制系统！确保 `.gitignore` 中包含 `.env`。

### 3. 创建数据目录

创建用于数据持久化的目录：

```bash
mkdir -p data uploads temp
```

## 构建 Docker 镜像

### 方式 1: 使用 docker build 命令

```bash
# 在项目根目录执行
docker build -t huobao-drama:latest .
```

构建过程说明：
- 第一阶段（builder）：编译后端 Go 代码和构建前端静态资源
- 第二阶段（runtime）：创建轻量级运行时镜像，仅包含必要的运行时依赖

构建时间：首次构建约 5-10 分钟（取决于网络速度）

### 方式 2: 使用 docker-compose 构建

```bash
docker-compose build
```

## 运行容器

### 方式 1: 使用 docker run 命令

```bash
docker run -d \
  --name huobao-drama \
  -p 8080:8080 \
  -v $(pwd)/data:/app/data \
  -v $(pwd)/uploads:/app/uploads \
  -v $(pwd)/temp:/app/temp \
  --env-file .env \
  --restart unless-stopped \
  huobao-drama:latest
```

参数说明：
- `-d`: 后台运行
- `--name`: 容器名称
- `-p 8080:8080`: 端口映射（宿主机:容器）
- `-v`: 卷挂载，持久化数据
- `--env-file`: 加载环境变量文件
- `--restart unless-stopped`: 自动重启策略

### 方式 2: 使用 docker-compose（推荐）

```bash
# 启动服务（后台运行）
docker-compose up -d

# 启动服务（前台运行，查看日志）
docker-compose up
```

## 访问应用

容器启动后，通过以下地址访问：

- **前端界面**: http://localhost:8080
- **API 接口**: http://localhost:8080/api/v1
- **健康检查**: http://localhost:8080/health

## 容器管理

### 查看容器状态

```bash
# 查看运行中的容器
docker ps

# 查看所有容器（包括停止的）
docker ps -a

# 使用 docker-compose 查看
docker-compose ps
```

### 查看容器日志

```bash
# 查看实时日志
docker logs -f huobao-drama

# 查看最近 100 行日志
docker logs --tail 100 huobao-drama

# 使用 docker-compose 查看
docker-compose logs -f huobao
```

### 进入容器调试

```bash
# 进入容器 shell
docker exec -it huobao-drama sh

# 在容器中执行命令
docker exec huobao-drama ls -la /app

# 使用 docker-compose
docker-compose exec huobao sh
```

在容器内可以执行的调试操作：
- 查看文件结构：`ls -la /app`
- 检查进程：`ps aux`
- 查看环境变量：`env`
- 测试 FFmpeg：`ffmpeg -version`

### 停止和启动容器

```bash
# 停止容器
docker stop huobao-drama

# 启动容器
docker start huobao-drama

# 重启容器
docker restart huobao-drama

# 使用 docker-compose
docker-compose stop
docker-compose start
docker-compose restart
```

### 删除容器

```bash
# 停止并删除容器
docker stop huobao-drama
docker rm huobao-drama

# 使用 docker-compose（同时删除网络和卷）
docker-compose down

# 删除容器和卷数据（谨慎使用！）
docker-compose down -v
```

## 数据持久化

### 卷挂载配置

Docker Compose 配置中已设置以下卷挂载：

```yaml
volumes:
  - ./data:/app/data        # 数据库文件
  - ./uploads:/app/uploads  # 上传文件
  - ./temp:/app/temp        # 临时文件
```

### 数据持久化的重要性

⚠️ **重要**: 如果不配置卷挂载，容器删除后所有数据将丢失！

确保数据持久化：
1. 使用卷挂载将数据目录映射到宿主机
2. 定期备份 `data/` 和 `uploads/` 目录
3. 不要使用 `docker-compose down -v` 删除卷数据

### 备份数据

```bash
# 备份数据库
cp data/huobao.db data/huobao.db.backup

# 备份上传文件
tar -czf uploads-backup.tar.gz uploads/

# 完整备份
tar -czf huobao-backup-$(date +%Y%m%d).tar.gz data/ uploads/
```

## 访问宿主机服务

如果需要访问宿主机上运行的服务（如 Ollama），有以下几种方式：

### 方式 1: 使用 extra_hosts（推荐，跨平台）

Docker Compose 配置中已包含：

```yaml
extra_hosts:
  - "host.docker.internal:host-gateway"
```

在 `.env` 文件中配置：

```bash
# 访问宿主机 Ollama 服务
AI_ENDPOINT=http://host.docker.internal:11434
```

### 方式 2: 使用 host 网络模式（仅 Linux）

修改 `docker-compose.yml`：

```yaml
services:
  huobao:
    network_mode: "host"
```

⚠️ **注意**: 
- `host` 网络模式仅在 Linux 上可用
- 使用 `host` 模式时，端口映射配置将被忽略
- 容器将直接使用宿主机网络

### 方式 3: 使用宿主机 IP 地址

获取宿主机 IP：

```bash
# Linux/macOS
ifconfig | grep "inet " | grep -v 127.0.0.1

# Windows
ipconfig
```

在 `.env` 文件中使用实际 IP：

```bash
AI_ENDPOINT=http://192.168.1.100:11434
```

## 更新和重启

### 更新应用

```bash
# 1. 拉取最新代码
git pull

# 2. 重新构建镜像
docker-compose build

# 3. 重启服务
docker-compose up -d

# 或者一条命令完成
docker-compose up -d --build
```

### 不停机更新（滚动更新）

```bash
# 1. 构建新镜像
docker-compose build

# 2. 创建新容器
docker-compose up -d --no-deps --build huobao

# 旧容器会自动停止并删除
```

## Docker 镜像加速（国内网络优化）

### 配置 Docker 镜像加速器

编辑 Docker 配置文件：

**Linux**:
```bash
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com",
    "https://mirror.ccs.tencentyun.com"
  ]
}
EOF

sudo systemctl daemon-reload
sudo systemctl restart docker
```

**macOS/Windows (Docker Desktop)**:
1. 打开 Docker Desktop 设置
2. 进入 "Docker Engine" 选项
3. 添加镜像加速器配置
4. 点击 "Apply & Restart"

### 配置 Go 和 npm 镜像

在 Dockerfile 中已包含镜像配置，如需修改可以编辑 Dockerfile：

```dockerfile
# Go 模块代理
ENV GOPROXY=https://goproxy.cn,direct

# npm 镜像
RUN npm config set registry https://registry.npmmirror.com
```

## 性能优化

### 资源限制

在 `docker-compose.yml` 中配置资源限制：

```yaml
deploy:
  resources:
    limits:
      cpus: '2.0'      # 最多使用 2 个 CPU 核心
      memory: 4G       # 最多使用 4GB 内存
    reservations:
      cpus: '0.5'      # 至少保留 0.5 个 CPU 核心
      memory: 512M     # 至少保留 512MB 内存
```

### 构建缓存优化

Dockerfile 已优化构建缓存：
- 先复制依赖文件（go.mod, package.json）
- 再复制源代码
- 利用 Docker 层缓存加速构建

### 多阶段构建优化

Dockerfile 使用多阶段构建：
- Builder 阶段：包含完整构建工具
- Runtime 阶段：仅包含运行时依赖
- 最终镜像大小约 100-200MB（相比单阶段构建减少 80%）

## 健康检查

### 容器健康检查

Dockerfile 中已配置健康检查：

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1
```

查看健康状态：

```bash
docker ps
# STATUS 列会显示健康状态：healthy 或 unhealthy
```

### 手动健康检查

```bash
# 检查健康端点
curl http://localhost:8080/health

# 在容器内检查
docker exec huobao-drama wget -O- http://localhost:8080/health
```

## 故障排查

### 容器无法启动

1. 查看容器日志：
```bash
docker logs huobao-drama
```

2. 检查端口占用：
```bash
# Linux/macOS
lsof -i :8080

# Windows
netstat -ano | findstr :8080
```

3. 检查卷挂载权限：
```bash
ls -la data/ uploads/ temp/
```

### 构建失败

1. 清理构建缓存：
```bash
docker builder prune -a
```

2. 重新构建：
```bash
docker-compose build --no-cache
```

3. 检查网络连接（依赖下载失败）：
```bash
# 测试 Go 代理
curl -I https://goproxy.cn

# 测试 npm 镜像
curl -I https://registry.npmmirror.com
```

### 容器运行但无法访问

1. 检查容器是否运行：
```bash
docker ps | grep huobao
```

2. 检查端口映射：
```bash
docker port huobao-drama
```

3. 检查防火墙设置：
```bash
# Linux
sudo ufw status

# 允许端口
sudo ufw allow 8080
```

### 数据丢失

如果数据丢失，检查：
1. 卷挂载配置是否正确
2. 是否使用了 `docker-compose down -v`
3. 宿主机目录权限是否正确

恢复数据：
```bash
# 从备份恢复
cp data/huobao.db.backup data/huobao.db
tar -xzf uploads-backup.tar.gz
```

## 生产环境建议

### 安全配置

1. **使用非 root 用户**: Dockerfile 已配置
2. **限制资源使用**: 配置 CPU 和内存限制
3. **定期更新镜像**: 及时更新基础镜像和依赖
4. **扫描漏洞**: 使用 `docker scan` 扫描镜像漏洞

```bash
docker scan huobao-drama:latest
```

### 监控和日志

1. **日志收集**: 使用 ELK、Loki 等日志系统
2. **监控指标**: 使用 Prometheus + Grafana
3. **告警配置**: 配置关键指标告警

### 备份策略

1. **定期备份**: 每天自动备份数据库和上传文件
2. **异地备份**: 将备份存储到云存储
3. **测试恢复**: 定期测试备份恢复流程

### 高可用部署

1. **负载均衡**: 使用 Nginx 或云负载均衡
2. **多实例部署**: 运行多个容器实例
3. **数据库分离**: 使用外部数据库（PostgreSQL/MySQL）

## 下一步

- [传统服务器部署](./traditional.md) - 了解非容器化部署方式
- [问题排查指南](../04-reference/troubleshooting.md) - 解决常见问题
- [性能优化](../04-reference/optimization.md) - 优化应用性能
