# NestJS DDD 模式技能

---
技能类型: 架构约束
适用范围: 所有 NestJS 后端代码
优先级: P0 (必须遵守)
---

## 📋 技能说明

本技能定义了基于 DDD（领域驱动设计）的 NestJS 项目架构规范。确保代码遵循 DDD 分层架构和模式。

**核心原则**:
1. 清晰的分层架构（API、应用、领域、基础设施）
2. 领域模型的独立性
3. 仓储模式的正确使用
4. 领域服务与应用服务的分离
5. 领域事件的使用

---

## 🎯 DDD 分层架构

```
┌─────────────────────────────────────────┐
│         API 层 (Presentation)           │
│  Controllers, DTOs, Pipes, Guards       │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│         应用层 (Application)            │
│  Application Services, Use Cases        │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│         领域层 (Domain)                 │
│  Entities, Value Objects, Domain        │
│  Services, Repository Interfaces,       │
│  Domain Events                          │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│      基础设施层 (Infrastructure)        │
│  Repository Implementations, Database,  │
│  External Services, Adapters            │
└─────────────────────────────────────────┘
```

---

## 🎯 约束规则

### 规则 1: 分层目录结构

**说明**: 代码必须按照 DDD 分层组织

**标准结构**:
```
src/
├── modules/
│   └── drama/
│       ├── api/                    # API 层
│       │   ├── controllers/
│       │   ├── dto/
│       │   ├── pipes/
│       │   └── guards/
│       ├── application/            # 应用层
│       │   ├── services/
│       │   └── use-cases/
│       ├── domain/                 # 领域层
│       │   ├── entities/
│       │   ├── value-objects/
│       │   ├── services/
│       │   ├── repositories/       # 接口
│       │   └── events/
│       ├── infrastructure/         # 基础设施层
│       │   ├── repositories/       # 实现
│       │   ├── adapters/
│       │   └── persistence/
│       └── drama.module.ts
└── common/                         # 共享代码
    ├── domain/
    │   └── base.entity.ts
    └── infrastructure/
        └── database/
```

**正确示例**:
```typescript
// ✅ 正确的分层结构

// src/modules/drama/domain/entities/drama.entity.ts
export class Drama {
  // 领域实体
}

// src/modules/drama/domain/repositories/drama.repository.interface.ts
export interface IDramaRepository {
  // 仓储接口
}

// src/modules/drama/infrastructure/repositories/drama.repository.ts
export class DramaRepository implements IDramaRepository {
  // 仓储实现
}

// src/modules/drama/application/services/drama.service.ts
export class DramaService {
  // 应用服务
}

// src/modules/drama/api/controllers/drama.controller.ts
export class DramaController {
  // API 控制器
}
```

**错误示例**:
```typescript
// ❌ 错误的结构
src/modules/drama/
├── drama.entity.ts          // 错误：没有分层
├── drama.repository.ts
├── drama.service.ts
└── drama.controller.ts
```

**检查清单**:
- [ ] 代码按照 DDD 四层组织
- [ ] 每层的职责清晰
- [ ] 依赖方向正确（上层依赖下层）

---

### 规则 2: 领域实体规范

**说明**: 领域实体包含业务逻辑和领域方法

**正确示例**:
```typescript
// ✅ 正确的领域实体
// src/modules/drama/domain/entities/drama.entity.ts

import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn } from 'typeorm';
import { DramaStatus } from '../value-objects/drama-status.vo';
import { DomainException } from '@/common/domain/exceptions/domain.exception';

@Entity('dramas')
export class Drama {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  title: string;

  @Column('text')
  description: string;

  @Column({
    type: 'enum',
    enum: DramaStatus,
    default: DramaStatus.DRAFT,
  })
  status: DramaStatus;

  @Column({ nullable: true })
  publishedAt: Date;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  // 领域方法：发布短剧
  publish(): void {
    if (this.status !== DramaStatus.DRAFT) {
      throw new DomainException('Only draft dramas can be published');
    }

    if (!this.title || this.title.length < 3) {
      throw new DomainException('Drama must have a valid title before publishing');
    }

    this.status = DramaStatus.PUBLISHED;
    this.publishedAt = new Date();
  }

  // 领域方法：归档短剧
  archive(): void {
    if (this.status === DramaStatus.ARCHIVED) {
      throw new DomainException('Drama is already archived');
    }

    this.status = DramaStatus.ARCHIVED;
  }

  // 领域方法：恢复短剧
  restore(): void {
    if (this.status !== DramaStatus.ARCHIVED) {
      throw new DomainException('Only archived dramas can be restored');
    }

    this.status = DramaStatus.DRAFT;
  }

  // 领域方法：验证标题
  updateTitle(newTitle: string): void {
    if (!newTitle || newTitle.length < 3) {
      throw new DomainException('Title must be at least 3 characters');
    }

    if (newTitle.length > 100) {
      throw new DomainException('Title must not exceed 100 characters');
    }

    this.title = newTitle;
  }

  // 领域查询方法
  isPublished(): boolean {
    return this.status === DramaStatus.PUBLISHED;
  }

  isDraft(): boolean {
    return this.status === DramaStatus.DRAFT;
  }

  canBeEdited(): boolean {
    return this.status === DramaStatus.DRAFT;
  }
}
```

**错误示例**:
```typescript
// ❌ 错误的领域实体
export class Drama {
  id: string;
  title: string;
  status: string;
  
  // 错误：没有领域方法
  // 错误：没有业务逻辑
  // 错误：没有验证
}
```

**检查清单**:
- [ ] 实体包含领域方法
- [ ] 领域方法包含业务规则验证
- [ ] 使用领域异常
- [ ] 不包含基础设施代码（如数据库查询）

---

### 规则 3: 值对象规范

**说明**: 使用值对象封装领域概念

**正确示例**:
```typescript
// ✅ 正确的值对象
// src/modules/drama/domain/value-objects/drama-status.vo.ts

export enum DramaStatus {
  DRAFT = 'draft',
  PUBLISHED = 'published',
  ARCHIVED = 'archived',
}

// src/modules/drama/domain/value-objects/drama-title.vo.ts
export class DramaTitle {
  private readonly value: string;

  constructor(title: string) {
    this.validate(title);
    this.value = title;
  }

  private validate(title: string): void {
    if (!title || title.trim().length === 0) {
      throw new Error('Title cannot be empty');
    }

    if (title.length < 3) {
      throw new Error('Title must be at least 3 characters');
    }

    if (title.length > 100) {
      throw new Error('Title must not exceed 100 characters');
    }
  }

  getValue(): string {
    return this.value;
  }

  equals(other: DramaTitle): boolean {
    return this.value === other.value;
  }
}
```

**检查清单**:
- [ ] 值对象是不可变的
- [ ] 包含验证逻辑
- [ ] 实现 equals 方法

---

### 规则 4: 仓储模式规范

**说明**: 使用仓储模式隔离领域层和基础设施层

**正确示例**:
```typescript
// ✅ 正确的仓储模式

// 1. 定义仓储接口（领域层）
// src/modules/drama/domain/repositories/drama.repository.interface.ts
export interface IDramaRepository {
  findById(id: string): Promise<Drama | null>;
  findAll(options?: FindOptions): Promise<Drama[]>;
  findByStatus(status: DramaStatus): Promise<Drama[]>;
  save(drama: Drama): Promise<Drama>;
  delete(id: string): Promise<void>;
  count(): Promise<number>;
}

export interface FindOptions {
  page?: number;
  limit?: number;
  sortBy?: string;
  sortOrder?: 'ASC' | 'DESC';
}

// 2. 实现仓储（基础设施层）
// src/modules/drama/infrastructure/repositories/drama.repository.ts
import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Drama } from '../../domain/entities/drama.entity';
import { IDramaRepository, FindOptions } from '../../domain/repositories/drama.repository.interface';
import { DramaStatus } from '../../domain/value-objects/drama-status.vo';

@Injectable()
export class DramaRepository implements IDramaRepository {
  constructor(
    @InjectRepository(Drama)
    private readonly repository: Repository<Drama>,
  ) {}

  async findById(id: string): Promise<Drama | null> {
    return this.repository.findOne({ where: { id } });
  }

  async findAll(options?: FindOptions): Promise<Drama[]> {
    const { page = 1, limit = 10, sortBy = 'createdAt', sortOrder = 'DESC' } = options || {};

    return this.repository.find({
      skip: (page - 1) * limit,
      take: limit,
      order: { [sortBy]: sortOrder },
    });
  }

  async findByStatus(status: DramaStatus): Promise<Drama[]> {
    return this.repository.find({ where: { status } });
  }

  async save(drama: Drama): Promise<Drama> {
    return this.repository.save(drama);
  }

  async delete(id: string): Promise<void> {
    await this.repository.delete(id);
  }

  async count(): Promise<number> {
    return this.repository.count();
  }
}

// 3. 在模块中注册
// src/modules/drama/drama.module.ts
@Module({
  imports: [TypeOrmModule.forFeature([Drama])],
  providers: [
    DramaRepository,
    {
      provide: 'IDramaRepository',
      useClass: DramaRepository,
    },
  ],
  exports: ['IDramaRepository'],
})
export class DramaModule {}

// 4. 在服务中使用接口
// src/modules/drama/application/services/drama.service.ts
@Injectable()
export class DramaService {
  constructor(
    @Inject('IDramaRepository')
    private readonly dramaRepository: IDramaRepository,
  ) {}

  async findById(id: string): Promise<Drama> {
    const drama = await this.dramaRepository.findById(id);
    
    if (!drama) {
      throw new NotFoundException(`Drama with ID ${id} not found`);
    }

    return drama;
  }
}
```

**错误示例**:
```typescript
// ❌ 错误的仓储模式

// 错误：直接在服务中使用 TypeORM Repository
@Injectable()
export class DramaService {
  constructor(
    @InjectRepository(Drama)
    private readonly repository: Repository<Drama>, // 错误：直接依赖 TypeORM
  ) {}
}

// 错误：没有定义仓储接口
export class DramaRepository {
  // 直接实现，没有接口
}
```

**检查清单**:
- [ ] 仓储接口在领域层
- [ ] 仓储实现在基础设施层
- [ ] 服务依赖仓储接口，不依赖实现
- [ ] 使用依赖注入注册仓储

---

### 规则 5: 领域服务与应用服务分离

**说明**: 领域服务处理领域逻辑，应用服务编排业务流程

**正确示例**:
```typescript
// ✅ 正确的服务分层

// 1. 领域服务（Domain Service）
// src/modules/drama/domain/services/drama-domain.service.ts
@Injectable()
export class DramaDomainService {
  // 领域逻辑：验证标题
  validateTitle(title: string): boolean {
    return title.length >= 3 && title.length <= 100;
  }

  // 领域逻辑：计算短剧时长
  calculateDuration(scenes: Scene[]): number {
    return scenes.reduce((total, scene) => total + scene.duration, 0);
  }

  // 领域逻辑：检查是否可以发布
  canPublish(drama: Drama): boolean {
    return (
      drama.isDraft() &&
      drama.title &&
      drama.title.length >= 3 &&
      drama.description &&
      drama.description.length >= 10
    );
  }
}

// 2. 应用服务（Application Service）
// src/modules/drama/application/services/drama.service.ts
@Injectable()
export class DramaService {
  constructor(
    @Inject('IDramaRepository')
    private readonly dramaRepository: IDramaRepository,
    private readonly dramaDomainService: DramaDomainService,
    private readonly eventBus: EventBus,
    private readonly logger: Logger,
  ) {}

  // 应用逻辑：编排业务流程
  async create(dto: CreateDramaDto): Promise<Drama> {
    this.logger.log(`Creating drama: ${dto.title}`);

    // 1. 验证（使用领域服务）
    if (!this.dramaDomainService.validateTitle(dto.title)) {
      throw new BadRequestException('Invalid drama title');
    }

    // 2. 创建领域实体
    const drama = new Drama();
    drama.updateTitle(dto.title);
    drama.description = dto.description;

    // 3. 保存（使用仓储）
    const savedDrama = await this.dramaRepository.save(drama);

    // 4. 发布领域事件
    await this.eventBus.publish(new DramaCreatedEvent(savedDrama.id));

    this.logger.log(`Drama created: ${savedDrama.id}`);

    return savedDrama;
  }

  async publish(id: string): Promise<Drama> {
    this.logger.log(`Publishing drama: ${id}`);

    // 1. 获取实体
    const drama = await this.dramaRepository.findById(id);
    if (!drama) {
      throw new NotFoundException(`Drama with ID ${id} not found`);
    }

    // 2. 验证（使用领域服务）
    if (!this.dramaDomainService.canPublish(drama)) {
      throw new BadRequestException('Drama cannot be published');
    }

    // 3. 执行领域方法
    drama.publish();

    // 4. 保存
    const publishedDrama = await this.dramaRepository.save(drama);

    // 5. 发布领域事件
    await this.eventBus.publish(new DramaPublishedEvent(publishedDrama.id));

    this.logger.log(`Drama published: ${id}`);

    return publishedDrama;
  }
}
```

**错误示例**:
```typescript
// ❌ 错误的服务分层

// 错误：所有逻辑混在应用服务中
@Injectable()
export class DramaService {
  async create(dto: any) {
    // 错误：领域逻辑在应用服务中
    if (dto.title.length < 3) {
      throw new Error('Invalid title');
    }

    // 错误：直接操作数据库
    const drama = await this.repository.save(dto);

    return drama;
  }
}
```

**检查清单**:
- [ ] 领域服务只包含领域逻辑
- [ ] 应用服务编排业务流程
- [ ] 应用服务使用领域服务
- [ ] 应用服务使用仓储接口
- [ ] 应用服务发布领域事件

---

### 规则 6: 领域事件规范

**说明**: 使用领域事件解耦模块

**正确示例**:
```typescript
// ✅ 正确的领域事件

// 1. 定义领域事件
// src/modules/drama/domain/events/drama-created.event.ts
export class DramaCreatedEvent {
  constructor(
    public readonly dramaId: string,
    public readonly occurredAt: Date = new Date(),
  ) {}
}

// src/modules/drama/domain/events/drama-published.event.ts
export class DramaPublishedEvent {
  constructor(
    public readonly dramaId: string,
    public readonly occurredAt: Date = new Date(),
  ) {}
}

// 2. 在应用服务中发布事件
// src/modules/drama/application/services/drama.service.ts
@Injectable()
export class DramaService {
  constructor(
    private readonly eventBus: EventBus,
  ) {}

  async create(dto: CreateDramaDto): Promise<Drama> {
    const drama = await this.dramaRepository.save(newDrama);

    // 发布领域事件
    await this.eventBus.publish(new DramaCreatedEvent(drama.id));

    return drama;
  }
}

// 3. 创建事件处理器
// src/modules/notification/application/handlers/drama-created.handler.ts
@EventsHandler(DramaCreatedEvent)
export class DramaCreatedHandler implements IEventHandler<DramaCreatedEvent> {
  constructor(
    private readonly notificationService: NotificationService,
  ) {}

  async handle(event: DramaCreatedEvent): Promise<void> {
    // 处理事件：发送通知
    await this.notificationService.sendDramaCreatedNotification(event.dramaId);
  }
}
```

**检查清单**:
- [ ] 领域事件在领域层定义
- [ ] 事件包含必要的数据
- [ ] 在应用服务中发布事件
- [ ] 事件处理器独立

---

## 🔍 验证方法

### DDD 架构检查清单

- [ ] 代码按照四层组织
- [ ] 领域实体包含领域方法
- [ ] 使用值对象封装领域概念
- [ ] 使用仓储模式
- [ ] 领域服务与应用服务分离
- [ ] 使用领域事件
- [ ] 依赖方向正确（上层依赖下层）
- [ ] 领域层不依赖基础设施层

---

## 📚 参考资料

- [Domain-Driven Design](https://domainlanguage.com/ddd/)
- [NestJS CQRS](https://docs.nestjs.com/recipes/cqrs)
- [DDD in TypeScript](https://khalilstemmler.com/articles/domain-driven-design-intro/)

---

*技能版本: v1.0*  
*创建时间: 2026-02-06*  
*维护者: Refactor Team*
