# Settings Sync Workflow

Sync `.claude` directory across two repo clones with the remote.

## Trigger: "sync my settings", "sync settings"

## Locations
- **TDDM:** `/c/source/TDDM/enterprise/.claude`
- **TDDev:** `/c/source/TDDev/enterprise/.claude`
- **Remote:** https://github.com/tdx-benheard/TDDev-Instruction-Docs.git

## Workflow

### 1. Pull in Both Locations
```bash
cd /c/source/TDDM/enterprise/.claude && git pull origin master
cd /c/source/TDDev/enterprise/.claude && git pull origin master
```

### 2. Check for Local Changes
```bash
cd /c/source/TDDM/enterprise/.claude && git status
cd /c/source/TDDev/enterprise/.claude && git status
```

### 3. Commit & Push (if changes exist)
Generate a descriptive commit message based on the changes, then for each location with changes:
```bash
git add . && git commit -m "<message>" && git push origin master
```
**DO NOT ask user for commit message - always generate an appropriate message automatically.**

### 4. Final Pull (Both Locations)
```bash
cd /c/source/TDDM/enterprise/.claude && git pull origin master
cd /c/source/TDDev/enterprise/.claude && git pull origin master
```

### 5. Verify
Both should show "up to date" with no uncommitted changes.

## Error Handling
- **Merge conflicts**: Show files, ask user how to resolve before continuing
- **Push rejected**: Run `git pull --rebase origin main`, resolve conflicts, retry
- **No changes**: Inform user settings are already in sync
