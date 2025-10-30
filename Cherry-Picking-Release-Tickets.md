# Cherry Picking a Release Ticket

Guide for cherry-picking commits from a feature branch to a release branch.

## Process Overview

1. Find the feature branch
2. Identify commits (already merged to develop)
3. Create worktree for release branch
4. Cherry-pick commits
5. Push branch
6. Create PR description

---

## Step 1: Find the Feature Branch

```bash
git branch -a | grep "[ticket-number]"
```

---

## Step 2: Identify Commits

**Goal:** Find commits already merged into develop to cherry-pick to release.

**Verify merged** (should return empty):
```bash
git log --format="%ai | %h | %s" --no-merges origin/develop..origin/feature/{developer}/{branch-name} | sort
```

**List all feature commits**:
```bash
git log --format="%ai | %h | %s" --no-merges origin/feature/{developer}/{branch-name} | head -20
```

Identify actual feature commits (ignore "Merge branch 'develop'" commits). These hashes are what you'll cherry-pick.

**Important:** If feature branch doesn't exist (deleted), you cannot proceed.

---

## Step 3: Create Worktree

**Naming:**
- Branch: `feature/{developer}/{cherry-picked-branch-name}_{version}`
- Folder: `../cp-[ticket-number]-[version]`
- Remove special characters like `#` from branch name

```bash
# IMPORTANT: Release branches use format origin/release/12.0 (with slash)
git worktree add ../cp-[ticket-number]-12.0 -b feature/{developer}/{cherry-picked-branch-name}_12.0 origin/release/12.0
git worktree add ../cp-[ticket-number]-12.1 -b feature/{developer}/{cherry-picked-branch-name}_12.1 origin/release/12.1
```

---

## Step 4: Cherry-Pick Commits

```bash
cd ../cp-[ticket-number]-[version]
git cherry-pick [commit-hash]
```

### If there's a conflict:

1. Document conflict (file path, type, description)
2. Resolve (check with user if unsure):
   ```bash
   git checkout --theirs <file>  # Accept incoming changes
   git checkout --ours <file>    # Keep release version
   ```
3. Continue:
   ```bash
   git add <resolved-files>
   git cherry-pick --continue
   ```

### Modify/Delete Conflicts
```bash
git rm path/to/missing-file  # Remove if file doesn't exist in release
git cherry-pick --continue
```

### Empty Commits
```bash
git cherry-pick --skip  # Skip and document in PR description
```

---

## Step 5: Push Branch

```bash
git push -u origin feature/{developer}/{cherry-picked-branch-name}_{version}
```

---

## Step 6: Create PR Description

Save in `.claude/PR_Message-[branch-name].txt`:

```
[Ticket Type] [Ticket ID] - [Ticket Title]

Cherry pick commits for Ticket #XXXXX to merge with [Release Version].

[commit-hash] - [commit message]

Merge conflicts:
[File] - [resolution explanation]

Skipped commits:
[commit-hash] - [message] - Reason: [why]
```

---

## Quick Reference

```bash
# Find & verify
git branch -a | grep "[ticket-number]"
git log --format="%ai | %h | %s" --no-merges origin/develop..origin/feature/{developer}/{branch-name} | sort
git log --format="%ai | %h | %s" --no-merges origin/feature/{developer}/{branch-name} | head -20

# Create worktree (note: origin/release/12.0 with slash)
git worktree add ../cp-[ticket-number]-[version] -b feature/{developer}/{cherry-picked-branch-name}_{version} origin/release/[version]

# Cherry-pick
cd ../cp-[ticket-number]-[version]
git cherry-pick [commit-hash]
git cherry-pick --continue  # After resolving
git cherry-pick --skip      # Skip empty

# Push
git push -u origin feature/{developer}/{cherry-picked-branch-name}_{version}

# Cleanup
git worktree remove ../cp-[ticket-number]-[version]
```
