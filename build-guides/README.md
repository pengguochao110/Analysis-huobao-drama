# Huobao Drama AI 短剧生成平台 - 构建指南

欢迎使用 Huobao Drama AI 短剧生成平台！本指南将帮助您从零开始搭建开发环境、配置项目、进行开发和部署。

## 📚 文档导航

### 🚀 快速开始

如果您是第一次使用本项目，请按以下顺序阅读：

1. **[环境准备](docs/01-getting-started/environment-setup.md)** - 安装必需的软件和工具
2. **[依赖安装](docs/01-getting-started/dependencies.md)** - 安装后端和前端依赖
3. **[配置设置](docs/02-development/configuration.md)** - 配置数据库、存储和 AI 服务
4. **[开发模式](docs/02-development/dev-mode.md)** - 启动开发环境

### 📖 完整文档目录

#### 01. 快速开始 (Getting Started)

- [环境准备](docs/01-getting-started/environment-setup.md)
  - 必需软件和版本要求
  - Windows/macOS/Linux 安装说明
  - 环境验证
  - 国内网络优化配置

- [依赖安装](docs/01-getting-started/dependencies.md)
  - 后端 Go 依赖安装
  - 前端 npm/pnpm 依赖安装
  - 依赖验证方法

- [常见问题排查](docs/01-getting-started/troubleshooting.md)
  - Go 模块下载失败
  - npm 安装错误
  - CGO 编译问题
  - 权限和网络问题

#### 02. 开发指南 (Development)

- [配置详解](docs/02-development/configuration.md)
  - 配置文件模板
  - 数据库配置
  - 存储配置
  - AI 服务配置
  - FFmpeg 配置
  - 敏感信息管理

- [开发模式](docs/02-development/dev-mode.md)
  - 后端开发模式启动
  - 前端开发模式启动
  - 并行启动和调试
  - 热重载配置

- [数据库管理](docs/02-development/database.md)
  - 数据库初始化
  - 手动迁移
  - 权限设置
  - Docker 环境配置
  - 数据库备份和恢复

#### 03. 部署指南 (Deployment)

- [生产构建](docs/03-deployment/production-build.md)
  - 后端构建
  - 前端构建
  - 构建优化
  - 跨平台编译
  - 构建验证

- [Docker 部署](docs/03-deployment/docker.md)
  - Dockerfile 说明
  - 多阶段构建
  - docker-compose 配置
  - 数据持久化
  - 网络配置
  - 容器管理

- [传统服务器部署](docs/03-deployment/traditional.md)
  - Linux 服务器部署
  - systemd 服务配置
  - Nginx 反向代理
  - SSL/TLS 配置
  - 日志管理
  - Windows 服务器部署

#### 04. 参考资料 (Reference)

- [问题排查](docs/04-reference/troubleshooting.md)
  - 构建错误
  - 运行时错误
  - FFmpeg 问题
  - 数据库问题
  - 网络问题

- [性能优化](docs/04-reference/optimization.md)
  - 日志分析
  - 性能调优
  - 资源优化

## 🎯 快速链接

### 常用命令

```bash
# 后端依赖安装
cd huobao-drama
go mod download

# 前端依赖安装
cd huobao-drama/web
npm install  # 或 pnpm install

# 启动开发环境
# 后端（在 huobao-drama/ 目录）
go run main.go

# 前端（在 huobao-drama/web/ 目录）
npm run dev  # 或 pnpm dev
```

### 配置文件

- [config.example.yaml](config/config.example.yaml) - 配置文件模板
- [Dockerfile](docker/Dockerfile) - Docker 镜像构建文件
- [docker-compose.yml](docker/docker-compose.yml) - Docker Compose 配置
- [huobao.service](deploy/huobao.service) - systemd 服务配置
- [nginx.conf](deploy/nginx.conf) - Nginx 反向代理配置

### 辅助脚本

- [setup.sh](scripts/setup.sh) - 环境设置脚本
- [build.sh](scripts/build.sh) - 构建脚本
- [deploy.sh](scripts/deploy.sh) - 部署脚本

## 💡 使用建议

### 新手用户

1. 从[环境准备](docs/01-getting-started/environment-setup.md)开始
2. 按顺序完成快速开始部分的所有步骤
3. 遇到问题查看[常见问题排查](docs/01-getting-started/troubleshooting.md)

### 有经验的开发者

1. 快速浏览[环境准备](docs/01-getting-started/environment-setup.md)确认版本要求
2. 直接跳到[依赖安装](docs/01-getting-started/dependencies.md)
3. 根据需要查阅[开发指南](docs/02-development/)或[部署指南](docs/03-deployment/)

### 运维人员

1. 查看[生产构建](docs/03-deployment/production-build.md)了解构建流程
2. 选择部署方式：
   - [Docker 部署](docs/03-deployment/docker.md)（推荐）
   - [传统服务器部署](docs/03-deployment/traditional.md)
3. 参考[问题排查](docs/04-reference/troubleshooting.md)解决常见问题

## 🔧 技术栈

| 组件 | 技术 | 版本要求 |
|------|------|---------|
| **后端** | Go + Gin | Go 1.23+ |
| **前端** | Vue 3 + TypeScript + Vite | Node.js 18+ |
| **数据库** | SQLite | - |
| **视频处理** | FFmpeg | 4.4+ |
| **容器化** | Docker | - |

## 📞 获取帮助

- **GitHub Issues**: [提交问题](https://github.com/your-repo/huobao-drama/issues)
- **文档问题**: 如果文档有错误或不清楚的地方，欢迎提交 PR
- **社区讨论**: [加入讨论](https://github.com/your-repo/huobao-drama/discussions)

## 📝 贡献指南

欢迎贡献！请查看[贡献指南](https://github.com/your-repo/huobao-drama/blob/main/CONTRIBUTING.md)了解如何参与项目。

## 📄 许可证

本项目采用 [MIT License](https://github.com/your-repo/huobao-drama/blob/main/LICENSE)。

---

**最后更新**: 2026-02-05

**文档版本**: 1.0.0
