#!/bin/bash

################################################################################
# Huobao Drama 环境设置脚本
# 
# 功能：
# - 检查必需的软件环境（Go, Node.js, FFmpeg）
# - 自动安装后端和前端依赖
# - 检查并创建配置文件
#
# 使用方法：
#   chmod +x setup.sh
#   ./setup.sh
################################################################################

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# 检查命令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 版本比较函数
version_ge() {
    # 比较版本号 $1 >= $2
    printf '%s\n%s\n' "$2" "$1" | sort -V -C
}

################################################################################
# 环境检查
################################################################################

check_environment() {
    print_header "检查环境依赖"
    
    local all_ok=true
    
    # 检查 Go
    print_info "检查 Go 版本..."
    if command_exists go; then
        GO_VERSION=$(go version | grep -oP 'go\K[0-9]+\.[0-9]+' || echo "0.0")
        if version_ge "$GO_VERSION" "1.23"; then
            print_success "Go 版本: $GO_VERSION (满足要求 >= 1.23)"
        else
            print_error "Go 版本: $GO_VERSION (需要 >= 1.23)"
            all_ok=false
        fi
    else
        print_error "Go 未安装"
        print_info "请访问 https://golang.org/dl/ 下载安装"
        all_ok=false
    fi
    
    # 检查 Node.js
    print_info "检查 Node.js 版本..."
    if command_exists node; then
        NODE_VERSION=$(node --version | grep -oP 'v\K[0-9]+' || echo "0")
        if [ "$NODE_VERSION" -ge 18 ]; then
            print_success "Node.js 版本: v$NODE_VERSION (满足要求 >= 18)"
        else
            print_error "Node.js 版本: v$NODE_VERSION (需要 >= 18)"
            all_ok=false
        fi
    else
        print_error "Node.js 未安装"
        print_info "请访问 https://nodejs.org/ 下载安装"
        all_ok=false
    fi
    
    # 检查 FFmpeg
    print_info "检查 FFmpeg..."
    if command_exists ffmpeg; then
        FFMPEG_VERSION=$(ffmpeg -version 2>/dev/null | head -n1 | grep -oP 'version \K[0-9]+\.[0-9]+' || echo "unknown")
        print_success "FFmpeg 已安装 (版本: $FFMPEG_VERSION)"
    else
        print_error "FFmpeg 未安装"
        print_info "请根据操作系统安装 FFmpeg:"
        print_info "  - Ubuntu/Debian: sudo apt-get install ffmpeg"
        print_info "  - macOS: brew install ffmpeg"
        print_info "  - Windows: 从 https://ffmpeg.org/download.html 下载"
        all_ok=false
    fi
    
    echo ""
    if [ "$all_ok" = true ]; then
        print_success "所有环境依赖检查通过"
        return 0
    else
        print_error "环境检查失败，请安装缺失的依赖后重试"
        return 1
    fi
}

################################################################################
# 安装依赖
################################################################################

install_backend_dependencies() {
    print_header "安装后端依赖"
    
    if [ ! -d "huobao-drama" ]; then
        print_error "未找到 huobao-drama 目录"
        print_info "请在项目根目录运行此脚本"
        return 1
    fi
    
    cd huobao-drama
    
    print_info "下载 Go 模块依赖..."
    if go mod download; then
        print_success "Go 依赖下载完成"
    else
        print_error "Go 依赖下载失败"
        print_warning "提示: 如果网络问题，请配置 GOPROXY:"
        print_info "  export GOPROXY=https://goproxy.cn,direct"
        cd ..
        return 1
    fi
    
    print_info "验证 Go 模块完整性..."
    if go mod verify; then
        print_success "Go 模块验证通过"
    else
        print_warning "Go 模块验证失败，但可以继续"
    fi
    
    cd ..
    return 0
}

install_frontend_dependencies() {
    print_header "安装前端依赖"
    
    if [ ! -d "huobao-drama/web" ]; then
        print_error "未找到 huobao-drama/web 目录"
        return 1
    fi
    
    cd huobao-drama/web
    
    # 检查使用哪个包管理器
    if command_exists pnpm; then
        print_info "使用 pnpm 安装前端依赖..."
        if pnpm install; then
            print_success "前端依赖安装完成 (pnpm)"
        else
            print_error "前端依赖安装失败"
            cd ../..
            return 1
        fi
    elif command_exists npm; then
        print_info "使用 npm 安装前端依赖..."
        if npm install; then
            print_success "前端依赖安装完成 (npm)"
        else
            print_error "前端依赖安装失败"
            print_warning "提示: 如果网络问题，请配置 npm 镜像:"
            print_info "  npm config set registry https://registry.npmmirror.com"
            cd ../..
            return 1
        fi
    else
        print_error "未找到 npm 或 pnpm"
        print_info "请先安装 Node.js"
        cd ../..
        return 1
    fi
    
    cd ../..
    return 0
}

################################################################################
# 配置文件检查
################################################################################

check_configuration() {
    print_header "检查配置文件"
    
    CONFIG_FILE="huobao-drama/config.yaml"
    EXAMPLE_CONFIG="Analysis-huobao-drama/build-guides/config/config.example.yaml"
    
    if [ -f "$CONFIG_FILE" ]; then
        print_success "配置文件已存在: $CONFIG_FILE"
        print_warning "如需更新配置，请手动编辑该文件"
    else
        print_info "配置文件不存在，尝试从模板创建..."
        
        if [ -f "$EXAMPLE_CONFIG" ]; then
            if cp "$EXAMPLE_CONFIG" "$CONFIG_FILE"; then
                print_success "已从模板创建配置文件: $CONFIG_FILE"
                print_warning "请编辑配置文件，填入实际的配置值（如 API 密钥等）"
            else
                print_error "创建配置文件失败"
                return 1
            fi
        else
            print_warning "未找到配置模板: $EXAMPLE_CONFIG"
            print_info "请手动创建配置文件: $CONFIG_FILE"
            print_info "参考文档: Analysis-huobao-drama/build-guides/docs/02-development/configuration.md"
        fi
    fi
    
    return 0
}

################################################################################
# 主函数
################################################################################

main() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   Huobao Drama 环境设置脚本           ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    echo ""
    
    # 检查环境
    if ! check_environment; then
        print_error "环境检查失败，请先安装必需的软件"
        exit 1
    fi
    
    # 安装后端依赖
    if ! install_backend_dependencies; then
        print_error "后端依赖安装失败"
        exit 1
    fi
    
    # 安装前端依赖
    if ! install_frontend_dependencies; then
        print_error "前端依赖安装失败"
        exit 1
    fi
    
    # 检查配置文件
    if ! check_configuration; then
        print_warning "配置文件检查失败，但可以继续"
    fi
    
    # 完成
    print_header "设置完成"
    print_success "环境设置成功完成！"
    echo ""
    print_info "下一步："
    print_info "  1. 编辑配置文件: huobao-drama/config.yaml"
    print_info "  2. 启动开发服务器，参考文档:"
    print_info "     Analysis-huobao-drama/build-guides/docs/02-development/dev-mode.md"
    echo ""
}

# 运行主函数
main
