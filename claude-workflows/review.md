# Code Review Workflow

## Trigger Commands
- "review the code"
- "review my changes"
- "do a code review"
- "review all pending changes"

## Review Standards
Always review for:
- **Errors** - Bugs, logic errors, runtime issues
- **Risks** - Security vulnerabilities, data loss potential, breaking changes
- **Redundancies** - Duplicate code, unnecessary repetition
- **Inefficiencies** - Performance issues, suboptimal algorithms, resource waste
- **Readability** - Code clarity, maintainability, documentation quality

## Workflow

1. **Get modified files:**
   ```bash
   git status
   git diff <files>
   ```

2. **Review each file** for the four categories above

3. **Check for common issues:**
   - XSS vulnerabilities (innerHTML vs textContent)
   - SQL injection (parameterization)
   - Breaking changes (API models, shared libraries, database schema)
   - N+1 query problems
   - Missing async/await on I/O operations
   - Memory leaks (event listeners)

4. **Present results:**
   ```
   ## Code Review Results

   ### ✅ Errors: [None found OR list with file:line]
   ### 🔒 Risks: [None found OR list with file:line]
   ### ♻️ Redundancies: [None found OR list]
   ### ⚡ Inefficiencies: [None found OR list]
   ### 📖 Readability: [Score/10 with suggestions for improvement]

   ### Overall: [✅ Ready | ⚠️ Needs attention | ❌ Must fix]
   ```

5. **Ask user** if they want to address issues before committing
