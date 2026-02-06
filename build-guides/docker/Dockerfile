# ============================================
# 第一阶段：构建阶段 (Builder Stage)
# ============================================
# 使用 Go 1.23 Alpine 作为基础镜像进行编译
FROM golang:1.23-alpine AS builder

# 设置工作目录
WORKDIR /build

# 安装构建依赖
# - build-base: 提供 GCC 编译器，CGO 编译 SQLite 所需
# - git: Go 模块下载可能需要
# - nodejs npm: 前端构建所需
RUN apk add --no-cache \
    build-base \
    git \
    nodejs \
    npm

# ============================================
# 构建后端
# ============================================
# 复制 Go 模块文件并下载依赖（利用 Docker 缓存层）
COPY huobao-drama/go.mod huobao-drama/go.sum ./
RUN go mod download

# 复制后端源代码
COPY huobao-drama/ ./

# 编译后端可执行文件
# CGO_ENABLED=1: 启用 CGO 以支持 SQLite
# -ldflags="-s -w": 去除调试信息，减小二进制文件大小
# -o: 指定输出文件名
RUN CGO_ENABLED=1 GOOS=linux go build \
    -ldflags="-s -w" \
    -o huobao-server \
    main.go

# ============================================
# 构建前端
# ============================================
# 进入前端目录
WORKDIR /build/web

# 复制前端依赖文件并安装（利用 Docker 缓存层）
COPY huobao-drama/web/package*.json ./
RUN npm install

# 复制前端源代码
COPY huobao-drama/web/ ./

# 构建前端静态资源
RUN npm run build

# ============================================
# 第二阶段：运行阶段 (Runtime Stage)
# ============================================
# 使用轻量级 Alpine 作为运行时基础镜像
FROM alpine:latest

# 安装运行时依赖
# - ca-certificates: HTTPS 请求所需的证书
# - ffmpeg: 视频处理工具
# - tzdata: 时区数据
RUN apk add --no-cache \
    ca-certificates \
    ffmpeg \
    tzdata

# 设置时区为上海（可根据需要修改）
ENV TZ=Asia/Shanghai

# 创建非 root 用户以提高安全性
RUN addgroup -g 1000 huobao && \
    adduser -D -u 1000 -G huobao huobao

# 设置工作目录
WORKDIR /app

# 从 builder 阶段复制后端可执行文件
COPY --from=builder /build/huobao-server .

# 从 builder 阶段复制前端构建产物
COPY --from=builder /build/web/dist ./web/dist

# 创建必要的目录并设置权限
RUN mkdir -p /app/data /app/uploads /app/temp && \
    chown -R huobao:huobao /app

# 切换到非 root 用户
USER huobao

# 暴露应用端口
EXPOSE 8080

# 健康检查
# 每 30 秒检查一次应用是否响应
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1

# 启动命令
CMD ["./huobao-server"]
