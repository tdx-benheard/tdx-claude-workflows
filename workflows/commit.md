# Commit Standards

**Triggers:** commit, git commit, "commit this", "commit changes"

**Auto-chains to:** push → PR workflow

---

## Workflow

1. **Pre-commit review:** Ask "Would you like me to perform a code review before committing?"
   - If yes: Follow [review.md](review.md), fix issues if requested
   - If no: Skip review

2. **Draft commit message** (format below)

3. **Get user approval:** Show message, ask "Proceed with this commit?"

4. **Execute commit** (only after approval)

5. **Auto-chain offers:**
   - Ask: "Push this branch to remote?"
   - If YES: `git push -u origin <branch>` → Then ask: "Create Pull Request?"
   - If YES to PR: Follow [pr.md](pr.md)

---

## Format

**🚨 CRITICAL: ALL commits MUST include work item numbers (Issue/Project/Problem/Feature #XXXXX)**

```
Type #Number - Brief description

Optional: Additional details explaining why/how.
```

- **Work item number is MANDATORY** - never commit without it
- Item type + number on first line (NO square brackets)
- Item types: Problem, Project, Feature, Enhancement, Task, Issue
- Extract ticket from branch: `git branch --show-current` → `feature/{USERNAME}/{TICKET_ID}_{Description}`

**Examples:**
```
Problem #29221965 - Fix accessibility in filter dropdown

Update keyboard navigation and screen reader support.
```

```
Project #441886 - Fix duplicate active tabs and tab creation

Fixes two tab management issues discovered during testing.
```
