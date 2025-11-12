# Tab Pinning - Next Steps: Pin Icon Implementation

## Overview
Complete the tab pinning feature by replacing the close X with a pin icon on pinned tabs, and making the pin icon clickable to unpin tabs.

## Status
- ✅ **CurrentTabsDropdown.ts** - Active tab selection in dropdown (COMPLETED)
- ⏳ **TabHandler.ts** - Pin icon replacement (4 changes needed)
- ⏳ **_navigation-tabs.scss** - Pin icon styles (1 change needed)

## Required Changes

### File 1: TabHandler.ts
**Location:** `C:/source/tddev/enterprise/TDWorkManagement/TypeScripts/TabHandler.ts`

#### Change A: Update toggleTabPin method (Line 569)
Add ONE line before `this.detectAndProcessTabChanges(true);`:

```typescript
    // Update the pin icon visibility
    this.updateTabPinIconVisibility(tabId);
```

**Result should look like:**
```typescript
    // Toggle the pinned state
    tabData.isPinned = !tabData.isPinned;

    // Update the pin icon visibility
    this.updateTabPinIconVisibility(tabId);

    // Refresh the dropdown to show updated pin state and trigger save
    this.detectAndProcessTabChanges(true);
  }
```

---

#### Change B: Add updateTabPinIconVisibility method (After Line 571)
Insert this complete method after the closing brace of `toggleTabPin`:

```typescript
  // update the visibility of pin icon vs close X for a tab
  private updateTabPinIconVisibility(tabId: string) {
    const tabElement = this.getExistingTab(tabId);
    if (!tabElement) return;

    const tabData = this.availableTabs.get(tabId);
    const isPinned = tabData?.isPinned ?? false;

    const pinIcon = tabElement.querySelector(".tdx-navigation-tabs__pin-icon") as HTMLElement;
    const closeX = tabElement.querySelector(".tdx-close-x") as HTMLElement;

    if (pinIcon && closeX) {
      if (isPinned) {
        pinIcon.style.display = "";
        closeX.style.display = "none";
      } else {
        pinIcon.style.display = "none";
        closeX.style.display = "";
      }
    }
  }
```

---

#### Change C: Add createPinIcon method (After line 644)
Insert this complete method after the closing brace of `createCancelX`:

```typescript
  // create the pin icon element that shows when a tab is pinned
  private createPinIcon(containingTabElement: HTMLElement, tabTitle: string): HTMLElement {
    const pinIconElement = document.createElement("i");
    pinIconElement.className = "fa-solid fa-thumbtack tdx-navigation-tabs__pin-icon";
    pinIconElement.tabIndex = 0;
    pinIconElement.setAttribute("aria-label", "Unpin " + tabTitle + " tab");
    pinIconElement.setAttribute("title", "Unpin");
    pinIconElement.setAttribute("role", "button");

    // if they click on the element, make sure nothing else receives the click event
    pinIconElement.addEventListener("mousedown", (e) => {
      e.stopPropagation();
    });

    const unpinHandler = (e: MouseEvent | TouchEvent) => {
      // don't let anything else handle the click event
      e.stopPropagation();

      // Tab must not be being dragged
      if (containingTabElement.dataset.isDragged) {
        return;
      }

      this.toggleTabPin(containingTabElement.id);
    };

    // handle a click on the pin icon
    pinIconElement.addEventListener("mouseup", unpinHandler);
    pinIconElement.addEventListener("touchstart", unpinHandler);

    pinIconElement.addEventListener("keydown", (e: KeyboardEvent) => {
      if (e.key == "Enter" || e.key == "Space") {
        e.stopPropagation();
        this.toggleTabPin(containingTabElement.id);
      }
    });

    // return the newly created element
    return pinIconElement;
  }
```

---

#### Change D: Modify addTab method (Lines 255-265)
**FIND this code:**
```typescript
    // create the cancel x to close the tab
    const cancelX = this.createCancelX(newTab, tabContent.textContent);

    // add all our elements to the tab
    newTab.append(iconElement, tabContent);

    // create the button to popout the tab into a browser window
    const popoutToBrowserButton = this.createTabPopoutToBrowserButton(newTab, tabContent.textContent);
    newTab.append(popoutToBrowserButton);

    newTab.append(cancelX);
```

**REPLACE with:**
```typescript
    // create the cancel x to close the tab
    const cancelX = this.createCancelX(newTab, tabContent.textContent);

    // create the pin icon for pinned tabs
    const pinIcon = this.createPinIcon(newTab, tabContent.textContent);

    // add all our elements to the tab
    newTab.append(iconElement, tabContent);

    // create the button to popout the tab into a browser window
    const popoutToBrowserButton = this.createTabPopoutToBrowserButton(newTab, tabContent.textContent);
    newTab.append(popoutToBrowserButton);

    // add pin icon or close X based on pinned state
    if (tabData.isPinned) {
      newTab.append(pinIcon);
      cancelX.style.display = "none";
      newTab.append(cancelX); // still add it to DOM but hidden
    } else {
      pinIcon.style.display = "none";
      newTab.append(pinIcon); // still add it to DOM but hidden
      newTab.append(cancelX);
    }
```

---

### File 2: _navigation-tabs.scss
**Location:** `C:/source/tddev/enterprise/TDWorkManagement/wwwroot/styles/components/_navigation-tabs.scss`

#### Add pin icon styles (At the end of file, after line 117)

```scss
.tdx-navigation-tabs__pin-icon {
  color: var(--purple);
  font-size: 0.875rem;
  cursor: pointer;
  padding: 0.25rem;
  border-radius: $border-radius-sm;

  &:hover {
    color: var(--primaryD1);
  }

  &:focus {
    outline: 2px solid var(--purple);
    outline-offset: 2px;
  }
}
```

---

## Build Commands

After making all changes, run these commands to compile:

```bash
cd /c/source/tddev/enterprise/TDWorkManagement
npm run builddev
npm run scss:compile
```

---

## Expected Behavior After Implementation

1. **Pinned tabs display pin icon**: When a tab is pinned (via dropdown), the close X is hidden and a purple thumbtack icon appears in its place
2. **Clicking pin icon unpins tab**: Clicking the pin icon on a pinned tab will unpin it, hiding the pin icon and restoring the close X
3. **Active tab highlighted in dropdown**: When opening the current tabs dropdown, the currently active tab will be highlighted with visual distinction
4. **Pin icon styling**: The pin icon has purple color, darkens on hover, and has proper focus outline for accessibility

---

## Implementation Notes

- Both pin icon and close X are always added to the DOM but visibility is toggled based on pinned state
- The pin icon uses Font Awesome's thumbtack icon (`fa-solid fa-thumbtack`)
- Clicking the pin icon calls `toggleTabPin()` which updates the pin state and triggers a save
- The `updateTabPinIconVisibility()` method handles showing/hiding the correct icon after state changes

---

## Troubleshooting

If changes cannot be applied via Edit tool:
- Close the file in VS Code or any other editors
- Stop any file watchers (`npm run watch`, webpack watch mode, etc.)
- Check for node.exe processes that might have file handles open
- Apply changes manually by editing the files directly

---

## Testing Checklist

After implementation, test:
- [ ] Pin a tab from the dropdown - verify pin icon appears on the tab itself
- [ ] Click the pin icon on a pinned tab - verify it unpins and close X returns
- [ ] Open the current tabs dropdown - verify the active tab is highlighted
- [ ] Pin/unpin multiple tabs - verify state persists correctly
- [ ] Keyboard navigation works with pin icon (Tab to focus, Enter/Space to activate)
- [ ] Hover states work correctly on pin icon
