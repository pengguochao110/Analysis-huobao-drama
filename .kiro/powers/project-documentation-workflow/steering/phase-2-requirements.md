# Phase 2: Requirements Extraction

Detailed workflow for extracting and documenting requirements using EARS format.

## Workflow Steps

### Step 1: Identify Core Features (15 minutes)

**Actions:**
1. Review Phase 1 analysis outputs
2. List API endpoints/routes
3. Examine database models
4. Check UI components (if applicable)
5. Review test files for feature hints

**Feature Identification:**
- Group related endpoints into features
- Map database models to features
- Identify user-facing functionality

**Output:**
- Feature inventory (10-20 features typical)
- Feature categorization (auth, user mgmt, etc.)

### Step 2: Extract Functional Requirements (30 minutes)

**For Each Feature:**

1. **Define What It Does**
   - Input: What data/actions trigger it
   - Processing: What happens
   - Output: What result is produced

2. **Write EARS Requirements**
   - Use appropriate EARS pattern
   - Assign unique ID (REQ-XXX-NNN)
   - Make it testable and measurable

**EARS Patterns:**

```markdown
# Pattern 1: Ubiquitous
REQ-SYS-001: The system SHALL encrypt all passwords using bcrypt with 12 rounds.

# Pattern 2: Event-Driven
REQ-AUTH-001: WHEN user submits login form, the system SHALL validate credentials within 2 seconds.

# Pattern 3: State-Driven
REQ-AUTH-002: WHILE user is authenticated, the system SHALL display user dashboard.

# Pattern 4: Optional Feature
REQ-AUTH-003: WHERE two-factor authentication is enabled, the system SHALL require OTP after password.

# Pattern 5: Error Handling
REQ-AUTH-004: IF login fails 5 times, THEN the system SHALL lock account for 30 minutes.
```

**Output:**
- Functional requirements document
- 20-50 requirements typical
- All in EARS format

### Step 3: Extract Non-Functional Requirements (20 minutes)

**Categories:**

1. **Performance**
   - Response times
   - Throughput
   - Resource usage

2. **Security**
   - Authentication methods
   - Encryption standards
   - Access control

3. **Availability**
   - Uptime requirements
   - RTO/RPO
   - Backup strategy

4. **Scalability**
   - Concurrent users
   - Data volume
   - Growth projections

5. **Maintainability**
   - Logging
   - Monitoring
   - Deployment process

**EARS Format for NFRs:**
```markdown
REQ-NF-001: The system SHALL respond to API requests within 200ms (p95).
REQ-NF-002: The system SHALL support 1000 concurrent users.
REQ-NF-003: The system SHALL maintain 99.9% uptime.
REQ-NF-004: The system SHALL encrypt data in transit using TLS 1.3.
```

**Output:**
- Non-functional requirements document
- 10-20 NFRs typical

### Step 4: Create User Stories (25 minutes)

**Format:**
```markdown
## US-001: User Login

**As a** registered user
**I want** to log in with my credentials
**So that** I can access my account

### Acceptance Criteria (EARS Format)

**AC-1: Successful Login**
WHEN user submits valid credentials,
the system SHALL authenticate user and redirect to dashboard within 2 seconds.

**AC-2: Invalid Credentials**
IF user submits invalid credentials,
THEN the system SHALL display error message and allow retry.

**AC-3: Account Lockout**
IF user fails login 5 consecutive times,
THEN the system SHALL lock account for 30 minutes.

### Priority: High
### Estimate: 5 Story Points
### Links: REQ-AUTH-001, REQ-AUTH-004
```

**Output:**
- User stories document
- 15-30 stories typical
- All with EARS acceptance criteria

### Step 5: Build Traceability Matrix (10 minutes)

**Create Matrix:**

| Requirement ID | User Story | Code Component | Test Case | Status |
|---------------|------------|----------------|-----------|--------|
| REQ-AUTH-001 | US-001 | AuthService.login() | test_login_success | ✅ |
| REQ-AUTH-002 | US-001 | AuthMiddleware | test_auth_required | ✅ |
| REQ-AUTH-004 | US-001 | AuthService.lockAccount() | test_account_lockout | ✅ |

**Output:**
- Traceability matrix document
- Links requirements to implementation

### Step 6: Generate Requirements Documents (10 minutes)

**Create 5 Documents:**

1. **SRS (Software Requirements Specification)**
   - Complete requirements overview
   - All functional and non-functional requirements
   - Glossary and references

2. **Functional Requirements**
   - Detailed functional requirements
   - Organized by feature/module
   - All in EARS format

3. **Non-Functional Requirements**
   - Performance, security, availability, etc.
   - Measurable criteria
   - Testing approach

4. **User Stories**
   - All user stories
   - Acceptance criteria in EARS format
   - Priority and estimates

5. **Traceability Matrix**
   - Requirements to code mapping
   - Test coverage tracking

**Save to:** `./docs/requirements/`

## Validation Checklist

Before proceeding to Phase 3:

- [ ] All features identified
- [ ] Functional requirements in EARS format
- [ ] Non-functional requirements documented
- [ ] User stories created with acceptance criteria
- [ ] Traceability matrix complete
- [ ] All requirements testable and measurable
- [ ] 5 requirements documents created

## EARS Format Reference

### Required Keywords
- **SHALL** or **MUST** (mandatory)
- Never use: should, may, could, might

### Patterns Summary

| Pattern | Template | Use Case |
|---------|----------|----------|
| Ubiquitous | The [system] SHALL [action] | Always applies |
| Event-Driven | WHEN [event], the [system] SHALL [action] | Triggered by event |
| State-Driven | WHILE [state], the [system] SHALL [action] | During specific state |
| Optional | WHERE [feature], the [system] SHALL [action] | Optional feature |
| Error | IF [error], THEN the [system] SHALL [response] | Error handling |

### Validation Rules

1. **One requirement per statement**
2. **Measurable and testable**
3. **No implementation details**
4. **Clear and unambiguous**
5. **Unique requirement ID**

## Common Issues

**Issue**: Requirements too vague
**Solution**: Add specific, measurable criteria (time, quantity, quality)

**Issue**: Too many requirements
**Solution**: Group related requirements, focus on core functionality first

**Issue**: Cannot determine requirements
**Solution**: Review test files, API documentation, user feedback
