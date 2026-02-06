# Ticket Workflow

Workflow: Select → Investigate → Claim → Branch → Fix → Build → Commit → Document

## Prerequisites
- **MCP Server**: `tdx-api-tickets-mcp`
- **Status IDs**: 2=Open, 3=In Process, 191349=Pending Client Review, 568=Ready for Test, 5=Closed
- **Functions**: `tdx_run_report`, `tdx_get_ticket`, `tdx_update_ticket`, `tdx_add_ticket_feed`, `tdx_add_ticket_tags`

## Phase 1: Ticket Selection

**User provides ticket ID:** Skip to Phase 2

**"get me a ticket":** Check `CLAUDE.local.md` for report priorities and follow order

**User provides report ID/name:** Run that report with filtering from `CLAUDE.local.md`

## Phase 2: Ticket Processing

### 1. Present Summary
- Get ticket via `tdx_get_ticket`
- Show: ID, title, priority, classification, description, application/component
- **Ask: Proceed investigating?** → If NO, stop

### 2. Light Investigation
- Surface analysis: read description, search code (Grep/Glob), identify problem areas
- Determine confidence: HIGH (clear fix), MEDIUM (needs deeper work), LOW (missing context)
- Present: issue, root cause hypothesis, confidence + reasoning, files to modify
- **Ask: Implement fix?** → If NO, stop (optionally add comment)

### 3. Claim Ticket
- **Ask via AskUserQuestion**: "Claim ticket (assign to you, add 'Clauded' tag, set In Process)?"
- If YES:
  - Assign & update status: `tdx_update_ticket` (responsibleUid, statusId: 3)
  - Add tag: `tdx_add_ticket_tags` (tags: ["Clauded"])
- If NO: Stop

### 4. Deep Investigation (if confidence MEDIUM/LOW)
- **Use Task tool with subagent_type=Explore** for codebase exploration
- Refine understanding, update confidence
- Present refined analysis

### 5. Create Branch
- Format: `feature/{USERNAME}/{TicketId}_{Summary}` (PascalCase, no spaces)
- **Ask via AskUserQuestion**: "Create worktree for isolation?"
- **If YES**: See `worktrees.md` for ticket worktree creation
- **If NO**: `git fetch origin develop && git checkout -b {BranchName} origin/develop`

### 6. Implement & Verify
- Write fix following existing patterns
- **Only edit source files** (SCSS not compiled CSS, etc.)
- Present changes
- **Get user confirmation** before committing
- If declined → adjust or abort

### 7. Build (if NOT in worktree)
- **If NOT in worktree**: Build to verify compilation
- **If in worktree**: Skip build (user builds in main directory)
- **ALWAYS reference `build.md`** for correct build commands
- Use minimal build strategy (only affected project)

### 8. Commit
- **If worktree**: Ensure in worktree directory
- Stage source files only (no compiled assets, no .gitignore unless required, no AI docs)
- Follow commit format from `commit.md`:
```bash
git add {files}
git commit -m "$(cat <<'EOF'
{Brief title}

{Detailed description}

{ItemType} #{TicketId}
EOF
)"
```
- ItemType from ticket's `ClassificationName` (Problem, Change, Incident)
- **If worktree**: Return to main enterprise directory, cleanup: `git worktree remove .claude/worktrees/{branch-name}`

### 9. Document
- Get commit hash: `git log {BranchName} -1 --format='%H'`
- Create lean documentation:
```markdown
# {Title}
**ID:** {TicketId} | **Branch:** {BranchName} | **Commit:** {ShortHash}

## Fix Summary
{2-3 sentences: root cause + changes}

## Files Modified
- `path/file` - {change description}

## Testing Notes
- {key test area}
```
- **Show to user first**
- **Ask via AskUserQuestion**: Create file (`.claude/tickets/{TicketId}_{Summary}.md`) OR post to ticket (private feed via `tdx_add_ticket_feed` with `isPrivate: true`)

## Key Patterns
- **Always use Explore agent** (Task tool) for code investigation
- **Worktree isolation** keeps workspace clean
- **User approval** before branch creation and commits
- **Parallel tool calls** when independent
- **Don't edit compiled files** (CSS, JS bundles)
