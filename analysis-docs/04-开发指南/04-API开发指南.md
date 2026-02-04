# 04-API开发指南

本文档详细介绍如何在火宝短剧项目中开发和测试 REST API。

---

## 1. 新增API完整步骤

### 1.1 定义Request/Response DTO结构体

在应用层定义数据传输对象（DTO）：

```go
// application/services/drama_service.go

// CreateDramaRequest 创建剧本请求
type CreateDramaRequest struct {
    Title       string `json:"title" binding:"required,min=1,max=100"`
    Description string `json:"description" binding:"omitempty,max=500"`
    Genre       string `json:"genre" binding:"omitempty,oneof=ancient modern suspense romance"`
    TotalEpisodes int  `json:"total_episodes" binding:"omitempty,min=1,max=100"`
}

// UpdateDramaRequest 更新剧本请求
type UpdateDramaRequest struct {
    Title       string `json:"title" binding:"omitempty,min=1,max=100"`
    Description string `json:"description" binding:"omitempty,max=500"`
    Genre       string `json:"genre" binding:"omitempty,oneof=ancient modern suspense romance"`
    Status      string `json:"status" binding:"omitempty,oneof=draft planning production completed archived"`
}

// DramaListQuery 剧本列表查询参数
type DramaListQuery struct {
    Page     int    `form:"page,default=1" binding:"omitempty,min=1"`
    PageSize int    `form:"page_size,default=20" binding:"omitempty,min=1,max=100"`
    Status   string `form:"status" binding:"omitempty,oneof=draft planning production completed archived"`
    Genre    string `form:"genre" binding:"omitempty"`
    Keyword  string `form:"keyword" binding:"omitempty,max=100"`
}

// DramaResponse 剧本响应数据
type DramaResponse struct {
    ID            uint      `json:"id"`
    Title         string    `json:"title"`
    Description   *string   `json:"description"`
    Genre         *string   `json:"genre"`
    TotalEpisodes int       `json:"total_episodes"`
    Status        string    `json:"status"`
    CreatedAt     time.Time `json:"created_at"`
    UpdatedAt     time.Time `json:"updated_at"`
}
```

### 1.2 创建Handler方法

创建 HTTP 处理器：

```go
// api/handlers/drama.go

package handlers

import (
    "github.com/drama-generator/backend/application/services"
    "github.com/drama-generator/backend/pkg/logger"
    "github.com/drama-generator/backend/pkg/response"
    "github.com/gin-gonic/gin"
    "gorm.io/gorm"
)

type DramaHandler struct {
    db         *gorm.DB
    service    *services.DramaService
    log        *logger.Logger
}

func NewDramaHandler(db *gorm.DB, cfg *config.Config, log *logger.Logger) *DramaHandler {
    return &DramaHandler{
        db:      db,
        service: services.NewDramaService(db, cfg, log),
        log:     log,
    }
}

// CreateDrama 创建剧本
func (h *DramaHandler) CreateDrama(c *gin.Context) {
    var req services.CreateDramaRequest
    
    // 参数绑定与验证
    if err := c.ShouldBindJSON(&req); err != nil {
        h.log.Warnw("参数验证失败", "error", err)
        response.BadRequest(c, err.Error())
        return
    }
    
    // 调用服务层
    drama, err := h.service.CreateDrama(&req)
    if err != nil {
        h.log.Errorw("创建剧本失败", "error", err)
        response.InternalError(c, "创建剧本失败")
        return
    }
    
    // 返回响应
    response.Created(c, drama)
}

// GetDrama 获取剧本详情
func (h *DramaHandler) GetDrama(c *gin.Context) {
    // 从 URL 参数获取 ID
    dramaID := c.Param("id")
    
    drama, err := h.service.GetDrama(dramaID)
    if err != nil {
        if err.Error() == "drama not found" {
            response.NotFound(c, "剧本不存在")
            return
        }
        h.log.Errorw("获取剧本失败", "error", err, "drama_id", dramaID)
        response.InternalError(c, "获取剧本失败")
        return
    }
    
    response.Success(c, drama)
}

// ListDramas 获取剧本列表
func (h *DramaHandler) ListDramas(c *gin.Context) {
    var query services.DramaListQuery
    
    // 绑定查询参数
    if err := c.ShouldBindQuery(&query); err != nil {
        response.BadRequest(c, err.Error())
        return
    }
    
    // 设置默认值
    if query.Page < 1 {
        query.Page = 1
    }
    if query.PageSize < 1 || query.PageSize > 100 {
        query.PageSize = 20
    }
    
    dramas, total, err := h.service.ListDramas(&query)
    if err != nil {
        h.log.Errorw("查询剧本列表失败", "error", err)
        response.InternalError(c, "查询失败")
        return
    }
    
    response.SuccessWithPagination(c, dramas, total, query.Page, query.PageSize)
}

// UpdateDrama 更新剧本
func (h *DramaHandler) UpdateDrama(c *gin.Context) {
    dramaID := c.Param("id")
    
    var req services.UpdateDramaRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        response.BadRequest(c, err.Error())
        return
    }
    
    drama, err := h.service.UpdateDrama(dramaID, &req)
    if err != nil {
        if err.Error() == "drama not found" {
            response.NotFound(c, "剧本不存在")
            return
        }
        h.log.Errorw("更新剧本失败", "error", err)
        response.InternalError(c, "更新失败")
        return
    }
    
    response.Success(c, drama)
}

// DeleteDrama 删除剧本
func (h *DramaHandler) DeleteDrama(c *gin.Context) {
    dramaID := c.Param("id")
    
    if err := h.service.DeleteDrama(dramaID); err != nil {
        if err.Error() == "drama not found" {
            response.NotFound(c, "剧本不存在")
            return
        }
        response.InternalError(c, "删除失败")
        return
    }
    
    response.Success(c, gin.H{"message": "删除成功"})
}
```

### 1.3 注册路由

在 `routes.go` 中注册路由：

```go
// api/routes/routes.go

func SetupRouter(cfg *config.Config, db *gorm.DB, logr *logger.Logger, localStorage interface{}) *gin.Engine {
    r := gin.New()
    
    // 中间件
    r.Use(gin.Recovery())
    r.Use(middlewares2.LoggerMiddleware(logr))
    r.Use(middlewares2.CORSMiddleware(cfg.Server.CORSOrigins))
    
    // 初始化 Handler
    dramaHandler := handlers2.NewDramaHandler(db, cfg, logr)
    
    // API 路由组
    api := r.Group("/api/v1")
    {
        api.Use(middlewares2.RateLimitMiddleware())
        
        // 剧本路由组
        dramas := api.Group("/dramas")
        {
            dramas.GET("", dramaHandler.ListDramas)          // 列表查询
            dramas.POST("", dramaHandler.CreateDrama)        // 创建
            dramas.GET("/:id", dramaHandler.GetDrama)        // 详情
            dramas.PUT("/:id", dramaHandler.UpdateDrama)   // 更新
            dramas.DELETE("/:id", dramaHandler.DeleteDrama)  // 删除
        }
    }
    
    return r
}
```

### 1.4 返回统一响应格式

项目使用统一的响应格式：

```go
// pkg/response/response.go

// 成功响应
{
    "success": true,
    "data": {
        "id": 1,
        "title": "测试剧本"
    },
    "timestamp": "2026-02-04T10:00:00Z"
}

// 错误响应
{
    "success": false,
    "error": {
        "code": "NOT_FOUND",
        "message": "剧本不存在"
    },
    "timestamp": "2026-02-04T10:00:00Z"
}

// 分页响应
{
    "success": true,
    "data": {
        "items": [...],
        "pagination": {
            "page": 1,
            "page_size": 20,
            "total": 100,
            "total_pages": 5
        }
    },
    "timestamp": "2026-02-04T10:00:00Z"
}
```

---

## 2. Handler编写规范

### 2.1 请求验证

#### binding标签使用

```go
type CreateDramaRequest struct {
    Title       string `json:"title" binding:"required,min=1,max=100"`
    Description string `json:"description" binding:"omitempty,max=500"`
    Genre       string `json:"genre" binding:"omitempty,oneof=ancient modern suspense romance"`
    Episodes    int    `json:"episodes" binding:"omitempty,min=1,max=100"`
    Email       string `json:"email" binding:"omitempty,email"`
    URL         string `json:"url" binding:"omitempty,url"`
}
```

#### 常用验证标签

| 标签 | 说明 | 示例 |
|------|------|------|
| `required` | 必填 | `binding:"required"` |
| `min` | 最小值 | `binding:"min=1"` |
| `max` | 最大值 | `binding:"max=100"` |
| `oneof` | 枚举值 | `binding:"oneof=a b c"` |
| `email` | 邮箱格式 | `binding:"email"` |
| `url` | URL格式 | `binding:"url"` |
| `alphanum` | 字母数字 | `binding:"alphanum"` |
| `numeric` | 数字 | `binding:"numeric"` |
| `gt` | 大于 | `binding:"gt=0"` |
| `gte` | 大于等于 | `binding:"gte=1"` |
| `lt` | 小于 | `binding:"lt=100"` |
| `lte` | 小于等于 | `binding:"lte=100"` |
| `len` | 固定长度 | `binding:"len=10"` |

#### 自定义验证函数

```go
// 注册自定义验证器
import "github.com/go-playground/validator/v10"

func init() {
    if v, ok := binding.Validator.Engine().(*validator.Validate); ok {
        v.RegisterValidation("isvalidstatus", validateStatus)
    }
}

// 状态验证
func validateStatus(fl validator.FieldLevel) bool {
    status := fl.Field().String()
    validStatuses := []string{"draft", "planning", "production", "completed", "archived"}
    
    for _, s := range validStatuses {
        if status == s {
            return true
        }
    }
    return false
}

// 使用自定义验证
type DramaRequest struct {
    Status string `json:"status" binding:"required,isvalidstatus"`
}
```

### 2.2 错误处理

#### 错误码定义

```go
// 统一错误码
const (
    ErrCodeBadRequest     = "BAD_REQUEST"
    ErrCodeUnauthorized   = "UNAUTHORIZED"
    ErrCodeForbidden      = "FORBIDDEN"
    ErrCodeNotFound       = "NOT_FOUND"
    ErrCodeInternalError  = "INTERNAL_ERROR"
    ErrCodeRateLimit      = "RATE_LIMIT"
    ErrCodeValidation     = "VALIDATION_ERROR"
    ErrCodeDatabase       = "DATABASE_ERROR"
)

// 业务错误码（可选）
const (
    ErrCodeDramaNotFound    = "DRAMA_NOT_FOUND"
    ErrCodeEpisodeNotFound  = "EPISODE_NOT_FOUND"
    ErrCodeInvalidStatus    = "INVALID_STATUS"
)
```

#### 错误消息返回

```go
func (h *DramaHandler) GetDrama(c *gin.Context) {
    dramaID := c.Param("id")
    
    drama, err := h.service.GetDrama(dramaID)
    if err != nil {
        switch {
        case errors.Is(err, services.ErrDramaNotFound):
            response.NotFound(c, "剧本不存在")
        case errors.Is(err, services.ErrInvalidID):
            response.BadRequest(c, "无效的剧本ID")
        default:
            h.log.Errorw("获取剧本失败", "error", err, "drama_id", dramaID)
            response.InternalError(c, "服务器内部错误")
        }
        return
    }
    
    response.Success(c, drama)
}
```

### 2.3 响应格式

#### 统一JSON结构

```go
// pkg/response/response.go

package response

import (
    "net/http"
    "time"
    
    "github.com/gin-gonic/gin"
)

type Response struct {
    Success   bool        `json:"success"`
    Data      interface{} `json:"data,omitempty"`
    Error     *ErrorInfo  `json:"error,omitempty"`
    Message   string      `json:"message,omitempty"`
    Timestamp string      `json:"timestamp"`
}

type ErrorInfo struct {
    Code    string      `json:"code"`
    Message string      `json:"message"`
    Details interface{} `json:"details,omitempty"`
}

type PaginationData struct {
    Items      interface{} `json:"items"`
    Pagination Pagination  `json:"pagination"`
}

type Pagination struct {
    Page       int   `json:"page"`
    PageSize   int   `json:"page_size"`
    Total      int64 `json:"total"`
    TotalPages int64 `json:"total_pages"`
}

// Success 成功响应
func Success(c *gin.Context, data interface{}) {
    c.JSON(http.StatusOK, Response{
        Success:   true,
        Data:      data,
        Timestamp: time.Now().UTC().Format(time.RFC3339),
    })
}

// SuccessWithPagination 分页成功响应
func SuccessWithPagination(c *gin.Context, items interface{}, total int64, page int, pageSize int) {
    totalPages := (total + int64(pageSize) - 1) / int64(pageSize)
    c.JSON(http.StatusOK, Response{
        Success: true,
        Data: PaginationData{
            Items: items,
            Pagination: Pagination{
                Page:       page,
                PageSize:   pageSize,
                Total:      total,
                TotalPages: totalPages,
            },
        },
        Timestamp: time.Now().UTC().Format(time.RFC3339),
    })
}

// Created 创建成功响应
func Created(c *gin.Context, data interface{}) {
    c.JSON(http.StatusCreated, Response{
        Success:   true,
        Data:      data,
        Timestamp: time.Now().UTC().Format(time.RFC3339),
    })
}

// Error 错误响应
func Error(c *gin.Context, statusCode int, errCode string, message string) {
    c.JSON(statusCode, Response{
        Success: false,
        Error: &ErrorInfo{
            Code:    errCode,
            Message: message,
        },
        Timestamp: time.Now().UTC().Format(time.RFC3339),
    })
}

// 快捷方法
func BadRequest(c *gin.Context, message string) {
    Error(c, http.StatusBadRequest, "BAD_REQUEST", message)
}

func NotFound(c *gin.Context, message string) {
    Error(c, http.StatusNotFound, "NOT_FOUND", message)
}

func InternalError(c *gin.Context, message string) {
    Error(c, http.StatusInternalServerError, "INTERNAL_ERROR", message)
}
```

### 2.4 日志记录

#### 请求日志

```go
func (h *DramaHandler) CreateDrama(c *gin.Context) {
    var req services.CreateDramaRequest
    
    // 记录请求
    h.log.Infow("创建剧本请求",
        "ip", c.ClientIP(),
        "method", c.Request.Method,
        "path", c.Request.URL.Path,
    )
    
    if err := c.ShouldBindJSON(&req); err != nil {
        h.log.Warnw("参数验证失败",
            "error", err,
            "body", c.Request.Body,
        )
        response.BadRequest(c, err.Error())
        return
    }
    
    // 记录请求参数（脱敏）
    h.log.Debugw("请求参数",
        "title", req.Title,
        "genre", req.Genre,
    )
    
    drama, err := h.service.CreateDrama(&req)
    if err != nil {
        h.log.Errorw("创建剧本失败",
            "error", err,
            "request", req,
        )
        response.InternalError(c, "创建失败")
        return
    }
    
    // 记录成功
    h.log.Infow("剧本创建成功",
        "drama_id", drama.ID,
        "title", drama.Title,
    )
    
    response.Created(c, drama)
}
```

#### 性能日志

```go
func PerformanceMiddleware() gin.HandlerFunc {
    return func(c *gin.Context) {
        start := time.Now()
        
        c.Next()
        
        duration := time.Since(start)
        log.Infow("API请求性能",
            "method", c.Request.Method,
            "path", c.Request.URL.Path,
            "status", c.Writer.Status(),
            "duration_ms", duration.Milliseconds(),
            "client_ip", c.ClientIP(),
        )
    }
}
```

---

## 3. 中间件使用

### 3.1 内置中间件

项目已配置以下内置中间件：

```go
// CORS 跨域处理
// api/middlewares/cors.go
func CORSMiddleware(origins []string) gin.HandlerFunc {
    return func(c *gin.Context) {
        origin := c.GetHeader("Origin")
        
        // 检查是否允许
        allowed := false
        for _, o := range origins {
            if origin == o || o == "*" {
                allowed = true
                break
            }
        }
        
        if allowed {
            c.Header("Access-Control-Allow-Origin", origin)
            c.Header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
            c.Header("Access-Control-Allow-Headers", "Content-Type, Authorization, X-Request-ID")
            c.Header("Access-Control-Allow-Credentials", "true")
        }
        
        if c.Request.Method == "OPTIONS" {
            c.AbortWithStatus(204)
            return
        }
        
        c.Next()
    }
}

// 日志中间件
// api/middlewares/logger.go
func LoggerMiddleware(log *logger.Logger) gin.HandlerFunc {
    return func(c *gin.Context) {
        start := time.Now()
        path := c.Request.URL.Path
        
        c.Next()
        
        latency := time.Since(start)
        statusCode := c.Writer.Status()
        
        log.Infow("HTTP请求",
            "status", statusCode,
            "latency_ms", latency.Milliseconds(),
            "client_ip", c.ClientIP(),
            "method", c.Request.Method,
            "path", path,
            "error", c.Errors.String(),
        )
    }
}

// Recovery 错误恢复
// 使用 Gin 内置的 gin.Recovery()
```

### 3.2 自定义中间件

#### 认证中间件（示例）

```go
// api/middlewares/auth.go
func AuthMiddleware() gin.HandlerFunc {
    return func(c *gin.Context) {
        token := c.GetHeader("Authorization")
        if token == "" {
            response.Unauthorized(c, "缺少认证令牌")
            c.Abort()
            return
        }
        
        // 验证 token
        userID, err := validateToken(token)
        if err != nil {
            response.Unauthorized(c, "无效的认证令牌")
            c.Abort()
            return
        }
        
        // 将用户信息存入上下文
        c.Set("user_id", userID)
        c.Next()
    }
}
```

#### 限流中间件

```go
// api/middlewares/ratelimit.go
import (
    "net/http"
    "sync"
    "time"
    
    "github.com/gin-gonic/gin"
)

type RateLimiter struct {
    visitors map[string]*Visitor
    mu       sync.RWMutex
    rate     int           // 每秒请求数
    burst    int           // 突发请求数
}

type Visitor struct {
    tokens   int
    lastSeen time.Time
}

func NewRateLimiter(rate, burst int) *RateLimiter {
    limiter := &RateLimiter{
        visitors: make(map[string]*Visitor),
        rate:     rate,
        burst:    burst,
    }
    
    // 定期清理过期访客
    go limiter.cleanupVisitors()
    
    return limiter
}

func (rl *RateLimiter) Allow(ip string) bool {
    rl.mu.Lock()
    defer rl.mu.Unlock()
    
    visitor, exists := rl.visitors[ip]
    if !exists {
        visitor = &Visitor{
            tokens:   rl.burst - 1,
            lastSeen: time.Now(),
        }
        rl.visitors[ip] = visitor
        return true
    }
    
    // 更新令牌桶
    elapsed := time.Since(visitor.lastSeen).Seconds()
    visitor.tokens = min(rl.burst, visitor.tokens+int(elapsed*float64(rl.rate)))
    visitor.lastSeen = time.Now()
    
    if visitor.tokens > 0 {
        visitor.tokens--
        return true
    }
    
    return false
}

func RateLimitMiddleware() gin.HandlerFunc {
    limiter := NewRateLimiter(10, 20) // 每秒10个请求，突发20个
    
    return func(c *gin.Context) {
        ip := c.ClientIP()
        
        if !limiter.Allow(ip) {
            c.JSON(http.StatusTooManyRequests, gin.H{
                "error": "请求过于频繁，请稍后再试",
            })
            c.Abort()
            return
        }
        
        c.Next()
    }
}
```

#### 请求ID中间件

```go
// api/middlewares/requestid.go
import (
    "github.com/gin-gonic/gin"
    "github.com/google/uuid"
)

func RequestIDMiddleware() gin.HandlerFunc {
    return func(c *gin.Context) {
        // 从请求头获取或生成
        requestID := c.GetHeader("X-Request-ID")
        if requestID == "" {
            requestID = uuid.New().String()
        }
        
        // 存入上下文
        c.Set("request_id", requestID)
        
        // 添加到响应头
        c.Header("X-Request-ID", requestID)
        
        c.Next()
    }
}
```

### 3.3 中间件链配置

```go
func SetupRouter(cfg *config.Config, db *gorm.DB, logr *logger.Logger, localStorage interface{}) *gin.Engine {
    r := gin.New()
    
    // 全局中间件（顺序重要）
    r.Use(gin.Recovery())                                    // 1. 错误恢复
    r.Use(middlewares2.RequestIDMiddleware())                 // 2. 请求ID
    r.Use(middlewares2.LoggerMiddleware(logr))              // 3. 日志记录
    r.Use(middlewares2.CORSMiddleware(cfg.Server.CORSOrigins)) // 4. 跨域
    
    // API 路由组中间件
    api := r.Group("/api/v1")
    {
        api.Use(middlewares2.RateLimitMiddleware())         // 限流
        // api.Use(middlewares2.AuthMiddleware())           // 认证（需要时启用）
        
        // ... 路由定义
    }
    
    return r
}
```

---

## 4. 完整示例代码

### 4.1 示例1：完整CRUD（增删改查）

```go
// api/handlers/prop.go - 道具管理

package handlers

import (
    "github.com/drama-generator/backend/application/services"
    "github.com/drama-generator/backend/pkg/logger"
    "github.com/drama-generator/backend/pkg/response"
    "github.com/gin-gonic/gin"
    "gorm.io/gorm"
)

type PropHandler struct {
    db     *gorm.DB
    log    *logger.Logger
    service *services.PropService
}

func NewPropHandler(db *gorm.DB, cfg *config.Config, log *logger.Logger) *PropHandler {
    return &PropHandler{
        db:      db,
        log:     log,
        service: services.NewPropService(db, cfg, log),
    }
}

// CreateProp 创建道具
// POST /api/v1/dramas/:drama_id/props
func (h *PropHandler) CreateProp(c *gin.Context) {
    dramaID := c.Param("drama_id")
    
    var req services.CreatePropRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        response.BadRequest(c, err.Error())
        return
    }
    
    req.DramaID = dramaID
    
    prop, err := h.service.CreateProp(&req)
    if err != nil {
        h.log.Errorw("创建道具失败", "error", err)
        response.InternalError(c, err.Error())
        return
    }
    
    response.Created(c, prop)
}

// ListProps 获取道具列表
// GET /api/v1/dramas/:drama_id/props
func (h *PropHandler) ListProps(c *gin.Context) {
    dramaID := c.Param("drama_id")
    
    var query services.PropListQuery
    if err := c.ShouldBindQuery(&query); err != nil {
        response.BadRequest(c, err.Error())
        return
    }
    
    props, total, err := h.service.ListProps(dramaID, &query)
    if err != nil {
        h.log.Errorw("查询道具列表失败", "error", err)
        response.InternalError(c, err.Error())
        return
    }
    
    response.SuccessWithPagination(c, props, total, query.Page, query.PageSize)
}

// GetProp 获取道具详情
// GET /api/v1/props/:id
func (h *PropHandler) GetProp(c *gin.Context) {
    propID := c.Param("id")
    
    prop, err := h.service.GetProp(propID)
    if err != nil {
        if err.Error() == "prop not found" {
            response.NotFound(c, "道具不存在")
            return
        }
        response.InternalError(c, err.Error())
        return
    }
    
    response.Success(c, prop)
}

// UpdateProp 更新道具
// PUT /api/v1/props/:id
func (h *PropHandler) UpdateProp(c *gin.Context) {
    propID := c.Param("id")
    
    var req services.UpdatePropRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        response.BadRequest(c, err.Error())
        return
    }
    
    prop, err := h.service.UpdateProp(propID, &req)
    if err != nil {
        if err.Error() == "prop not found" {
            response.NotFound(c, "道具不存在")
            return
        }
        response.InternalError(c, err.Error())
        return
    }
    
    response.Success(c, prop)
}

// DeleteProp 删除道具
// DELETE /api/v1/props/:id
func (h *PropHandler) DeleteProp(c *gin.Context) {
    propID := c.Param("id")
    
    if err := h.service.DeleteProp(propID); err != nil {
        if err.Error() == "prop not found" {
            response.NotFound(c, "道具不存在")
            return
        }
        response.InternalError(c, err.Error())
        return
    }
    
    response.Success(c, gin.H{"message": "删除成功"})
}
```

### 4.2 示例2：文件上传（Multipart/form-data）

```go
// api/handlers/upload.go

package handlers

import (
    "fmt"
    "io"
    "mime/multipart"
    "os"
    "path/filepath"
    "time"
    
    "github.com/drama-generator/backend/pkg/logger"
    "github.com/drama-generator/backend/pkg/response"
    "github.com/gin-gonic/gin"
    "github.com/google/uuid"
)

type UploadHandler struct {
    storagePath string
    maxSize     int64
    log         *logger.Logger
}

func NewUploadHandler(storagePath string, maxSizeMB int, log *logger.Logger) *UploadHandler {
    return &UploadHandler{
        storagePath: storagePath,
        maxSize:     int64(maxSizeMB) * 1024 * 1024,
        log:         log,
    }
}

// UploadImage 上传图片
// POST /api/v1/upload/image
func (h *UploadHandler) UploadImage(c *gin.Context) {
    // 1. 获取上传文件
    file, header, err := c.Request.FormFile("file")
    if err != nil {
        response.BadRequest(c, "请上传文件")
        return
    }
    defer file.Close()
    
    // 2. 验证文件大小
    if header.Size > h.maxSize {
        response.BadRequest(c, fmt.Sprintf("文件大小不能超过 %d MB", h.maxSize/1024/1024))
        return
    }
    
    // 3. 验证文件类型
    allowedTypes := map[string]bool{
        "image/jpeg": true,
        "image/png":  true,
        "image/webp": true,
    }
    
    contentType := header.Header.Get("Content-Type")
    if !allowedTypes[contentType] {
        response.BadRequest(c, "只允许上传 JPEG、PNG、WebP 格式的图片")
        return
    }
    
    // 4. 生成文件名
    ext := filepath.Ext(header.Filename)
    filename := fmt.Sprintf("%s%s", uuid.New().String(), ext)
    
    // 5. 创建日期目录
    dateDir := time.Now().Format("2006/01/02")
    fullDir := filepath.Join(h.storagePath, "images", dateDir)
    if err := os.MkdirAll(fullDir, 0755); err != nil {
        h.log.Errorw("创建目录失败", "error", err)
        response.InternalError(c, "上传失败")
        return
    }
    
    // 6. 保存文件
    filepath := filepath.Join(fullDir, filename)
    out, err := os.Create(filepath)
    if err != nil {
        h.log.Errorw("创建文件失败", "error", err)
        response.InternalError(c, "上传失败")
        return
    }
    defer out.Close()
    
    if _, err := io.Copy(out, file); err != nil {
        h.log.Errorw("保存文件失败", "error", err)
        response.InternalError(c, "上传失败")
        return
    }
    
    // 7. 构建访问 URL
    relativePath := filepath.Join("images", dateDir, filename)
    
    h.log.Infow("图片上传成功",
        "filename", header.Filename,
        "size", header.Size,
        "path", relativePath,
    )
    
    response.Success(c, gin.H{
        "filename":    header.Filename,
        "url":         relativePath,
        "content_type": contentType,
        "size":        header.Size,
    })
}

// UploadMultipleImages 批量上传图片
// POST /api/v1/upload/images
func (h *UploadHandler) UploadMultipleImages(c *gin.Context) {
    // 解析 multipart form
    form, err := c.MultipartForm()
    if err != nil {
        response.BadRequest(c, "解析表单失败")
        return
    }
    
    files := form.File["files"]
    if len(files) == 0 {
        response.BadRequest(c, "请选择要上传的文件")
        return
    }
    
    if len(files) > 10 {
        response.BadRequest(c, "一次最多上传10个文件")
        return
    }
    
    var uploaded []gin.H
    var errors []string
    
    for _, file := range files {
        result, err := h.processImage(file)
        if err != nil {
            errors = append(errors, fmt.Sprintf("%s: %v", file.Filename, err))
            continue
        }
        uploaded = append(uploaded, result)
    }
    
    response.Success(c, gin.H{
        "uploaded": uploaded,
        "errors":   errors,
        "total":    len(files),
        "success":  len(uploaded),
    })
}

func (h *UploadHandler) processImage(file *multipart.FileHeader) (gin.H, error) {
    src, err := file.Open()
    if err != nil {
        return nil, err
    }
    defer src.Close()
    
    // 验证和处理逻辑...
    
    return gin.H{
        "filename": file.Filename,
        "url":      "path/to/file",
        "size":     file.Size,
    }, nil
}
```

### 4.3 示例3：异步任务（202 Accepted + 轮询）

```go
// domain/models/task.go

type TaskStatus string

const (
    TaskStatusPending    TaskStatus = "pending"
    TaskStatusProcessing TaskStatus = "processing"
    TaskStatusCompleted  TaskStatus = "completed"
    TaskStatusFailed     TaskStatus = "failed"
)

type AsyncTask struct {
    ID          uint           `gorm:"primaryKey" json:"id"`
    Type        string         `json:"type"`           // 任务类型
    Status      TaskStatus     `json:"status"`         // 任务状态
    InputData   datatypes.JSON `json:"input_data"`     // 输入数据
    ResultData  datatypes.JSON `json:"result_data"`    // 结果数据
    ErrorMsg    *string        `json:"error_msg"`      // 错误信息
    Progress    int            `json:"progress"`       // 进度 0-100
    CreatedAt   time.Time      `json:"created_at"`
    UpdatedAt   time.Time      `json:"updated_at"`
}

// api/handlers/video_generation.go

// GenerateVideo 提交视频生成任务
// POST /api/v1/videos
func (h *VideoGenerationHandler) GenerateVideo(c *gin.Context) {
    var req services.GenerateVideoRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        response.BadRequest(c, err.Error())
        return
    }
    
    // 创建异步任务
    task, err := h.service.CreateVideoGenerationTask(&req)
    if err != nil {
        response.InternalError(c, err.Error())
        return
    }
    
    // 返回 202 Accepted，告知客户端轮询任务状态
    c.Header("Location", fmt.Sprintf("/api/v1/tasks/%d", task.ID))
    response.SuccessWithMessage(c, "任务已提交", gin.H{
        "task_id": task.ID,
        "status": task.Status,
        "poll_url": fmt.Sprintf("/api/v1/tasks/%d", task.ID),
    })
    c.Status(http.StatusAccepted)
}

// api/handlers/task.go

// GetTaskStatus 获取任务状态
// GET /api/v1/tasks/:task_id
func (h *TaskHandler) GetTaskStatus(c *gin.Context) {
    taskID := c.Param("task_id")
    
    task, err := h.service.GetTask(taskID)
    if err != nil {
        if err.Error() == "task not found" {
            response.NotFound(c, "任务不存在")
            return
        }
        response.InternalError(c, err.Error())
        return
    }
    
    resp := gin.H{
        "id":       task.ID,
        "type":     task.Type,
        "status":   task.Status,
        "progress": task.Progress,
        "created_at": task.CreatedAt,
        "updated_at": task.UpdatedAt,
    }
    
    // 任务完成时返回结果
    if task.Status == models.TaskStatusCompleted {
        resp["result"] = task.ResultData
    }
    
    // 任务失败时返回错误信息
    if task.Status == models.TaskStatusFailed && task.ErrorMsg != nil {
        resp["error"] = *task.ErrorMsg
    }
    
    response.Success(c, resp)
}
```

### 4.4 示例4：批量操作

```go
// api/handlers/drama.go

// BatchDeleteDramas 批量删除剧本
// POST /api/v1/dramas/batch-delete
func (h *DramaHandler) BatchDeleteDramas(c *gin.Context) {
    var req struct {
        IDs []string `json:"ids" binding:"required,min=1,max=100,dive,numeric"`
    }
    
    if err := c.ShouldBindJSON(&req); err != nil {
        response.BadRequest(c, err.Error())
        return
    }
    
    result, err := h.service.BatchDeleteDramas(req.IDs)
    if err != nil {
        response.InternalError(c, err.Error())
        return
    }
    
    response.Success(c, result)
}

// application/services/drama_service.go

type BatchDeleteResult struct {
    Total      int      `json:"total"`
    Success    int      `json:"success"`
    Failed     int      `json:"failed"`
    FailedIDs  []string `json:"failed_ids,omitempty"`
    Errors     []string `json:"errors,omitempty"`
}

func (s *DramaService) BatchDeleteDramas(ids []string) (*BatchDeleteResult, error) {
    result := &BatchDeleteResult{
        Total: len(ids),
    }
    
    for _, id := range ids {
        if err := s.DeleteDrama(id); err != nil {
            result.Failed++
            result.FailedIDs = append(result.FailedIDs, id)
            result.Errors = append(result.Errors, fmt.Sprintf("ID %s: %v", id, err))
        } else {
            result.Success++
        }
    }
    
    return result, nil
}

// BatchUpdateDramas 批量更新剧本
// PUT /api/v1/dramas/batch-update
func (h *DramaHandler) BatchUpdateDramas(c *gin.Context) {
    var req struct {
        IDs    []string                 `json:"ids" binding:"required,min=1,max=100"`
        Fields map[string]interface{}   `json:"fields" binding:"required"`
    }
    
    if err := c.ShouldBindJSON(&req); err != nil {
        response.BadRequest(c, err.Error())
        return
    }
    
    // 验证可批量更新的字段
    allowedFields := map[string]bool{
        "status": true,
        "genre":  true,
    }
    
    for field := range req.Fields {
        if !allowedFields[field] {
            response.BadRequest(c, fmt.Sprintf("字段 '%s' 不支持批量更新", field))
            return
        }
    }
    
    result, err := h.service.BatchUpdateDramas(req.IDs, req.Fields)
    if err != nil {
        response.InternalError(c, err.Error())
        return
    }
    
    response.Success(c, result)
}
```

---

## 5. API测试

### 5.1 curl测试示例

```bash
# 1. 健康检查
curl http://localhost:5678/health

# 2. 创建剧本（POST）
curl -X POST http://localhost:5678/api/v1/dramas \
  -H "Content-Type: application/json" \
  -d '{
    "title": "测试剧本",
    "description": "这是一个测试剧本",
    "genre": "modern",
    "total_episodes": 10
  }'

# 3. 获取剧本列表（GET + Query）
curl "http://localhost:5678/api/v1/dramas?page=1&page_size=20&status=draft"

# 4. 获取剧本详情（Path 参数）
curl http://localhost:5678/api/v1/dramas/1

# 5. 更新剧本（PUT）
curl -X PUT http://localhost:5678/api/v1/dramas/1 \
  -H "Content-Type: application/json" \
  -d '{
    "title": "更新的剧本标题",
    "status": "planning"
  }'

# 6. 删除剧本（DELETE）
curl -X DELETE http://localhost:5678/api/v1/dramas/1

# 7. 上传文件
curl -X POST http://localhost:5678/api/v1/upload/image \
  -F "file=@/path/to/image.jpg"

# 8. 批量删除
curl -X POST http://localhost:5678/api/v1/dramas/batch-delete \
  -H "Content-Type: application/json" \
  -d '{"ids": ["1", "2", "3"]}'
```

### 5.2 Postman/Insomnia配置

#### 环境变量配置

```json
{
  "name": "Huobao Drama Dev",
  "values": [
    {
      "key": "base_url",
      "value": "http://localhost:5678",
      "enabled": true
    },
    {
      "key": "api_version",
      "value": "v1",
      "enabled": true
    },
    {
      "key": "auth_token",
      "value": "",
      "enabled": true
    }
  ]
}
```

#### 请求集合示例

```json
{
  "info": {
    "name": "Huobao Drama API",
    "description": "火宝短剧平台 API 集合"
  },
  "item": [
    {
      "name": "剧本管理",
      "item": [
        {
          "name": "创建剧本",
          "request": {
            "method": "POST",
            "header": [
              {
                "key": "Content-Type",
                "value": "application/json"
              }
            ],
            "url": {
              "raw": "{{base_url}}/api/{{api_version}}/dramas",
              "host": ["{{base_url}}"],
              "path": ["api", "{{api_version}}", "dramas"]
            },
            "body": {
              "mode": "raw",
              "raw": "{\n  \"title\": \"测试剧本\",\n  \"description\": \"这是一个测试剧本\",\n  \"genre\": \"modern\",\n  \"total_episodes\": 10\n}"
            }
          }
        },
        {
          "name": "获取剧本列表",
          "request": {
            "method": "GET",
            "url": {
              "raw": "{{base_url}}/api/{{api_version}}/dramas?page=1&page_size=20",
              "host": ["{{base_url}}"],
              "path": ["api", "{{api_version}}", "dramas"],
              "query": [
                {
                  "key": "page",
                  "value": "1"
                },
                {
                  "key": "page_size",
                  "value": "20"
                }
              ]
            }
          }
        }
      ]
    }
  ]
}
```

### 5.3 自动化API测试

使用 Go 编写 API 测试：

```go
// api/handlers/drama_test.go

package handlers

import (
    "bytes"
    "encoding/json"
    "net/http"
    "net/http/httptest"
    "testing"
    
    "github.com/gin-gonic/gin"
    "github.com/stretchr/testify/assert"
)

func TestDramaHandler_CreateDrama(t *testing.T) {
    // 设置测试模式
    gin.SetMode(gin.TestMode)
    
    // 初始化依赖
    db := setupTestDB()
    log := logger.NewLogger(true)
    handler := NewDramaHandler(db, testConfig, log)
    
    // 构建请求
    reqBody := map[string]interface{}{
        "title": "测试剧本",
        "genre": "modern",
    }
    jsonBody, _ := json.Marshal(reqBody)
    
    req := httptest.NewRequest(http.MethodPost, "/api/v1/dramas", bytes.NewBuffer(jsonBody))
    req.Header.Set("Content-Type", "application/json")
    
    // 执行请求
    w := httptest.NewRecorder()
    c, _ := gin.CreateTestContext(w)
    c.Request = req
    
    handler.CreateDrama(c)
    
    // 验证结果
    assert.Equal(t, http.StatusCreated, w.Code)
    
    var resp map[string]interface{}
    json.Unmarshal(w.Body.Bytes(), &resp)
    
    assert.True(t, resp["success"].(bool))
    assert.NotNil(t, resp["data"])
}

func TestDramaHandler_GetDrama_NotFound(t *testing.T) {
    gin.SetMode(gin.TestMode)
    
    db := setupTestDB()
    log := logger.NewLogger(true)
    handler := NewDramaHandler(db, testConfig, log)
    
    req := httptest.NewRequest(http.MethodGet, "/api/v1/dramas/99999", nil)
    w := httptest.NewRecorder()
    c, _ := gin.CreateTestContext(w)
    c.Request = req
    c.Params = gin.Params{{Key: "id", Value: "99999"}}
    
    handler.GetDrama(c)
    
    assert.Equal(t, http.StatusNotFound, w.Code)
    
    var resp map[string]interface{}
    json.Unmarshal(w.Body.Bytes(), &resp)
    
    assert.False(t, resp["success"].(bool))
    assert.Equal(t, "NOT_FOUND", resp["error"].(map[string]interface{})["code"])
}
```

---

## 相关文档

- [01-环境搭建指南.md](./01-环境搭建指南.md)
- [02-代码规范.md](./02-代码规范.md)
- [03-DDD开发指南.md](./03-DDD开发指南.md)
