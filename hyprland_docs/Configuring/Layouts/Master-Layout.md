---
weight: 21
title: Master Layout
---

> [!NOTE]
> Looking for the old hyprlang syntax? Check the [0.54 wiki pages](https://wiki.hypr.land/0.54.0/).
> Since Hyprland 0.55, hyprlang is deprecated in favor of lua.

The master layout makes one (or more) window(s) be the "master", taking (by
default) the left part of the screen, and tiles the rest on the right. You can
change the orientation on a per-workspace basis if you want to use anything other
than the default left/right split.

<video width="1024" height="566" autoplay muted>
  <source src="https://dl.hypr.land/wiki/demo_master.mp4" type="video/mp4">
</video>

## Config

category name `master` (`hl.config({ master = {...} })`)

| name | description | type | default |
| --- | --- | --- | --- |
| allow_small_split | enable adding additional master windows in a horizontal split style | bool | `false` |
| special_scale_factor | the scale of the special workspace windows. [0.0 - 1.0] | float | `1` |
| mfact | the size as a percentage of the master window, for example `mfact = 0.70` would mean 70% of the screen will be the master window, and 30% the slave [0.0 - 1.0] | floatvalue | `0.55 `|
| new_status | `"master"`: new window becomes master; `"slave"`: new windows are added to slave stack; `"inherit"`: inherit from focused window | string | `"slave"` |
| new_on_top | whether a newly open window should be on the top of the stack | bool | `false` |
| new_on_active | `"before"`, `"after"`: place new window relative to the focused window; `"none"`: place new window according to the value of `new_on_top`.  | string | `"none"` |
| orientation | default placement of the master area, can be `"left"`, `"right"`, `"top"`, `"bottom"` or `"center"` | string | `"left"` |
| slave_count_for_center_master | when using orientation=center, make the master window centered only when at least this many slave windows are open. (Set 0 to always_center_master) | int | `2` |
| center_master_fallback | Set fallback for center master when slaves are less than slave_count_for_center_master, can be `"left"`, `"right"`, `"top"`, `"bottom"` | string | `"left"` |
| smart_resizing | if enabled, resizing direction will be determined by the mouse's position on the window (nearest to which corner). Else, it is based on the window's tiling position. | bool | `true` |
| drop_at_cursor | when enabled, dragging and dropping windows will put them at the cursor position. Otherwise, when dropped at the stack side, they will go to the top/bottom of the stack depending on new_on_top. | bool | `true` |
| always_keep_position | whether to keep the master window in its configured position when there are no slave windows | bool | `false` |
| focus_master_on_close | when enabled, closing a window focuses the master window | bool | `false` |

## Layout messages

Dispatcher `hl.dsp.layout(string)` params:

| command | description | params |
| --- | --- | --- |
| swapwithmaster | swaps the current window with master. If the current window is the master, swaps it with the first child. | either `master` (new focus is the new master window), `child` (new focus is the new child) or `auto` (which is the default, keeps the focus of the previously focused window). Adding `ignoremaster` will ignore this dispatcher if master is already focused. |
| focusmaster | focuses the master window. | either `master` (focus stays on master), `auto` (default; focus first non-master window if already on master) or `previous` (remember current window when focusing master, if already on master, focus previous or fallback to `auto`). |
| cyclenext | focuses the next window respecting the layout | either `loop` (allow looping from the bottom of the pile back to master) or `noloop` (force stop at the bottom of the pile, like in DWM). `loop` is the default if left blank. |
| cycleprev | focuses the previous window respecting the layout | either `loop` (allow looping from master to the bottom of the pile) or `noloop` (force stop at master, like in DWM). `loop` is the default if left blank. |
| swapnext | swaps the focused window with the next window respecting the layout | either `loop` (allow swapping the bottom of the pile and master) or `noloop` (do not allow it, like in DWM). `loop` is the default if left blank. |
| swapprev | swaps the focused window with the previous window respecting the layout | either `loop` (allow swapping master and the bottom of the pile) or `noloop` (do not allow it, like in DWM). `loop` is the default if left blank. |
| addmaster | adds a master to the master side. That will be the active window, if it's not a master, or the first non-master window. | none |
| removemaster | removes a master from the master side. That will be the active window, if it's a master, or the last master window. | none |
| orientationleft | sets the orientation for the current workspace to left (master area left, slave windows to the right, vertically stacked) | none |
| orientationright | sets the orientation for the current workspace to right (master area right, slave windows to the left, vertically stacked) | none |
| orientationtop | sets the orientation for the current workspace to top (master area top, slave windows to the bottom, horizontally stacked) | none |
| orientationbottom | sets the orientation for the current workspace to bottom (master area bottom, slave windows to the top, horizontally stacked) | none |
| orientationcenter | sets the orientation for the current workspace to center (master area center, slave windows alternate to the left and right, vertically stacked) | none |
| orientationnext | cycle to the next orientation for the current workspace (clockwise) | none |
| orientationprev | cycle to the previous orientation for the current workspace (counter-clockwise) | none |
| orientationcycle | cycle to the next orientation from the provided list, for the current workspace | allowed values: `left`, `top`, `right`, `bottom`, or `center`. The values have to be separated by a space. If left empty, it will work like `orientationnext` |
| mfact | change mfact, the master split ratio | the new split ratio, a relative float delta (e.g `-0.2` or `+0.2`) or `exact` followed by a the exact float value between 0.0 and 1.0 |
| rollnext | rotate the next window in stack to be the master, while keeping the focus on master | none |
| rollprev | rotate the previous window in stack to be the master, while keeping the focus on master | none |

Parameters for the commands are separated by a single space.

> [!NOTE]
> Example usage:
> 
> ```lua
> hl.bind(KEYS, hl.dsp.layout("cyclenext"))
> -- behaves like xmonads promote feature (https://hackage.haskell.org/package/xmonad-contrib-0.17.1/docs/XMonad-Actions-Promote.html)
> hl.bind(KEYS, hl.dsp.layout("swapwithmaster master"))
> ```

## Workspace Rules

`layout_opts` rules:

| rule | description | type |
| --- | --- | --- |
| orientation = [o] | Sets the orientation of a workspace. For available orientations, see [Config->orientation](#config) | string |

Example usage:

```lua
hl.workspace_rule({ workspace = "2", layout_opts =  { orientation = "top" } })
```
