# Temporary Files

## Purpose

Use the `.claude/temp/` directory for:
- Test files
- Bug reproduction steps
- Manual testing procedures
- Debugging notes
- Other temporary documentation

## Location

**Directory:** `.claude/temp/` (create if it doesn't exist)

## Naming Convention

```
[Item ID (if exists)]_Description of file contents
```

**Examples:**
- `555661_Leave-Dialog-Double-Click-Bug.md` - Bug reproduction for ticket #555661
- `Test-API-Endpoint.md` - Generic test procedure (no item ID)
- `550123_Manual-Test-Steps.md` - Test steps for ticket #550123

**Rules:**
- Include item ID (ticket/bug number) if associated with a specific item
- Use descriptive names that clearly indicate file contents
- Use hyphens for spaces in description
- Use `.md` extension for markdown files

## When to Create Temp Files

Create temp files when you need to:
1. Document bug reproduction steps for future debugging
2. Save manual testing procedures for verification
3. Store temporary notes or research
4. Create test data or scenarios

## Cleanup

Temp files can be deleted when:
- The associated bug is fixed and verified
- The test is no longer needed
- The documentation has been moved to a permanent location
