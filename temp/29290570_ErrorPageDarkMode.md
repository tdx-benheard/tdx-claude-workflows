# Error page in dark mode

**ID:** 29290570 | **Branch:** feature/bheard/29290570_ErrorPageDarkMode | **Commit:** e451e3d

## Fix Summary
Error pages were rendering as partial views without the layout, which prevented dark mode CSS from loading. Changed the Error() method to return View() instead of PartialView() so error pages inherit the full layout with proper theme styling.

## Files Modified
- `TDWorkManagement/Areas/WorkManagement/Controllers/ErrorController.cs:84` - Changed return statement from PartialView(model) to View(model)

## Testing Notes
- Enable dark mode in Work Management
- Navigate to an invalid URL (e.g., `/TDNext/Apps/Downloads/ERA/Downloadz`)
- Verify error page displays with proper dark mode styling (light text on dark background)
- Test in light mode to ensure no regression
