# Project Loading for Application Overlay - Implementation Notes

## Performance Optimization Update (2025-01-05)

### AJAX Lazy Loading Implementation - COMPLETED

**Goal:** Reduce initial page load time by loading projects via AJAX when the application overlay is opened, instead of during page render.

### Implementation Summary

#### 1. Performance Measurement Hooks Added

**Server-Side (C#):**
- `HeaderBarViewComponent.cs:57` - Added total stopwatch for entire ViewComponent render
- `HeaderBarViewComponent.cs:67-70` - Project loading time measurement (now commented out)
- `HeaderBarViewComponent.cs:108-109` - Total render time logging with application count
- `HomeController.cs:453-458` - AJAX project loading time measurement

**Frontend (TypeScript):**
- `MainContentManager.ts:108` - Initialize() start timing
- `MainContentManager.ts:112-115` - setApplicationData() timing
- `MainContentManager.ts:140-141` - Total initialize() timing
- `ApplicationOverlayHandler.ts:566-606` - Complete AJAX project loading timing breakdown

#### 2. AJAX Endpoint Created

**File:** `TDWorkManagement/Areas/WorkManagement/Controllers/HomeController.cs:444-489`

```csharp
[HttpGet]
public IActionResult GetUserProjects()
```

- Added `IProjectService` dependency injection
- Mirrors server-side project loading logic
- Returns `List<UserApplicationViewModel>` as JSON
- Includes performance logging with `[PERF AJAX]` prefix
- Error handling returns empty list on failure

#### 3. Frontend AJAX Handler

**File:** `TDWorkManagement/TypeScripts/UserSettingsHandler.ts:20-24`

```typescript
public static async getUserProjects(): Promise<UserApplicationViewModel[]>
```

- Follows existing pattern (similar to `getSavedTabs()`)
- Uses `Global.sendGetRequest()` utility
- Returns typed array of `UserApplicationViewModel`

#### 4. Lazy Loading Implementation

**File:** `TDWorkManagement/TypeScripts/ApplicationOverlayHandler.ts`

**Changes:**
- Lines 22-23: Added `projectsLoaded` and `loadingProjects` flags
- Lines 108-111: Triggers `loadProjectsAsync()` when overlay opens
- Lines 561-607: New `loadProjectsAsync()` method with:
  - AJAX fetch of projects
  - Pinned state loading from user settings
  - Project data population
  - Performance timing at each step
  - Auto-refresh overlay if user is already searching

#### 5. Server-Side Project Loading Disabled

**File:** `TDWorkManagement/Areas/WorkManagement/ViewComponents/HeaderBarViewComponent.cs:64-103`

- Original project loading code commented out
- Clear documentation explaining why and where new logic lives
- Easy to re-enable for comparison or rollback

### Performance Impact

**Expected Results:**

**Baseline (Server-Side Loading):**
- Initial page load: Includes project loading time (100-500ms depending on project count)
- Every page request pays this cost
- Projects serialized and sent to client even if never used

**AJAX Lazy Loading:**
- Initial page load: No project loading (faster by 100-500ms)
- Overlay open time: +100-300ms (one-time cost per session, only when overlay opens)
- Network request only made once per session
- Projects only loaded if user opens overlay

**Net Improvement:**
- Users who never open overlay: 100-500ms faster page loads
- Users who open overlay: Slight delay on first open, but faster initial page load
- Reduced server load per page request
- Smaller initial page payload

### Testing Instructions

**To test baseline (before AJAX):**
1. Uncomment lines 69-103 in `HeaderBarViewComponent.cs`
2. Comment out line 110 in `ApplicationOverlayHandler.ts` (disable lazy load)
3. Rebuild and run
4. Check console for `[PERF]` logs
5. Note timings in server logs and browser console

**To test AJAX implementation (current):**
1. Ensure lines 69-103 in `HeaderBarViewComponent.cs` are commented
2. Ensure line 110 in `ApplicationOverlayHandler.ts` is active
3. Rebuild and run
4. Check console for `[PERF]` and `[PERF AJAX]` logs
5. Open overlay and observe project loading

**What to look for:**
- Server logs: `[PERF] Total HeaderBar ViewComponent render time`
- Browser console: `[PERF] Total MainContentManager.initialize() time`
- Browser console: `[PERF] Starting AJAX project load...`
- Browser console: `[PERF] AJAX fetch time`, `Pin load time`, `Total AJAX project loading time`
- Projects appear in search when overlay opens
- No errors in console or server logs

### Files Modified

1. ✅ `TDWorkManagement/Areas/WorkManagement/ViewComponents/HeaderBarViewComponent.cs`
2. ✅ `TDWorkManagement/Areas/WorkManagement/Controllers/HomeController.cs`
3. ✅ `TDWorkManagement/TypeScripts/MainContentManager.ts`
4. ✅ `TDWorkManagement/TypeScripts/ApplicationOverlayHandler.ts`
5. ✅ `TDWorkManagement/TypeScripts/UserSettingsHandler.ts`

### Build Status

✅ TypeScript compiled successfully (npm run build)
✅ No compilation errors
⏳ Ready for runtime testing

---

## Original Implementation (2025-01-05)

### What We Just Did

**Problem Identified:**
- Projects were not appearing in the application overlay search
- Root cause: Individual projects were not included in `ApplicationViewData`
- The system only included aggregate project applications (TDProjectBriefcase, TDProjectCalendar, etc.)
- Individual projects (with `applicationSystemClass = "TDProject"`) were loaded separately via left navigation

**Solution Implemented:**

#### 1. Server-Side Changes (C#)
**File:** `TDWorkManagement/Areas/WorkManagement/ViewComponents/HeaderBarViewComponent.cs`

- Added `IProjectService` dependency injection
- Modified `InvokeAsync()` method to load user's projects
- Called `_projectService.GetNavigatorProjects()` to retrieve projects
- Converted projects to `UserApplicationViewModel` format with:
  - `applicationSystemClass = "TDProject"`
  - `applicationId = projectId`
  - `name = projectName`
  - `url = /WorkManagement/Home/DynamicApp/{projectId}?type=TDProject`
  - `tabId = TDProject{projectId}`
- Appended projects to ApplicationViewData
- Added error handling to continue without projects if loading fails

#### 2. Frontend Changes (TypeScript)
**File:** `TDWorkManagement/TypeScripts/MainContentManager.ts`

- Changed project detection from `"Project"` to `"TDProject"` (line 700)
- Added comment explaining this is the correct system class for individual projects
- Projects are now properly separated into `userProjectData` Map

### Current State

✅ **Server loads projects** into ApplicationViewData
✅ **Frontend separates projects** from applications
✅ **Project data passed** to ApplicationOverlayHandler
🔄 **Testing in progress** - awaiting user confirmation that projects appear
⏳ **Debug logging still active** - will remove once confirmed working

### Architecture

```
Server Side:
  HeaderBarViewComponent.InvokeAsync()
    ↓
  Gets applications: _applicationService.GetUserApplications()
    ↓
  Gets projects: _projectService.GetNavigatorProjects()
    ↓
  Combines both into ApplicationViewData
    ↓
  Passes to view as Model.ApplicationViewData

Client Side:
  Default.cshtml receives Model.ApplicationViewData
    ↓
  Serializes to JSON and passes to MainContentManager.initialize()
    ↓
  MainContentManager.setApplicationData() separates:
    - applicationSystemClass === "TDProject" → userProjectData
    - everything else → userApplicationData
    ↓
  Both Maps passed to ApplicationOverlayHandler constructor
    ↓
  ApplicationOverlayHandler.filterOverlayApplications():
    - Filters applications by search text
    - If checkbox checked AND searchText.length > 0:
      - Calls createProjectTiles(searchText)
      - Filters projects by name and creates tiles with "PROJECT" badge
```

---

## What's Next

### Immediate Next Steps

1. **Testing** - User needs to confirm:
   - Console shows: `[MainContentManager] Total projects: X` (where X > 0)
   - Console shows: `[MainContentManager] ✓ Found project: ...` for each project
   - Projects appear in overlay when typing
   - Checkbox controls project visibility
   - Project badge displays correctly
   - Pin functionality works for projects

2. **Remove Debug Logging** (once confirmed working):
   - Remove all console.log statements from:
     - `MainContentManager.ts` (lines 108, 113, 682, 686, 703, 709-710)
     - `ApplicationOverlayHandler.ts` (constructor and filter methods)
     - `Default.cshtml` (line 149)

3. **Cleanup**:
   - Review and remove any temporary code
   - Ensure error handling is production-ready

---

## Known Issues & Edge Cases

### Handled
- ✅ Empty search text - projects hidden
- ✅ Checkbox unchecked - projects hidden
- ✅ Error loading projects - continues without projects (logged)
- ✅ Search bar closing overlay - prevented via stopPropagation
- ✅ Checkbox state persistence - saved to user settings

### To Verify
- ⏳ Performance with large project counts (100+)
- ⏳ Projects with special characters in names
- ⏳ Project permissions - only showing projects user has access to
- ⏳ Pinned projects persistence across sessions

---

## Key System Classes Reference

**Project-Related ApplicationSystemClass Values:**
- `TDProjects` - The Projects application itself (aggregate view)
- `TDProject` - An individual project instance (what we're using)
- `TDProjectBriefcase` - Project briefcase aggregate app
- `TDProjectCalendar` - Project calendar aggregate app
- `TDProjectWorkflows` - Project workflows aggregate app
- `TDProjectPlans` - Project plans aggregate app

**Source:** `TeamDynamix.Domain.Apps.ApplicationSystemClass` enum

---

## File Modifications Summary

### Server-Side (C#)
- ✅ `HeaderBarViewComponent.cs` - Added project loading logic

### Client-Side (TypeScript)
- ✅ `MainContentManager.ts` - Changed "Project" to "TDProject"
- ✅ `ApplicationOverlayHandler.ts` - Already had project handling logic
- ✅ `WorkMgmtUserSettings.ts` - Added project preference methods

### Client-Side (Views)
- ✅ `Default.cshtml` - Added checkbox and event handlers

### Client-Side (Styles)
- ✅ `_overlay.scss` - Added project badge styles

---

## Design Decisions Made

1. **Server-side loading vs Client-side API call**
   - ✅ Chose server-side: Projects loaded with initial page load
   - Rationale: Simpler, faster user experience, consistent with app loading pattern

2. **System class to check**
   - ✅ Using "TDProject" (individual projects)
   - Not "TDProjects" (aggregate app) or "Project" (doesn't exist)

3. **Encapsulation pattern**
   - ✅ WorkMgmtUserSettings stays internal
   - ✅ MainContentManager provides facade methods for preference access
   - Rationale: Keeps implementation details hidden from views

4. **Checkbox visibility**
   - ✅ Hidden until user starts typing
   - ✅ Checked by default
   - Rationale: Reduces UI clutter, projects opt-out instead of opt-in

5. **Project badge design**
   - ✅ Small "PROJECT" label at bottom-left
   - ✅ Inverts color on tile hover
   - Rationale: Clear visual distinction without overwhelming the design

---

## Related Documentation

- Main project docs: `C:\source\tddev\enterprise\.claude\claude.local.md`
- Ticket workflow: `C:\source\tddev\enterprise\.claude\workflow instructions\ticket-workflow.md`
- Commit standards: `C:\source\tddev\enterprise\.claude\workflow instructions\commits.md`

---

## Questions for Future Consideration

1. Should project tiles show project health indicator?
2. Should projects be grouped/categorized separately in the overlay?
3. Should closed/inactive projects be excluded from search?
4. Should there be a limit on number of projects loaded (performance)?
5. Should project descriptions be searchable in addition to names?

---

## Testing Checklist

- [ ] Console shows projects being loaded
- [ ] Projects appear when typing in search
- [ ] Checkbox controls project visibility
- [ ] Checkbox state persists across sessions
- [ ] Project badge displays correctly
- [ ] Clicking project tile opens project detail page
- [ ] Pin icon appears on project tiles
- [ ] Pinning projects persists across sessions
- [ ] Unpinned pins persist across sessions
- [ ] No console errors
- [ ] Performance is acceptable with user's project count

---

*Last Updated: 2025-01-05*
*Status: Testing in progress*
