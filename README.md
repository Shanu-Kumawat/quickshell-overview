# Quickshell Window Switcher for Hyprland

<div align="center">

A macOS `⌘-Tab`-style window switcher for Hyprland using Quickshell — hold Super and tap Tab to cycle through your running apps, release Super to focus the one you land on. Monitor- and workspace-agnostic.

![Quickshell](https://img.shields.io/badge/Quickshell-0.2.0-blue?style=flat-square)
![Hyprland](https://img.shields.io/badge/Hyprland-Compatible-purple?style=flat-square)
![Qt6](https://img.shields.io/badge/Qt-6-green?style=flat-square)
![License](https://img.shields.io/badge/License-GPL-orange?style=flat-square)

</div>

---

## ✨ Features

- ⌨️ **macOS `⌘-Tab` behavior** — `Super + Tab` opens the switcher; keep Super held and tap Tab to cycle apps; release Super to focus the selection.
- 🔁 **Backward cycling** — `Super + Shift + Tab` walks the list in reverse.
- 🧠 **MRU ordering** — windows are ordered most-recently-used, so the first tap always lands on your previous window (just like macOS).
- 🪟 **One tile per window** — every open window is its own switch target (Alt-Tab style); the selected window's title shows beneath the row.
- 🖥️ **Monitor- and workspace-agnostic** — every window is a candidate no matter which monitor or workspace it lives on. Confirming jumps you straight to it.
- 🎨 **Three presentation styles** — `icons`, `thumbnails`, or `hybrid`, selectable in config.
- 🫥 **Special/scratchpad windows included** — optional, on by default.
- 🖱️ **Mouse support** — hover to select, click to focus, middle-click to close an app's window.
- 💎 **Material Design 3 theming** with optional transparency/blur.

---

## 📦 Installation

### Arch Linux (AUR)

```bash
# Using yay
yay -S quickshell-overview-git

# Using paru
paru -S quickshell-overview-git
```

On AUR installs, module files are package-managed under:

```text
/etc/xdg/quickshell/overview/
```

Put your custom settings in:

```text
~/.config/quickshell/overview/config.json
```

Then add the keybinds and auto-start to your Hyprland config (see Setup below).

> **Note:** the config/IPC name is still `overview` (the directory and `qs -c overview` handle) for install-path compatibility, even though the tool is now a window switcher.

### Prerequisites

- **Hyprland** compositor
- **Quickshell** ([installation guide](https://quickshell.org/docs/v0.1.0/guide/install-setup/))
- **Qt 6** with modules: QtQuick, QtQuick.Controls, QtQuick.Layouts

### Setup

1. **Install module files** (choose one):
   - **Git clone (manual install):**
   ```bash
   git clone https://github.com/Shanu-Kumawat/quickshell-overview ~/.config/quickshell/overview
   ```
   - **AUR package:** use the command above (`yay -S quickshell-overview-git` or `paru -S ...`)

2. **Add keybinds** to your Hyprland config.

   The switcher uses a single "open" keybind per direction; once it is
   showing, it grabs the keyboard itself and handles further Tab / Shift+Tab
   / Escape presses and the Super release.

   *For Hyprland 0.55+ (`~/.config/hypr/hyprland.lua`):*
   ```lua
   -- Open forward (hold Super, tap Tab to keep cycling)
   hl.bind("SUPER + TAB", hl.dsp.exec_cmd("qs ipc -c overview call overview open"))
   -- Open backward (hold Super+Shift, tap Tab to keep cycling)
   hl.bind("SUPER + SHIFT + TAB", hl.dsp.exec_cmd("qs ipc -c overview call overview prev"))
   ```
   *For Hyprland 0.54 and older (`~/.config/hypr/hyprland.conf`):*
   ```conf
   # Open forward (hold Super, tap Tab to keep cycling)
   bind = SUPER, Tab, exec, qs ipc -c overview call overview open
   # Open backward (hold Super+Shift, tap Tab to keep cycling)
   bind = SUPER SHIFT, Tab, exec, qs ipc -c overview call overview prev
   ```

3. **Auto-start** the switcher (add to Hyprland config):

   *For Hyprland 0.55+ (`~/.config/hypr/hyprland.lua`):*
   ```lua
   hl.on("hyprland.start", function ()
       hl.exec_cmd("qs -c overview")
   end)
   ```
   *For Hyprland 0.54 and older (`~/.config/hypr/hyprland.conf`):*
   ```conf
   exec-once = qs -c overview
   ```

4. **Reload Hyprland**:
   ```bash
   hyprctl reload
   ```

### How the keybind works (and the fast-tap edge case)

The switcher follows the "single keybind + keyboard grab" model:

1. `Super + Tab` runs one IPC command that opens the switcher.
2. The switcher's layer surface takes an **exclusive keyboard grab** the
   instant it maps, so every subsequent `Tab` (forward), `Shift + Tab`
   (backward), `Escape` (cancel), and the eventual **Super release**
   (confirm + focus) is handled inside the switcher — no extra keybinds
   needed.

**Edge case — very fast tap-and-release:** if you tap `Super + Tab` and
release Super *extremely* quickly, the release can out-race the surface
map, so the switcher never sees the release and can stay open. If you hit
this, either press `Escape`/`Enter` to dismiss it, or add the optional
safety net below, which confirms on Super release via IPC. It is a no-op
whenever the switcher isn't open, so it's safe to leave on:

*Hyprland 0.55+ (`hyprland.lua`):*
```lua
hl.bindr("SUPER", "SUPER_L", hl.dsp.exec_cmd("qs ipc -c overview call overview confirm"))
```
*Hyprland 0.54 and older (`hyprland.conf`):*
```conf
bindr = SUPER, Super_L, exec, qs ipc -c overview call overview confirm
```

### Manual Start (if needed)

```bash
qs -c overview &
```

### NixOS

Ensure Quickshell has access to the required Qt6 modules:

```nix
# In your configuration.nix or home-manager config
environment.systemPackages = with pkgs; [
  quickshell
  qt6.qtwayland
];
```

If you're using home-manager:

```nix
home.packages = with pkgs; [
  quickshell
  qt6.qtwayland
];
```

## 🎮 Usage

Hold **Super** and use the switcher like macOS `⌘-Tab`:

| Action | Description |
|--------|-------------|
| **Super + Tab** | Open the switcher / advance to the next window |
| **Super held, tap Tab** | Cycle forward through windows |
| **Super + Shift + Tab** | Cycle backward through windows |
| **← / →** | Move selection left/right (while open) |
| **Release Super** | Focus the selected window and close the switcher |
| **Enter** | Focus the selected window and close |
| **Escape** | Close without changing focus |
| **Hover a tile** | Select that window |
| **Click a tile** | Focus that window and close |
| **Middle-click a tile** | Close that window |
| **Click outside** | Close (when `switcher.closeOnFocusLoss` is enabled — default) |

The selection lands on the chosen window wherever it lives — Hyprland
switches to the right monitor and workspace for you.

---

## ⚙️ Configuration

> **⚠️ Want to change the style, size, or behavior?**
> Create/edit `~/.config/quickshell/overview/config.json`.

`Config.qml` inside the module is treated as defaults. User overrides are
read from:

- `$XDG_CONFIG_HOME/quickshell/overview/config.json`
- fallback: `~/.config/quickshell/overview/config.json`

> **Note:** After editing `config.json`, restart the switcher for changes
> to apply:
> `qs ipc -c overview call overview close && qs -c overview`

### Quick Start

```bash
mkdir -p ~/.config/quickshell/overview
cp /etc/xdg/quickshell/overview/config.example.json ~/.config/quickshell/overview/config.json
```

If you installed from a git clone instead of AUR, copy from your repo path:

```bash
cp ~/.config/quickshell/overview/config.example.json ~/.config/quickshell/overview/config.json
```

### Switcher

Edit `~/.config/quickshell/overview/config.json`:

```json
{
  "switcher": {
    "style": "icons",
    "enable": true,
    "tileSize": 96,
    "tileSpacing": 12,
    "showTitle": true,
    "previewsEnabled": true,
    "previewMode": "live",
    "previewRecaptureDelayMs": 60,
    "includeInactiveMonitorPreviews": true,
    "includeSpecialWorkspaces": true,
    "closeOnFocusLoss": true,
    "backgroundPadding": 16,
    "effects": {
      "enableBackdrop": false,
      "backdropOpacity": 0.28,
      "panelOpacity": 0.92,
      "windowOverlayOpacity": 0.22,
      "enableBlur": false,
      "glassMode": false,
      "glassTintStrength": 0.35,
      "glassBorderOpacity": 0.72,
      "glassShineOpacity": 0.14
    }
  }
}
```

- `style`: how each app tile is drawn — see [Presentation styles](#presentation-styles) below.
- `enable`: master on/off for the switcher panel.
- `tileSize`: width/height of each app tile in pixels.
- `tileSpacing`: gap between tiles in pixels.
- `showTitle`: show the selected app's window title beneath the row.
- `includeSpecialWorkspaces`: include special/scratchpad windows as candidates (default `true`).
- `closeOnFocusLoss`: clicking outside the switcher closes it (default `true`).
- `backgroundPadding`: inner padding of the switcher panel in pixels.
- Preview keys (`previewsEnabled`, `previewMode`, `previewRecaptureDelayMs`, `includeInactiveMonitorPreviews`) and `effects.*` are covered under [Presentation styles](#presentation-styles) and [Transparency & blur](#transparency--blur).

### Presentation styles

`switcher.style` controls how each app tile looks:

| Value | Look |
|-------|------|
| `"icons"` | App icon only (default). Fast, lightweight, no screencopy. |
| `"thumbnails"` | A live preview of the app's most-recent window, falling back to the icon when no preview is available. |
| `"hybrid"` | The window preview as a dimmed background with the app icon centered on top. |

Preview behavior (used by `thumbnails` and `hybrid`):

```json
{
  "switcher": {
    "style": "thumbnails",
    "previewsEnabled": true,
    "previewMode": "live",
    "includeInactiveMonitorPreviews": true,
    "previewRecaptureDelayMs": 60
  }
}
```

- `previewsEnabled`: turn all window screencopy previews on/off. With `style: "icons"` this has no visible effect.
- `previewMode`: `live` (best visuals, more RAM) or `event` (lower RAM, refreshes on window events).
- `includeInactiveMonitorPreviews`: when `false`, only current-monitor windows get preview capture.
- `previewRecaptureDelayMs`: delay used for event-mode snapshot refresh (lower = faster updates).

**Low-memory preset:**

```json
{
  "switcher": {
    "style": "icons"
  },
  "hacks": {
    "hyprlandEventDebounceMs": 80
  }
}
```

The `icons` style skips screencopy entirely, so it's the lightest option.

### Position

```json
{
  "position": {
    "topMargin": 100
  }
}
```

Increase `topMargin` to move the switcher down; decrease it to move up.

### Transparency & Blur

```json
{
  "switcher": {
    "effects": {
      "enableBackdrop": false,
      "backdropOpacity": 0.28,
      "panelOpacity": 0.92,
      "windowOverlayOpacity": 0.22,
      "enableBlur": false,
      "glassMode": false,
      "glassTintStrength": 0.35,
      "glassBorderOpacity": 0.72,
      "glassShineOpacity": 0.14
    }
  }
}
```

- `enableBackdrop`: show/hide a full-screen dim backdrop behind the switcher.
- `backdropOpacity`: opacity of the backdrop dim layer (`0` to `1`).
- `panelOpacity`: opacity of the switcher panel container (`0` to `1`).
- `windowOverlayOpacity`: opacity of the color tint over window previews (`0` to `1`).
- `enableBlur`: switches the layer namespace to `quickshell:overview-blur`.
- `glassMode`: enables a glass-like tint + softer transparency preset.
- `glassTintStrength`: tint mixing strength for glass mode (`0` to `1`).
- `glassBorderOpacity`: border alpha used by glass mode (`0` to `1`).
- `glassShineOpacity`: top highlight strength for glass reflections (`0` to `1`).

For Hyprland blur, add layer rules (example):

```ini
layerrule = blur true, match:namespace quickshell:overview-blur
layerrule = ignore_alpha 0.2, match:namespace quickshell:overview-blur
```

If `enableBlur` is `false`, the namespace remains `quickshell:overview`.

### Full Example

```json
{
  "appearance": {
    "colorSource": "default",
    "caelestia": {
      "autoRefresh": true,
      "refreshInterval": 2000,
      "accentProfile": "vibrant"
    },
    "rounding": {
      "unsharpen": 2,
      "verysmall": 8,
      "small": 12,
      "normal": 17,
      "large": 23,
      "full": 9999,
      "screenRounding": 23,
      "windowRounding": 18
    },
    "font": {
      "family": {
        "main": "sans-serif",
        "title": "sans-serif",
        "expressive": "sans-serif"
      },
      "pixelSize": {
        "smaller": 12,
        "small": 15,
        "normal": 16,
        "larger": 19,
        "huge": 22
      }
    },
    "animation": {
      "duration": {
        "elementMove": 500,
        "elementMoveEnter": 400,
        "elementMoveFast": 200
      }
    },
    "sizes": {
      "elevationMargin": 10
    }
  },
  "switcher": {
    "style": "icons",
    "enable": true,
    "tileSize": 96,
    "tileSpacing": 12,
    "showTitle": true,
    "previewsEnabled": true,
    "previewMode": "live",
    "previewRecaptureDelayMs": 60,
    "includeInactiveMonitorPreviews": true,
    "includeSpecialWorkspaces": true,
    "closeOnFocusLoss": true,
    "backgroundPadding": 16,
    "effects": {
      "enableBackdrop": false,
      "backdropOpacity": 0.28,
      "panelOpacity": 0.92,
      "windowOverlayOpacity": 0.22,
      "enableBlur": false,
      "glassMode": false,
      "glassTintStrength": 0.35,
      "glassBorderOpacity": 0.72,
      "glassShineOpacity": 0.14
    }
  },
  "position": {
    "topMargin": 100
  },
  "windowPreview": {
    "showIcons": true,
    "iconToWindowRatio": 0.25,
    "iconToWindowRatioCompact": 0.45,
    "xwaylandIndicatorToIconRatio": 0.35,
    "inactiveMonitorOpacity": 0.4,
    "cropToFill": false
  },
  "hacks": {
    "arbitraryRaceConditionDelay": 150,
    "hyprlandEventDebounceMs": 40
  }
}
```

### Theme & Colors

Most theme sizing/timing options are configurable via `config.json`:
- `appearance.colorSource` (`default`, `matugen`, `caelestia`)
- `appearance.caelestia.*` (`autoRefresh`, `refreshInterval`, `accentProfile`)
- `appearance.rounding.*`
- `appearance.font.*`
- `appearance.animation.duration.*`
- `appearance.sizes.elevationMargin`

For full color palette customization, edit `~/.config/quickshell/overview/common/Appearance.qml`.

### Matugen (Dynamic Colors from Wallpaper)

[Matugen](https://github.com/InioX/matugen) lets you generate Material You colors from your wallpaper and apply them to the switcher automatically.

**1. Install matugen** — follow [matugen's install guide](https://github.com/InioX/matugen?tab=readme-ov-file#installation)

**2. Copy the template** from this repo to matugen's templates folder:
```bash
mkdir -p ~/.config/matugen/templates
cp ~/.config/quickshell/overview/quickshell-overview.qml ~/.config/matugen/templates/
```

**3. Add this to `~/.config/matugen/config.toml`** (create the file if it doesn't exist):
```toml
[templates.quickshell_overview]
input_path  = "./templates/quickshell-overview.qml"
output_path = "~/.config/quickshell/overview/common/Appearance.colors.qml"
```

**4. Enable it** in `~/.config/quickshell/overview/config.json`:
```json
{
  "appearance": {
    "colorSource": "matugen"
  }
}
```

**5. Run matugen** with your wallpaper to generate colors:
```bash
matugen image /path/to/your/wallpaper.jpg
```

This generates `Appearance.colors.qml` which the switcher loads automatically. Re-run step 5 whenever you change your wallpaper.

### Caelestia

If you use Caelestia, set the source to `caelestia`:

```json
{
  "appearance": {
    "colorSource": "caelestia",
    "caelestia": {
      "autoRefresh": true,
      "refreshInterval": 2000,
      "accentProfile": "vibrant"
    }
  }
}
```

The switcher reads the active palette from `caelestia scheme get` and refreshes it live when `autoRefresh` is enabled, so wallpaper/scheme changes can apply without a restart.

---

## 📋 Requirements

- **Hyprland** compositor (tested on latest versions; Lua-config 0.55+ and legacy `.conf` both supported)
- **Quickshell** (Qt6-based shell framework)
- **Qt 6** with the following modules:
  - QtQuick
  - QtQuick.Controls
  - QtQuick.Layouts
  - Quickshell.Wayland
  - Quickshell.Hyprland

## 📁 File Structure

```
~/.config/quickshell/overview/
├── shell.qml                      # Main entry point
├── README.md                      # This file
├── config.example.json            # User override template
├── common/
│   ├── Appearance.qml             # Theme and styling
│   ├── Config.qml                 # Default config + user override loader
│   ├── functions/
│   │   └── ColorUtils.qml         # Color manipulation utilities
│   └── widgets/
│       ├── StyledText.qml         # Styled text component
│       ├── StyledRectangularShadow.qml
│       ├── StyledToolTip.qml
│       └── StyledToolTipContent.qml
├── services/
│   ├── Switcher.qml               # Switcher state + logic (singleton)
│   └── HyprlandData.qml           # Hyprland data provider
└── modules/
    └── switcher/
        ├── WindowSwitcher.qml     # Scope: window, keyboard grab, IPC
        ├── SwitcherView.qml       # The panel: row of app tiles + title
        └── SwitcherTile.qml       # A single app tile
```

## 🎯 IPC Commands

```bash
# Open the switcher (advances to the next app if already open)
qs ipc -c overview call overview open

# Cycle forward / backward (opens first if closed)
qs ipc -c overview call overview next
qs ipc -c overview call overview prev

# Confirm the current selection and focus it (no-op if not open)
qs ipc -c overview call overview confirm

# Close without changing focus
qs ipc -c overview call overview close

# Toggle open/closed
qs ipc -c overview call overview toggle
```

## 🐛 Known Issues

- Window icons may fall back to a generic icon if the app's class name doesn't match an icon-theme entry.
- Very fast `Super + Tab` tap-and-release can occasionally leave the switcher open (see [the fast-tap edge case](#how-the-keybind-works-and-the-fast-tap-edge-case) and the optional `bindr` safety net).
- Potential instability during rapid window state changes due to Wayland screencopy buffer management (only relevant with `thumbnails`/`hybrid` styles).

## 💖 Support

If this project helps your setup and you want to support continued maintenance, you can sponsor here:

https://github.com/sponsors/Shanu-Kumawat

## Credits

Extracted and reworked from the overview feature in [illogical-impulse](https://github.com/end-4/dots-hyprland) by [end-4](https://github.com/end-4).

Adapted into a standalone macOS-style window switcher for Hyprland + Quickshell users.

---

<div align="center">

**Note:** Maintenance will be limited due to time constraints, but **PRs and code improvements are welcome!** Feel free to contribute or fork for your own needs.

Made with ❤️ for the Hyprland community

</div>
