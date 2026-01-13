# Track (Tracker) Workflow

Manage project/ticket progress tracking documents for AI handoff and context preservation.

**Use for:** Multi-day projects, investigations/audits, large tickets (L/XL), work with uncommitted changes.

## When to Read vs Update

**Read (for AI context refresh) when:**
- "track" alone AND fresh context (just started session, after /clear)
- User asks explicitly: "show track", "read track"
- No work has been done yet in this session

**Update (document work) when:**
- Work has been done: commits, implementations, investigations completed
- User provides context: "update track - completed X"
- Changes exist that should be documented
- User explicitly says "update track/tracker"

**IMPORTANT:** If there are changes/work since last update, prioritize UPDATING over just showing.
"Track" is primarily for AI to read context at session start, but should update when work exists.

**Always ask if unclear** - don't guess

## Commands

### Create Track
**Triggers:** "create track", "new track", "start track"

1. Get ticket/project ID from branch (or ask)
2. Generate filename: `{ID}_{description}.md`
3. Create `.claude/tracks/` directory if needed
4. Populate from template with metadata
5. Show, save, report location

### Update Track
**Triggers:** "update track", "update tracker", "refresh track", OR "track" when work has been done

**When to proactively update:**
- After commits are made
- After completing investigations or implementations
- After significant progress on work items
- When user says "track" but changes exist

**Process:**
1. Find tracker for current branch (ask if ambiguous)
2. Read content, check line count (warn if 600+)
3. Determine changes (specified, inferred from conversation, or ask)
4. Update: timestamp, status, what's left, current work, checklist
5. **Trim**: Keep last 10-15 commits, condense completed, remove old notes
6. Show diff, confirm, save

### Show Track
**Triggers:** "show track", "read track", "track" (when no context)

1. Find tracker, display content
2. Warn if over 600 lines

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

## Size Management - Max 800 Lines

**When updating, actively trim:**
- Commits: Keep last 10-15 only
- Completed work: One line per item
- Current work: Remove after implementation
- Notes: Delete outdated investigations

**At 600+ lines:** Warn user
**At 800+ lines:** Archive, split, or aggressively trim

## File Management

**Location:** `.claude/tracks/{ID}_{description}.md`
**Examples:** `27580198_client-portal-tdx12.md`
**Cleanup:** When complete, closed, or unneeded

## Integration Suggestions

From **ticket workflow**: "Multi-session work. Create tracker?"
From **commit workflow**: "Update tracker with this commit?"

## Key Guidelines

1. Read existing tracker before updating
2. Check size (warn 600+, trim actively)
3. Show diff before saving
4. Preserve user manual edits
5. Update timestamp always
6. Be brief: bullets over paragraphs
7. Infer from context when possible
8. Ask when unclear
