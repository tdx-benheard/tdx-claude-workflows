# Post-Build Pre-warming

**Problem:** After building, first request to each app is slow due to ASP.NET compilation and initialization.

**Solution:** Pre-warm applications by hitting key endpoints to trigger compilation and startup.

---

## When to Run Prewarm

**⚠️ IMPORTANT:** Only run prewarm after **C# builds** (MSBuild/dotnet build). Do NOT run after frontend-only builds.

**Run prewarm after:**
- MSBuild of web projects (TDNext, TDClient, TDAdmin, TDWorkManagement)
- `dotnet build` commands
- Full solution builds → Prewarm all apps in parallel

**Do NOT run after:**
- `npm run builddev` (TypeScript only)
- `npm run scss:compile` (SCSS only)
- Vue builds in VueLibrarySource

---

## Project Mapping

- Built **TDNext** → Prewarm TDNext (automatically prewarms TDWorkManagement)
- Built **TDClient** → Prewarm TDClient
- Built **TDAdmin** → Prewarm TDAdmin
- Built **TDWorkManagement** → Prewarm TDWorkManagement
- Built **full solution** → Prewarm all apps in parallel

---

## Execution Requirements

**CRITICAL RULES:**
1. **Use prewarm-auth.ps1 script** - Handles authentication automatically
2. **Background execution:** ALWAYS use `run_in_background: true` in Bash tool
3. **30-second timeout:** Use `timeout: 30000` in Bash tool
4. **Non-blocking:** Do NOT wait for completion - proceed immediately

**⚠️ BASH PATH HANDLING:** Bash tool strips backslashes. Wrap in `powershell -Command` with `cd` first.

---

## Command Format

**Basic prewarm:**
```bash
powershell -Command "cd enterprise; ${workflowsRoot}/workflows/prewarm-auth.ps1 -Project '{ProjectName}'"
```

**With specific page (for testing specific features):**
```bash
powershell -Command "cd enterprise; ${workflowsRoot}/workflows/prewarm-auth.ps1 -Project 'TDNext' -SpecificPage 'http://localhost/TDDev/TDNext/Apps/274/Assets/AssetExportQRCodes.aspx?AssetIDs=1,2,3'"
```

**Examples:**
```bash
# After building TDNext
powershell -Command "cd enterprise; ${workflowsRoot}/workflows/prewarm-auth.ps1 -Project 'TDNext'"

# After building TDWorkManagement
powershell -Command "cd enterprise; ${workflowsRoot}/workflows/prewarm-auth.ps1 -Project 'TDWorkManagement'"

# With specific page
powershell -Command "cd enterprise; ${workflowsRoot}/workflows/prewarm-auth.ps1 -Project 'TDNext' -SpecificPage 'http://localhost/TDDev/TDNext/Home/Desktop'"
```

**Important:** After starting prewarm (in background), immediately continue with other tasks.

---

## Prewarming Specific Test Pages

**⚠️ BEST PRACTICE:** When working on a feature/bug, prewarm all pages you'll test for faster feedback.

### When to Use -SpecificPage
- Testing specific forms, lookups, or pages
- Debugging issues on particular URLs
- Following ticket reproduction steps

### Single Page Example
```bash
powershell -Command "cd enterprise; ${workflowsRoot}/workflows/prewarm-auth.ps1 -Project 'TDClient' -SpecificPage 'http://localhost/TDDev/TDClient/10000029/Portal/Issues/?TID=228411'"
```

### Multiple Pages Example (parallel execution)
```bash
# If feature affects multiple pages, prewarm all of them in parallel
powershell -Command "cd enterprise; ${workflowsRoot}/workflows/prewarm-auth.ps1 -Project 'TDClient' -SpecificPage 'http://localhost/TDDev/TDClient/10000029/Portal/Issues/?TID=228411'" &
powershell -Command "cd enterprise; ${workflowsRoot}/workflows/prewarm-auth.ps1 -Project 'TDNext' -SpecificPage 'http://localhost/TDDev/TDNext/Apps/627/Tickets/TicketDet?TicketID=550001'"
```

**Finding test URLs:** Check `.claude/project-docs/`, ticket descriptions, or CLAUDE.local.md
