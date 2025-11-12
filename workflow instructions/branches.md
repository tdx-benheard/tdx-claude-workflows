# Branch Naming Convention

## Pattern
```
feature/{developer}/{problemNumber}_{BriefDescription}
```

## Components
- **Prefix**: Always use `feature/` (not `problem/`)
- **Developer**: Use the developer's username (e.g., `bheard`)
- **Problem Number**: The ticket/problem ID from TeamDynamix
- **Description**: Brief CamelCase description of the work

## Examples
```
feature/bheard/29221965_FixFilterDropAccessibility
feature/bheard/29225164_FixModalScrollReset
```

## How to Create a Branch
**IMPORTANT**: Ensure develop has the latest changes before branching from it.

When the user provides a problem number, follow these steps:
```bash
# 1. Switch to develop branch
git checkout develop

# 2. Pull the latest changes to update develop
git pull

# 3. Create the new feature branch from develop
git checkout -b feature/{developer}/{problemNumber}_{Description}
```

**Note**: Git will prevent you from switching branches if you have uncommitted changes that would conflict. Your work is safe - either commit changes first or use `git stash` to temporarily save them.

## Notes
- Always use `feature/` prefix, even for bug fixes
- Description should be concise and in CamelCase
- Problem number comes directly from the user or ticket system
- Update develop before creating the branch, but you don't need to stay on develop after
