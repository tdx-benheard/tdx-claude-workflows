# Settings Sync Workflow

Sync `.claude` directory across TDDM/TDDev repos with remote.

**Trigger:** "sync settings", "sync"

**Locations:**
- TDDM: `/c/source/TDDM/enterprise/.claude`
- TDDev: `/c/source/TDDev/enterprise/.claude`
- Remote: https://github.com/tdx-benheard/TDDev-Instruction-Docs.git

---

## Workflow

### For Each Directory (Current Dir, Then Other Dir)

**1. Check for changes**
```bash
cd {DIR}/.claude && git status
```

**2. If changes exist:**
- Stage: `git add .`
- Show diff: `git diff --cached`
- **Ask for approval:** "Review these changes. Commit them?"
- If YES: Auto-generate commit message and commit
- If NO: Stop

**3. Pull and merge**
```bash
git pull origin master
```
- If conflicts: Show files, ask user to resolve, continue

**4. Push**
```bash
git push origin master
```

### Final Sync

**1. Pull in current dir again** (to get other dir's changes)
```bash
cd {CURRENT_DIR}/.claude && git pull origin master
```

**2. Verify both synced**
```bash
cd /c/source/TDDM/enterprise/.claude && git status
cd /c/source/TDDev/enterprise/.claude && git status
```
Both should show "up to date" with no uncommitted changes.

---

## Notes

- Auto-generate commit messages (don't ask user)
- Show diffs before committing (user reviews)
- Commit BEFORE pull (captures local changes first)
- If no changes in either location, inform user already in sync
