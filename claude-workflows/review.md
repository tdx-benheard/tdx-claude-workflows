# Code Review Workflow

**Triggers:** "review", "review code", "review my changes"

## Review Standards

Check for:
- **Errors** - Bugs, logic errors, runtime issues
- **Risks** - Security vulnerabilities, data loss, breaking changes
- **Redundancies** - Duplicate code, unnecessary repetition
- **Inefficiencies** - Performance issues, suboptimal algorithms
- **Readability** - Code clarity, maintainability

---

## Workflow

**1. Get modified files**
```bash
git status
git diff <files>
```

**2. Review for standards above**

**3. Check common issues**
- XSS vulnerabilities (innerHTML vs textContent)
- SQL injection (parameterization)
- Breaking changes (API models, shared libraries, DB schema)
- N+1 query problems
- Missing async/await on I/O operations
- Memory leaks (event listeners)

**4. Present results**
```
## Code Review Results

### ✅ Errors: [None OR list with file:line]
### 🔒 Risks: [None OR list with file:line]
### ♻️ Redundancies: [None OR list]
### ⚡ Inefficiencies: [None OR list]
### 📖 Readability: [Score/10 with suggestions]

### Overall: [✅ Ready | ⚠️ Needs attention | ❌ Must fix]
```

**5. Ask if user wants to address issues before committing**
