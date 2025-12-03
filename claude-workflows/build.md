# Build Instructions

**IMPORTANT:** Overrides base CLAUDE.md. Authoritative build documentation.

## MSBuild Path
```
C:\Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe
```

## Solution/Project File Locations
- **Full solution:** `Monorepo.sln` (in parent directory of `enterprise/`)
- **Web projects:** `enterprise/TDNext/TDNext.csproj`, `enterprise/TDClient/TDClient.csproj`, etc.
- **Shared libraries:** `enterprise/../objects/TeamDynamix.Domain/TeamDynamix.Domain.csproj`, etc.
- **Work Management:** `enterprise/TDWorkManagement/TDWorkManagement.csproj`

## Full Solution Build
```bash
# From enterprise dir - navigate to parent first (where Monorepo.sln is)
cd .. && powershell -Command "& 'C:\Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe' Monorepo.sln /t:Build /p:Configuration=Debug /m /v:minimal"
```
- `/m` = parallel, `/v:minimal` = errors/warnings only
- Takes 5-10min cold, 1-3min incremental
- Expected warnings: NU1701, NU1702, MSB3277, MSB3073 (safe to ignore)

## Build Strategy: Minimum Required Only

**IMPORTANT:** Only build the specific project(s) you modified to save time and resources.

**⚠️ When NO MSBuild is needed (just refresh browser):**
- Inline CSS in `.aspx` files (within `<style>` tags)
- Inline JavaScript in `.aspx` files (within `<script>` tags)
- `.aspx` markup/HTML changes only

**⚠️ SCSS files:** Do NOT use MSBuild for SCSS changes. User will handle SCSS compilation manually.

**🚨 ALWAYS ASK USER FIRST:** Before building, ask the user which approach they prefer:
1. Build only the specific changed project(s)
2. Build the full solution
3. No build needed (if only inline CSS/JS/markup changed)

**Exception:** If user explicitly says "build the solution", proceed directly with full solution build without asking.

**Examples:**
- Changed `TDClient` controller → Build only `TDClient\TDClient.csproj`
- Changed `TDNext` page → Build only `TDNext\TDNext.csproj`
- Changed shared `TeamDynamix.Domain` code → **Ask user** if they want full solution or just the changed project + specific app

**When full solution might be needed:**
- Changes to shared libraries (`objects/TeamDynamix.*`)
- Database schema changes (`TeamDynamixDB`)
- Unsure of dependencies

**⚠️ Objects folder dependency note:** If you build any project in `objects/`, you must rebuild any dependent project you're testing to get the updated DLL reference.

**When to build single project:**
- Changes isolated to one application (TDClient, TDNext, TDAdmin, etc.)
- UI-only changes (controllers, views, scripts)
- Shared library changes (user can specify which apps need the updated DLL)

## Web Forms Projects (TDNext/TDAdmin/TDClient)
```bash
# From enterprise dir - must use MSBuild via PowerShell (bash breaks / switches)
powershell -Command "& 'C:\Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe' TDNext\TDNext.csproj /t:Build /p:Configuration=Debug"
```
**CRITICAL:** Must wrap in `powershell -Command` with single quotes around path. Direct bash invocation strips `/t:` and `/p:` switches.

## TDWorkManagement (ASP.NET Core + TypeScript + Vue)

**⚠️ For TypeScript/SCSS changes only (PREFERRED - faster):**
```bash
# TypeScript changes: From enterprise dir
cd TDWorkManagement && npm run builddev

# SCSS changes: From enterprise dir
cd TDWorkManagement && npm run scss:compile

# Vue changes: From enterprise dir
cd TDWorkManagement\VueLibrarySource && npm run builddev
```
**Do NOT use MSBuild/dotnet build for frontend-only changes** - it's slower and unnecessary.

**For C# changes or full rebuild:**
```bash
# From enterprise dir
dotnet build TDWorkManagement\TDWorkManagement.csproj
```
**Auto-runs:** .csproj MSBuild targets handle Vue/TS builds automatically (uses timestamp files to skip if unchanged)

## Troubleshooting

**NU1900 (NuGet auth):** Install credential provider:
```bash
powershell -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://aka.ms/install-artifacts-credprovider.ps1'))"
```

**Locked files:** IIS app pools auto-stopped/started during build. If locked DLL error occurs:
```bash
# From enterprise dir - touch web.config to force IIS app pool recycle
echo. >> TDWorkManagement\web.config
# Then retry build
```

**Force rebuild TDWorkManagement:** Delete timestamps:
```bash
del /f TDWorkManagement\node_modules\tdworkmanagement.timestamp
del /f TDWorkManagement\VueLibrarySource\node_modules\vuelibrarysource.timestamp
```

## 🚨 CRITICAL: Post-Build Pre-warming 🚨

**⚠️ MANDATORY:** After EVERY successful **C# build** (MSBuild/dotnet build), immediately run: `powershell -File .claude/claude-workflows/prewarm-auth.ps1 -Project "{ProjectName}"`

**When prewarm is needed:**
- After MSBuild of web projects (TDNext, TDClient, TDAdmin, TDWorkManagement C# project)
- After `dotnet build` commands
- After full solution builds

**When prewarm is NOT needed:**
- After `npm run builddev` (TypeScript only)
- After `npm run scss:compile` (SCSS only)
- After Vue builds in VueLibrarySource

**See [prewarm.md](prewarm.md) for complete details.**

Always use `run_in_background: true` and `timeout: 30000` when calling via Bash tool. DO NOT SKIP THIS STEP.

## Prerequisites
- .NET 8.0 SDK
- Node.js LTS
- Azure Artifacts Credential Provider (see NU1900 above)
