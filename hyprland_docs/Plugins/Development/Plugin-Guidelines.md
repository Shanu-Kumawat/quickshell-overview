---
weight: 2
title: Plugin guidelines
---

This page documents the recommended guidelines for making a stable and neat
plugin.

## Making your plugin compatible with hyprpm

In order for your plugin to be installable by `hyprpm`, you need a manifest.

`hyprpm` will parse `hyprload` manifests just fine, but it's recommended to use
the more powerful hyprpm manifest.

Make a file in the root of your repository called `hyprpm.toml`.

### Repository metadata

At the beginning, put some metadata about your plugin:

```toml {filename="hyprpm.toml"}
[repository]
name = "MyPlugin"
authors = ["Me"]
commit_pins = [
    ["3bb9c7c5cf4f2ee30bf821501499f2308d616f94", "efee74a7404495dbda70205824d6e9fc923ccdae"],
    ["d74607e414dcd16911089a6d4b6aeb661c880923", "efee74a7404495dbda70205824d6e9fc923ccdae"]
]
```

`name` and `authors` are required. `commit_pins` are optional. See
[commit pins](#commit-pins) for more info.

### Plugins

For each plugin, make a category like this:

```toml {filename="hyprpm.toml"}
[plugin-name]
description = "An epic plugin that will change the world!"
authors = ["Me"]
output = "plugin.so"
build = [
    "make all"
]
```

`description`, `authors` are optional. `output` and `build` are required.

`build` are the commands that `hyprpm` will run in the root of the repo to build
the plugin. Every command will reset the cwd to the repo root.

`output` is the path to the output `.so` file from the root of the repo.

### Commit pins

Commit pins allow you to manage versioning of your plugin. they are pairs of
`hash,hash`, where the first hash is the Hyprland commit hash, and the second is
your plugin's corresponding commit hash.

For example, in the manifest above, `d74607e414dcd16911089a6d4b6aeb661c880923`
corresponds to Hyprland's `0.33.1` release, which means that if someone is
running `0.33.1`, `hyprpm` will reset your plugin to commit hash
`efee74a7404495dbda70205824d6e9fc923ccdae`.

It's recommended you add a pin for each Hyprland release. If no pin matches,
latest git will be used.

## Formatting

Although Hyprland plugins obviously are not _required_ to follow Hyprland's
formatting, naming conventions, etc. it might be a good idea to keep your code
consistent. See
[`.clang-format`](https://github.com/hyprwm/Hyprland/blob/main/.clang-format) in
the Hyprland repo.

## Usage of the API

It's always advised to use the API entries whenever possible, as they are
guaranteed stability as long as the version matches.

It is, of course, possible to use the internal methods by just including the
proper headers, but it should not be treated as the default way of doing things.

Hyprland's internal methods may be changed, removed or added without any prior
notice. It is worth nothing though that methods that "seem" fundamental, like
e.g. `focusWindow` or `mouseMoveUnified` probably are, and are unlikely to
change their general method of functioning.

## Function Hooks

Function hooks allow your plugin to intercept all calls to a function of your
choice. They are to be treated as a last resort, as they are the easiest thing
to break between updates.

Always prefer using Event Hooks.

## Threads

The Wayland event loop is strictly single-threaded. It is not recommended to
create threads in your code, unless they are fully detached from the Hyprland
process. (e.g. saving a file)
