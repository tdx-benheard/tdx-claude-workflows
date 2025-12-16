# Commit Standards

## Workflow
1. **Pre-commit code review:** MANDATORY - Ask user "Would you like me to perform a code review of the staged changes before committing?"
   - If yes: Follow **[review.md](review.md)** workflow, fix issues if requested, then continue
   - If no: Skip review and continue
2. **Draft:** Create commit message following format below
3. **🚨 MUST GET USER APPROVAL 🚨** - Show message, ask "Would you like me to proceed with this commit?", wait for confirmation
4. **Execute:** Only after approval, run git commit
5. **Push:** After successful commit, ask user "Would you like me to push this branch to remote?"
   - If yes: Run `git push -u origin <branch-name>`
   - If no: Skip and continue

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
