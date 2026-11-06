---
weight: 60
title: XWayland
---

> [!NOTE]
> Looking for the old hyprlang syntax? Check the [0.54 wiki pages](https://wiki.hypr.land/0.54.0/).
> Since Hyprland 0.55, hyprlang is deprecated in favor of lua.

XWayland is the bridging mechanism between legacy Xorg programs and Wayland
compositors.

## HiDPI XWayland

XWayland currently looks pixelated on HiDPI screens, due to Xorg's inability to
scale.

This problem is mitigated by the
[`hl.config({ xwayland = { force_zero_scaling = true } })`](../../Basics/Variables/#xwayland) option,
which forces XWayland windows not to be scaled.

This will get rid of the pixelated look, but will not scale applications
properly. To do this, each toolkit has its own mechanism.

```lua
-- change monitor to high resolution, the last argument is the scale factor
hl.monitor({ output = "", mode = "highres", position = "auto", scale = "2" })

-- unscale XWayland
hl.config({
  xwayland = {
    force_zero_scaling = true
  }
})

-- toolkit-specific scale
hl.env("GDK_SCALE", "2")
hl.env("XCURSOR_SIZE", "32")
```

The GDK_SCALE variable won't conflict with Wayland-native GTK programs.

> [!WARNING]
> XWayland HiDPI patches are no longer supported. Do not use them.

## Abstract Unix domain socket

X11 applications use Unix domain sockets to communicate with XWayland. On Linux, libX11 prefers
to use the abstract Unix domain socket. This type of socket uses a separate, abstract namespace that
is independent of the host filesystem. This makes abstract sockets more flexible
but harder to [isolate](https://github.com/hyprwm/Hyprland/pull/8874)
for some kinds of sandboxes like Flatpak. However, removing the abstract socket
has [potential](https://gitlab.gnome.org/GNOME/mutter/-/issues/1613) security
and compatibility issues.

Keeping that in mind, we add the [`xwayland:create_abstract_socket`](../../Basics/Variables/#xwayland) option.
When the abstract socket is disabled, only the regular Unix domain
socket will be created.

_\* Abstract Unix domain sockets are available only on Linux-based systems_
