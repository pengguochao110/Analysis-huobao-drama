# 数据库管理

本文档介绍 Huobao Drama AI 短剧生成平台的数据库初始化、管理和维护操作。

## 目录

- [数据库概述](#数据库概述)
- [自动初始化](#自动初始化)
- [手动迁移](#手动迁移)
- [权限设置](#权限设置)
- [Docker 环境配置](#docker-环境配置)
- [数据库重置](#数据库重置)
- [备份与恢复](#备份与恢复)
- [常见问题](#常见问题)

---

## 数据库概述

Huobao Drama 使用 **SQLite** 作为默认数据库，这是一个轻量级、无需独立服务器的嵌入式数据库，非常适合中小型应用和开发环境。

### 技术栈

- **数据库**: SQLite 3
- **ORM 框架**: GORM
- **驱动**: modernc.org/sqlite (纯 Go 实现，无需 CGO)
- **数据库文件**: 单个 `.db` 文件

### 数据库特性

- ✅ **零配置**: 无需安装独立数据库服务器
- ✅ **自动初始化**: 应用首次启动时自动创建数据库和表结构
- ✅ **事务支持**: 支持 ACID 事务
- ✅ **并发优化**: 使用 WAL 模式提升并发性能
- ✅ **便于备份**: 单文件存储，备份简单

---

## 自动初始化

### 初始化机制

应用在首次启动时会自动执行以下操作：

1. **检查数据库目录**: 如果配置的数据库文件路径的目录不存在，自动创建目录
2. **创建数据库文件**: 如果数据库文件不存在，自动创建 SQLite 数据库文件
3. **执行表结构迁移**: 使用 GORM AutoMigrate 自动创建所有必需的数据表

### 数据库文件位置

数据库文件的位置由配置文件 `config.yaml` 中的 `database.path` 配置项决定：

```yaml
database:
  path: ./data/huobao.db
```

**默认位置**: `./data/huobao.db` (相对于应用运行目录)

### 自动创建的表结构

应用启动时会自动创建以下数据表：

#### 核心业务表
- `dramas` - 剧集信息
- `episodes` - 剧集分集
- `characters` - 角色信息
- `scenes` - 场景信息
- `storyboards` - 分镜脚本
- `frame_prompts` - 分镜提示词
- `props` - 道具信息

#### 生成任务表
- `image_generations` - 图片生成记录
- `video_generations` - 视频生成记录
- `video_merges` - 视频合成记录

#### 配置管理表
- `ai_service_configs` - AI 服务配置
- `ai_service_providers` - AI 服务提供商

#### 资源管理表
- `assets` - 资源文件管理
- `character_libraries` - 角色库

#### 任务管理表
- `async_tasks` - 异步任务队列

### 启动日志示例

应用启动时，您会看到类似以下的日志输出：

```
2024-01-20 10:30:15 INFO  Starting Drama Generator API Server...
2024-01-20 10:30:15 INFO  Database connected successfully
2024-01-20 10:30:16 INFO  Database tables migrated successfully
2024-01-20 10:30:16 INFO  🚀 Server starting...
```

如果看到 "Database tables migrated successfully"，说明数据库初始化成功。

---

## 手动迁移

### 使用迁移工具

项目提供了独立的数据迁移工具，用于执行数据清洗和迁移任务。

#### 迁移工具位置

```
huobao-drama/cmd/migrate/main.go
```

#### 执行迁移命令

```bash
# 进入后端目录
cd huobao-drama

# 执行迁移工具
go run cmd/migrate/main.go
```

#### 迁移工具功能

迁移工具主要用于以下场景：

1. **数据清洗**: 迁移 `local_path` 为空的历史数据
2. **资源本地化**: 将远程 URL 资源下载到本地存储
3. **数据修复**: 修复不一致的数据状态

#### 迁移输出示例

```
=== 数据清洗工具：迁移 local_path ===
开始时间: 2024-01-20 10:35:00

初始化日志系统...
配置加载成功
数据库连接成功
开始数据清洗：迁移 local_path 为空的数据
找到需要迁移的 assets: 15
找到需要迁移的 character_libraries: 8
...
数据清洗完成
总耗时: 2m30s
Assets成功: 15, Assets失败: 0
角色库成功: 8, 角色库失败: 0
...

=== 数据清洗完成 ===
结束时间: 2024-01-20 10:37:30
```

### 手动执行 SQL 迁移

如果需要执行自定义 SQL 迁移脚本，可以使用 SQLite 命令行工具：

```bash
# 连接到数据库
sqlite3 data/huobao.db

# 执行 SQL 命令
sqlite> .tables                    # 查看所有表
sqlite> .schema dramas             # 查看表结构
sqlite> SELECT COUNT(*) FROM dramas;  # 查询数据

# 执行 SQL 文件
sqlite> .read migrations/custom.sql

# 退出
sqlite> .quit
```

---

## 权限设置

### 为什么需要设置权限

SQLite 数据库文件需要应用程序具有**读写权限**才能正常工作。权限不足会导致以下错误：

- `unable to open database file`
- `attempt to write a readonly database`
- `database is locked`

### Linux/macOS 权限设置

#### 设置数据库文件权限

```bash
# 设置数据库文件为可读写（644）
chmod 644 data/huobao.db

# 或者设置为完全权限（666，不推荐生产环境）
chmod 666 data/huobao.db
```

#### 设置数据库目录权限

```bash
# 设置目录权限（755）
chmod 755 data/

# 确保目录所有者正确
chown -R your-user:your-group data/
```

#### 推荐的权限配置

```bash
# 开发环境
chmod 755 data/
chmod 644 data/huobao.db

# 生产环境（使用专用用户）
chown -R huobao:huobao data/
chmod 750 data/
chmod 640 data/huobao.db
```

### Windows 权限设置

#### 使用文件资源管理器

1. 右键点击 `data` 文件夹
2. 选择 "属性" → "安全" 选项卡
3. 点击 "编辑" 按钮
4. 选择当前用户或应用运行用户
5. 勾选 "完全控制" 或至少 "修改" 权限
6. 点击 "应用" 和 "确定"

#### 使用命令行 (PowerShell)

```powershell
# 授予当前用户完全控制权限
icacls data /grant ${env:USERNAME}:F /T

# 授予特定用户权限
icacls data /grant "DOMAIN\username:F" /T
```

### Docker 环境权限

在 Docker 容器中，权限问题通常由用户 ID 不匹配引起。参见 [Docker 环境配置](#docker-环境配置) 章节。

---

## Docker 环境配置

### 数据持久化

在 Docker 环境中，数据库文件必须通过**卷挂载**持久化到宿主机，否则容器重启后数据会丢失。

### docker-compose.yml 配置

```yaml
version: '3.8'

services:
  huobao:
    image: huobao-drama:latest
    container_name: huobao-drama
    ports:
      - "8080:8080"
    volumes:
      # 数据库文件持久化
      - ./data:/app/data
      # 上传文件持久化
      - ./uploads:/app/uploads
      # 临时文件持久化（可选）
      - ./temp:/app/temp
    environment:
      - AI_API_KEY=${AI_API_KEY}
    restart: unless-stopped
```

### 卷挂载说明

| 容器路径 | 宿主机路径 | 说明 |
|---------|-----------|------|
| `/app/data` | `./data` | 数据库文件目录 |
| `/app/uploads` | `./uploads` | 用户上传文件 |
| `/app/temp` | `./temp` | 临时文件（可选） |

### 权限问题解决

#### 方法 1: 使用命名卷

```yaml
volumes:
  huobao-data:
    driver: local

services:
  huobao:
    volumes:
      - huobao-data:/app/data
```

#### 方法 2: 设置容器用户

```yaml
services:
  huobao:
    user: "${UID}:${GID}"
    volumes:
      - ./data:/app/data
```

然后在启动前设置环境变量：

```bash
export UID=$(id -u)
export GID=$(id -g)
docker-compose up -d
```

#### 方法 3: 预创建目录并设置权限

```bash
# 创建目录
mkdir -p data uploads temp

# 设置权限（允许容器写入）
chmod 777 data uploads temp

# 启动容器
docker-compose up -d

# 启动后可以调整权限
chmod 755 data uploads temp
```

### 验证数据持久化

```bash
# 进入容器
docker exec -it huobao-drama sh

# 检查数据库文件
ls -la /app/data/huobao.db

# 检查数据库内容
sqlite3 /app/data/huobao.db "SELECT COUNT(*) FROM dramas;"

# 退出容器
exit
```

---

## 数据库重置

### 何时需要重置数据库

- 开发环境需要清空测试数据
- 数据库结构发生重大变更
- 数据库文件损坏
- 需要从头开始测试

⚠️ **警告**: 重置数据库会**永久删除所有数据**，请谨慎操作！

### 重置步骤

#### 方法 1: 删除数据库文件

```bash
# 停止应用
# Ctrl+C 或 kill 进程

# 删除数据库文件
rm data/huobao.db

# 重新启动应用（会自动创建新数据库）
go run main.go
```

#### 方法 2: 使用脚本重置

```bash
#!/bin/bash
# reset-database.sh

echo "⚠️  警告：即将删除数据库，所有数据将丢失！"
read -p "确认继续？(yes/no): " confirm

if [ "$confirm" = "yes" ]; then
    echo "停止应用..."
    # 根据实际情况停止应用
    # pkill -f "go run main.go"
    
    echo "删除数据库文件..."
    rm -f data/huobao.db
    
    echo "删除上传文件（可选）..."
    # rm -rf uploads/*
    
    echo "✅ 数据库已重置"
    echo "请重新启动应用"
else
    echo "❌ 操作已取消"
fi
```

#### 方法 3: Docker 环境重置

```bash
# 停止并删除容器
docker-compose down

# 删除数据卷中的数据库文件
rm data/huobao.db

# 重新启动容器
docker-compose up -d
```

### 重置后验证

```bash
# 启动应用后检查日志
# 应该看到 "Database tables migrated successfully"

# 检查数据库文件是否重新创建
ls -lh data/huobao.db

# 连接数据库验证表结构
sqlite3 data/huobao.db ".tables"
```

---

## 备份与恢复

### 为什么需要备份

- 防止数据丢失
- 版本升级前保护数据
- 迁移到新服务器
- 灾难恢复

### 备份策略

#### 手动备份

```bash
# 创建备份目录
mkdir -p backups

# 备份数据库文件（带时间戳）
cp data/huobao.db backups/huobao_$(date +%Y%m%d_%H%M%S).db

# 备份上传文件
tar -czf backups/uploads_$(date +%Y%m%d_%H%M%S).tar.gz uploads/
```

#### 自动备份脚本

```bash
#!/bin/bash
# backup-database.sh

BACKUP_DIR="backups"
DB_FILE="data/huobao.db"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/huobao_${TIMESTAMP}.db"

# 创建备份目录
mkdir -p ${BACKUP_DIR}

# 备份数据库
echo "开始备份数据库..."
cp ${DB_FILE} ${BACKUP_FILE}

# 压缩备份文件
gzip ${BACKUP_FILE}

echo "✅ 备份完成: ${BACKUP_FILE}.gz"

# 清理 7 天前的备份
find ${BACKUP_DIR} -name "huobao_*.db.gz" -mtime +7 -delete
echo "✅ 已清理 7 天前的旧备份"
```

#### 定时备份 (Cron)

```bash
# 编辑 crontab
crontab -e

# 添加定时任务（每天凌晨 2 点备份）
0 2 * * * /path/to/backup-database.sh >> /var/log/huobao-backup.log 2>&1
```

### 恢复数据库

#### 从备份恢复

```bash
# 停止应用
# Ctrl+C 或 kill 进程

# 解压备份文件（如果已压缩）
gunzip backups/huobao_20240120_020000.db.gz

# 恢复数据库文件
cp backups/huobao_20240120_020000.db data/huobao.db

# 设置权限
chmod 644 data/huobao.db

# 重新启动应用
go run main.go
```

#### Docker 环境恢复

```bash
# 停止容器
docker-compose down

# 恢复数据库文件
cp backups/huobao_20240120_020000.db data/huobao.db

# 重新启动容器
docker-compose up -d
```

### 验证恢复

```bash
# 连接数据库
sqlite3 data/huobao.db

# 检查数据
sqlite> SELECT COUNT(*) FROM dramas;
sqlite> SELECT * FROM dramas LIMIT 5;
sqlite> .quit
```

### 备份最佳实践

1. **定期备份**: 建议每天至少备份一次
2. **多地存储**: 将备份文件存储到不同位置（本地 + 云存储）
3. **测试恢复**: 定期测试备份文件是否可以成功恢复
4. **保留策略**: 
   - 每日备份保留 7 天
   - 每周备份保留 4 周
   - 每月备份保留 12 个月
5. **加密备份**: 生产环境的备份文件应该加密存储

---

## 常见问题

### 1. 数据库文件无法创建

**错误信息**:
```
Failed to connect to database: unable to open database file
```

**原因**: 数据库目录不存在或没有写入权限

**解决方案**:
```bash
# 创建目录
mkdir -p data

# 设置权限
chmod 755 data/
```

### 2. 数据库被锁定

**错误信息**:
```
database is locked
```

**原因**: 
- 另一个进程正在访问数据库
- 应用异常退出未释放连接
- SQLite 并发写入限制

**解决方案**:
```bash
# 检查是否有其他进程在使用数据库
lsof data/huobao.db

# 杀死占用进程
kill -9 <PID>

# 或者删除锁文件
rm data/huobao.db-shm
rm data/huobao.db-wal
```

### 3. 表结构不匹配

**错误信息**:
```
Error 1054: Unknown column 'xxx' in 'field list'
```

**原因**: 代码中的模型结构与数据库表结构不一致

**解决方案**:
```bash
# 方法 1: 重置数据库（会丢失数据）
rm data/huobao.db
go run main.go

# 方法 2: 手动执行迁移
go run cmd/migrate/main.go
```

### 4. 数据库文件过大

**症状**: 数据库文件占用空间过大，性能下降

**解决方案**:
```bash
# 连接数据库
sqlite3 data/huobao.db

# 清理已删除的数据，回收空间
sqlite> VACUUM;

# 分析并优化查询
sqlite> ANALYZE;

# 退出
sqlite> .quit
```

### 5. Docker 容器中权限错误

**错误信息**:
```
unable to open database file
Permission denied
```

**解决方案**:
```bash
# 方法 1: 设置宿主机目录权限
chmod 777 data/

# 方法 2: 使用命名卷
# 在 docker-compose.yml 中使用命名卷而不是绑定挂载

# 方法 3: 设置容器用户
# 在 docker-compose.yml 中添加 user: "${UID}:${GID}"
```

### 6. 迁移工具执行失败

**错误信息**:
```
Failed to migrate database: ...
```

**解决方案**:
```bash
# 检查配置文件是否存在
ls -la config.yaml

# 检查数据库连接
sqlite3 data/huobao.db ".tables"

# 查看详细错误日志
go run cmd/migrate/main.go 2>&1 | tee migrate.log
```

---

## 相关文档

- [配置详解](configuration.md) - 数据库配置说明
- [开发模式](dev-mode.md) - 开发环境启动
- [Docker 部署](../03-deployment/docker.md) - Docker 环境配置
- [问题排查](../04-reference/troubleshooting.md) - 更多问题解决方案

---

**提示**: 如果遇到本文档未涵盖的问题，请查看应用日志或提交 Issue 寻求帮助。
