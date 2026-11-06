---
weight: 11
title: FAQ
---

### Symbol lookup errors

If you are getting an error like:
```
<app>: symbol lookup error: <app>: undefined symbol: <symbol>
```
or
```
<app>: error while loading shared libraries: <lib>: cannot open shared object file: No such file or directory.
```

or sometimes without errors, just crashing at start / randomly

This means that you have built Hyprland yourself and your stack has gotten mismatched. Each hypr* app depends on a bunch of libraries. If you update those libraries, and you don't rebuild the hypr* stack, you will get these errors or crashes.

If you want to avoid these errors altogether, _use packages and don't build yourself_. By building yourself, the responsibility for maintaining this consistency falls on **you**!

When building yourself, you need to _build all hypr* components_, you cannot use some from packages and some from repos.

**For Arch users**: `-git` packages count as building yourself.

The order in which you **must** build the stack is as follows:
```
hyprland-protocols
hyprwayland-scanner
hyprutils
hyprgraphics
hyprlang
hyprcursor
aquamarine
xdg-desktop-portal-hyprland
hyprwire
hyprtoolkit
hyprland
```

Other things, e.g. hyprapps (hyprlock, hyprsunset, ...) can be built in any order
after hyprland.

***Never, under any circumstances***, symbolically link different .so versions together, this will lead to memory bugs and crashes.
I don't care what some random person tells you online. Don't do it.

### My apps are pixelated

This just means they are running through XWayland, which physically cannot scale
by fractional amounts.

To force them to run in native Wayland mode, see
[the Master Tutorial](../Getting-Started/Master-Tutorial/#force-apps-to-use-wayland).

If they can't, see [the XWayland page](../Configuring/Advanced-and-Cool/XWayland).

### My external monitor is blank / doesn't render / receives no signal (laptop)

For Nvidia graphics - This issue appears to be resolved when using Nvidia
Drivers 525.60.11 or later, but it may persist with older drivers.

For systems with limited hardware (Ex. iGPU, USB-C, USB Hubs) - Set env `AQ_NO_MODIFIERS` to `1` in your config.
To diagnose if you have the exact problem above you can get a [DRM log](https://wiki.hypr.land/Crashes-and-Bugs/#debugging-drm-issues) and look for

```plain
Requested display configuration exceeds system DDB limitations
```

Outside those, there is a way to fix it that _might_ work for you though:

**Option 1:** Use _only_ the external monitor

By using `AQ_DRM_DEVICES=/dev/dri/card1` (or `card0`) environment variable you can force Hyprland to
use only your dGPU, meaning your laptop's screen will be gone but your external
one will work.

**Option 2:** Use all outputs, at the cost of battery life.

By switching your laptop to only use the dGPU in the BIOS, you _might_ be able
to get everything to work, at the cost of high battery usage.

_Please note these are highly model-specific and might or might not work. If
they don't, you're unfortunately out of luck._

You might try a USB-C to HDMI adapter though, maybe that could route the
external monitor through the iGPU.

### How do I screenshot?

**Option 1:** Install `grim` and `slurp`.

Use a keybind (or execute) `grim -g "$(slurp)"`, and select a region. A screenshot
will pop into your `~/Pictures/` (You can configure grim and slurp, see their
GitHub pages).

If you want those screenshots to go directly to your clipboard, consider using
`wl-copy`, from [`wl-clipboard`](https://github.com/bugaevc/wl-clipboard).
Here's an example command to bind:
`grim -g "$(slurp -d)" - | wl-copy` For a more complete
utility, try our own screenshotting utility:
[Grimblast](https://github.com/hyprwm/contrib).

There are many screenshot tools out there, one search away in your favorite search engine.

For recording videos, [wf-recorder](https://github.com/ammen99/wf-recorder),
[wl-screenrec](https://github.com/russelltg/wl-screenrec) or
[OBS Studio](https://obsproject.com/) could be used.

### Screenshare / OBS no worky

Check [Screensharing](../Useful-Utilities/Screen-Sharing).

Also install `qt6-wayland` if you plan to use obs.

### How do I change my wallpaper?

See [Wallpapers](../Useful-Utilities/Wallpapers).

### How heavy is this?

Not that much heavier than Xorg. If you want maximum performance, consider
turning off the blur and animations.

### My monitor no worky

Try changing the mode in your config. If your preferred one doesn't work, try a
lower one. A good way to list all modes is to get `wlr-randr` and do a
`wlr-randr --dryrun`

### My monitor has flickering brightness when I turn on VRR

Change the VRR option to `2` (fullscreen), so that it is only used in games.
This happens because the brightness on some monitors can depends on the refresh
rate, and rapidly changing refresh rates (for example, when the screen
momentarily updates after pressing a key) will cause rapid changes in
brightness.

If you want VRR always enabled regardless,
the flickering can be mitigated or even removed by changing the VRR range in your monitor's EDID.
More information in [the ArchWiki](https://wiki.archlinux.org/title/Kernel_mode_setting#Forcing_modes_and_EDID).

### How do I update?

Open a terminal where you cloned the repo.

```bash
git pull
make all && sudo make install
```

If you are using the AUR (hyprland-git) package, you will need to cleanbuild to
update the package. Paru has been problematic with updating before, use Yay.

### How do I screen lock?

Use a Wayland-compatible locking utility using WLR protocols, e.g. `swaylock`.
Be aware that they will not prevent tty-changing using Ctrl-Alt-F1...F7.

### How do I change me mouse cursor?

See [hyprcursor](../Hypr-Ecosystem/hyprcursor)

1. Set the GTK cursor using [nwg-look](https://github.com/nwg-piotr/nwg-look).
2. Add `hyprctl setcursor [THEME] [SIZE]` to your autoexecs in your config and restart Hyprland.

If using flatpak, run `flatpak override --filesystem=~/.themes:ro --filesystem=~/.icons:ro --user` and put your themes in both `/usr/share/themes` and `~/.themes`, and put your icons and cursors in both `/usr/share/icons` and `~/.icons`.

For Qt applications, Hyprland exports XCURSOR_SIZE as 24, which is the default.
You can overwrite this by exporting XCURSOR_SIZE to a different value with `env`.

You can also try running `gsettings set org.gnome.desktop.interface cursor-theme 'theme-name'` or adding it after autoexecs in your config.

If you do not want to install a GTK settings editor, change the config files according to the
[XDG specification (Arch Wiki link)](https://wiki.archlinux.org/title/Cursor_themes#Configuration).
Make sure to also edit `~/.config/gtk-4.0/settings.ini` and `~/.gtkrc-2.0` if _not_ using a tool
(like `nwg-look`).

### GTK Settings no work / whatever

[https://github.com/swaywm/sway/wiki/GTK-3-settings-on-Wayland](https://github.com/swaywm/sway/wiki/GTK-3-settings-on-Wayland)

### My \[program name\] is freezing

Make sure you have a notification daemon running, for example `dunst`. You can autostart them
in the config.

### Waybar workspaces no worky???

Waybar has a set of caveats or settings that you need to be aware of. See
[Status bars](../Useful-Utilities/Status-Bars) for solutions.

### How do I autostart my favorite apps?

Using the window rules to assign apps to workspaces, you can open a bunch of
applications on various workspaces. The following method will start these apps
silently (i.e. without the flickering from workspace to workspace).

Put the following in your `hyprland.lua`: (example)

```lua
hl.on("hyprland.start", function ()
  hl.exec_cmd("kitty")
  hl.exec_cmd("dolphin")
  hl.exec_cmd("dunst")
  hl.exec_cmd("amongus", { workspace = "1" })
end)
```

### How do I move my favorite workspaces to a new monitor when I plug it in?

You can listen to the `monitor.added` event and move your workspaces there.

### My tablet no worky??

Use [Open Tablet Driver](https://github.com/OpenTabletDriver/OpenTabletDriver)
to configure your tablet. In the future it will be supported in the config.
Until then, OTD is the way to go.

### Some of my apps take a really long time to open...?

```lua {filename="~/.config/hypr/hyprland.lua"}
hl.on("hyprland.start", function()
  hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
end)
```

Make sure that your portals launch _after_ this gets executed. For some people,
they might launch before that has happened.

In such cases, a script like this:

```bash
#!/usr/bin/env bash
sleep 4
killall -e xdg-desktop-portal-hyprland
killall xdg-desktop-portal
/usr/lib/xdg-desktop-portal-hyprland &
sleep 4
/usr/lib/xdg-desktop-portal &
```

launched on start should fix all issues. Adjust the sleep durations to
taste.

### How do I export envvars for Hyprland?

See [Environment Variables](../Configuring/Advanced-and-Cool/Environment-variables)

The `hl.env()` function is used for this purpose. For example:

```lua
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
```

### How to disable middle-click paste?

Setting `misc.middle_click_paste` to `false` disables the feature altogether with the exception of some browsers (notably firefox) having a separate built-in way of emulating that feature which has to be disabled within the browser's settings.

### My apps take a long time to start / can't screenshare

See [The XDPH Page](../Hypr-Ecosystem/xdg-desktop-portal-hyprland/#debugging).

You most likely have multiple portal impls / an impl is failing to launch.

### My screenshot utilities won't work with multiple screens

Some programs like Flameshot (currently) have limited Wayland support, consider
using one made for wayland natively.

### I cannot bind SUPER as my mod key on my laptop

Many laptops have a built-in function to toggle `SUPER` between single key press
mode and hold mode. This is usually indicated by a padlock on the `SUPER` key.

First, install and run `wev`, then press `SUPER`. If you see a key press event
followed by an instant key release event, then it's likely your `SUPER` key is
set to single press mode.

On most laptops, this can be fixed by pressing `FN+SUPER` and verified in `wev`.
You should be able to hold `SUPER` and not see an instant release event. In case
`FN+SUPER` doesn't work, consult your laptop's manual.

### My VM doesn't receive keybinds I have set in Hyprland

This is expected, as Hyprland takes precedence.

A simple fix is to create an empty "passthrough" submap:

```lua
hl.define_submap("passthru", function()
  hl.bind("SUPER + Escape", hl.dsp.submap("reset"))
end)
hl.bind("...", hl.dsp.submap("passthru"))
```

By pressing the selected combo, you will enter a mode where Hyprland ignores your
keybinds and passes them on to the VM. Pressing `SUPER + Escape` will leave that mode.

### Steam's file picker no worky

On instances where you have a Steam library on another drive that you have to
add, Hyprland's file picker would not normally appear when selecting a directory
from Steam.

Steam has its own file picker, however, it's not functional. Install
`xdg-desktop-portal-gtk` to show the desktop's file picker.

### Workspaces or clients are disappearing or monitor related dispatchers cause crashes

It seems there is a Kernel bug making the system think there is an extra
phantom monitor, that causes all sorts of issues, crashes and weird behaviors
like disappearing workspaces or clients when adding or removing an external
monitor.

First check the list of monitors detected by Hyprland by running:

```ini
hyprctl monitors
```

If you see a monitor that should not be there (usually named `Unknown-1`), you
can work around the issue by adding in your `hyprland.lua`:

```lua
hl.monitor({ output = "Unknown-1", disabled = true })
```

### I get a .so file missing error on launch

If you are using a -git package, this is a common occurrence when ABI-breaking updates are done.

_**Do not**_ symlink different .so versions, this will cause crashes!!!

Instead, find all hypr* packages with `-git` you have installed, remove them (possibly remove dependencies of them, too)
and simply install them again.

If using yay, make sure to `CleanBuild` every package. If using paru, manually remove the cache of hypr* packages in `~/.cache/paru`.

If you are not using any -git packages, this is a mistake in your distro's packaging and should be solved there.

### My cursor is a hyprland icon?

This means you have no hyprcursor theme installed, and hyprland failed to find an XCursor theme as well. Install a cursor theme.

### Smart gaps please?

[Here](../Configuring/Basics/Workspace-Rules/#smart-gaps).

### I can't create Discord binds

You most likely have `ELECTRON_OZONE_PLATFORM_HINT = wayland` in your config.

Try running Discord like this `ELECTRON_OZONE_PLATFORM_HINT= discord`.

> [!WARNING]
> Keep in mind that this will run Discord under XWayland.

If it works, navigate to the Discord desktop entry (usually located in `/usr/share/applications/`). Duplicate it and replace `Exec=/usr/bin/discord` with `Exec=env ELECTRON_OZONE_PLATFORM_HINT= /usr/bin/discord`. You can also give it a new name, e.g. `Name=DiscordX`, to avoid confusion as to which is which.

### Fullscreen applications/Steam Games open with secondary monitor's resolution

The issue is likely the default monitor for X11 is not your desired primary monitor, to fix this, do the following:

Add `xrandr --output [MONITOR_ID] --primary` to your autostarts in the config, replacing [MONITOR_ID] with your main monitor's ID (e.g. DP-3). You can find your monitor ID by running `hyprctl monitors`.

By adding this to your hyprland config, it will set the default monitor for X11 applications to your main monitor.

### My mouse cursor keeps escaping the game window!

Whilst most games should be able to lock your cursor seamlessly, you can lock the cursor from Hyprland's side instead using the `confine_pointer` window rule. To apply this rule to all fullscreen apps with content type 'game', the below rule would suffice:

```lua
hl.window_rule({ match = { content = "game", fullscreen = true }, confine_pointer = true })
```
