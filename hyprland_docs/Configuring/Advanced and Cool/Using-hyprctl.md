---
weight: 40
title: Using hyprctl
---

`hyprctl` is a utility for controlling some parts of the compositor from a CLI
or a script. It should automatically be installed along with Hyprland.

> [!WARNING]
> _hyprctl_ calls will be dispatched by the compositor _synchronously_, meaning
> any spam of the utility will cause slowdowns. It's recommended to use `--batch`
> for many control calls, and limiting the amount of info calls.
> 
> For live event handling, see the [events](../Expanding-functionality/#events).

## Commands

### eval

Issue a lua string to execute dynamically.

```sh
hyprctl eval 'hl.dispatch(hl.dsp.focus({ workspace = "3" }))'
```

### dispatch

Dispatch is a shorthand for `eval 'hl.dispatch(...)'`:

```sh
hyprctl dispatch 'hl.dsp.focus({ workspace = "3" })'
```

See [Dispatchers](../../Basics/Dispatchers) for a list of dispatchers.

### reload

Issue a `reload` to force reload the config.

### kill

Issue a `kill` to get into a kill mode, where you can kill an app by clicking on
it. You can exit it with ESCAPE.

Kind of like xkill.

### setcursor

Sets the cursor theme and reloads the cursor manager. Will set the theme for
everything except GTK, because GTK.

Please note that since 0.37.0, this only accepts hyprcursor themes. For legacy xcursor themes,
use the `XCURSOR_THEME` and `XCURSOR_SIZE` env vars.

params: theme and size

e.g.:

```sh
hyprctl setcursor Bibata-Modern-Classic 24
```

### output

Allows you to add and remove fake outputs to your preferred backend.

Usage:

```sh
hyprctl output create [backend] (name)
```

or

```sh
hyprctl output remove [name]
```

Where `[backend]` is the name of the backend and `(name)` is an optional name
for the output. If `(name)` is not specified, the default naming scheme will be
used (`HEADLESS-2`, `WL-1`, etc.)

> [!NOTE]
> `create` and `remove` can also be `add` or `destroy`, respectively.

Available backends:

- `wayland`: Creates an output as a Wayland window. This will only work if
  you're already running Hyprland with the Wayland backend.
- `headless`: Creates a headless monitor output. If you're running a VNC/RDP/
  Sunshine server, you should use this.
- `auto`: Picks a backend for you. For example, if you're running Hyprland from
  the TTY, `headless` will be chosen.

For example, to create a headless output named "test":

```sh
hyprctl output create headless test
```

And to remove it:

```sh
hyprctl output remove test
```

### switchxkblayout

Sets the xkb layout index for a keyboard.

For example, if you set:

```lua
hl.device({
  name = "my-epic-keyboard-v1",
  kb_layout = "us,pl,de"
})
```

You can use this command to switch between them.

```sh
hyprctl switchxkblayout [DEVICE] [CMD]
```

where `CMD` is either `next` for next, `prev` for previous, or `ID` for a
specific one (in the above case, `us`: 0, `pl`: 1, `de`: 2). You can find the
`DEVICE` using `hyprctl devices` command.

`DEVICE` can also be `current` or `all`, self-explanatory. Current is the `main` keyboard from `devices`.

Example command for a typical keyboard:

```sh
hyprctl switchxkblayout at-translated-set-2-keyboard next
```

> [!NOTE]
> If you want a single variant i.e. pl/dvorak on one layout but us/qwerty on the
> other, xkb parameters can still be blank, however the amount of comma-separated
> parameters have to match. Alternatively, a single parameter can be specified for
> it to apply to all three.
> 
> ```lua
> hl.config({
>   input = {
>     kb_layout = "pl,us,ru",
>      kb_variant = "dvorak,,",
>      kb_options = "caps:ctrl_modifier"
>   }
> })
> ```

### seterror

Sets the hyprctl error string. Will reset when Hyprland's config is reloaded.

```sh
hyprctl seterror 'rgba(66ee66ff)' hello world this is my problem
```

To disable:

```sh
hyprctl seterror disable
```

### getprop

Gets a property value of a window.

```sh
hyprctl getprop [window] [property]
```

Where `window` is as described [here](../../Basics/Dispatchers#parameter-explanation), and `property` is any which can be set with [setprop](../../Basics/Dispatchers/#setprop).

#### Notes
- If `animationstyle` is unset, `(unset)` is returned.
- `min_size` defaults to `20 20`.
- `max_size` defaults to `inf inf` or `[null,null]` in JSON.

### notify

Sends a notification using the built-in Hyprland notification system.

```sh
hyprctl notify [ICON] [TIME_MS] [COLOR] [MESSAGE]
```

For example:

```sh
hyprctl notify -1 10000 "rgb(ff1ea3)" "Hello everyone!"
```

Icon of `-1` means "No icon"

Color of `0` means "Default color for icon"

Icon list:

```sh
WARNING = 0
INFO = 1
HINT = 2
ERROR = 3
CONFUSED = 4
OK = 5
```

Optionally, you can specify a font size of the notification like so:

```sh
hyprctl notify -1 10000 "rgb(ff0000)" "fontsize:35 This text is big"
```

The default font-size is 13.

### dismissnotify

Dismisses all or up to AMOUNT notifications.

```sh
hyprctl dismissnotify # dismiss all notifications
hyprctl dismissnotify 2 # dismiss the oldest 2 notifications
hyprctl dismissnotify -1 # dismiss all notifications (same as no arguments)
```

## Info

```plain
version - prints the Hyprland version along with flags, commit and branch of build.
monitors - lists active outputs with their properties, 'monitors all' lists active and inactive outputs
workspaces - lists all workspaces with their properties
activeworkspace - gets the active workspace and its properties
workspacerules - gets the list of defined workspace rules
clients - lists all windows with their properties
devices - lists all connected keyboards and mice
decorations [window] - lists all decorations and their info
binds - lists all registered binds
activewindow - gets the active window name and its properties
layers - lists all the layers
splash - prints the current random splash
getoption [option] - gets the config option status (values)
cursorpos - gets the current cursor position in global layout coordinates
animations - gets the currently configured info about animations and beziers
instances - lists all running instances of Hyprland with their info
layouts - lists all layouts available (including from plugins)
configerrors - lists all current config parsing errors
rollinglog - prints tail of the log. Also supports -f/--follow option
locked - prints whether the current session is locked.
descriptions - returns a JSON with all config options, their descriptions and types.
submap - prints the current submap the keybinds are in
```

For the getoption command, the option name should be written as
`section.option`, e.g.:

```sh
hyprctl getoption general.border_size

# For nested sections:
hyprctl getoption input.touchpad.disable_while_typing
```

See [Variables](../../Basics/Variables) for sections and options you can use.

## Batch

You can use the legacy `--batch` flag to issue multiple commands separated with a `;`.

## Flags

You can specify flags for the request like this:

```sh
hyprctl -j monitors
```

flag list:

```txt
j -> output in JSON
i -> select instance (id or index in hyprctl instances)
r -> force state refresh after issuing commands (e.g. layout or rule changes)
```
