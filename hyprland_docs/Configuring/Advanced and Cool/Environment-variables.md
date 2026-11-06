---
weight: 70
title: Environment variables
---

> [!NOTE]
> Looking for the old hyprlang syntax? Check the [0.54 wiki pages](https://wiki.hypr.land/0.54.0/).
> Since Hyprland 0.55, hyprlang is deprecated in favor of lua.

> [!NOTE]
> [uwsm](../../../Useful-Utilities/Systemd-start) users should avoid placing environment variables in the `hyprland.lua` file.  
> Instead, use `~/.config/uwsm/env` for theming, xcursor, Nvidia and toolkit variables, and `~/.config/uwsm/env-hyprland` for `HYPR*` and `AQ_*` variables.  
> The format is `export KEY=VAL`.
> 
> ```plain
> export XCURSOR_SIZE=24
> ```
> 
> See [uwsm readme](https://github.com/Vladimir-csp/uwsm?tab=readme-ov-file#4-environments-and-shell-profile) for additional information.

You can use the `hl.env()` method to set environment variables prior to the
initialization of the Display Server, e.g.:

```lua
hl.env("GTK_THEME", "Nord")
```

> [!NOTE]
> When referencing existing environment variables like `$XDG_RUNTIME_DIR`, use `os.getenv()`, eg.:
> `hl.env("SSH_AUTH_SOCK", os.getenv("XDG_RUNTIME_DIR").."/ssh-agent.socket")`

> [!WARNING]
> Please avoid putting those environment variables in `/etc/environment`.  
> That will cause all sessions (including Xorg ones) to pick up your Wayland-specific
> environment on traditional Linux distros.

## Hyprland Environment Variables

- `hl.env("HYPRLAND_TRACE", "1")` - Enables more verbose logging.
- `hl.env("HYPRLAND_NO_RT", "1")` - Disables realtime priority setting by Hyprland.
- `hl.env("HYPRLAND_NO_SD_NOTIFY", "1")` - If systemd, disables the `sd_notify` calls.
- `hl.env("HYPRLAND_NO_SD_VARS", "1")` - Disables management of variables in systemd and dbus activation environments.
- `hl.env("HYPRLAND_CONFIG", "/path/to/hyprland.lua")` - Specifies where you want your Hyprland configuration.

## Aquamarine Environment Variables <!-- ref https://github.com/hyprwm/aquamarine/blob/main/docs/env.md -->

- `hl.env("AQ_TRACE", "1")` - Enables more verbose logging.
- `hl.env("AQ_DRM_DEVICES", "...")` - Set an explicit list of DRM devices (GPUs) to use. It's a colon-separated list of paths, with the first being the primary.
  E.g.: `/dev/dri/card1:/dev/dri/card0`
- `hl.env("AQ_FORCE_LINEAR_BLIT", "0")` - Disables forcing linear explicit modifiers on Multi-GPU buffers to potentially workaround Nvidia issues.
- `hl.env("AQ_MGPU_NO_EXPLICIT", "1")` - Disables explicit syncing on mgpu buffers.
- `hl.env("AQ_NO_MODIFIERS", "1")` - Disables modifiers for DRM buffers.
- `hl.env("AQ_NO_KMS_REQUIREMENT", "1")` - Disable KMS requirement for starting on headless GPUs.

## Toolkit Backend Variables

- `hl.env("GDK_BACKEND", "wayland,x11,*")` - GTK: Use Wayland if available; if not, try X11 and  then any other GDK backend.
- `hl.env("QT_QPA_PLATFORM", "wayland;xcb")` - Qt: Use Wayland if available, fall back to
  X11 if not.
- `hl.env("SDL_VIDEODRIVER", "wayland")` - Run SDL2 applications on Wayland. Remove or set to
  `x11` if games that provide older versions of SDL cause compatibility issues
- `hl.env("CLUTTER_BACKEND", "wayland")` - Clutter package already has Wayland enabled, this
  variable will force Clutter applications to try and use the Wayland backend

## XDG Specifications

- `hl.env("XDG_CURRENT_DESKTOP", "Hyprland")`
- `hl.env("XDG_SESSION_TYPE", "wayland")`
- `hl.env("XDG_SESSION_DESKTOP", "Hyprland")`

XDG specific environment variables are often detected through portals and
applications that may set those for you, however it is not a bad idea to set
them explicitly.

If your [desktop portal](https://wiki.archlinux.org/title/XDG_Desktop_Portal) is malfunctioning for seemingly
no reason (no errors), it's likely your XDG env isn't set correctly.

> [!NOTE]
> [uwsm](../../../Useful-Utilities/Systemd-start) users don't need to explicitly set XDG environment variables, as uwsm sets them automatically.

## Qt Variables

- `hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")` -
  [(From the Qt documentation)](https://doc.qt.io/qt-5/highdpi.html) enables
  automatic scaling, based on the monitor's pixel density
- `hl.env("QT_QPA_PLATFORM", "wayland;xcb")` - Tell Qt applications to use the Wayland
  backend, and fall back to X11 if Wayland is unavailable
- `hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")` - Disables window decorations on Qt
  applications
- `hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")` - Tells Qt based applications to pick your theme
  from qt5ct, use with Kvantum.

## NVIDIA Specific

To force GBM as a backend, set the following environment variables:

- `hl.env("GBM_BACKEND", "nvidia-drm")`
- `hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")`

> See
> [Archwiki Wayland Page](https://wiki.archlinux.org/title/Wayland#Requirements)
> for more details on those variables.

- `hl.env("LIBVA_DRIVER_NAME", "nvidia")` - Hardware acceleration on NVIDIA GPUs

> See
> [Archwiki Hardware Acceleration Page](https://wiki.archlinux.org/title/Hardware_video_acceleration)
> for details and necessary values before setting this variable.

- `__GL_GSYNC_ALLOWED` - Controls if G-Sync capable monitors should use Variable
  Refresh Rate (VRR)

> See
> [Nvidia Documentation](https://download.nvidia.com/XFree86/Linux-32bit-ARM/375.26/README/openglenvvariables.html)
> for details.

- `__GL_VRR_ALLOWED` - Controls if Adaptive Sync should be used. Recommended to
  set as "0" to avoid having problems on some games.

- `hl.env("AQ_NO_ATOMIC", "1")` - use legacy DRM interface instead of atomic mode
  setting. **NOT** recommended.

## Theming Related Variables

- `GTK_THEME` - Set a GTK theme manually, for those who want to avoid appearance
  tools such as lxappearance or nwg-look.
- `XCURSOR_THEME` - Set your cursor theme. The theme needs to be installed and
  readable by your user.
- `XCURSOR_SIZE` - Set cursor size. See [here](../../../FAQ) for why you might
  want this variable set.
