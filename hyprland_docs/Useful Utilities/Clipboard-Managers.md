---
weight: 9
title: Clipboard Managers
---

_Starting method:_ manual (in hyprland config's autostarts)

Clipboard Managers provide a convenient way to organize and access previously
copied content, including both text and images.  
Some common ones include:

- [`cliphist`](https://github.com/sentriz/cliphist) - Utilizes Wayland with `wl-clipboard` and can store text,
images and any binary data.

- [`clipman`](https://github.com/chmouel/clipman) - Utilizes Wayland with `wl-clipboard` support and stores text only.

- [`clipvault`](https://github.com/rolv-apneseth/clipvault) - Utilizes Wayland with `wl-clipboard` and can store text, images and any binary data.  
Alternative to `cliphist` with a couple extra features (e.g. max age for entries, min/max entry length).

- [`clipse`](https://github.com/savedra1/clipse) - Utilizes Wayland with `wl-clipboard` and supports text and images. Accessible via a TUI that can be bound to a floating window in your Hyprland config. Features include custom themes, image/text previews, multi-select, pinned items, auto-paste, sensitive content handling and more.

- [`copyq`](https://github.com/hluk/CopyQ) - Supports text, images, and various other formats. It offers searchable history, editing capabilities, and a scripting interface. You can also organize items into tabs and synchronize clipboards across different devices.

- [`wl-clip-persist`](https://github.com/Linus789/wl-clip-persist) - When copying something on Wayland, the copied data remains in the clipboard until the application that was copied from is closed; after that, the data disappears and can no longer be pasted.  
To fix this problem, you can use `wl-clip-persist` which will preserve the data in the clipboard after the application is closed.

- [`cursor-clip`](https://github.com/Sirulex/cursor-clip) - A modern wayland clipboard manager built with Rust, GTK4, Libadwaita and Layer Shell that makes clipboard handling more reliable. Features a Windows 11–style clipboard history interface with native GNOME design, which is always positioned at the current mouse pointer location. Supports all clipboard formats, including text, images, and files. 

## cliphist

Start by adding the following autostarts to your config:
 - `wl-paste --type text --watch cliphist store`
 - `wl-paste --type image --watch cliphist store`

Note that any of the above lines can be disabled based on your needs.

To bind `cliphist` to a hotkey and display it under `rofi`, `dmenu`, `wofi` or `fuzzel`,
you can edit it in `hyprland.lua`.

Bash commands:

{{< tabs items="rofi,dmenu,wofi,fuzzel" >}}

{{< tab >}}
```sh
cliphist list | rofi -dmenu -display-columns 2 | cliphist decode | wl-copy
```
{{< /tab >}}

{{< tab >}}
```sh
cliphist list | dmenu | cliphist decode | wl-copy
```
{{< /tab >}}

{{< tab >}}
```sh
cliphist list | wofi --dmenu --pre-display-cmd "echo '%s' | cut -f 2" | cliphist decode | wl-copy
```
{{< /tab >}}

{{< tab >}}
```sh
cliphist list | fuzzel --dmenu --with-nth 2 | cliphist decode | wl-copy
```
{{< /tab >}}

{{< /tabs >}}

The binds above bind `SUPER + V` to access the clipboard history.  
For further info, please refer to the program's GitHub repository linked above.

## clipman

Start by adding the following to autostarts: `wl-paste -t text --watch clipman store --no-persist`

If you wish to use it as a primary clipboard manager, use this instead: `wl-paste -p -t text --watch clipman store -P --histpath="~/.local/share/clipman-primary.json"`

Ensure that `~/.local/share/clipman-primary.json` is already created.

Now you can bind `clipman` like this:

{{< tabs items="rofi,dmenu,wofi,fuzzel" >}}

{{< tab >}}
```lua
hl.bind("SUPER + V", hl.dsp.exec_cmd("clipman pick -t rofi))
```
{{< /tab >}}

{{< tab >}}
```lua
hl.bind("SUPER + V", hl.dsp.exec_cmd("clipman pick -t dmenu"))
```
{{< /tab >}}

{{< tab >}}
```lua
hl.bind("SUPER + V", hl.dsp.exec_cmd("clipman pick -t wofi"))
```
{{< /tab >}}

{{< tab >}}
```lua
hl.bind("SUPER + V", hl.dsp.exec_cmd("clipman pick -t STDOUT | fuzzel --dmenu | wl-copy"))
```
{{< /tab >}}

{{< /tabs >}}

...and so on.  
For further information, please refer to the program's GitHub repository linked above.

## clipvault

Start by adding the following autostart(s) to your `~/.config/hypr/hyprland.lua`

```sh
wl-paste --watch clipvault store # Stores text, image and any other binary data
# wl-paste --type text --watch clipvault store # Stores only text data
# wl-paste --type image --watch clipvault store # Stores only image data
# wl-paste --watch clipvault store --min-entry-length 2 --max-entries 200 --max-entry-age 2d # Store any data, but with additional parameters
```

Note that you can uncomment any of the commented out lines above based on your needs. Refer to the setup
section in the project's GitHub repository linked above for more information.

To bind `clipvault` to a hotkey and display it using a picker of your choice (e.g. `rofi`, `dmenu`, `wofi`, etc.),
you can add one of the below commands to a bind to your `hyprland.lua`:

{{< tabs items="rofi,dmenu,wofi,fuzzel,tofi" >}}

{{< tab >}}
```sh
clipvault list | rofi -dmenu -display-columns 2 | clipvault get | wl-copy
```
{{< /tab >}}

{{< tab >}}
```sh
clipvault list | dmenu | clipvault get | wl-copy
```
{{< /tab >}}

{{< tab >}}
```sh
clipvault list | wofi -S dmenu --pre-display-cmd "echo '%s' | cut -f 2" | clipvault get | wl-copy
```
{{< /tab >}}

{{< tab >}}
```sh
clipvault list | fuzzel --dmenu --with-nth 2 | clipvault get | wl-copy
```
{{< /tab >}}

{{< tab >}}
```sh
clipvault list | tofi | clipvault get | wl-copy
```
{{< /tab >}}

{{< /tabs >}}

The binds above bind `SUPER + V` to access the clipboard history.  
For further info, please refer to the program's GitHub repository linked above.

## clipse

Start by adding the following to your autostart: `clipse -listen`

You can bind the TUI to a something nice like this:

```lua
hl.bind("SUPER + V", hl.dsp.exec_cmd("kitty --class clipse -e clipse", { float = true, size = {622, 652}, stay_focused = true }))
```

The `kitty` terminal emulator is recommended due to having the most compatible image rendering, but you can swap
this for any other terminal of your choosing. 

The class is optional, but it's recommended to use a floating window for a more traditional, 
GUI-like feel.

For more details on `clipse`, please refer to its GitHub repo linked at the top
of the page.

## copyq

Start by adding the following to your autostart: `copyq --start-server`

If the main window of `copyq` cannot close or hide properly, try to enable its
"Hide main window" option in the Layout configuration tab in the Preferences
dialog.

## wl-clip-persist

Add the following to your autostarts.
No other changes are required. The basic wayland copy/paste mechanisms will now persist even when the source window is closed.

```sh
wl-clip-persist --clipboard regular
```

Can also be applied to the primary selection (i.e. middle click to paste selection) too, but this is not recommended because the primary selection [has unintended side-effects for some GTK applications.](https://github.com/Linus789/wl-clip-persist#primary-selection-mode-breaks-the-selection-system-3)

```sh
wl-clip-persist --clipboard primary
```

## cursor-clip

Start by adding the following to your autostarts: `cursor-clip --daemon`

This starts the background daemon that monitors clipboard changes.

To bind `cursor-clip` to a hotkey for quick access, you can add a keybind to run `cursor-clip` to your hyprland config.

When triggered, `cursor-clip` will automatically position its overlay window at your current mouse location, providing a Windows 11-style clipboard history interface. The overlay supports all clipboard formats including text, images, and files, with a native GNOME design built using GTK4 and Libadwaita.

For further information, please refer to the program's GitHub repository linked at the top of the page.
