# Workflow Instructions

This directory contains standardized workflow documentation for AI-assisted development.

## Files in This Directory

- **[ticket-workflow.md](ticket-workflow.md)** - Complete workflow for AI-assisted ticket handling
- **[commits.md](commits.md)** - Commit message format and standards
- **[branches.md](branches.md)** - Branch naming conventions
- **[worktrees.md](worktrees.md)** - Git worktree management and location standards
- **[build.md](build.md)** - Build commands for individual projects (overrides base CLAUDE.md)
- **[cherry-pick.md](cherry-pick.md)** - Release cherry-picking process

## Directory Structure & Artifacts

The `.claude/` directory is organized as follows:

```
.claude/
├── claude.local.md              # Main instruction file (HIGHEST PRIORITY)
├── settings.local.json          # Local project settings
├── workflow instructions/       # Workflow documentation (this directory)
│   ├── README.md               # This file
│   ├── ticket-workflow.md
│   ├── commits.md
│   ├── branches.md
│   ├── worktrees.md
│   ├── build.md
│   └── cherry-pick.md
├── tickets/                     # Ticket artifacts (created by ticket-workflow.md)
│   └── [TicketId]_[Summary].md # Ticket research and implementation notes
├── temp/                        # Temporary files and project-specific notes
│   └── [various].md            # Miscellaneous temporary documentation
├── worktrees/                   # Git worktrees for isolated ticket work
│   └── [TicketId]/             # Separate working directory per ticket
└── [other files]                # Documentation that doesn't fit above categories
```

## Path References in Workflow Instructions

When workflow instructions need to reference artifact locations, they should use:

- **Ticket artifacts**: `../.claude/tickets/[TicketId]_[Summary].md` - Ticket research and implementation notes
- **Temp files**: `../.claude/temp/[filename].md` - Temporary project-specific notes
- **Worktrees**: `../.claude/worktrees/[TicketId]/` - Isolated git working directories for ticket work
- **Other workflow docs**: `./[filename].md` (relative to this directory)

## Usage Notes

1. **Workflow instructions** (this directory) should be stable and checked into version control
2. **Ticket artifacts** (`../tickets/`) are gitignored - used for temporary research/notes during development
3. **Temp files** (`../temp/`) are gitignored - ephemeral documentation that should be cleaned up regularly
4. **Worktrees** (`../worktrees/`) are gitignored - separate git working directories per ticket
5. When adding new workflows, update both this README and the main `../claude.local.md` file

## Priority Hierarchy

As documented in `../claude.local.md`:
1. **HIGHEST**: Project `.claude/claude.local.md` - Specific workflows and standards
2. **MEDIUM**: User `~/.claude/CLAUDE.md` - Personal preferences
3. **LOWEST**: Team `CLAUDE.md` in project root - Generic guidance
