---
weight: 1
title: Must have
---

This page documents software that is **strongly** recommended to have running
for a smooth Hyprland experience.

DEs like Plasma or GNOME will take care of this automatically. Hyprland will
not, as you might want to use something else.

### A notification daemon

_Starting method:_ Automatically, via D-Bus activation, when a notification is emitted. Alternatively,
autostart entry inside `hyprland.lua` can be used. The latter might be preferable, if there are several notification daemons installed on your system.

Many apps (e.g. Discord) may freeze without one running.

Examples: `dunst`, `mako`, `fnott` and `swaync`.

### Pipewire

_Starting method:_ Automatic on systemd, manual otherwise.

Pipewire is not necessarily required, but screensharing will not work without
it.

Install `pipewire` and `wireplumber` (**not** `pipewire-media-session`).

#### Non-systemd distros

Since there is no truly standardized way (outside of systemd) to load PipeWire
when starting a graphical shell,[^1] non-systemd distros like Gentoo or Artix
provide a dedicated launcher.

It can be usually found by running `whereis <distro>-pipewire-launcher`. If such
a file does not exist on your install, please refer to your distro's
documentation for help.

[^1]: https://wiki.gentoo.org/wiki/PipeWire#OpenRC

### XDG Desktop Portal

_Starting method:_ Automatic on systemd, manual otherwise.

XDG Desktop Portal handles a lot of stuff for your desktop, like file pickers,
screensharing, etc.

See the [Hyprland Desktop Portal Page.](../../Hypr-Ecosystem/xdg-desktop-portal-hyprland)

### Authentication Agent

_Starting method:_ manual (autostart in config)

Authentication agents are the things that pop up a window asking you for a
password whenever an app wants to elevate its privileges.

See [hyprpolkitagent](../../Hypr-Ecosystem/hyprpolkitagent)

### Qt Wayland Support

_Starting method:_ none (just a library)

Install `qt5-wayland` and `qt6-wayland`.

### Fonts

_Starting method:_ none (just a library)

A `sans-serif` font is required to render text. Without one, you may see squares instead of text. A common choice is `noto-fonts`.

For icons to display correctly, installing a Nerd Font or FontAwesome is recommended. Nerd Fonts will be used by default if available, then FontAwesome, before falling back to text.
