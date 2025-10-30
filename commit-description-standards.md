# Commit Description Standards

## Required Format

Every commit message MUST include the item type and number at the very end of the entire commit message (not on the first line):

```
Item type #Item number
```

Note: Do NOT use square brackets around the item type.

## Examples

```
Fix accessibility issues in filter dropdown

Update the dropdown component to properly handle keyboard navigation
and screen reader announcements for improved accessibility.

Problem #29221965
```

```
Update modal scroll behavior to reset on open

Ensure modals always open scrolled to the top instead of remembering
previous scroll position.

Problem #29225164
```

```
Add user authentication endpoint

Feature #29180234
```

## Item Types

Common item types include:
- `Problem` - Bug fixes and issues
- `Feature` - New functionality
- `Enhancement` - Improvements to existing features
- `Task` - General development tasks

## Best Practices

- Write clear, concise commit messages in imperative mood
- Include the item reference at the very end of the entire commit message
- Keep the first line under 72 characters when possible
- Add additional details in the body if needed
- Do NOT use square brackets around the item type

## Template

```
Brief description of what was done

Optional: More detailed explanation of the changes,
why they were made, and any important context.

Type #Number
```
