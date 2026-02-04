# Azure DevOps Configuration

**Organization:** `tdx-eng` | **URL:** `https://dev.azure.com/tdx-eng`
**Main Project:** `enterprise` | **Repository:** `monorepo`

**Branch Strategy:**
- `develop` - Active development (all PRs target here)
- `release/12.1` - Current release branch
- Feature: `feature/{username}/{ticket-id}-{description}`

**IDs:** Repository `ccecaf19-cfa6-44c3-9bfa-68004d980b75` | Project `7bebb013-8c5a-4dc3-b080-1f9d068a5a69`

## Personal Access Token (PAT)

### Creating a PAT

1. Go to: https://dev.azure.com/tdx-eng/_usersSettings/tokens
2. Click "New Token"
3. Select organization scope: `tdx-eng` (or "All accessible organizations")
4. Select scopes based on usage:

**For Pull Requests:**
- Code (Read & Write) - Create PRs, push branches
- Work Items (Read & Write) - Link work items to PRs

**For Claude Code Feature (Codebase Access):**
- Code (Read) - Read repository files, search code

### Storing PAT Credentials

**For PR Creation:** `C:\Users\{USERNAME}\.claude\azure-devops.json`
```json
{
  "organization": "tdx-eng",
  "organizationUrl": "https://dev.azure.com/tdx-eng",
  "pat": "YOUR_PAT_HERE",
  "defaultProject": "enterprise",
  "defaultRepo": "monorepo"
}
```

**For Claude Code Feature:** `TDWorkManagement/appsettings.Development.json`
```json
"AzureDevOps": {
  "Enabled": true,
  "Organization": "tdx-eng",
  "Project": "enterprise",
  "Repository": "monorepo",
  "DefaultBranch": "release/12.1",
  "PersonalAccessToken": "YOUR_PAT_HERE",
  "EnterpriseBasePath": "enterprise",
  "ObjectsBasePath": "objects"
}
```

## REST API Endpoints

### Base URLs
- API Base: `https://dev.azure.com/tdx-eng/enterprise/_apis`
- Web Base: `https://dev.azure.com/tdx-eng/enterprise`

### Common Endpoints

**Projects:**
```
GET https://dev.azure.com/tdx-eng/_apis/projects?api-version=7.0
```

**Repository Items (List Files):**
```
GET https://dev.azure.com/tdx-eng/enterprise/_apis/git/repositories/monorepo/items?scopePath=/enterprise&recursionLevel=full&versionDescriptor.version=release/12.1&versionDescriptor.versionType=branch&api-version=7.0
```

**Read File Content:**
```
GET https://dev.azure.com/tdx-eng/enterprise/_apis/git/repositories/monorepo/items?path=/enterprise/TDNext/Login.aspx&versionDescriptor.version=release/12.1&versionDescriptor.versionType=branch&api-version=7.0
```

**Pull Requests:**
```
POST https://dev.azure.com/tdx-eng/enterprise/_apis/git/repositories/monorepo/pullrequests?api-version=7.1
```

### Authentication

All API calls use Basic authentication with PAT:

**PowerShell:**
```powershell
$pat = "YOUR_PAT_HERE"
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$pat"))
$headers = @{
    "Authorization" = "Basic $base64AuthInfo"
    "Content-Type" = "application/json"
}
Invoke-RestMethod -Uri $url -Headers $headers
```

**Bash/curl:**
```bash
curl -u ":YOUR_PAT_HERE" "https://dev.azure.com/tdx-eng/..."
```

**C# (.NET):**
```csharp
var credentials = Convert.ToBase64String(
    Encoding.ASCII.GetBytes($":{patToken}"));
httpClient.DefaultRequestHeaders.Authorization =
    new AuthenticationHeaderValue("Basic", credentials);
```

## Testing Your PAT

### Quick Test (List Projects)
```bash
curl -u ":YOUR_PAT_HERE" "https://dev.azure.com/tdx-eng/_apis/projects?api-version=7.0"
```

**Expected:** JSON response with project list (HTTP 200)
**Failure:** Empty response or HTML error (HTTP 401) - PAT is invalid or missing permissions

### Test Repository Access
```bash
curl -u ":YOUR_PAT_HERE" "https://dev.azure.com/tdx-eng/enterprise/_apis/git/repositories/monorepo/items?scopePath=/enterprise&api-version=7.0"
```

**Expected:** JSON with file listing (count: 27942+)
**Failure:** 401/403 - Missing Code (Read) permission

## Troubleshooting

### 401 Unauthorized
- PAT is expired or invalid
- PAT doesn't have required permissions
- Organization scope doesn't include `tdx-eng`
- Trailing spaces in PAT token

### 404 Not Found
- Incorrect organization name (must be `tdx-eng`, not `teamdynamix`)
- Incorrect project name (must be `enterprise`, not `TDX`)
- Repository name typo (must be `monorepo`)

### HTML Response Instead of JSON
- Usually indicates authentication failure (401)
- Check PAT token validity at: https://dev.azure.com/tdx-eng/_usersSettings/tokens
- Regenerate PAT if expired

## Web URLs

**Repository Browser:**
```
https://dev.azure.com/tdx-eng/enterprise/_git/monorepo
```

**Specific Branch:**
```
https://dev.azure.com/tdx-eng/enterprise/_git/monorepo?version=GBrelease/12.1
```

**Pull Request:**
```
https://dev.azure.com/tdx-eng/enterprise/_git/monorepo/pullrequest/{prId}
```

**File in Browser:**
```
https://dev.azure.com/tdx-eng/enterprise/_git/monorepo?path=/enterprise/TDNext/Login.aspx&version=GBrelease/12.1
```

## Related Documentation

- **PR Creation:** [pr.md](pr.md)
- **Branch Management:** [branch.md](branch.md)
- **Cherry-Pick Workflow:** [cherry-pick.md](cherry-pick.md)
