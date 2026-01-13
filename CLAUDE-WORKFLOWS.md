# Workflows

**Index and trigger router** for Claude Code workflows. Check this file to see if a workflow applies.

**User config:** See `CLAUDE.local.md` for username, report IDs, release version, etc.

---

## ⚡ Triggers → Files

**Pattern:** When you see these phrases, read the corresponding workflow file FIRST.

| Trigger | File | Notes |
|---------|------|-------|
| build, compile, msbuild, grunt | [build.md](claude-workflows/build.md) | **🔥 MANDATORY READ FIRST** |
| commit, "commit this" | [commit.md](claude-workflows/commit.md) | Review offer, auto-chain to push/PR |
| "create pr", "make pr", pr | [pr.md](claude-workflows/pr.md) | Pre-reqs check, Azure DevOps API |
| review, "review code" | [review.md](claude-workflows/review.md) | Security, performance, quality |
| "get ticket", "clauded ticket" | [ticket-workflow.md](claude-workflows/ticket-workflow.md) | Full workflow: claim → fix → commit |
| "test in browser", login, screenshot | [webagent.md](claude-workflows/webagent.md) | Auth, URLs, testing |
| "create branch", "new branch" | [branch.md](claude-workflows/branch.md) | Naming conventions |
| "cherry-pick", "port to release" | [cherry-pick.md](claude-workflows/cherry-pick.md) | Release workflow |
| "create worktree", "worktree add" | [worktrees.md](claude-workflows/worktrees.md) | Naming and structure |
| "close ticket", "mark complete" | [closing-tickets.md](claude-workflows/closing-tickets.md) | Parent/child handling |
| "sync settings", "sync .claude" | [sync.md](claude-workflows/sync.md) | TDDM ↔ TDDev sync |
| "create temp file", "test script" | [temp-files.md](claude-workflows/temp-files.md) | Location and gitignore |
| "create track", "update track", "track" | [track.md](claude-workflows/track.md) | Progress tracking docs (800 line max) |

---

## 📚 Reference Documentation

Non-workflow reference files for configuration and troubleshooting:

| File | Purpose |
|------|---------|
| [azure-devops.md](claude-workflows/azure-devops.md) | Azure DevOps org settings, PAT config, API endpoints |
| [prewarm.md](claude-workflows/prewarm.md) | Pre-warming documentation (referenced by build.md) |

---

## Variables

Placeholders in workflow files (values from `CLAUDE.local.md`):
- `{USERNAME}` - Developer username
- `{USER_UID}` - TDX user UID
- `{TICKET_ID}` - Ticket number
- `{RELEASE_VERSION}` - Release version (e.g., `12.1`)
- `{MSBUILD_PATH}` - Path to MSBuild.exe

## Rules

**Modifying .claude files:**
1. Run sync workflow to pull latest
2. Make changes
3. Run sync workflow to commit and push

**Git repository:**
- `.claude/` has its own separate git repo (gitignored from main repo)
- If staged accidentally: `git reset .claude/`

**After updating workflows:** Run sync workflow to push changes (see [sync.md](claude-workflows/sync.md))
