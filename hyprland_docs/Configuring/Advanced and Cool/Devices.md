---
weight: 11
title: Devices
---

> [!NOTE]
> Looking for the old hyprlang syntax? Check the [0.54 wiki pages](https://wiki.hypr.land/0.54.0/).
> Since Hyprland 0.55, hyprlang is deprecated in favor of lua.

For global device configs, check the [Variables](../../Basics/Variables) page. This page
will focus on per-device configs.

A basic per-device config is done via the `hl.device()` fn:

```lua
hl.device({
    name = "my-epic-keyboard",
    sensitivity = -0.5
})
```

The `name` can be easily obtained by checking the output of `hyprctl devices`.

Inside of it, put your config options. All options from the `input` category
(and all subcategories, e.g. `input.touchpad`) can be put inside, **EXCEPT**:

- `force_no_accel`
- Options that configure window management, such as: `follow_mouse`,
  `follow_mouse_threshold`, `float_switch_override_focus`, `mouse_refocus`,
  `special_fallthrough`, etc.


You can also use the `output` setting for tablets to bind them to outputs.
Remember to use the name of the `Tablet` and not `Tablet Pad` or `Tablet Tool`.

Additional properties only present in per-device configs:

- `enabled` -> (only for mice / touchpads / touchdevices / keyboards)
  - enables / disables the device (connects / disconnects from the on-screen cursor)
  - default: Enabled
- `keybinds` -> (only for devices that send key events)
  - enables / disables keybinds for the device
  - default: Enabled
- `tags` -> (only for keyboards / pointers)
  - provides grouping and alt-names is device specific binds (see [Per-Device Binds](../../Basics/Binds#per-device-binds)). comma separated list of tags
  - default: ""

> [!NOTE]
> Per-device layouts will by default not alter the keybind keymap, so for example
> with a global keymap of `us` and a per-device one of `fr`, the keybinds will
> still act as if you were on `us`.
> 
> You can change this behavior by setting `resolve_binds_by_sym = 1`. In that case
> you'll need to type the symbol specified in the bind to activate it.
