# Build Instructions

**IMPORTANT:** These instructions override any build guidance in the base `CLAUDE.md` file. This is the authoritative build documentation for this project.

## Overview

This guide provides command-line build instructions for building individual projects in the enterprise solution. The preferred approach is to build specific projects directly using `dotnet build` or MSBuild rather than using `build.bat` for the entire solution.

## General Project Build Pattern

To build any project in the solution:

```bash
# From the enterprise directory
dotnet build [ProjectName]\[ProjectName].csproj

# Examples:
dotnet build TDAdmin\TDAdmin.csproj
dotnet build TDNext\TDNext.csproj
dotnet build TDWebApi\TDWebApi.csproj
```

---

## TDWorkManagement Build Instructions

TDWorkManagement is an ASP.NET Core project with additional frontend build steps (TypeScript + Vue).

## Quick Reference

```bash
# Build everything (C# + TypeScript + Vue)
dotnet build TDWorkManagement\TDWorkManagement.csproj

# Build just TypeScript (development mode)
cd TDWorkManagement && npm run builddev

# Build just Vue components (development mode)
cd TDWorkManagement\VueLibrarySource && npm run builddev

# Build styles
cd TDWorkManagement && npm run scss:compile
```

---

## C# Build (TDWorkManagement.csproj)

### Using dotnet build

The recommended way to build TDWorkManagement from the command line:

```bash
# From enterprise directory - Build in Debug mode
dotnet build TDWorkManagement\TDWorkManagement.csproj

# Build in Release mode
dotnet build TDWorkManagement\TDWorkManagement.csproj --configuration Release
```

### What Happens Automatically

The `.csproj` file includes MSBuild targets that run **before** the C# compilation:

1. **VueLibrarySourceInstallAndBuild** - Builds Vue components
   - Runs `npm i` in `VueLibrarySource/`
   - Runs `npm run builddev` (Debug) or `npm run build` (Release)

2. **TDWorkManagementInstallAndBuild** - Builds TypeScript
   - Runs `npm install` in root TDWorkManagement directory
   - Runs `npm run builddev` (Debug) or `npm run build` (Release)

### Build Optimization

The MSBuild targets use timestamp files to skip rebuilding if sources haven't changed:
- `VueLibrarySource/node_modules/vuelibrarysource.timestamp`
- `node_modules/tdworkmanagement.timestamp`

To force a rebuild, delete these timestamp files.

---

## VueLibrarySource Build (Manual)

If you need to build **just** the Vue components separately:

```bash
# From enterprise directory
cd TDWorkManagement\VueLibrarySource

# Install dependencies (first time or after package.json changes)
npm install

# Development build (with source maps, faster)
npm run builddev

# Production build (minified, optimized)
npm run build

# Watch mode (auto-rebuild on file changes)
npm run watch
```

### Details

- **Build Tool:** Vite
- **Source:** `VueLibrarySource/src/` directory
- **Output:** `wwwroot/vue-library/` directory
- **Config:** `vite.config.ts`

---

## TypeScript Build (Manual)

If you need to build **just** the TypeScript files separately:

```bash
# From enterprise directory
cd TDWorkManagement

# Install dependencies (first time or after package.json changes)
npm install

# Development build (with source maps, faster)
npm run builddev

# Production build (minified, optimized)
npm run build

# Watch mode (auto-rebuild on file changes)
npm run watch

# Type checking only (no output files)
npm run tsc
```

### Details

- **Build Tool:** Webpack with ts-loader
- **Source:** `TypeScripts/` directory
- **TypeScript Config:** `TypeScripts/tsconfig.json`
- **Webpack Configs:**
  - Production: `TypeScripts/webpack.config.cjs`
  - Development: `TypeScripts/webpack.config.development.cjs`
  - JavaScript: `JavaScripts/webpack.config.cjs` and `JavaScripts/webpack.config.development.cjs`

### Important Note

The `.csproj` has `<TypeScriptCompileBlocked>true</TypeScriptCompileBlocked>`, meaning MSBuild won't compile TypeScript automatically. It relies on the Webpack builds instead.

---

## SCSS/CSS Build (Manual)

If you need to rebuild styles separately:

```bash
# From enterprise directory
cd TDWorkManagement

# Compile all styles (expanded + minified versions)
npm run scss:compile

# Compile with watch mode (auto-rebuild on changes)
npm run scss:watch

# Compile all style variations
npm run scss:compile:all
```

### Details

- **Compiler:** Dart Sass
- **Source:** `wwwroot/styles/` directory
- **Note:** Deprecation warnings are silenced in the compile scripts

---

## Recommended Build Order (Full Manual Build)

If you're building everything manually from scratch:

```bash
# From enterprise directory
cd TDWorkManagement

# 1. Install dependencies for main project
npm install

# 2. Install dependencies for Vue library
cd VueLibrarySource
npm install
cd ..

# 3. Build Vue library (development)
cd VueLibrarySource
npm run builddev
cd ..

# 4. Build TypeScript (development)
npm run builddev

# 5. Build SCSS (optional - if styles changed)
npm run scss:compile

# 6. Build C# project
cd ..
dotnet build TDWorkManagement\TDWorkManagement.csproj
```

**Note:** Step 6 will also trigger Vue and TypeScript builds via MSBuild targets if timestamp files indicate changes.

---

## Key Files Reference

| File | Purpose |
|------|---------|
| `TDWorkManagement.csproj` | C# project with MSBuild targets |
| `package.json` | TypeScript/JavaScript/SCSS build scripts |
| `VueLibrarySource/package.json` | Vue component build scripts |
| `TypeScripts/tsconfig.json` | TypeScript compiler configuration |
| `TypeScripts/webpack.config.cjs` | Webpack config for production TypeScript |
| `TypeScripts/webpack.config.development.cjs` | Webpack config for development TypeScript |
| `VueLibrarySource/vite.config.ts` | Vite config for Vue components |

---

## Important Notes

### IIS App Pool Management

The project includes PreBuild and PostBuild events in Debug mode that manage IIS app pools:

**PreBuild:** Stops these app pools:
- TDWorkManagement
- TDWorkManagement_TDDev
- TDWorkManagement_TDMaint

**PostBuild:** Starts these app pools again.

This prevents file locking issues during builds. If the build fails, you may need to manually start the app pools.

### Dependencies

The project also builds `tdx-dashboards` (via `TdxDashboards.targets`) before the main build.

### Build Configuration

- **Debug mode:** Uses `builddev` npm scripts (faster, includes source maps)
- **Release mode:** Uses `build` npm scripts (minified, optimized)

---

## Troubleshooting

### "npm command not found"

Ensure Node.js is installed and in your PATH.

### "dotnet command not found"

Ensure .NET SDK is installed and in your PATH.

### Azure DevOps NuGet Authentication Errors (NU1900)

**Error:**
```
error NU1900: Warning As Error: Error occurred while getting package vulnerability data:
Unable to load the service index for source https://pkgs.dev.azure.com/tdx-eng/teamdynamix/_packaging/teamdynamix/nuget/v3/index.json.
```

**Cause:** Missing or expired Azure Artifacts Credential Provider for authenticating to Azure DevOps NuGet feeds.

**Solution:** Install the Azure Artifacts Credential Provider:

```bash
# Install credential provider (PowerShell)
powershell -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://aka.ms/install-artifacts-credprovider.ps1'))"

# Then retry the build
dotnet build "TDWorkManagement/TDWorkManagement.csproj" --configuration Debug --no-restore
```

**Alternative Solutions:**

1. **Use Visual Studio** - VS has its own credential provider already configured
2. **Authenticate interactively:**
   ```bash
   dotnet restore TDWorkManagement/TDWorkManagement.csproj --interactive
   ```
3. **Use Azure CLI:**
   ```bash
   az login
   ```
4. **Use Personal Access Token (PAT):**
   ```bash
   dotnet nuget update source teamdynamix --username "any" --password "YOUR_PAT" --store-password-in-clear-text
   ```

### Files are locked during build

If IIS Express is running, the PostBuild event should handle this. If not:
```bash
# Stop IIS Express manually
iisreset /stop
```

### Timestamp files causing issues

Delete timestamp files to force rebuild:
```bash
cd TDWorkManagement
del /f node_modules\tdworkmanagement.timestamp
del /f VueLibrarySource\node_modules\vuelibrarysource.timestamp
```

### TypeScript errors but project still builds

MSBuild ignores TypeScript compiler errors by default. Check npm output for actual errors:
```bash
cd TDWorkManagement
npm run tsc
```

---

## Prerequisites

### Required Software

- **.NET 8.0 SDK** - For building ASP.NET Core applications
- **Node.js** (LTS version) - For npm/TypeScript/Vue builds
- **Azure Artifacts Credential Provider** - For Azure DevOps NuGet feed authentication

### First-Time Setup

If this is your first time building TDWorkManagement from command line:

1. **Install Azure Artifacts Credential Provider:**
   ```bash
   powershell -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://aka.ms/install-artifacts-credprovider.ps1'))"
   ```

2. **Verify NuGet sources:**
   ```bash
   dotnet nuget list source
   ```
   Should show `teamdynamix` source pointing to Azure DevOps

3. **Install npm dependencies:**
   ```bash
   cd TDWorkManagement
   npm install
   cd VueLibrarySource
   npm install
   cd ../..
   ```

4. **Build the project:**
   ```bash
   dotnet build "TDWorkManagement/TDWorkManagement.csproj" --configuration Debug
   ```
