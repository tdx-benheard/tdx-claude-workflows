# Cherry Picking a Release Ticket

Guide for cherry-picking commits from a feature branch to release/12.1.

## Process Overview

1. Find the feature branch
2. Identify commits (already merged to develop)
3. **Confirm commits with user**
4. **Ask user: Use worktree (separate directory) or checkout directly (current directory)?**
5. Create and checkout branch (via worktree or direct checkout)
6. Cherry-pick commits
7. Push branch
8. Create PR description

---

## Step 1: Find the Feature Branch

```bash
git branch -a | grep "[ticket-number]"
```

---

## Step 2: Identify Commits

**Goal:** Find commits already merged into develop to cherry-pick to release/12.1.

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

## Step 3: Confirm Commits with User

**IMPORTANT:** Before proceeding, show the user the list of commits that will be cherry-picked and confirm they agree with the list.

---

## Step 4: Ask User About Checkout Method

**IMPORTANT:** Cherry-picking requires checking out the target branch. Ask the user:

**"Do you want to:**
1. **Checkout directly** (will change your current working directory to the release branch)
2. **Use a worktree** (creates a separate directory, leaves your current work untouched)"

---

## Step 5: Create and Checkout Branch

**Naming:**
- Branch: `feature/{developer}/{cherry-picked-branch-name}_12.1`
- Remove special characters like `#` from branch name

### Option 1: Direct Checkout

```bash
# Create and checkout the branch directly
git checkout -b feature/{developer}/{cherry-picked-branch-name}_12.1 origin/release/12.1
```

**Note:** This changes your current working directory to the release/12.1 branch.

### Option 2: Use Worktree

```bash
# Create worktree in separate directory
git worktree add ../cp-[ticket-number]-12.1 -b feature/{developer}/{cherry-picked-branch-name}_12.1 origin/release/12.1

# Change to worktree directory
cd ../cp-[ticket-number]-12.1
```

**Note:** Your original working directory remains untouched.

---

## Step 6: Cherry-Pick Commits

```bash
# Cherry-pick all commits
git cherry-pick [commit-hash-1] [commit-hash-2] [commit-hash-3] ...
```

### If there's a conflict:

**Resolve conflicts:**
1. View conflicted files with `git status`
2. Resolve manually or use:
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

## Step 7: Return to Original Directory (if using worktree)

```bash
# Return to enterprise directory
cd -

# Note: Don't remove worktree yet - need to push first
```

---

## Step 8: Push Branch

```bash
git push -u origin feature/{developer}/{cherry-picked-branch-name}_12.1
```

**If using direct checkout:** You can now return to your original branch:
```bash
git checkout -
```

**If using worktree:** Clean up the worktree after pushing:
```bash
git worktree remove ../cp-[ticket-number]-12.1
```

---

## Step 9: Create PR Description

**Output the PR description as a copyable text block** for the user to paste into the PR:

```
[Ticket Type] #[Ticket ID] - [Ticket Title]

Cherry pick commits for [Ticket Type] #XXXXX to merge with release/12.1.

[commit-hash] - [commit message without ticket type/number]
[commit-hash] - [commit message without ticket type/number]
...

Merge conflicts:
[File] - [resolution explanation]

Skipped commits:
[commit-hash] - [message] - Reason: [why]
```

**Note:** Remove the ticket type and number (e.g., "Problem #29207761") from individual commit descriptions in the PR message. The ticket is already identified in the title and first line.

**After outputting the PR description, ask the user if they want to save it to a file** (`.claude/PR_Message-[branch-name].txt`). Most users will just copy the text directly, but some may prefer a file for reference.

---

## Quick Reference

```bash
# Find & verify
git branch -a | grep "[ticket-number]"
git log --format="%ai | %h | %s" --no-merges origin/develop..origin/feature/{developer}/{branch-name} | sort
git log --format="%ai | %h | %s" --no-merges origin/feature/{developer}/{branch-name} | head -20

# Confirm commits with user, then ask: Direct checkout or worktree?

# Option 1: Direct checkout
git checkout -b feature/{developer}/{cherry-picked-branch-name}_12.1 origin/release/12.1
git cherry-pick [commit-hash-1] [commit-hash-2] ...
git push -u origin feature/{developer}/{cherry-picked-branch-name}_12.1
git checkout -  # Return to previous branch

# Option 2: Worktree
git worktree add ../cp-[ticket-number]-12.1 -b feature/{developer}/{cherry-picked-branch-name}_12.1 origin/release/12.1
cd ../cp-[ticket-number]-12.1
git cherry-pick [commit-hash-1] [commit-hash-2] ...
cd -
git push -u origin feature/{developer}/{cherry-picked-branch-name}_12.1
git worktree remove ../cp-[ticket-number]-12.1
```
