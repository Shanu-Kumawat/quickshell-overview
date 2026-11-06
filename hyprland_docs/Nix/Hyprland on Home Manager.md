---
title: Hyprland on Home Manager
weight: 3
---

For a list of available options, check the
[Home Manager options](https://nix-community.github.io/home-manager/options.xhtml#opt-wayland.windowManager.hyprland.enable).

> [!WARNING]
> **Required:**
> - **NixOS Module:** enables critical components needed to run Hyprland properly.  
>   Without this, you may have issues with missing session files in your
>     Display Manager.
> 
> **Optional**:
> - **Home Manager module:** lets you configure Hyprland declaratively through Home Manager.  
> - Configures Hyprland and adds it to your user's `$PATH`, but
>     does not make certain system-level changes such as adding a desktop session
>     file for your display manager.  
>     This is handled by the NixOS module, once you enable it.

## Installation

{{< tabs items="Home Manager,Flakes,Nix stable (with flake-compat)" >}}

{{< tab "Home Manager" >}}

```nix {filename="home.nix"}
{
  programs.kitty.enable = true; # required for the default Hyprland config
  wayland.windowManager.hyprland.enable = true; # enable Hyprland

  # Optional, hint Electron apps to use Wayland:
  # home.sessionVariables.NIXOS_OZONE_WL = "1";
}
```

{{< /tab >}}

{{< tab "Flakes" >}}

The following snippet of code tries to show how to bring the Hyprland flake from
the flake input and use its packages with Home Manager. Feel free to make any
adjustment for your setup.

Don't forget to replace `user@hostname` with your username and hostname!

```nix {filename="flake.nix"}
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";
  };

  outputs = {nixpkgs, home-manager, hyprland, ...}: {
    homeConfigurations."user@hostname" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;

      modules = [
        {
          wayland.windowManager.hyprland = {
            enable = true;
            # set the flake package
            package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
            portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
          };
        }
        # ...
      ];
    };
  };
}
```

{{< /tab >}}

{{< tab "Nix stable (with flake-compat)" >}}

> [!WARNING]
> The flake module is merely an extension to the Home Manager downstream module.
> It is mainly used as a staging area for new options, so unless you're a tester
> you should use the downstream Home Manager module.

The following snippet of code tries to show how to bring the Hyprland flake from
the flake input and use the package in the Home Manager option. Feel free to
make any adjustment for your setup.

```nix {filename="home.nix"}
{pkgs, ...}: let
  flake-compat = builtins.fetchTarball "https://github.com/edolstra/flake-compat/archive/master.tar.gz";

  hyprland = (import flake-compat {
    src = builtins.fetchTarball "https://github.com/hyprwm/Hyprland/archive/main.tar.gz";
  }).defaultNix;
in {
  wayland.windowManager.hyprland = {
    enable = true;
    # set the flake package
    package = hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  }
}
```

{{< /tab >}}

{{< /tabs >}}

## Usage

Once the module is enabled, you can use it to declaratively configure Hyprland.
Here is an example config:

```nix {filename="home.nix"}
{
  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";
    bind =
      [
        "$mod, F, exec, firefox"
        ", Print, exec, grimblast copy area"
      ]
      ++ (
        # workspaces
        # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
        builtins.concatLists (builtins.genList (i:
            let ws = i + 1;
            in [
              "$mod, code:1${toString i}, workspace, ${toString ws}"
              "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
            ]
          )
          9)
      );
  };
}
```

## Plugins

Hyprland plugins can be added through the `plugins` option:

```nix {filename="home.nix"}
{
  wayland.windowManager.hyprland.plugins = [
    inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.hyprbars
    "/absolute/path/to/plugin.so"
  ];
}
```

For examples on how to build Hyprland plugins using Nix, see the
[Nix/Plugins](../Plugins) page.

## FAQ

### Fixing problems with themes

If your themes for mouse cursors, icons or windows don't load correctly, try
setting them with `home.pointerCursor` and `gtk.theme`, which enable a bunch of
compatibility options that should make the themes load in all situations.

Example configuration:

```nix {filename="home.nix"}
{
  home.pointerCursor = {
    gtk.enable = true;
    # x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 16;
  };

  gtk = {
    enable = true;

    theme = {
      package = pkgs.flat-remix-gtk;
      name = "Flat-Remix-GTK-Grey-Darkest";
    };

    iconTheme = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
    };

    font = {
      name = "Sans";
      size = 11;
    };
  };
}
```

### Using the Home-Manager module with NixOS

If you want to use the Home Manager module while using the Hyprland package you've
defined in your NixOS module, you can now do so as long as you're running
[Home Manager `5dc1c2e40410f7dabef3ba8bf4fdb3145eae3ceb`](https://github.com/nix-community/home-manager/commit/5dc1c2e40410f7dabef3ba8bf4fdb3145eae3ceb)
or later by setting your `package` and `portalPackage` to `null`.

```nix {filename="home.nix"}
{
  wayland.windowManager.hyprland = {
    enable = true;
    # set the Hyprland and XDPH packages to null to use the ones from the NixOS module
    package = null;
    portalPackage = null;
  };
}
```

Make sure **not** to mix versions of Hyprland and XDPH.
If your NixOS config uses Hyprland from the flake, you should also use XDPH from the flake.
If you set the Home Manager Hyprland module package to `null`, you should also set the XDPH package to `null`.

### Programs don't work in systemd services, but do on the terminal

This problem is related to systemd not importing the environment by default. It
will not have knowledge of `PATH`, so it cannot run the commands in the
services. This is the most common with user-configured services such as
`hypridle` or `swayidle`.

To fix it, add to your config:

```nix {filename="home.nix"}
{
  wayland.windowManager.hyprland.systemd.variables = ["--all"];
}
```

This setting will produce the following entry in the Hyprland config:

```ini {filename="hyprland.conf"}
exec-once = dbus-update-activation-environment --systemd --all
```

Make sure to use the above command if you do not use the Home Manager module.

#### NixOS UWSM

If you're using the NixOS module with UWSM (`programs.hyprland.withUWSM =
true`), you can [set environment variables][uwsm-env] like this:

```nix {filename="home.nix"}
{
  xdg.configFile."uwsm/env".source = "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh"; 
}
```

[uwsm-env]: https://github.com/Vladimir-csp/uwsm?tab=readme-ov-file#4-environments-and-shell-profile "Environments and shell profile - UWSM"
