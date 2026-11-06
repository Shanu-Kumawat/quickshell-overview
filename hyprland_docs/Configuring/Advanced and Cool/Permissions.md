---
weight: 30
title: Permissions
---

> [!NOTE]
> Looking for the old hyprlang syntax? Check the [0.54 wiki pages](https://wiki.hypr.land/0.54.0/).
> Since Hyprland 0.55, hyprlang is deprecated in favor of lua.

If you have `hyprland-guiutils` installed, you can make use of Hyprland's built-in
permission system.

For now, it only has a few permissions, but it might include more in the future.

## Permissions

Permissions work a bit like Android ones. If an app tries to do something sensitive with
the compositor (Hyprland), Hyprland will pop up a notification asking you if you
want to let it do that.

> [!NOTE]
> Before setting up permissions, make sure you enable them by setting
> `hl.config({ ecosystem = { enforce_permissions = true } })`, as it's disabled by default.


### Configuring permissions

> [!IMPORTANT]
> Permissions set up in the config are **not** reloaded on-the-fly and require a Hyprland
> restart for security reasons.

Configuring them is simple:

```lua
hl.permission({ binary, type, mode })
```

for example:
```lua
hl.permission({ binary = "/usr/bin/grim", type = "screencopy", mode = "allow" })
```
Will allow `/usr/bin/grim` to always capture your screen without asking.

```lua
hl.permission({ binary = "/usr/bin/appsuite-.*", type = "screencopy", mode = "allow" })
```
Will allow any app whose path starts with `/usr/bin/appsuite-` to capture your screen without asking.

### Permission modes

There are 3 modes:
- `allow`: Don't ask, just allow the app to proceed.
- `ask`: Pop up a notification every time the app tries to do something sensitive. These popups allow you to Deny, Allow until the app exits, or Allow until Hyprland exits.
- `deny`: Don't ask, always deny the application access.


### Permission list

`screencopy`:
 - Default: **ASK**
 - Access to your screen _without_ going through xdg-desktop-portal-hyprland. Examples include: `grim`, `wl-screenrec`, `wf-recorder`.
 - If denied, will render a black screen with a "permission denied" text.
 - Why deny? For apps / scripts that might maliciously try to capture your screen without your knowledge by using wayland protocols directly.

`plugin`:
 - Default: **ASK**
 - Access to load a plugin. Can be either a regex for the app binary, or plugin path.
 - Do _not_ allow `hyprctl` to load your plugins by default (attacker could issue `hyprctl plugin load /tmp/my-malicious-plugin.so`) - use either `deny` to disable or `ask` to be prompted.

`keyboard`:
 - Default: **ALLOW**
 - Access to connecting a new keyboard. Regex of the device name.
 - If you want to disable all keyboards not matching a regex, make a rule that sets `DENY` for `.*` _as the last keyboard permission rule_.
 - Why deny? Rubber duckies, malicious virtual / usb keyboards.

`cursorpos`:                                                                                        
 - Default: **ASK**
 - Access to your cursor position and cursor image via Wayland protocols directly.                                                           
 - Why deny? Prevents apps from silently tracking where your cursor is without going through xdg-desktop-portal.

## Notes

**xdg-desktop-portal** implementations (including xdph) are just regular applications. They will go through permissions too. You might want to consider
adding a rule like this:
```lua
hl.permission({ binary = "/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", type = "screencopy", mode = "allow" })
```
if you are not allowing screencopy for all apps.

<br/>

NixOS does not have static paths for the binaries, so regex has to be used. These example rules allow `grim` and `xdg-desktop-portal-hyprland` to copy the screen:
```lua
hl.permission({ binary = "/nix/store/[a-z0-9]{32}-grim-[0-9.]*/bin/grim", type = "screencopy", mode = "allow" })
hl.permission({ binary = "/nix/store/[a-z0-9]{32}-xdg-desktop-portal-hyprland-[0-9.]*/libexec/.xdg-desktop-portal-hyprland-wrapped", type = "screencopy", mode = "allow" })
```

When rendering the configuration with Nix itself, string interpolation can also be used (be aware that if the path contains special regex characters (e.g. `+`) they need to be escaped):
```lua
hl.permission({ binary = "${lib.getExe pkgs.grim}", type = "screencopy", mode = "allow" })
hl.permission({ binary = "${lib.escapeRegex (lib.getExe config.programs.hyprlock.package)}", type = "screencopy", mode = "allow" })
hl.permission({ binary = "${pkgs.xdg-desktop-portal-hyprland}/libexec/.xdg-desktop-portal-hyprland-wrapped", type = "screencopy", mode = "allow" })
```

<br/>

On some **BSD** systems paths might not work. In such cases, you might want to disable permissions altogether, by setting
```lua
hl.config({ 
  ecosystem = {
    enforce_permissions = false
  }
})
```
otherwise, you have no _config_ control over permissions (popups will still work, although will not show paths, and "remember" will not be available).
