---
weight: 105
title: aquamarine
---

[aquamarine](https://github.com/hyprwm/aquamarine) is a very light linux rendering backend library.

It is not a replacement or competitor to any other wayland compositor library (e.g. wlroots, libweston), instead implementing only the low-level KMS/DRM/etc rendering backends.

## Configuration

Configuration options are passed via environment variables starting with `AQ_` to an app that uses aquamarine, e.g. Hyprland.

### Variables

| Name | Description |
| --- | --- |
| `AQ_TRACE` | Enables trace (very, very verbose) logging. |
| `AQ_DRM_DEVICES` | A colon-separated list of DRM devices (aka. GPUs) to use. <br> The first will be used as primary. <br> Example: `/dev/dri/card1:/dev/dri/card0`. |
| `AQ_NO_MODIFIERS` | Disables modifiers for DRM buffers. |
| `AQ_MGPU_NO_EXPLICIT` | Disables passing of explicit fences for multi-gpu scanouts |
| `AQ_NO_ATOMIC` | **(HEAVILY NOT RECOMMENDED)** Disable atomic modesetting. |

## Documentation

Documentation will come soon.
