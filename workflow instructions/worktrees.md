# Git Worktrees Instructions

## Overview
Git worktrees allow you to work on multiple branches simultaneously in separate working directories. This is particularly useful when working on tickets to avoid context switching and potential conflicts.

## Worktree Location
**IMPORTANT**: All worktrees should be created in `.claude/worktrees/` directory.

## Creating a Worktree

### Standard Worktree Creation
```bash
# Create worktree from develop branch
git fetch origin develop
git worktree add .claude/worktrees/[TicketId] -b [BranchName] origin/develop
```

### Example
```bash
# For ticket 28056844 with branch feature/bheard/28056844_ReportSaveNavigatorScroll
git fetch origin develop
git worktree add .claude/worktrees/28056844 -b feature/bheard/28056844_ReportSaveNavigatorScroll origin/develop
```

## Navigating to Worktree

After creating a worktree, navigate to it:

**Windows PowerShell:**
```powershell
cd .claude\worktrees\[TicketId]\enterprise
```

**Git Bash (Unix-style paths):**
```bash
cd .claude/worktrees/[TicketId]/enterprise
```

## Working in a Worktree

Once in the worktree:
- All git operations work normally
- Changes are isolated from your main working directory
- You can build, test, and commit independently
- File paths will be: `C:\source\TDDev\enterprise\.claude\worktrees\[TicketId]\enterprise\...`

## Listing Worktrees

To see all active worktrees:
```bash
git worktree list
```

## Removing a Worktree

When done with a ticket (after PR is merged):

```bash
# Remove the worktree
git worktree remove .claude/worktrees/[TicketId]

# Or use prune to clean up if directory was manually deleted
git worktree prune
```

## Important Notes

1. **Location**: Always create worktrees in `.claude/worktrees/[TicketId]` - they are gitignored
2. **Branch naming**: Follow the branch naming conventions in [branches.md](branches.md)
3. **Ticket workflow**: Worktree creation is part of the [ticket-workflow.md](ticket-workflow.md)
4. **Cleanup**: Remove worktrees after PR is merged to avoid clutter
5. **Isolation**: Each worktree is completely independent - changes in one don't affect others

## Troubleshooting

### Worktree already exists
```bash
# If worktree directory exists but git doesn't recognize it
git worktree prune
# Then recreate the worktree
```

### Cannot remove worktree
```bash
# Force remove if needed
git worktree remove --force .claude/worktrees/[TicketId]
```

### Branch already checked out
```bash
# If branch exists in another worktree, checkout fails
# Either remove the other worktree or use a different branch name
git worktree list  # Find where branch is checked out
```

---

## See Also

- **[branches.md](branches.md)** - Branch naming conventions used when creating worktrees
