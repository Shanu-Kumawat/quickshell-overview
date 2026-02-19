# Quickshell Overview for Hyprland

<div align="center">

A standalone workspace overview module for Hyprland using Quickshell - shows all workspaces with live window previews, drag-and-drop support, and Super+Tab keybind.

![Quickshell](https://img.shields.io/badge/Quickshell-0.2.0-blue?style=flat-square)
![Hyprland](https://img.shields.io/badge/Hyprland-Compatible-purple?style=flat-square)
![Qt6](https://img.shields.io/badge/Qt-6-green?style=flat-square)
![License](https://img.shields.io/badge/License-GPL-orange?style=flat-square)


</div>

---

## 📸 Preview

![Overview Screenshot](assets/image.png)

https://github.com/user-attachments/assets/9c3d2488-1c24-4cdd-84cd-87c4397d02a8

> *Workspace overview showing live window previews with drag-and-drop support*

---

## ✨ Features

- 🖼️ Visual workspace overview showing all workspaces and windows
- 🖥️ Multi-monitor support with proper scaling and vertical/rotated monitors [in experimental branch]
- 📐 Smart row hiding - optionally hide empty workspace rows
- 🎯 Click windows to focus them
- 🖱️ Middle-click windows to close them  
- 🔄 Drag and drop windows between workspaces
- ⌨️ Keyboard navigation (Arrow keys, vim keys, number shortcuts)
- 💡 Hover tooltips showing window information
- 🎨 Material Design 3 theming
- ⚡ Smooth animations and transitions

## 📦 Installation

### Arch Linux (AUR)

For Arch Linux users, you can install directly from the AUR:

```bash
# Using yay
yay -S quickshell-overview-git

# Using paru
paru -S quickshell-overview-git
```

Then add the keybind and auto-start to your Hyprland config (see Setup steps 2-4 below).

### Prerequisites

- **Hyprland** compositor
- **Quickshell** ([installation guide](https://quickshell.org/docs/v0.1.0/guide/install-setup/))
- **Qt 6** with modules: QtQuick, QtQuick.Controls

### Setup

1. **Clone this repository** to your Quickshell config directory:
   ```bash
   git clone https://github.com/Shanu-Kumawat/quickshell-overview ~/.config/quickshell/overview
   ```

2. **Add keybind** to your Hyprland config (`~/.config/hypr/hyprland.conf`):
   ```conf
   bind = Super, TAB, exec, qs ipc -c overview call overview toggle
   ```

3. **Auto-start** the overview (add to Hyprland config):
   ```conf
   exec-once = qs -c overview
   ```

4. **Reload Hyprland**:
   ```bash
   hyprctl reload
   ```

### Manual Start (if needed)

```bash
qs -c overview &
```

### NixOS

For NixOS users, ensure Quickshell has access to required Qt6 modules:

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

| Action | Description |
|--------|-------------|
| **Super + Tab** | Toggle the overview |
| **Arrow Keys / h/l** | Navigate left/right within current row* |
| **Up/Down / j/k** | Navigate between workspace rows |
| **1-9, 0** | Jump to Nth workspace in current group (0 = 10th) |
| **Escape / Enter** | Close the overview |
| **Click workspace** | Switch to that workspace |
| **Click window** | Focus that window |
| **Middle-click window** | Close that window |
| **Drag window** | Move window to different workspace |

> *When `hideEmptyRows` is enabled, left/right navigation wraps within the current visible row for better UX

---

## ⚙️ Configuration

> **⚠️ Want to change the size, position, or number of workspaces?**  
> Edit `~/.config/quickshell/overview/common/Config.qml` - it's all there!

### Workspace Grid

Edit `~/.config/quickshell/overview/common/Config.qml`:

```qml
property QtObject overview: QtObject {
    property int rows: 2        // Number of workspace rows
    property int columns: 5     // Number of workspace columns (10 total workspaces)
    property real scale: 0.16   // Overview scale factor (0.1-0.3, smaller = more compact)
    property bool enable: true
    property bool hideEmptyRows: true  // Hide workspace rows with no windows (recommended!)
}
```

**Common adjustments:**
- **Too small?** Increase `scale` (try 0.20 or 0.25)
- **Too big?** Decrease `scale` (try 0.12 or 0.14)
- **More workspaces?** Change `rows` and `columns` (e.g., 3 rows × 4 columns = 12 workspaces)

**Hide empty workspace rows:**
- Set `hideEmptyRows: true` to automatically hide rows that have no windows
- Keeps your overview clean by only showing rows with active workspaces
- The current workspace row is always visible, even if empty
- Arrow key navigation (left/right) stays within the current row when enabled
- Great for 2-row setups where you rarely use workspaces 6-10

### Position

Edit `~/.config/quickshell/overview/modules/overview/Overview.qml` (line ~111):

```qml
anchors {
    horizontalCenter: parent.horizontalCenter
    top: parent.top
    topMargin: 100  // Change this value to move up/down
}
```

### Theme & Colors

Edit `~/.config/quickshell/overview/common/Appearance.qml` to customize:
- Colors (m3colors and colors objects)
- Font families and sizes  
- Animation curves and durations
- Border radius values
##### Use matugen generated colors 
  - add the below config to `config.toml` in matugen config 
```toml
  [templates.quickshell_overview]
  input_path  = "~/.config/matugen/templates/quickshell-overview.qml"
  output_path = "~/.config/quickshell/overview/common/Appearance.colors.qml"
```
  - paste this [matugen overview template](./quickshell-overview.qml) into your `matugen/templates/` folder
  - Now set the below show property to `true` in `common/Appearance.qml`
```qml
 property QtObject appearance: QtObject {
            property bool useMatugenColors: false   // change to true to use matugen colors 
        }
```

---

## 📋 Requirements

- **Hyprland** compositor (tested on latest versions)
- **Quickshell** (Qt6-based shell framework)
- **Qt 6** with the following modules:
  - QtQuick
  - QtQuick.Controls
  - QtQuick.Layouts
  - Quickshell.Wayland
  - Quickshell.Hyprland

## 🚫 Removed Features (from original illogical-impulse)

The following features were removed to make it standalone:

- App search functionality
- Emoji picker
- Clipboard history integration
- Search widget
- Integration with the full illogical-impulse shell ecosystem

## 📁 File Structure

```
~/.config/quickshell/overview/
├── shell.qml                      # Main entry point
├── README.md                      # This file
├── hyprland-config.conf          # Configuration reference
├── common/
│   ├── Appearance.qml            # Theme and styling
│   ├── Config.qml                # Configuration options
│   ├── functions/
│   │   └── ColorUtils.qml        # Color manipulation utilities
│   └── widgets/
│       ├── StyledText.qml        # Styled text component
│       ├── StyledRectangularShadow.qml
│       ├── StyledToolTip.qml
│       └── StyledToolTipContent.qml
├── services/
│   ├── GlobalStates.qml          # Global state management
│   └── HyprlandData.qml          # Hyprland data provider
└── modules/
    └── overview/
        ├── Overview.qml          # Main overview component
        ├── OverviewWidget.qml    # Workspace grid widget
        └── OverviewWindow.qml    # Individual window preview
```

## 🎯 IPC Commands

```bash
# Toggle overview
qs ipc -c overview call overview toggle

# Open overview
qs ipc -c overview call overview open

# Close overview  
qs ipc -c overview call overview close
```

## 🐛 Known Issues

- Window icons may fallback to generic icon if app class name doesn't match icon theme
- Potential crashes during rapid window state changes due to Wayland screencopy buffer management

##  Credits

Extracted from the overview feature in [illogical-impulse](https://github.com/end-4/dots-hyprland) by [end-4](https://github.com/end-4).

Adapted as a standalone component for Hyprland + Quickshell users who want just the overview functionality.

---

<div align="center">

**Note:** Maintenance will be limited due to time constraints, but **PRs and code improvements are welcome!** Feel free to contribute or fork for your own needs.

Made with ❤️ for the Hyprland community

</div>
