# 火宝短剧 (Huobao Drama) 产品文档

**版本**: v1.0  
**最后更新**: 2025-02-03  

---

## 产品概述

火宝短剧（Huobao Drama）是一个开源的AI驱动短剧自动化生产平台，支持从剧本生成到视频合成的全流程自动化。

### 核心价值

- **自动化生产**: 从剧本到成品的端到端自动化
- **AI驱动**: 集成多种AI服务提供商，智能生成角色、场景、分镜、视频
- **灵活配置**: 支持多种AI服务配置，可根据需求灵活切换
- **开源免费**: 完全开源，支持私有化部署

---

## 需求文档索引

### 已生成的需求文档

| 文档类型 | 文件路径 | 版本 | 日期 | 状态 |
|---------|---------|------|------|------|
| **软件需求规格说明书 (SRS)** | `docs/requirements/srs/srs-huobao-drama-v1.0.md` | v1.0 | 2025-02-03 | 草案 |
| **功能需求说明书** | `docs/requirements/functional/functional-requirements-huobao-drama-20250203.md` | v1.0 | 2025-02-03 | 草案 |
| **非功能需求说明书** | `docs/requirements/non-functional/non-functional-requirements-20250203.md` | v1.0 | 2025-02-03 | 草案 |
| **用户故事** | `docs/requirements/user-stories/user-stories-huobao-drama-20250203.md` | v1.0 | 2025-02-03 | 草案 |
| **数据需求说明书** | `docs/requirements/data/data-requirements-20250203.md` | v1.0 | 2025-02-03 | 草案 |
| **业务规则说明书** | `docs/requirements/business/business-rules-20250203.md` | v1.0 | 2025-02-03 | 草案 |

### 需求文档结构

```
docs/requirements/
├── srs/
│   └── srs-huobao-drama-v1.0.md              # 软件需求规格说明书
├── functional/
│   └── functional-requirements-huobao-drama-20250203.md  # 功能需求
├── non-functional/
│   └── non-functional-requirements-20250203.md          # 非功能需求
├── user-stories/
│   └── user-stories-huobao-drama-20250203.md            # 用户故事
├── data/
│   └── data-requirements-20250203.md                    # 数据需求
└── business/
    └── business-rules-20250203.md                     # 业务规则
```

---

## 核心功能模块

### 1. 短剧管理 (Drama Management)
- **功能ID前缀**: FR-DM-xxx, US-DM-xxx
- **对应文档**: 功能需求说明书第1章、用户故事第1章
- **核心功能**:
  - 短剧项目CRUD
  - 剧本大纲管理
  - 分集管理
  - 项目统计

### 2. 角色管理 (Character Management)
- **功能ID前缀**: FR-CM-xxx, US-CM-xxx
- **对应文档**: 功能需求说明书第2章、用户故事第2章
- **核心功能**:
  - 角色CRUD
  - AI角色图像生成
  - 批量角色生成
  - 角色库管理

### 3. 场景管理 (Scene Management)
- **功能ID前缀**: FR-SM-xxx, US-SM-xxx
- **对应文档**: 功能需求说明书第3章、用户故事第3章
- **核心功能**:
  - 场景CRUD
  - AI场景图像生成

### 4. 分镜管理 (Storyboard Management)
- **功能ID前缀**: FR-SB-xxx, US-SB-xxx
- **对应文档**: 功能需求说明书第4章、用户故事第4章
- **核心功能**:
  - 自动剧本解析
  - 分镜手动编辑
  - 分镜图像生成
  - 帧提示词管理

### 5. 道具管理 (Prop Management)
- **功能ID前缀**: FR-PM-xxx
- **对应文档**: 功能需求说明书第5章
- **核心功能**:
  - 道具CRUD
  - AI道具图像生成
  - 剧本道具提取

### 6. 图像生成 (Image Generation)
- **功能ID前缀**: FR-IG-xxx, US-IG-xxx
- **对应文档**: 功能需求说明书第6章、用户故事第5章
- **核心功能**:
  - 图像生成任务管理
  - 图像类型支持
  - 批量图像生成
  - 图像资产管理

### 7. 视频生成 (Video Generation)
- **功能ID前缀**: FR-VG-xxx, US-VG-xxx
- **对应文档**: 功能需求说明书第7章、用户故事第6章
- **核心功能**:
  - 视频生成任务管理
  - 视频参数配置
  - 图生视频
  - 批量视频生成

### 8. 视频合成 (Video Merge)
- **功能ID前缀**: FR-VM-xxx, US-VM-xxx
- **对应文档**: 功能需求说明书第8章、用户故事第7章
- **核心功能**:
  - 视频合并
  - 音频提取

### 9. AI配置管理 (AI Configuration)
- **功能ID前缀**: FR-AI-xxx, US-AI-xxx
- **对应文档**: 功能需求说明书第9章、用户故事第8章
- **核心功能**:
  - AI服务配置CRUD
  - AI服务测试
  - 多提供商支持

### 10. 资产管理 (Asset Management)
- **功能ID前缀**: FR-AM-xxx, US-AM-xxx
- **对应文档**: 功能需求说明书第10章、用户故事第9章
- **核心功能**:
  - 资产CRUD
  - 资产元数据
  - 资产收藏与浏览

### 11. 任务管理 (Task Management)
- **功能ID前缀**: FR-TM-xxx, US-TM-xxx
- **对应文档**: 功能需求说明书第11章、用户故事第10章
- **核心功能**:
  - 异步任务管理
  - 任务类型支持

---

## 数据模型

### 核心实体

| 实体 | 对应文档 | 关系 |
|-----|---------|------|
| Drama | 数据需求第1.1.1节 | 1:N Episode, 1:N Character, 1:N Scene, 1:N Prop |
| Character | 数据需求第1.1.2节 | N:M Episode, N:M Storyboard, 1:N ImageGeneration |
| Episode | 数据需求第1.1.3节 | N:M Character, 1:N Scene, 1:N Storyboard |
| Scene | 数据需求第1.1.4节 | 1:N Storyboard, 1:N ImageGeneration |
| Storyboard | 数据需求第1.1.5节 | N:M Character, N:M Prop, 1:N ImageGeneration, 1:N VideoGeneration |
| Prop | 数据需求第1.1.6节 | N:M Storyboard, 1:N ImageGeneration |

### 生成记录实体

| 实体 | 对应文档 | 用途 |
|-----|---------|------|
| ImageGeneration | 数据需求第1.2.1节 | 记录AI图像生成任务 |
| VideoGeneration | 数据需求第1.2.2节 | 记录AI视频生成任务 |

### 配置与任务实体

| 实体 | 对应文档 | 用途 |
|-----|---------|------|
| AIServiceConfig | 数据需求第1.3.1节 | AI服务配置 |
| AsyncTask | 数据需求第1.3.2节 | 异步任务记录 |
| Asset | 数据需求第1.3.3节 | 媒体资产库 |
| CharacterLibrary | 数据需求第1.3.4节 | 全局角色库 |
| FramePrompt | 数据需求第1.3.5节 | 帧提示词 |

---

## 技术栈

- **后端**: Go 1.23 + Gin Framework
- **前端**: Vue 3 + TypeScript + Element Plus
- **数据库**: SQLite (开发) / MySQL (生产)
- **ORM**: GORM
- **存储**: 本地文件系统 / MinIO
- **AI服务**: OpenAI, Gemini, 豆包, 火山引擎等
- **视频处理**: FFmpeg

---

## 业务流程

### 主要业务流程

1. **短剧创作流程** (业务规则第2.1节)
   - 项目创建 → 大纲编写 → 角色设计 → 场景设定 → 分集规划 → 剧本编写 → 分镜生成 → 图像生成 → 视频生成 → 视频合成

2. **角色管理流程** (业务规则第2.2节)
   - 角色创建 → 图像生成/上传/库选择 → 应用到剧集

3. **分镜制作流程** (业务规则第2.3节)
   - 自动解析: 提交剧本 → AI解析 → 创建场景/角色/分镜
   - 手动编辑: 创建/编辑分镜 → 保存验证 → 生成图像

4. **AI生成任务流程** (业务规则第2.4节)
   - 单图像/视频生成: 提交请求 → 创建任务 → 调用AI → 处理结果
   - 批量生成: 提交批量请求 → 任务分解 → 队列处理 → 完成通知

5. **视频合成流程** (业务规则第2.5节)
   - 准备阶段 → 创建任务 → FFmpeg合成 → 处理结果 → 完成通知

---

## 验收标准汇总

### 功能验收标准 (EARS格式)

```
【短剧管理】
WHEN 用户提交有效项目信息 THEN 系统 SHALL 创建新项目
WHEN 用户请求项目列表 THEN 系统 SHALL 返回分页结果

【角色管理】
WHEN 用户创建角色 THEN 系统 SHALL 检查名称唯一性
WHEN 用户请求生成角色图像 THEN 系统 SHALL 调用AI服务

【场景管理】
WHEN 用户创建场景 THEN 系统 SHALL 存储地点、时间、提示词
WHEN 用户请求生成场景图像 THEN 系统 SHALL 使用场景提示词

【分镜管理】
WHEN 用户提交剧本 THEN 系统 SHALL 调用AI服务解析
WHEN 解析完成 THEN 系统 SHALL 创建分镜记录

【图像生成】
WHEN 用户提交生成请求 THEN 系统 SHALL 立即返回任务ID
WHEN AI服务开始处理 THEN 系统 SHALL 更新状态为processing

【视频生成】
WHEN 用户提交视频生成请求 THEN 系统 SHALL 创建任务记录
WHEN 用户提供参考图像 THEN 系统 SHALL 支持多种参考模式

【视频合成】
WHEN 用户选择多个视频 THEN 系统 SHALL 使用FFmpeg合并
WHEN 指定转场效果 THEN 系统 SHALL 添加过渡效果
```

### 非功能验收标准 (EARS格式)

```
【性能】
WHEN 请求列表数据 THEN 系统 SHALL 在2秒内返回
WHEN 50个用户同时访问 THEN 系统 SHALL 正常响应
WHEN 批量任务提交 THEN 系统 SHALL 最多并行处理10个图像生成

【可用性】
WHEN 系统部署运行 THEN 可用率 SHALL 达到99.5%
WHEN 系统崩溃 THEN 系统 SHALL 在5分钟内恢复

【安全性】
WHEN 存储API密钥 THEN 系统 SHALL 使用AES-256加密
WHEN 用户提交表单 THEN 系统 SHALL 验证数据类型和长度
```

---

## 变更历史

| 日期 | 版本 | 变更内容 | 作者 |
|-----|------|---------|------|
| 2025-02-03 | v1.0 | 初始版本，生成完整需求文档 | AI Assistant |

---

## 待办事项

- [ ] 需求评审会议
- [ ] 技术方案设计
- [ ] 原型设计
- [ ] 开发计划制定
- [ ] 测试计划制定

---

**文档结束**
