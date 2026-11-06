---
weight: 7
title: xdg-desktop-portal-hyprland
---

An XDG Desktop Portal is a program that lets other applications communicate with
the compositor through D-Bus.

A portal implements certain functionalities, such as opening file pickers or
screen sharing.

[xdg-desktop-portal-hyprland](https://github.com/hyprwm/xdg-desktop-portal-hyprland)
is Hyprland's xdg-desktop-portal implementation. It allows for screensharing,
global shortcuts, etc.

> [!NOTE]
> Throughout this document, `xdg-desktop-portal-hyprland` will be referred to as
> XDPH.

> [!WARNING]
> XDPH doesn't implement a file picker. For that, it is recommended to install
> `xdg-desktop-portal-gtk` alongside XDPH.

## Installing

{{< tabs items="Arch Linux,NixOS,Gentoo,Manual" >}}

{{< tab "Arch Linux" >}}

```sh
pacman -S xdg-desktop-portal-hyprland
```

or, for -git:

```sh
yay -S xdg-desktop-portal-hyprland-git
```

{{< /tab >}}

{{< tab "NixOS" >}}

On NixOS, XDPH is already enabled by the
[NixOS module for Hyprland](../../Nix/Hyprland-on-NixOS), through
`programs.hyprland.enable = true;`.

{{< /tab >}}

{{< tab "Gentoo" >}}

### Unmask Dependencies

```plain {filename="/etc/portage/profile/package.unmask"}
dev-qt/qtbase
dev-qt/qtwayland
dev-qt/qtdeclarative
dev-qt/qtshadertools
```

### Apply Necessary useflags

```plain {filename="/etc/portage/package.use"}
dev-qt/qtbase opengl egl eglfs gles2-only
dev-qt/qtdeclarative opengl
sys-apps/xdg-desktop-portal screencast
```

### Unmask Dependencies and xdph

```plain {filename="/etc/portage/package.accept_keywords"}
gui-libs/xdg-desktop-portal-hyprland 
dev-qt/qtbase
dev-qt/qtwayland
dev-qt/qtdeclarative
dev-qt/qtshadertools
```

btw those are the useflags that I have tested, you could also test others.

### Installation

```sh
eselect repository enable guru
emaint sync -r guru
emerge --ask --verbose gui-libs/xdg-desktop-portal-hyprland
```

{{< /tab >}}

{{< tab "Manual" >}}

See
[The GitHub repo's readme](https://github.com/hyprwm/xdg-desktop-portal-hyprland).

{{</ tab >}}

{{< /tabs >}}

## Usage

XDPH is automatically started by D-Bus, once Hyprland starts.

To check if everything is OK is, try to screenshare anything, or opening OBS and
select the PipeWire source.  
If XDPH is running, a Qt menu will pop up asking you what to share.

XDPH will work on other wlroots compositors, but features available only on
Hyprland will not work (e.g. window sharing).

For a nuclear option, you can use this script and autostart it:

```sh
#!/bin/sh
sleep 1
killall -e xdg-desktop-portal-hyprland
killall xdg-desktop-portal
/usr/lib/xdg-desktop-portal-hyprland &
sleep 2
/usr/lib/xdg-desktop-portal &
```

Adjust the paths if they're incorrect.

## Share Picker Doesn't Use the System Theme

Try one or both:

```sh
dbus-update-activation-environment --systemd --all
systemctl --user import-environment QT_QPA_PLATFORMTHEME
```

If it works, add it to your config in autostarts.

## Using the KDE File Picker With XDPH

XDPH does not implement a file picker and uses the GTK one as a fallback by
default (see `/usr/share/xdg-desktop-portal/hyprland-portals.conf`). If you want
to use the KDE file picker but let XDPH handle everything else, create a file
`~/.config/xdg-desktop-portal/hyprland-portals.conf` with the following content:

```ini {filename="~/.config/xdg-desktop-portal/hyprland-portals.conf"}
[preferred]
default = hyprland;gtk
org.freedesktop.impl.portal.FileChooser = kde
```

You can read more about this in the
[xdg-desktop-portal documentation in the Arch Wiki](https://wiki.archlinux.org/title/XDG_Desktop_Portal).
Note that some applications like Firefox may require additional configuration to
use the KDE file picker.

## Debugging

If you get long app launch times, or screensharing does not work, consult the
logs.

`systemctl --user status xdg-desktop-portal-hyprland`

If you see a crash, it's likely you are missing either `qt6-wayland` or
`qt5-wayland`.

If the portal does not autostart, does not function when manually started,
and does not produce any error logs, it's very likely your [XDG env variables](../../Configuring/Advanced-and-Cool/Environment-variables/#xdg-specifications)
are messed up

## Configuration

Example:

```ini
screencopy {
    max_fps = 60
}
```

Config file `~/.config/hypr/xdph.conf` allows for these variables:

### category screencopy

| Variable | Description | Type | Default |
| -- | -- | -- | -- |
| `max_fps`  | Maximum fps of a screensharing session. <br> `0` means no limit. | int | `120` |
| `allow_token_by_default`  | If enabled, will tick the "Allow restore token" box by default. | bool  | `false` |
| `custom_picker_binary`  | If non-empty, will use that **binary** as your share picker. <br> Please note that it has to conform to the stdout selection layout of `hyprland-share-picker`. | string  | `"hyprland-share-picker"` |
| `force_shm` | If enabled, will skip DMA-BUF and always use SHM for screensharing. SHM is slower than DMA-BUF (especially at high resolutions) but can work around DMA-BUF allocation failures on multi-GPU systems. | bool | `false` |
