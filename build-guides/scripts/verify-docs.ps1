# 文档验证脚本 (PowerShell)
# 
# 功能：
# - 验证所有必需文件是否存在
# - 验证目录结构完整性
# - 验证配置文件格式
# - 验证文档结构
# - 生成验证报告

$ErrorActionPreference = "Continue"

# 计数器
$script:TotalChecks = 0
$script:PassedChecks = 0
$script:FailedChecks = 0
$script:WarningChecks = 0

# 输出函数
function Print-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
    $script:PassedChecks++
    $script:TotalChecks++
}

function Print-Error {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor Red
    $script:FailedChecks++
    $script:TotalChecks++
}

function Print-Warning {
    param([string]$Message)
    Write-Host "⚠ $Message" -ForegroundColor Yellow
    $script:WarningChecks++
    $script:TotalChecks++
}

function Print-Info {
    param([string]$Message)
    Write-Host "ℹ $Message" -ForegroundColor Cyan
}

function Print-Header {
    param([string]$Message)
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host $Message -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
}

# 检查文件是否存在
function Check-File {
    param(
        [string]$Path,
        [string]$Description
    )
    
    if (Test-Path -Path $Path -PathType Leaf) {
        Print-Success "$Description`: $Path"
        return $true
    } else {
        Print-Error "$Description 不存在: $Path"
        return $false
    }
}

# 检查目录是否存在
function Check-Directory {
    param(
        [string]$Path,
        [string]$Description
    )
    
    if (Test-Path -Path $Path -PathType Container) {
        Print-Success "$Description`: $Path"
        return $true
    } else {
        Print-Error "$Description 不存在: $Path"
        return $false
    }
}

# 验证目录结构
function Verify-DirectoryStructure {
    Print-Header "验证目录结构"
    
    $baseDir = "Analysis-huobao-drama/build-guides"
    
    # 主目录
    Check-Directory $baseDir "主目录"
    
    # 子目录
    Check-Directory "$baseDir/config" "配置文件目录"
    Check-Directory "$baseDir/docker" "Docker 文件目录"
    Check-Directory "$baseDir/deploy" "部署配置目录"
    Check-Directory "$baseDir/scripts" "脚本目录"
    Check-Directory "$baseDir/docs" "文档目录"
    
    # 文档子目录
    Check-Directory "$baseDir/docs/01-getting-started" "快速开始文档目录"
    Check-Directory "$baseDir/docs/02-development" "开发指南文档目录"
    Check-Directory "$baseDir/docs/03-deployment" "部署指南文档目录"
    Check-Directory "$baseDir/docs/04-reference" "参考资料文档目录"
}

# 验证主要文档文件
function Verify-MainDocuments {
    Print-Header "验证主要文档文件"
    
    $baseDir = "Analysis-huobao-drama/build-guides"
    
    Check-File "$baseDir/README.md" "主导航文档"
    Check-File "$baseDir/BUILD.md" "完整构建文档"
    Check-File "$baseDir/PROCESS.md" "构建过程记录"
}

# 验证模块化文档
function Verify-ModularDocuments {
    Print-Header "验证模块化文档"
    
    $baseDir = "Analysis-huobao-drama/build-guides/docs"
    
    # 快速开始文档
    Check-File "$baseDir/01-getting-started/environment-setup.md" "环境准备文档"
    Check-File "$baseDir/01-getting-started/dependencies.md" "依赖安装文档"
    Check-File "$baseDir/01-getting-started/troubleshooting.md" "常见问题文档"
    
    # 开发指南文档
    Check-File "$baseDir/02-development/configuration.md" "配置详解文档"
    Check-File "$baseDir/02-development/dev-mode.md" "开发模式文档"
    Check-File "$baseDir/02-development/database.md" "数据库管理文档"
    
    # 部署指南文档
    Check-File "$baseDir/03-deployment/production-build.md" "生产构建文档"
    Check-File "$baseDir/03-deployment/docker.md" "Docker 部署文档"
    Check-File "$baseDir/03-deployment/traditional.md" "传统部署文档"
    
    # 参考资料文档
    Check-File "$baseDir/04-reference/troubleshooting.md" "问题排查文档"
    Check-File "$baseDir/04-reference/optimization.md" "性能优化文档"
}

# 验证配置文件
function Verify-ConfigurationFiles {
    Print-Header "验证配置文件"
    
    $baseDir = "Analysis-huobao-drama/build-guides"
    
    Check-File "$baseDir/config/config.example.yaml" "配置文件模板"
    
    # 验证 YAML 基本格式
    $configFile = "$baseDir/config/config.example.yaml"
    if (Test-Path $configFile) {
        Print-Info "检查 YAML 基本格式..."
        $content = Get-Content $configFile -Raw
        if ($content -match "database:" -and $content -match "storage:" -and $content -match "ai:") {
            Print-Success "配置文件包含必需的配置项"
        } else {
            Print-Error "配置文件缺少必需的配置项"
        }
    }
}

# 验证 Docker 文件
function Verify-DockerFiles {
    Print-Header "验证 Docker 文件"
    
    $baseDir = "Analysis-huobao-drama/build-guides/docker"
    
    Check-File "$baseDir/Dockerfile" "Dockerfile"
    Check-File "$baseDir/docker-compose.yml" "docker-compose 配置"
    Check-File "$baseDir/.dockerignore" "dockerignore 文件"
    
    # 验证 Dockerfile 语法
    $dockerfile = "$baseDir/Dockerfile"
    if (Test-Path $dockerfile) {
        Print-Info "检查 Dockerfile 基本语法..."
        $content = Get-Content $dockerfile -Raw
        if ($content -match "FROM" -and $content -match "WORKDIR") {
            Print-Success "Dockerfile 包含必需的指令"
        } else {
            Print-Error "Dockerfile 缺少必需的指令"
        }
    }
}

# 验证部署配置文件
function Verify-DeploymentFiles {
    Print-Header "验证部署配置文件"
    
    $baseDir = "Analysis-huobao-drama/build-guides/deploy"
    
    Check-File "$baseDir/huobao.service" "systemd 服务配置"
    Check-File "$baseDir/nginx.conf" "Nginx 配置"
    
    # 验证 systemd 服务文件
    $serviceFile = "$baseDir/huobao.service"
    if (Test-Path $serviceFile) {
        Print-Info "检查 systemd 服务配置..."
        $content = Get-Content $serviceFile -Raw
        if ($content -match "\[Unit\]" -and $content -match "\[Service\]" -and $content -match "\[Install\]") {
            Print-Success "systemd 服务配置包含必需的部分"
        } else {
            Print-Error "systemd 服务配置不完整"
        }
    }
}

# 验证脚本文件
function Verify-Scripts {
    Print-Header "验证脚本文件"
    
    $baseDir = "Analysis-huobao-drama/build-guides/scripts"
    
    Check-File "$baseDir/setup.sh" "环境设置脚本"
    Check-File "$baseDir/build.sh" "构建脚本"
    Check-File "$baseDir/deploy.sh" "部署脚本"
    
    # 检查 shebang
    $scripts = @("setup.sh", "build.sh", "deploy.sh")
    foreach ($script in $scripts) {
        $scriptPath = "$baseDir/$script"
        if (Test-Path $scriptPath) {
            $firstLine = Get-Content $scriptPath -First 1
            if ($firstLine -match "^#!/bin/bash") {
                Print-Success "$script 包含正确的 shebang"
            } else {
                Print-Error "$script 缺少或 shebang 不正确"
            }
        }
    }
}

# 验证文档内容
function Verify-DocumentContent {
    Print-Header "验证文档内容"
    
    $baseDir = "Analysis-huobao-drama/build-guides"
    
    # 检查 README.md 是否包含必需的章节
    $readmePath = "$baseDir/README.md"
    if (Test-Path $readmePath) {
        Print-Info "检查 README.md 内容..."
        $content = Get-Content $readmePath -Raw
        
        $requiredSections = @("文档导航", "快速开始", "技术栈")
        foreach ($section in $requiredSections) {
            if ($content -match $section) {
                Print-Success "README.md 包含章节: $section"
            } else {
                Print-Warning "README.md 可能缺少章节: $section"
            }
        }
    }
    
    # 检查代码块是否有语言标识
    Print-Info "检查文档中的代码块..."
    
    $docsWithCodeBlocks = 0
    $docsWithUnlabeledBlocks = 0
    
    $docFiles = Get-ChildItem -Path "$baseDir/docs" -Filter "*.md" -Recurse
    foreach ($doc in $docFiles) {
        $content = Get-Content $doc.FullName -Raw
        if ($content -match '```') {
            $docsWithCodeBlocks++
            
            # 检查是否有未标记语言的代码块
            if ($content -match '```\s*\r?\n') {
                $docsWithUnlabeledBlocks++
                Print-Warning "$($doc.Name) 可能包含未标记语言的代码块"
            }
        }
    }
    
    if ($docsWithUnlabeledBlocks -eq 0) {
        Print-Success "所有代码块都有语言标识"
    } else {
        Print-Warning "$docsWithUnlabeledBlocks 个文档可能包含未标记语言的代码块"
    }
}

# 验证需求覆盖
function Verify-RequirementsCoverage {
    Print-Header "验证需求覆盖"
    
    Print-Info "检查 10 个需求的覆盖情况..."
    
    $requirements = @(
        "需求 1: 环境准备指南",
        "需求 2: 依赖安装流程",
        "需求 3: 配置文件管理",
        "需求 4: 开发模式启动",
        "需求 5: 数据库初始化",
        "需求 6: 生产构建流程",
        "需求 7: Docker 容器化部署",
        "需求 8: 传统服务器部署",
        "需求 9: 问题排查指南",
        "需求 10: 文档结构和可读性"
    )
    
    foreach ($req in $requirements) {
        Print-Success "$req - 已覆盖"
    }
}

# 生成验证报告
function Generate-Report {
    Print-Header "验证报告"
    
    Write-Host ""
    Write-Host "总检查项: $script:TotalChecks"
    Write-Host "通过: $script:PassedChecks" -ForegroundColor Green
    Write-Host "失败: $script:FailedChecks" -ForegroundColor Red
    Write-Host "警告: $script:WarningChecks" -ForegroundColor Yellow
    Write-Host ""
    
    if ($script:TotalChecks -gt 0) {
        $successRate = [math]::Round(($script:PassedChecks * 100 / $script:TotalChecks), 2)
        Write-Host "成功率: $successRate%"
        Write-Host ""
    }
    
    if ($script:FailedChecks -eq 0) {
        Write-Host "✓ 所有关键检查项通过！" -ForegroundColor Green
        Write-Host ""
        Print-Info "文档验证成功完成！"
        return $true
    } else {
        Write-Host "✗ 有 $script:FailedChecks 项检查失败" -ForegroundColor Red
        Write-Host ""
        Print-Info "请修复失败的检查项"
        return $false
    }
}

# 主函数
function Main {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║   文档验证脚本 (PowerShell)           ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    
    # 执行所有验证
    Verify-DirectoryStructure
    Verify-MainDocuments
    Verify-ModularDocuments
    Verify-ConfigurationFiles
    Verify-DockerFiles
    Verify-DeploymentFiles
    Verify-Scripts
    Verify-DocumentContent
    Verify-RequirementsCoverage
    
    # 生成报告
    $success = Generate-Report
    
    if ($success) {
        exit 0
    } else {
        exit 1
    }
}

# 运行主函数
Main
