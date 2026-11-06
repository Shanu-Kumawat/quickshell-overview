---
weight: 2
title: hyprpicker
---

[hyprpicker](https://github.com/hyprwm/hyprpicker) is a neat utility for picking a color from your screen on Hyprland.

## Configuration

Doesn't require configuration, only launch flags:

| Flag | Description | Args |
| --- | --- | --- |
| `-a` \| `--autocopy` | Automatically copies the output to the clipboard (requires wl-clipboard) | none |
| `-f` \| `--format=` | Specifies the output format | `cmyk` \| `hex` \| `rgb` \| `hsl` \| `hsv` |
| `-o` \| `--output-format=` | Specifies how the output color should be formatted | string format e.g. "rgb({0}, {1}, {2})" |
| `-n` \| `--notify` | Sends a desktop notification when a color is picked (requires notify-send and a notification daemon like dunst) | none |
| `-b` \| `--no-fancy` | Disables the "fancy" (aka. colored) outputting | none |
| `-h` \| `--help` | Shows the help message | none |
| `-r` \| `--render-inactive` | Render (freeze) inactive displays | none |
| `-z` \| `--no-zoom` | Disable the zoom lens | none |
| `-q` \| `--quiet` | Disable most logs (leaves errors) | none |
| `-v` \| `--verbose` | Enable more logs | none |
| `-t` \| `--no-fractional` | Disable fractional scaling support | none |
| `-d` \| `--disable-hex-preview` | Disable live preview of Hex code | none |
| `-l` \| `--lowercase-hex` | Outputs the hexcode in lowercase | none |
| `-s` \| `--scale=scale` | Set the zoom scale | float between 1.0 and 10.0 |
| `-u` \| `--radius=radius` | Set the circle radius | int between 1 and 1000 |
| `-V` \| `--version` | Print version info | none |

