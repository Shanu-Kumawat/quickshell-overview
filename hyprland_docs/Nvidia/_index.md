---
weight: 8
title: Nvidia
---

## Foreword

There is no _official_ Hyprland support for Nvidia hardware. However, many
people have had success with the instructions on this page. Please read
everything in FULL before asking for help.

There are three potential setups you can have with driver setup on Nvidia.

1. Entirely proprietary Nvidia drivers, often referred to as "Proprietary
   Drivers"
2. Entirely proprietary Nvidia drivers, except with the open source kernel
   modules, referred to as "Open Drivers".
3. Nouveau open source drivers. A clean-room implementation of Nvidia drivers,
   referred to simply as "Nouveau", and not to be confused with the "Open
   Drivers".

For maximum performance and support with newer cards, running either of the
first two setups is recommended as it contains some vital optimisations and
power management support for newer GPUs.

> [!WARNING]
> For those on the Nvidia 50xx series of graphics cards (5090, 5080, etc) or
> newer, the open source kernel modules are **REQUIRED** when using the
> proprietary Nvidia drivers.

According to
[Nvidia](https://developer.nvidia.com/blog/nvidia-transitions-fully-towards-open-source-gpu-kernel-modules/),
the open source kernel modules are also recommended to be used by the
architectures Turing and Ampere. In short, this includes the 16xx and 20xx
series of consumer cards and later. Your mileage may vary, so please try both of
them if your card is supported by both.

If either of the proprietary Nvidia driver setups do not work properly on your
computer, the Nouveau driver might work fine. This will likely be the case for
[older cards](https://wiki.archlinux.org/title/NVIDIA#Unsupported_drivers).

## Proprietary driver setup

On Arch Linux and other Arch-based distros, we recommend using the DKMS variety
of the kernel modules, as it will support all installed kernels on your system.

If you are only using the `linux` or `linux-lts` kernels on your system, you can
also use the non-dkms packages if you wish.

For the entirely proprietary Nvidia drivers, you can therefore use the
`nvidia-dkms` package. And for those wanting / needing to use the open source
kernel modules, `nvidia-open-dkms` can be used.

These DKMS packages rely on having the "headers" package installed for your
kernels of choice. So please make sure you have all relevant headers packages
installed on your system. For example, if you have the Zen kernel installed, you
must ensure `linux-zen-headers` is also installed.

### Further Installation

The following packages must also be installed to ensure a smooth experience with
the proprietary drivers.

1. `nvidia-utils`: The userspace graphics drivers. You need this for pretty much
   everything on your system, and we do not recommend running your computer
   without it. If you are also using the "multilib" or "lib32" packages for
   gaming, Steam, Wine, etc., then you also require `lib32-nvidia-utils`.
2. `egl-wayland` (`libnvidia-egl-wayland1` and `libnvidia-egl-gbm1` on Ubuntu):
   This is required in order to enable compatibility between the EGL API and the
   Wayland protocol. This should already be installed on most distros.

### Early KMS, modeset and fbdev

As of Nvidia driver version 570.86.16, `fbdev` has now been enabled by default
when `modeset` is also enabled. Therefore we simply need to enable `modeset`.

To enable it, create and edit `/etc/modprobe.d/nvidia.conf`, and add this line
to the file:

```conf {filename="/etc/modprobe.d/nvidia.conf"}
options nvidia_drm modeset=1
```

If you're on Arch Linux, this step has already been done for you.

If you're on NixOS, it is also
[enabled by default](https://github.com/NixOS/nixpkgs/blob/0196e5372b8b7a282cb3bbe5cbf446617141ce38/nixos/modules/hardware/video/nvidia.nix#L116)
on all driver versions after 535.

Early KMS will allow the Nvidia modules to load earlier into the boot sequence.
On distros using `mkinitcpio`, like Arch, you can enable it by editing
`/etc/mkinitcpio.conf`. In the `MODULES` array add the following module
names:

```conf {filename="/etc/mkinitcpio.conf"}
MODULES=(... nvidia nvidia_modeset nvidia_uvm nvidia_drm ...)
```

> [!WARNING]
> Loading the Nvidia modules early may cause resuming from hibernation to not work anymore (i.e. the system will just boot instead of resuming).
> If you have issues with that, try disabling early KMS.

> [!WARNING]
> Electron or Chromium-based apps can stall for up to a minute after boot on hybrid graphics systems with an Intel iGPU and an Nvidia dGPU.
>
> This can be fixed by loading the `i915` module **before** the Nvidia ones in `/etc/mkinitcpio.conf`. Just edit the `MODULES` line like this:
>
> ```conf {filename="/etc/mkinitcpio.conf"}
> MODULES=(i915 nvidia nvidia_modeset nvidia_uvm nvidia_drm ...)
> ```

You can then rebuild the initramfs with `sudo mkinitcpio -P`, and reboot.

After rebooting, you can verify that DRM is actually enabled by running
`cat /sys/module/nvidia_drm/parameters/modeset` which should return `Y`.

More information is available
[here](https://wiki.archlinux.org/title/NVIDIA#DRM_kernel_mode_setting).

### Environment variables

Add these variables to your Hyprland config:

```lua
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
```

### Finishing up

Install a few packages to get some apps to function natively with Wayland for
the best compatibility and performance. See
[the Master Tutorial](https://wiki.hypr.land/Getting-Started/Master-Tutorial/#force-apps-to-use-wayland).

Reboot your computer.

Launch Hyprland.

It _should_ work now.

### Flickering in Electron / CEF apps

Electron and CEF apps flicker because:

1. They run in XWayland by default.
2. They don't use the `syncobj` protocol by default.

To enable native Wayland support for most Electron apps, add this
environment variable to your config:

```lua
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
```

This has been confirmed to work on Vesktop, VSCodium, Obsidian and will probably
work on other Electron apps as well.

Other Electron or CEF apps have to be launched with these flags:

```sh
--enable-features=UseOzonePlatform --ozone-platform=wayland
```

For Spotify, Arch Linux has a `spotify-launcher` package in their official
repos. Use that instead of the `spotify` package in the AUR. Afterwards,
enable the Wayland flags by creating the file
`~/.config/spotify-launcher.conf` with these contents:

```sh {filename="~/.config/spotify-launcher.conf"}
[spotify]
extra_arguments = ["--enable-features=UseOzonePlatform", "--ozone-platform=wayland"]
```

For Arch Linux, some CEF / Electron apps may also have respective flags files
in `$XDG_CONFIG_HOME`. For example, VSCodium reads them from
`$XDG_CONFIG_HOME/codium-flags.conf` while Obsidian reads them from
`$XDG_CONFIG_HOME/obsidian/user-flags.conf`.

On NixOS, you can set the environment variable `NIXOS_OZONE_WL=1`, which
automatically configures Electron / CEF apps to use Wayland.

As of Electron 35/Chromium 134, the "syncobj" protocol, which implements
explicit sync correctly, is now supported. This resolves all flickering in
Electron apps. However, it needs to be _manually enabled_ by adding the below flag
to any Electron/CEF app:

```sh
--enable-features=WaylandLinuxDrmSyncobj
```

Using this in conjunction with native Wayland on these apps should solve all
issues.

### VA-API hardware video acceleration

Hardware video acceleration on Nvidia and Wayland is possible with the
[nvidia-vaapi-driver](https://github.com/elFarto/nvidia-vaapi-driver). This may
solve specific issues in Electron apps.

The install instructions are available in the README. However, a quick guide
will be given here:

1. Install the package. On Arch, this is `libva-nvidia-driver` in the official
   repos.

2. Add this variable to your Hyprland config:
   ```lua
   hl.env("NVD_BACKEND", "direct")
   ```

   See
   [here](https://github.com/elFarto/nvidia-vaapi-driver?tab=readme-ov-file#upstream-regressions)
   for more information on this environment variable.

You can check the README to get it working for Firefox. There is also
experimental support for Chromium, however there has not been much success.

### Other issues

#### Multi-monitor with hybrid graphics
If you experience issues with multi-monitor setup on a hybrid graphics device
(a laptop with both an Intel and an Nvidia GPU), switching to discrete-only mode may help:

1. Remove the `optimus-manager` package if installed (disabling the
   service does not work).
2. Change your BIOS settings from hybrid graphics to discrete graphics.


#### Multi-GPU (or hybrid graphics) not working for monitors attached to Nvidia GPU
Nvidia doesn't support important features for Multi-GPU which can result in a broken or slow setup.
There are some workarounds to try:

1. Try changing the primary GPU [with the AQ_DRM_DEVICES environment variable](../Configuring/Advanced-and-Cool/Multi-GPU/#telling-hyprland-which-gpu-to-use).
2. Try setting the environment variable `AQ_FORCE_LINEAR_BLIT=0` to not force linear modifiers on Multi-GPU buffers.

This might slow down rendering to secondary monitors and make Hyprland a bit laggy on them,
but it's better than not having a secondary monitor at all, and it's the best we can do on Nvidia.

#### Flickering in XWayland games

XWayland games may flicker or present frames out-of-order in a way which makes
them unplayable. This is due to the lack of implicit synchronization in the
driver, and/or flaky explicit sync support in newer ones.

There are a few fixes:

1. Install the latest versions of `xorg-xwayland`, `wayland-protocols` and
   Nvidia driver. Ensure `xorg-xwayland` is at least version 24.1,
   `wayland-protocols` is at least version 1.34 and Nvidia driver is at least
   version 555. These enable explicit sync on the Nvidia driver and should avoid
   flickering.

2. If your GPU is no longer supported by the 555 or later drivers, install older
   Nvidia drivers which do not exhibit this issue. The last ones that work are
   the 535xx series of drivers. These can be installed on Arch via
   [these AUR packages](https://aur.archlinux.org/packages?O=0&K=535xx)

#### Suspend/wakeup issues

On Arch Linux and NixOS, the instructions below are already done for you, but
for others:

- Enable the services `nvidia-suspend.service`, `nvidia-hibernate.service` and
  `nvidia-resume.service`. They will be started by systemd when needed.

Add `nvidia.NVreg_PreserveVideoMemoryAllocations=1` to your kernel parameters if
you haven't already.

For Nix users, the equivalent of the above is

```nix {filename="configuration.nix"}
{
  hardware.nvidia.powerManagement.enable = true;
}
```

> [!WARNING]
> [Loading the Nvidia modules early](https://wiki.hypr.land/Nvidia/#early-kms-modeset-and-fbdev) may cause resuming from hibernation to not work anymore (i.e. the system will just boot instead of resuming).
> If you have issues with that, try disabling early KMS.

> [!WARNING]
> According to Nvidia, suspend/wakeup issues should be solved on the Nvidia open
> driver. If it still doesn't work and you're using the open driver, it may be
> worth trying the fully proprietary one.

## Still having issues?

If you're still having issues after following this guide, you can join the
[Hyprland Discord](https://discord.gg/hQ9XvMUjjr) and ask for help in the
`#hyprland-nvidia` channel.
