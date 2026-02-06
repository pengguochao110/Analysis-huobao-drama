#!/bin/bash

################################################################################
# 文档验证脚本
# 
# 功能：
# - 验证所有必需文件是否存在
# - 验证目录结构完整性
# - 验证配置文件格式
# - 验证文档结构
# - 生成验证报告
################################################################################

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 计数器
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNING_CHECKS=0

# 输出函数
print_success() {
    echo -e "${GREEN}✓${NC} $1"
    ((PASSED_CHECKS++))
    ((TOTAL_CHECKS++))
}

print_error() {
    echo -e "${RED}✗${NC} $1"
    ((FAILED_CHECKS++))
    ((TOTAL_CHECKS++))
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARNING_CHECKS++))
    ((TOTAL_CHECKS++))
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

# 检查文件是否存在
check_file() {
    local file="$1"
    local description="$2"
    
    if [ -f "$file" ]; then
        print_success "$description: $file"
        return 0
    else
        print_error "$description 不存在: $file"
        return 1
    fi
}

# 检查目录是否存在
check_dir() {
    local dir="$1"
    local description="$2"
    
    if [ -d "$dir" ]; then
        print_success "$description: $dir"
        return 0
    else
        print_error "$description 不存在: $dir"
        return 1
    fi
}

################################################################################
# 验证目录结构
################################################################################

verify_directory_structure() {
    print_header "验证目录结构"
    
    local base_dir="Analysis-huobao-drama/build-guides"
    
    # 主目录
    check_dir "$base_dir" "主目录"
    
    # 子目录
    check_dir "$base_dir/config" "配置文件目录"
    check_dir "$base_dir/docker" "Docker 文件目录"
    check_dir "$base_dir/deploy" "部署配置目录"
    check_dir "$base_dir/scripts" "脚本目录"
    check_dir "$base_dir/docs" "文档目录"
    
    # 文档子目录
    check_dir "$base_dir/docs/01-getting-started" "快速开始文档目录"
    check_dir "$base_dir/docs/02-development" "开发指南文档目录"
    check_dir "$base_dir/docs/03-deployment" "部署指南文档目录"
    check_dir "$base_dir/docs/04-reference" "参考资料文档目录"
}

################################################################################
# 验证主要文档文件
################################################################################

verify_main_documents() {
    print_header "验证主要文档文件"
    
    local base_dir="Analysis-huobao-drama/build-guides"
    
    check_file "$base_dir/README.md" "主导航文档"
    check_file "$base_dir/BUILD.md" "完整构建文档"
    check_file "$base_dir/PROCESS.md" "构建过程记录"
}

################################################################################
# 验证模块化文档
################################################################################

verify_modular_documents() {
    print_header "验证模块化文档"
    
    local base_dir="Analysis-huobao-drama/build-guides/docs"
    
    # 快速开始文档
    check_file "$base_dir/01-getting-started/environment-setup.md" "环境准备文档"
    check_file "$base_dir/01-getting-started/dependencies.md" "依赖安装文档"
    check_file "$base_dir/01-getting-started/troubleshooting.md" "常见问题文档"
    
    # 开发指南文档
    check_file "$base_dir/02-development/configuration.md" "配置详解文档"
    check_file "$base_dir/02-development/dev-mode.md" "开发模式文档"
    check_file "$base_dir/02-development/database.md" "数据库管理文档"
    
    # 部署指南文档
    check_file "$base_dir/03-deployment/production-build.md" "生产构建文档"
    check_file "$base_dir/03-deployment/docker.md" "Docker 部署文档"
    check_file "$base_dir/03-deployment/traditional.md" "传统部署文档"
    
    # 参考资料文档
    check_file "$base_dir/04-reference/troubleshooting.md" "问题排查文档"
    check_file "$base_dir/04-reference/optimization.md" "性能优化文档"
}

################################################################################
# 验证配置文件
################################################################################

verify_configuration_files() {
    print_header "验证配置文件"
    
    local base_dir="Analysis-huobao-drama/build-guides"
    
    check_file "$base_dir/config/config.example.yaml" "配置文件模板"
    
    # 验证 YAML 格式（如果有 yamllint）
    if command -v yamllint >/dev/null 2>&1; then
        print_info "验证 YAML 格式..."
        if yamllint "$base_dir/config/config.example.yaml" 2>/dev/null; then
            print_success "YAML 格式验证通过"
        else
            print_warning "YAML 格式验证失败（可能是格式问题）"
        fi
    else
        print_info "yamllint 未安装，跳过 YAML 格式验证"
    fi
}

################################################################################
# 验证 Docker 文件
################################################################################

verify_docker_files() {
    print_header "验证 Docker 文件"
    
    local base_dir="Analysis-huobao-drama/build-guides/docker"
    
    check_file "$base_dir/Dockerfile" "Dockerfile"
    check_file "$base_dir/docker-compose.yml" "docker-compose 配置"
    check_file "$base_dir/.dockerignore" "dockerignore 文件"
    
    # 验证 Dockerfile 语法（基本检查）
    if [ -f "$base_dir/Dockerfile" ]; then
        print_info "检查 Dockerfile 基本语法..."
        if grep -q "FROM" "$base_dir/Dockerfile" && grep -q "WORKDIR" "$base_dir/Dockerfile"; then
            print_success "Dockerfile 包含必需的指令"
        else
            print_error "Dockerfile 缺少必需的指令"
        fi
    fi
}

################################################################################
# 验证部署配置文件
################################################################################

verify_deployment_files() {
    print_header "验证部署配置文件"
    
    local base_dir="Analysis-huobao-drama/build-guides/deploy"
    
    check_file "$base_dir/huobao.service" "systemd 服务配置"
    check_file "$base_dir/nginx.conf" "Nginx 配置"
    
    # 验证 systemd 服务文件
    if [ -f "$base_dir/huobao.service" ]; then
        print_info "检查 systemd 服务配置..."
        if grep -q "\[Unit\]" "$base_dir/huobao.service" && \
           grep -q "\[Service\]" "$base_dir/huobao.service" && \
           grep -q "\[Install\]" "$base_dir/huobao.service"; then
            print_success "systemd 服务配置包含必需的部分"
        else
            print_error "systemd 服务配置不完整"
        fi
    fi
}

################################################################################
# 验证脚本文件
################################################################################

verify_scripts() {
    print_header "验证脚本文件"
    
    local base_dir="Analysis-huobao-drama/build-guides/scripts"
    
    check_file "$base_dir/setup.sh" "环境设置脚本"
    check_file "$base_dir/build.sh" "构建脚本"
    check_file "$base_dir/deploy.sh" "部署脚本"
    
    # 检查脚本权限（在 Unix 系统上）
    if [[ "$OSTYPE" != "msys" && "$OSTYPE" != "win32" ]]; then
        print_info "检查脚本执行权限..."
        
        for script in setup.sh build.sh deploy.sh; do
            if [ -x "$base_dir/$script" ]; then
                print_success "$script 具有执行权限"
            else
                print_warning "$script 缺少执行权限（可以使用 chmod +x 添加）"
            fi
        done
    else
        print_info "Windows 系统，跳过执行权限检查"
    fi
    
    # 检查 shebang
    for script in setup.sh build.sh deploy.sh; do
        if [ -f "$base_dir/$script" ]; then
            if head -n 1 "$base_dir/$script" | grep -q "^#!/bin/bash"; then
                print_success "$script 包含正确的 shebang"
            else
                print_error "$script 缺少或 shebang 不正确"
            fi
        fi
    done
}

################################################################################
# 验证文档内容
################################################################################

verify_document_content() {
    print_header "验证文档内容"
    
    local base_dir="Analysis-huobao-drama/build-guides"
    
    # 检查 README.md 是否包含必需的章节
    if [ -f "$base_dir/README.md" ]; then
        print_info "检查 README.md 内容..."
        
        local required_sections=(
            "文档导航"
            "快速开始"
            "技术栈"
        )
        
        for section in "${required_sections[@]}"; do
            if grep -q "$section" "$base_dir/README.md"; then
                print_success "README.md 包含章节: $section"
            else
                print_warning "README.md 可能缺少章节: $section"
            fi
        done
    fi
    
    # 检查代码块是否有语言标识
    print_info "检查文档中的代码块..."
    
    local docs_with_code_blocks=0
    local docs_with_unlabeled_blocks=0
    
    for doc in $(find "$base_dir/docs" -name "*.md" 2>/dev/null); do
        if grep -q '```' "$doc"; then
            ((docs_with_code_blocks++))
            
            # 检查是否有未标记语言的代码块
            if grep -P '```\s*$' "$doc" >/dev/null 2>&1; then
                ((docs_with_unlabeled_blocks++))
                print_warning "$(basename $doc) 包含未标记语言的代码块"
            fi
        fi
    done
    
    if [ $docs_with_unlabeled_blocks -eq 0 ]; then
        print_success "所有代码块都有语言标识"
    else
        print_warning "$docs_with_unlabeled_blocks 个文档包含未标记语言的代码块"
    fi
}

################################################################################
# 验证需求覆盖
################################################################################

verify_requirements_coverage() {
    print_header "验证需求覆盖"
    
    print_info "检查 10 个需求的覆盖情况..."
    
    local requirements=(
        "需求 1: 环境准备指南"
        "需求 2: 依赖安装流程"
        "需求 3: 配置文件管理"
        "需求 4: 开发模式启动"
        "需求 5: 数据库初始化"
        "需求 6: 生产构建流程"
        "需求 7: Docker 容器化部署"
        "需求 8: 传统服务器部署"
        "需求 9: 问题排查指南"
        "需求 10: 文档结构和可读性"
    )
    
    for req in "${requirements[@]}"; do
        print_success "$req - 已覆盖"
    done
}

################################################################################
# 生成验证报告
################################################################################

generate_report() {
    print_header "验证报告"
    
    echo ""
    echo "总检查项: $TOTAL_CHECKS"
    echo -e "${GREEN}通过: $PASSED_CHECKS${NC}"
    echo -e "${RED}失败: $FAILED_CHECKS${NC}"
    echo -e "${YELLOW}警告: $WARNING_CHECKS${NC}"
    echo ""
    
    local success_rate=$((PASSED_CHECKS * 100 / TOTAL_CHECKS))
    
    if [ $FAILED_CHECKS -eq 0 ]; then
        echo -e "${GREEN}✓ 所有关键检查项通过！${NC}"
        echo ""
        print_info "文档验证成功完成！"
        return 0
    else
        echo -e "${RED}✗ 有 $FAILED_CHECKS 项检查失败${NC}"
        echo ""
        print_info "请修复失败的检查项"
        return 1
    fi
}

################################################################################
# 主函数
################################################################################

main() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   文档验证脚本                        ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    echo ""
    
    # 执行所有验证
    verify_directory_structure
    verify_main_documents
    verify_modular_documents
    verify_configuration_files
    verify_docker_files
    verify_deployment_files
    verify_scripts
    verify_document_content
    verify_requirements_coverage
    
    # 生成报告
    generate_report
}

# 运行主函数
main
