# Web Agent Testing

Use web-agent-mcp to test TeamDynamix applications in the browser.

## Environment URLs

### TDDM
- TDNext: `http://localhost/TDDM/TDNext/`
- TDClient: `http://localhost/TDDM/TDClient/`
- TDAdmin: `http://localhost/TDDM/TDAdmin/`
- TDWorkManagement: `http://localhost/TDDM/TDWorkManagement/`

### TDDev
- TDNext: `http://localhost/TDDev/TDNext/`
- TDClient: `http://localhost/TDDev/TDClient/`
- TDAdmin: `http://localhost/TDDev/TDAdmin/`
- TDWorkManagement: `http://localhost/TDDev/TDWorkManagement/`

## Authentication

**Credentials:** Stored in `~/.config/tdx-mcp/dev-credentials.json`
- `TDX_USERNAME`: Username
- `TDX_PASSWORD`: DPAPI-encrypted password (format: `dpapi:BASE64STRING`)

**Login selectors:**
- Username: `#txtUserName`
- Password: `#txtPassword`
- Submit: `#btnSignIn`

**Login tool:**
```javascript
mcp__web-agent-mcp__login({
  usernameSelector: '#txtUserName',
  passwordSelector: '#txtPassword',
  username: 'bheard',
  password: 'dpapi:...', // From dev-credentials.json
  submitSelector: '#btnSignIn'
})
```

**Note:** Login may timeout but usually succeeds. Take a screenshot to verify.

## Basic Operations

**Navigate:**
```javascript
mcp__web-agent-mcp__navigate({
  url: 'http://localhost/TDDM/TDNext/',
  waitUntil: 'networkidle'
})
```

**Screenshot:**
```javascript
mcp__web-agent-mcp__screenshot({ filename: 'page.jpg' })
```

**Type:**
```javascript
mcp__web-agent-mcp__type({ selector: '#inputId', text: 'value' })
```

**Click:**
```javascript
mcp__web-agent-mcp__click({ selector: '#buttonId' })
```

**Execute console:**
```javascript
mcp__web-agent-mcp__execute_console({
  code: 'window.location.href'
})
```

**Query elements:**
```javascript
mcp__web-agent-mcp__query_page({
  queries: [
    { name: 'title', selector: 'h1', extract: 'text' },
    { name: 'buttons', selector: 'button', all: true }
  ]
})
```

## Common Testing Patterns

**Check computed styles:**
```javascript
mcp__web-agent-mcp__execute_console({
  code: `
    const el = document.querySelector('.selector');
    const styles = window.getComputedStyle(el);
    JSON.stringify({
      color: styles.color,
      fontSize: styles.fontSize
    }, null, 2);
  `
})
```

**Highlight element:**
```javascript
mcp__web-agent-mcp__execute_console({
  code: `
    document.querySelector('.selector').style.outline = '3px solid red';
  `
})
```

## Troubleshooting

**Element not found:** Wait after navigation/clicks
```javascript
mcp__web-agent-mcp__wait({ timeout: 3000 })
```

**Wrong environment after login:** Check `appsettings.Development.json` has correct `/TDDM/` or `/TDDev/` paths

**Changes don't appear:** Recycle app pool (touch web.config) and close/reopen browser tabs
