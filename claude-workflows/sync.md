# Settings Sync Workflow

This workflow synchronizes the `.claude` directory with its remote git repository.

## Trigger Commands
When the user says any of these phrases, execute this workflow:
- "sync my settings"
- "sync my claude settings"
- "sync settings"

## Overview
The `.claude` directory is a git repository that tracks workflow documentation, settings, and other Claude Code configuration files. This workflow keeps it in sync with the remote repository at: https://github.com/tdx-benheard/TDDev-Instruction-Docs.git

## Workflow Steps

### 1. Fetch and Pull Remote Updates
```bash
cd .claude && git fetch origin
```

Check status to see if remote has updates:
```bash
cd .claude && git status
```

If remote has updates, pull them:
```bash
cd .claude && git pull --rebase origin main
```
*Note: Adjust branch name if using `master` or another branch*

### 2. Review Local Changes
Check for uncommitted local changes (git automatically respects .gitignore):
```bash
cd .claude && git status
```

Show detailed changes:
```bash
cd .claude && git diff
```

### 3. Review Changes with User
- Show what files were modified (only files not in .gitignore will appear in `git status`)
- Display the diff of changes
- Ask user: "Do you want to commit these changes? If yes, please provide a commit message or I'll use: 'Update settings and workflow documentation'"

### 4. Commit Local Changes
After user approval, use `git add .` which automatically respects .gitignore:
```bash
cd .claude && git add . && git commit -m "<user-provided or default message>"
```

**IMPORTANT**: `git add .` automatically excludes files listed in `.gitignore`. Never use `git add -f` (force) unless explicitly requested by user.

### 5. Push to Remote
```bash
cd .claude && git push origin main
```

### 6. Confirm Sync Complete
Verify everything is up to date:
```bash
cd .claude && git status
```

## Error Handling

### Merge Conflicts
If conflicts occur during pull:
1. List conflicting files with `git status`
2. Ask user how to proceed (manual resolution, keep local, keep remote)
3. Don't proceed with commit/push until resolved

### Push Rejected (Diverged Branches)
If push fails due to diverged history:
1. Run `git pull --rebase origin main` first
2. Resolve any conflicts
3. Retry push

### No Changes Scenario
If no remote updates AND no local changes:
- Simply inform user: "Settings are already in sync with remote repository"

## Best Practices
- Always show changes before committing
- Use descriptive commit messages
- Don't force push unless explicitly requested by user
- Check branch name first (might be `main`, `master`, or other)
- Git automatically respects `.gitignore` - files listed there won't be added with `git add .`
- Never use `git add -f` (force) or manually add ignored files unless user explicitly requests it
