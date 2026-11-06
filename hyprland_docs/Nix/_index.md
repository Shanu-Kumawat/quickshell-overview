---
weight: 7
title: Nix
---

To install Hyprland on NixOS, we provide a NixOS and a Home Manager module.

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

## NixOS module

```nix {filename="configuration.nix"}
{
  programs.hyprland.enable = true;
  # Optional, hint electron apps to use wayland:
  # environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
```

For other NixOS options, see [Hyprland on NixOS](./Hyprland-on-NixOS).  
For additional options, see
[module options](https://search.nixos.org/options?channel=unstable&from=0&size=50&sort=relevance&type=packages&query=hyprland).


## Home Manager module

Read [Hyprland on Home Manager](./Hyprland-on-Home-Manager).

For the adventurous, [@spikespaz](https://github.com/spikespaz) has made a
Hyprland module that can be used in Home Manager and NixOS. It can be found
[here](https://github.com/hyprland-community/hyprnix).

## Options and overrides

Read [Options & Overrides](./Options-Overrides).

## Overlays

### default

The `default` Hyprland overlay only contains the Hyprland package along with xdg-desktop-portal-hyprland, and Hyprland's internal dependencies (udis86-hyprland and glaze-hyprland).

This means you need to import all the overlays for the hypr* dependencies yourself if you want them up to date. Otherwise Hyprland will build with the versions available in Nixpkgs.

### hyprland-packages

If you instead want an overlay with all dependencies, import both `hyprland-packages` and `hyprland-extras` overlays.

> [!NOTE]
> The dependencies can sometimes be out of date and impact other hypr* apps. E.g. <https://github.com/hyprwm/Hyprland/discussions/13396>. In such cases, either ping the maintainers to update the lockfiles, or use the `default` overlay.
