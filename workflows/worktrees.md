# Git Worktrees

**Always create in `.claude/worktrees/`** (gitignored)

## Naming

**Directory names use branch suffix** (part after `feature/{USERNAME}/`)

- `{BRANCH_NAME}` = Full branch (e.g., `feature/bheard/28056844_Description`)
- `{branch-name}` = Suffix only (e.g., `28056844_Description`)

**Patterns:**
- Ticket work: `.claude/worktrees/{branch-name}`
- Cherry-pick: `.claude/worktrees/cherry-pick-{branch-name}`

---

## Create Worktrees

**Ticket work** (from develop):
```bash
git fetch origin develop
git worktree add .claude/worktrees/{branch-name} -b {BRANCH_NAME} origin/develop
cd .claude/worktrees/{branch-name}/enterprise
```

**Cherry-pick** (from release):
```bash
git fetch origin release/{RELEASE_VERSION}
git worktree add .claude/worktrees/cherry-pick-{branch-name} -b {BRANCH_NAME} origin/release/{RELEASE_VERSION}
cd .claude/worktrees/cherry-pick-{branch-name}/enterprise
```

---

## Cleanup

```bash
git worktree list                                      # List all
git worktree remove .claude/worktrees/{branch-name}    # Remove
git worktree prune                                     # Clean up deleted
git worktree remove --force .claude/worktrees/{name}   # Force remove
```

**Notes:**
- Each worktree is fully isolated
- Remove after PR merge
- Always navigate to `enterprise/` subdirectory after creating
