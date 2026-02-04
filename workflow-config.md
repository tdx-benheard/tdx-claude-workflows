# Workflow Configuration

```json
{
  "workflowsRoot": "~/.claude/claude-workflows",
  "msbuildPath": "C:/Program Files/Microsoft Visual Studio/2022/Professional/MSBuild/Current/Bin/MSBuild.exe"
}
```

**What this does:** Defines portable paths for workflows and build tools.

**Derived paths:**
- Workflow files: `${workflowsRoot}/workflows/`
- Prewarm script: `${workflowsRoot}/workflows/prewarm-auth.ps1`

**To customize:**
- Change `workflowsRoot` if you store workflows elsewhere (use `~/` for portability)
- Change `msbuildPath` if you have a different VS version or installation path

**Project-specific config** (project paths, usernames, etc.) goes in each project's `.claude/CLAUDE.local.md`, NOT here.
