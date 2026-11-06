---
weight: 6
title: Dispatchers
---

> [!NOTE]
> Looking for the old hyprlang syntax? Check the [0.54 wiki pages](https://wiki.hypr.land/0.54.0/).
> Since Hyprland 0.55, hyprlang is deprecated in favor of lua.

Please keep in mind some layout-specific dispatchers will be listed in the
layout pages (See the sidebar).

## Dispatchers

Dispatchers return tables that describe an action you want to make. They do not invoke any action immediately, and their
contents are not guaranteed to be stable at all. Their purpose is to be fed into `hl.bind()` or `hl.dispatch()`.

### Parameter explanation

|  Param type | Description  |
|---|---|
| `action` | `toggle`(default if no value given), `enable`/`on`, `disable`/`off` |

#### Window

A window. Can be:
 - window object
 - regexes:
   - `class:...`
   - `initialclass:...`
   - `title:...`
   - `initialtitle:...`
   - `tag:...`
 - exact selectors:
   - `pid:...`
   - `address:0x...`
 - `activewindow`
 - `floating`
 - `tiled`

If no window is provided, the active window is used.

#### Workspace

A workspace. Can be:
 - workspace object
 - workspace ID
 - workspace selector, see [below](#workspace-selectors)

#### Direction

A simple direction. `l` / `r` / `u` / `d`

#### Monitor

A monitor. Can be:
 - monitor object
 - monitor ID
 - direction
 - name
 - `desc:` and description
 - `current`
 - relative: `+1` / `-2`

## Dispatchers

### General

`hl.dsp.` contains:

| method | description |
| --- | --- |
| `exec_cmd(cmd, rules?)` | execute a command. Rules can be a table of window rule effects to apply (see [below](#executing-with-rules)). |
| `exec_raw(cmd)` | execute a raw command. While `exec_cmd` will do `sh -c`, this won't. |
| `focus({ direction })` | move the focus in a direction |
| `focus({ monitor })` | move the focus to a monitor |
| `focus({ workspace, on_current_monitor? })` | move the focus to a workspace |
| `focus({ window })` | move the focus to a window |
| `focus({ urgent_or_last })` | move the focus to an urgent, or last window |
| `focus({ last })` | move the focus to the last window |
| `exit()` | quit Hyprland. It's recommended to use `hyprshutdown` instead of this. |
| `submap(name)` | move to a submap |
| `pass({ window? })` | pass the shortcut to a window |
| `send_shortcut({ mods, key, window? })` | send a specific shortcut to a window |
| `send_key_state({ mods, key, state, window? })` | same as above, but you control `down` / `up` |
| `layout(message)` | send a layout message as a string |
| `dpms({ action?, monitor? })` | toggle monitors on/off (not physically, as in idle-screensaver.) |
| `event(string)` | send an event to socket2. |
| `global(string)` | activate a dbus global shortcut. See [Binds > Global Shortcuts](../Binds#DBus-Global-Shortcuts) |
| `force_idle(seconds)` | sets elapsed time for all idle timers, ignoring idle inhibitors. Timers return to normal behavior upon the next activity. Do not use with a keybind directly. |
| `no_op()` | does nothing. Useful for conditional binds. |

### Window

`hl.dsp.window.` contains:

| method | description |
| --- | --- |
| `close(window?)` | Close a window. |
| `kill(window?)` | Kill a window |
| `signal({ signal, window? })` | send a signal to a window process |
| `float({ action?, window? })` | set a window's floating state. |
| `fullscreen({ mode?, action?, window? })` | set a window's fullscreen state. `mode` can be "maximized" and "fullscreen". `action` can be `toggle`/`set`/`unset` |
| `fullscreen_state({ internal, client, action?, window? })` | set a window's fullscreen state with more precision. `action` can be `toggle`/`set`/`unset`. See [Fullscreenstate](#fullscreenstate) |
| `pseudo({ action?, window? })` | set a window's pseudotiling state. |
| `move({ direction, group_aware? })` | move a window in a direction. `group_aware = true` will put windows in/out of groups alongside the given direction. |
| `move({ workspace, follow? })` | move a window to a workspace |
| `move({ monitor, follow? })` | move a window to a monitor |
| `move({ x, y, relative? })` | move a window by / to a coord |
| `move({ into_group = direction })` | move a window into a group in a direction |
| `move({ into_or_create_group = direction })` | move a window into a group in a direction, or create a group if no group exists in that direction |
| `move({ out_of_group })` | move a window out of a group. `true` for directionless, direction for a direction |
| `swap({ direction })` | swap the current window with another one in a given direction | 
| `swap({ target })` | swap the current window with another one | 
| `swap({ next })` | swap the current window with the next one | 
| `swap({ prev })` | swap the current window with the previous one | 
| `center({ window? })` | center the current window on screen |
| `cycle_next({ next?, tiled?, floating?, window? })` | focus the next window |
| `tag({ tag, window? })` | tag a window |
| `clear_tags({ window? })` | clear all tags from a window |
| `toggle_swallow()` | toggle all swallowed windows visible |
| `pin({ window? })` | pin a window |
| `alter_zorder({ mode, window? })` | mode can be "top" or "bottom" |
| `set_prop({ prop, value, window? })` | set a window property |
| `deny_from_group({ action? })` | deny a window from entering a group |
| `drag()` | begin an interactive drag. To be used with mouse binds. |
| `resize()` | begin an interactive resize. To be used with mouse binds. |
| `resize({ x, y, relative?, window? })` | resize a window |

### Workspace

`hl.dsp.workspace.` contains:

| method | description |
| --- | --- |
| `rename({ workspace, name? })` | rename a workspace |
| `move({ workspace?, monitor })` | move a workspace to a monitor |
| `swap_monitors({ monitor1, monitor2 })` | swap current workspaces of two monitors |
| `toggle_special(special_name)` | toggle a special workspace by name |

### Group

`hl.dsp.group.` contains:

| method | description |
| --- | --- |
| `toggle({ window? })` | toggle a group |
| `next({ window? })` | switch to the next window in a group | 
| `prev({ window? })` | switch to the previous window in a group | 
| `active({ index, window? })` | switch to a window in a group, indexed | 
| `move_window({ forward?, window? })` | move a window in the group order | 
| `lock({ action?, window? })` | lock a group | 
| `lock_active({ action? })` | lock the active group | 

### Cursor

`hl.dsp.cursor.` contains:

| method | description |
| --- | --- |
| `move_to_corner({ corner, window? })` | move the cursor to a given corner of the window. Corner is 0-3 |
| `move({ x, y })` | move the cursor to agiven coordinate |

> [!WARNING]
> [uwsm](../../../Useful-Utilities/Systemd-start) users should avoid using `exit` dispatcher, or terminating Hyprland process directly, as exiting Hyprland this way removes it from under its clients and interferes with ordered shutdown sequence. Use `exec, uwsm stop` (or [other variants](https://github.com/Vladimir-csp/uwsm#how-to-stop)) which will gracefully bring down graphical session (and login session bound to it, if any). If you experience problems with units entering inconsistent states, affecting subsequent sessions, use `exec, loginctl terminate-user ""` instead (terminates all units of the user).
> 
> It's also strongly advised to replace the `exit` dispatcher inside `hyprland.lua` keybinds section accordingly.

> [!WARNING]
> It is NOT recommended to set DPMS or forceidle with a keybind directly, as it
> might cause undefined behavior. Instead, consider something like
> 
> ```lua
> hl.bind("...", function()
>                  hl.timer(function()
>                    hl.dispatch(hl.dsp.dpms({ action = "disable" }))
>                  end, {timeout = 500, type = "oneshot"})
>                end)
> ```

### Grouped (tabbed) windows

Hyprland allows you to make a group from the current active window with the
`hl.dsp.group.toggle()` bind dispatcher.

A group is like i3wm’s “tabbed” container. It takes the space of one window, and
you can toggle the windows within it.

You can lock a group with the `lock` dispatcher in order to stop new
windows from entering this group.

You can prevent a window from being added to a group or becoming a group with the
`window.deny_from_group` dispatcher.

## Workspace selectors

You have nine choices:

- ID: e.g. `1`, `2`, or `3`

- Relative ID: e.g. `+1`, `-3` or `+100`

- workspace on monitor, relative with `+` or `-`, absolute with `~`: e.g. `m+1`,
  `m-2` or `m~3`

- workspace on monitor including empty workspaces, relative with `+` or `-`,
  absolute with `~`: e.g. `r+1` or `r~3`

- open workspace, relative with `+` or `-`, absolute with `~`: e.g. `e+1`,
  `e-10`, or `e~2`

- Name: e.g. `name:Web`, `name:Anime` or `name:Better anime`

- Previous workspace: `previous`, or `previous_per_monitor`

- First available empty workspace: `empty`, suffix with `m` to only search
  on monitor. and/or `n` to make it the _next_ available empty workspace. e.g.
  `emptynm`

- Special Workspace: `special` or `special:name` for named special workspaces.

> [!WARNING]
> Numerical workspaces (e.g. `1`, `2`, `13371337`) are allowed **ONLY** between 1
> and 2147483647 (inclusive).  
> Neither `0` nor negative numbers are allowed.

## Special Workspace

A special workspace is what is called a "scratchpad" in some other places. A
workspace that you can toggle on/off on any monitor.

> [!NOTE]
> You can define multiple named special workspaces, but the amount of those is
> limited to 97 at a time.

For example, to move a window to a named special workspace you can use the following syntax:

```lua
hl.bind("SUPER + C", hl.dsp.window.move({ workspace = "special:magic" }))
-- To see the hiden window and workspace you can use: 
hl.bind("SUPER + S", hl.dsp.workspace.toggle_special("magic"))
```

## Executing with rules 

The `exec_cmd` dispatcher supports adding rules. Please note some windows might work better, some worse. It records the PID of the spawned process and uses that. For example, if your process forks and then the fork opens a window, this will not work.

Example:

```lua
hl.bind("SUPER + E", hl.dsp.exec_cmd("kitty", { float = true, move = {0, 0} }))
```

## setprop

Props are any of the _dynamic effects_ of [Window Rules](../Window-Rules#dynamic-effects).

For example:

```lua
{ prop = "no_anim", value = "1" }
{ prop = "no_anim", value = "1", window = "class:abc" }
```

Some props are expanded from their window rule parents which take multiple arguments:
- `border_color` -> `active_border_color`, `inactive_border_color`
- `opacity` -> `opacity`, `opacity_inactive`, `opacity_fullscreen`, `opacity_override`, `opacity_inactive_override`, `opacity_fullscreen_override`

## Fullscreenstate

The `fullscreen_state` dispatcher decouples the state that Hyprland maintains for a window from the fullscreen state that is communicated to the client.  

`internal` is a reference to the state maintained by Hyprland.

`client` is a reference to the state that the application receives.

| Value | State | Description |
| --- | --- | --- |
| -1 | Current | Maintains the current fullscreen state. |
| 0 | None | Window allocates the space defined by the current layout. |
| 1 | Maximize | Window takes up the entire working space, keeping the margins. |
| 2 | Fullscreen | Window takes up the entire screen. |
| 3 | Maximize and Fullscreen | The state of a fullscreened maximized window. Works the same as fullscreen. |

For example:

`{internal = 2, client = 0}` Fullscreens the application and keeps the client in non-fullscreen mode.  

This can be used to prevent Chromium-based browsers from going into presentation mode when they detect they have been fullscreened.  

`{internal = 0, client = 2}` Keeps the window non-fullscreen, but the client goes into fullscreen mode within the window.
