#!/bin/bash

################################################################################
# Huobao Drama 生产构建脚本
# 
# 功能：
# - 构建后端 Go 可执行文件
# - 构建前端静态资源
# - 验证构建产物
# - 创建部署压缩包
#
# 使用方法：
#   chmod +x build.sh
#   ./build.sh
################################################################################

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 构建配置
BUILD_DIR="build"
BACKEND_BINARY="huobao-server"
DEPLOY_PACKAGE="huobao-drama-deploy.tar.gz"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

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

# 错误处理和回滚
cleanup_on_error() {
    print_error "构建失败，正在清理..."
    
    # 如果有备份，恢复
    if [ -d "${BUILD_DIR}.backup" ]; then
        print_info "恢复之前的构建产物..."
        rm -rf "$BUILD_DIR"
        mv "${BUILD_DIR}.backup" "$BUILD_DIR"
        print_success "已恢复之前的构建产物"
    fi
    
    exit 1
}

# 设置错误处理
trap cleanup_on_error ERR

################################################################################
# 准备构建
################################################################################

prepare_build() {
    print_header "准备构建环境"
    
    # 检查项目目录
    if [ ! -d "huobao-drama" ]; then
        print_error "未找到 huobao-drama 目录"
        print_info "请在项目根目录运行此脚本"
        exit 1
    fi
    
    # 备份现有构建产物
    if [ -d "$BUILD_DIR" ]; then
        print_info "备份现有构建产物..."
        rm -rf "${BUILD_DIR}.backup"
        cp -r "$BUILD_DIR" "${BUILD_DIR}.backup"
        print_success "已备份现有构建产物"
    fi
    
    # 创建构建目录
    print_info "创建构建目录..."
    mkdir -p "$BUILD_DIR"
    print_success "构建目录已创建: $BUILD_DIR"
}

################################################################################
# 构建后端
################################################################################

build_backend() {
    print_header "构建后端服务"
    
    cd huobao-drama
    
    print_progress "清理旧的构建产物..."
    rm -f "$BACKEND_BINARY"
    
    print_progress "编译 Go 代码..."
    print_info "使用 CGO_ENABLED=1 以支持 SQLite"
    
    # 构建命令
    if CGO_ENABLED=1 go build -o "$BACKEND_BINARY" -ldflags="-s -w" main.go; then
        print_success "后端编译完成"
    else
        print_error "后端编译失败"
        cd ..
        return 1
    fi
    
    # 验证可执行文件
    if [ -f "$BACKEND_BINARY" ]; then
        FILE_SIZE=$(du -h "$BACKEND_BINARY" | cut -f1)
        print_success "后端可执行文件已生成: $BACKEND_BINARY (大小: $FILE_SIZE)"
    else
        print_error "未找到后端可执行文件"
        cd ..
        return 1
    fi
    
    # 移动到构建目录
    print_progress "移动构建产物到构建目录..."
    mv "$BACKEND_BINARY" "../$BUILD_DIR/"
    print_success "后端构建产物已移动到: $BUILD_DIR/$BACKEND_BINARY"
    
    cd ..
    return 0
}

################################################################################
# 构建前端
################################################################################

build_frontend() {
    print_header "构建前端应用"
    
    cd huobao-drama/web
    
    print_progress "清理旧的构建产物..."
    rm -rf dist
    
    print_progress "构建前端静态资源..."
    print_info "这可能需要几分钟时间..."
    
    # 检查使用哪个包管理器
    if command -v pnpm >/dev/null 2>&1; then
        print_info "使用 pnpm 构建..."
        if pnpm build; then
            print_success "前端构建完成 (pnpm)"
        else
            print_error "前端构建失败"
            cd ../..
            return 1
        fi
    elif command -v npm >/dev/null 2>&1; then
        print_info "使用 npm 构建..."
        if npm run build; then
            print_success "前端构建完成 (npm)"
        else
            print_error "前端构建失败"
            cd ../..
            return 1
        fi
    else
        print_error "未找到 npm 或 pnpm"
        cd ../..
        return 1
    fi
    
    # 验证构建产物
    if [ -d "dist" ]; then
        DIST_SIZE=$(du -sh dist | cut -f1)
        FILE_COUNT=$(find dist -type f | wc -l)
        print_success "前端构建产物已生成: dist/ (大小: $DIST_SIZE, 文件数: $FILE_COUNT)"
    else
        print_error "未找到前端构建产物目录 dist/"
        cd ../..
        return 1
    fi
    
    # 移动到构建目录
    print_progress "移动构建产物到构建目录..."
    cp -r dist "../../$BUILD_DIR/web"
    print_success "前端构建产物已移动到: $BUILD_DIR/web"
    
    cd ../..
    return 0
}

################################################################################
# 验证构建产物
################################################################################

verify_build() {
    print_header "验证构建产物"
    
    local all_ok=true
    
    # 检查后端可执行文件
    print_info "检查后端可执行文件..."
    if [ -f "$BUILD_DIR/$BACKEND_BINARY" ]; then
        if [ -x "$BUILD_DIR/$BACKEND_BINARY" ]; then
            print_success "后端可执行文件存在且可执行"
        else
            print_warning "后端可执行文件存在但不可执行"
            chmod +x "$BUILD_DIR/$BACKEND_BINARY"
            print_success "已添加执行权限"
        fi
    else
        print_error "后端可执行文件不存在"
        all_ok=false
    fi
    
    # 检查前端静态资源
    print_info "检查前端静态资源..."
    if [ -d "$BUILD_DIR/web" ]; then
        if [ -f "$BUILD_DIR/web/index.html" ]; then
            print_success "前端静态资源存在"
        else
            print_error "前端静态资源不完整（缺少 index.html）"
            all_ok=false
        fi
    else
        print_error "前端静态资源目录不存在"
        all_ok=false
    fi
    
    echo ""
    if [ "$all_ok" = true ]; then
        print_success "所有构建产物验证通过"
        return 0
    else
        print_error "构建产物验证失败"
        return 1
    fi
}

################################################################################
# 创建部署包
################################################################################

create_deploy_package() {
    print_header "创建部署压缩包"
    
    print_progress "准备部署文件..."
    
    # 复制必要的配置文件和目录结构
    mkdir -p "$BUILD_DIR/configs"
    mkdir -p "$BUILD_DIR/data"
    mkdir -p "$BUILD_DIR/uploads"
    mkdir -p "$BUILD_DIR/migrations"
    
    # 复制配置示例
    if [ -f "Analysis-huobao-drama/build-guides/config/config.example.yaml" ]; then
        cp "Analysis-huobao-drama/build-guides/config/config.example.yaml" "$BUILD_DIR/configs/"
        print_success "已复制配置示例文件"
    fi
    
    # 复制数据库迁移文件
    if [ -d "huobao-drama/migrations" ]; then
        cp -r huobao-drama/migrations/* "$BUILD_DIR/migrations/"
        print_success "已复制数据库迁移文件"
    fi
    
    # 创建 README
    cat > "$BUILD_DIR/README.txt" << 'EOF'
Huobao Drama 部署包
==================

构建时间: $(date)

目录结构:
- huobao-server: 后端可执行文件
- web/: 前端静态资源
- configs/: 配置文件示例
- migrations/: 数据库迁移文件
- data/: 数据库文件目录（运行时创建）
- uploads/: 上传文件目录（运行时创建）

部署步骤:
1. 解压此压缩包到目标服务器
2. 复制 configs/config.example.yaml 为 config.yaml 并编辑
3. 确保 FFmpeg 已安装
4. 运行 ./huobao-server 启动服务

详细文档请参考:
Analysis-huobao-drama/build-guides/docs/03-deployment/
EOF
    
    print_progress "创建压缩包..."
    PACKAGE_NAME="${DEPLOY_PACKAGE%.tar.gz}_${TIMESTAMP}.tar.gz"
    
    if tar -czf "$PACKAGE_NAME" -C "$BUILD_DIR" .; then
        PACKAGE_SIZE=$(du -h "$PACKAGE_NAME" | cut -f1)
        print_success "部署压缩包已创建: $PACKAGE_NAME (大小: $PACKAGE_SIZE)"
    else
        print_error "创建压缩包失败"
        return 1
    fi
    
    return 0
}

################################################################################
# 显示构建摘要
################################################################################

show_summary() {
    print_header "构建摘要"
    
    echo ""
    print_success "构建成功完成！"
    echo ""
    
    print_info "构建产物位置:"
    echo "  - 构建目录: $BUILD_DIR/"
    echo "  - 后端可执行文件: $BUILD_DIR/$BACKEND_BINARY"
    echo "  - 前端静态资源: $BUILD_DIR/web/"
    
    if [ -f "$PACKAGE_NAME" ]; then
        echo "  - 部署压缩包: $PACKAGE_NAME"
    fi
    
    echo ""
    print_info "下一步:"
    echo "  1. 测试构建产物:"
    echo "     cd $BUILD_DIR && ./$BACKEND_BINARY"
    echo ""
    echo "  2. 部署到服务器:"
    echo "     参考文档: Analysis-huobao-drama/build-guides/docs/03-deployment/"
    echo ""
}

################################################################################
# 主函数
################################################################################

main() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   Huobao Drama 生产构建脚本           ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    echo ""
    
    # 准备构建
    prepare_build
    
    # 构建后端
    if ! build_backend; then
        print_error "后端构建失败"
        cleanup_on_error
    fi
    
    # 构建前端
    if ! build_frontend; then
        print_error "前端构建失败"
        cleanup_on_error
    fi
    
    # 验证构建产物
    if ! verify_build; then
        print_error "构建产物验证失败"
        cleanup_on_error
    fi
    
    # 创建部署包
    if ! create_deploy_package; then
        print_warning "创建部署包失败，但构建产物可用"
    fi
    
    # 清理备份
    if [ -d "${BUILD_DIR}.backup" ]; then
        rm -rf "${BUILD_DIR}.backup"
    fi
    
    # 显示摘要
    show_summary
}

# 运行主函数
main
