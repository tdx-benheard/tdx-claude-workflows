# Pull Request Creation

## Azure DevOps REST API

Pull requests can be created using the Azure DevOps REST API with stored credentials.

### Configuration

**PAT Location:** `C:\Users\{USERNAME}\.claude\azure-devops.json`

```json
{
  "organization": "tdx-eng",
  "organizationUrl": "https://dev.azure.com/tdx-eng",
  "pat": "YOUR_PAT_HERE",
  "defaultProject": "enterprise",
  "defaultRepo": "monorepo"
}
```

**Required PAT Scopes:**
- Code (Read & Write) - For branches and PRs
- Work Items (Read & Write) - For linking work items

**Creating a PAT:** https://dev.azure.com/tdx-eng/_usersSettings/tokens

## PR Creation Workflow

### Standard Feature Branch PR

1. **Verify commit is pushed**
   ```bash
   git status  # Should show "up to date with origin"
   ```

2. **Gather PR details:**
   - Current branch name (extract ticket ID)
   - Target branch (usually `develop`)
   - Commit history for PR description
   ```bash
   git log --format="%h - %s" origin/develop..HEAD
   ```

3. **Draft PR description:**
   ```
   [Type] #[ID] - [Title]

   ## Summary
   - [Change 1]
   - [Change 2]
   - [Change 3]

   ## Test Plan
   - [ ] [Testing step 1]
   - [ ] [Testing step 2]
   ```

4. **Get user approval** - Show PR title and description, ask to proceed

5. **Create PR via Azure DevOps API (PowerShell - RECOMMENDED):**

   **Note:** PowerShell with `Invoke-RestMethod` is the most reliable method on Windows. Avoid bash/curl due to quoting/escaping issues.

   Create a temporary PowerShell script:
   ```powershell
   $prBody = @"
   {
     "sourceRefName": "refs/heads/BRANCH_NAME",
     "targetRefName": "refs/heads/develop",
     "title": "PR_TITLE",
     "description": "PR_DESCRIPTION"
   }
   "@

   $config = Get-Content C:\Users\{USERNAME}\.claude\azure-devops.json | ConvertFrom-Json

   $response = Invoke-RestMethod -Uri "https://dev.azure.com/tdx-eng/enterprise/_apis/git/repositories/monorepo/pullrequests?api-version=7.1" `
     -Method Post `
     -Headers @{
       "Authorization" = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($config.pat)"))
       "Content-Type" = "application/json"
     } `
     -Body $prBody

   $response | ConvertTo-Json
   ```

   Then execute:
   ```bash
   powershell -File create-pr.ps1
   rm create-pr.ps1
   ```

6. **Output PR URL** for user to view

   Format: `https://dev.azure.com/tdx-eng/enterprise/_git/monorepo/pullrequest/{prId}`

### Cherry-Pick Release PR

Same workflow as above, but:
- **Target branch:** `release/{RELEASE_VERSION}`
- **PR description:** Use cherry-pick template from `cherry-pick.md`

## API Reference

**Base URL:** `https://dev.azure.com/tdx-eng/enterprise/_apis`

**Repository Info:**
- Project: `enterprise`
- Repository: `monorepo`

**Common Operations:**
- Create PR: `POST /git/repositories/monorepo/pullrequests?api-version=7.1`
- Add comment: `POST /git/repositories/monorepo/pullrequests/{prId}/threads?api-version=7.1`
- Link work item: `PATCH /git/repositories/monorepo/pullrequests/{prId}?api-version=7.1`
- Set reviewers: Include `reviewers` array in create request

**Auth:** Basic authentication with PAT as password (empty username)

## Complete Working Example

```powershell
# create-pr.ps1
$branch = git branch --show-current

$prBody = @"
{
  "sourceRefName": "refs/heads/$branch",
  "targetRefName": "refs/heads/develop",
  "title": "Problem #12345 - Your PR title here",
  "description": "Problem #12345 - Your PR title\n\n## Summary\n- Change 1\n- Change 2\n\n## Test Plan\n- [ ] Test 1\n- [ ] Test 2"
}
"@

$config = Get-Content C:\Users\ben.heard\.claude\azure-devops.json | ConvertFrom-Json

$response = Invoke-RestMethod -Uri "https://dev.azure.com/tdx-eng/enterprise/_apis/git/repositories/monorepo/pullrequests?api-version=7.1" `
  -Method Post `
  -Headers @{
    "Authorization" = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($config.pat)"))
    "Content-Type" = "application/json"
  } `
  -Body $prBody

Write-Host "PR Created: https://dev.azure.com/tdx-eng/enterprise/_git/monorepo/pullrequest/$($response.pullRequestId)"
$response | ConvertTo-Json
```

Execute with:
```bash
powershell -File create-pr.ps1
rm create-pr.ps1
```

## Troubleshooting

**401 Unauthorized:**
- Verify PAT is valid: https://dev.azure.com/tdx-eng/_usersSettings/tokens
- Check PAT has Code (Write) scope

**400 Bad Request:**
- Verify branch exists on remote: `git branch -r | grep BRANCH_NAME`
- Ensure branch is pushed: `git push`
- Check target branch exists

**Bash/curl quoting errors:**
- **Do not use bash with curl** for PR creation on Windows - escaping is unreliable
- Use the PowerShell approach above instead

**PR URL format:**
`https://dev.azure.com/tdx-eng/enterprise/_git/monorepo/pullrequest/{prId}`
