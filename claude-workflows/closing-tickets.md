# Closing Tickets Workflow

## Quick Summary
Close TDX tickets and their children after work is complete. Mark tasks complete, update status, add feed entries.

## Prerequisites
- **MCP Server**: `tdx-tickets-mcp`
- **Status IDs**: 568=Ready for Test, 5=Closed (see ticket-workflow.md for full list)
- **Key Functions**: `tdx_get_ticket`, `tdx_update_ticket`, `tdx_add_ticket_feed`, `tdx_search_tickets`, `tdx_list_ticket_tasks`, `tdx_update_ticket_task`

## Finding Tickets Ready to Close

**When user asks "what tickets are ready to close" or "close tickets that are ready":**
1. Search tickets: `tdx_search_tickets` with `responsibilityUids: ["{USER_UID}"]` and `statusIDs: [568]` (Ready for Test)
2. For each ticket, check tasks via `tdx_list_ticket_tasks`
3. Ticket is ready if it has task "Update External Fields and Notify User (if applicable)"
4. Present list of ready tickets to user

## Steps to Close Tickets

### 1. Identify Tickets and Children
- Get ticket details via `tdx_get_ticket`
- Search for children via `tdx_search_tickets` with `parentTicketID` parameter

### 2. Complete Remaining Tasks (if applicable)
- For incomplete tasks (PercentComplete < 100): use `tdx_update_ticket_task` with comments "Task completed - marking as 100% complete."

### 3. Close All Tickets
- Update parent and child tickets: `tdx_update_ticket` with `statusId: 5`
- **IMPORTANT**: `comments` parameter does NOT create visible feed entries

### 4. Add Feed Entries
- Add feed entry separately via `tdx_add_ticket_feed` to ALL tickets (parents and children)
- Example message: "Fix to go out in next release"

## Key Points
- **Status ID 568 = Ready for Test, 5 = Closed**
- **Feed entries are separate** - must use `tdx_add_ticket_feed`
- **Always close children** - search first to avoid orphans
- **Use TodoWrite** to track multi-step operations
