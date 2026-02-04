# Project Documentation Workflow Power

Complete end-to-end workflow for analyzing projects, extracting requirements, and generating comprehensive documentation.

## Installation

### Option 1: Local Project Installation
```bash
# Copy this power to your project
cp -r .kiro/powers/project-documentation-workflow /path/to/your/project/.kiro/powers/
```

### Option 2: Global Installation
```bash
# Copy this power to your user directory
cp -r .kiro/powers/project-documentation-workflow ~/.kiro/powers/
```

### Option 3: Via Kiro Powers UI
1. Open Kiro IDE
2. Open Powers panel (sidebar)
3. Click "Install from local"
4. Select this directory

## Quick Start

### Full Workflow
```
Execute the complete project documentation workflow for [project-name]
```

### Step-by-Step
```
Phase 1: Analyze the [project-name] project
Phase 2: Extract requirements from [project-name]
Phase 3: Generate documentation for [project-name]
Phase 4: Organize documentation for [project-name]
```

## What This Power Does

### Phase 1: Project Analysis (15-30 min)
- Analyzes codebase structure
- Identifies technology stack
- Maps architecture patterns
- **Output**: 3 analysis reports

### Phase 2: Requirements Extraction (30-60 min)
- Extracts functional requirements (EARS format)
- Documents non-functional requirements
- Creates user stories
- Builds traceability matrix
- **Output**: 5 requirements documents

### Phase 3: Documentation Generation (45-90 min)
- Creates project overview
- Generates C4 architecture diagrams (3 levels)
- Documents workflows with sequence diagrams
- Creates component deep-dives
- **Output**: 5-10 technical documents

### Phase 4: Documentation Organization (10-15 min)
- Organizes all documents
- Creates documentation index
- Updates project README
- **Output**: Complete documentation repository

## Output Structure

```
project-root/
├── docs/
│   ├── README.md                          # Documentation index
│   ├── MAINTENANCE.md                     # Maintenance guide
│   ├── 1. Project Overview.md
│   ├── 2. Architecture Overview.md
│   ├── 3. Workflow Overview.md
│   ├── 4. Deep Dive/
│   │   └── [Component files]
│   ├── requirements/
│   │   ├── srs/
│   │   ├── functional/
│   │   ├── non-functional/
│   │   ├── user-stories/
│   │   └── traceability-matrix.md
│   └── analysis/
│       ├── project-overview.md
│       ├── tech-stack.md
│       └── architecture-summary.md
└── README.md (updated)
```

## Features

- ✅ **EARS Format**: All requirements in testable, unambiguous format
- ✅ **C4 Diagrams**: Industry-standard architecture visualization
- ✅ **Mermaid Syntax**: All diagrams in Mermaid format
- ✅ **Traceability**: Requirements mapped to code
- ✅ **Standardized**: Consistent structure across projects
- ✅ **Maintainable**: Easy to update and extend

## Requirements

- Kiro IDE installed
- Access to project codebase
- 2-4 hours for full workflow

## Troubleshooting

### Power Not Activating
- Check power is in `.kiro/powers/` or `~/.kiro/powers/`
- Restart Kiro IDE
- Try explicit activation: "Use project-documentation-workflow power"

### Missing Dependencies
- Ensure all steering files are present
- Check POWER.md has correct frontmatter

### Diagrams Not Rendering
- Validate Mermaid syntax at mermaid.live
- Check for typos in diagram code

## Support

For issues or questions:
- Check POWER.md for detailed instructions
- Review steering files for phase-specific guidance
- Consult Kiro documentation

## License

MIT License - Free to use and modify

## Version

1.0.0 - Initial release
