---
title: Contributing and Debugging
weight: 7
---

Everything needed to build and debug Hyprland and other hyprwm programs is
included inside the provided `devShell`s.

To use it in the cloned repo, simply run `nix develop`.

## Build in debug mode

A debug build is already provided through
`hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland-debug`.

Most hyprwm apps also provide their own `-debug` versions. For those that don't,
one can build the debug version from the CLI by using
[overrideAttrs](../Options-Overrides/#using-nix-repl) with
`cmakeBuildType = "Debug";` or `mesonBuildType = "debug";`, depending on the
program.

## Bisecting an issue

Follow the
[Bisecting an issue](https://wiki.hypr.land/Crashes-and-Bugs/#bisecting-an-issue)
guide. To build, run `nix build`.

> [!WARNING]
> To build with Tracy support, modify `nix/default.nix` to enable the flag, then run
> `nix build '.?submodules=1'`.

To view logs, pass the `--print-build-logs` (`-L`) flag.

To keep a failed build directory, pass the `--keep-failed` flag.

## Building the Wayland stack with ASan

Run `nix develop` first, then follow the
[Building with ASan](https://wiki.hypr.land/Crashes-and-Bugs/#building-the-wayland-stack-with-asan)
guide.

## Getting a debug stacktrace

Debug stacktraces provide useful info on why a program crashed. To get proper
stacktraces from Hyprland, make sure it was [built in debug mode](#build-in-debug-mode).

After a crash, perform the following steps:

```sh
nix shell nixpkgs#gdb # get gdb temporarily
coredumpctl # check the PID of the recent crash
coredumpctl debug <PID> # using the PID found in the previous step
```

The rest of the process is the same as
[here](../../Crashes-and-Bugs#obtaining-a-debug-stacktrace), from step 3 onwards.

## Manual building

Nix works differently than other build systems, so it has its own abstractions
over popular build systems such as Meson, CMake and Ninja.

In order to manually build Hyprland, you can run the following commands, while
in the `nix develop` shell.

For CMake:

```bash
cmakeConfigurePhase # to run the CMake configure phase
buildPhase     # to run the build phase
installPhase   # to run the install phase
```

For Meson:

```bash
mesonConfigurePhase # to run the Meson configure phase
ninjaBuildPhase     # to run the Ninja build phase
mesonInstallPhase   # to run the Meson install phase
```
