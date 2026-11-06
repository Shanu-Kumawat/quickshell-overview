---
weight: 11
title: Other
---

Here you will find links to some other projects that may not fit into any of the
above categories.

### Workspace management

[split-monitor-workspaces](https://github.com/Duckonaut/split-monitor-workspaces) by _Stanisław Zagórowski_: Awesome-like
workspaces for Hyprland.

### Window switchers

[snappy-switcher](https://github.com/OpalAayan/snappy-switcher) by _OpalAayan_: A blazing-fast, animated Alt+Tab window switcher for Hyprland written in C (using Pango and Cairo).

### Keyboard layout management

[hyprland-per-window-layout](https://github.com/coffebar/hyprland-per-window-layout/)
by _MahouShoujoMivutilde and coffebar_: Per window keyboard layouts for
Hyprland.

### Editor support for config files

[HyprLS](https://github.com/hyprland-community/hyprls) by _gwennlbh_: A LSP server to provide auto-completion and more for Hyprland's configuration files in neovim, VS Code & others

### Keybind Management

[hyprKCS](https://github.com/kosa12/hyprKCS) by _kosa12_: A fast, minimal
Hyprland keybind manager written in Rust/GTK4.

### IPC wrappers

[hyprland-rs](https://github.com/yavko/hyprland-rs) by _yavko_: A neat wrapper
for Hyprland's IPC written in Rust.

### Screen shaders/color temperature

- [hyprshade](https://github.com/loqusion/hyprshade) by _loqusion_: Utility for
  swapping and scheduling screen shaders; also functions as an
  [automatic color temperature shifter](https://en.wikipedia.org/wiki/F.lux).
- [gammastep](https://gitlab.com/chinstrap/gammastep) by _Chinstrap_: Control temperature color automatically depending on the time of the day and location.

### Wireless settings

- [iwgtk](https://github.com/J-Lentz/iwgtk) by _Jesse Lentz_: WiFi settings frontend for `iwd` in GTK
- [blueberry](https://github.com/linuxmint/blueberry) by _Linux Mint_: Bluetooth settings frontend in GTK
- [Overskride](https://github.com/kaii-lb/overskride) by _kaii-lb_: A simple yet powerful bluetooth client in GTK4
- [nm-applet](https://gitlab.gnome.org/GNOME/network-manager-applet) by _GNOME_: Applet for interfacing with NetworkManager in GTK

### Automatically Mounting Using `udiskie`

_Starting method:_ manual (autostart in hyprland config)

USB mass storage devices, like thumb drives, mobile phones, digital cameras,
etc. are not mounted automatically to the file system.

Typically, they have to be manually mounted, often using root and `umount` to do so.

Many popular DEs automatically handle this by using `udisks2` wrappers.

`udiskie` is a udisks2 front-end that allows to manage removable media such as
CDs or flash drives from userspace.

Install `udiskie` via your package manager, or
[build manually](https://github.com/coldfix/udiskie/wiki/installation)

Head over to your `hyprland.lua` and add `udiskie` to autostarts.

[See more uses here](https://github.com/coldfix/udiskie/wiki/Usage).

### Monitor configuration

[Monique](https://github.com/ToRvaLDz/monique) by _ToRvaLDz_: Graphical monitor
configurator for Hyprland and Sway with drag-and-drop layout, profile system,
and hotplug daemon for automatic configuration.

### Other useful utilities

The website [We Are Wayland Now](https://wearewaylandnow.com/) details some other useful utilities and applications for Wayland like docks, email clients, and so on, along with some other useful information about compatibility on Wayland.
