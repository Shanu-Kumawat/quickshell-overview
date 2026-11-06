---
weight: 20
title: Dwindle Layout
---

> [!NOTE]
> Looking for the old hyprlang syntax? Check the [0.54 wiki pages](https://wiki.hypr.land/0.54.0/).
> Since Hyprland 0.55, hyprlang is deprecated in favor of lua.

Dwindle is a BSPWM-like layout, where every window on a workspace is a member of
a binary tree.

<video width="1024" height="566" autoplay muted>
  <source src="https://dl.hypr.land/wiki/demo_dwindle.mp4" type="video/mp4">
</video>

## Quirks

Dwindle splits are NOT PERMANENT. The split is determined dynamically with the
W/H ratio of the parent node. If W > H, it's side-by-side. If H > W, it's
top-and-bottom. You can make them permanent by enabling `preserve_split`.

## Config

category name: `dwindle`

| name | description | type | default |
| --- | --- | --- | --- |
| force_split | 0 -> split follows mouse, 1 -> always split to the left (new = left or top) 2 -> always split to the right (new = right or bottom) | int | `0` |
| preserve_split | if enabled, the split (side/top) will not change regardless of what happens to the container. | bool | `false` |
| smart_split | if enabled, allows a more precise control over the window split direction based on the cursor's position. The window is conceptually divided into four triangles, and cursor's triangle determines the split direction. This feature also turns on preserve_split. | bool | `false` |
| smart_resizing | if enabled, resizing direction will be determined by the mouse's position on the window (nearest to which corner). Else, it is based on the window's tiling position. | bool | `true` |
| permanent_direction_override | if enabled, makes the preselect direction persist until either this mode is turned off, another direction is specified, or a non-direction is specified (anything other than l,r,u/t,d/b) | bool | `false` |
| special_scale_factor | specifies the scale factor of windows on the special workspace [0 - 1] | float | `1` |
| split_width_multiplier | specifies the auto-split width multiplier. Multiplying window size is useful on widescreen monitors where window W > H even after several splits. | float | `1.0` |
| use_active_for_splits | whether to prefer the active window or the mouse position for splits | bool | `true` |
| default_split_ratio | the default split ratio on window open. 1 means even 50/50 split. [0.1 - 1.9] | float | `1.0` |
| split_bias | specifies which window will receive the split ratio. 0 -> directional (the top or left window), 1 -> the current window | int | `0` |
| precise_mouse_move | bindm movewindow will drop the window more precisely depending on where your mouse is. | bool | `false` |

```lua
hl.config({
  dwindle = {
      force_split                  = 0,
      preserve_split               = false,
      smart_split                  = false,
      smart_resizing               = true,
      permanent_direction_override = false,
      special_scale_factor         = 1,
      split_width_multiplier       = 1.0,
      use_active_for_splits        = true,
      default_split_ratio          = 1.0,
      split_bias                   = 0,
      precise_mouse_move           = false,
  },
})
```

## Dispatchers

| dispatcher | description | params |
| --- | --- | --- |
| window.pseudo | toggles the given window's pseudo mode | left empty / `"active"` for current, or `"window"` for a specific window |

```lua
hl.bind("SUPER + P", hl.dsp.window.pseudo())
```

## Layout Messages

Dispatcher `hl.dsp.layout(msg)` params:

| param | description | args |
| --- | --- | --- |
| splitratio | changes the split ratio | float [0.1-1.9] |
| togglesplit | toggles the split (top/side) of the current window. `preserve_split` must be enabled for toggling to work. | none |
| swapsplit | swaps the two halves of the split of the current window. | none |
| preselect | A one-time override for the split direction. (valid for the next window to be opened, only works on tiled windows) | direction |
| movetoroot | moves the selected window (active window if unspecified) to the root of its workspace tree. The default behavior maximizes the window in its current subtree. If `unstable` is provided as the second argument, the window will be swapped with the other subtree instead. It is not possible to only provide the second argument, but `movetoroot active unstable` will achieve the same result. | [window, [ string ]] |

>[!NOTE]
>`splitratio` defaults to using a positive delta, so `"splitratio 0.5"` will make the current
>split move to the right by 0.5. You can also explicitly make it a positive delta with 
>`"splitratio +0.5"`. 
>
>Likewise, `"splitratio -0.5"` will move it to the left by 0.5. 
>
>Finally, we can use the `exact` keyword after a value to specifically set the split ratio to 
>that value. `"splitratio 1.0 exact"` will _always_ put the split in the exact center.

Example usage:

```lua
hl.bind("SUPER + A", hl.dsp.layout("togglesplit"))
```
