# Post-Build Pre-warming

**Problem:** After building, first request to each app is slow due to ASP.NET compilation and application initialization.

**Solution:** Pre-warm applications by hitting key endpoints to trigger compilation and startup.

## Pre-warming Instructions for Claude Code

**After building any web project with C# changes (MSBuild/dotnet build), automatically run pre-warm for that project:**

**⚠️ IMPORTANT:** Only run prewarm after **C# builds** (MSBuild/dotnet build). Do NOT run after frontend-only builds (npm run builddev, npm run scss:compile, Vue builds).

### Project Mapping:
- Built **TDNext** → Prewarm TDNext (automatically also prewarms TDWorkManagement)
- Built **TDClient** → Prewarm TDClient
- Built **TDAdmin** → Prewarm TDAdmin
- Built **TDWorkManagement** → Prewarm TDWorkManagement
- Built **full solution** → Prewarm TDNext (which includes TDWorkManagement)

### Specific Page Prewarming:
**⚠️ IMPORTANT:** If working on a specific page/feature, pass the full URL to `-SpecificPage` parameter:
- Example: `powershell -File .claude/prewarm-auth.ps1 -Project "TDNext" -SpecificPage "http://localhost/TDDev/TDNext/Apps/274/Assets/AssetExportQRCodes.aspx?AssetIDs=1,2,3"`
- This ensures the specific page is compiled and ready for immediate testing

## 🚨 EXECUTION REQUIREMENTS 🚨

**CRITICAL RULES:**
1. **Use prewarm-auth.ps1 script** - Handles authentication automatically
2. **Background Execution:** ALWAYS run with `run_in_background: true` parameter in Bash tool
3. **30-Second Timeout:** Use `timeout: 30000` in Bash tool
4. **Non-Blocking:** Do NOT wait for prewarm to complete - proceed with other tasks immediately

**Command Format:**
```bash
powershell -File .claude/prewarm-auth.ps1 -Project "{ProjectName}" [-SpecificPage "{FullURL}"]
```

**Examples:**
```bash
# After building TDNext
powershell -File .claude/prewarm-auth.ps1 -Project "TDNext"

# After building TDClient
powershell -File .claude/prewarm-auth.ps1 -Project "TDClient"

# After building TDAdmin
powershell -File .claude/prewarm-auth.ps1 -Project "TDAdmin"

# After building TDWorkManagement
powershell -File .claude/prewarm-auth.ps1 -Project "TDWorkManagement"

# With specific page you're working on
powershell -File .claude/prewarm-auth.ps1 -Project "TDNext" -SpecificPage "http://localhost/TDDev/TDNext/Apps/274/Assets/AssetExportQRCodes.aspx?AssetIDs=7874,7726,6600"
```

**Important:** After starting the prewarm (in background), immediately continue with other tasks. Do not check status or wait for completion.

## Endpoint Reference

**Local URLs:** All apps under `http://localhost/TDDev/`

**TDNext:**
- `http://localhost/TDDev/TDNext/`
- `http://localhost/TDDev/TDNext/Home/Desktop`

**TDClient:**
- `http://localhost/TDDev/TDClient/`
- `http://localhost/TDDev/TDClient/Home/Desktop`

**TDAdmin:**
- `http://localhost/TDDev/TDAdmin/`

**TDWorkManagement:**
- `http://localhost/TDDev/TDWorkManagement/`
- `http://localhost/TDDev/TDWorkManagement/Home/Index`
