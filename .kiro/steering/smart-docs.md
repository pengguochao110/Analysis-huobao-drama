---
inclusion: manual
description: AI-powered comprehensive codebase documentation generator using C4 model diagrams and Mermaid visualizations
keywords: documentation, C4 model, architecture diagrams, technical docs, codebase analysis, mermaid
---

# Smart Documentation Generator

Generate comprehensive, professional codebase documentation with C4 model architecture diagrams.

## Core Principles

1. **Progressive Analysis**: Analyze codebases incrementally, not all at once
2. **Pattern Recognition**: Identify common architectural patterns
3. **C4 Model**: Structure documentation following C4 model levels
4. **Mermaid Diagrams**: Use Mermaid for all visualizations
5. **Markdown Output**: Generate well-structured markdown files

## Workflow

### Phase 1: Project Discovery (5-10 minutes)

**Objective**: Understand project structure, technology stack, and scope

**Steps**:

1. **Get Project Overview**:
   - Use directory listing to understand structure
   - Exclude: node_modules, target, build, dist, vendor, __pycache__, .git

2. **Count Lines of Code**:
   - Identify file types and count lines
   - Get sense of project size

3. **Identify Entry Points**:
   - README files
   - Config files (package.json, Cargo.toml, pom.xml, go.mod, setup.py)
   - Main entry points (main.*, index.*, app.*)

4. **Read Key Files**:
   - README.md
   - Package/build config files
   - Main entry point files

5. **Determine Technology Stack**:
   - Primary language(s)
   - Frameworks used
   - Build tools
   - Dependencies

### Phase 2: Architecture Analysis (10-20 minutes)

**Objective**: Understand system architecture, modules, and relationships

**Steps**:

1. **Identify Modules/Packages**
2. **Map Dependencies**
3. **Detect Architectural Patterns**:
   - MVC/MVVM patterns
   - Layered architecture
   - Microservices vs monolith
   - Event-driven architecture
   - Domain-driven design patterns

4. **Identify Core Components**:
   - API endpoints/routes
   - Database models/entities
   - Business logic/services
   - Utilities/helpers
   - Configuration management

### Phase 3: Documentation Generation (20-40 minutes)

**Objective**: Create comprehensive markdown documentation

Create `./docs/` directory structure:

```
./docs/
├── 1. Project Overview.md
├── 2. Architecture Overview.md
├── 3. Workflow Overview.md
└── 4. Deep Dive/
    ├── [Component1].md
    ├── [Component2].md
    └── [Component3].md
```

#### Document 1: Project Overview.md

**Content Structure**:
- What is [Project Name]?
- Core Purpose
- Technology Stack
- Key Features
- Project Structure
- Getting Started
- Architecture Summary

#### Document 2: Architecture Overview.md

**Content Structure**:
- System Context (C4 Level 1) with Mermaid C4Context diagram
- Container Architecture (C4 Level 2) with Mermaid C4Container diagram
- Component Architecture (C4 Level 3) with Mermaid graph
- Architectural Patterns
- Key Design Decisions
- Module Breakdown

#### Document 3: Workflow Overview.md

**Content Structure**:
- Core Workflows with Mermaid sequence diagrams
- Data Flow with Mermaid flowcharts
- State Management
- Error Handling

#### Documents 4+: Deep Dive Components

For each major module/component:
- Overview
- Responsibilities
- Architecture with Mermaid class diagrams
- Key Files
- Implementation Details
- Dependencies
- API/Interface
- Testing
- Potential Improvements

### Phase 4: Diagram Generation (10-15 minutes)

**Mermaid Diagram Types to Use**:

1. **System Context** - C4Context
2. **Container Diagram** - C4Container
3. **Component Relationships** - Graph TB/LR
4. **Sequence Diagrams** - For workflows
5. **Class Diagrams** - For OOP architectures
6. **State Diagrams** - For state machines
7. **ER Diagrams** - For data models
8. **Flow Charts** - For processes

**Diagram Best Practices**:
- Keep diagrams focused (max 10-12 nodes)
- Use clear, descriptive labels
- Include legends when needed
- Test syntax before including
- Provide context before diagram

### Phase 5: Quality Assurance (5-10 minutes)

**Checklist**:
- [ ] All markdown files created
- [ ] Mermaid syntax validated
- [ ] Cross-references work
- [ ] File structure logical
- [ ] No Lorem ipsum placeholders
- [ ] Code examples accurate
- [ ] Diagrams render correctly
- [ ] Consistent formatting

## Language-Specific Patterns

### Rust Projects
- Focus on: modules, traits, lifetimes, error handling
- Key files: `Cargo.toml`, `src/main.rs`, `src/lib.rs`
- Document: ownership patterns, async/await usage

### Python Projects
- Focus on: packages, classes, decorators, type hints
- Key files: `setup.py`, `pyproject.toml`, `__init__.py`
- Document: virtual env, dependency management

### Java Projects
- Focus on: packages, interfaces, annotations
- Key files: `pom.xml`, `build.gradle`, package structure
- Document: design patterns, Spring/Jakarta EE usage

### JavaScript/TypeScript Projects
- Focus on: modules, components, hooks (if React)
- Key files: `package.json`, `tsconfig.json`
- Document: build process, bundling, type system

## Large Codebase Strategy

For projects >1000 files:

1. **Prioritize Core Modules**: Focus on main functionality first
2. **Batch Processing**: Analyze 10-20 files at a time
3. **Progressive Documentation**: Generate overview first, details later
4. **Multiple Passes**: Refine documentation in iterations

## Output Format

Always use markdown with:
- Clear headings (# ## ###)
- Code blocks with language tags
- Mermaid diagrams in code blocks
- Lists for clarity
- Links between documents

## When to Use

✅ **Use When**:
- Need comprehensive codebase documentation
- Want C4 model architecture diagrams
- Understanding unfamiliar codebase
- Onboarding new team members
- Preparing technical presentations
- Documentation maintenance

❌ **Don't Use When**:
- Need exact specific format
- Working with proprietary/closed-source tools
- Require specific documentation templates
- Have custom documentation workflows
