# Commit Standards

**Triggers:** commit, git commit, "commit this", "commit changes"

**Auto-chains to:** push → PR workflow

---

## Workflow
1. **Pre-commit code review:** MANDATORY - Ask user "Would you like me to perform a code review of the staged changes before committing?"
   - If yes: Follow **[review.md](review.md)** workflow, fix issues if requested, then continue
   - If no: Skip review and continue
2. **Draft:** Create commit message following format below
3. **🚨 MUST GET USER APPROVAL 🚨** - Show message, ask "Would you like me to proceed with this commit?", wait for confirmation
4. **Execute:** Only after approval, run git commit
5. **Post-Commit Automatic Chaining:** After successful commit, AUTOMATICALLY offer these next steps (don't wait for user to ask):

   **Push to Remote:**
   - Ask: "Would you like me to push this branch to remote?"
   - If **YES**: Execute `git push -u origin <branch-name>`
     - After successful push, proceed to PR offer below
   - If **NO**: Stop here

   **Create Pull Request:**
   - After successful push, ask: "Would you like me to create a Pull Request?"
   - If **YES**: Read **[pr.md](pr.md)** and execute PR workflow
   - If **NO**: Stop here

   **Rationale:** This chaining prevents users from forgetting to push or create PRs after commits. The workflow should feel seamless: commit → push → PR in one flow.

## Code Review
See **[review.md](review.md)** for complete code review workflow and standards.

## Ticket Number Extraction
Ticket is in branch name: `feature/{USERNAME}/{TICKET_ID}_{Description}`
Extract with: `git branch --show-current`

## Required Format
```
Type #Number - Brief description of what was done

Optional: Additional details explaining why/how.
```
- Item type + number on **first line** with brief description
- NO square brackets around type
- Item types: Problem, Feature, Enhancement, Task

## Example
```
Problem #29221965 - Fix accessibility in filter dropdown

Update keyboard navigation and screen reader support.
```
