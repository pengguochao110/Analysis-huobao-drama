# 03-DDD开发指南

本文档详细讲解火宝短剧项目的 DDD（领域驱动设计）分层架构开发模式，包含完整的新增功能示例。

---

## 1. DDD四层架构回顾

### 1.1 每层职责清晰定义

```
┌─────────────────────────────────────────────────────────────┐
│                        API Layer                            │
│                   （接口层 / Presentation）                    │
│  ┌───────────────────────────────────────────────────────┐  │
│  │ • HTTP 请求处理                                        │  │
│  │ • 输入验证（DTO）                                      │  │
│  │ • 响应格式化                                          │  │
│  │ • 路由定义                                            │  │
│  └───────────────────────────────────────────────────────┘  │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    Application Layer                          │
│                     （应用层 / Service）                     │
│  ┌───────────────────────────────────────────────────────┐  │
│  │ • 业务流程编排（用例实现）                              │  │
│  │ • 事务管理                                            │  │
│  │ • 跨领域对象协调                                       │  │
│  │ • 应用服务编排                                        │  │
│  └───────────────────────────────────────────────────────┘  │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                      Domain Layer                             │
│                    （领域层 / Domain）                       │
│  ┌───────────────────────────────────────────────────────┐  │
│  │ • 领域实体（Entity）                                   │  │
│  │ • 值对象（Value Object）                              │  │
│  │ • 领域事件（Domain Event）                             │  │
│  │ • 仓库接口（Repository Interface）                     │  │
│  │ • 业务规则（Business Rules）                          │  │
│  └───────────────────────────────────────────────────────┘  │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                   Infrastructure Layer                      │
│                    （基础设施层）                              │
│  ┌───────────────────────────────────────────────────────┐  │
│  │ • 数据库实现（GORM）                                   │  │
│  │ • 文件存储实现                                        │  │
│  │ • 外部 API 客户端                                     │  │
│  │ • 缓存实现                                            │  │
│  │ • 消息队列                                            │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 依赖方向图示

```
                    依赖方向（向内）
                         
    ┌─────────────────────────────────────┐
    │          API Layer                  │◄──── HTTP 请求
    │    (api/handlers, api/routes)       │
    └──────────────────┬──────────────────┘
                       │ 依赖
                       ▼
    ┌─────────────────────────────────────┐
    │       Application Layer             │
    │    (application/services)           │
    └──────────────────┬──────────────────┘
                       │ 依赖
                       ▼
    ┌─────────────────────────────────────┐
    │         Domain Layer                │
    │      (domain/models)                │
    └──────────────────┬──────────────────┘
                       │ 实现
                       ▼
    ┌─────────────────────────────────────┐
    │      Infrastructure Layer           │
    │ (infrastructure/database, storage)    │
    └─────────────────────────────────────┘
```

**核心原则：**
- 内层不依赖外层
- 外层依赖内层
- 依赖通过接口实现
- 领域层完全独立

### 1.3 数据流向说明

```
HTTP Request
    │
    ▼
┌────────────────────────────────────────────────────┐
│ Router (api/routes/routes.go)                      │
│ • 路由匹配                                          │
│ • 中间件执行（CORS、日志、限流）                      │
└──────────────────┬─────────────────────────────────┘
                   │
                   ▼
┌────────────────────────────────────────────────────┐
│ Handler (api/handlers/xxx.go)                      │
│ • 解析请求参数（Query/Body/Path）                    │
│ • 验证输入（binding）                               │
│ • 调用 Service                                     │
└──────────────────┬─────────────────────────────────┘
                   │
                   ▼
┌────────────────────────────────────────────────────┐
│ Service (application/services/xxx_service.go)        │
│ • 业务逻辑编排                                      │
│ • 事务管理（Begin/Commit/Rollback）                 │
│ • 调用 Repository                                  │
│ • 调用外部服务                                      │
└──────────────────┬─────────────────────────────────┘
                   │
                   ▼
┌────────────────────────────────────────────────────┐
│ Model (domain/models/xxx.go)                       │
│ • 领域对象创建                                      │
│ • 业务规则执行                                      │
└──────────────────┬─────────────────────────────────┘
                   │
                   ▼
┌────────────────────────────────────────────────────┐
│ Repository (infrastructure/database/xxx.go)        │
│ • GORM 操作（Create/Update/Delete/Query）            │
│ • 数据持久化                                       │
└────────────────────────────────────────────────────┘
                   │
                   ▼
              Response
```

---

## 2. 新增功能完整示例：标签系统

以**剧本标签系统**为例，完整演示 DDD 架构下的功能开发流程。

### Step 1 领域层：定义Tag实体

创建文件：`domain/models/tag.go`

```go
package models

import (
	"time"

	"gorm.io/datatypes"
	"gorm.io/gorm"
)

// Tag 标签实体
type Tag struct {
	ID          uint           `gorm:"primaryKey;autoIncrement" json:"id"`
	Name        string         `gorm:"type:varchar(100);not null;uniqueIndex:idx_tag_name" json:"name"`
	Color       string         `gorm:"type:varchar(7);default:'#1890ff'" json:"color"` // 标签颜色（Hex）
	Description *string        `gorm:"type:text" json:"description"`
	Category    string         `gorm:"type:varchar(50);default:'general'" json:"category"` // 分类：genre, style, mood, general
	SortOrder   int            `gorm:"default:0" json:"sort_order"`
	CreatedAt   time.Time      `gorm:"not null;autoCreateTime" json:"created_at"`
	UpdatedAt   time.Time      `gorm:"not null;autoUpdateTime" json:"updated_at"`
	DeletedAt   gorm.DeletedAt `gorm:"index" json:"-"`
}

func (t *Tag) TableName() string {
	return "tags"
}

// DramaTag 剧本标签关联表
type DramaTag struct {
	ID        uint           `gorm:"primaryKey;autoIncrement" json:"id"`
	DramaID   uint           `gorm:"not null;index:idx_drama_tag" json:"drama_id"`
	TagID     uint           `gorm:"not null;index:idx_drama_tag" json:"tag_id"`
	CreatedAt time.Time      `gorm:"not null;autoCreateTime" json:"created_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`
}

func (dt *DramaTag) TableName() string {
	return "drama_tags"
}

// TagCategory 标签分类常量
const (
	TagCategoryGenre  = "genre"   // 题材：古装、现代、悬疑
	TagCategoryStyle  = "style"   // 风格：写实、卡通、油画
	TagCategoryMood   = "mood"    // 情绪：搞笑、感人、紧张
	TagCategoryGeneral = "general" // 其他
)

// ValidateCategory 验证标签分类
func (t *Tag) ValidateCategory() bool {
	switch t.Category {
	case TagCategoryGenre, TagCategoryStyle, TagCategoryMood, TagCategoryGeneral:
		return true
	default:
		return false
	}
}

// SetDefaultColor 设置默认颜色
func (t *Tag) SetDefaultColor() {
	if t.Color == "" {
		switch t.Category {
		case TagCategoryGenre:
			t.Color = "#52c41a"
		case TagCategoryStyle:
			t.Color = "#1890ff"
		case TagCategoryMood:
			t.Color = "#faad14"
		default:
			t.Color = "#d9d9d9"
		}
	}
}

// BeforeCreate 创建前钩子
func (t *Tag) BeforeCreate(tx *gorm.DB) error {
	t.SetDefaultColor()
	return nil
}
```

### Step 2 领域层：定义TagRepository接口

创建文件：`domain/models/tag_repository.go`

```go
package models

// TagRepository 标签仓库接口
type TagRepository interface {
	// 基础 CRUD
	Create(tag *Tag) error
	Update(tag *Tag) error
	Delete(id uint) error
	FindByID(id uint) (*Tag, error)
	FindByName(name string) (*Tag, error)
	ListAll() ([]Tag, error)
	ListByCategory(category string) ([]Tag, error)
	
	// 分页查询
	List(page, pageSize int) ([]Tag, int64, error)
	Search(keyword string, page, pageSize int) ([]Tag, int64, error)
	
	// 剧本标签关联
	AssociateTag(dramaID, tagID uint) error
	RemoveTag(dramaID, tagID uint) error
	GetTagsByDramaID(dramaID uint) ([]Tag, error)
	SetDramaTags(dramaID uint, tagIDs []uint) error
}
```

### Step 3 应用层：实现TagService

创建文件：`application/services/tag_service.go`

```go
package services

import (
	"errors"
	"fmt"
	"time"

	"github.com/drama-generator/backend/domain/models"
	"github.com/drama-generator/backend/pkg/logger"
	"gorm.io/gorm"
)

// TagService 标签应用服务
type TagService struct {
	db  *gorm.DB
	log *logger.Logger
}

// NewTagService 创建标签服务
func NewTagService(db *gorm.DB, log *logger.Logger) *TagService {
	return &TagService{
		db:  db,
		log: log,
	}
}

// CreateTagRequest 创建标签请求
type CreateTagRequest struct {
	Name        string  `json:"name" binding:"required,min=1,max=100"`
	Color       string  `json:"color" binding:"omitempty,hexcolor"`
	Description string  `json:"description" binding:"omitempty,max=500"`
	Category    string  `json:"category" binding:"required,oneof=genre style mood general"`
	SortOrder   int     `json:"sort_order" binding:"omitempty,min=0"`
}

// UpdateTagRequest 更新标签请求
type UpdateTagRequest struct {
	Name        string  `json:"name" binding:"omitempty,min=1,max=100"`
	Color       string  `json:"color" binding:"omitempty,hexcolor"`
	Description *string `json:"description" binding:"omitempty,max=500"`
	Category    string  `json:"category" binding:"omitempty,oneof=genre style mood general"`
	SortOrder   *int    `json:"sort_order" binding:"omitempty,min=0"`
}

// TagListQuery 标签列表查询参数
type TagListQuery struct {
	Page     int    `form:"page,default=1" binding:"omitempty,min=1"`
	PageSize int    `form:"page_size,default=20" binding:"omitempty,min=1,max=100"`
	Category string `form:"category" binding:"omitempty,oneof=genre style mood general"`
	Keyword  string `form:"keyword" binding:"omitempty,max=100"`
}

// CreateTag 创建标签
func (s *TagService) CreateTag(req *CreateTagRequest) (*models.Tag, error) {
	// 检查标签名是否已存在
	var existing models.Tag
	if err := s.db.Where("name = ?", req.Name).First(&existing).Error; err == nil {
		return nil, errors.New("标签名称已存在")
	} else if !errors.Is(err, gorm.ErrRecordNotFound) {
		s.log.Errorw("检查标签存在性失败", "error", err, "name", req.Name)
		return nil, fmt.Errorf("检查标签存在性失败: %w", err)
	}

	// 创建标签实体
	tag := &models.Tag{
		Name:        req.Name,
		Color:       req.Color,
		Category:    req.Category,
		SortOrder:   req.SortOrder,
	}

	if req.Description != "" {
		tag.Description = &req.Description
	}

	// 保存到数据库
	if err := s.db.Create(tag).Error; err != nil {
		s.log.Errorw("创建标签失败", "error", err, "tag", req.Name)
		return nil, fmt.Errorf("创建标签失败: %w", err)
	}

	s.log.Infow("标签创建成功", "tag_id", tag.ID, "name", tag.Name)
	return tag, nil
}

// GetTag 获取标签详情
func (s *TagService) GetTag(id string) (*models.Tag, error) {
	var tagID uint
	if _, err := fmt.Sscanf(id, "%d", &tagID); err != nil {
		return nil, errors.New("无效的标签ID")
	}

	var tag models.Tag
	if err := s.db.First(&tag, tagID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("标签不存在")
		}
		s.log.Errorw("获取标签失败", "error", err, "tag_id", tagID)
		return nil, fmt.Errorf("获取标签失败: %w", err)
	}

	return &tag, nil
}

// ListTags 获取标签列表
func (s *TagService) ListTags(query *TagListQuery) ([]models.Tag, int64, error) {
	var tags []models.Tag
	var total int64

	db := s.db.Model(&models.Tag{})

	// 分类过滤
	if query.Category != "" {
		db = db.Where("category = ?", query.Category)
	}

	// 关键词搜索
	if query.Keyword != "" {
		db = db.Where("name LIKE ? OR description LIKE ?", 
			"%"+query.Keyword+"%", "%"+query.Keyword+"%")
	}

	// 统计总数
	if err := db.Count(&total).Error; err != nil {
		s.log.Errorw("统计标签数量失败", "error", err)
		return nil, 0, err
	}

	// 分页查询
	offset := (query.Page - 1) * query.PageSize
	err := db.Order("sort_order ASC, created_at DESC").
		Offset(offset).
		Limit(query.PageSize).
		Find(&tags).Error

	if err != nil {
		s.log.Errorw("查询标签列表失败", "error", err)
		return nil, 0, err
	}

	return tags, total, nil
}

// UpdateTag 更新标签
func (s *TagService) UpdateTag(id string, req *UpdateTagRequest) (*models.Tag, error) {
	// 获取现有标签
	tag, err := s.GetTag(id)
	if err != nil {
		return nil, err
	}

	// 如果修改了名称，检查是否与其他标签冲突
	if req.Name != "" && req.Name != tag.Name {
		var existing models.Tag
		if err := s.db.Where("name = ? AND id != ?", req.Name, tag.ID).First(&existing).Error; err == nil {
			return nil, errors.New("标签名称已存在")
		}
		tag.Name = req.Name
	}

	// 更新字段
	updates := map[string]interface{}{
		"updated_at": time.Now(),
	}

	if req.Color != "" {
		updates["color"] = req.Color
	}
	if req.Description != nil {
		updates["description"] = *req.Description
	}
	if req.Category != "" {
		updates["category"] = req.Category
	}
	if req.SortOrder != nil {
		updates["sort_order"] = *req.SortOrder
	}

	if err := s.db.Model(tag).Updates(updates).Error; err != nil {
		s.log.Errorw("更新标签失败", "error", err, "tag_id", tag.ID)
		return nil, fmt.Errorf("更新标签失败: %w", err)
	}

	// 重新加载标签
	if err := s.db.First(tag, tag.ID).Error; err != nil {
		return nil, err
	}

	s.log.Infow("标签更新成功", "tag_id", tag.ID)
	return tag, nil
}

// DeleteTag 删除标签
func (s *TagService) DeleteTag(id string) error {
	tag, err := s.GetTag(id)
	if err != nil {
		return err
	}

	// 使用事务删除标签及关联关系
	err = s.db.Transaction(func(tx *gorm.DB) error {
		// 删除剧本标签关联
		if err := tx.Where("tag_id = ?", tag.ID).Delete(&models.DramaTag{}).Error; err != nil {
			return err
		}

		// 删除标签
		if err := tx.Delete(tag).Error; err != nil {
			return err
		}

		return nil
	})

	if err != nil {
		s.log.Errorw("删除标签失败", "error", err, "tag_id", tag.ID)
		return fmt.Errorf("删除标签失败: %w", err)
	}

	s.log.Infow("标签删除成功", "tag_id", tag.ID)
	return nil
}

// SetDramaTags 设置剧本的标签
func (s *TagService) SetDramaTags(dramaID string, tagIDs []uint) error {
	var drama uint
	if _, err := fmt.Sscanf(dramaID, "%d", &drama); err != nil {
		return errors.New("无效的剧本ID")
	}

	// 验证所有标签是否存在
	var count int64
	if err := s.db.Model(&models.Tag{}).Where("id IN ?", tagIDs).Count(&count).Error; err != nil {
		return err
	}
	if int(count) != len(tagIDs) {
		return errors.New("部分标签不存在")
	}

	// 使用事务更新关联
	err := s.db.Transaction(func(tx *gorm.DB) error {
		// 删除现有关联
		if err := tx.Where("drama_id = ?", drama).Delete(&models.DramaTag{}).Error; err != nil {
			return err
		}

		// 创建新关联
		for _, tagID := range tagIDs {
			dramaTag := &models.DramaTag{
				DramaID: drama,
				TagID:   tagID,
			}
			if err := tx.Create(dramaTag).Error; err != nil {
				return err
			}
		}

		return nil
	})

	if err != nil {
		s.log.Errorw("设置剧本标签失败", "error", err, "drama_id", drama)
		return fmt.Errorf("设置剧本标签失败: %w", err)
	}

	s.log.Infow("剧本标签设置成功", "drama_id", drama, "tag_count", len(tagIDs))
	return nil
}

// GetDramaTags 获取剧本的标签列表
func (s *TagService) GetDramaTags(dramaID string) ([]models.Tag, error) {
	var drama uint
	if _, err := fmt.Sscanf(dramaID, "%d", &drama); err != nil {
		return nil, errors.New("无效的剧本ID")
	}

	var tags []models.Tag
	err := s.db.Table("tags").
		Joins("JOIN drama_tags ON drama_tags.tag_id = tags.id").
		Where("drama_tags.drama_id = ?", drama).
		Order("tags.sort_order ASC, tags.created_at DESC").
		Find(&tags).Error

	if err != nil {
		s.log.Errorw("获取剧本标签失败", "error", err, "drama_id", drama)
		return nil, fmt.Errorf("获取剧本标签失败: %w", err)
	}

	return tags, nil
}
```

### Step 4 API层：创建TagHandler和DTO

创建文件：`api/handlers/tag.go`

```go
package handlers

import (
	"github.com/drama-generator/backend/application/services"
	"github.com/drama-generator/backend/pkg/logger"
	"github.com/drama-generator/backend/pkg/response"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// TagHandler 标签处理器
type TagHandler struct {
	db         *gorm.DB
	tagService *services.TagService
	log        *logger.Logger
}

// NewTagHandler 创建标签处理器
func NewTagHandler(db *gorm.DB, log *logger.Logger) *TagHandler {
	return &TagHandler{
		db:         db,
		tagService: services.NewTagService(db, log),
		log:        log,
	}
}

// CreateTag 创建标签
func (h *TagHandler) CreateTag(c *gin.Context) {
	var req services.CreateTagRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.BadRequest(c, err.Error())
		return
	}

	tag, err := h.tagService.CreateTag(&req)
	if err != nil {
		h.log.Errorw("创建标签失败", "error", err)
		response.InternalError(c, err.Error())
		return
	}

	response.Created(c, tag)
}

// GetTag 获取标签详情
func (h *TagHandler) GetTag(c *gin.Context) {
	tagID := c.Param("id")

	tag, err := h.tagService.GetTag(tagID)
	if err != nil {
		if err.Error() == "标签不存在" {
			response.NotFound(c, "标签不存在")
			return
		}
		response.InternalError(c, err.Error())
		return
	}

	response.Success(c, tag)
}

// ListTags 获取标签列表
func (h *TagHandler) ListTags(c *gin.Context) {
	var query services.TagListQuery
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

	tags, total, err := h.tagService.ListTags(&query)
	if err != nil {
		response.InternalError(c, err.Error())
		return
	}

	response.SuccessWithPagination(c, tags, total, query.Page, query.PageSize)
}

// UpdateTag 更新标签
func (h *TagHandler) UpdateTag(c *gin.Context) {
	tagID := c.Param("id")

	var req services.UpdateTagRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.BadRequest(c, err.Error())
		return
	}

	tag, err := h.tagService.UpdateTag(tagID, &req)
	if err != nil {
		switch err.Error() {
		case "标签不存在":
			response.NotFound(c, "标签不存在")
		case "标签名称已存在":
			response.BadRequest(c, "标签名称已存在")
		default:
			response.InternalError(c, err.Error())
		}
		return
	}

	response.Success(c, tag)
}

// DeleteTag 删除标签
func (h *TagHandler) DeleteTag(c *gin.Context) {
	tagID := c.Param("id")

	if err := h.tagService.DeleteTag(tagID); err != nil {
		switch err.Error() {
		case "标签不存在":
			response.NotFound(c, "标签不存在")
		case "无效的标签ID":
			response.BadRequest(c, "无效的标签ID")
		default:
			response.InternalError(c, err.Error())
		}
		return
	}

	response.Success(c, gin.H{"message": "删除成功"})
}

// GetDramaTags 获取剧本的标签
func (h *TagHandler) GetDramaTags(c *gin.Context) {
	dramaID := c.Param("drama_id")

	tags, err := h.tagService.GetDramaTags(dramaID)
	if err != nil {
		response.InternalError(c, err.Error())
		return
	}

	response.Success(c, tags)
}

// SetDramaTags 设置剧本的标签
func (h *TagHandler) SetDramaTags(c *gin.Context) {
	dramaID := c.Param("drama_id")

	var req struct {
		TagIDs []uint `json:"tag_ids" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		response.BadRequest(c, err.Error())
		return
	}

	if err := h.tagService.SetDramaTags(dramaID, req.TagIDs); err != nil {
		response.InternalError(c, err.Error())
		return
	}

	response.Success(c, gin.H{"message": "标签设置成功"})
}
```

### Step 5 API层：注册路由

修改文件：`api/routes/routes.go`

```go
func SetupRouter(cfg *config.Config, db *gorm.DB, logr *logger.Logger, localStorage interface{}) *gin.Engine {
	// ... 现有代码 ...

	// 初始化标签处理器
	tagHandler := handlers2.NewTagHandler(db, logr)

	api := r.Group("/api/v1")
	{
		// ... 现有路由 ...

		// 标签路由组 - 新增
		tags := api.Group("/tags")
		{
			tags.GET("", tagHandler.ListTags)          // GET /api/v1/tags
			tags.POST("", tagHandler.CreateTag)        // POST /api/v1/tags
			tags.GET("/:id", tagHandler.GetTag)        // GET /api/v1/tags/:id
			tags.PUT("/:id", tagHandler.UpdateTag)     // PUT /api/v1/tags/:id
			tags.DELETE("/:id", tagHandler.DeleteTag)  // DELETE /api/v1/tags/:id
		}

		// 剧本标签关联路由 - 新增
		dramas := api.Group("/dramas")
		{
			// ... 现有路由 ...
			
			// 标签关联路由
			dramas.GET("/:drama_id/tags", tagHandler.GetDramaTags)     // GET /api/v1/dramas/:id/tags
			dramas.PUT("/:drama_id/tags", tagHandler.SetDramaTags)     // PUT /api/v1/dramas/:id/tags
		}
	}

	// ... 其余代码 ...
	return r
}
```

### Step 6 基础设施层：实现Repository

创建文件：`infrastructure/database/tag_repository.go`

```go
package database

import (
	"github.com/drama-generator/backend/domain/models"
	"gorm.io/gorm"
)

// TagRepositoryImpl 标签仓库实现
type TagRepositoryImpl struct {
	db *gorm.DB
}

// NewTagRepository 创建标签仓库
func NewTagRepository(db *gorm.DB) *TagRepositoryImpl {
	return &TagRepositoryImpl{db: db}
}

// Create 创建标签
func (r *TagRepositoryImpl) Create(tag *models.Tag) error {
	return r.db.Create(tag).Error
}

// Update 更新标签
func (r *TagRepositoryImpl) Update(tag *models.Tag) error {
	return r.db.Save(tag).Error
}

// Delete 删除标签
func (r *TagRepositoryImpl) Delete(id uint) error {
	return r.db.Delete(&models.Tag{}, id).Error
}

// FindByID 根据ID查找标签
func (r *TagRepositoryImpl) FindByID(id uint) (*models.Tag, error) {
	var tag models.Tag
	if err := r.db.First(&tag, id).Error; err != nil {
		return nil, err
	}
	return &tag, nil
}

// FindByName 根据名称查找标签
func (r *TagRepositoryImpl) FindByName(name string) (*models.Tag, error) {
	var tag models.Tag
	if err := r.db.Where("name = ?", name).First(&tag).Error; err != nil {
		return nil, err
	}
	return &tag, nil
}

// ListAll 获取所有标签
func (r *TagRepositoryImpl) ListAll() ([]models.Tag, error) {
	var tags []models.Tag
	if err := r.db.Order("sort_order ASC, created_at DESC").Find(&tags).Error; err != nil {
		return nil, err
	}
	return tags, nil
}

// ListByCategory 根据分类获取标签
func (r *TagRepositoryImpl) ListByCategory(category string) ([]models.Tag, error) {
	var tags []models.Tag
	if err := r.db.Where("category = ?", category).Order("sort_order ASC").Find(&tags).Error; err != nil {
		return nil, err
	}
	return tags, nil
}

// List 分页获取标签
func (r *TagRepositoryImpl) List(page, pageSize int) ([]models.Tag, int64, error) {
	var tags []models.Tag
	var total int64

	if err := r.db.Model(&models.Tag{}).Count(&total).Error; err != nil {
		return nil, 0, err
	}

	offset := (page - 1) * pageSize
	err := r.db.Order("sort_order ASC, created_at DESC").
		Offset(offset).
		Limit(pageSize).
		Find(&tags).Error

	if err != nil {
		return nil, 0, err
	}

	return tags, total, nil
}

// Search 搜索标签
func (r *TagRepositoryImpl) Search(keyword string, page, pageSize int) ([]models.Tag, int64, error) {
	var tags []models.Tag
	var total int64

	db := r.db.Model(&models.Tag{}).
		Where("name LIKE ? OR description LIKE ?", "%"+keyword+"%", "%"+keyword+"%")

	if err := db.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	offset := (page - 1) * pageSize
	err := db.Order("sort_order ASC, created_at DESC").
		Offset(offset).
		Limit(pageSize).
		Find(&tags).Error

	if err != nil {
		return nil, 0, err
	}

	return tags, total, nil
}

// AssociateTag 关联标签到剧本
func (r *TagRepositoryImpl) AssociateTag(dramaID, tagID uint) error {
	dramaTag := &models.DramaTag{
		DramaID: dramaID,
		TagID:   tagID,
	}
	return r.db.Create(dramaTag).Error
}

// RemoveTag 移除剧本的标签关联
func (r *TagRepositoryImpl) RemoveTag(dramaID, tagID uint) error {
	return r.db.Where("drama_id = ? AND tag_id = ?", dramaID, tagID).
		Delete(&models.DramaTag{}).Error
}

// GetTagsByDramaID 获取剧本的所有标签
func (r *TagRepositoryImpl) GetTagsByDramaID(dramaID uint) ([]models.Tag, error) {
	var tags []models.Tag
	err := r.db.Table("tags").
		Joins("JOIN drama_tags ON drama_tags.tag_id = tags.id").
		Where("drama_tags.drama_id = ?", dramaID).
		Order("tags.sort_order ASC, tags.created_at DESC").
		Find(&tags).Error
	return tags, err
}

// SetDramaTags 设置剧本的标签（全量替换）
func (r *TagRepositoryImpl) SetDramaTags(dramaID uint, tagIDs []uint) error {
	return r.db.Transaction(func(tx *gorm.DB) error {
		// 删除现有关联
		if err := tx.Where("drama_id = ?", dramaID).Delete(&models.DramaTag{}).Error; err != nil {
			return err
		}

		// 创建新关联
		for _, tagID := range tagIDs {
			dramaTag := &models.DramaTag{
				DramaID: dramaID,
				TagID:   tagID,
			}
			if err := tx.Create(dramaTag).Error; err != nil {
				return err
			}
		}

		return nil
	})
}
```

### Step 7 测试验证

#### 单元测试

创建文件：`application/services/tag_service_test.go`

```go
package services

import (
	"testing"

	"github.com/drama-generator/backend/domain/models"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
)

// MockTagRepository 模拟标签仓库
type MockTagRepository struct {
	mock.Mock
}

func (m *MockTagRepository) Create(tag *models.Tag) error {
	args := m.Called(tag)
	return args.Error(0)
}

func (m *MockTagRepository) FindByName(name string) (*models.Tag, error) {
	args := m.Called(name)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*models.Tag), args.Error(1)
}

// ... 其他方法 ...

func TestTagService_CreateTag(t *testing.T) {
	// 测试用例
	tests := []struct {
		name    string
		req     CreateTagRequest
		wantErr bool
		errMsg  string
	}{
		{
			name: "成功创建标签",
			req: CreateTagRequest{
				Name:     "古装",
				Category: models.TagCategoryGenre,
			},
			wantErr: false,
		},
		{
			name: "重复标签名",
			req: CreateTagRequest{
				Name:     "已存在的标签",
				Category: models.TagCategoryGenre,
			},
			wantErr: true,
			errMsg:  "标签名称已存在",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// 设置测试...
		})
	}
}
```

#### API 测试

```bash
# 1. 启动服务
go run main.go

# 2. 测试创建标签
curl -X POST http://localhost:5678/api/v1/tags \
  -H "Content-Type: application/json" \
  -d '{
    "name": "悬疑",
    "color": "#ff4d4f",
    "description": "悬疑推理类短剧",
    "category": "genre",
    "sort_order": 1
  }'

# 预期响应
{
  "success": true,
  "data": {
    "id": 1,
    "name": "悬疑",
    "color": "#ff4d4f",
    "description": "悬疑推理类短剧",
    "category": "genre",
    "sort_order": 1,
    "created_at": "2026-02-04T10:00:00Z",
    "updated_at": "2026-02-04T10:00:00Z"
  },
  "timestamp": "2026-02-04T10:00:00Z"
}

# 3. 测试获取标签列表
curl http://localhost:5678/api/v1/tags?page=1&page_size=10

# 4. 测试设置剧本标签
curl -X PUT http://localhost:5678/api/v1/dramas/1/tags \
  -H "Content-Type: application/json" \
  -d '{
    "tag_ids": [1, 2, 3]
  }'

# 5. 测试获取剧本标签
curl http://localhost:5678/api/v1/dramas/1/tags
```

---

## 3. 依赖注入实践

### 3.1 构造函数注入模式

项目使用构造函数注入模式管理依赖：

```go
// ✅ 正确：通过构造函数注入依赖

type DramaHandler struct {
	db                *gorm.DB              // 数据库连接
	dramaService      *services.DramaService // 应用服务
	videoMergeService *services.VideoMergeService
	log               *logger.Logger        // 日志服务
}

func NewDramaHandler(
	db *gorm.DB, 
	cfg *config.Config, 
	log *logger.Logger, 
	transferService *services.ResourceTransferService,
) *DramaHandler {
	return &DramaHandler{
		db:                db,
		dramaService:      services.NewDramaService(db, cfg, log),
		videoMergeService: services.NewVideoMergeService(db, transferService, cfg.Storage.LocalPath, cfg.Storage.BaseURL, log),
		log:               log,
	}
}
```

### 3.2 Wire工具使用（可选）

对于更复杂的依赖关系，可以使用 Google Wire 工具：

```go
// wire.go
//go:build wireinject
// +build wireinject

package main

import (
	"github.com/google/wire"
	"github.com/drama-generator/backend/api/handlers"
	"github.com/drama-generator/backend/application/services"
	"github.com/drama-generator/backend/infrastructure/database"
)

// InitializeDramaHandler 初始化 DramaHandler
func InitializeDramaHandler() *handlers.DramaHandler {
	wire.Build(
		database.NewDatabase,
		services.NewDramaService,
		services.NewVideoMergeService,
		handlers.NewDramaHandler,
	)
	return nil
}
```

### 3.3 服务提供者模式

在 `routes.go` 中集中管理服务初始化：

```go
func SetupRouter(cfg *config.Config, db *gorm.DB, logr *logger.Logger, localStorage interface{}) *gin.Engine {
	// 共享服务实例
	transferService := services2.NewResourceTransferService(db, logr)
	
	// 初始化 Handler，注入依赖
	dramaHandler := handlers2.NewDramaHandler(db, cfg, logr, transferService)
	aiConfigHandler := handlers2.NewAIConfigHandler(db, cfg, logr)
	
	// ... 其他 handler 初始化
}
```

---

## 4. 事务管理

### 4.1 GORM事务使用

```go
// ✅ 正确：使用 GORM 事务
func (s *TagService) DeleteTag(id string) error {
	tag, err := s.GetTag(id)
	if err != nil {
		return err
	}

	// 使用事务
	err = s.db.Transaction(func(tx *gorm.DB) error {
		// 在事务中操作
		if err := tx.Where("tag_id = ?", tag.ID).Delete(&models.DramaTag{}).Error; err != nil {
			return err  // 返回错误，自动回滚
		}

		if err := tx.Delete(tag).Error; err != nil {
			return err  // 返回错误，自动回滚
		}

		return nil  // 返回 nil，自动提交
	})

	if err != nil {
		s.log.Errorw("删除标签失败", "error", err)
		return fmt.Errorf("删除标签失败: %w", err)
	}

	return nil
}
```

### 4.2 跨服务事务处理

跨服务事务通过应用层协调：

```go
func (s *DramaService) CreateDramaWithDefaultTags(req *CreateDramaRequest) (*models.Drama, error) {
	var drama *models.Drama
	
	err := s.db.Transaction(func(tx *gorm.DB) error {
		// 1. 创建剧本
		drama = &models.Drama{...}
		if err := tx.Create(drama).Error; err != nil {
			return err
		}
		
		// 2. 添加默认标签
		for _, tagID := range defaultTags {
			dramaTag := &models.DramaTag{
				DramaID: drama.ID,
				TagID:   tagID,
			}
			if err := tx.Create(dramaTag).Error; err != nil {
				return err
			}
		}
		
		return nil
	})
	
	if err != nil {
		return nil, err
	}
	
	return drama, nil
}
```

### 4.3 事务回滚策略

```go
// 手动控制事务（高级场景）
func (s *DramaService) ComplexOperation() error {
	tx := s.db.Begin()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
			panic(r)
		}
	}()
	
	// 操作1
	if err := tx.Create(&obj1).Error; err != nil {
		tx.Rollback()
		return err
	}
	
	// 操作2
	if err := tx.Create(&obj2).Error; err != nil {
		tx.Rollback()
		return err
	}
	
	// 提交
	if err := tx.Commit().Error; err != nil {
		return err
	}
	
	return nil
}
```

---

## 5. 最佳实践和常见错误

### 5.1 最佳实践

#### 1. 领域层保持纯净

```go
// ✅ 正确：领域层只依赖标准库
type Tag struct {
    ID   uint   `gorm:"primaryKey" json:"id"`
    Name string `gorm:"not null" json:"name"`
}

// 业务方法
func (t *Tag) Validate() error {
    if t.Name == "" {
        return errors.New("name is required")
    }
    return nil
}
```

#### 2. 应用层处理业务流程

```go
// ✅ 正确：应用层编排用例
func (s *TagService) CreateTag(req *CreateTagRequest) (*Tag, error) {
    // 1. 验证
    if err := validateRequest(req); err != nil {
        return nil, err
    }
    
    // 2. 业务检查
    if exists := s.checkExists(req.Name); exists {
        return nil, errors.New("already exists")
    }
    
    // 3. 创建领域对象
    tag := &Tag{Name: req.Name}
    
    // 4. 持久化
    if err := s.repo.Create(tag); err != nil {
        return nil, err
    }
    
    return tag, nil
}
```

#### 3. 基础设施层实现抽象

```go
// ✅ 正确：实现领域层定义的接口
type TagRepositoryImpl struct {
    db *gorm.DB
}

func (r *TagRepositoryImpl) Create(tag *models.Tag) error {
    return r.db.Create(tag).Error
}
```

### 5.2 常见错误

#### 错误1：领域层依赖外层

```go
// ❌ 错误：领域层依赖应用层
// domain/models/tag.go
import "github.com/drama-generator/backend/application/services"  // 禁止！
```

#### 错误2：跨层直接访问

```go
// ❌ 错误：Handler 直接访问 Repository
// api/handlers/drama.go
func (h *DramaHandler) Create(c *gin.Context) {
    drama := &models.Drama{}
    h.db.Create(drama)  // 应该通过 Service
}
```

#### 错误3：在领域层处理 HTTP

```go
// ❌ 错误：领域层处理 HTTP 状态码
// domain/models/tag.go
func (t *Tag) Save() {
    if err := db.Save(t); err != nil {
        c.JSON(500, ...)  // 领域层不应该知道 HTTP
    }
}
```

#### 错误4：贫血领域模型

```go
// ❌ 错误：领域模型只有数据，没有行为
type Tag struct {
    ID   uint
    Name string
}

// ✅ 正确：领域模型包含业务逻辑
type Tag struct {
    ID   uint
    Name string
}

func (t *Tag) SetDefaultColor() {
    if t.Color == "" {
        t.Color = defaultColors[t.Category]
    }
}

func (t *Tag) ValidateCategory() bool {
    return allowedCategories[t.Category]
}
```

---

## 相关文档

- [01-环境搭建指南.md](./01-环境搭建指南.md)
- [02-代码规范.md](./02-代码规范.md)
- [04-API开发指南.md](./04-API开发指南.md)
