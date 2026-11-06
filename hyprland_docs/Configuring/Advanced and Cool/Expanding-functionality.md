---
weight: 50
title: Expanding functionality
---

> [!NOTE]
> Looking for the old hyprlang syntax? Check the [0.54 wiki pages](https://wiki.hypr.land/0.54.0/).
> Since Hyprland 0.55, hyprlang is deprecated in favor of lua.

## Lua utilities

Hyprland exposes a bunch of lua utilities for you to script your desktop
with custom functionality and more.

### Events

With `hl.on`, you can define callbacks on events. You can register as many as you want.

```lua
hl.on("window.active", function(w)
  hl.notification.create({ text = "Window focused: " .. w.title, timeout = 5000, icon = "ok" })
end)
```

or, if you're working with events that have multiple parameters

```lua
hl.on("workspace.move_to_monitor", function(ws, m)
  hl.notification.create({
    text = "Workspace: " .. ws.name .. " moved to a monitor at x: " .. m.position.x,
    timeout = 4000,
    icon = "ok"
  })
end)
```

Event list:

| Event | Description | Parameters |
| --- | --- | --- |
| hyprland.start | Emitted once on start | None |
| hyprland.shutdown | Emitted once before Hyprland exiting | None |
| window.open | Emitted when a window is fully initialized with window rules applied. | Window |
| window.open_early | Emitted when a window is created and mapped, but **before** window rules are applied. | Window |
| window.close | Emitted when a window is closed. It may still be visible during its closing animation. | Window |
| window.destroy | Emitted when a window is removed from the compositor. For windows with a close animation, fires after the animation completes. | Window |
| window.kill | Emitted when a window is forcefully killed via hyprctl kill. | Window |
| window.active | Emitted when the active window changes. | Window, int \[0/1\] |
| window.urgent | Emitted when a window requests an `urgent` state. | Window |
| window.title | Emitted when a window title changes. | Window |
| window.class | Emitted when a window class changes. | Window |
| window.pin | Emitted when a window is pinned or unpinned. | Window |
| window.fullscreen | Emitted when the fullscreen status of a window changes. | Window |
| window.update_rules | Emitted when a window's rules are re-evaluated, e.g. when its title or class changes. | Window |
| window.move_to_workspace | Emitted when a window is moved to a different workspace. | Window, Workspace |
| layer.opened | Emitted when a layer surface is opened. | LayerSurface |
| layer.closed | Emitted when a layer surface is closed. | LayerSurface |
| monitor.added | Emitted when a monitor is connected and ready. | Monitor |
| monitor.removed | Emitted when a monitor is disconnected and removed. | Monitor |
| monitor.focused | Emitted when the active monitor changes. | Monitor |
| monitor.layout_changed | Emitted when the monitor arrangement changes. This occurs when a monitor is added or removed, a monitor's resolution or refresh rate is changed, or the config is reloaded with different rules. | None |
| workspace.active | Emitted when the active workspace on a monitor changes. | Workspace |
| workspace.created | Emitted when a workspace is created. | Workspace |
| workspace.removed | Emitted when a workspace is removed. | Workspace |
| workspace.move_to_monitor | Emitted when a workspace is moved to a different monitor. | Workspace, Monitor |
| config.reloaded | Emitted when the config has been reloaded **and applied**. | None |
| keybinds.submap | Emitted when the active submap changes. An empty string means the default submap was restored. | String: Submap Name|
| screenshare.state | Emitted when a screenshare session starts or stops. | Bool: Active, Integer: Type, String: Name |

### Convenience functions

Hyprland exposes a bunch of convenience functions:
 - `hl.get_config()`
 - `hl.get_active_window()`
 - `hl.get_windows()`
 - `hl.get_window(selector)`
 - `hl.get_urgent_window()`
 - `hl.get_workspaces()`
 - `hl.get_workspace(selector)`
 - `hl.get_active_workspace()`
 - `hl.get_active_special_workspace()`
 - `hl.get_monitors()`
 - `hl.get_monitor(selector)`
 - `hl.get_active_monitor()`
 - `hl.get_monitor_at({ x = num, y = num })`
 - `hl.get_monitor_at_cursor()`
 - `hl.get_cursor_pos()`
 - `hl.get_last_window()`
 - `hl.get_last_workspace()`
 - `hl.get_layers()`
 - `hl.get_workspace_windows(workspace_selector)`
 - `hl.get_current_submap()`
 - `hl.version()`
 - `hl.exec_cmd()`
 - `hl.get_loaded_plugins()`


Use the LSP for the return values (classes and their parameters) of these functions. See [here](../../Start/#autocompletions) for setting up the LSP for your code editor


### Dynamically changing a config option:

You can use `hl.get_config()` to get the current value of a config option. Pass a config option like `"general.layout"`.

Pay attention that the return type of `hl.get_config()` will be a representation of the actual underlying type.

For example: If your `general.gaps_in` is set as `gaps_in = 3` in `hl.config()`, `hl.get_config()` returns a table of the form:
```lua
{
  top = 3,
  left = 3,
  right = 3,
  bottom = 3
}
```
because `gaps_in` also accepts a table of the form `{ top?, left?, right?, bottom? }`


You can change the value of a config option with a keybind with a script like:
```lua
-- Toggle gaps_in beween 0 and 3 (equivalent to  {3, 3, 3, 3} )
hl.bind(mainMod .. " + SHIFT + G", function()

    local gapsInValueTable = hl.get_config("general.gaps_in")

    if gapsInValueTable.top == 3 then
        hl.config({
            general = {gaps_in = 0}
        })
    else
        hl.config({
            general = {gaps_in = 3}
        })
    end
end)
```


### Timers

You can spawn and manage timers via `hl.timer()`:

```lua
local demoTimer = hl.timer(function()
  print("hello from timer")
end, { timeout = 1000, type = "repeat" })

demoTimer:set_enabled(false)

hl.bind("SUPER + X", function()
  -- toggle the timer
  demoTimer:set_enabled(not demoTimer:is_enabled())
end)
```

### Combining it all

You can expand functionality e.g. like so:

```lua
-- bind to toggle floating, unless the window is htop,
-- then only set floating

hl.bind("SUPER + X", function()
  local w = hl.get_active_window()
  if w ~= nil and w.title == "htop" do
    hl.dispatch(hl.dsp.window.float({ action = "set" }))
  else
    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
  end
end)
```

## Sockets (IPC)

It's recommended to use Lua. Lua will be faster, less buggy, have more APIs,
and is more integrated.

However, if you want to use IPC instead, check the [IPC](../../../IPC) page.
