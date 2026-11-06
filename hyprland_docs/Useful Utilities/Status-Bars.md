---
weight: 2
title: Status bars
---

## Simple status bars

Typically you'll be able to configure the order and style of widgets with little to no coding skill.

### Waybar

Waybar is a GTK status bar made specifically for wlroots compositors and
supports Hyprland by default. To use it, it's recommended to use your distro's
package.

To start configuring, copy the configuration files from
`/etc/xdg/waybar/` into `~/.config/waybar/`.

To use the workspaces module, replace all the occurrences of `sway/workspaces`
with `hyprland/workspaces`. Additionally replace all occurrences of `sway/mode` with `hyprland/submap`

For more info regarding configuration, see
[The Waybar Wiki](https://github.com/Alexays/Waybar/wiki/Module:-Hyprland).

#### How to launch

Type `waybar` into your terminal. In order to have Waybar launch alongside
Hyprland, add `waybar` to your hyprland config's autostarts.

Waybar also provides a systemd service. If you use Hyprland with [uwsm](../../Useful-Utilities/Systemd-start), you can enable it, using the following command.

```ini
systemctl --user enable --now waybar.service
```

#### Waybar FAQ

##### Active workspace doesn't show up

Replace `#workspaces button.focused` with `#workspaces button.active` in
`~/.config/waybar/style.css`.

##### Scrolling through workspaces

Since a lot of configuration options from `sway/workspaces` are missing,
you should deduce some of them by yourself. In the case of scrolling, it should
look like this:

```json
"hyprland/workspaces": {
     "format": "{icon}",
     "on-scroll-up": "hyprctl dispatch workspace e+1",
     "on-scroll-down": "hyprctl dispatch workspace e-1"
}
```

#### Window title is missing

The prefix for the window module that provides the title is `hyprland` not `wlr`.
In your Waybar config, insert this module:

```json
"modules-center": ["hyprland/window"],
```

If you are using multiple monitors, you may want to insert the following option:

```json
"hyprland/window": {
    "separate-outputs": true
},
```

### ashell

[ashell](https://malpenzibo.github.io/ashell/) is a ready to go Wayland status bar for Hyprland

- Ashell is ready to use out of the box. Just install it, start using it, and customize only what you need.
- Ashell comes with essential modules like workspaces, time, battery, network, and more. No need to hunt for plugins or write custom scripts.
- Powered by iced. A cross-platform GUI library for Rust
- Has a pretty limited configuration options. It's a good and a bad thing at the same time. You can get a very decent result quickly and with a little effort, but some crazy waybar-alike tweaks are not possible.


### Noctalia
[Noctalia](https://noctalia.dev/) is a beautiful, minimal desktop shell for Wayland.

- Built on a lean, modern stack with a calm, distinctive look you can tune to match your setup.
- Extensive theming with predefined color schemes and automatic color generation from your wallpaper.
- Notification system with history and Do Not Disturb.
- Plugin support.
- Built on Quickshell.

## Widget systems

Use them when you want custom menus with fully customizable layout. 
You basically need to write code, but widget systems significantly 
ease the process. 
Below are three popular choices in alphabetical order.

|   | [AGS/Astal](https://aylur.github.io/astal/) | [EWW](https://elkowar.github.io/eww/) | [Quickshell](https://quickshell.outfoxxed.me/) | 
|--------------------------|-------------------|-------------------|-------------------|
| UI Toolkit               | GTK 3/4            | GTK 3             | Qt                |
| Config language          | JS(X)/TS/languages that support [Gobject Introspection](https://en.wikipedia.org/wiki/List_of_language_bindings_for_GTK) | Yuck (EWW's flavor of Lisp) | QML |

### AGS/Astal

- [Astal](https://aylur.github.io/astal/) is a suite and framework to craft desktop shells and Wayland widgets with GTK.
- [AGS](https://aylur.github.io/ags/) (Aylur's GTK Shell) is a scaffolding tool for Astal and TypeScript/Javascript(X).
In simple words, it eases creation of Astal projects in those languages.

To get started with Astal, see its [installation instructions](https://aylur.github.io/astal/guide/installation)
and [examples](https://aylur.github.io/astal/guide/introduction#supported-languages).
For AGS, see its [Quick start](https://aylur.github.io/ags/guide/quick-start.html) page.

#### Advantages
- Language flexibility: You can use your favorite if it supports
[Gobject Introspection](https://en.wikipedia.org/wiki/List_of_language_bindings_for_GTK) (although JS(X)/TS are most well-supported by AGS)
- Provides a large set of libraries, including Network (both Wi-Fi and Ethernet) and Bluetooth

#### Disadvantages
- Does not provide hot reload out of the box

### Eww

[Eww](https://github.com/elkowar/eww) (ElKowar's Wacky Widgets) is a widget
system made in Rust + GTK, which allows the creation of custom widgets
similarly to AwesomeWM. The key difference is that it is independent of window
manager/compositor.

Install Eww either using your distro's package manager, by searching
`eww-wayland`, or by manually compiling. In the latter case, you can follow the
[instructions](https://elkowar.github.io/eww).

#### Advantages
- Its Lisp-like config syntax is simple compared to other config languages
- Supports styling with SCSS out of the box

#### Disadvantages
- Heavy reliance on external scripts/programs, as it does not provide many libraries
- Performance
  - Only supports GTK 3, which does not support GPU acceleration
  - Overhead from the use of external scripts and unnecessary component recreations on data re-evaluation

#### Configuration

There are a few examples listed in the [Readme](https://github.com/elkowar/eww).
It's also highly recommended to read through the
[Configuration options](https://elkowar.github.io/eww/configuration.html).

> [!WARNING]
> Read
> [the Wayland section](https://elkowar.github.io/eww/configuration.html#wayland)
> carefully, otherwise Eww won't work on Hyprland.

Here are some example widgets that might be useful for Hyprland:

<details>
<summary>Workspaces widget</summary>

This widget displays a list of workspaces 1-10. Each workspace can be clicked on
to jump to it, and scrolling over the widget cycles through them. It supports
different styles for the current workspace, occupied workspaces, and empty
workspaces. It requires [bash](https://linux.die.net/man/1/bash),
[awk](https://linux.die.net/man/1/awk),
[stdbuf](https://linux.die.net/man/1/stdbuf),
[grep](https://linux.die.net/man/1/grep),
[seq](https://linux.die.net/man/1/seq),
[socat](https://linux.die.net/man/1/socat),
[jq](https://stedolan.github.io/jq/), and [Python 3](https://www.python.org/).

##### `~/.config/eww.yuck`

```lisp
...
(deflisten workspaces :initial "[]" "bash ~/.config/eww/scripts/get-workspaces")
(deflisten current_workspace :initial "1" "bash ~/.config/eww/scripts/get-active-workspace")
(defwidget workspaces []
  (eventbox :onscroll "bash ~/.config/eww/scripts/change-active-workspace {} ${current_workspace}" :class "workspaces-widget"
    (box :space-evenly true
      (label :text "${workspaces}${current_workspace}" :visible false)
      (for workspace in workspaces
        (eventbox :onclick "hyprctl dispatch workspace ${workspace.id}"
          (box :class "workspace-entry ${workspace.windows > 0 ? "occupied" : "empty"}"
            (label :text "${workspace.id}" :class "workspace-entry ${workspace.id == current_workspace ? "current" : ""}" )
            )
          )
        )
      )
    )
  )
...
```

##### `~/.config/eww/scripts/change-active-workspace`

```sh
#!/usr/bin/env bash
function clamp {
  min=$1
  max=$2
  val=$3
  python -c "print(max($min, min($val, $max)))"
}

direction=$1
current=$2
if test "$direction" = "down"
then
  target=$(clamp 1 10 $(($current+1)))
  echo "jumping to $target"
  hyprctl dispatch workspace $target
elif test "$direction" = "up"
then
  target=$(clamp 1 10 $(($current-1)))
  echo "jumping to $target"
  hyprctl dispatch workspace $target
fi
```

##### `~/.config/eww/scripts/get-active-workspace`

```sh
#!/usr/bin/env bash

hyprctl monitors -j | jq '.[] | select(.focused) | .activeWorkspace.id'

socat -u UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - |
  stdbuf -o0 awk -F '>>|,' -e '/^workspace>>/ {print $2}' -e '/^focusedmon>>/ {print $3}'
```

##### `~/.config/eww/scripts/get-workspaces`

```sh
#!/usr/bin/env bash

spaces (){
  WORKSPACE_WINDOWS=$(hyprctl workspaces -j | jq 'map({key: .id | tostring, value: .windows}) | from_entries')
  seq 1 10 | jq --argjson windows "${WORKSPACE_WINDOWS}" --slurp -Mc 'map(tostring) | map({id: ., windows: ($windows[.]//0)})'
}

spaces
socat -u UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - | while read -r line; do
  spaces
done
```

</details>

<details>
<summary>Active window title widget</summary>

This widget simply displays the title of the active window. It requires
[awk](https://linux.die.net/man/1/awk),
[stdbuf](https://linux.die.net/man/1/stdbuf),
[socat](https://linux.die.net/man/1/socat), and
[jq](https://stedolan.github.io/jq/).

##### `~/.config/eww/eww.yuck`

```lisp
...
(deflisten window :initial "..." "sh ~/.config/eww/scripts/get-window-title")
(defwidget window_w []
  (box
    (label :text "${window}"
    )
  )
...
```

##### `~/.config/eww/scripts/get-window-title`

```sh
#!/bin/sh
hyprctl activewindow -j | jq --raw-output .title
socat -u UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - | stdbuf -o0 awk -F '>>|,' '/^activewindow>>/{print $3}'
```

</details>

### Quickshell

[Quickshell](https://quickshell.outfoxxed.me/) is a flexible QtQuick-based desktop shell toolkit.
Note that although Qt is notoriously hard to theme, Quickshell can be styled independently.

To get started, see the 
[setup instructions](https://quickshell.outfoxxed.me/docs/configuration/getting-started/)
and a [guided hello world](https://quickshell.outfoxxed.me/docs/configuration/intro/)

#### Advantages
- Provides advanced Wayland/Hyprland integrations, for example live window previews
- Automatically reloads config on changes out of the box

#### Disadvantages
- Qt can be less intuitive to work with compared to GTK for its positioning system
- Does not yet provide a Wi-Fi service at the time of writing
- It is still in alpha and minor breaking changes are to be expected
- Styles are declared with components instead of in CSS, which might be less familiar for some people

## Tips

### Blur

Use the `blur` and `ignore_alpha` [layer rules](../../Configuring/Basics/Window-Rules/#layer-rules). 
The former enables blur, and the latter makes it ignore insufficiently opaque regions. 
Ideally, the value used with `ignore_alpha` is higher than the shadow opacity and lower than the bar/menu content's opacity. 
Additionally, if it has transparent popups, you can use the `blur_popups` rule.

