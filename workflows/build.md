# Build Instructions

**Triggers:** build, compile, rebuild, msbuild, MSBuild, dotnet build, npm run build, grunt, build.bat, build.ps1, "fix build errors"

**IMPORTANT:** Overrides base CLAUDE.md. Authoritative build documentation.

---

## MSBuild Path
```
${msbuildPath}
```

## Solution/Project Locations
- **Full solution:** `Monorepo.sln` (parent of `enterprise/`)
- **Web projects:** `enterprise/TDNext/TDNext.csproj`, `TDClient/TDClient.csproj`, etc.
- **Shared libraries:** `enterprise/../objects/TeamDynamix.Domain/TeamDynamix.Domain.csproj`, etc.
- **Work Management:** `enterprise/TDWorkManagement/TDWorkManagement.csproj`

---

## When NO MSBuild Needed (just refresh browser)
- Inline CSS in `.aspx` files (within `<style>` tags)
- Inline JavaScript in `.aspx` files (within `<script>` tags)
- `.aspx` markup/HTML only changes

**⚠️ SCSS files:** Do NOT use MSBuild. User handles SCSS compilation manually.

---

## Frontend Asset Building (Grunt)

**For TDNext/TDClient/TDAdmin LESS/CSS/JavaScript changes:**

```bash
# Works from project root or enterprise/
grunt styles  # Compile LESS → CSS, minify
grunt scripts # Uglify/minify JavaScript
```

**IMPORTANT:** Use `grunt styles` instead of targeting individual tasks - ensures all LESS is compiled consistently.

---

## Build Decision Rules

**Build FULL solution (no questions) when:**
- User says "switch branches and build" or "pull and build"
- No specific context about which app is being worked on
- User explicitly says "build the solution"

**Build SPECIFIC project only when:**
- You just made targeted changes to files in a single project
- User explicitly specifies which project to build
- Clear context that work is isolated to one application

**Examples:**
- Changed `TDClient` controller → Build only `enterprise/TDClient/TDClient.csproj`
- Changed shared `TeamDynamix.Domain` code → Build full solution (affects multiple apps)

**⚠️ Objects folder dependency:** If you build any project in `objects/`, rebuild dependent apps you're testing to get updated DLL reference.

---

## Build Commands

### Full Solution
```bash
# From project root
powershell -Command "& '${msbuildPath}' Monorepo.sln /t:Build /p:Configuration=Debug /m /v:minimal"
```
- `/m` = parallel, `/v:minimal` = errors/warnings only
- Takes 5-10min cold, 1-3min incremental
- Expected warnings: NU1701, NU1702, MSB3277, MSB3073 (safe to ignore)

### Web Forms Projects (TDNext/TDAdmin/TDClient)
```bash
# From project root - must use PowerShell wrapper
powershell -Command "& '${msbuildPath}' enterprise\TDNext\TDNext.csproj /t:Build /p:Configuration=Debug"
```
**CRITICAL:** Must wrap in `powershell -Command` - direct bash invocation strips `/t:` and `/p:` switches.

### TDWorkManagement

**⚠️ For frontend-only changes (PREFERRED - faster):**
```bash
# TypeScript: From project root
cd enterprise/TDWorkManagement && npm run builddev

# SCSS: From project root
cd enterprise/TDWorkManagement && npm run scss:compile

# Vue: From project root
cd enterprise/TDWorkManagement/VueLibrarySource && npm run builddev
```
**Do NOT use MSBuild/dotnet build for frontend-only changes** - unnecessary and slower.

**For C# changes or full rebuild:**
```bash
# From project root - touch web.config first to prevent DLL locks
powershell -Command "(Get-Item enterprise/TDWorkManagement/web.config).LastWriteTime = Get-Date; Start-Sleep -Seconds 5; dotnet build enterprise/TDWorkManagement/TDWorkManagement.csproj"
```
**Why touch web.config:** Triggers IIS recycle to release DLL locks before build.

**Auto-runs:** .csproj MSBuild targets handle Vue/TS builds (uses timestamp files to skip if unchanged).

---

## Troubleshooting

**NU1900 (NuGet auth):** Install credential provider:
```bash
powershell -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://aka.ms/install-artifacts-credprovider.ps1'))"
```

**Persistent build errors (RuntimeIdentifier, strange NuGet errors):** Clean all bin/obj folders:
```bash
# From project root - removes all build artifacts from enterprise/
Get-ChildItem -Path enterprise -Include bin,obj -Recurse -Directory | Remove-Item -Recurse -Force

# Then restore NuGet packages
powershell -Command "& '${msbuildPath}' Monorepo.sln /t:Restore"
```
**When to use:** Build errors that persist after NuGet restore, or when switching between branches with different package versions.

**Exit code 1 - IMPORTANT:** Exit code 1 does NOT always mean build failure.

**Check for actual errors first:**
```bash
... | Select-String -Pattern 'error CS|error MSB|Build FAILED|: error' -Context 2,2
```

**Real errors:** `error CS####` (compilation), `error MSB3073` (build commands), `error :` (NuGet), `Build FAILED`
**IIS warnings only (build succeeded):** Exit code 1 from `appcmd.exe` warnings, all projects show `-> ...\Project.dll`

Always search for real errors before assuming it's just IIS warnings.

**Locked DLL (w3wp.exe holds TDWorkManagement.dll):**
```bash
# Touch web.config, wait, rebuild
powershell -Command "(Get-Item enterprise\TDWorkManagement\web.config).LastWriteTime = Get-Date; Start-Sleep -Seconds 5; dotnet build enterprise\TDWorkManagement\TDWorkManagement.csproj"
```

**Force rebuild TDWorkManagement:** Delete timestamps:
```bash
del /f enterprise\TDWorkManagement\node_modules\tdworkmanagement.timestamp
del /f enterprise\TDWorkManagement\VueLibrarySource\node_modules\vuelibrarysource.timestamp
```

---

## Post-Build: Pre-warming (MANDATORY)

**⚠️ MANDATORY:** After EVERY successful **C# build** (MSBuild/dotnet build), immediately run prewarm.

**⚠️ BASH PATH HANDLING:** Bash tool strips backslashes. Use `powershell -Command` with `cd`:
```bash
powershell -Command "cd enterprise; ${workflowsRoot}/workflows/prewarm-auth.ps1 -Project 'TDWorkManagement'"
```

**When prewarm is needed:**
- After MSBuild of web projects (TDNext, TDClient, TDAdmin, TDWorkManagement)
- After `dotnet build` commands
- After full solution builds → Prewarm all apps in parallel (TDNext, TDClient, TDAdmin, TDWorkManagement)

**When prewarm is NOT needed:**
- After `npm run builddev` (TypeScript only)
- After `npm run scss:compile` (SCSS only)
- After Vue builds

**See [prewarm.md](prewarm.md) for complete details.**

Always use `run_in_background: true` and `timeout: 30000` when calling via Bash tool.

**💡 TIP:** Use `-SpecificPage` for exact test URLs. Prewarm multiple pages in parallel if feature affects them:
```bash
# Single page
powershell -Command "cd enterprise; ${workflowsRoot}/workflows/prewarm-auth.ps1 -Project 'TDClient' -SpecificPage 'http://localhost/TDDev/TDClient/path/to/page'"

# Multiple pages (run in parallel using &)
# ... -SpecificPage 'url1'" & powershell -Command "cd enterprise; ${workflowsRoot}/workflows/prewarm-auth.ps1 -Project 'TDNext' -SpecificPage 'url2'"
```

---

## Post-Build: Offer to Commit

After successful build + prewarm:

If working on feature branch (not main/develop):
- Ask: "Build and prewarm succeeded. Would you like to commit these changes?"
- If **YES** → Read `commit.md` and start commit workflow
- If **NO** → Stop

**Rationale:** Users often forget to commit after builds.
