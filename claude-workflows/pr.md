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
  "defaultProject": "TDDM",
  "defaultRepo": "enterprise"
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

5. **Create PR via Azure DevOps API:**
   ```bash
   curl -X POST \
     -H "Content-Type: application/json" \
     -H "Authorization: Basic $(echo -n :PAT | base64)" \
     "https://dev.azure.com/tdx-eng/TDDM/_apis/git/repositories/enterprise/pullrequests?api-version=7.1" \
     -d '{
       "sourceRefName": "refs/heads/BRANCH_NAME",
       "targetRefName": "refs/heads/develop",
       "title": "PR_TITLE",
       "description": "PR_DESCRIPTION"
     }'
   ```

6. **Output PR URL** for user to view

### Cherry-Pick Release PR

Same workflow as above, but:
- **Target branch:** `release/{RELEASE_VERSION}`
- **PR description:** Use cherry-pick template from `cherry-pick.md`

## API Reference

**Base URL:** `https://dev.azure.com/tdx-eng/TDDM/_apis`

**Common Operations:**
- Create PR: `POST /git/repositories/{repo}/pullrequests?api-version=7.1`
- Add comment: `POST /git/repositories/{repo}/pullrequests/{prId}/threads?api-version=7.1`
- Link work item: `PATCH /git/repositories/{repo}/pullrequests/{prId}?api-version=7.1`
- Set reviewers: Include `reviewers` array in create request

**Auth:** Basic authentication with PAT as password (empty username)

## Example: Create PR

```bash
# Read config
PAT=$(powershell -Command "& {(Get-Content C:\Users\{USERNAME}\.claude\azure-devops.json | ConvertFrom-Json).pat}")

# Get current branch
BRANCH=$(git branch --show-current)

# Create PR
curl -X POST \
  -u ":$PAT" \
  -H "Content-Type: application/json" \
  "https://dev.azure.com/tdx-eng/TDDM/_apis/git/repositories/enterprise/pullrequests?api-version=7.1" \
  -d @pr-body.json
```

## Troubleshooting

**401 Unauthorized:**
- Verify PAT is valid: https://dev.azure.com/tdx-eng/_usersSettings/tokens
- Check PAT has Code (Write) scope

**400 Bad Request:**
- Verify branch exists on remote: `git branch -r | grep BRANCH_NAME`
- Ensure branch is pushed: `git push`
- Check target branch exists

**PR URL format:**
`https://dev.azure.com/tdx-eng/TDDM/_git/enterprise/pullrequest/{prId}`
