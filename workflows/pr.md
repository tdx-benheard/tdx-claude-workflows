# Pull Request Creation

**Triggers:** "create pr", "make pr", "pull request", pr, "open pr"

---

## Pre-Requisites

Verify these before starting:

1. **Branch Pushed to Remote**
   - Check: `git status` shows "Your branch is up to date with 'origin/<branch>'"
   - If NOT: Ask "Should I push it now?" → `git push origin <branch>`

2. **Commits Complete**
   - If uncertain: Ask "Have you committed all changes?"
   - If NO: Offer to run commit workflow (see commit.md)

3. **Build Succeeded** (for code changes)
   - Ask: "Did the build succeed and prewarm complete?"
   - If NO/UNCERTAIN: Recommend running build workflow (see build.md)

---

## Azure DevOps API Setup

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
- Code (Read & Write) - Branches and PRs
- Work Items (Read & Write) - Linking work items

**Create PAT:** https://dev.azure.com/tdx-eng/_usersSettings/tokens

---

## PR Creation Workflow

### 1. Verify & Gather Info
```bash
git status  # Should show "up to date with origin"
git log --format="%h - %s" origin/develop..HEAD  # Commits for PR
```

### 2. Draft PR Description
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

**Cherry-Pick PRs:** Use cherry-pick template from `cherry-pick.md`

### 3. Get User Approval
Show PR title and description, ask to proceed

### 4. Create PR via PowerShell

**Use PowerShell** (most reliable on Windows - avoid bash/curl due to escaping issues)

Create temporary script:
```powershell
# create-pr.ps1
$branch = git branch --show-current
$targetBranch = "develop"  # or "release/{RELEASE_VERSION}" for cherry-picks

$prBody = @"
{
  "sourceRefName": "refs/heads/$branch",
  "targetRefName": "refs/heads/$targetBranch",
  "title": "Problem #12345 - Your PR title",
  "description": "Problem #12345 - Title\n\n## Summary\n- Change 1\n\n## Test Plan\n- [ ] Test 1"
}
"@

$config = Get-Content C:\Users\{USERNAME}\.claude\azure-devops.json | ConvertFrom-Json

$response = Invoke-RestMethod `
  -Uri "https://dev.azure.com/tdx-eng/enterprise/_apis/git/repositories/monorepo/pullrequests?api-version=7.1" `
  -Method Post `
  -Headers @{
    "Authorization" = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($config.pat)"))
    "Content-Type" = "application/json"
  } `
  -Body $prBody

Write-Host "PR Created: https://dev.azure.com/tdx-eng/enterprise/_git/monorepo/pullrequest/$($response.pullRequestId)"
```

Execute:
```bash
powershell -File create-pr.ps1
rm create-pr.ps1
```

### 5. Output PR URL
Format: `https://dev.azure.com/tdx-eng/enterprise/_git/monorepo/pullrequest/{prId}`

---

## API Reference

**Base URL:** `https://dev.azure.com/tdx-eng/enterprise/_apis`

**Repository:** enterprise/monorepo

**Operations:**
- Create PR: `POST /git/repositories/monorepo/pullrequests?api-version=7.1`
- Add comment: `POST /git/repositories/monorepo/pullrequests/{prId}/threads?api-version=7.1`
- Link work item: `PATCH /git/repositories/monorepo/pullrequests/{prId}?api-version=7.1`

**Auth:** Basic auth with PAT as password (empty username)

---

## Troubleshooting

**401 Unauthorized:**
- Verify PAT: https://dev.azure.com/tdx-eng/_usersSettings/tokens
- Check PAT has Code (Write) scope

**400 Bad Request:**
- Verify branch exists: `git branch -r | grep BRANCH_NAME`
- Ensure pushed: `git push`
- Check target branch exists

**Bash/curl errors:**
- Don't use bash with curl on Windows - use PowerShell approach above
