# AI Ticket Handler Instructions

## Overview
This document provides instructions for AI-assisted ticket handling within the TeamDynamix platform.

## Prerequisites

### Required MCP Server

**IMPORTANT:** This workflow requires the TeamDynamix Tickets MCP server to be installed and configured.

- **Repository**: https://github.com/tdx-benheard/tdx-api-tickets-mcp
- **Server Name**: `tdx-api-tickets-mcp`
- **Purpose**: Provides API access to TeamDynamix tickets, reports, and feed functionality
- **Configuration**: Must be installed and enabled in Claude Code's MCP settings

Without this MCP server, the ticket workflow cannot function as it depends on the API tools for fetching tickets, updating status, and posting to ticket feeds.

### Required Claude Code Permissions
Ensure Claude Code has the following permissions enabled:
- **File Operations**: Create, read, edit files and directories
- **Git Operations**: `git status`, `git checkout`, `git pull`, `git stash`, `git branch`, `git add`, `git commit`, `git worktree`, `git fetch`
- **MCP Tools**: `mcp__tdx-api-tickets-mcp__*` functions for TeamDynamix API access (prod environment)

### TeamDynamix API Configuration
- **MCP Server**: `mcp__tdx-api-tickets-mcp` (handles authentication automatically, always use prod environment)
- **Current User Info** (Ben Heard):
  - **UID**: `5ec7a897-1405-ec11-b563-0050f2eef4a7`
  - **Username**: `ben.heard@teamdynamix.com`
  - **Note**: Retrieved via `mcp__tdx-api-tickets-mcp__tdx_get_current_user` on first session
- **Report IDs**:
  - **Calcifer's Coders - Open Tickets**: 279612 (assigned to me)
  - **Calcifer's Coders - Unassigned Tickets**: 279607
  - **Open Beta Bugs**: 231599 (temporary)
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

When the user requests to work on a ticket, determine which report to use:

**Method 1: Specific Ticket ID**
- User provides a ticket number directly (e.g., "28056844")
- Skip report lookup and go directly to ticket processing

**Method 2: Default Ticket Request**
- User asks generically for "a ticket" without specifying a report
- **First**, check report 279612 (Calcifer's Coders - Open Tickets) for tickets assigned to me in "Open" status
- **If none found**, check report 279607 (Calcifer's Coders - Unassigned Tickets) for unassigned tickets in "Open" status

**Method 3: Specific Report Name or ID**
- User provides a report name or ID (e.g., "231599" or "Calcifer's Coders - Open Tickets")
- Run the specified report and find first ticket in "Open" status (assigned to me OR unassigned only)

**Filtering Rules (All Methods):**
- Only select tickets with status "Open" (statusId = 2)
- Only select tickets that are either unassigned OR assigned to me
- Skip all other tickets

### Phase 2: Ticket Processing
Once a ticket is selected, process it through these steps:

#### Step 1: Present Ticket Summary
- Get ticket details via `tdx_get_ticket` (if not already retrieved)
- Present a clear summary to the user:
  - Ticket ID, title, priority, classification
  - Key issue description
  - Application and component affected
- **Ask user if they want to proceed with investigating this ticket**
- **If user declines**: Stop here, do nothing further
- **If user confirms**: Continue to Step 2

#### Step 2: Light Investigation & Analysis
- Do a **surface-level/light investigation** to understand the issue:
  - Read the ticket description carefully
  - Search for relevant code patterns (Grep/Glob for key terms)
  - Identify likely problem areas without deep dive
  - Look for similar patterns already solved in codebase
- **Determine confidence level** (HIGH/MEDIUM/LOW):
  - **HIGH**: Clear root cause, straightforward fix, existing patterns to follow, can verify solution
  - **MEDIUM**: Solvable but requires deeper investigation or has some uncertainty
  - **LOW**: Requires specialized tools, cannot verify fix, or missing critical context
- **Present analysis to user** including:
  - Issue description (what's happening)
  - Root cause hypothesis
  - Confidence level with reasoning
  - Likely files/areas to modify
- **Ask user if they want you to work on implementing the fix**
- **If user declines**: Stop here, optionally add ticket comment explaining why
- **If user confirms**: Continue to Step 3

#### Step 3: Claim the Ticket
- **Only after user confirms they want you to implement the fix**:
  - Assign ticket to self via `tdx_update_ticket` with `responsibleUid`
  - Add "clauded" tag via `tdx_add_ticket_tags` with `tags: ["clauded"]`
- **DO NOT change status yet** - ticket remains in "Open" status until ready to implement

#### Step 4: Deep Investigation (If Needed)
- **If confidence was HIGH**: Skip this step, proceed to Step 5
- **If confidence was MEDIUM/LOW**: Do thorough investigation now
  - **Use the Task tool with subagent_type=Explore** for codebase exploration:
    - Find where functionality is implemented
    - Understand relationships between components
    - Search for patterns across multiple files
    - Example: "Find report save code and left navigation refresh behavior"
  - Refine understanding of root cause
  - Update confidence level if needed
  - Present refined analysis to user

#### Step 5: Confirm Implementation Start
- **If this step is reached, user has already confirmed in Step 2**
- Set status to "In Process" (statusId: 3) via `tdx_update_ticket`
- Continue to Step 6

#### Step 6: Branch Creation
- Branch name format: `feature/bheard/[TicketId]_[Summary]`
  - Use just the ticket ID number (no "Problem" or "CL" prefix)
  - Summary should be descriptive but concise (PascalCase, no spaces)
  - Example: `feature/bheard/28056844_ReportSaveNavigatorScroll`
- **Ask user if worktree should be created** using `AskUserQuestion` tool:
  - **If YES** (worktree authorized):
    ```bash
    git fetch origin develop && git worktree add .claude/worktrees/[TicketId] -b [BranchName] origin/develop
    ```
    - **IMPORTANT**: Navigate to the correct path using Unix-style paths:
      ```bash
      cd .claude/worktrees/[TicketId]/enterprise
      ```
    - All work happens in this isolated workspace
    - File paths must use the worktree location (e.g., `C:\source\TDDev\enterprise\.claude\worktrees\28056844\enterprise\...`)
  - **If NO** (worktree not allowed):
    - Create and checkout new branch without worktree
    ```bash
    git fetch origin develop && git checkout -b [BranchName] origin/develop
    ```

#### Step 7: Implement Solution
- Write code to fix the issue following existing patterns
- **IMPORTANT**: Only edit source files, NEVER edit compiled/generated files:
  - Edit SCSS source files (e.g., `_links.scss`)
  - Do NOT edit compiled CSS files (e.g., `styles-tdx-12.css`, `*.min.css`)
  - Build process will compile assets later
- Test implementation as thoroughly as possible

#### Step 7: Verify Solution
- Present changes to user
- **Get user confirmation** that solution is acceptable before committing
- Make any requested adjustments
- **If user declines solution**: Return to Step 6 or abort

#### Step 8: Commit Changes
- **If using worktree**: Ensure you're in the worktree directory before staging/committing
- Stage only files that fix the issue (source files only, no compiled assets)
- **Do NOT stage**:
  - Files in `ClaudeTickets/` directory
  - `.gitignore` (unless part of ticket requirements)
  - AI documentation or artifacts
  - Compiled/generated files (CSS, JS bundles, etc.)
- Commit with format (use HEREDOC syntax):
  ```bash
  cd .claude/worktrees/[TicketId]/enterprise
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
  - Clean up worktree: `git worktree remove .claude/worktrees/[TicketId]`

#### Step 9: Document Solution
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
- **Show documentation to user first** for review
- **Ask user to choose documentation method** using `AskUserQuestion` tool:
  - **Option 1: Create File** - Create markdown file in `.claude/tickets/[TicketId]_[Summary].md` (matches branch name pattern)
  - **Option 2: Post to Ticket** - Post as private feed entry via `tdx_add_ticket_feed` with `isPrivate: true`
- After user selects method, save/post the documentation accordingly

## Command Reference

### User Provides Specific Ticket ID
Example: "28056844" or "process ticket 28056844"

1. Get ticket details via `tdx_get_ticket` with specified ticketId
2. Verify ticket is assigned to me OR unassigned
3. Execute Phase 2 (Ticket Processing) steps 1-8

### User Requests "A Ticket" (Generic)
Example: "give me a ticket" or "get me a ticket"

1. Run `tdx_run_report` with reportId=279612 (Calcifer's Coders - Open Tickets)
2. Find first ticket with:
   - StatusID = 2 (Open)
   - Assigned to me
3. If no tickets found in 279612, run reportId=279607 (Calcifer's Coders - Unassigned Tickets)
4. Find first ticket with:
   - StatusID = 2 (Open)
   - Unassigned
5. Execute Phase 2 (Ticket Processing) steps 1-8

### User Specifies Report Name or ID
Example: "231599" or "get ticket from Calcifer's Coders - Open Tickets"

1. Run `tdx_run_report` with specified reportId
2. Find first ticket with:
   - StatusID = 2 (Open)
   - Assigned to me OR unassigned
3. Execute Phase 2 (Ticket Processing) steps 1-8

## Best Practices & Lessons Learned

### Code Investigation
- **Always use Task tool with Explore agent** for finding code patterns and relationships
- Be thorough in understanding the flow before implementing fixes
- Look for existing patterns (like preserving active tabs/collapsed folders) that can guide your solution

### Path Management
- **Git Bash uses Unix-style paths**: `/c/source/tddev` not `C:\source\tddev`
- **File operations use Windows paths**: `C:\source\tddev\...` for Read/Edit/Write tools
- When working in worktrees, always verify you're in the correct directory with `pwd`
- Navigate to the `enterprise` subdirectory within worktrees: `cd .claude/worktrees/[TicketId]/enterprise`

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

---

## See Also

- **[branches.md](branches.md)** - Branch naming conventions
- **[commits.md](commits.md)** - Commit message standards
- **[worktrees.md](worktrees.md)** - Git worktree management details
- **[build.md](build.md)** - Build instructions for testing changes
