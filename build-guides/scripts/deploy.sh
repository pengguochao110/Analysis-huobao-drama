#!/bin/bash

################################################################################
# Huobao Drama 部署脚本
# 
# 功能：
# - 检查服务器连接
# - 上传构建产物到服务器
# - 停止旧服务
# - 替换文件并设置权限
# - 启动新服务
# - 健康检查
# - 失败时自动回滚
#
# 使用方法：
#   chmod +x deploy.sh
#   ./deploy.sh <server_host> <server_user> [deploy_path]
#
# 示例：
#   ./deploy.sh 192.168.1.100 ubuntu /opt/huobao
################################################################################

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 部署配置
BUILD_DIR="build"
BACKUP_SUFFIX=$(date +%Y%m%d_%H%M%S)
SERVICE_NAME="huobao"
HEALTH_CHECK_TIMEOUT=30
HEALTH_CHECK_INTERVAL=2

# 输出函数
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_header() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_progress() {
    echo -e "${BLUE}▶${NC} $1"
}

# 使用说明
usage() {
    echo "使用方法: $0 <server_host> <server_user> [deploy_path]"
    echo ""
    echo "参数:"
    echo "  server_host   - 服务器地址（IP 或域名）"
    echo "  server_user   - SSH 登录用户名"
    echo "  deploy_path   - 部署目录路径（默认: /opt/huobao）"
    echo ""
    echo "示例:"
    echo "  $0 192.168.1.100 ubuntu"
    echo "  $0 example.com deploy /home/deploy/huobao"
    echo ""
    exit 1
}

# 解析参数
if [ $# -lt 2 ]; then
    usage
fi

SERVER_HOST="$1"
SERVER_USER="$2"
DEPLOY_PATH="${3:-/opt/huobao}"

# SSH 连接字符串
SSH_CONN="${SERVER_USER}@${SERVER_HOST}"

################################################################################
# 检查本地构建产物
################################################################################

check_local_build() {
    print_header "检查本地构建产物"
    
    if [ ! -d "$BUILD_DIR" ]; then
        print_error "未找到构建目录: $BUILD_DIR"
        print_info "请先运行构建脚本: ./build.sh"
        exit 1
    fi
    
    if [ ! -f "$BUILD_DIR/huobao-server" ]; then
        print_error "未找到后端可执行文件"
        exit 1
    fi
    
    if [ ! -d "$BUILD_DIR/web" ]; then
        print_error "未找到前端静态资源"
        exit 1
    fi
    
    print_success "本地构建产物检查通过"
}

################################################################################
# 检查服务器连接
################################################################################

check_server_connection() {
    print_header "检查服务器连接"
    
    print_progress "测试 SSH 连接: $SSH_CONN"
    
    if ssh -o ConnectTimeout=10 -o BatchMode=yes "$SSH_CONN" "echo 'SSH 连接成功'" >/dev/null 2>&1; then
        print_success "SSH 连接测试成功"
    else
        print_error "SSH 连接失败"
        print_info "请检查:"
        print_info "  1. 服务器地址和用户名是否正确"
        print_info "  2. SSH 密钥是否已配置（推荐使用密钥认证）"
        print_info "  3. 服务器防火墙是否允许 SSH 连接"
        exit 1
    fi
    
    # 检查服务器上的必要命令
    print_progress "检查服务器环境..."
    
    local missing_commands=()
    for cmd in systemctl tar; do
        if ! ssh "$SSH_CONN" "command -v $cmd >/dev/null 2>&1"; then
            missing_commands+=("$cmd")
        fi
    done
    
    if [ ${#missing_commands[@]} -gt 0 ]; then
        print_warning "服务器缺少以下命令: ${missing_commands[*]}"
        print_info "部分功能可能不可用"
    else
        print_success "服务器环境检查通过"
    fi
}

################################################################################
# 备份当前版本
################################################################################

backup_current_version() {
    print_header "备份当前版本"
    
    print_progress "检查部署目录是否存在..."
    
    if ssh "$SSH_CONN" "[ -d '$DEPLOY_PATH' ]"; then
        print_info "部署目录存在，创建备份..."
        
        BACKUP_PATH="${DEPLOY_PATH}.backup_${BACKUP_SUFFIX}"
        
        if ssh "$SSH_CONN" "cp -r '$DEPLOY_PATH' '$BACKUP_PATH'"; then
            print_success "已创建备份: $BACKUP_PATH"
            echo "$BACKUP_PATH" > /tmp/huobao_backup_path.txt
        else
            print_error "创建备份失败"
            exit 1
        fi
    else
        print_info "部署目录不存在，跳过备份"
        print_progress "创建部署目录..."
        
        if ssh "$SSH_CONN" "sudo mkdir -p '$DEPLOY_PATH' && sudo chown $SERVER_USER:$SERVER_USER '$DEPLOY_PATH'"; then
            print_success "部署目录已创建"
        else
            print_error "创建部署目录失败"
            exit 1
        fi
    fi
}

################################################################################
# 停止服务
################################################################################

stop_service() {
    print_header "停止服务"
    
    print_progress "检查服务状态..."
    
    if ssh "$SSH_CONN" "sudo systemctl is-active --quiet $SERVICE_NAME 2>/dev/null"; then
        print_info "服务正在运行，准备停止..."
        
        if ssh "$SSH_CONN" "sudo systemctl stop $SERVICE_NAME"; then
            print_success "服务已停止"
            sleep 2  # 等待服务完全停止
        else
            print_warning "停止服务失败，可能服务未配置"
        fi
    else
        print_info "服务未运行或未配置"
    fi
}

################################################################################
# 上传文件
################################################################################

upload_files() {
    print_header "上传构建产物"
    
    print_progress "使用 rsync 上传文件..."
    print_info "这可能需要几分钟时间，取决于网络速度..."
    
    # 使用 rsync 上传，显示进度
    if rsync -avz --progress "$BUILD_DIR/" "$SSH_CONN:$DEPLOY_PATH/"; then
        print_success "文件上传完成"
    else
        print_error "文件上传失败"
        
        # 尝试使用 scp 作为备选方案
        print_warning "尝试使用 scp 上传..."
        
        if scp -r "$BUILD_DIR/"* "$SSH_CONN:$DEPLOY_PATH/"; then
            print_success "文件上传完成（使用 scp）"
        else
            print_error "文件上传失败"
            exit 1
        fi
    fi
}

################################################################################
# 设置权限
################################################################################

set_permissions() {
    print_header "设置文件权限"
    
    print_progress "设置可执行文件权限..."
    
    if ssh "$SSH_CONN" "chmod +x '$DEPLOY_PATH/huobao-server'"; then
        print_success "可执行文件权限已设置"
    else
        print_error "设置权限失败"
        exit 1
    fi
    
    print_progress "设置目录权限..."
    
    ssh "$SSH_CONN" "mkdir -p '$DEPLOY_PATH/data' '$DEPLOY_PATH/uploads' '$DEPLOY_PATH/logs'"
    ssh "$SSH_CONN" "chmod 755 '$DEPLOY_PATH/data' '$DEPLOY_PATH/uploads' '$DEPLOY_PATH/logs'"
    
    print_success "目录权限已设置"
}

################################################################################
# 启动服务
################################################################################

start_service() {
    print_header "启动服务"
    
    print_progress "启动 systemd 服务..."
    
    if ssh "$SSH_CONN" "sudo systemctl start $SERVICE_NAME"; then
        print_success "服务启动命令已执行"
    else
        print_warning "启动服务失败，可能服务未配置"
        print_info "尝试直接启动应用..."
        
        # 尝试直接启动（后台运行）
        if ssh "$SSH_CONN" "cd '$DEPLOY_PATH' && nohup ./huobao-server > logs/app.log 2>&1 &"; then
            print_success "应用已在后台启动"
        else
            print_error "启动应用失败"
            return 1
        fi
    fi
    
    return 0
}

################################################################################
# 健康检查
################################################################################

health_check() {
    print_header "健康检查"
    
    print_progress "等待服务启动..."
    sleep 5
    
    print_info "检查服务状态（超时: ${HEALTH_CHECK_TIMEOUT}秒）..."
    
    local elapsed=0
    local service_ok=false
    
    while [ $elapsed -lt $HEALTH_CHECK_TIMEOUT ]; do
        # 检查进程是否运行
        if ssh "$SSH_CONN" "pgrep -f huobao-server >/dev/null"; then
            print_success "服务进程正在运行"
            service_ok=true
            break
        fi
        
        sleep $HEALTH_CHECK_INTERVAL
        elapsed=$((elapsed + HEALTH_CHECK_INTERVAL))
        echo -n "."
    done
    
    echo ""
    
    if [ "$service_ok" = false ]; then
        print_error "服务启动失败或超时"
        print_info "查看日志:"
        ssh "$SSH_CONN" "tail -n 20 '$DEPLOY_PATH/logs/app.log' 2>/dev/null || journalctl -u $SERVICE_NAME -n 20"
        return 1
    fi
    
    # 检查端口监听
    print_progress "检查端口监听..."
    
    if ssh "$SSH_CONN" "ss -tlnp | grep -q ':8080'"; then
        print_success "服务正在监听端口 8080"
    else
        print_warning "未检测到端口 8080 监听"
        print_info "服务可能仍在启动中"
    fi
    
    print_success "健康检查通过"
    return 0
}

################################################################################
# 回滚
################################################################################

rollback() {
    print_header "执行回滚"
    
    print_error "部署失败，正在回滚到之前的版本..."
    
    if [ -f /tmp/huobao_backup_path.txt ]; then
        BACKUP_PATH=$(cat /tmp/huobao_backup_path.txt)
        
        if ssh "$SSH_CONN" "[ -d '$BACKUP_PATH' ]"; then
            print_progress "停止当前服务..."
            ssh "$SSH_CONN" "sudo systemctl stop $SERVICE_NAME 2>/dev/null || true"
            
            print_progress "恢复备份..."
            ssh "$SSH_CONN" "rm -rf '$DEPLOY_PATH' && mv '$BACKUP_PATH' '$DEPLOY_PATH'"
            
            print_progress "重启服务..."
            ssh "$SSH_CONN" "sudo systemctl start $SERVICE_NAME 2>/dev/null || cd '$DEPLOY_PATH' && nohup ./huobao-server > logs/app.log 2>&1 &"
            
            print_success "已回滚到之前的版本"
            
            # 清理临时文件
            rm -f /tmp/huobao_backup_path.txt
        else
            print_error "未找到备份，无法回滚"
        fi
    else
        print_warning "这是首次部署，无法回滚"
    fi
    
    exit 1
}

################################################################################
# 清理备份
################################################################################

cleanup_backup() {
    print_header "清理旧备份"
    
    if [ -f /tmp/huobao_backup_path.txt ]; then
        BACKUP_PATH=$(cat /tmp/huobao_backup_path.txt)
        
        print_progress "删除备份: $BACKUP_PATH"
        
        if ssh "$SSH_CONN" "rm -rf '$BACKUP_PATH'"; then
            print_success "备份已清理"
        else
            print_warning "清理备份失败，请手动删除"
        fi
        
        rm -f /tmp/huobao_backup_path.txt
    fi
    
    # 清理超过 7 天的旧备份
    print_progress "清理超过 7 天的旧备份..."
    ssh "$SSH_CONN" "find $(dirname '$DEPLOY_PATH') -maxdepth 1 -name '$(basename '$DEPLOY_PATH').backup_*' -mtime +7 -exec rm -rf {} \; 2>/dev/null || true"
    print_success "旧备份已清理"
}

################################################################################
# 显示部署摘要
################################################################################

show_summary() {
    print_header "部署摘要"
    
    echo ""
    print_success "部署成功完成！"
    echo ""
    
    print_info "部署信息:"
    echo "  - 服务器: $SERVER_HOST"
    echo "  - 用户: $SERVER_USER"
    echo "  - 部署路径: $DEPLOY_PATH"
    echo "  - 部署时间: $(date)"
    echo ""
    
    print_info "服务管理命令:"
    echo "  - 查看状态: ssh $SSH_CONN 'sudo systemctl status $SERVICE_NAME'"
    echo "  - 查看日志: ssh $SSH_CONN 'journalctl -u $SERVICE_NAME -f'"
    echo "  - 重启服务: ssh $SSH_CONN 'sudo systemctl restart $SERVICE_NAME'"
    echo ""
    
    print_info "访问应用:"
    echo "  - 后端 API: http://$SERVER_HOST:8080"
    echo "  - 前端页面: 需要配置 Nginx 反向代理"
    echo ""
}

################################################################################
# 主函数
################################################################################

main() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   Huobao Drama 部署脚本               ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    echo ""
    
    print_info "部署目标: $SSH_CONN:$DEPLOY_PATH"
    echo ""
    
    # 检查本地构建产物
    check_local_build
    
    # 检查服务器连接
    check_server_connection
    
    # 备份当前版本
    backup_current_version
    
    # 停止服务
    stop_service
    
    # 上传文件
    if ! upload_files; then
        rollback
    fi
    
    # 设置权限
    if ! set_permissions; then
        rollback
    fi
    
    # 启动服务
    if ! start_service; then
        rollback
    fi
    
    # 健康检查
    if ! health_check; then
        rollback
    fi
    
    # 清理备份
    cleanup_backup
    
    # 显示摘要
    show_summary
}

# 运行主函数
main
