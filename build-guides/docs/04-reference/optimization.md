# 性能优化指南

本文档提供了 Huobao Drama AI 短剧生成平台的性能优化建议和最佳实践。

---

## 目录

- [后端性能优化](#后端性能优化)
- [前端性能优化](#前端性能优化)
- [数据库优化](#数据库优化)
- [网络和部署优化](#网络和部署优化)
- [监控和诊断](#监控和诊断)

---

## 后端性能优化

### 1. 异步处理

将耗时任务放入后台处理，避免阻塞主线程：

```go
// 异步处理视频生成
func (s *VideoService) GenerateAsync(req *VideoRequest) (string, error) {
    taskID := generateTaskID()
    
    // 创建任务记录
    task := &Task{
        ID:     taskID,
        Status: "pending",
        Type:   "video_generation",
    }
    s.db.Create(task)
    
    // 异步处理
    go func() {
        defer func() {
            if r := recover(); r != nil {
                log.Printf("Panic in video generation: %v", r)
                s.updateTaskStatus(taskID, "failed")
            }
        }()
        
        result, err := s.generateVideo(req)
        if err != nil {
            s.updateTaskStatus(taskID, "failed")
            return
        }
        
        s.updateTaskStatus(taskID, "completed")
        s.saveResult(taskID, result)
    }()
    
    return taskID, nil
}
```

### 2. 使用 Worker Pool

限制并发 goroutine 数量，避免资源耗尽：

```go
type WorkerPool struct {
    maxWorkers int
    taskQueue  chan func()
    wg         sync.WaitGroup
}

func NewWorkerPool(maxWorkers int) *WorkerPool {
    pool := &WorkerPool{
        maxWorkers: maxWorkers,
        taskQueue:  make(chan func(), 100),
    }
    
    pool.start()
    return pool
}

func (p *WorkerPool) start() {
    for i := 0; i < p.maxWorkers; i++ {
        p.wg.Add(1)
        go p.worker()
    }
}

func (p *WorkerPool) worker() {
    defer p.wg.Done()
    for task := range p.taskQueue {
        task()
    }
}

func (p *WorkerPool) Submit(task func()) {
    p.taskQueue <- task
}
```


### 3. 缓存策略

使用缓存减少重复计算和数据库查询：

```go
import "github.com/patrickmn/go-cache"

// 创建缓存
c := cache.New(5*time.Minute, 10*time.Minute)

// 缓存 AI 生成结果
func (s *AIService) GenerateWithCache(prompt string) (string, error) {
    // 尝试从缓存获取
    if cached, found := c.Get(prompt); found {
        return cached.(string), nil
    }
    
    // 调用 AI 服务
    result, err := s.callAI(prompt)
    if err != nil {
        return "", err
    }
    
    // 存入缓存
    c.Set(prompt, result, cache.DefaultExpiration)
    return result, nil
}
```

### 4. 连接池配置

优化数据库和 HTTP 连接池：

```go
// 数据库连接池
db.DB().SetMaxOpenConns(25)
db.DB().SetMaxIdleConns(10)
db.DB().SetConnMaxLifetime(5 * time.Minute)

// HTTP 客户端连接池
client := &http.Client{
    Transport: &http.Transport{
        MaxIdleConns:        100,
        MaxIdleConnsPerHost: 10,
        IdleConnTimeout:     90 * time.Second,
        TLSHandshakeTimeout: 10 * time.Second,
    },
    Timeout: 30 * time.Second,
}
```

### 5. 限流和熔断

保护服务免受过载：

```go
import "golang.org/x/time/rate"

// 创建限流器
limiter := rate.NewLimiter(rate.Limit(10), 20)

// 中间件
func RateLimitMiddleware() gin.HandlerFunc {
    return func(c *gin.Context) {
        if !limiter.Allow() {
            c.JSON(429, gin.H{
                "error": "Too many requests",
            })
            c.Abort()
            return
        }
        c.Next()
    }
}
```

---

## 前端性能优化

### 1. 代码分割

使用动态导入实现代码分割：

```javascript
// router/index.ts
const routes = [
  {
    path: '/drama',
    component: () => import('@/views/drama/DramaList.vue')
  },
  {
    path: '/editor',
    component: () => import('@/views/editor/TimelineEditor.vue')
  }
]
```

### 2. 组件懒加载

延迟加载非关键组件：

```vue
<script setup>
import { defineAsyncComponent } from 'vue'

const VideoPlayer = defineAsyncComponent(() =>
  import('@/components/VideoPlayer.vue')
)
</script>

<template>
  <Suspense>
    <template #default>
      <VideoPlayer />
    </template>
    <template #fallback>
      <div>加载中...</div>
    </template>
  </Suspense>
</template>
```

### 3. 虚拟滚动

处理大列表时使用虚拟滚动：

```vue
<script setup>
import { ref } from 'vue'
import VirtualList from 'vue-virtual-scroll-list'

const items = ref([/* 大量数据 */])
</script>

<template>
  <VirtualList
    :data-sources="items"
    :data-key="'id'"
    :data-component="ItemComponent"
    :estimate-size="50"
  />
</template>
```


### 4. 图片优化

使用现代图片格式和懒加载：

```vue
<template>
  <!-- 使用 WebP 格式 -->
  <picture>
    <source srcset="image.webp" type="image/webp">
    <img src="image.jpg" alt="描述" loading="lazy">
  </picture>
  
  <!-- 响应式图片 -->
  <img
    srcset="small.jpg 480w, medium.jpg 800w, large.jpg 1200w"
    sizes="(max-width: 600px) 480px, (max-width: 900px) 800px, 1200px"
    src="medium.jpg"
    alt="描述"
    loading="lazy"
  >
</template>
```

### 5. 防抖和节流

优化频繁触发的事件：

```javascript
import { debounce, throttle } from 'lodash-es'

// 防抖：搜索输入
const handleSearch = debounce((query) => {
  searchAPI(query)
}, 300)

// 节流：滚动事件
const handleScroll = throttle(() => {
  updateScrollPosition()
}, 100)
```

---

## 数据库优化

### 1. 索引优化

为常用查询字段添加索引：

```sql
-- 为用户 ID 添加索引
CREATE INDEX idx_dramas_user_id ON dramas(user_id);

-- 为状态和创建时间添加复合索引
CREATE INDEX idx_tasks_status_created ON tasks(status, created_at);

-- 为全文搜索添加索引
CREATE INDEX idx_dramas_title ON dramas(title);
```

### 2. 查询优化

避免 N+1 查询问题：

```go
// 不好的做法：N+1 查询
dramas := []Drama{}
db.Find(&dramas)
for _, drama := range dramas {
    db.Model(&drama).Association("Scenes").Find(&drama.Scenes)
}

// 好的做法：预加载
dramas := []Drama{}
db.Preload("Scenes").Preload("Characters").Find(&dramas)
```

### 3. 分页查询

使用游标分页提高性能：

```go
// 基于 ID 的游标分页
func GetDramas(lastID uint, limit int) ([]Drama, error) {
    var dramas []Drama
    err := db.Where("id > ?", lastID).
        Order("id ASC").
        Limit(limit).
        Find(&dramas).Error
    return dramas, err
}
```

### 4. 批量操作

使用批量插入和更新：

```go
// 批量插入
scenes := []Scene{
    {DramaID: 1, Content: "Scene 1"},
    {DramaID: 1, Content: "Scene 2"},
}
db.CreateInBatches(scenes, 100)

// 批量更新
db.Model(&Task{}).
    Where("status = ?", "pending").
    Updates(map[string]interface{}{
        "status": "processing",
        "updated_at": time.Now(),
    })
```

---

## 网络和部署优化

### 1. Nginx 配置优化

```nginx
# nginx.conf

# 启用 gzip 压缩
gzip on;
gzip_vary on;
gzip_min_length 1024;
gzip_types text/plain text/css text/xml text/javascript 
           application/json application/javascript application/xml+rss;

# 静态资源缓存
location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}

# API 不缓存
location /api/ {
    proxy_pass http://localhost:8080;
    proxy_cache_bypass $http_upgrade;
    add_header Cache-Control "no-cache, no-store, must-revalidate";
}

# 连接优化
keepalive_timeout 65;
keepalive_requests 100;

# 缓冲区优化
client_body_buffer_size 128k;
client_max_body_size 100m;
```

### 2. HTTP/2 启用

```nginx
server {
    listen 443 ssl http2;
    server_name example.com;
    
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;
    
    # HTTP/2 推送
    http2_push_preload on;
}
```

### 3. CDN 配置

使用 CDN 加速静态资源：

```javascript
// vite.config.ts
export default defineConfig({
  base: process.env.NODE_ENV === 'production'
    ? 'https://cdn.example.com/'
    : '/',
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          'vendor': ['vue', 'vue-router', 'pinia'],
          'ui': ['element-plus'],
        }
      }
    }
  }
})
```


---

## 监控和诊断

### 1. 应用监控

使用 Prometheus 和 Grafana 监控应用：

```go
import (
    "github.com/prometheus/client_golang/prometheus"
    "github.com/prometheus/client_golang/prometheus/promhttp"
)

var (
    httpRequestsTotal = prometheus.NewCounterVec(
        prometheus.CounterOpts{
            Name: "http_requests_total",
            Help: "Total number of HTTP requests",
        },
        []string{"method", "endpoint", "status"},
    )
    
    httpRequestDuration = prometheus.NewHistogramVec(
        prometheus.HistogramOpts{
            Name: "http_request_duration_seconds",
            Help: "HTTP request duration in seconds",
        },
        []string{"method", "endpoint"},
    )
)

func init() {
    prometheus.MustRegister(httpRequestsTotal)
    prometheus.MustRegister(httpRequestDuration)
}

// 中间件
func PrometheusMiddleware() gin.HandlerFunc {
    return func(c *gin.Context) {
        start := time.Now()
        
        c.Next()
        
        duration := time.Since(start).Seconds()
        status := strconv.Itoa(c.Writer.Status())
        
        httpRequestsTotal.WithLabelValues(
            c.Request.Method,
            c.FullPath(),
            status,
        ).Inc()
        
        httpRequestDuration.WithLabelValues(
            c.Request.Method,
            c.FullPath(),
        ).Observe(duration)
    }
}

// 暴露 metrics 端点
router.GET("/metrics", gin.WrapH(promhttp.Handler()))
```

### 2. 日志聚合

使用结构化日志便于分析：

```go
import "go.uber.org/zap"

logger, _ := zap.NewProduction()
defer logger.Sync()

logger.Info("Video generation started",
    zap.String("task_id", taskID),
    zap.String("user_id", userID),
    zap.Int("frame_count", frameCount),
)

logger.Error("Video generation failed",
    zap.String("task_id", taskID),
    zap.Error(err),
    zap.Duration("duration", time.Since(start)),
)
```

### 3. 分布式追踪

使用 OpenTelemetry 追踪请求：

```go
import (
    "go.opentelemetry.io/otel"
    "go.opentelemetry.io/otel/trace"
)

func ProcessVideo(ctx context.Context, videoID string) error {
    tracer := otel.Tracer("video-service")
    ctx, span := tracer.Start(ctx, "ProcessVideo")
    defer span.End()
    
    // 添加属性
    span.SetAttributes(
        attribute.String("video.id", videoID),
    )
    
    // 处理逻辑
    if err := generateFrames(ctx, videoID); err != nil {
        span.RecordError(err)
        return err
    }
    
    return nil
}
```

### 4. 健康检查

实现健康检查端点：

```go
func HealthCheck(c *gin.Context) {
    health := gin.H{
        "status": "ok",
        "timestamp": time.Now().Unix(),
    }
    
    // 检查数据库连接
    if err := db.DB().Ping(); err != nil {
        health["status"] = "error"
        health["database"] = "disconnected"
        c.JSON(503, health)
        return
    }
    
    // 检查 Redis 连接（如果使用）
    // if err := redis.Ping(); err != nil {
    //     health["redis"] = "disconnected"
    // }
    
    c.JSON(200, health)
}

router.GET("/health", HealthCheck)
```

---

## 性能优化检查清单

### 后端优化

- [ ] 使用异步处理耗时任务
- [ ] 实现 Worker Pool 限制并发
- [ ] 添加缓存层（内存缓存或 Redis）
- [ ] 优化数据库连接池配置
- [ ] 实现限流和熔断机制
- [ ] 使用 pprof 分析性能瓶颈
- [ ] 优化日志输出（避免过度日志）

### 前端优化

- [ ] 实现代码分割和懒加载
- [ ] 使用虚拟滚动处理大列表
- [ ] 优化图片（WebP、懒加载）
- [ ] 实现防抖和节流
- [ ] 减少 bundle 大小
- [ ] 使用 Service Worker 缓存
- [ ] 优化首屏加载时间

### 数据库优化

- [ ] 为常用查询添加索引
- [ ] 避免 N+1 查询问题
- [ ] 使用批量操作
- [ ] 实现查询缓存
- [ ] 定期清理过期数据
- [ ] 使用连接池
- [ ] 监控慢查询

### 部署优化

- [ ] 启用 gzip 压缩
- [ ] 配置静态资源缓存
- [ ] 使用 CDN
- [ ] 启用 HTTP/2
- [ ] 配置负载均衡
- [ ] 实现健康检查
- [ ] 设置监控和告警

---

## 性能测试

### 1. 压力测试

使用 Apache Bench 进行压力测试：

```bash
# 测试 API 性能
ab -n 1000 -c 10 http://localhost:8080/api/dramas

# 输出示例：
# Requests per second:    100.00 [#/sec] (mean)
# Time per request:       100.000 [ms] (mean)
```

### 2. 负载测试

使用 wrk 进行负载测试：

```bash
# 测试 30 秒，10 个线程，100 个连接
wrk -t10 -c100 -d30s http://localhost:8080/api/dramas

# 输出示例：
# Requests/sec:   1000.00
# Transfer/sec:   500.00KB
```

### 3. 前端性能测试

使用 Lighthouse 评估前端性能：

```bash
# 安装 Lighthouse CLI
npm install -g lighthouse

# 运行测试
lighthouse http://localhost:5173 --output html --output-path ./report.html

# 查看报告
open report.html
```

---

## 最佳实践总结

### 开发阶段

1. **编写高效代码**: 避免不必要的循环和计算
2. **使用性能分析工具**: 及早发现性能问题
3. **实现缓存策略**: 减少重复计算和查询
4. **异步处理**: 不阻塞主线程

### 测试阶段

1. **性能测试**: 定期进行压力测试和负载测试
2. **监控指标**: 关注响应时间、吞吐量、错误率
3. **优化瓶颈**: 针对性优化慢查询和慢接口

### 部署阶段

1. **使用 CDN**: 加速静态资源加载
2. **启用缓存**: 减少服务器负载
3. **负载均衡**: 分散流量
4. **监控告警**: 及时发现和处理问题

### 运维阶段

1. **持续监控**: 使用 Prometheus、Grafana 等工具
2. **日志分析**: 定期分析日志，发现潜在问题
3. **容量规划**: 根据业务增长调整资源
4. **定期优化**: 持续改进性能

💡 **记住**: 性能优化是一个持续的过程，需要根据实际情况不断调整和改进。

---

[返回主页](../../README.md) | [问题排查](troubleshooting.md)

