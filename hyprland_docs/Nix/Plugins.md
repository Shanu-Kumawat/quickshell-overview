---
title: Plugins
weight: 6
---

Hyprland plugins are managed differently on Nix than on other distros.  
The most notable change is that `hyprpm` is unsupported, but we have our own way of
building and managing plugins.

> [!WARNING]
> Using plugins using the syntax below requires you to be using Hyprland through
> the [Home Manager module](../Hyprland-on-Home-Manager) or the
> [upstream NixOS module](../Hyprland-on-NixOS#upstream-module).

## Using plugins from Nixpkgs

In Nixpkgs, there are Hyprland plugins packaged for the Hyprland version in
Nixpkgs. You can use them like this:

```nix {filename="home.nix"}
{pkgs, ...}: {
  wayland.windowManager.hyprland.plugins = [
    pkgs.hyprlandPlugins.<plugin>
  ];
}
```

You can find which plugins are included using
`nix search nixpkgs#hyprlandPlugins ^`.

## hyprland-plugins

Official plugins made/maintained by vaxry.

To use these plugins, it is recommended to be already using the Hyprland
flake, and **not** the Nixpkgs version.

First, add the flake to your flake inputs:

```nix {filename="flake.nix"}
{
  inputs = {
    hyprland.url = "github:hyprwm/Hyprland";

    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    # ...
  }
}
```

The `inputs.hyprland.follows` line makes hyprland-plugins use the exact Hyprland
revision you have locked.  
This means there aren't any version mismatches, as long as you update both inputs at once.

The next step is adding the plugins to Hyprland:

```nix {filename="home.nix"}
{inputs, pkgs, ...}: {
  wayland.windowManager.hyprland = {
    enable = true;

    plugins = [
      inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.<plugin>
    ];
  };
}
```

## Building plugins with Nix

The plugins inside Nixpkgs, as well as the ones in `hyprland-plugins`, are built
using a general function: `mkHyprlandPlugin`.  
Any plugin can be made to work with it. The general usage is presented below, exemplified through hy3's
derivation:

```nix {filename="plugin.nix"}
{
  lib,
  fetchFromGitHub,
  cmake,
  hyprland,
  hyprlandPlugins,
}:
hyprlandPlugins.mkHyprlandPlugin (finalAttrs: {
  pluginName = "hy3";
  version = "0.39.1";

  src = fetchFromGitHub {
    owner = "outfoxxed";
    repo = "hy3";
    rev = "hl${finalAttrs.version}";
    hash = "sha256-PqVld+oFziSt7VZTNBomPyboaMEAIkerPQFwNJL/Wjw=";
  };

  # any nativeBuildInputs required for the plugin
  nativeBuildInputs = [cmake];

  # set any buildInputs that are not already included in Hyprland
  # by default, Hyprland and its dependencies are included
  buildInputs = [];

  meta = {
    homepage = "https://github.com/outfoxxed/hy3";
    description = "Hyprland plugin for an i3 / sway like manual tiling layout";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux;
  };
})
```

```nix {filename="home.nix"}
{pkgs, ...}: {
  wayland.windowManager.hyprland.plugins = [
    (pkgs.callPackage ./plugin.nix {})
  ];
}
```

In a similar manner to `stdenv.mkDerivation`, `mkHyprlandPlugin` takes an
attrset with mostly the same options as `mkDerivation`, as it is essentially a
wrapper around it.
