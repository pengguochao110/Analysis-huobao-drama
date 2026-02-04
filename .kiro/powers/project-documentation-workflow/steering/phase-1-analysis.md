# Phase 1: Project Analysis

Detailed workflow for analyzing project structure, tech stack, and architecture.

## Workflow Steps

### Step 1: Quick Overview (5 minutes)

**Actions:**
1. Read README.md (first 100 lines)
2. List root directory files
3. Identify project type (web app, library, CLI, etc.)
4. Note any existing documentation

**Output:**
- Project name and purpose
- Project type classification
- Existing documentation inventory

### Step 2: Tech Stack Detection (10 minutes)

**Package Manager Detection:**
```bash
# Check for these files:
- package.json → Node.js/JavaScript/TypeScript
- go.mod → Go
- Cargo.toml → Rust
- requirements.txt, pyproject.toml → Python
- pom.xml, build.gradle → Java
- Gemfile → Ruby
- composer.json → PHP
```

**Framework Detection:**
- Read dependencies in package files
- Check import statements in main files
- Identify web frameworks, ORMs, testing frameworks

**Infrastructure Detection:**
```bash
# Check for these files:
- Dockerfile, docker-compose.yml
- kubernetes/, k8s/
- terraform/, *.tf
- .github/workflows/
- .gitlab-ci.yml
```

**Output:**
- Complete technology inventory
- Framework versions
- Infrastructure setup

### Step 3: Architecture Mapping (15 minutes)

**Directory Structure Analysis:**
1. Map top 3 levels of directory tree
2. Annotate each directory with purpose
3. Identify architectural patterns

**Pattern Recognition:**
- **DDD**: domain/, application/, infrastructure/
- **MVC**: models/, views/, controllers/
- **Layered**: api/, service/, data/
- **Microservices**: Multiple service directories
- **Monorepo**: packages/, apps/

**Component Identification:**
- Entry points (main.*, index.*, app.*)
- API routes/endpoints
- Database models
- Business logic services
- Utilities and helpers

**Output:**
- Annotated directory tree
- Architecture pattern classification
- Component inventory

### Step 4: Generate Analysis Report (10 minutes)

**Create 3 Documents:**

1. **project-overview.md**
   - Project name and description
   - Purpose and goals
   - Target users
   - Key features (high-level)

2. **tech-stack.md**
   - Languages and versions
   - Frameworks and libraries
   - Build tools
   - Infrastructure
   - Development tools

3. **architecture-summary.md**
   - Architecture pattern
   - Layer breakdown
   - Key components
   - Entry points
   - Data flow (high-level)

**Save to:** `./docs/analysis/`

## Validation Checklist

Before proceeding to Phase 2:

- [ ] README.md analyzed
- [ ] Tech stack completely identified
- [ ] Architecture pattern recognized
- [ ] All major components mapped
- [ ] Entry points documented
- [ ] Development workflow understood
- [ ] 3 analysis documents created

## Common Issues

**Issue**: Cannot determine tech stack
**Solution**: Check subdirectories, look for hidden config files

**Issue**: Unclear architecture
**Solution**: Focus on directory structure and file naming patterns

**Issue**: Multiple frameworks detected
**Solution**: Identify primary vs. secondary frameworks (e.g., main app vs. tooling)
