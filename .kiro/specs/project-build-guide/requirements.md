# 需求文档 - 项目构建指南

## 简介

本文档定义了 Huobao Drama AI 短剧生成平台的完整项目构建指南需求。该平台是一个基于 Go + Vue3 的全栈 AI 短剧自动化生产系统，采用 DDD 领域驱动设计，实现从剧本生成、角色设计、分镜制作到视频合成的全流程自动化。

构建指南旨在为开发者提供清晰、可执行的步骤，涵盖环境准备、依赖安装、配置设置、开发启动、生产构建、部署方案和问题排查等完整流程。

## 术语表

- **Build_System**: 项目构建系统，负责管理依赖、编译代码和生成可部署产物
- **Development_Environment**: 开发环境，用于本地开发和调试的运行环境
- **Production_Environment**: 生产环境，用于实际部署和运行的环境
- **Backend_Service**: 后端服务，基于 Go + Gin 的 API 服务
- **Frontend_Application**: 前端应用，基于 Vue3 + TypeScript 的 Web 应用
- **FFmpeg**: 开源视频处理工具，用于视频编码、转码和合成
- **Docker_Container**: Docker 容器，用于应用的容器化部署
- **Configuration_File**: 配置文件，包含数据库、存储、AI 服务等配置信息
- **Dependency_Manager**: 依赖管理器，Go 使用 go mod，前端使用 npm/pnpm
- **Database_Migration**: 数据库迁移，管理数据库结构变更
- **Hot_Reload**: 热重载，开发模式下代码变更自动重启服务

## 需求

### 需求 1: 环境准备指南

**用户故事**: 作为开发者，我想要清晰了解所需的软件环境和版本要求，以便正确配置开发环境。

#### 验收标准

1. THE Build_System SHALL 列出所有必需的软件依赖及其最低版本要求
2. WHEN 开发者查看环境要求时，THE Build_System SHALL 提供 Go 1.23+、Node.js 18+、FFmpeg 的安装说明
3. WHERE 在 Windows 环境下，THE Build_System SHALL 提供特定的环境配置说明
4. THE Build_System SHALL 提供环境验证命令以确认安装成功
5. WHEN 开发者在国内网络环境时，THE Build_System SHALL 提供镜像加速配置说明

### 需求 2: 依赖安装流程

**用户故事**: 作为开发者，我想要正确安装后端和前端的所有依赖，以便能够运行项目。

#### 验收标准

1. WHEN 开发者执行依赖安装命令时，THE Dependency_Manager SHALL 下载并安装所有必需的包
2. THE Build_System SHALL 提供后端 Go 模块依赖的安装步骤
3. THE Build_System SHALL 提供前端 npm/pnpm 依赖的安装步骤
4. IF 依赖安装失败，THEN THE Build_System SHALL 提供常见错误的解决方案
5. THE Build_System SHALL 说明如何验证依赖安装的完整性

### 需求 3: 配置文件管理

**用户故事**: 作为开发者，我想要正确配置数据库、存储、AI 服务等，以便系统能够正常运行。

#### 验收标准

1. THE Configuration_File SHALL 包含数据库连接配置（SQLite 文件路径和权限）
2. THE Configuration_File SHALL 包含文件存储路径配置（上传目录、临时目录）
3. THE Configuration_File SHALL 包含 AI 服务配置（API 密钥、服务端点）
4. THE Configuration_File SHALL 包含 FFmpeg 可执行文件路径配置
5. WHEN 配置文件不存在时，THE Build_System SHALL 提供配置模板和示例
6. THE Build_System SHALL 说明敏感信息（API 密钥）的安全管理方式
7. THE Build_System SHALL 提供配置验证机制以检测配置错误

### 需求 4: 开发模式启动

**用户故事**: 作为开发者，我想要在开发环境中启动前后端服务，以便进行开发和调试。

#### 验收标准

1. WHEN 开发者执行启动命令时，THE Backend_Service SHALL 在开发模式下启动并监听指定端口
2. WHEN 开发者执行启动命令时，THE Frontend_Application SHALL 在开发模式下启动并启用 Hot_Reload
3. THE Development_Environment SHALL 支持后端和前端的并行启动
4. WHEN 代码文件变更时，THE Development_Environment SHALL 自动重新编译和重启服务
5. THE Build_System SHALL 提供日志输出以显示服务启动状态
6. THE Build_System SHALL 说明如何访问开发环境的前端和后端服务

### 需求 5: 数据库初始化

**用户故事**: 作为开发者，我想要正确初始化数据库结构，以便应用能够正常存储和读取数据。

#### 验收标准

1. WHEN 首次启动应用时，THE Database_Migration SHALL 自动创建 SQLite 数据库文件
2. THE Database_Migration SHALL 执行所有必需的表结构创建
3. THE Build_System SHALL 确保 SQLite 文件具有正确的读写权限
4. WHERE 在 Docker 环境中，THE Build_System SHALL 确保数据库文件持久化到卷
5. THE Build_System SHALL 提供数据库重置和迁移的命令

### 需求 6: 生产构建流程

**用户故事**: 作为开发者，我想要构建生产环境的可部署版本，以便部署到服务器。

#### 验收标准

1. WHEN 开发者执行构建命令时，THE Build_System SHALL 编译后端 Go 代码为可执行文件
2. WHEN 开发者执行构建命令时，THE Build_System SHALL 构建前端静态资源
3. THE Build_System SHALL 优化生产构建产物的大小和性能
4. THE Build_System SHALL 生成包含所有必需文件的部署包
5. THE Build_System SHALL 提供构建产物的验证步骤
6. THE Production_Environment SHALL 使用优化的配置（禁用调试、启用缓存）

### 需求 7: Docker 容器化部署

**用户故事**: 作为运维人员，我想要使用 Docker 进行容器化部署，以便简化部署流程和环境管理。

#### 验收标准

1. THE Docker_Container SHALL 包含所有运行时依赖（Go 运行时、FFmpeg）
2. WHEN 构建 Docker 镜像时，THE Build_System SHALL 使用多阶段构建以减小镜像大小
3. THE Docker_Container SHALL 正确映射端口以允许外部访问
4. THE Docker_Container SHALL 挂载卷以持久化数据库和上传文件
5. WHERE 需要访问宿主机服务（如 Ollama）时，THE Docker_Container SHALL 配置网络以允许访问
6. THE Build_System SHALL 提供 docker-compose 配置以简化多容器编排
7. THE Build_System SHALL 说明如何配置 Docker 镜像加速（针对国内网络）

### 需求 8: 传统服务器部署

**用户故事**: 作为运维人员，我想要在服务器上进行传统方式部署，以便在不使用 Docker 的环境中运行应用。

#### 验收标准

1. THE Build_System SHALL 提供在 Linux 服务器上部署的完整步骤
2. THE Build_System SHALL 说明如何配置系统服务（systemd）以自动启动应用
3. THE Build_System SHALL 提供反向代理配置示例（Nginx/Caddy）
4. THE Build_System SHALL 说明如何配置文件权限和用户权限
5. THE Build_System SHALL 提供日志管理和轮转配置
6. WHERE 在 Windows 服务器上，THE Build_System SHALL 提供 Windows 服务配置说明

### 需求 9: 问题排查指南

**用户故事**: 作为开发者，我想要在遇到常见问题时能够快速解决，以便减少调试时间。

#### 验收标准

1. THE Build_System SHALL 列出常见的构建错误及其解决方案
2. THE Build_System SHALL 列出常见的运行时错误及其解决方案
3. WHEN FFmpeg 不可用时，THE Build_System SHALL 提供诊断和修复步骤
4. WHEN 数据库权限错误时，THE Build_System SHALL 提供权限修复命令
5. WHEN 端口冲突时，THE Build_System SHALL 说明如何更改端口配置
6. THE Build_System SHALL 提供日志查看和分析的指导
7. THE Build_System SHALL 提供性能问题的排查思路

### 需求 10: 文档结构和可读性

**用户故事**: 作为开发者，我想要文档结构清晰、易于导航，以便快速找到所需信息。

#### 验收标准

1. THE Build_System SHALL 使用清晰的章节结构组织文档内容
2. THE Build_System SHALL 为每个主要步骤提供代码示例
3. THE Build_System SHALL 使用代码块标注命令和配置
4. THE Build_System SHALL 提供目录以快速导航到特定章节
5. THE Build_System SHALL 使用图标或标记区分不同类型的信息（提示、警告、注意）
6. WHERE 有多种选择时，THE Build_System SHALL 清晰说明每种选择的适用场景
