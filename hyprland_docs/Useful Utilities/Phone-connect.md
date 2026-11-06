---
weight: 7
title: Phone connect
---

This page lists utilities for connecting phones to a Hyprland session, including
device integration, file access, screen mirroring, and quick local file sharing.

## Phone integration

### KDE Connect

[KDE Connect](https://kdeconnect.kde.org/) integrates phones with the desktop.
It can share files and clipboard contents, show phone notifications, ring or
find a device, and expose remote input features.

Install [hypr-kdeconnect-fix](https://github.com/gfhdhytghd/hypr-kdeconnect-fix) to make the remote input funtion of kde connect work.

## Device access

### Android: adb and MTP

Install `android-tools` for `adb`. Enable USB debugging on the phone, then check
that the device is visible:

For file-manager access over MTP, install `gvfs-mtp`. This lets GVfs-aware file
managers browse Android storage after the phone is unlocked and set to file
transfer mode.

### iOS: libimobiledevice and ifuse

Install [`libimobiledevice`](https://libimobiledevice.org/) and
[`ifuse`](https://github.com/libimobiledevice/ifuse) for iPhone and iPad access.

Package names and service handling vary by distro. Some setups also need
`usbmuxd` running for iOS devices.

## Screen mirroring

### scrcpy

[`scrcpy`](https://github.com/Genymobile/scrcpy) displays and controls Android
devices over USB or TCP/IP using `adb`. It is lightweight and works well when
USB debugging is enabled.

### Escrcpy

[Escrcpy](https://github.com/viarotel-org/escrcpy) is a graphical frontend built
around `scrcpy`. It can be useful if you prefer managing multiple Android
devices, mirroring options, and common actions from a GUI instead of command-line
flags.

## Quick local file sharing

### LocalSend

[LocalSend](https://localsend.org/) is a cross-platform local-network file
sharing application. Install it on both devices, keep them on the same network,
and send files without setting up SSH, SMB, or cloud storage.

### Fyde Drop

[Fyde Drop](https://drop.fydeos.io/) is a browser-based local-network file sharing
tool. Open the page on both devices and use it for quick one-off transfers when
you do not want to install an application.
