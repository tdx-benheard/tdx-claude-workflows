# Cherry-Pick Release Process

Cherry-pick commits from feature branch to `release/{RELEASE_VERSION}`.

## Workflow

1. Find feature branch
2. Identify commits (verify merged to develop)
3. **Confirm commits with user**
4. **Ask: Direct checkout or worktree?**
5. Create branch, cherry-pick, push
6. Output PR description

---

## Step 1: Find & Identify Commits

```bash
# Find branch
git branch -a | grep "{TICKET_ID}"

# Verify merged to develop (should be empty)
git log --format="%ai | %h | %s" --no-merges origin/develop..origin/feature/{USERNAME}/{BRANCH_NAME} | sort

# Find ONLY commits to cherry-pick (not already in release)
git log --format="%h | %s" --no-merges --reverse origin/release/{RELEASE_VERSION}..origin/feature/{USERNAME}/{BRANCH_NAME}
```

**CRITICAL:** Feature branch may have 200+ commits, but most are from develop history or already in release.

### Identify ALL Related Work Items

**Look for multiple work item IDs:**
- Main Project # (e.g., Project #441886)
- Related Problems created during development (e.g., #29286856, #28997752)
- Commits WITHOUT IDs: initial work, code review feedback, refactors
- Pattern match: "Add [feature]", "Fix code quality", "Apply suggestions"

**Categorize commits:**
- ✅ Cherry-pick: Core feature (main Project #) + Related Problems + No-ID feature commits
- ❌ Exclude: Unrelated bugs (dark mode fixes, permission bugs) - already in release or not needed

**Verify exclusions:**
```bash
# Check if "unrelated" commit is already in release
git log --oneline origin/release/{RELEASE_VERSION} | grep {commit-hash}
```

**IMPORTANT:** Show user categorized commits list, get confirmation before proceeding.

---

## Step 2: Ask Checkout Method

**Ask user via AskUserQuestion:** "Do you want to create a worktree for the cherry pick?"
1. Create worktree
2. Use current directory

---

## Step 3: Create Branch & Cherry-Pick

**Branch naming:** `feature/{USERNAME}/{NAME}_{RELEASE_VERSION}` (remove `#` chars)

**Option 1: Direct Checkout**
```bash
git checkout -b feature/{USERNAME}/{NAME}_{RELEASE_VERSION} origin/release/{RELEASE_VERSION}
git cherry-pick {hash-1} {hash-2} ...
git push -u origin feature/{USERNAME}/{NAME}_{RELEASE_VERSION}
git checkout -  # Return to previous branch
```

**Option 2: Worktree**
- See `worktrees.md` for cherry-pick worktree creation
- Navigate to worktree enterprise directory
- Cherry-pick commits, push, cleanup:
```bash
git cherry-pick {hash-1} {hash-2} ...
git push -u origin feature/{USERNAME}/{NAME}_{RELEASE_VERSION}
cd -  # Return to original directory
git worktree remove .claude/worktrees/cherry-pick-{branch-name}
```

---

## Conflict Resolution

**🚨 NEVER use `git checkout --ours/--theirs`** - takes entire file, brings in/loses unrelated code

**Process:**
1. Manually resolve each conflict marker
2. Verify: `head -5 <file>` (check imports), `git diff --cached <file>` (verify changes)
3. Add and continue: `git add <file> && git cherry-pick --continue`

**Common patterns:**
- Settings merges: Keep properties from both sides
- Accessibility: Accept incoming (e.g., `:focus-visible` additions)
- Code from other projects: Exclude (check imports, search for other project IDs)

**Skip empty:** `git cherry-pick --skip` (document in PR)

---

## Step 4: Create Pull Request

**After successful push, ask user:** "Would you like me to create the pull request?"

If yes, follow **[pr.md](pr.md)** workflow with cherry-pick PR description:

### PR Description Template
```
{Type} #{ID} - {Title}

Cherry pick commits for {Type} #{ID} to merge with release/{RELEASE_VERSION}.

{hash} - {message without ticket type/number}
{hash} - {message without ticket type/number}

Merge conflicts:
{File} - {resolution explanation}

Skipped commits:
{hash} - {message} - Reason: {why}
```

**Fallback:** If PR creation fails, output as copyable text. Ask if user wants it saved to `.claude/temp/CP_PR_Message-{BRANCH_NAME}.txt`
