# NestJS 最佳实践技能

---
技能类型: 代码生成约束
适用范围: 所有 NestJS 后端代码
优先级: P0 (必须遵守)
---

## 📋 技能说明

本技能定义了 NestJS 项目的代码规范和最佳实践。所有生成的 NestJS 代码必须严格遵循本文档的约束规则。

**核心原则**:
1. 使用依赖注入，不直接 new 对象
2. 使用装饰器声明元数据
3. 统一的异常处理
4. 结构化的日志记录
5. 配置外部化管理

---

## 🎯 约束规则

### 规则 1: 模块结构规范

**说明**: 每个业务模块必须按照标准结构组织代码

**标准结构**:
```
src/modules/[module-name]/
├── controllers/              # 控制器层
│   └── [module].controller.ts
├── services/                 # 服务层
│   └── [module].service.ts
├── repositories/             # 仓储层
│   └── [module].repository.ts
├── entities/                 # 实体定义
│   └── [module].entity.ts
├── dto/                      # 数据传输对象
│   ├── create-[module].dto.ts
│   ├── update-[module].dto.ts
│   └── [module]-response.dto.ts
├── interfaces/               # 接口定义
│   └── [module].interface.ts
├── constants/                # 常量定义
│   └── [module].constants.ts
├── exceptions/               # 自定义异常
│   └── [module].exception.ts
├── tests/                    # 测试文件
│   ├── [module].controller.spec.ts
│   └── [module].service.spec.ts
└── [module].module.ts        # 模块定义
```

**正确示例**:
```typescript
// ✅ src/modules/drama/drama.module.ts
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { DramaController } from './controllers/drama.controller';
import { DramaService } from './services/drama.service';
import { DramaRepository } from './repositories/drama.repository';
import { Drama } from './entities/drama.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Drama])],
  controllers: [DramaController],
  providers: [DramaService, DramaRepository],
  exports: [DramaService],
})
export class DramaModule {}
```

**错误示例**:
```typescript
// ❌ 所有代码混在一个文件
// src/drama/drama.ts
export class Drama { }
export class DramaService { }
export class DramaController { }
```

**检查清单**:
- [ ] 每个模块有独立的目录
- [ ] 目录结构符合标准
- [ ] 文件命名符合规范（kebab-case）
- [ ] 模块定义文件存在

---

### 规则 2: 依赖注入规范

**说明**: 使用构造函数注入，不直接实例化依赖

**正确示例**:
```typescript
// ✅ 使用依赖注入
import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ConfigService } from '@nestjs/config';
import { Drama } from '../entities/drama.entity';

@Injectable()
export class DramaService {
  private readonly logger = new Logger(DramaService.name);

  constructor(
    @InjectRepository(Drama)
    private readonly dramaRepository: Repository<Drama>,
    private readonly configService: ConfigService,
  ) {}

  async findAll(): Promise<Drama[]> {
    this.logger.log('Finding all dramas');
    return this.dramaRepository.find();
  }
}
```

**错误示例**:
```typescript
// ❌ 直接实例化依赖
export class DramaService {
  private dramaRepository = new Repository(); // 错误：直接 new
  private config = { apiKey: 'xxx' };         // 错误：硬编码配置

  async findAll() {
    console.log('Finding all dramas');        // 错误：使用 console.log
    return this.dramaRepository.find();
  }
}
```

**检查清单**:
- [ ] 类使用 @Injectable() 装饰器
- [ ] 依赖通过构造函数注入
- [ ] 使用 @InjectRepository() 注入仓储
- [ ] 不直接 new 对象
- [ ] Logger 使用 NestJS 的 Logger 类

---

### 规则 3: 控制器规范

**说明**: 控制器只负责处理 HTTP 请求，业务逻辑在 Service 中

**正确示例**:
```typescript
// ✅ 正确的控制器
import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  Query,
  HttpCode,
  HttpStatus,
  UseGuards,
  UsePipes,
  ValidationPipe,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { DramaService } from '../services/drama.service';
import { CreateDramaDto } from '../dto/create-drama.dto';
import { UpdateDramaDto } from '../dto/update-drama.dto';
import { DramaResponseDto } from '../dto/drama-response.dto';
import { JwtAuthGuard } from '@/common/guards/jwt-auth.guard';

@Controller('dramas')
@ApiTags('dramas')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
export class DramaController {
  constructor(private readonly dramaService: DramaService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Create a new drama' })
  @ApiResponse({
    status: 201,
    description: 'Drama created successfully',
    type: DramaResponseDto,
  })
  @ApiResponse({ status: 400, description: 'Bad request' })
  @UsePipes(new ValidationPipe({ transform: true }))
  async create(
    @Body() createDramaDto: CreateDramaDto,
  ): Promise<DramaResponseDto> {
    return this.dramaService.create(createDramaDto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all dramas' })
  @ApiResponse({
    status: 200,
    description: 'Dramas retrieved successfully',
    type: [DramaResponseDto],
  })
  async findAll(
    @Query('page') page: number = 1,
    @Query('limit') limit: number = 10,
  ): Promise<DramaResponseDto[]> {
    return this.dramaService.findAll({ page, limit });
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get drama by ID' })
  @ApiResponse({
    status: 200,
    description: 'Drama retrieved successfully',
    type: DramaResponseDto,
  })
  @ApiResponse({ status: 404, description: 'Drama not found' })
  async findOne(@Param('id') id: string): Promise<DramaResponseDto> {
    return this.dramaService.findOne(id);
  }

  @Put(':id')
  @ApiOperation({ summary: 'Update drama' })
  @ApiResponse({
    status: 200,
    description: 'Drama updated successfully',
    type: DramaResponseDto,
  })
  @UsePipes(new ValidationPipe({ transform: true }))
  async update(
    @Param('id') id: string,
    @Body() updateDramaDto: UpdateDramaDto,
  ): Promise<DramaResponseDto> {
    return this.dramaService.update(id, updateDramaDto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Delete drama' })
  @ApiResponse({ status: 204, description: 'Drama deleted successfully' })
  @ApiResponse({ status: 404, description: 'Drama not found' })
  async remove(@Param('id') id: string): Promise<void> {
    return this.dramaService.remove(id);
  }
}
```

**错误示例**:
```typescript
// ❌ 错误的控制器
export class DramaController {
  // 错误：缺少装饰器
  async create(dto: any) { // 错误：参数类型为 any
    // 错误：业务逻辑在控制器中
    const drama = new Drama();
    drama.title = dto.title;
    await drama.save();
    return drama;
  }

  // 错误：缺少 Swagger 文档
  async findAll() {
    return this.dramaService.findAll();
  }
}
```

**检查清单**:
- [ ] 使用 @Controller() 装饰器
- [ ] 使用 @ApiTags() 标记 API 分组
- [ ] 每个方法使用正确的 HTTP 方法装饰器
- [ ] 使用 @ApiOperation() 描述操作
- [ ] 使用 @ApiResponse() 描述响应
- [ ] 使用 @UsePipes() 进行验证
- [ ] 参数使用明确的类型（DTO）
- [ ] 返回值使用明确的类型
- [ ] 不在控制器中写业务逻辑

---

### 规则 4: 服务层规范

**说明**: 服务层包含业务逻辑，处理异常和日志

**正确示例**:
```typescript
// ✅ 正确的服务
import {
  Injectable,
  NotFoundException,
  BadRequestException,
  InternalServerErrorException,
  Logger,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Drama } from '../entities/drama.entity';
import { CreateDramaDto } from '../dto/create-drama.dto';
import { UpdateDramaDto } from '../dto/update-drama.dto';
import { DramaResponseDto } from '../dto/drama-response.dto';

@Injectable()
export class DramaService {
  private readonly logger = new Logger(DramaService.name);

  constructor(
    @InjectRepository(Drama)
    private readonly dramaRepository: Repository<Drama>,
  ) {}

  async create(createDramaDto: CreateDramaDto): Promise<DramaResponseDto> {
    this.logger.log(`Creating drama: ${createDramaDto.title}`);

    try {
      // 业务验证
      await this.validateDramaTitle(createDramaDto.title);

      // 创建实体
      const drama = this.dramaRepository.create(createDramaDto);

      // 保存
      const savedDrama = await this.dramaRepository.save(drama);

      this.logger.log(`Drama created successfully: ${savedDrama.id}`);

      // 转换为 DTO
      return this.toResponseDto(savedDrama);
    } catch (error) {
      this.logger.error(
        `Failed to create drama: ${error.message}`,
        error.stack,
      );

      if (error instanceof BadRequestException) {
        throw error;
      }

      throw new InternalServerErrorException('Failed to create drama');
    }
  }

  async findAll(options?: {
    page?: number;
    limit?: number;
  }): Promise<DramaResponseDto[]> {
    this.logger.log('Finding all dramas');

    const { page = 1, limit = 10 } = options || {};

    try {
      const [dramas, total] = await this.dramaRepository.findAndCount({
        skip: (page - 1) * limit,
        take: limit,
        order: { createdAt: 'DESC' },
      });

      this.logger.log(`Found ${dramas.length} dramas (total: ${total})`);

      return dramas.map((drama) => this.toResponseDto(drama));
    } catch (error) {
      this.logger.error(
        `Failed to find dramas: ${error.message}`,
        error.stack,
      );
      throw new InternalServerErrorException('Failed to retrieve dramas');
    }
  }

  async findOne(id: string): Promise<DramaResponseDto> {
    this.logger.log(`Finding drama: ${id}`);

    const drama = await this.dramaRepository.findOne({ where: { id } });

    if (!drama) {
      this.logger.warn(`Drama not found: ${id}`);
      throw new NotFoundException(`Drama with ID ${id} not found`);
    }

    return this.toResponseDto(drama);
  }

  async update(
    id: string,
    updateDramaDto: UpdateDramaDto,
  ): Promise<DramaResponseDto> {
    this.logger.log(`Updating drama: ${id}`);

    const drama = await this.dramaRepository.findOne({ where: { id } });

    if (!drama) {
      throw new NotFoundException(`Drama with ID ${id} not found`);
    }

    try {
      // 更新字段
      Object.assign(drama, updateDramaDto);

      // 保存
      const updatedDrama = await this.dramaRepository.save(drama);

      this.logger.log(`Drama updated successfully: ${id}`);

      return this.toResponseDto(updatedDrama);
    } catch (error) {
      this.logger.error(
        `Failed to update drama: ${error.message}`,
        error.stack,
      );
      throw new InternalServerErrorException('Failed to update drama');
    }
  }

  async remove(id: string): Promise<void> {
    this.logger.log(`Deleting drama: ${id}`);

    const drama = await this.dramaRepository.findOne({ where: { id } });

    if (!drama) {
      throw new NotFoundException(`Drama with ID ${id} not found`);
    }

    try {
      await this.dramaRepository.remove(drama);
      this.logger.log(`Drama deleted successfully: ${id}`);
    } catch (error) {
      this.logger.error(
        `Failed to delete drama: ${error.message}`,
        error.stack,
      );
      throw new InternalServerErrorException('Failed to delete drama');
    }
  }

  // 私有辅助方法
  private async validateDramaTitle(title: string): Promise<void> {
    if (title.length < 3) {
      throw new BadRequestException('Drama title must be at least 3 characters');
    }

    if (title.length > 100) {
      throw new BadRequestException('Drama title must not exceed 100 characters');
    }

    // 检查重复
    const existing = await this.dramaRepository.findOne({ where: { title } });
    if (existing) {
      throw new BadRequestException('Drama with this title already exists');
    }
  }

  private toResponseDto(drama: Drama): DramaResponseDto {
    return {
      id: drama.id,
      title: drama.title,
      description: drama.description,
      status: drama.status,
      createdAt: drama.createdAt.toISOString(),
      updatedAt: drama.updatedAt.toISOString(),
    };
  }
}
```

**错误示例**:
```typescript
// ❌ 错误的服务
export class DramaService {
  async create(dto: any) { // 错误：参数类型 any
    console.log('creating'); // 错误：使用 console.log
    
    const drama = await this.dramaRepository.save(dto); // 错误：没有验证
    return drama; // 错误：没有异常处理
  }

  async findOne(id: string) {
    return await this.dramaRepository.findOne({ where: { id } }); 
    // 错误：没有检查 null
    // 错误：没有日志
  }
}
```

**检查清单**:
- [ ] 使用 @Injectable() 装饰器
- [ ] 使用 Logger 记录日志
- [ ] 所有方法有明确的返回类型
- [ ] 使用 try-catch 处理异常
- [ ] 抛出合适的 HTTP 异常
- [ ] 验证业务规则
- [ ] 检查 null/undefined
- [ ] 记录关键操作日志

---

### 规则 5: DTO 规范

**说明**: 使用 class-validator 和 class-transformer 进行验证和转换

**正确示例**:
```typescript
// ✅ 正确的 DTO
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsString,
  IsNotEmpty,
  IsEnum,
  IsOptional,
  MinLength,
  MaxLength,
} from 'class-validator';
import { DramaStatus } from '../entities/drama.entity';

export class CreateDramaDto {
  @ApiProperty({
    description: 'Drama title',
    example: 'My Drama',
    minLength: 3,
    maxLength: 100,
  })
  @IsString()
  @IsNotEmpty()
  @MinLength(3)
  @MaxLength(100)
  title: string;

  @ApiPropertyOptional({
    description: 'Drama description',
    example: 'A great drama about...',
  })
  @IsString()
  @IsOptional()
  description?: string;

  @ApiPropertyOptional({
    description: 'Drama status',
    enum: DramaStatus,
    default: DramaStatus.DRAFT,
  })
  @IsEnum(DramaStatus)
  @IsOptional()
  status?: DramaStatus;
}

export class UpdateDramaDto {
  @ApiPropertyOptional({
    description: 'Drama title',
    minLength: 3,
    maxLength: 100,
  })
  @IsString()
  @IsOptional()
  @MinLength(3)
  @MaxLength(100)
  title?: string;

  @ApiPropertyOptional({
    description: 'Drama description',
  })
  @IsString()
  @IsOptional()
  description?: string;

  @ApiPropertyOptional({
    description: 'Drama status',
    enum: DramaStatus,
  })
  @IsEnum(DramaStatus)
  @IsOptional()
  status?: DramaStatus;
}

export class DramaResponseDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  title: string;

  @ApiProperty()
  description: string;

  @ApiProperty({ enum: DramaStatus })
  status: DramaStatus;

  @ApiProperty()
  createdAt: string;

  @ApiProperty()
  updatedAt: string;
}
```

**错误示例**:
```typescript
// ❌ 错误的 DTO
export class CreateDramaDto {
  title: string;        // 错误：缺少验证装饰器
  description: any;     // 错误：使用 any 类型
  // 错误：缺少 Swagger 文档
}
```

**检查清单**:
- [ ] 使用 class-validator 装饰器
- [ ] 使用 @ApiProperty() 文档化
- [ ] 所有字段有明确的类型
- [ ] 不使用 any 类型
- [ ] 可选字段使用 @IsOptional()
- [ ] 字符串字段有长度限制

---

### 规则 6: 异常处理规范

**说明**: 使用 NestJS 内置的 HTTP 异常

**正确示例**:
```typescript
// ✅ 正确的异常处理
import {
  NotFoundException,
  BadRequestException,
  UnauthorizedException,
  ForbiddenException,
  ConflictException,
  InternalServerErrorException,
} from '@nestjs/common';

// 资源不存在
if (!drama) {
  throw new NotFoundException(`Drama with ID ${id} not found`);
}

// 请求参数错误
if (title.length < 3) {
  throw new BadRequestException('Title must be at least 3 characters');
}

// 未认证
if (!user) {
  throw new UnauthorizedException('Please login first');
}

// 无权限
if (drama.userId !== user.id) {
  throw new ForbiddenException('You do not have permission to edit this drama');
}

// 资源冲突
if (existingDrama) {
  throw new ConflictException('Drama with this title already exists');
}

// 服务器错误
try {
  await this.dramaRepository.save(drama);
} catch (error) {
  this.logger.error(`Failed to save drama: ${error.message}`, error.stack);
  throw new InternalServerErrorException('Failed to save drama');
}
```

**错误示例**:
```typescript
// ❌ 错误的异常处理
if (!drama) {
  throw new Error('Not found'); // 错误：使用普通 Error
}

if (title.length < 3) {
  return null; // 错误：返回 null 而不是抛出异常
}

try {
  await this.dramaRepository.save(drama);
} catch (error) {
  console.error(error); // 错误：只打印错误，不抛出
}
```

**检查清单**:
- [ ] 使用 NestJS 的 HTTP 异常类
- [ ] 异常消息清晰明确
- [ ] 记录错误日志
- [ ] 不吞掉异常
- [ ] 不返回 null 代替异常

---

### 规则 7: 配置管理规范

**说明**: 使用 @nestjs/config 管理配置

**正确示例**:
```typescript
// ✅ 正确的配置管理

// 1. 配置文件 src/config/configuration.ts
export default () => ({
  port: parseInt(process.env.PORT, 10) || 3000,
  database: {
    host: process.env.DATABASE_HOST || 'localhost',
    port: parseInt(process.env.DATABASE_PORT, 10) || 5432,
  },
  storage: {
    path: process.env.STORAGE_PATH || './data/storage',
    baseUrl: process.env.STORAGE_BASE_URL || 'http://localhost:3000/static',
  },
});

// 2. 在模块中导入
import { ConfigModule } from '@nestjs/config';
import configuration from './config/configuration';

@Module({
  imports: [
    ConfigModule.forRoot({
      load: [configuration],
      isGlobal: true,
    }),
  ],
})
export class AppModule {}

// 3. 在服务中使用
import { ConfigService } from '@nestjs/config';

@Injectable()
export class DramaService {
  constructor(private readonly configService: ConfigService) {}

  getStoragePath(): string {
    return this.configService.get<string>('storage.path');
  }
}
```

**错误示例**:
```typescript
// ❌ 错误的配置管理
const STORAGE_PATH = '/data/storage'; // 错误：硬编码
const API_KEY = 'sk-xxx'; // 错误：硬编码敏感信息

export class DramaService {
  private storagePath = process.env.STORAGE_PATH || '/data/storage'; 
  // 错误：直接使用 process.env
}
```

**检查清单**:
- [ ] 使用 ConfigModule
- [ ] 配置文件独立
- [ ] 不硬编码配置
- [ ] 不直接使用 process.env
- [ ] 敏感信息使用环境变量

---

## 🔍 验证方法

### 自动验证

使用 ESLint 和 TypeScript 编译器：

```json
// .eslintrc.js
module.exports = {
  rules: {
    '@typescript-eslint/no-explicit-any': 'error',
    '@typescript-eslint/explicit-function-return-type': 'error',
    'no-console': 'error',
  },
};
```

### 手动验证清单

在代码审查时检查：

- [ ] 模块结构符合规范
- [ ] 使用依赖注入
- [ ] 控制器只处理 HTTP 请求
- [ ] 服务层包含业务逻辑
- [ ] DTO 有完整的验证
- [ ] 异常处理完整
- [ ] 配置外部化
- [ ] 日志记录完整
- [ ] Swagger 文档完整

---

## 📚 参考资料

- [NestJS 官方文档](https://docs.nestjs.com/)
- [NestJS 最佳实践](https://docs.nestjs.com/techniques/configuration)
- [TypeScript 严格模式](https://www.typescriptlang.org/tsconfig#strict)

---

*技能版本: v1.0*  
*创建时间: 2026-02-06*  
*维护者: Refactor Team*
