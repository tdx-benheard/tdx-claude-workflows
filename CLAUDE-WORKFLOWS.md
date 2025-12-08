# Workflows

## What is this?

This file is an **index of workflow instructions for Claude Code** (the AI assistant). It is NOT intended for human developers to read directly.

**Usage:**
- Copy this file and the `claude-workflows/` directory to your `.claude/` folder
- Reference it in your `.claude/CLAUDE.local.md` with: `See CLAUDE-WORKFLOWS.md for workflow instructions`
- Claude Code will follow these workflows when you work with tickets, commits, branches, etc.

**User-specific configuration:** See `CLAUDE.local.md` for your username, report IDs, release version, etc.

---

## Workflow Files

- **[ticket-workflow.md](claude-workflows/ticket-workflow.md)** - Ticket handling (MCP required)
- **[closing-tickets.md](claude-workflows/closing-tickets.md)** - Closing tickets and children (MCP required)
- **[commit.md](claude-workflows/commit.md)** - Commit format/standards
- **[branch.md](claude-workflows/branch.md)** - Branch naming conventions
- **[worktrees.md](claude-workflows/worktrees.md)** - Worktree management
- **[build.md](claude-workflows/build.md)** - Build commands (**overrides base CLAUDE.md**)
- **[cherry-pick.md](claude-workflows/cherry-pick.md)** - Release cherry-picking
- **[review.md](claude-workflows/review.md)** - Code review standards and workflow
- **[sync-settings.md](claude-workflows/sync-settings.md)** - Sync .claude directory with remote git repository

## Variables Used

**How variables work:** When you see `{USERNAME}` in workflow files, that's a placeholder that I (Claude Code) will replace with the actual value from your `CLAUDE.local.md` when executing workflows. You don't type the curly braces literally.

Generic placeholders (user-specific values defined in `CLAUDE.local.md`):
- `{USERNAME}` - Developer username
- `{USER_UID}` - TeamDynamix user UID
- `{TICKET_ID}` - Ticket number
- `{TAG_NAME}` - Tag to apply when claiming tickets (optional, user-defined)
- `{RELEASE_VERSION}` - Release version (e.g., `12.1`)
- `{MSBUILD_PATH}` - Path to MSBuild.exe

---

## Quick Reference

### Modifying .claude Files
**⚠️ CRITICAL:** Before making ANY changes to files in the `.claude/` directory:
1. **First sync** - Run the sync workflow (see [sync-settings.md](claude-workflows/sync-settings.md)) to pull latest changes
2. **Make your changes** - Edit the files as needed
3. **Commit and push** - Run sync workflow again to commit and push your changes

This prevents merge conflicts and ensures all changes are tracked in the remote repository.

### Git Repository Rules
- `.claude/` is gitignored from the main repo - **NEVER commit to main repo**
- The `.claude/` directory has its **own separate git repository** for syncing settings
- If staged accidentally in main repo: `git reset .claude/`

### PowerShell Commands
- **Prefer**: Script files (`powershell -File temp.ps1`)
- **Best**: Use MCP servers (`mcp__*` tools) when available
