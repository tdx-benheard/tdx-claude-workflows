# Workflow Configuration

```json
{
  "workflowsRoot": "~/.claude/claude-workflows",
  "msbuildPath": "C:/Program Files/Microsoft Visual Studio/2022/Professional/MSBuild/Current/Bin/MSBuild.exe",
  "azureDevOpsConfig": "~/.claude/azure-devops.json",
  "webCredentials": "~/.config/tdx-mcp/dev-credentials.json"
}
```

**Variables:** Use `${variableName}` in workflow files (e.g., `${workflowsRoot}`, `${msbuildPath}`).

**To customize:** Edit values above for your environment. Use `~/` for portability.

**Project-specific config** (usernames, report IDs, etc.) goes in each project's `.claude/CLAUDE.local.md`.
