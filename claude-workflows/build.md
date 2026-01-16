# Build Instructions

**Triggers:** build, compile, rebuild, msbuild, MSBuild, dotnet build, npm run build, grunt, build.bat, build.ps1, "fix build errors"

**IMPORTANT:** Overrides base CLAUDE.md. Authoritative build documentation.

---

## MSBuild Path
```
C:\Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe
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
- Changed `TDClient` controller → Build only `TDClient\TDClient.csproj`
- Changed shared `TeamDynamix.Domain` code → Build full solution (affects multiple apps)

**⚠️ Objects folder dependency:** If you build any project in `objects/`, rebuild dependent apps you're testing to get updated DLL reference.

---

## Build Commands

### Full Solution
```bash
# From enterprise dir - navigate to parent first
cd .. && powershell -Command "& 'C:\Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe' Monorepo.sln /t:Build /p:Configuration=Debug /m /v:minimal"
```
- `/m` = parallel, `/v:minimal` = errors/warnings only
- Takes 5-10min cold, 1-3min incremental
- Expected warnings: NU1701, NU1702, MSB3277, MSB3073 (safe to ignore)

### Web Forms Projects (TDNext/TDAdmin/TDClient)
```bash
# From enterprise dir - must use PowerShell wrapper
powershell -Command "& 'C:\Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe' TDNext\TDNext.csproj /t:Build /p:Configuration=Debug"
```
**CRITICAL:** Must wrap in `powershell -Command` - direct bash invocation strips `/t:` and `/p:` switches.

### TDWorkManagement

**⚠️ For frontend-only changes (PREFERRED - faster):**
```bash
# TypeScript: From enterprise dir
cd TDWorkManagement && npm run builddev

# SCSS: From enterprise dir
cd TDWorkManagement && npm run scss:compile

# Vue: From enterprise dir
cd TDWorkManagement\VueLibrarySource && npm run builddev
```
**Do NOT use MSBuild/dotnet build for frontend-only changes** - unnecessary and slower.

**For C# changes or full rebuild:**
```bash
# From enterprise dir - touch web.config first to prevent DLL locks
powershell -Command "(Get-Item TDWorkManagement/web.config).LastWriteTime = Get-Date; Start-Sleep -Seconds 5; dotnet build TDWorkManagement/TDWorkManagement.csproj"
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
# From enterprise dir - removes all build artifacts
Get-ChildItem -Path . -Include bin,obj -Recurse -Directory | Remove-Item -Recurse -Force

# Then restore NuGet packages
cd .. && powershell -Command "& 'C:\Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe' Monorepo.sln /t:Restore"
```
**When to use:** Build errors that persist after NuGet restore, or when switching between branches with different package versions.

**Exit code 1 but build succeeds:** Check actual compilation output, not just exit code. Exit code 1 can occur when:
- Post-build IIS app pool restart fails (permissions on `redirection.config`)
- MSB3073 warnings about appcmd.exe
- All projects show successful compilation (`-> C:\source\TDDev\...\Project.dll`)

**Locked DLL (w3wp.exe holds TDWorkManagement.dll):**
```bash
# Touch web.config, wait, rebuild
powershell -Command "(Get-Item TDWorkManagement\web.config).LastWriteTime = Get-Date; Start-Sleep -Seconds 5; dotnet build TDWorkManagement\TDWorkManagement.csproj"
```

**Force rebuild TDWorkManagement:** Delete timestamps:
```bash
del /f TDWorkManagement\node_modules\tdworkmanagement.timestamp
del /f TDWorkManagement\VueLibrarySource\node_modules\vuelibrarysource.timestamp
```

---

## Post-Build: Pre-warming (MANDATORY)

**⚠️ MANDATORY:** After EVERY successful **C# build** (MSBuild/dotnet build), immediately run prewarm.

**⚠️ BASH PATH HANDLING:** Bash tool strips backslashes. Use `powershell -Command` with `cd`:
```bash
powershell -Command "cd C:\source\TDDev\enterprise; C:\Users\ben.heard\.claude\claude-workflow\claude-workflows\prewarm-auth.ps1 -Project 'TDWorkManagement'"
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

---

## Post-Build: Offer to Commit

After successful build + prewarm:

If working on feature branch (not main/develop):
- Ask: "Build and prewarm succeeded. Would you like to commit these changes?"
- If **YES** → Read `commit.md` and start commit workflow
- If **NO** → Stop

**Rationale:** Users often forget to commit after builds.
