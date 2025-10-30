# Claude Code Instructions

This file provides guidance to Claude Code when working in this repository.

## Documentation Overview

This `.claude` folder contains comprehensive workflow documentation:

- **[ticket-workflow.md](./ticket-workflow.md)** - Complete workflow for AI-assisted ticket handling, from claiming tickets through implementation to documentation. Use this when the user provides a ticket ID, asks for "a ticket", or specifies a report name/ID.

- **[commit-description-standards.md](./commit-description-standards.md)** - Commit message format and standards. Reference when creating commits.

- **[branch-naming.md](./branch-naming.md)** - Branch naming conventions. Reference when creating new branches.

- **[Cherry-Picking-Release-Tickets.md](./Cherry-Picking-Release-Tickets.md)** - Release cherry-picking process. Reference when cherry-picking commits for release branches.

## Commit Messages

**IMPORTANT**: When creating commits, follow the standards in [commit-description-standards.md](./commit-description-standards.md)

Key requirements:
- Item type and number must be at the very end of the commit message
- Format: `Type #Number` (no square brackets)
- Example: `Problem #29221965`

## Branch Naming

When creating or working with branches, follow the conventions in [branch-naming.md](./branch-naming.md)

## Cherry-Picking for Releases

When cherry-picking commits for release branches, refer to [Cherry-Picking-Release-Tickets.md](./Cherry-Picking-Release-Tickets.md)

## Ticket Handling Workflow

When the user requests to work on tickets, follow the complete workflow documented in [ticket-workflow.md](./ticket-workflow.md)

**Examples:**
- User provides ticket ID: "28056844" → Get that specific ticket
- User requests generically: "get me a ticket" → Check assigned tickets first (report 279612), then unassigned (279607)
- User specifies report: "231599" or "Calcifer's Coders - Open Tickets" → Use that specific report

**Important:** Only select tickets that are in "Open" status (statusId = 2) and are either unassigned or assigned to me.
