# Implementation Plan — Super+Tab Window Switcher

**Goal:** Replace the workspace-grid overview with a macOS `cmd-Tab`-style
window switcher. See spec:
`docs/superpowers/specs/2026-08-17-super-tab-window-switcher-design.md`.

**Architecture:** Quickshell/QML for Hyprland. A `Switcher` singleton
holds all state/logic; a `PanelWindow` on the focused monitor renders a
row of tiles and handles keyboard; a single Hyprland keybind opens it
(Option B: QML grabs the keyboard for Tab/Shift+Tab/Escape/Super-release).

**Tech Stack:** QML (Qt6), Quickshell (`Quickshell`, `.Wayland`,
`.Hyprland`, `.Io`), `ScreencopyView`, `DesktopEntries`. No automated
test harness exists — verification is `qs` loading without QML errors,
plus manual checks in a live Hyprland session.

**Constraints:**
- Monitor-agnostic: never filter candidates by monitor/workspace.
- Keyboard grab must be immediate on open (no 150 ms delay gating it).
- Lua-aware Hyprland dispatch (respect `Hyprland.usingLua`).
- Prefix shell commands with `rtk` per project CLAUDE.md.

**Verification note:** "Test" steps below are `qs` load checks
(`qs -c <dir> 2>&1` shows QML compile/load errors) since no unit tests
exist. Full behavioral verification is a manual pass (Task 8), run by the
user in their live Hyprland session.

---

## Task 1: Config — swap `overview` block for `switcher` block

**Files:**
- Modify: `common/Config.qml` (the `overview` QtObject, ~line 106-142)
- Modify: `config.example.json`

**Details:**
- Replace `options.overview` with `options.switcher`:
  - `style` string `readString("switcher.style", "icons")` (icons|thumbnails|hybrid)
  - `enable` bool (true)
  - `tileSize` int (96)
  - `tileSpacing` real (12)
  - `showTitle` bool (true)
  - `previewsEnabled` bool (true)
  - `previewMode` string ("live")
  - `previewRecaptureDelayMs` int (60)
  - `includeInactiveMonitorPreviews` bool (true)
  - `includeSpecialWorkspaces` bool (true)
  - `closeOnFocusLoss` bool (true)
  - `effects`: `enableBackdrop`(false), `backdropOpacity`(0.28),
    `panelOpacity`(0.92), `enableBlur`(false), plus glass keys
    (`glassMode`,`glassTintStrength`,`glassBorderOpacity`,`glassShineOpacity`)
    carried over unchanged.
- Keep `appearance`, `position`, `windowPreview`, `hacks` blocks as-is.
- `config.example.json`: replace the `overview` object with the new
  `switcher` object mirroring these defaults.

**Verify:** grep confirms no remaining `Config.options.overview.` refs
will resolve (they'll break in later tasks, expected until then).

---

## Task 2: `services/Switcher.qml` — state + logic singleton

**Files:**
- Create: `services/Switcher.qml`
- Modify: `services/qmldir` (add `singleton Switcher 1.0 Switcher.qml`)

**Interfaces (consumed by Switcher.qml view + IPC):**
- Property `bool open`
- Property `int selectedIndex`
- Property `var entries` — computed list of app-groups, MRU-ordered.
  Each entry: `{ appClass, title, iconPath, addresses:[...],
  focusAddress, toplevel }` where `focusAddress`/`toplevel` = the group's
  most-recent (lowest `focusHistoryID`) window.
- Methods: `openSwitcher()`, `next()`, `prev()`, `confirm()`, `cancel()`.

**Details:**
- Build candidates from `ToplevelManager.toplevels.values`, joined to
  `HyprlandData.windowByAddress` by `0x<address>`.
- Include special-workspace windows when
  `Config.options.switcher.includeSpecialWorkspaces` (default true).
- Group by `class`; group rank = min `focusHistoryID`; sort groups by
  rank ascending (MRU). Per-group focus target = window with min
  `focusHistoryID`.
- Icon: reuse `DesktopEntries.heuristicLookup(appClass)` →
  `Quickshell.iconPath(icon, "image-missing")`.
- `openSwitcher()`: set `open=true`, recompute entries, set
  `selectedIndex = entries.length > 1 ? 1 : 0`.
- `next()`/`prev()`: wraparound over `entries.length` (no-op if empty).
- `confirm()`: if an entry is selected, dispatch focus
  (`hl.dsp.focus({ window = 'address:<addr>' })` when `usingLua`, else
  `focuswindow address:<addr>`), then `open=false`.
- `cancel()`: `open=false` with no focus change.

**Test:** `qs -c overview 2>&1` loads without errors referencing
Switcher.qml (nothing instantiates it yet — this is a load-only check via
a temporary `Switcher {}`-free import; real check comes in Task 5).

---

## Task 3: `modules/switcher/SwitcherTile.qml` — one app tile

**Files:**
- Create: `modules/switcher/SwitcherTile.qml`
- Create: `modules/switcher/qmldir` (add the three switcher components)

**Interfaces:**
- Consumes props: `entry` (from Switcher), `selected` (bool),
  `tileSize`, `style`.

**Details:**
- Salvage from `OverviewWindow.qml`: the `DesktopEntries` icon block and,
  for `thumbnails`/`hybrid`, the `ScreencopyView` capturing
  `entry.toplevel` (gate `captureSource` on `Switcher.open &&
  previewsEnabled`).
- `style === "icons"`: centered app icon at `tileSize`.
- `style === "thumbnails"`: live preview box; small icon badge optional.
- `style === "hybrid"`: preview as background, icon centered on top.
- Selection: highlighted border/background when `selected`
  (reuse `Appearance.colors` + rounding).
- Click → `Switcher.selectedIndex = <this index>` then
  `Switcher.confirm()`. Middle-click closes the group's focus window
  (optional; defer if it complicates).

**Test:** `qs -c overview 2>&1` load check.

---

## Task 4: `modules/switcher/SwitcherView.qml` — tile row

**Files:**
- Create: `modules/switcher/SwitcherView.qml`

**Interfaces:**
- Standalone: reads `Switcher.entries`, `Switcher.selectedIndex`,
  `Config.options.switcher.*`.

**Details:**
- Horizontal `Row`/`RowLayout` of `SwitcherTile` over `Switcher.entries`
  with `tileSpacing`.
- A sliding selection highlight (`Behavior on x` using
  `Appearance.animation.elementMoveFast`) OR per-tile `selected` styling
  (pick per-tile styling for simplicity + a moving accent rectangle if
  cheap).
- Title label under the row (`showTitle`) showing
  `entries[selectedIndex].title`.
- Panel background/padding reuses the styled rectangle look from
  `OverviewWidget` (background rect + `StyledRectangularShadow`), slimmed.

**Test:** `qs -c overview 2>&1` load check.

---

## Task 5: `modules/switcher/Switcher.qml` — scope, window, IPC, keyboard

**Files:**
- Create: `modules/switcher/Switcher.qml` (replaces `Overview.qml` role)

**Details:**
- `Scope` → `Variants` over `Quickshell.screens` → `PanelWindow`, content
  visible only on the focused monitor
  (`Hyprland.focusedMonitor?.id == monitorFor(screen)?.id`). Backdrop may
  span all monitors if `enableBackdrop`.
- `visible: Switcher.open`; `WlrLayer.Overlay`;
  `WlrKeyboardFocus.Exclusive`; namespace `quickshell:overview[-blur]`.
- Keyboard: a focused `Item` (`focus: Switcher.open`) with
  - `Keys.onPressed`: `Tab` + `Qt.ShiftModifier` → `Switcher.prev()`;
    `Tab` alone → `Switcher.next()`; `Escape` → `Switcher.cancel()`;
    accept the event.
  - `Keys.onReleased`: `Qt.Key_Super_L|Super_R|Meta` →
    `Switcher.confirm()`.
  - Ensure the item takes focus immediately when `Switcher.open` turns
    true (bind `focus`, and `forceActiveFocus()` on open) so the Super
    release is caught — do NOT gate keyboard focus behind the
    `arbitraryRaceConditionDelay` timer.
- Optional `HyprlandFocusGrab` for click-outside-close when
  `closeOnFocusLoss` (reuse existing pattern; this one may keep the delay
  since it's pointer-only).
- Center the `SwitcherView` on screen.
- `IpcHandler { target: "overview" }` with functions
  `open()`→`Switcher.openSwitcher()`, `next()`→`Switcher.next()`,
  `prev()`→`Switcher.prev()`, `confirm()`→`Switcher.confirm()`,
  `close()`→`Switcher.cancel()`. Keep `toggle()` (open if closed / cancel
  if open) for convenience.

**Test:** `qs -c overview 2>&1` loads clean; `qs ipc -c overview call
overview open` shows the switcher (manual, Task 8).

---

## Task 6: Wire entry point, delete grid, migrate GlobalStates

**Files:**
- Modify: `shell.qml` (import `./modules/switcher/`, instantiate
  `Switcher {}`; drop the overview import + `Overview {}`)
- Modify: `modules/switcher/qmldir` (Switcher/SwitcherView/SwitcherTile)
- Delete: `modules/overview/Overview.qml`,
  `modules/overview/OverviewWidget.qml`,
  `modules/overview/OverviewWindow.qml`, `modules/overview/qmldir`
- Modify: `services/GlobalStates.qml` — remove
  `superReleaseMightTrigger`; keep or drop `overviewOpen` (all state now
  in `Switcher`; grep for remaining refs and repoint to `Switcher.open`).

**Test:** `qs -c overview 2>&1` loads clean with no dangling references to
deleted components or removed config keys.

---

## Task 7: Docs — README + config.example

**Files:**
- Modify: `README.md`
- Modify: `config.example.json` (already updated in Task 1; reconcile)

**Details:**
- Rewrite the intro/features/usage for the switcher.
- Keybind section: single-keybind recipe (conf + Lua 0.55+).
- Document the fast-tap edge case + optional `bindr` safety net.
- Document `switcher.*` config incl. the three styles.
- Remove grid-only docs (rows/columns/workspaceMap/special strip/drag).

**Test:** N/A (docs).

---

## Task 8: Manual verification pass (user, live Hyprland)

Walk the six required behaviors: open on Super+Tab; Tab cycles forward;
Super+Shift+Tab cycles backward; release Super focuses selection + closes;
selection lands on the app's window regardless of monitor/workspace;
tap-and-release toggles the two most-recent apps. Confirm all three
`switcher.style` values render. Note any fast-tap "stays open" behavior
and whether the optional `bindr` net is wanted.
```
