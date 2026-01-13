# claude.local.md

## ⚠️ CRITICAL WORKFLOW ENFORCEMENT ⚠️

**BEFORE taking ANY action, you MUST check if it requires a workflow:**

1. Read `CLAUDE-WORKFLOWS.md` (in this directory) to see trigger mappings
2. If your action matches a trigger, read that workflow file FIRST
3. Follow the workflow exactly

### 🔥 BUILD - SPECIAL ENFORCEMENT 🔥

**If user mentions: build, compile, msbuild, MSBuild, dotnet build, grunt, npm run build**

→ **STOP IMMEDIATELY**
→ **Read `claude-workflows/build.md` FIRST** (mandatory, no exceptions)
→ Build violations waste hours and break dependencies

### All Other Workflows

Check `CLAUDE-WORKFLOWS.md` for full trigger list. Common ones:
- "commit" → commit.md
- "create pr" → pr.md
- "review" → review.md
- "get ticket" → ticket-workflow.md
- "test in browser" → webagent.md

**Pattern:** When in doubt, check CLAUDE-WORKFLOWS.md first.

---

## Priority Hierarchy
When instructions conflict, follow this order:
1. **HIGHEST**: Workflow files in `claude-workflows/`
2. **MEDIUM**: This file
3. **LOWEST**: `../CLAUDE.md`

## 🚨 CRITICAL RULES 🚨
- **NEVER UPDATE `CLAUDE.md`** - This is the shared project documentation. Only update workflow files in `.claude/` or this local file.
- For build instructions, always update `claude-workflows/build.md`, NOT `CLAUDE.md`
- TDWorkManagement SCSS compilation: Use `npm run scss:compile` from the TDWorkManagement directory (already documented in build.md)

---

## User-Specific Configuration

### Developer Info
- **Username**: `bheard`
- **Full Name**: `Ben Heard`
- **Email**: `ben.heard@teamdynamix.com`
- **TDX User UID**: `5ec7a897-1405-ec11-b563-0050f2eef4a7`

### Ticket Workflow - Report Priorities

CC is short for our team - Calcifer's Coders

**Report IDs:**
- **279612** - Calcifer's Coders - Pending Tickets / CC - Pending Tickets (Open status); filter on tickets assigned to me.
- **279607** - Calcifer's Coders - Unassigned (Open status) / CC - Unassigned; take top item
- **326597** - Clauded tickets (Ben - Clauded report);take top item

**When user says "get me a ticket":**
1. Check report 279612 (assigned to me, status=2 Open)
2. If none found, check report 279607 (unassigned, status=2 Open)
3. Return first ticket found

**When user says "clauded ticket":**
- Run report 326597 (Clauded tickets)
- Return first result

**When user provides specific report name or ID:**
- Use that report
- Find first status=2 (Open) ticket that is either assigned to me OR unassigned

### Code Review Standards
**Whenever performing any code review (whether requested explicitly or before commits), follow `claude-workflows/review.md`**

### Build Configuration
- **MSBuild Path**: `C:\Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe`
- **Project Directory**: `enterprise` (standard working subdirectory within repo and worktrees)

### Repository Structure
- **objects directory location**: One level up from `enterprise` folder (at `C:\source\TDDev\objects`)
  - Contains shared libraries like `TeamDynamix.Domain`, `TeamDynamix.Core`, `TeamDynamix.Data`, etc.
  - When searching for code in shared libraries, search in `../objects/` from the `enterprise` directory

### Release Info
- **Release Version**: `12.1`

### Web Config Virtual Directory Path
**Issue:** Sometimes web.config files and appsettings.Development.json point to `/TDDev/` instead of `/TDDM/`, causing modals to load through old paths instead of the new UX.

**Symptom:** When testing changes in TDWorkManagement, modals load content from `/TDDev/TDNext/` instead of going through TDWorkManagement, so TypeScript/JavaScript changes don't appear.

**Fix:**
1. **Check if stash exists:** `git stash list` (look for web config template stash)
2. **Apply stash:** `git stash apply stash@{0}` (or whichever has web config changes)
3. **Run update script:** `cmd /c "updatewebconfigsbah - DM.bat"` (or `UpdateWebConfigsIterativeNet.bat bah`)
4. **Manually fix TDWorkManagement:** Edit `TDWorkManagement/appsettings.Development.json` and change all `/TDDev/` to `/TDDM/`
5. **Recycle app pools:** Touch web.config files or restart IIS

**Files to check:**
- `TDNext/web.config.values-bah` - Should have `BASE_HTTP_PATH=/TDDM/`
- `TDWorkManagement/appsettings.Development.json` - Should have `"BaseHttpPath": "/TDDM/TDNext/"`

**Verification:** Check iframe URL when modal opens - should be `/TDDM/` not `/TDDev/`

### Testing Tip
**TDWorkManagement tab caching:** If changes don't appear after fixing paths/recycling, close extracted app tabs completely and open fresh - tabs cache their URLs and won't pick up config changes on refresh.
