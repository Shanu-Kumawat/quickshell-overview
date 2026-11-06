---
title: Cachix
weight: 4
---

> [!NOTE]
> This page only applies to the flake package.  
> You can safely skip this if you use the Nixpkgs package.

The Hyprland flake is not built by Hydra, so it is not cached in
[cache.nixos.org], like the rest of Nixpkgs.

Instead of requiring you to build Hyprland (and its dependencies, which may
include `mesa`, `ffmpeg`, etc), we provide a Cachix cache that you can add to
your Nix configuration.

The [Hyprland Cachix](https://app.cachix.org/cache/hyprland) exists to cache the
`hyprland` packages and any dependencies not found in [cache.nixos.org].

> [!WARNING]
> In order for Nix to take advantage of the cache, it has to be enabled **before**
> using the Hyprland flake package.

```nix {filename="configuration.nix"}
{
  nix.settings = {
    substituters = ["https://hyprland.cachix.org"];
    trusted-substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  };
}
```

> [!WARNING]
>  Do **not** override Hyprland's `nixpkgs` input
> unless you know what you are doing.  
> Doing so will render the cache useless, since you're building from a different
> Nixpkgs commit. 

[cache.nixos.org]: https://cache.nixos.org
