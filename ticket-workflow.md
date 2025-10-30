# AI Ticket Handler Instructions

## Overview
This document provides instructions for AI-assisted ticket handling within the TeamDynamix platform.

## Prerequisites

### Required Claude Code Permissions
Ensure Claude Code has the following permissions enabled:
- **File Operations**: Create, read, edit files and directories
- **Git Operations**: `git status`, `git checkout`, `git pull`, `git stash`, `git branch`, `git add`, `git commit`, `git worktree`, `git fetch`
- **MCP Tools**: `mcp__tdx-api-mcp-prod__*` functions for TeamDynamix API access

### TeamDynamix API Configuration
- **MCP Server**: `mcp__tdx-api-mcp-prod` (handles authentication automatically)
- **Report IDs**:
  - Unassigned Team Tickets: 279607
  - Assigned Team Tickets: 279612
- **Key Functions**:
  - `tdx_run_report` - Run TeamDynamix reports
  - `tdx_get_ticket` - Get ticket details by ID
  - `tdx_update_ticket` - Update ticket fields (partial update, e.g., statusId, responsibleUid)
  - `tdx_add_ticket_feed` - Add comments/updates to tickets (supports isPrivate flag)
  - `tdx_add_ticket_tags` - Add tags to tickets
- **Common Status IDs**:
  - 2 = "Open"
  - 3 = "In Process"
  - 191349 = "Pending Client Review"
  - 568 = "Ready for Test"
  - 5 = "Closed"
  - 6 = "Closed and Approved"
  - 711 = "Cancelled"
  - 712 = "On Hold"
  - 1363 = "Enhancement Request"

### Build Commands Reference

**Full Project Build:**
```bash
cd enterprise && build.bat              # Full build with tests
cd enterprise && build.bat Compile      # Quick compile without tests
cd enterprise && build.bat Precompile   # Validates Web Forms pages and MVC views
```

**Frontend Asset Building (from repository root):**
```bash
grunt                    # Build all JavaScript/CSS/TypeScript assets
grunt styles             # Compile LESS to CSS with PostCSS and auto-prefixing
grunt scripts            # JavaScript compilation and minification
grunt typescript         # TypeScript compilation
```

**Vue Library Building:**
```bash
cd TDWorkManagement/VueLibrarySource
npm run build            # Production build to ../wwwroot/vue-library/
npm run builddev         # Development build with sourcemaps
npm run watch            # Watch mode for development
npm run tsc              # TypeScript type checking without emit
npm run lint             # ESLint + vue-tsc linting
```

**Bash Command Syntax Rules:**
- **Path format**: Use Unix-style paths (`/c/source/tddev`) NOT Windows paths (`C:\source\tddev`)
- **Spaces in paths**: Always use double quotes: `cd "/c/source/my folder"`
- **Chaining commands**:
  - Use `&&` for sequential commands where later commands depend on earlier success
  - Use `;` for sequential commands that should run regardless of earlier failures
  - Use `||` for fallback commands that run only if the previous command fails
- **Multi-line strings**: Use HEREDOC syntax for commit messages:
  ```bash
  git commit -m "$(cat <<'EOF'
  Multi-line
  commit message
  EOF
  )"
  ```
- **Current directory**: Git Bash starts in the working directory set by Claude Code

## Workflow Overview

The ticket handling process has two main phases:

### Phase 1: Ticket Selection
Choose one of three methods to select a ticket:
1. **"Grab a new ticket"** - Get first unassigned ticket from report 279607
2. **"Grab my ticket"** - Get first assigned-to-me ticket from report 279612
3. **"Process ticket [ID]"** - Use specified ticket ID directly

### Phase 2: Ticket Processing
Once a ticket is selected, process it through these steps:

#### Step 1: Claim the Ticket
- Get ticket details via `tdx_get_ticket` (if not already retrieved)
- **Assign ticket to self** via `tdx_update_ticket` (only if not already assigned)
- **Set status to "In Process"** via `tdx_update_ticket` with `statusId: 3`

#### Step 2: Analyze the Ticket
- Analyze description, requirements, and technical complexity
- **Use the Task tool with subagent_type=Explore** for codebase exploration when:
  - You need to find where functionality is implemented
  - The issue requires understanding relationships between components
  - You're searching for patterns across multiple files
  - Example: "Find report save code and left navigation refresh behavior"
- **Determine confidence level** (HIGH/MEDIUM/LOW):
  - **HIGH**: Clear root cause, straightforward fix, can verify solution
  - **MEDIUM**: Solvable but requires investigation or has some uncertainty
  - **LOW**: Requires specialized tools, cannot verify fix, or missing critical context
- **Report confidence assessment and summary to user** (DO NOT create temporary file yet)

#### Step 3: Wait for User Confirmation
- Wait for user to confirm whether to proceed with implementation
- **If user declines**:
  - Add feed entry via `tdx_add_ticket_feed` with analysis and reason for declining
  - Ticket remains assigned for manual review
  - Done
- **If user confirms**: Continue to Step 4

#### Step 4: Branch Creation
- Branch name format: `feature/bheard/[TicketId]_[Summary]`
  - Use just the ticket ID number (no "Problem" or "CL" prefix)
  - Summary should be descriptive but concise (PascalCase, no spaces)
  - Example: `feature/bheard/28056844_ReportSaveNavigatorScroll`
- **Ask user if worktree should be created** using `AskUserQuestion` tool:
  - **If YES** (worktree authorized):
    ```bash
    git fetch origin develop && git worktree add ../enterprise-claude-[TicketId] -b [BranchName] origin/develop
    ```
    - **IMPORTANT**: Navigate to the correct path using Unix-style paths:
      ```bash
      cd /c/source/tddev/enterprise-claude-[TicketId]/enterprise
      ```
    - All work happens in this isolated workspace
    - File paths must use the worktree location (e.g., `C:\source\tddev\enterprise-claude-28056844\enterprise\...`)
  - **If NO** (worktree not allowed):
    - Create and checkout new branch without worktree
    ```bash
    git fetch origin develop && git checkout -b [BranchName] origin/develop
    ```

#### Step 5: Implement Solution
- Write code to fix the issue following existing patterns
- **IMPORTANT**: Only edit source files, NEVER edit compiled/generated files:
  - Edit SCSS source files (e.g., `_links.scss`)
  - Do NOT edit compiled CSS files (e.g., `styles-tdx-12.css`, `*.min.css`)
  - Build process will compile assets later
- Test implementation as thoroughly as possible

#### Step 6: Verify Solution
- Present changes to user
- **Get user confirmation** that solution is acceptable before committing
- Make any requested adjustments
- **If user declines solution**: Return to Step 5 or abort

#### Step 7: Commit Changes
- **If using worktree**: Ensure you're in the worktree directory before staging/committing
- Stage only files that fix the issue (source files only, no compiled assets)
- **Do NOT stage**:
  - Files in `ClaudeTickets/` directory
  - `.gitignore` (unless part of ticket requirements)
  - AI documentation or artifacts
  - Compiled/generated files (CSS, JS bundles, etc.)
- Commit with format (use HEREDOC syntax):
  ```bash
  cd /c/source/tddev/enterprise-claude-[TicketId]/enterprise
  git add [modified files]
  git commit -m "$(cat <<'EOF'
  [Brief title of fix]

  [Detailed description of changes and why]

  [ItemType] #[TicketId]

  🤖 Generated with [Claude Code](https://claude.com/claude-code)

  Co-Authored-By: Claude <noreply@anthropic.com>
  EOF
  )"
  ```
  - ItemType comes from ticket's `ClassificationName` field (e.g., "Problem", "Change", "Incident")
  - Example: `Problem #28056844`
- **If worktree was created**:
  - Return to main directory: `cd /c/source/tddev/enterprise`
  - Clean up worktree: `git worktree remove ../enterprise-claude-[TicketId]`

#### Step 8: Document and Post to Ticket
- Get the commit hash from the correct branch:
  ```bash
  git log feature/bheard/[TicketId]_[Summary] -1 --format='%H'
  ```
- Create documentation (lean format):
  ```markdown
  # [Ticket Title]
  **ID:** [TicketId] | **Branch:** [BranchName] | **Commit:** [ShortHash]

  ## Fix Summary
  [2-3 sentences: root cause + what was changed]

  ## Files Modified
  - `path/to/file.ext` - [Brief description of change]

  ## Testing Notes
  - [Key area to test]
  - [Another key area]
  ```
- **Show documentation to user first** for review before posting
- **After user approval**, post documentation as feed entry via `tdx_add_ticket_feed` with `isPrivate: true`
  - This preserves the documentation in the ticket for future reference
  - The ticket feed is the permanent location for this documentation

## Command Reference

### "Grab a New Ticket"
Selects the first unassigned ticket from report 279607, then processes it:
1. Run `tdx_run_report` with reportId=279607
2. Get first unassigned ticket details
3. Execute Phase 2 (Ticket Processing) steps 1-8

### "Grab My Ticket" or "Tackle My Ticket"
Selects the first assigned-to-me ticket from report 279612, then processes it:
1. Run `tdx_run_report` with reportId=279612
2. Get first ticket assigned to current user
3. Check ticket status:
   - If status is NOT "Open" (statusId != 2): Skip (already in progress or completed), try next ticket
   - If status is "Open": Continue with this ticket
4. Execute Phase 2 (Ticket Processing) steps 1-8

### "Process Ticket [ID]"
Processes a specific ticket by ID:
1. Get ticket details via `tdx_get_ticket` with specified ticketId
2. Execute Phase 2 (Ticket Processing) steps 1-8

## Best Practices & Lessons Learned

### Code Investigation
- **Always use Task tool with Explore agent** for finding code patterns and relationships
- Be thorough in understanding the flow before implementing fixes
- Look for existing patterns (like preserving active tabs/collapsed folders) that can guide your solution

### Path Management
- **Git Bash uses Unix-style paths**: `/c/source/tddev` not `C:\source\tddev`
- **File operations use Windows paths**: `C:\source\tddev\...` for Read/Edit/Write tools
- When working in worktrees, always verify you're in the correct directory with `pwd`
- Navigate to the `enterprise` subdirectory within worktrees: `cd /c/source/tddev/enterprise-claude-[TicketId]/enterprise`

### Git Worktrees
- Worktrees provide isolation and keep your main workspace clean
- Always verify worktree removal with `git worktree list` and directory existence check
- Get commit hash using the full branch name: `git log feature/bheard/[TicketId]_[Summary] -1 --format='%H'`

### Communication
- Show documentation to user before posting to ticket feed
- Present changes and get explicit approval before committing
- Be transparent about confidence levels and uncertainties

### Efficiency
- Use parallel tool calls when operations are independent (e.g., git status + git diff)
- Use sequential chaining (`&&`) when later commands depend on earlier success
- Keep temporary files minimal - only create when truly needed
