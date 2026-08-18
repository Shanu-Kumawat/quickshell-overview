# Super+Tab Window Switcher — Design

**Date:** 2026-08-17
**Status:** Approved direction; spec under review

## Goal

Repurpose this module from a workspace-grid overview into a macOS
`cmd-Tab`-style window switcher. The user thinks in terms of *running
applications*, not workspaces. Switching to an app should focus it
wherever it lives; which workspace/monitor it is on is irrelevant.

### Required behaviors

1. Monitor-agnostic — the switcher does not care what monitor/workspace
   a window is on.
2. `SUPER + Tab` (rebindable in the compositor) opens the switcher.
3. Releasing `SUPER` closes the switcher and focuses the selection.
4. Holding `SUPER` and tapping `Tab` cycles forward through entries.
5. Holding `SUPER + SHIFT` and tapping `Tab` cycles backward.
6. Entries are apps, not workspaces. Confirming focuses the app's most
   recent window, which lands you on whatever workspace it is on.

## Decisions

- **Presentation is configurable** via `switcher.style`:
  - `icons` — a row of large app icons + a title label (truest cmd-Tab).
  - `thumbnails` — a strip of live window previews (screencopy).
  - `hybrid` — icon as the primary mark over a small live thumbnail.
  All three are built; `icons` is the default.
- **Granularity = one tile per app.** Windows are grouped by `class`.
  MRU order via `focusHistoryID`. An app-group's rank is the lowest
  `focusHistoryID` among its windows; confirming focuses that window.
- **The workspace grid is replaced**, not kept as a second mode.
- **Keybind mechanism = Option B (single keybind + QML keyboard grab).**
  One Hyprland keybind opens the switcher; the layer surface takes
  exclusive keyboard focus and QML handles all subsequent keys.
- **Special/scratchpad windows are included** as normal entries.

## Interaction model

- On `open`: build the MRU-ordered app-group list. Select **index 1**
  (the previous app) when ≥2 groups exist, else index 0. This makes a
  single tap-and-release toggle between the two most-recent apps, as on
  macOS.
- `next` / `prev`: move the highlight with wraparound.
- `confirm`: focus the selected group's most-recent window via
  `focuswindow address:<addr>` (Lua-aware dispatch, reusing the existing
  `Hyprland.usingLua` branch), then close.
- `cancel` (Escape): close without changing focus.
- Clicking a tile confirms that tile. Middle-click closes that window
  (nice-to-have, may defer).
- Rendered on the currently-focused monitor only. No monitor/workspace
  filtering of candidates — every toplevel is eligible.

## Keybind wiring (Option B)

Compositor side is a single keybind (rebindable — this is where
"configurable Super+Tab" lives):

```conf
# Hyprland 0.54 and older
bind = SUPER, Tab, exec, qs ipc -c overview call overview open
```

```lua
-- Hyprland 0.55+
hl.bind("SUPER + TAB", hl.dsp.exec_cmd("qs ipc -c overview call overview open"))
```

QML side, once open (layer has `WlrKeyboardFocus.Exclusive`):

- `Keys.onPressed`:
  - `Tab` without Shift → `Switcher.next()`
  - `Tab` with `Qt.ShiftModifier` → `Switcher.prev()`
  - `Escape` → `Switcher.cancel()`
- `Keys.onReleased`:
  - `Qt.Key_Super_L` / `Qt.Key_Super_R` / `Qt.Key_Meta` → `Switcher.confirm()`

To catch the `SUPER` release, the surface must grab the keyboard
**immediately** on open — the existing 150 ms grab delay
(`arbitraryRaceConditionDelay`, used for click-outside) must NOT gate
keyboard focus. Keyboard focus comes from the layershell
`WlrKeyboardFocus.Exclusive` property applied on map, not from the
pointer `HyprlandFocusGrab`.

### Known edge case + escape hatch

If the user taps and releases `SUPER` faster than the layer surface can
map and grab the keyboard, the release event is missed and the switcher
stays open (Escape/click still dismiss it). Documented in the README
with an optional one-line safety net the user can add if it ever bites:

```conf
bindr = SUPER, Super_L, exec, qs ipc -c overview call overview confirm
```

## Components

New `modules/switcher/`:

- **`services/Switcher.qml`** (new singleton) — single source of truth.
  Owns `open` (bool), computed `entries` (app-groups, MRU-ordered),
  `selectedIndex`, and methods `openSwitcher()`, `next()`, `prev()`,
  `confirm()`, `cancel()`. Reads window data from `HyprlandData` +
  `ToplevelManager`.
- **`Switcher.qml`** — `Scope` with a `PanelWindow` on the focused
  monitor, the `IpcHandler` (`target: "overview"`, functions
  `open/next/prev/confirm/close`), and the keyboard handling. Replaces
  `Overview.qml`.
- **`SwitcherView.qml`** — the horizontal tile row, the sliding
  selection highlight, and the selected-title label. Replaces
  `OverviewWidget.qml`.
- **`SwitcherTile.qml`** — one app tile; renders icon / live thumbnail /
  hybrid per `switcher.style`. Salvages the `DesktopEntries` icon lookup
  and `ScreencopyView` preview logic from `OverviewWindow.qml`.

Deleted: `Overview.qml`, `OverviewWidget.qml`, `OverviewWindow.qml`.

Kept: `HyprlandData.qml` (still needed for `hyprctl clients`: `class`,
`address`, `focusHistoryID`, `monitor`). Workspace-only helpers may be
trimmed in a later cleanup, not in this change.

`GlobalStates.qml`: `overviewOpen` is superseded by `Switcher.open`;
keep a thin alias or migrate references. Remove `superReleaseMightTrigger`.

## Config changes (`common/Config.qml` + `config.example.json`)

Replace the `overview` block with a `switcher` block. Proposed keys
(defaults in parens):

- `switcher.style` (`"icons"`) — `icons` | `thumbnails` | `hybrid`
- `switcher.enable` (`true`)
- `switcher.tileSize` (`96`) — px, the icon/thumbnail box
- `switcher.tileSpacing` (`12`)
- `switcher.showTitle` (`true`) — title label under the row
- `switcher.previewsEnabled` (`true`) — for thumbnails/hybrid styles
- `switcher.previewMode` (`"live"`) — `live` | `event`
- `switcher.includeSpecialWorkspaces` (`true`)
- `switcher.effects.*` — slimmed: `enableBackdrop`, `backdropOpacity`,
  `panelOpacity`, `enableBlur`, plus the existing glass keys if cheap to
  keep.

`appearance`, `position`, `windowPreview`, `hacks` blocks are unchanged.
Grid-only keys (`rows`, `columns`, `workspaceMap`, `orderRightLeft`,
`hideEmptyRows`, special-workspace strip config, etc.) are removed.

## Docs

`README.md` and `config.example.json` rewritten for the switcher: the
single-keybind recipe (conf + Lua), the `switcher.*` config, the style
gallery, and the edge-case note with the `bindr` safety net.

## Testing / verification

No unit-test harness exists in this repo (pure QML). Verification is
manual, in a live Hyprland session, against the six required behaviors —
especially the Super-release-to-confirm timing under Option B. The user
runs this; I cannot exercise Hyprland keybinds from here.

## Out of scope

- Drag-and-drop between workspaces (grid feature, dropped).
- The workspace grid as an alternate mode.
- Renaming the `overview` qs config dir / IPC target.
