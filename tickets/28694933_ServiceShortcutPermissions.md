# Permission checking for shortcut-ed services is not working as intended
**ID:** 28694933 | **Branch:** feature/bheard/28694933_ServiceShortcutPermissions | **Commit:** 1c4cc46f

## Fix Summary
Service shortcuts were bypassing client portal permission checks because the system used the source portal's ID instead of the target portal's ID from shortcuts. Fixed by extracting shortcut IDs from the query string and using `ShortcutsHelper.DetermineContentClientPortalID()` to determine the correct portal for both permission checks and URL generation, following the pattern already established in KnowledgeBaseController.

## Files Modified
- `TDClient/Controllers/ServicesController.cs` - Added shortcut extraction in `TryGetRequestInitiator()` method to use correct portal ID for service/offering lookups and permission checks (lines 351-372, 395)
- `TDClient/Helpers/UrlHelper.cs` - Updated `GetServiceDetailUrl()` and `GetServiceCategoryUrl()` to determine portal from shortcuts when generating URLs (lines 5549-5575, 5664-5686)

## Testing Notes
- Test with two portals: Main portal (accessible to all) and Restricted portal (limited access)
- Create shortcut from Main portal to service in Restricted portal
- **Direct access test**: User without Restricted portal access should see "You do not have permission" ✅
- **Shortcut access test**: Same user clicking shortcut should now ALSO see "You do not have permission" (previously allowed access ❌)
- **URL verification**: Shortcut URLs should now show `/ClientPortal/{RestrictedPortalID}/...` instead of `/ClientPortal/{MainPortalID}/...`
- **Positive test**: Users WITH Restricted portal access should be able to use shortcuts successfully
