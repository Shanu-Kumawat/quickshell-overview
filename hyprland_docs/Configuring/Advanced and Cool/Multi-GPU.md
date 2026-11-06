---
weight: 80
title: Multi-GPU
---

> [!NOTE]
> Looking for the old hyprlang syntax? Check the [0.54 wiki pages](https://wiki.hypr.land/0.54.0/).
> Since Hyprland 0.55, hyprlang is deprecated in favor of lua.

## General

If your host machine uses multiple GPUs, you may want to use one GPU
for rendering all the elements for Hyprland including windows, animations, and
another for hardware acceleration for certain applications, etc.

This setup is very common in the likes of gaming laptops, GPU-passthrough
(without VFIO) capable hosts, and if you have multiple GPUs in general.

## Detecting GPUs

For this case, the writer is taking the example of their laptop.

Upon running `lspci -d ::03xx`, one can list all the PCI display controllers
available.

```plain
01:00.0 VGA compatible controller: NVIDIA Corporation TU117M [GeForce GTX 1650 Mobile / Max-Q] (rev a1)
06:00.0 VGA compatible controller: Advanced Micro Devices, Inc. [AMD/ATI] Cezanne [Radeon Vega Series / Radeon Vega Mobile Series] (rev c6)
```

Here it is clear that 2 GPUs are available, the dedicated NVIDIA GTX 1650 Mobile
/ Max-Q and the integrated AMD Cezanne Radeon Vega Series GPU.

Now, run `ls -l /dev/dri/by-path`

```plain
 total 0
lrwxrwxrwx 1 root root  8 Jul 14 15:45 pci-0000:01:00.0-card -> ../card0
lrwxrwxrwx 1 root root 13 Jul 14 15:45 pci-0000:01:00.0-render -> ../renderD128
lrwxrwxrwx 1 root root  8 Jul 14 15:45 pci-0000:06:00.0-card -> ../card1
lrwxrwxrwx 1 root root 13 Jul 14 15:45 pci-0000:06:00.0-render -> ../renderD129
```

So from the above outputs, we can see that the path for the AMD card is
`pci-0000:06:00.0-card`, due to the matching `06:00.0` from the first command.
Do not use the `card1` symlink indicated here. It is dynamically assigned at
boot and is subject to frequent change, making it unsuitable as a marker for GPU selection.

## Telling Hyprland which GPU to use

After determining which "card" belongs to which GPU, we can now tell
Hyprland which GPUs to use by setting the `AQ_DRM_DEVICES` environment variable.

> [!NOTE]
> It is generally a good idea for laptops to use the integrated GPU as the primary
> renderer as this preserves battery life and is practically indistinguishable
> from using the dedicated GPU on modern systems in most cases. Hyprland can be
> run on integrated GPUs just fine. The same principle applies for desktop setups
> with lower and higher power rating GPUs respectively.

If you would like to use another GPU, or the wrong GPU is picked by default,
set `AQ_DRM_DEVICES` to a `:`-separated list of card paths, e.g.

```lua
hl.env("AQ_DRM_DEVICES", "/dev/dri/card0:/dev/dri/card1")
```

Here, we tell Hyprland which GPUs it's allowed to use, in order of priority. 
For example, `card0` will be the primary renderer, but if it isn't available for
whatever reason, then `card1` is primary.

Do note that if you have an external monitor connected to, for example `card1`,
that card must be included in `AQ_DRM_DEVICES` for the monitor to work, though
it doesn't have to be the primary renderer.

You should now be able to use an integrated GPU for lighter GPU loads,
including Hyprland, or default to your dGPU if you prefer.

> [!NOTE]
> [uwsm](../../../Useful-Utilities/Systemd-start) users are advised to export the `AQ_DRM_DEVICES` variable inside `~/.config/uwsm/env-hyprland`, instead. 
> This method ensures that the variable is properly exported to the systemd environment without conflicting with other compositors or desktop environments.
> 
> ```plain
> export AQ_DRM_DEVICES="/dev/dri/card0:/dev/dri/card1"
> ```

## Creating consistent device paths for specific cards

As mentioned above, it's not recommended to use the `/dev/dri/card*` device paths since they
periodically change which device they are symlinked to. Furthermore, the colons in the actual card
device paths are not usable in the `AQ_DRM_DEVICES` environment variable since colons `:` are used
as a separator for multiple paths.

It's possible to use udev rules to create reliable symlinks to particular device cards. For example,
to create a symlink to an AMD card at the path `/dev/dri/amd-igpu`, we can create a udev rule at
`/etc/udev/rules.d/amd-igpu-dev-path.rules` programmatically like so:

```sh
SYMLINK_NAME="amd-igpu"
RULE_PATH="/etc/udev/rules.d/amd-igpu-dev-path.rules"
AMD_IGPU_ID=$(lspci -d ::03xx | grep 'AMD' | cut -f1 -d' ')
UDEV_RULE="$(cat <<EOF
KERNEL=="card*", \
KERNELS=="0000:$AMD_IGPU_ID", \
SUBSYSTEM=="drm", \
SUBSYSTEMS=="pci", \
SYMLINK+="dri/$SYMLINK_NAME"
EOF
)"

echo "$UDEV_RULE" | sudo tee "$RULE_PATH"
```
Then reloading the udev rules with:
```sh
sudo udevadm control --reload
sudo udevadm trigger
```

There should now be a symlink at `/dev/dri/amd-igpu` that points to your respective card file:
```console
$ ls -l /dev/dri/amd-igpu
lrwxrwxrwx 1 root root 5 /dev/dri/amd-igpu -> card1
```

This symlink will automatically update to point to correct card file if it ever changes.

Now it is possible to use the new symlink in the `AQ_DRM_DEVICES` environment variable:
```lua
hl.env("AQ_DRM_DEVICES", "/dev/dri/amd-igpu")
```