# Closing Tickets Workflow

Close TDX tickets and children after work is complete.

## Prerequisites

- **MCP Server**: `tdx-tickets-mcp`
- **Status IDs**: 568=Ready for Test, 5=Closed
- **Functions**: `tdx_get_ticket`, `tdx_update_ticket`, `tdx_add_ticket_feed`, `tdx_search_tickets`, `tdx_list_ticket_tasks`, `tdx_update_ticket_task`

---

## Finding Tickets Ready to Close

**When user asks "what tickets are ready to close":**
1. Search: `tdx_search_tickets` with `responsibilityUids: ["{USER_UID}"]`, `statusIDs: [568]`
2. Check tasks via `tdx_list_ticket_tasks`
3. Ready if has task "Update External Fields and Notify User (if applicable)"
4. Present list to user

---

## Steps to Close

**1. Identify tickets and children**
- Get ticket: `tdx_get_ticket`
- Search children: `tdx_search_tickets` with `parentTicketID`

**2. Complete remaining tasks** (if applicable)
- For incomplete tasks (PercentComplete < 100): `tdx_update_ticket_task` with comment "Task completed - marking as 100% complete."

**3. Close all tickets**
- Update parent and children: `tdx_update_ticket` with `statusId: 5`
- **IMPORTANT**: `comments` parameter does NOT create feed entries

**4. Add feed entries**
- Use `tdx_add_ticket_feed` on ALL tickets (parents and children)
- Example: "Fix to go out in next release"

---

## Key Points

- Feed entries are separate - must use `tdx_add_ticket_feed`
- Always close children - search first to avoid orphans
- Use TodoWrite to track multi-step operations
