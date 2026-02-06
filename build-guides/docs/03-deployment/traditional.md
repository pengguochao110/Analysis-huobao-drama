# 传统服务器部署指南

本文档提供在传统 Linux 和 Windows 服务器上部署 Huobao Drama AI 短剧生成平台的完整指南。

## 目录

- [Linux 服务器部署](#linux-服务器部署)
  - [前置准备](#前置准备)
  - [创建专用用户](#创建专用用户)
  - [部署应用文件](#部署应用文件)
  - [配置 systemd 服务](#配置-systemd-服务)
  - [配置 Nginx 反向代理](#配置-nginx-反向代理)
  - [配置 SSL/TLS 证书](#配置-ssltls-证书)
  - [日志管理](#日志管理)
- [Windows 服务器部署](#windows-服务器部署)
- [服务管理](#服务管理)
- [监控和维护](#监控和维护)

---

## Linux 服务器部署

### 前置准备

在开始部署前，确保服务器满足以下要求：

**系统要求**：
- 操作系统：Ubuntu 20.04+, CentOS 8+, Debian 11+ 或其他主流 Linux 发行版
- CPU：2 核心以上
- 内存：4GB 以上（推荐 8GB）
- 磁盘：20GB 以上可用空间（根据数据量调整）

**必需软件**：
- FFmpeg 4.4+
- Nginx 或其他反向代理服务器
- systemd（大多数现代 Linux 发行版默认包含）

**安装 FFmpeg**：

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install ffmpeg

# CentOS/RHEL
sudo yum install epel-release
sudo yum install ffmpeg

# 验证安装
ffmpeg -version
```

**安装 Nginx**：

```bash
# Ubuntu/Debian
sudo apt install nginx

# CentOS/RHEL
sudo yum install nginx

# 启动 Nginx
sudo systemctl start nginx
sudo systemctl enable nginx
```

---

### 创建专用用户

为了提高安全性，建议创建专用的系统用户来运行应用：

```bash
# 创建系统用户（不创建家目录，不允许登录）
sudo useradd -r -s /bin/false huobao

# 或者创建普通用户（如果需要登录管理）
sudo useradd -m -s /bin/bash huobao
```

**说明**：
- `-r`：创建系统用户
- `-s /bin/false`：禁止登录（提高安全性）
- `-m`：创建家目录（如果需要）

---

### 部署应用文件

#### 1. 创建部署目录

```bash
# 创建应用目录
sudo mkdir -p /opt/huobao
sudo mkdir -p /opt/huobao/data
sudo mkdir -p /opt/huobao/uploads
sudo mkdir -p /opt/huobao/temp
sudo mkdir -p /opt/huobao/logs

# 如果部署前端静态文件
sudo mkdir -p /opt/huobao/web/dist
```

#### 2. 上传构建产物

**方法一：使用 scp 上传**

在本地开发机器上执行：

```bash
# 上传后端可执行文件
scp huobao-server user@server-ip:/tmp/

# 上传配置文件
scp config.yaml user@server-ip:/tmp/

# 上传前端构建产物（整个 dist 目录）
scp -r web/dist/* user@server-ip:/tmp/web-dist/
```

在服务器上移动文件到部署目录：

```bash
# 移动后端文件
sudo mv /tmp/huobao-server /opt/huobao/
sudo mv /tmp/config.yaml /opt/huobao/

# 移动前端文件
sudo mv /tmp/web-dist/* /opt/huobao/web/dist/
```

**方法二：使用 rsync 同步**

```bash
# 同步后端文件
rsync -avz huobao-server user@server-ip:/tmp/

# 同步前端文件
rsync -avz web/dist/ user@server-ip:/tmp/web-dist/
```

#### 3. 设置文件权限

```bash
# 设置所有者
sudo chown -R huobao:huobao /opt/huobao

# 设置可执行文件权限
sudo chmod +x /opt/huobao/huobao-server

# 设置配置文件权限（只读）
sudo chmod 640 /opt/huobao/config.yaml

# 设置数据目录权限（读写）
sudo chmod 755 /opt/huobao/data
sudo chmod 755 /opt/huobao/uploads
sudo chmod 755 /opt/huobao/temp

# 设置日志目录权限
sudo chmod 755 /opt/huobao/logs
```

**权限说明**：
- `755`：所有者可读写执行，其他用户可读执行
- `640`：所有者可读写，组用户可读，其他用户无权限
- `+x`：添加可执行权限

#### 4. 创建环境变量文件

```bash
# 创建环境变量文件
sudo nano /opt/huobao/.env
```

添加以下内容（根据实际情况修改）：

```bash
# 运行环境
GO_ENV=production
GIN_MODE=release

# AI 服务配置
AI_API_KEY=your-api-key-here
AI_ENDPOINT=https://api.example.com

# 其他敏感配置
# DATABASE_PASSWORD=your-password
```

设置权限：

```bash
# 只有所有者可读写
sudo chmod 600 /opt/huobao/.env
sudo chown huobao:huobao /opt/huobao/.env
```

---

### 配置 systemd 服务

#### 1. 复制服务配置文件

从构建指南目录复制 systemd 服务配置：

```bash
# 复制服务配置文件
sudo cp build-guides/deploy/huobao.service /etc/systemd/system/

# 或者手动创建
sudo nano /etc/systemd/system/huobao.service
```

#### 2. 修改配置文件

根据实际部署路径修改配置文件中的以下内容：

```ini
# 修改工作目录
WorkingDirectory=/opt/huobao

# 修改可执行文件路径
ExecStart=/opt/huobao/huobao-server

# 修改运行用户
User=huobao
Group=huobao

# 修改环境变量文件路径
EnvironmentFile=-/opt/huobao/.env
```

#### 3. 重新加载 systemd

```bash
# 重新加载 systemd 配置
sudo systemctl daemon-reload
```

#### 4. 启动服务

```bash
# 启动服务
sudo systemctl start huobao

# 查看服务状态
sudo systemctl status huobao

# 设置开机自启
sudo systemctl enable huobao
```

#### 5. 验证服务运行

```bash
# 检查服务是否正在运行
sudo systemctl is-active huobao

# 查看服务日志
sudo journalctl -u huobao -f

# 查看最近 100 行日志
sudo journalctl -u huobao -n 100

# 查看今天的日志
sudo journalctl -u huobao --since today
```

---

### 配置 Nginx 反向代理

#### 1. 复制 Nginx 配置文件

```bash
# 复制配置文件
sudo cp build-guides/deploy/nginx.conf /etc/nginx/sites-available/huobao

# 或者手动创建
sudo nano /etc/nginx/sites-available/huobao
```

#### 2. 修改配置文件

根据实际情况修改以下内容：

```nginx
# 修改服务器域名
server_name your-domain.com www.your-domain.com;

# 修改静态文件路径
location /static/ {
    alias /opt/huobao/web/dist/;
}

# 修改上传文件路径
location /uploads/ {
    alias /opt/huobao/uploads/;
}
```

#### 3. 启用站点配置

```bash
# 创建符号链接到 sites-enabled
sudo ln -s /etc/nginx/sites-available/huobao /etc/nginx/sites-enabled/

# 测试 Nginx 配置
sudo nginx -t

# 如果测试通过，重新加载 Nginx
sudo systemctl reload nginx
```

#### 4. 验证反向代理

```bash
# 测试 HTTP 访问
curl http://your-domain.com

# 查看 Nginx 日志
sudo tail -f /var/log/nginx/huobao-access.log
sudo tail -f /var/log/nginx/huobao-error.log
```

---

### 配置 SSL/TLS 证书

使用 Let's Encrypt 免费证书为网站启用 HTTPS。

#### 1. 安装 Certbot

```bash
# Ubuntu/Debian
sudo apt install certbot python3-certbot-nginx

# CentOS/RHEL
sudo yum install certbot python3-certbot-nginx
```

#### 2. 获取证书

```bash
# 自动配置 Nginx 并获取证书
sudo certbot --nginx -d your-domain.com -d www.your-domain.com

# 或者只获取证书，手动配置
sudo certbot certonly --nginx -d your-domain.com
```

**交互式提示**：
- 输入邮箱地址（用于证书到期提醒）
- 同意服务条款
- 选择是否重定向 HTTP 到 HTTPS（推荐选择重定向）

#### 3. 验证 HTTPS

```bash
# 测试 HTTPS 访问
curl https://your-domain.com

# 查看证书信息
sudo certbot certificates
```

#### 4. 自动续期

Let's Encrypt 证书有效期为 90 天，Certbot 会自动配置续期任务：

```bash
# 测试自动续期
sudo certbot renew --dry-run

# 查看续期定时任务
sudo systemctl list-timers | grep certbot
```

**手动续期**（如果需要）：

```bash
sudo certbot renew
sudo systemctl reload nginx
```

---

### 日志管理

#### 1. 应用日志

**查看 systemd 日志**：

```bash
# 实时查看日志
sudo journalctl -u huobao -f

# 查看最近的日志
sudo journalctl -u huobao -n 100

# 查看特定时间范围的日志
sudo journalctl -u huobao --since "2024-01-01" --until "2024-01-02"

# 查看错误日志
sudo journalctl -u huobao -p err
```

**应用自定义日志**（如果应用写入文件）：

```bash
# 查看应用日志
sudo tail -f /opt/huobao/logs/app.log

# 查看错误日志
sudo tail -f /opt/huobao/logs/error.log
```

#### 2. Nginx 日志

```bash
# 访问日志
sudo tail -f /var/log/nginx/huobao-access.log

# 错误日志
sudo tail -f /var/log/nginx/huobao-error.log

# 查看特定 IP 的访问
sudo grep "192.168.1.100" /var/log/nginx/huobao-access.log
```

#### 3. 配置日志轮转

创建 logrotate 配置以防止日志文件过大：

```bash
# 创建 logrotate 配置
sudo nano /etc/logrotate.d/huobao
```

添加以下内容：

```
/opt/huobao/logs/*.log {
    daily                   # 每天轮转
    rotate 30               # 保留 30 天
    compress                # 压缩旧日志
    delaycompress           # 延迟压缩（保留最近一天未压缩）
    missingok               # 日志文件不存在不报错
    notifempty              # 空文件不轮转
    create 0640 huobao huobao  # 创建新日志文件的权限
    sharedscripts           # 所有日志轮转后只执行一次脚本
    postrotate
        # 轮转后重新加载应用（如果需要）
        systemctl reload huobao > /dev/null 2>&1 || true
    endscript
}
```

**测试 logrotate 配置**：

```bash
# 测试配置
sudo logrotate -d /etc/logrotate.d/huobao

# 强制执行轮转
sudo logrotate -f /etc/logrotate.d/huobao
```

---

## Windows 服务器部署

在 Windows 服务器上部署应用，可以使用 NSSM（Non-Sucking Service Manager）将应用注册为 Windows 服务。

### 1. 安装 NSSM

**下载 NSSM**：
- 访问 https://nssm.cc/download
- 下载最新版本（如 nssm-2.24.zip）
- 解压到 `C:\nssm`

**添加到系统路径**（可选）：
- 右键"此电脑" → "属性" → "高级系统设置"
- "环境变量" → 编辑 "Path"
- 添加 `C:\nssm\win64`（或 win32）

### 2. 部署应用文件

```powershell
# 创建部署目录
New-Item -ItemType Directory -Path "C:\huobao" -Force
New-Item -ItemType Directory -Path "C:\huobao\data" -Force
New-Item -ItemType Directory -Path "C:\huobao\uploads" -Force
New-Item -ItemType Directory -Path "C:\huobao\temp" -Force
New-Item -ItemType Directory -Path "C:\huobao\logs" -Force

# 复制构建产物
Copy-Item "huobao-server.exe" -Destination "C:\huobao\"
Copy-Item "config.yaml" -Destination "C:\huobao\"

# 复制前端文件
Copy-Item "web\dist\*" -Destination "C:\huobao\web\dist\" -Recurse
```

### 3. 安装 Windows 服务

**使用 NSSM 图形界面**：

```powershell
# 打开 NSSM 安装界面
nssm install HuobaoDrama
```

在弹出的窗口中配置：

**Application 标签**：
- Path: `C:\huobao\huobao-server.exe`
- Startup directory: `C:\huobao`
- Arguments: （留空或添加命令行参数）

**Details 标签**：
- Display name: `Huobao Drama Service`
- Description: `Huobao Drama AI Short Video Generation Platform`
- Startup type: `Automatic`

**I/O 标签**：
- Output (stdout): `C:\huobao\logs\output.log`
- Error (stderr): `C:\huobao\logs\error.log`

**Environment 标签**：
添加环境变量（每行一个）：
```
GO_ENV=production
GIN_MODE=release
AI_API_KEY=your-api-key-here
```

点击 "Install service" 完成安装。

**使用命令行安装**：

```powershell
# 安装服务
nssm install HuobaoDrama "C:\huobao\huobao-server.exe"

# 设置工作目录
nssm set HuobaoDrama AppDirectory "C:\huobao"

# 设置日志输出
nssm set HuobaoDrama AppStdout "C:\huobao\logs\output.log"
nssm set HuobaoDrama AppStderr "C:\huobao\logs\error.log"

# 设置环境变量
nssm set HuobaoDrama AppEnvironmentExtra "GO_ENV=production" "GIN_MODE=release"

# 设置自动启动
nssm set HuobaoDrama Start SERVICE_AUTO_START
```

### 4. 管理 Windows 服务

```powershell
# 启动服务
nssm start HuobaoDrama
# 或使用 Windows 命令
net start HuobaoDrama

# 停止服务
nssm stop HuobaoDrama
# 或
net stop HuobaoDrama

# 重启服务
nssm restart HuobaoDrama

# 查看服务状态
nssm status HuobaoDrama

# 查看服务配置
nssm dump HuobaoDrama

# 卸载服务
nssm remove HuobaoDrama confirm
```

### 5. 配置 IIS 反向代理（可选）

如果使用 IIS 作为反向代理：

**安装 URL Rewrite 和 ARR**：
1. 下载并安装 URL Rewrite Module
2. 下载并安装 Application Request Routing (ARR)

**配置反向代理**：
1. 打开 IIS 管理器
2. 选择站点 → URL Rewrite → Add Rule
3. 选择 "Reverse Proxy"
4. 输入后端地址：`localhost:8080`
5. 配置完成

---

## 服务管理

### Linux 服务管理命令

```bash
# 启动服务
sudo systemctl start huobao

# 停止服务
sudo systemctl stop huobao

# 重启服务
sudo systemctl restart huobao

# 重新加载配置（不中断服务）
sudo systemctl reload huobao

# 查看服务状态
sudo systemctl status huobao

# 启用开机自启
sudo systemctl enable huobao

# 禁用开机自启
sudo systemctl disable huobao

# 查看服务是否启用
sudo systemctl is-enabled huobao

# 查看服务是否运行
sudo systemctl is-active huobao
```

### 服务故障排查

**服务无法启动**：

```bash
# 查看详细错误信息
sudo systemctl status huobao -l

# 查看完整日志
sudo journalctl -u huobao -xe

# 检查配置文件语法
sudo systemd-analyze verify /etc/systemd/system/huobao.service
```

**服务频繁重启**：

```bash
# 查看重启历史
sudo journalctl -u huobao | grep "Started\|Stopped"

# 检查资源限制
sudo systemctl show huobao | grep Limit

# 增加重启间隔
sudo systemctl edit huobao
```

添加：
```ini
[Service]
RestartSec=10s
```

---

## 监控和维护

### 1. 健康检查

创建健康检查脚本：

```bash
#!/bin/bash
# /opt/huobao/scripts/health-check.sh

# 检查服务状态
if ! systemctl is-active --quiet huobao; then
    echo "Service is not running"
    exit 1
fi

# 检查 HTTP 响应
if ! curl -f http://localhost:8080/health > /dev/null 2>&1; then
    echo "Health check failed"
    exit 1
fi

echo "Service is healthy"
exit 0
```

设置定时任务：

```bash
# 编辑 crontab
crontab -e

# 每 5 分钟检查一次
*/5 * * * * /opt/huobao/scripts/health-check.sh || systemctl restart huobao
```

### 2. 性能监控

```bash
# 查看进程资源使用
top -p $(pgrep huobao-server)

# 查看内存使用
ps aux | grep huobao-server

# 查看打开的文件数
lsof -p $(pgrep huobao-server) | wc -l

# 查看网络连接
netstat -anp | grep :8080
```

### 3. 备份策略

**数据库备份**：

```bash
#!/bin/bash
# /opt/huobao/scripts/backup.sh

BACKUP_DIR="/opt/huobao/backups"
DATE=$(date +%Y%m%d_%H%M%S)

# 创建备份目录
mkdir -p $BACKUP_DIR

# 备份数据库
cp /opt/huobao/data/huobao.db $BACKUP_DIR/huobao_$DATE.db

# 压缩备份
gzip $BACKUP_DIR/huobao_$DATE.db

# 删除 30 天前的备份
find $BACKUP_DIR -name "*.gz" -mtime +30 -delete

echo "Backup completed: huobao_$DATE.db.gz"
```

设置定时备份：

```bash
# 每天凌晨 2 点备份
0 2 * * * /opt/huobao/scripts/backup.sh
```

### 4. 更新部署

```bash
#!/bin/bash
# /opt/huobao/scripts/update.sh

# 停止服务
sudo systemctl stop huobao

# 备份当前版本
sudo cp /opt/huobao/huobao-server /opt/huobao/huobao-server.backup

# 上传新版本（假设已上传到 /tmp）
sudo mv /tmp/huobao-server /opt/huobao/
sudo chmod +x /opt/huobao/huobao-server
sudo chown huobao:huobao /opt/huobao/huobao-server

# 启动服务
sudo systemctl start huobao

# 检查服务状态
sleep 5
if systemctl is-active --quiet huobao; then
    echo "Update successful"
else
    echo "Update failed, rolling back"
    sudo systemctl stop huobao
    sudo mv /opt/huobao/huobao-server.backup /opt/huobao/huobao-server
    sudo systemctl start huobao
fi
```

---

## 安全建议

1. **防火墙配置**：
```bash
# 只允许必要的端口
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 22/tcp
sudo ufw enable
```

2. **定期更新系统**：
```bash
# Ubuntu/Debian
sudo apt update && sudo apt upgrade

# CentOS/RHEL
sudo yum update
```

3. **限制文件权限**：
- 配置文件：640 或 600
- 可执行文件：755
- 数据目录：755
- 日志目录：755

4. **使用强密码和密钥认证**：
- 禁用 root SSH 登录
- 使用 SSH 密钥认证
- 定期更换密码

5. **监控异常访问**：
```bash
# 查看失败的登录尝试
sudo journalctl -u ssh | grep "Failed"

# 查看 Nginx 错误日志
sudo tail -f /var/log/nginx/error.log
```

---

## 总结

传统服务器部署虽然配置步骤较多，但提供了更大的灵活性和控制力。关键步骤包括：

1. ✅ 创建专用用户和目录结构
2. ✅ 正确设置文件权限
3. ✅ 配置 systemd 服务实现自动启动和管理
4. ✅ 配置 Nginx 反向代理和 SSL 证书
5. ✅ 设置日志管理和轮转
6. ✅ 实施监控和备份策略

遵循本指南，您可以在生产环境中稳定运行 Huobao Drama 平台。
