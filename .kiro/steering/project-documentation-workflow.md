---
inclusion: manual
description: Complete workflow orchestrating project analysis, requirements analysis, and documentation generation
keywords: project documentation, workflow, analysis pipeline, documentation workflow
---

# Project Documentation Workflow

Complete end-to-end workflow for analyzing projects, extracting requirements, and generating comprehensive documentation.

## Workflow Overview

This workflow orchestrates three specialized skills:
1. **Analyzing Projects** - Understand codebase structure and architecture
2. **Requirements Analyst** - Extract and document requirements using EARS format
3. **Smart Docs** - Generate comprehensive technical documentation with C4 diagrams

## When to Use This Workflow

Use this workflow when:
- Onboarding to an existing project without documentation
- Reverse-engineering requirements from existing code
- Creating comprehensive documentation for legacy systems
- Preparing handover documentation
- Conducting technical due diligence
- Planning major refactoring or migration

## Complete Workflow Phases

```
┌─────────────────────────────────────────────────────────────┐
│                    PHASE 1: PROJECT ANALYSIS                 │
│  Goal: Understand what exists (codebase, architecture)      │
│  Output: Project analysis report                            │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                 PHASE 2: REQUIREMENTS EXTRACTION             │
│  Goal: Document what the system does (requirements)         │
│  Output: Requirements documents (SRS, functional, etc.)     │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                 PHASE 3: DOCUMENTATION GENERATION            │
│  Goal: Create comprehensive technical documentation         │
│  Output: Architecture docs with C4 diagrams                 │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                 PHASE 4: DOCUMENTATION ORGANIZATION          │
│  Goal: Organize all documents in standard structure         │
│  Output: Complete documentation repository                  │
└─────────────────────────────────────────────────────────────┘
```

---

## Phase 1: Project Analysis (Analyzing Projects)

**Objective**: Understand the existing codebase, technology stack, and architecture patterns.

### Step 1.1: Quick Overview
```bash
# Activate analyzing-projects knowledge
# (Already active if inclusion: always)

# Tasks:
- Read README.md
- List root directory structure
- Identify project type
```

**Deliverable**: Initial project understanding

### Step 1.2: Tech Stack Detection
```bash
# Tasks:
- Identify package managers (package.json, go.mod, etc.)
- List frameworks and libraries
- Check infrastructure files (Docker, K8s, etc.)
```

**Deliverable**: Technology stack inventory

### Step 1.3: Architecture Mapping
```bash
# Tasks:
- Map directory structure
- Identify architectural patterns (DDD, MVC, etc.)
- Document key components
- Identify entry points
```

**Deliverable**: Architecture overview

### Step 1.4: Generate Analysis Report
```bash
# Output location: ./analysis-docs/01-project-analysis/
# Files to create:
- project-overview.md
- tech-stack.md
- architecture-summary.md
```

**Checkpoint**: Review analysis report before proceeding to Phase 2

---

## Phase 2: Requirements Extraction (Requirements Analyst)

**Objective**: Reverse-engineer requirements from the existing codebase.

### Step 2.1: Identify Core Features
```bash
# Reference analyzing-projects knowledge
# Activate requirements-analyst knowledge

# Tasks:
- List main features from code analysis
- Identify user-facing functionality
- Document API endpoints/routes
- Map database models to features
```

**Deliverable**: Feature inventory

### Step 2.2: Extract Functional Requirements
```bash
# For each feature identified:
# Tasks:
- Define what the feature does
- Identify inputs, processing, outputs
- Write acceptance criteria in EARS format
- Assign requirement IDs (REQ-XXX)
```

**Example**:
```markdown
REQ-AUTH-001: WHEN user submits valid credentials, 
              the system SHALL authenticate and create session within 2 seconds.
```

**Deliverable**: Functional requirements document

### Step 2.3: Extract Non-Functional Requirements
```bash
# Tasks:
- Document performance characteristics
- Identify security measures
- Note scalability patterns
- Document availability requirements
```

**Deliverable**: Non-functional requirements document

### Step 2.4: Create User Stories
```bash
# Tasks:
- Convert features to user stories
- Format: As a [user], I want [action], So that [goal]
- Add acceptance criteria in EARS format
- Link to functional requirements
```

**Deliverable**: User stories document

### Step 2.5: Build Traceability Matrix
```bash
# Tasks:
- Map requirements to code components
- Link user stories to requirements
- Document dependencies
```

**Deliverable**: Traceability matrix

### Step 2.6: Generate Requirements Documents
```bash
# Output location: ./docs/requirements/
# Files to create:
- srs/srs-[project-name]-v1.0.md
- functional/functional-requirements-[date].md
- non-functional/non-functional-requirements-[date].md
- user-stories/user-stories-[date].md
- traceability-matrix-[date].md
```

**Checkpoint**: Review requirements documents before proceeding to Phase 3

---

## Phase 3: Documentation Generation (Smart Docs)

**Objective**: Create comprehensive technical documentation with C4 model diagrams.

### Step 3.1: Project Overview Document
```bash
# Reference analyzing-projects and requirements-analyst outputs
# Activate smart-docs knowledge

# Output: ./docs/1. Project Overview.md
# Content:
- What is [Project Name]?
- Core Purpose (from requirements)
- Technology Stack (from analysis)
- Key Features (from requirements)
- Project Structure (from analysis)
- Getting Started
```

**Deliverable**: Project Overview document

### Step 3.2: Architecture Overview Document
```bash
# Output: ./docs/2. Architecture Overview.md
# Content:
- System Context (C4 Level 1) - Mermaid diagram
- Container Architecture (C4 Level 2) - Mermaid diagram
- Component Architecture (C4 Level 3) - Mermaid diagram
- Architectural Patterns (from analysis)
- Key Design Decisions
- Module Breakdown
```

**Deliverable**: Architecture Overview with C4 diagrams

### Step 3.3: Workflow Overview Document
```bash
# Output: ./docs/3. Workflow Overview.md
# Content:
- Core Workflows (from requirements)
- Sequence diagrams (Mermaid)
- Data Flow diagrams (Mermaid)
- State Management
- Error Handling
```

**Deliverable**: Workflow Overview with diagrams

### Step 3.4: Deep Dive Component Documents
```bash
# Output: ./docs/4. Deep Dive/
# For each major component:
# Files to create:
- [Component-Name].md

# Content per component:
- Overview
- Responsibilities
- Architecture (class diagrams)
- Key Files
- Implementation Details
- Dependencies
- API/Interface
- Testing
```

**Deliverable**: Component deep-dive documents

**Checkpoint**: Review all documentation before proceeding to Phase 4

---

## Phase 4: Documentation Organization

**Objective**: Organize all generated documents into a standardized structure.

### Step 4.1: Create Standard Directory Structure
```bash
# Create the following structure:
project-root/
├── docs/
│   ├── 1. Project Overview.md
│   ├── 2. Architecture Overview.md
│   ├── 3. Workflow Overview.md
│   ├── 4. Deep Dive/
│   │   ├── [Component-1].md
│   │   ├── [Component-2].md
│   │   └── [Component-N].md
│   ├── requirements/
│   │   ├── srs/
│   │   │   └── srs-[project]-v1.0.md
│   │   ├── functional/
│   │   │   └── functional-requirements-[date].md
│   │   ├── non-functional/
│   │   │   └── non-functional-requirements-[date].md
│   │   ├── user-stories/
│   │   │   └── user-stories-[date].md
│   │   └── traceability-matrix-[date].md
│   └── analysis/
│       ├── project-overview.md
│       ├── tech-stack.md
│       └── architecture-summary.md
└── README.md (updated with links to docs)
```

### Step 4.2: Create Documentation Index
```bash
# Output: ./docs/README.md
# Content:
- Documentation overview
- Links to all major documents
- Quick navigation guide
- Document update history
```

### Step 4.3: Update Project README
```bash
# Update: ./README.md
# Add sections:
- Link to documentation
- Quick start guide
- Architecture summary
- Contributing guidelines
```

### Step 4.4: Create Documentation Maintenance Guide
```bash
# Output: ./docs/MAINTENANCE.md
# Content:
- How to update documentation
- Documentation standards
- Review process
- Version control for docs
```

**Final Deliverable**: Complete, organized documentation repository

---

## Execution Commands

### Full Workflow Execution

```bash
# Step 1: Activate workflow
"Execute the complete project documentation workflow for [project-name]"

# Or step-by-step:
"Phase 1: Analyze the project structure and architecture"
"Phase 2: Extract and document requirements from the codebase"
"Phase 3: Generate comprehensive technical documentation"
"Phase 4: Organize all documentation"
```

### Individual Phase Execution

```bash
# Phase 1 only
"Analyze this project using the analyzing-projects workflow"

# Phase 2 only
"Extract requirements from the codebase using EARS format"

# Phase 3 only
"Generate technical documentation with C4 diagrams"

# Phase 4 only
"Organize the documentation into standard structure"
```

---

## Quality Checklist

### Phase 1 Completion Checklist
- [ ] README.md analyzed
- [ ] Tech stack identified and documented
- [ ] Architecture patterns recognized
- [ ] Key components mapped
- [ ] Entry points documented
- [ ] Development workflow understood

### Phase 2 Completion Checklist
- [ ] All features identified
- [ ] Functional requirements documented in EARS format
- [ ] Non-functional requirements documented
- [ ] User stories created
- [ ] Traceability matrix complete
- [ ] Requirements validated for completeness

### Phase 3 Completion Checklist
- [ ] Project overview document created
- [ ] C4 Level 1 diagram (System Context)
- [ ] C4 Level 2 diagram (Containers)
- [ ] C4 Level 3 diagram (Components)
- [ ] Workflow sequence diagrams
- [ ] Component deep-dive documents
- [ ] All Mermaid diagrams validated

### Phase 4 Completion Checklist
- [ ] Standard directory structure created
- [ ] All documents organized
- [ ] Documentation index created
- [ ] Project README updated
- [ ] Maintenance guide created
- [ ] All links verified

---

## Output Directory Structure

```
project-root/
├── docs/
│   ├── README.md                          # Documentation index
│   ├── MAINTENANCE.md                     # Maintenance guide
│   │
│   ├── 1. Project Overview.md             # Phase 3 output
│   ├── 2. Architecture Overview.md        # Phase 3 output
│   ├── 3. Workflow Overview.md            # Phase 3 output
│   │
│   ├── 4. Deep Dive/                      # Phase 3 output
│   │   ├── Backend-Services.md
│   │   ├── Frontend-Components.md
│   │   ├── Database-Layer.md
│   │   └── API-Layer.md
│   │
│   ├── requirements/                      # Phase 2 output
│   │   ├── srs/
│   │   │   └── srs-project-v1.0.md
│   │   ├── functional/
│   │   │   └── functional-requirements-20260204.md
│   │   ├── non-functional/
│   │   │   └── non-functional-requirements-20260204.md
│   │   ├── user-stories/
│   │   │   └── user-stories-20260204.md
│   │   └── traceability-matrix-20260204.md
│   │
│   └── analysis/                          # Phase 1 output
│       ├── project-overview.md
│       ├── tech-stack.md
│       └── architecture-summary.md
│
└── README.md                              # Updated with doc links
```

---

## Best Practices

### During Execution

1. **Work Incrementally**: Complete each phase before moving to the next
2. **Validate Outputs**: Review each phase's deliverables with stakeholders
3. **Maintain Consistency**: Use consistent terminology across all documents
4. **Cross-Reference**: Link related documents together
5. **Version Control**: Commit after each phase completion

### Documentation Standards

1. **Use Markdown**: All documents in Markdown format
2. **EARS Format**: All requirements in EARS format
3. **Mermaid Diagrams**: All diagrams in Mermaid syntax
4. **Clear Headings**: Use hierarchical heading structure
5. **Code Examples**: Include code blocks with language tags

### Maintenance

1. **Keep Updated**: Update docs when code changes
2. **Review Regularly**: Quarterly documentation review
3. **Track Changes**: Document update history
4. **Validate Links**: Check all internal links periodically

---

## Troubleshooting

### Issue: Phase 1 - Cannot identify tech stack
**Solution**: 
- Check for hidden config files (.env, .config/)
- Look in subdirectories
- Search for import/require statements

### Issue: Phase 2 - Unclear requirements
**Solution**:
- Review code comments and docstrings
- Check test files for expected behavior
- Interview developers if available

### Issue: Phase 3 - Diagrams too complex
**Solution**:
- Break into multiple diagrams
- Focus on one subsystem at a time
- Use abstraction layers

### Issue: Phase 4 - Too many documents
**Solution**:
- Consolidate related documents
- Create summary documents
- Use clear navigation structure

---

## Example Usage

### Full Workflow Example

```
User: "Execute the complete project documentation workflow for huobao-drama"

Agent Response:
"Starting complete documentation workflow for huobao-drama...

Phase 1: Project Analysis
✓ Analyzed README.md
✓ Identified tech stack: Go 1.23 + Vue 3.4
✓ Mapped DDD architecture
✓ Generated analysis reports in ./docs/analysis/

Phase 2: Requirements Extraction
✓ Extracted 15 functional requirements
✓ Documented 8 non-functional requirements
✓ Created 23 user stories
✓ Generated requirements documents in ./docs/requirements/

Phase 3: Documentation Generation
✓ Created Project Overview
✓ Generated C4 diagrams (3 levels)
✓ Created workflow sequence diagrams
✓ Generated 5 component deep-dive documents
✓ Saved documentation in ./docs/

Phase 4: Documentation Organization
✓ Created standard directory structure
✓ Generated documentation index
✓ Updated project README
✓ Created maintenance guide

✅ Complete documentation workflow finished!
📁 All documents available in ./docs/
"
```

---

## Summary

This workflow provides a systematic approach to:
1. **Understand** existing codebases (Analyzing Projects)
2. **Document** what they do (Requirements Analyst)
3. **Explain** how they work (Smart Docs)
4. **Organize** everything properly (Documentation Organization)

**Total Time Estimate**: 2-4 hours for medium-sized projects

**Key Benefits**:
- Comprehensive documentation from existing code
- Standardized format across all documents
- EARS-compliant requirements
- C4 model architecture diagrams
- Organized, maintainable documentation repository

---

**To execute this workflow, simply say:**
```
"Run the project documentation workflow for [project-name]"
```

Or reference this file:
```
#.kiro/steering/project-documentation-workflow.md

Execute the workflow for [project-name]
```
