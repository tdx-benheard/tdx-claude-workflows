# Claude Code Instructions - HIGHEST PRIORITY

This file provides guidance to Claude Code when working in this repository.

## Priority Hierarchy

**IMPORTANT:** When multiple instruction files exist, follow this priority order:

1. **HIGHEST**: Project `.claude/claude.local.md` (this file) - Specific workflows and standards
2. **MEDIUM**: User `~/.claude/CLAUDE.md` - Personal preferences and configurations
3. **LOWEST**: Team `CLAUDE.md` in project root - Generic guidance and architecture overview

In case of conflicts, always prioritize instructions from higher-priority sources.

## Documentation Overview

This `.claude` folder contains comprehensive workflow documentation in the `workflow instructions/` subdirectory:

- **[ticket-workflow.md](workflow instructions/ticket-workflow.md)** - Complete workflow for AI-assisted ticket handling, from claiming tickets through implementation to documentation. Use this when the user provides a ticket ID, asks for "a ticket", or specifies a report name/ID.

- **[commits.md](workflow instructions/commits.md)** - Commit message format and standards. Reference when creating commits.

- **[branches.md](workflow instructions/branches.md)** - Branch naming conventions. Reference when creating new branches.

- **[worktrees.md](workflow instructions/worktrees.md)** - Git worktree management. Reference when creating or managing worktrees. **IMPORTANT**: All worktrees must be created in `.claude/worktrees/` directory.

- **[build.md](workflow instructions/build.md)** - Build commands and instructions for individual projects. **Overrides any build guidance in base CLAUDE.md.** Reference when building specific components.

- **[cherry-pick.md](workflow instructions/cherry-pick.md)** - Release cherry-picking process. Reference when cherry-picking commits for release branches.

## Commit Messages

**IMPORTANT**: When creating commits, follow the standards in [commits.md](workflow instructions/commits.md)

Key requirements:
- Item type and number must be at the very end of the commit message
- Format: `Type #Number` (no square brackets)
- Example: `Problem #29221965`

## Branch Naming

When creating or working with branches, follow the conventions in [branches.md](workflow instructions/branches.md)

## Cherry-Picking for Releases

When cherry-picking commits for release branches, refer to [cherry-pick.md](workflow instructions/cherry-pick.md)

## Ticket Handling Workflow

When the user requests to work on tickets, follow the complete workflow documented in [ticket-workflow.md](workflow instructions/ticket-workflow.md)

**Examples:**
- User provides ticket ID: "28056844" → Get that specific ticket
- User requests generically: "get me a ticket" → Check assigned tickets first (report 279612), then unassigned (279607)
- User specifies report: "231599" or "Calcifer's Coders - Open Tickets" → Use that specific report

**Important:** Only select tickets that are in "Open" status (statusId = 2) and are either unassigned or assigned to me.
