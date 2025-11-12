# iFrameScrollMemory Splice Bug

**Status:** Pre-existing bug (not introduced in current work)
**Severity:** Medium
**Introduced:** April 30, 2025 by commit e755a2c5bef (Problem #27717341)
**File:** `TDWorkManagement/TypeScripts/MainContentManager.ts`
**Line:** 869

## Summary

The `iFrameScrollMemory.splice()` call has incorrect syntax - it's missing the second parameter (deleteCount), causing it to delete multiple array entries instead of just one.

## The Bug

### Current (Buggy) Code:
```typescript
// Line 869
this.iFrameScrollMemory.splice(this.iFrameScrollMemory.findIndex(offsetMemory => offsetMemory.tabId === this.activeTabId, 1));
```

### Problems:
1. **The `, 1` is passed to `findIndex()` as the `thisArg` parameter** (which does nothing useful)
2. **`splice()` is called with only ONE argument** (the index), missing the `deleteCount` parameter
3. When `splice(index)` is called without a second parameter, it deletes **everything from that index to the end of the array**

### Correct Syntax:
```typescript
// Option 1: Store index first (recommended for clarity)
const index = this.iFrameScrollMemory.findIndex(offsetMemory => offsetMemory.tabId === this.activeTabId);
if (index >= 0) {
  this.iFrameScrollMemory.splice(index, 1);
}

// Option 2: Inline (fix the parentheses)
this.iFrameScrollMemory.splice(
  this.iFrameScrollMemory.findIndex(offsetMemory => offsetMemory.tabId === this.activeTabId),
  1  // <-- Move the ", 1" HERE (outside findIndex, inside splice)
);
```

## Impact

### What Should Happen:
When switching from Tab A to Tab B:
1. Remove Tab A's old scroll position entry from the array
2. Add Tab A's current scroll position to the array
3. Switch to Tab B and restore its scroll position

### What Actually Happens:
```javascript
// Example:
iFrameScrollMemory = [
  {tabId: "home", offset: 0},
  {tabId: "tickets", offset: 200},  // User switches FROM this tab
  {tabId: "assets", offset: 300}
]

// Buggy code does: splice(1)
// Result: [{tabId: "home", offset: 0}]
// Lost BOTH "tickets" and "assets" entries!
```

### User-Visible Impact:
- **Intermittent loss of scroll positions** when switching between tabs
- More noticeable when user has 3+ tabs open
- Tabs that come "after" the tab you're leaving lose their scroll position
- When you return to those tabs, they scroll to the top instead of their saved position

## Why It Hasn't Been Noticed

The bug has subtle impact because:
1. Users typically switch between 2-3 tabs repeatedly (the last tab in the array isn't affected)
2. Scroll positions get rebuilt as you revisit tabs
3. The behavior might be attributed to "normal" iframe behavior rather than a bug
4. The bug only affects tabs that come "after" the one you're leaving in array order

## How to Reproduce

1. Open Work Management
2. Open 4+ tabs (e.g., Home, Tickets, Assets, Projects)
3. Scroll down in each tab
4. Switch FROM the "Tickets" tab (second in the list) to another tab
5. Try switching to "Assets" or "Projects"
6. **Expected:** Should restore to previous scroll position
7. **Actual:** Scrolls to top (scroll position was lost)

## Recommendation

**Fix Priority:** Medium
**Rationale:** Pre-existing bug with subtle impact, but causes intermittent UX issues

**Suggested Fix:**
```typescript
// Remove existing memory index if it exists
const existingIndex = this.iFrameScrollMemory.findIndex(offsetMemory => offsetMemory.tabId === this.activeTabId);
if (existingIndex >= 0) {
  this.iFrameScrollMemory.splice(existingIndex, 1);
}
```

This fix:
- Removes the useless `, 1` from `findIndex()`
- Properly passes `1` as the second parameter to `splice()`
- Stores the index in a variable for clarity
- Checks if index is valid before splicing
