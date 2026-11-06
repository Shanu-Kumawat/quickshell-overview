---
weight: 13
title: hyprqt6engine
---

[hyprqt6engine](https://github.com/hyprwm/hyprqt6engine) provides a theme for QT6 apps. It's a replacement for qt6ct, compatible with KDE Apps / KColorScheme.

## Usage

Install, then set `QT_QPA_PLATFORMTHEME=hyprqt6engine`.  
You can set this as `env=` in Hyprland, or in `/etc/environment` for setting it system-wide.

## Configuration

The config file is located in `~/.config/hypr/hyprqt6engine.conf`.

### Theme

category `theme:`

| Variable | Description | Type | Default |
| --- | --- | --- | --- |
| `color_scheme` | The full path to a color scheme. <br> Can be a qt6ct theme, or a KColorScheme. <br> Leave empty for defaults. | string | _empty_ |
| `icon_theme` | Name of an icon theme to use. | string | _empty_ |
| `style` | Widget style to use, e.g. Fusion or kvantum-dark. | string | `Fusion` |
| `font_fixed` | Font family for the fixed width font. | string | `monospace` |
| `font_fixed_size` | Font size for the fixed width font. | int | `11` |
| `font` | Font family for the regular font. | string | `Sans Serif` |
| `font_size` | Font size for the regular font. | int | `11` |

### Misc

category `misc:`

| Variable | Description | Type | Default |
| --- | --- | --- | --- |
| `single_click_activate` | Whether single-clicks should activate, or open. | bool | `true` |
| `menus_have_icons` | Whether context menus should include icons. | bool | `true` |
| `shortcuts_for_context_menus` | Whether context menu options should show their keyboard shortcuts. | bool | `true` |
