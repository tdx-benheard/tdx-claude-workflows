# Web Agent Testing Workflow

This document describes how to use the web-agent-mcp tool to test TeamDynamix applications in local development environments.

## Prerequisites

- web-agent-mcp MCP server installed and configured (see `C:\Users\ben.heard\.claude\MCP-SETUP.md`)
- Playwright browsers installed (`npx playwright install` in `C:\source\MCP\web-agent-mcp`)
- Development credentials stored in `C:\Users\ben.heard\.config\tdx-mcp\dev-credentials.json`

## Development Environment URLs

### TDDM Environment
- **Repository**: `C:\source\TDDM\enterprise`
- **Base URL**: `http://localhost/TDDM/`
- **Applications**:
  - TDNext: `http://localhost/TDDM/TDNext/`
  - TDClient: `http://localhost/TDDM/TDClient/`
  - TDAdmin: `http://localhost/TDDM/TDAdmin/`
  - TDWorkManagement: `http://localhost/TDDM/TDWorkManagement/`

### TDDev Environment
- **Repository**: `C:\source\TDDev\enterprise`
- **Base URL**: `http://localhost/TDDev/`
- **Applications**: Same structure as TDDM

## Authentication

### Credentials Location

Development credentials are stored in:
```
C:\Users\ben.heard\.config\tdx-mcp\dev-credentials.json
```

Contains:
- `TDX_USERNAME`: Username for local development
- `TDX_PASSWORD`: DPAPI-encrypted password (format: `dpapi:BASE64STRING`)

### Login Form Selectors

- **Username field**: `#txtUserName`
- **Password field**: `#txtPassword`
- **Submit button**: `#btnSignIn`

### Web Agent Login Tool

```javascript
await mcp__web-agent-mcp__login({
  usernameSelector: '#txtUserName',
  passwordSelector: '#txtPassword',
  username: 'bheard',
  password: 'dpapi:AQAAANCMnd8BFdERjHoAwE/Cl+sBAAAA...',  // From dev-credentials.json
  submitSelector: '#btnSignIn'
});
```

**Security Note**: The `dpapi:` prefix indicates Windows DPAPI encryption. The password is automatically decrypted by the web-agent-mcp tool and never exposed in logs.

### Login Workflow

1. **Navigate to any protected page** - The app will redirect to login if not authenticated
2. **Use the login tool** - Provides credentials and form selectors
3. **Wait for redirect** - After successful login, the app redirects to the requested page
4. **Check authentication** - Use `window.location.href` to verify you're on the correct page

### Known Issue: Login Timeout

The login tool may timeout waiting for navigation to complete, but the login usually succeeds anyway. If timeout occurs:
1. Take a screenshot to verify the page loaded
2. Check `window.location.href` to confirm authentication succeeded
3. Navigate to the desired URL if needed

## Basic Web Agent Operations

### Navigate to URL

```javascript
await mcp__web-agent-mcp__navigate({
  url: 'http://localhost/TDDM/TDNext/',
  waitUntil: 'networkidle'  // or 'load', 'domcontentloaded'
});
```

### Take Screenshot

```javascript
// Default: 800px JPEG (preferred for context)
await mcp__web-agent-mcp__screenshot({
  filename: 'page-name.jpg'
});

// High resolution (only when needed)
await mcp__web-agent-mcp__screenshot({
  filename: 'design.jpg',
  hiRes: true
});
```

### Query Page Elements

```javascript
await mcp__web-agent-mcp__query_page({
  queries: [
    { name: 'element1', selector: '#elementId' },
    { name: 'element2', selector: '.className', extract: 'text' },
    { name: 'allButtons', selector: 'button', all: true }
  ]
});
```

### Type Into Input

```javascript
await mcp__web-agent-mcp__type({
  selector: '#inputField',
  text: 'some text'
});
```

### Click Element

```javascript
await mcp__web-agent-mcp__click({
  selector: '#buttonId'
});
```

### Execute Console Code

```javascript
await mcp__web-agent-mcp__execute_console({
  code: 'window.location.href'
});
```

## Troubleshooting

### Playwright Browsers Not Installed

**Symptom**: Error message about missing browser executables

**Fix**: Run `npx playwright install` in `C:\source\MCP\web-agent-mcp`

### Login Redirects to Wrong Environment

**Symptom**: After login, redirected to `/TDDev/` instead of `/TDDM/` (or vice versa)

**Cause**: Application `appsettings.Development.json` or `web.config` has incorrect virtual directory paths

**Fix**: See `CLAUDE.local.md` section on "Web Config Virtual Directory Path"

### Changes Don't Appear After Build

**Symptom**: Code changes don't reflect in the browser

**Fix**:
1. Recycle app pool: Touch `web.config` or restart IIS
2. Close browser tabs completely and reopen (tabs cache URLs)
3. Hard refresh: Ctrl+Shift+R

## Reference Documentation

- **Web agent documentation**: `C:\source\MCP\web-agent-mcp\CLAUDE.md`
- **Dev credentials**: `C:\Users\ben.heard\.config\tdx-mcp\dev-credentials.json`
- **MCP setup guide**: `C:\Users\ben.heard\.claude\MCP-SETUP.md`
- **Project instructions**: `CLAUDE.md` and `CLAUDE.local.md` in project root
