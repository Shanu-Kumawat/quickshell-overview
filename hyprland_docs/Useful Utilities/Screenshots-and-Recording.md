---
weight: 5
title: Screenshots & Recording
---

> [!NOTE]
> Looking for the old hyprlang syntax? Check the [0.54 wiki pages](https://wiki.hypr.land/0.54.0/).
> Since Hyprland 0.55, hyprlang is deprecated in favor of lua.

This page lists commonly used tools for taking screenshots and recording the
screen on Hyprland.

## Screenshot utilities

### HyprCapture

[HyprCapture](https://github.com/gfhdhytghd/HyprCapture) is a Hyprland-oriented
screenshot and recording utility. It is useful if you want a workflow that is
integrated with Hyprland instead of wiring several smaller tools together.

### grim and swappy

[`grim`](https://sr.ht/~emersion/grim/) is a simple Wayland screenshot tool. It
is commonly used with [`slurp`](https://github.com/emersion/slurp) for area
selection and [`swappy`](https://github.com/jtheoof/swappy) for annotations.

For example, to select an area and open it in `swappy`:

```lua
hl.bind("Print", hl.dsp.exec_cmd('grim -g "$(slurp)" - | swappy -f -'))
```

To copy a selected area directly to the clipboard, install
[`wl-clipboard`](https://github.com/bugaevc/wl-clipboard) and use:

```lua
hl.bind("SUPER + Print", hl.dsp.exec_cmd('grim -g "$(slurp -d)" - | wl-copy'))
```

### Satty
[`Satty`](https://github.com/Satty-org/Satty) is a powerful and modern screenshot
annotation tool inspired by [`swappy`](https://github.com/jtheoof/swappy) and 
[Flameshot](https://github.com/flameshot-org/flameshot). It's been created to provide
improvements over existing screenshot tools and is an almost drop-in replacement for swappy.

For example, to take a screenshot and open it with `satty`, 
Ctrl-C to copy to clipboard and Ctrl-S saves it to `~/Pictures/Screenshots/`:

```lua
hl.bind("Print", hl.dsp.exec_cmd('grim - | satty -f - --copy-command wl-copy -o "~/Pictures/Screenshots/%Y%m%d_%H%M%S.png"'))
```

### Flameshot

[Flameshot](https://github.com/flameshot-org/flameshot) is a screenshot tool
with a built-in annotation UI. On Wayland, it relies on portal support for screen
capture. If it cannot capture the screen, make sure your desktop portal setup is
working or use `grim` with `swappy` instead.

### WeChat screenshot

WeChat has its own screenshot shortcut. If Hyprland catches the keybind first,
WeChat will not receive it unless the keybind is explicitly passed to the WeChat
window.

Use the `pass` dispatcher to forward <key>Alt</key> + <key>A</key> to WeChat:

```lua
hl.bind("ALT + A", hl.dsp.pass({class = "^(wechat)$"}))
```

The `pass` dispatcher sends both the press and release events to the matched
window, so a separate `bindr` is not needed. This is useful for application
shortcuts that need to behave like global shortcuts while still being handled by
the application itself.

If the bind does not work, check the actual WeChat window class:

```sh
hyprctl clients
```

Then adjust the matcher accordingly. For example, if your package reports a
different class, replace `class:^(wechat)$` with the class shown by
`hyprctl clients`.

## Recording utilities

### OBS Studio

[OBS Studio](https://obsproject.com/) can record the screen through PipeWire and
the desktop portal. Make sure `pipewire`, `wireplumber`,
[`xdg-desktop-portal-hyprland`](../../Hypr-Ecosystem/xdg-desktop-portal-hyprland)
and `qt6-wayland` are installed. See [Screen sharing](../Screen-Sharing) for
portal setup notes.

### wf-recorder

[`wf-recorder`](https://github.com/ammen99/wf-recorder) is a lightweight
Wayland screen recorder.

Record the whole screen:

```sh
wf-recorder -f ~/Videos/recording.mp4
```

Record a selected region:

```sh
wf-recorder -g "$(slurp)" -f ~/Videos/recording.mp4
```

If capture tools are blocked by Hyprland's permission system, see
[Permissions](../../Configuring/Advanced-and-Cool/Permissions).
