---
weight: 3
title: hyprlauncher
---

[hyprlauncher](https://github.com/hyprwm/hyprlauncher) is a multipurpose and versatile launcher / picker for hyprland. It's fast, simple, and provides
various modules.

## Usage

Hyprlauncher is _always_ a daemon. Launching it spawns a daemon that will listen to
requests. If launched with `hyprlauncher -d`, it will not open a window for the first launch.

To open hyprlauncher, just bind `hyprlauncher` to a key.

## Configuration

### Theming

Theme follows your [hyprtoolkit](../hyprtoolkit) theme.

### Config

`~/.config/hypr/hyprlauncher.conf`

Config categories and their values:

#### General

| Option | Description | Type | Default |
| -- | -- | -- | -- |
| `grab_focus` | Whether to force a full keyboard focus grab. | bool | `true` |


#### Cache

| Option | Description | Type | Default |
| -- | -- | -- | -- |
| enabled | Controls whether modules keep a cache of often used entries. <br> That history is stored on your disk, in plain text, in `~/.local/share/hyprlauncher`. | bool | `true` |

#### Finders

Available finders: `math`, `desktop`, `unicode`.

Prefixes can only be one character.

| option | description | type | default |
| -- | -- | -- | -- |
| `default_finder` | Controls the default finder used. | string | `desktop` |
| `desktop_prefix` | Prefix for the desktop finder to be used. | string | empty |
| `unicode_prefix` | Prefix for the unicode finder to be used. | string | `.` |
| `math_prefix` | Prefix for the math finder to be used. | string | `=` |
| `font_prefix` | Prefix for the font finder to be used. | string | `'` |
| `desktop_launch_prefix` | Launch prefix for each desktop app, e.g. `uwsm app -- `. | string | empty |
| `desktop_icons` | Whether to enable desktop icons in the results. | bool | `true` |

#### UI

| option | description | type | default |
| -- | -- | -- | -- |
| window_size | the size of the launcher | vec2 | `400 260` |

