# Track (Tracker) Workflow

Manage project/ticket progress tracking documents for AI handoff and context preservation.

**Use for:** Multi-day projects, investigations/audits, large tickets (L/XL), work with uncommitted changes.

## Commands

### Show Track (Read Only)
**Triggers:** "show track", "read track", "track" (when tracker hasn't been read yet this session)

**Process:**
1. Find tracker for current branch (ask if ambiguous)
2. Check line count (warn if over 500 lines)
3. Display content
4. Analyze pending changes vs tracker:
   - Check `git status` for modified/untracked files
   - Check `git log` for commits since last tracker update
   - Compare uncommitted changes section with actual changes
5. Report discrepancies:
   - List items that appear completed but not documented
   - List new files/changes not reflected in tracker
   - List commits made after tracker's "Updated" timestamp
6. Show "What's Left To Do" from tracker
7. Ask: **"Should I proceed with the next steps or update the tracker?"**

**Example output:**
```
📋 Tracker Status (154 lines)

Current Status: Phase 4 testing
Last Updated: 2026-01-15

⚠️ Items not up to date:
- 3 new commits since last update (b18dc31, 16729f3, 4de80e9)
- 15 untracked documentation files created
- web.config.values-bah files modified (not documented)
- FEATURE-CLAUDE-CODE.md deleted (not documented)

🎯 Next Steps (from tracker):
1. IMMEDIATE: Test production ticket lookup with ticket 28130100
2. Short Term: Complete Phase 4 commit
3. Long Term: Phase 5 - TDNext integration

Should I proceed with the next steps or update the tracker?
```

### Create Track
**Triggers:** "create track", "new track", "start track"

1. Get ticket/project ID from branch (or ask)
2. Generate filename: `{ID}_{description}.md`
3. Create `.claude/tracks/` directory if needed
4. Populate from template with metadata
5. Show, save, report location

### Update Track
**Triggers:** "update track", "update tracker", "refresh track"

**Process:**
1. Find tracker for current branch (ask if ambiguous)
2. Read content, check line count
3. Gather changes to document:
   - New commits since last update
   - Completed work items
   - New uncommitted changes
   - Status changes
   - Progress on "What's Left To Do"
4. Update sections:
   - Timestamp (always)
   - Current Status
   - What's Left To Do (move completed items down)
   - Current Work (describe focus)
   - Completed Checklist (add recent commits/work)
   - Uncommitted Changes (update file count)
5. **Trim to target 500 lines** (max 600):
   - Keep last 10-15 commits only
   - Condense completed work to one line per item
   - Remove old "Current Work" sections after implementation
   - Delete outdated investigation notes
   - Consolidate similar items
6. Show diff preview
7. Confirm with user
8. Save

**Line count targets:**
- **Target**: 500 lines
- **Warn at**: 500+ lines
- **Max**: 600 lines (trim aggressively if exceeded)

## Template Structure

```markdown
# {ID} - {Title}
**Branch**: `{branch}` | **Release**: {ver} | **Status**: {status} | **Updated**: {date}

## 📍 Current Status
{Paragraph} - Completed: ✅ | In Progress: 🔄 | Not Started: ⏹️

## 🎯 What's Left To Do
1. IMMEDIATE: {action}
2. Short Term: {items}
3. Medium/Long Term: {items}

## 🔍 Current Work: {Focus}
What we're doing | Key findings | Next steps | Links to docs

## 📋 Completed Checklist
Commits (10-15 max) | Work items | Features | Research

## 💾 Uncommitted Changes (optional)
Count & file list

## 📝 Notes (optional)
Constraints | Feedback | Testing
```

## Trimming Strategies (to reach 500 lines)

**Priority order (cut first to last):**
1. Old "Current Work" sections (keep only latest focus)
2. Detailed investigation notes (keep only key findings)
3. Older commits (keep last 10-15)
4. Verbose status descriptions (make concise)
5. Duplicate information
6. Long file lists (summarize: "15 doc files", not full list)
7. Completed checklist details (one line per item max)

**Keep:**
- Current Status (always)
- What's Left To Do (critical)
- Recent commits (last 10-15)
- Active notes (constraints, blockers)

## File Management

**Location:** `.claude/tracks/{ID}_{description}.md`
**Examples:** `27580198_client-portal-tdx12.md`, `FEATURE_claude-code-analysis.md`
**Cleanup:** When work complete, closed, or no longer needed

## Integration Suggestions

From **ticket workflow**: "Multi-session work. Create tracker?"
From **commit workflow**: "Update tracker with this commit?"

## Key Guidelines

1. **First "track" call per session**: Read only, analyze changes, offer to proceed or update
2. **Check size**: Warn at 500+ lines, trim actively when updating
3. **Show diff** before saving updates
4. **Preserve user manual edits** when updating
5. **Update timestamp** always
6. **Be brief**: Bullets over paragraphs
7. **Infer from context** when possible
8. **Ask when unclear** - don't guess

## Detecting Session Start

**Indicators tracker hasn't been read yet:**
- No previous references to tracker content in conversation
- User just said "wf" or "track" without prior context
- Fresh conversation start

**If uncertain:** Default to read-only mode with change analysis
