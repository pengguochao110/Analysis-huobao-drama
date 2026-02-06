# 实施计划: 项目构建指南

## 概述

本实施计划将创建 Huobao Drama AI 短剧生成平台的完整构建指南文档和相关配置文件。所有文件将存放在 `Analysis-huobao-drama/build-guides/` 目录下，不会修改原项目目录结构。

**文档采用模块化结构**：将大型文档拆分为多个专题文档，按使用流程组织（快速开始 → 开发 → 部署 → 参考），每个文档专注单一主题，便于维护、更新和阅读。

实施将按照从基础到高级的顺序进行：首先创建目录结构和主导航页面，然后逐步完善各个模块化文档，最后创建配置文件和辅助脚本。每个任务都明确引用了对应的需求编号，确保完整覆盖所有需求。

## 任务

- [x] 1. 创建目录结构和主导航页面
  - 创建 `Analysis-huobao-drama/build-guides/` 主目录
  - 创建 `build-guides/docs/` 文档目录
  - 创建 `build-guides/docs/01-getting-started/` 快速开始目录
  - 创建 `build-guides/docs/02-development/` 开发指南目录
  - 创建 `build-guides/docs/03-deployment/` 部署指南目录
  - 创建 `build-guides/docs/04-reference/` 参考资料目录
  - 创建 `build-guides/config/` 配置文件目录
  - 创建 `build-guides/docker/` Docker 文件目录
  - 创建 `build-guides/deploy/` 部署配置目录
  - 创建 `build-guides/scripts/` 辅助脚本目录
  - 创建 README.md 主导航页面，包含文档结构和快速链接
  - 创建 PROCESS.md 用于记录实际构建过程和问题
  - 创建 REFACTORING_SUMMARY.md 记录重构过程和进度
  - _需求: 10.1, 10.4_

- [x] 2. 创建环境准备文档
  - [x] 2.1 创建 environment-setup.md 文档
    - 创建文件 `docs/01-getting-started/environment-setup.md`
    - 列出 Go 1.23+, Node.js 18+, FFmpeg 4.4+ 的明确版本要求
    - 提供 Windows 环境的详细安装说明（包括 Chocolatey 或手动安装）
    - 提供 macOS 环境的安装说明（使用 Homebrew）
    - 提供 Linux 环境的安装说明（apt, yum 等包管理器）
    - 添加环境验证命令（`go version`, `node --version`, `ffmpeg -version`）
    - 说明预期输出格式，帮助用户确认安装成功
    - _需求: 1.1, 1.2, 1.3, 1.4_
  
  - [x] 2.2 添加国内网络优化说明
    - 在 environment-setup.md 中添加网络优化章节
    - 提供 Go 模块代理配置（GOPROXY=https://goproxy.cn,direct）
    - 提供 npm 镜像配置（淘宝镜像或使用 nrm）
    - 提供 pnpm 镜像配置
    - 提供 Docker 镜像加速配置（阿里云、DaoCloud 等）
    - 说明如何验证镜像配置是否生效
    - _需求: 1.5, 7.7_

- [x] 3. 创建依赖安装文档
  - [x] 3.1 创建 dependencies.md 文档 - 后端部分
    - 创建文件 `docs/01-getting-started/dependencies.md`
    - 提供进入后端目录的命令（`cd huobao-drama`）
    - 提供 `go mod download` 命令下载依赖
    - 提供 `go mod verify` 命令验证依赖完整性
    - 说明如何检查依赖安装是否成功
    - _需求: 2.1, 2.2, 2.5_
  
  - [x] 3.2 完善 dependencies.md 文档 - 前端部分
    - 在 dependencies.md 中添加前端依赖安装章节
    - 提供进入前端目录的命令（`cd huobao-drama/web`）
    - 提供 npm 安装命令（`npm install`）
    - 提供 pnpm 安装命令（`pnpm install`）作为替代选择
    - 说明两种包管理器的适用场景
    - 说明依赖安装验证方法（检查 node_modules 目录）
    - _需求: 2.1, 2.3, 2.5_
  
  - [x] 3.3 创建 troubleshooting.md 文档 - 依赖安装错误
    - 创建文件 `docs/01-getting-started/troubleshooting.md`
    - 列出 Go 模块下载失败的错误（网络问题、代理配置）
    - 列出 npm 安装失败的错误（权限问题、网络超时）
    - 列出 CGO 相关的编译错误（Windows 环境常见）
    - 为每个错误提供具体的解决步骤
    - _需求: 2.4_

- [x] 4. 创建配置文件和配置文档
  - [x] 4.1 创建 config.example.yaml 配置模板文件
    - 创建文件 `config/config.example.yaml`
    - 包含数据库配置部分（SQLite 文件路径，如 `./data/huobao.db`）
    - 包含存储配置部分（上传目录 `./uploads`，临时目录 `./temp`）
    - 包含 AI 服务配置部分（API 密钥占位符，服务端点 URL）
    - 包含 FFmpeg 配置部分（可执行文件路径，如 `/usr/bin/ffmpeg`）
    - 包含服务器配置部分（监听端口 8080，运行模式 development/production）
    - 使用 YAML 格式，确保语法正确
    - 添加注释说明每个配置项的作用
    - _需求: 3.1, 3.2, 3.3, 3.4_
  
  - [x] 4.2 创建 configuration.md 文档
    - 创建文件 `docs/02-development/configuration.md`
    - 说明如何将 config.example.yaml 复制到项目目录并重命名为 config.yaml
    - 详细解释每个配置项的作用和可选值
    - 提供不同场景下的配置示例（开发环境 vs 生产环境）
    - 说明敏感信息管理方式（使用环境变量 `${AI_API_KEY}`）
    - 提供配置验证方法（应用启动时的配置检查）
    - 说明配置文件的加载优先级（环境变量 > 配置文件 > 默认值）
    - _需求: 3.5, 3.6, 3.7_

- [x] 5. 创建开发模式文档
  - [x] 5.1 创建 dev-mode.md 文档 - 后端部分
    - 创建文件 `docs/02-development/dev-mode.md`
    - 提供进入后端目录的命令
    - 提供开发模式启动命令（`go run main.go`）
    - 说明后端监听的端口（默认 8080）
    - 说明后端 API 访问地址（`http://localhost:8080`）
    - 说明如何查看后端日志输出
    - _需求: 4.1, 4.5, 4.6_
  
  - [x] 5.2 完善 dev-mode.md 文档 - 前端部分
    - 在 dev-mode.md 中添加前端开发模式章节
    - 提供进入前端目录的命令
    - 提供开发模式启动命令（`npm run dev` 或 `pnpm dev`）
    - 说明前端开发服务器端口（默认 5173）
    - 说明前端访问地址（`http://localhost:5173`）
    - 说明热重载功能（代码变更自动刷新）
    - 说明如何配置代理以连接后端 API
    - _需求: 4.2, 4.4, 4.6_
  
  - [x] 5.3 完善 dev-mode.md 文档 - 并行启动和调试
    - 在 dev-mode.md 中添加并行启动和调试章节
    - 说明如何使用多个终端窗口同时启动前后端
    - 提供使用 tmux 或 screen 的建议（Linux/macOS）
    - 说明如何使用 Windows Terminal 的多标签功能
    - 提供日志查看和过滤方法
    - 说明常见的开发调试技巧
    - _需求: 4.3, 4.5_

- [x] 6. 创建数据库管理文档
  - 创建文件 `docs/02-development/database.md`
  - 说明应用首次启动时的自动数据库初始化机制
  - 说明 SQLite 数据库文件的创建位置（根据配置文件）
  - 说明数据库表结构的自动创建过程（GORM AutoMigrate）
  - 提供手动执行数据库迁移的命令（如果有独立的迁移工具）
  - 说明 SQLite 文件的权限要求（读写权限）
  - 提供 Linux/macOS 下的权限设置命令（`chmod 644`）
  - 提供 Windows 下的权限设置说明
  - 说明 Docker 环境下的数据库持久化配置（卷挂载）
  - 提供数据库重置命令（删除数据库文件并重启应用）
  - 说明如何备份和恢复 SQLite 数据库
  - _需求: 5.1, 5.2, 5.3, 5.4, 5.5_

- [x] 7. 编写生产构建章节
  - [x] 7.1 编写后端生产构建说明
    - 提供进入后端目录的命令
    - 提供 Go 生产构建命令（`CGO_ENABLED=1 go build -o huobao-server cmd/server/main.go`）
    - 说明 CGO_ENABLED=1 的必要性（SQLite 依赖）
    - 说明构建产物的位置和名称（`huobao-server` 可执行文件）
    - 提供跨平台编译的说明（GOOS 和 GOARCH 环境变量）
    - _需求: 6.1, 6.4_
  
  - [x] 7.2 编写前端生产构建说明
    - 提供进入前端目录的命令
    - 提供前端生产构建命令（`npm run build` 或 `pnpm build`）
    - 说明构建产物的位置（`dist/` 目录）
    - 说明构建产物的内容（HTML, CSS, JS, 静态资源）
    - 说明如何配置生产环境的 API 端点
    - _需求: 6.2, 6.4_
  
  - [x] 7.3 添加构建优化和验证说明
    - 说明生产环境配置优化（禁用调试日志，启用缓存）
    - 说明如何减小构建产物大小（代码压缩，Tree Shaking）
    - 提供构建产物验证步骤（运行可执行文件，检查静态资源）
    - 说明如何测试生产构建（本地运行生产版本）
    - 提供构建产物打包说明（创建部署包）
    - _需求: 6.3, 6.5, 6.6_

- [x] 8. 创建 Docker 部署配置和编写部署文档
  - [x] 8.1 创建 Dockerfile 文件
    - 创建文件 `build-guides/Dockerfile`
    - 实现多阶段构建：第一阶段（builder）用于编译
    - Builder 阶段：使用 `golang:1.23-alpine` 作为基础镜像
    - Builder 阶段：复制后端代码并执行 `go build`
    - Builder 阶段：复制前端代码并执行 `npm install` 和 `npm run build`
    - 实现多阶段构建：第二阶段（runtime）用于运行
    - Runtime 阶段：使用 `alpine:latest` 作为基础镜像
    - Runtime 阶段：安装 FFmpeg 运行时依赖
    - Runtime 阶段：从 builder 阶段复制编译产物
    - 配置工作目录、暴露端口（8080）
    - 配置启动命令（CMD）
    - 添加注释说明每个步骤的作用
    - _需求: 7.1, 7.2_
  
  - [x] 8.2 创建 docker-compose.yml 文件
    - 创建文件 `build-guides/docker-compose.yml`
    - 定义 huobao 服务配置
    - 配置构建上下文（指向 Dockerfile）
    - 配置端口映射（8080:8080）
    - 配置卷挂载：数据库文件持久化（`./data:/app/data`）
    - 配置卷挂载：上传文件持久化（`./uploads:/app/uploads`）
    - 配置环境变量（AI_API_KEY 等敏感信息）
    - 配置网络模式（如需访问宿主机 Ollama 服务）
    - 配置重启策略（`restart: unless-stopped`）
    - 添加注释说明配置项
    - _需求: 7.3, 7.4, 7.5, 7.6_
  
  - [x] 8.3 创建 .dockerignore 文件
    - 创建文件 `build-guides/.dockerignore`
    - 添加需要忽略的文件：node_modules/
    - 添加需要忽略的文件：dist/
    - 添加需要忽略的文件：.git/
    - 添加需要忽略的文件：*.log
    - 添加需要忽略的文件：临时文件和缓存
    - 添加注释说明忽略规则的作用
    - _需求: 7.2_
  
  - [x] 8.4 编写 Docker 部署章节
    - 说明 Docker 部署的优势（环境一致性，简化部署）
    - 提供 Docker 镜像构建命令（`docker build -t huobao-drama .`）
    - 提供单容器运行命令（`docker run`）
    - 提供 docker-compose 启动命令（`docker-compose up -d`）
    - 说明如何查看容器日志（`docker logs`）
    - 说明如何进入容器调试（`docker exec`）
    - 说明数据持久化的重要性和卷挂载配置
    - 说明如何配置网络以访问宿主机服务（host.docker.internal）
    - 提供 Docker 镜像加速配置（针对国内网络）
    - 说明如何更新和重启容器
    - _需求: 5.4, 7.7_

- [x] 9. 创建传统服务器部署配置和编写部署文档
  - [x] 9.1 创建 systemd 服务配置文件
    - 创建文件 `build-guides/deploy/huobao.service`
    - 配置 [Unit] 部分：服务描述和依赖关系（After=network.target）
    - 配置 [Service] 部分：服务类型（Type=simple）
    - 配置 [Service] 部分：运行用户（User=huobao）
    - 配置 [Service] 部分：工作目录（WorkingDirectory=/opt/huobao）
    - 配置 [Service] 部分：启动命令（ExecStart=/opt/huobao/huobao-server）
    - 配置 [Service] 部分：重启策略（Restart=on-failure）
    - 配置 [Service] 部分：环境变量文件（EnvironmentFile）
    - 配置 [Install] 部分：启动目标（WantedBy=multi-user.target）
    - 添加注释说明每个配置项
    - _需求: 8.2_
  
  - [x] 9.2 创建 Nginx 反向代理配置示例
    - 创建文件 `build-guides/deploy/nginx.conf`
    - 配置 upstream 后端服务器（localhost:8080）
    - 配置 server 块：监听端口 80
    - 配置 server 块：服务器名称（server_name）
    - 配置 location / 块：反向代理到后端 API
    - 配置 location /static/ 块：直接服务前端静态文件
    - 配置代理头部（X-Real-IP, X-Forwarded-For 等）
    - 配置 gzip 压缩以优化传输
    - 配置缓存策略（静态资源缓存）
    - 添加注释说明配置项
    - _需求: 8.3_
  
  - [x] 9.3 编写传统服务器部署章节
    - 提供 Linux 服务器部署的完整步骤清单
    - 说明如何创建专用用户（useradd huobao）
    - 说明如何设置文件权限（chown, chmod）
    - 说明如何复制构建产物到服务器（scp 或 rsync）
    - 说明如何安装和配置 systemd 服务
    - 提供服务管理命令（systemctl start/stop/restart/status）
    - 提供服务开机自启配置（systemctl enable）
    - 说明如何配置 Nginx 反向代理
    - 说明如何配置 SSL/TLS 证书（Let's Encrypt）
    - 提供日志管理配置（logrotate）
    - 提供日志查看命令（journalctl）
    - 提供 Windows 服务器部署说明（使用 NSSM 或 Windows Service）
    - _需求: 8.1, 8.4, 8.5, 8.6_

- [x] 10. 编写问题排查章节
  - [x] 10.1 添加构建错误排查指南
    - 列出 Go 模块下载失败错误（网络超时，代理问题）
    - 提供 GOPROXY 配置解决方案
    - 列出 CGO 编译错误（Windows 下缺少 GCC）
    - 提供 MinGW 或 TDM-GCC 安装说明
    - 列出前端依赖安装失败错误（npm ERR!）
    - 提供清除缓存和重新安装的解决方案
    - 列出构建脚本权限错误（Linux/macOS）
    - 提供 chmod +x 解决方案
    - _需求: 9.1_
  
  - [x] 10.2 添加运行时错误排查指南
    - 列出常见运行时错误类型和症状
    - 列出 FFmpeg 不可用错误（"ffmpeg: command not found"）
    - 提供 FFmpeg 安装验证步骤
    - 提供配置文件中 FFmpeg 路径设置方法
    - 列出数据库权限错误（"unable to open database file"）
    - 提供 SQLite 文件权限修复命令（chmod 644）
    - 提供数据库目录权限修复命令（chmod 755）
    - 列出端口冲突错误（"address already in use"）
    - 提供端口占用检查命令（netstat, lsof）
    - 提供配置文件中端口修改方法
    - 列出 AI 服务连接错误（API 密钥无效，网络问题）
    - 提供 API 密钥验证和网络诊断方法
    - _需求: 9.2, 9.3, 9.4, 9.5_
  
  - [x] 10.3 添加日志分析和性能优化指导
    - 说明如何查看应用日志（控制台输出，日志文件）
    - 说明日志级别的含义（DEBUG, INFO, WARN, ERROR）
    - 提供日志过滤和搜索技巧（grep, tail -f）
    - 说明如何启用详细日志以诊断问题
    - 列出常见性能问题症状（响应慢，内存占用高）
    - 提供性能分析工具建议（pprof, Chrome DevTools）
    - 提供数据库查询优化建议（索引，查询优化）
    - 提供静态资源优化建议（CDN，缓存）
    - 提供并发处理优化建议（连接池，goroutine 管理）
    - _需求: 9.6, 9.7_

- [x] 11. 创建辅助脚本
  - [x] 11.1 创建环境设置脚本
    - 创建文件 `build-guides/scripts/setup.sh`
    - 添加 shebang（#!/bin/bash）和脚本说明注释
    - 实现环境检查功能：检测 Go 版本
    - 实现环境检查功能：检测 Node.js 版本
    - 实现环境检查功能：检测 FFmpeg 是否安装
    - 实现依赖安装功能：自动执行 `go mod download`
    - 实现依赖安装功能：自动执行 `npm install`
    - 实现配置文件检查：检查 config.yaml 是否存在
    - 实现配置文件检查：如不存在则从 config.example.yaml 复制
    - 提供友好的输出信息（成功、失败、警告）
    - 添加错误处理（set -e）
    - 使脚本可执行（chmod +x）
    - _需求: 1.4_
  
  - [x] 11.2 创建构建脚本
    - 创建文件 `build-guides/scripts/build.sh`
    - 添加 shebang 和脚本说明注释
    - 实现后端构建：执行 `CGO_ENABLED=1 go build`
    - 实现前端构建：执行 `npm run build`
    - 实现构建产物验证：检查可执行文件是否生成
    - 实现构建产物验证：检查 dist/ 目录是否生成
    - 实现构建产物打包：创建部署压缩包
    - 提供构建进度提示信息
    - 添加错误处理和回滚机制
    - 使脚本可执行
    - _需求: 6.4, 6.5_
  
  - [x] 11.3 创建部署脚本
    - 创建文件 `build-guides/scripts/deploy.sh`
    - 添加 shebang 和脚本说明注释
    - 实现服务器连接检查（SSH 连接测试）
    - 实现文件上传功能（使用 scp 或 rsync）
    - 实现远程服务停止（systemctl stop）
    - 实现文件替换和权限设置
    - 实现远程服务启动（systemctl start）
    - 实现健康检查（检查服务是否正常启动）
    - 提供部署进度提示信息
    - 添加回滚机制（部署失败时恢复旧版本）
    - 使脚本可执行
    - _需求: 8.1_

- [x] 12. 完善文档格式和可读性
  - [x] 12.1 添加文档目录和导航
    - 在 BUILD.md 开头添加完整的目录结构
    - 为每个主要章节创建锚点链接
    - 添加"返回目录"链接以便快速导航
    - 确保目录层级清晰（最多 3 级）
    - _需求: 10.4_
  
  - [x] 12.2 优化代码块和示例
    - 确保所有命令都使用代码块标注（```bash）
    - 为所有代码块添加正确的语言标识（bash, yaml, go, etc.）
    - 为关键命令添加说明注释
    - 为复杂步骤提供分步骤的代码示例
    - 确保代码示例可以直接复制使用
    - 为代码示例添加预期输出说明
    - _需求: 10.2, 10.3_
  
  - [x] 12.3 添加信息标记和视觉元素
    - 使用 ℹ️ 图标标记提示信息（Tips）
    - 使用 ⚠️ 图标标记警告信息（Warnings）
    - 使用 ⚡ 图标标记重要注意事项（Important）
    - 使用 💡 图标标记最佳实践建议
    - 为多种选择提供清晰的对比表格
    - 说明每种选择的适用场景和优缺点
    - 使用引用块（>）突出显示关键信息
    - 添加分隔线（---）区分不同主题
    - _需求: 10.5, 10.6_

- [~] 13. 最终检查点和文档验证
  - 验证所有文件已创建在 `Analysis-huobao-drama/build-guides/` 目录
  - 验证目录结构完整（deploy/, scripts/ 子目录）
  - 验证 BUILD.md 文档包含所有必需章节
  - 验证 config.example.yaml 配置文件格式正确且完整
  - 验证 Dockerfile 语法正确且可构建
  - 验证 docker-compose.yml 配置正确
  - 验证 systemd 服务配置文件格式正确
  - 验证 Nginx 配置文件语法正确
  - 验证所有脚本文件具有可执行权限
  - 验证文档中的所有代码块都有语言标识
  - 验证文档中的所有链接和引用都有效
  - 验证所有 10 个需求都已完整覆盖
  - 运行文档结构验证测试（如果有）
  - 询问用户是否有问题或需要调整

## 注意事项

### 文件存放位置
- 所有生成的文件都创建在 `Analysis-huobao-drama/build-guides/` 目录下
- 不修改 `huobao-drama/` 原项目目录的任何文件
- 用户在实际使用时，可以根据指南将配置文件复制到项目目录

### 文档编写原则
- 文档使用中文编写，面向中文开发者
- 提供详细的分步骤指导，适合不熟悉项目的开发者
- 包含可直接复制使用的命令和配置示例
- 考虑不同操作系统的差异（Windows, macOS, Linux）
- 考虑国内网络环境的特殊性（镜像加速配置）

### 任务执行顺序
- 按照任务编号顺序执行，确保依赖关系正确
- 每个主要任务完成后，验证生成的文件内容
- 在编写文档章节时，参考设计文档中的内容结构
- 在创建配置文件时，参考设计文档中的数据模型

### 需求覆盖验证
- 每个任务都明确标注了对应的需求编号
- 完成任务时，确保满足所有引用的需求验收标准
- 最终检查点会验证所有 10 个需求是否完整覆盖

### 文档质量标准
- 代码块必须有正确的语言标识
- 命令必须可以直接复制执行
- 配置文件必须是有效的 YAML/JSON 格式
- 脚本文件必须有可执行权限
- 使用信息标记（提示、警告、注意）增强可读性
