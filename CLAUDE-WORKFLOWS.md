# Workflows

**Index and trigger router** for Claude Code workflows. Check this file to see if a workflow applies.

**Configuration:**
- **Workflow variables:** See `workflow-config.md` for paths and environment settings
- **User config:** See `CLAUDE.local.md` for username, report IDs, release version, etc.

---

## ⚡ Triggers → Files

**Pattern:** When you see these phrases, read the corresponding workflow file FIRST.

| Trigger | File | Notes |
|---------|------|-------|
| build, compile, msbuild, grunt | [build.md](workflows/build.md) | **🔥 MANDATORY READ FIRST** |
| commit, "commit this" | [commit.md](workflows/commit.md) | Review offer, auto-chain to push/PR |
| "create pr", "make pr", pr | [pr.md](workflows/pr.md) | Pre-reqs check, Azure DevOps API |
| dev.azure.com URL, "azure devops", "pr link" | [azure-devops.md](workflows/azure-devops.md) | PAT auth, REST API access |
| review, "review code" | [review.md](workflows/review.md) | Security, performance, quality |
| "get ticket", "clauded ticket" | [ticket-workflow.md](workflows/ticket-workflow.md) | Full workflow: claim → fix → commit |
| "test in browser", login, screenshot | [webagent.md](workflows/webagent.md) | Auth, URLs, testing |
| "create branch", "new branch" | [branch.md](workflows/branch.md) | Naming conventions |
| "cherry-pick", "port to release" | [cherry-pick.md](workflows/cherry-pick.md) | Release workflow |
| "create worktree", "worktree add" | [worktrees.md](workflows/worktrees.md) | Naming and structure |
| "close ticket", "mark complete" | [closing-tickets.md](workflows/closing-tickets.md) | Parent/child handling |
| "create temp file", "test script" | [temp-files.md](workflows/temp-files.md) | Location and gitignore |
| "create track", "update track", "track" | [track.md](workflows/track.md) | Progress tracking docs (800 line max) |

---

## 📚 Reference Documentation

Non-workflow reference files for configuration and troubleshooting:

| File | Purpose |
|------|---------|
| [azure-devops.md](workflows/azure-devops.md) | Azure DevOps org settings, PAT config, API endpoints |
| [prewarm.md](workflows/prewarm.md) | Pre-warming documentation (referenced by build.md) |

---

## Variables

Placeholders in workflow files (values from `CLAUDE.local.md`):
- `{USERNAME}` - Developer username
- `{USER_UID}` - TDX user UID
- `{TICKET_ID}` - Ticket number
- `{RELEASE_VERSION}` - Release version (e.g., `12.1`)
- `{MSBUILD_PATH}` - Path to MSBuild.exe

## Rules

**Modifying workflow files:**
- Workflows are at user scope (`${WORKFLOWS_ROOT}` - see workflow-config.md)
- Changes apply to all projects immediately
- Commit and push changes as needed using git
- Update `workflow-config.md` if you change your workflows location

**Project-specific config:**
- Keep in each project's `.claude\CLAUDE.local.md`
- Examples: username, UIDs, report IDs, paths
- Not tracked in workflows git repo
