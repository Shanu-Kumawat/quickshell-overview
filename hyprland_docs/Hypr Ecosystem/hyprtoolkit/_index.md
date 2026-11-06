---
weight: 100
title: hyprtoolkit
---

[hyprtoolkit](https://github.com/hyprwm/hyprtoolkit) is a GUI toolkit for developing applications that run natively on Wayland.  
It's specifically made for Hyprland's needs, but will generally run on any Wayland compositor
that supports modern standards.

For developer docs, see [development](./development)

## Configuration

The general toolkit config is at `~/.config/hypr/hyprtoolkit.conf`.  
It contains theming and some minor adjustments and supports the same color options as hyprland.

| Variable | Description | Type | Default |
| --- | --- | --- | --- |
| `background` | Background color. | color | `0xFF181818` |
| `base` | Base color. | color | `0xFF202020` |
| `text` | Text color. | color | `0xFFDADADA` |
| `alternate_base` | Alternative base color. | color | `0xFF272727` |
| `bright_text` | Bright text color. | color | `0xFFFFDEDE` |
| `accent` | Accent color. | color | `0xFF00FFCC` |
| `accent_secondary` | Secondary accent color. | color | `0xFF0099F0` |
| `h1_size` | Font size for H1. | int | `19` |
| `h2_size` | Font size for H2. | int | `15` |
| `h3_size` | Font size for H3. | int | `13` |
| `font_size` | Font size for regular text elements. | int | `11` |
| `small_font_size` | Font size for small text elements. | int | `10` |
| `icon_theme` | Name of the icon theme to use, empty for "the first found". | string | _empty_ |
| `font_family` | Name of the font family to use. | string | `Sans Serif` |
| `font_family_monospace` | Name of the monospace font family to use. | string | `monospace` |
| `rounding_large` | Big rounding in logical px | int | `10` |
| `rounding_small` | Small rounding in logical px | int | `5` |