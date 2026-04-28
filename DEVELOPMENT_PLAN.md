# MemoryRestartBar Development Plan

## 1. Summary

Build a native, lightweight, low-distraction macOS menu bar utility for quickly restarting commonly used apps.

Version 1 only covers the core loop:

- Add application
- Show added applications
- Restart one application
- Remove application
- Restart all applications

This phase excludes monitoring, complex settings UI, and custom windows. Stability, low memory use, and predictable interaction come first.

## 2. Product Definition

### 2.1 Target User

- Personal use
- Occasional use
- Scenario: long-running apps become heavy over time and need a quick manual restart

### 2.2 Core Goals

- Restart a common app within two clicks
- Keep the tool itself lightweight
- Avoid persistent complex UI
- Avoid fragile interaction chains

### 2.3 Non-Goals

Out of scope for v1:

- Memory monitoring
- Threshold-triggered restart
- Launch at login
- Settings window
- Drag-to-sort
- Search
- App icon preview
- Manual JSON config editing
- Advanced Notification Center integration
- History and statistics

## 3. Technical Direction

### 3.1 Architecture Choice

Use a pure AppKit menu bar implementation:

- `NSApplication`
- `NSStatusBar`
- `NSStatusItem`
- `NSMenu`
- `NSMenuItem`
- `NSOpenPanel`
- `NSWorkspace`
- `NSRunningApplication`
- `UserDefaults`

### 3.2 Key Principles

- Do not use SwiftUI menu content
- Do not use custom panels as the main interaction model
- Rebuild the full menu after every data change
- Prove the shortest path first, then add features
- Each iteration implements one capability and validates it immediately

## 4. Data Model

### 4.1 Persistence Structure

Store the tracked app list in `UserDefaults`.

Each app item contains:

- `id`
- `displayName`
- `bundleId`
- `appPath`

### 4.2 Default Behavior

- No enabled/disabled state
- No per-app quit strategy
- Version 1 uses one restart flow:
  - If running: `terminate()` + timeout wait
  - If not running: launch directly

## 5. Functional Breakdown

### 5.1 Menu Bar Host

Show one status bar icon after launch. Clicking opens the menu.

Fixed menu structure:

- `Add Application...`
- `Restart All`
- Separator
- `[Tracked Applications]`
- Separator
- `[Remove <AppName>]`
- Separator
- `Quit`

Rules:

- Disable `Restart All` when the list is empty
- Keep remove items below restart items to reduce accidental restart/remove confusion

### 5.2 Add Application

When clicking `Add Application...`:

- Activate the app to foreground
- Open `NSOpenPanel`
- Allow choosing `.app`
- Parse:
  - `bundleIdentifier`
  - `displayName`
  - `appPath`
- Deduplicate
- Save
- Rebuild menu immediately

Failure cases:

- User cancels
- Selected item is not a valid app bundle
- Cannot resolve bundle ID
- Duplicate app

All of these must produce clear status feedback.

### 5.3 Restart One Application

When clicking an app item:

- If the app is running:
  - call `terminate()`
  - wait for exit (timeout 5-8 seconds)
  - relaunch
- If not running:
  - launch directly

Failure cases:

- Path invalid
- App cannot be resolved by bundle ID
- Exit timeout
- Launch failure

Feedback method:

- Update a status item at the top of the menu
- Do not depend on notifications in v1

### 5.4 Restart All

When clicking `Restart All`:

- Restart all tracked apps sequentially
- One failure must not stop later apps
- Final status shows:
  - success count
  - failure count

### 5.5 Remove Application

Each tracked app gets a matching remove menu item:

- Remove from persistence
- Rebuild menu
- Do not show again on next launch

## 6. Iteration Plan

### Iteration 1: Status Bar Host and Static Menu

**Goal**

- Launch app
- Show menu bar icon
- Open static menu
- `Quit` exits normally

**Implementation**

- Initialize `NSApplication`
- Create `NSStatusItem`
- Attach static `NSMenu`

**Validation**

- `swift build` passes
- Status bar icon appears
- Menu opens/closes stably
- `Quit` exits app

**Done**

- Menu bar host is stable with no business logic yet

### Iteration 2: Add Application and Persistence

**Goal**

- `Add Application...` can select `.app`
- Added app appears immediately in the menu
- Relaunching the utility preserves the list

**Implementation**

- `NSOpenPanel`
- App bundle parsing
- `UserDefaults` read/write
- Dynamic menu rebuild

**Validation**

- Selecting `Ghostty.app` or another `.app` immediately adds it to the menu
- After quitting and relaunching the utility, the app remains
- Duplicate add is blocked
- Canceling the picker leaves state unchanged

**Done**

- The full add -> persist -> render loop works

### Iteration 3: Restart One Application

**Goal**

- Clicking an app item restarts it

**Implementation**

- Query running instance
- `terminate()` + wait
- Relaunch via `NSWorkspace`
- Status feedback

**Validation**

Cover at least:

1. App is running -> exits and reopens
2. App is not running -> launches directly
3. Stored path is invalid -> failure is shown
4. Repeated clicks on the same app -> no crash, no frozen menu

**Done**

- Multiple manual runs produce consistent results
- Menu interaction stays responsive

### Iteration 4: Remove Application

**Goal**

- Support removing tracked apps

**Implementation**

- Remove menu item
- Persistence update
- Immediate menu rebuild

**Validation**

- App disappears from menu after removal
- It does not return after relaunch
- Other tracked apps remain intact

**Done**

- List management loop is complete

### Iteration 5: Restart All

**Goal**

- Support `Restart All`

**Implementation**

- Sequential restart
- Aggregated result reporting

**Validation**

- Test with at least 2-3 tracked apps
- One failed item does not block the rest
- Final status shows success/failure totals

**Done**

- Batch behavior is predictable and recoverable

## 7. Public Interfaces / Internal Types

No external API in version 1.

Internal responsibilities:

- **AppStorage / Preferences**
  - Read and write tracked apps
- **AppRegistry**
  - Parse `.app` into structured app metadata
- **RestartService**
  - Restart one app or all apps
- **MenuController / StatusBarController**
  - Build menus and dispatch actions

Suggested internal models:

- `TrackedApp`
- `RestartResult`

## 8. Data Flow

Main flow:

1. Launch app
2. Load tracked apps from `UserDefaults`
3. Build menu from the current list
4. User clicks a menu action
5. Execute action (add / remove / restart / restart all)
6. Update status
7. If data changed, persist and rebuild menu

Key rule:

- UI must not hold complex independent state
- The menu is always rebuilt from one source of truth

## 9. Testing Plan

### 9.1 Build Verification

Every iteration must run:

- `swift build`

### 9.2 Manual Verification

Each iteration is tested only for the capability added in that iteration.

Core scenarios:

- Status bar icon appears after launch
- Menu opens stably
- App can be added and appears immediately
- App persists across relaunch
- Single restart works
- Remove works
- Restart all works

### 9.3 Error Scenarios

Must cover:

- Cancel picker
- Duplicate add
- Invalid app bundle
- Invalid stored app path
- App not running
- App exit timeout
- One failure during batch restart

## 10. Risks and Controls

### Risk 1: `NSOpenPanel` focus issues in a menu bar app

**Control**

- Activate the app before presenting the panel

### Risk 2: Menu state and data state drift apart

**Control**

- Never patch menu incrementally; always rebuild from storage state

### Risk 3: Third-party app does not respond to `terminate()`

**Control**

- Return timeout failure in v1
- Do not auto-fallback to force kill

### Risk 4: Batch restart blocks menu interaction

**Control**

- Execute sequentially
- Update top status item during execution

## 11. Assumptions

- Platform is macOS only
- Version 1 is for personal use, not team distribution
- Monitoring is intentionally excluded from this phase
- Native simplicity is more important than feature richness
- Tracked app count stays small

## 12. Done Criteria

Version 1 is complete only when all of the following are true:

- Status bar icon displays reliably
- Any valid `.app` can be added
- Added app appears immediately
- Tracked apps persist after relaunch
- Clicking one app restarts it
- App can be removed
- `Restart All` works
- Every iteration passes build verification and matching manual validation
- No extra custom windows or monitoring logic are introduced
