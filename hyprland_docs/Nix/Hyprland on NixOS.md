---
title: Hyprland on NixOS
weight: 1
---

The NixOS module enables critical components needed to run Hyprland properly,
such as polkit,
[xdg-desktop-portal-hyprland](https://github.com/hyprwm/xdg-desktop-portal-hyprland),
graphics drivers, fonts, dconf, xwayland, and adding a proper Desktop Entry to
your Display Manager.

Make sure to check out the options of the
[NixOS module](https://search.nixos.org/options?channel=unstable&from=0&size=50&sort=relevance&type=packages&query=hyprland).

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

{{< tabs items="Nixpkgs,Flakes,Nix stable (flake-compat)" >}}

{{< tab "Nixpkgs" >}}

```nix {filename="configuration.nix"}
{
  programs.hyprland.enable = true; # enable Hyprland

  environment.systemPackages = [
    # ... other packages
    pkgs.kitty # required for the default Hyprland config
  ];

  # Optional, hint Electron apps to use Wayland:
  # environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
```

This will use the Hyprland version included in the Nixpkgs release you're using.

{{< /tab >}}

{{< tab >}}

> [!NOTE]
> If you don't want to compile Hyprland yourself, make sure to enable [Cachix](../Cachix).

In case you want to use the _development_ version of Hyprland, you can add it like
this:

```nix {filename="flake.nix"}
{
  inputs.hyprland.url = "github:hyprwm/Hyprland";
  # ...

  outputs = {nixpkgs, ...} @ inputs: {
    nixosConfigurations.HOSTNAME = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; }; # this is the important part
      modules = [
        ./configuration.nix
      ];
    };
  };
}
```

Don't forget to change the `HOSTNAME` to your actual hostname!

```nix {filename="configuration.nix"}
{inputs, pkgs, ...}: {
  programs.hyprland = {
    enable = true;
    # set the flake package
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    # make sure to also set the portal package, so that they are in sync
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };
}
```

If you are using the Home Manager module, you will need to add these lines there as well/instead

If you start experiencing lag and FPS drops in games or programs like Blender on
**stable** NixOS when using the Hyprland flake, it is most likely a `mesa`
version mismatch between your system and Hyprland.

You can fix this issue by using `mesa` from Hyprland's `nixpkgs` input:

```nix {filename="configuration.nix"}
{pkgs, inputs, ...}: let
  pkgs-unstable = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in {
  hardware.graphics = {
    package = pkgs-unstable.mesa;

    # if you also want 32-bit support (e.g for Steam)
    enable32Bit = true;
    package32 = pkgs-unstable.pkgsi686Linux.mesa;
  };
}
```

For more details, see
[issue #5148](https://github.com/hyprwm/Hyprland/issues/5148).

{{< /tab >}}

{{< tab "Nix stable" >}}

> [!NOTE]
> If you don't want to compile Hyprland yourself, make sure to enable [Cachix](../Cachix).

```nix {filename="configuration.nix"}
{pkgs, ...}: let
  flake-compat = builtins.fetchTarball "https://github.com/edolstra/flake-compat/archive/master.tar.gz";

  hyprland = (import flake-compat {
    src = builtins.fetchTarball "https://github.com/hyprwm/Hyprland/archive/main.tar.gz";
  }).defaultNix;
in {
  programs.hyprland = {
    enable = true;
    # set the flake package
    package = hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    # make sure to also set the portal package, so that they are in sync
    portalPackage = hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };
}
```

{{< /tab >}}

{{< /tabs >}}

## Fixing problems with themes

If your themes for your mouse cursors, icons or windows don't load correctly, see the
relevant section in [Hyprland on Home Manager](../Hyprland-on-Home-Manager).

If you prefer not to use Home Manager, you can also resolve the issues with GTK
themes using dconf like so:

```nix {filename="configuration.nix"}
{
  programs.dconf.profiles.user.databases = [
    {
      settings."org/gnome/desktop/interface" = {
        gtk-theme = "Adwaita";
        icon-theme = "Flat-Remix-Red-Dark";
        font-name = "Noto Sans Medium 11";
        document-font-name = "Noto Sans Medium 11";
        monospace-font-name = "Noto Sans Mono Medium 11";
      };
    }
  ];
}
```

## Upstream module

The [upstream module](https://github.com/hyprwm/Hyprland/blob/main/nix/module.nix)
provides options similar to the ones in the [Home Manager module](../Hyprland-on-Home-Manager).

To use it, simply add

```nix
{inputs, ...}: {
  imports = [inputs.hyprland.nixosModules.default];

  programs.hyprland = {
    # usual Nixpkgs module options
    plugins = [
      #...
    ];
    settings = {
      # ...
    };
  };
}
```
