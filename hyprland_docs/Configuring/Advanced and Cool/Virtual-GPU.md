---
weight: 90
title: Virtual-GPU
---

> [!NOTE]
> Looking for the old hyprlang syntax? Check the [0.54 wiki pages](https://wiki.hypr.land/0.54.0/).
> Since Hyprland 0.55, hyprlang is deprecated in favor of lua.

## General

If you happen to be in possession of a GPU that falls into one of these categories:
- Intel Arc Pro card
- Intel laptop integrated graphics
- NVIDIA Workstation or Server  card
- NVIDIA RTX 2000 series card
- AMD Radeon Instinct card

It is very likely that your graphics card supports virtual partitioning, either through the use
of mediated devices or SR-IOV. The means of enabling this partitioning is beyond the scope 
of this wiki, and is very different between vendors.

As an example, once partitioning is enabled, this is what an RTX A5000 card will create:
```
# lspci -d 10de:
```
```plain
01:00.0 3D controller: NVIDIA Corporation GA102GL [RTX A5000] (rev a1)
01:00.4 3D controller: NVIDIA Corporation GA102GL [RTX A5000] (rev a1)
01:00.5 3D controller: NVIDIA Corporation GA102GL [RTX A5000] (rev a1)
01:00.6 3D controller: NVIDIA Corporation GA102GL [RTX A5000] (rev a1)
01:00.7 3D controller: NVIDIA Corporation GA102GL [RTX A5000] (rev a1)
01:01.0 3D controller: NVIDIA Corporation GA102GL [RTX A5000] (rev a1)
01:01.1 3D controller: NVIDIA Corporation GA102GL [RTX A5000] (rev a1)
01:01.2 3D controller: NVIDIA Corporation GA102GL [RTX A5000] (rev a1)
01:01.3 3D controller: NVIDIA Corporation GA102GL [RTX A5000] (rev a1)
01:01.4 3D controller: NVIDIA Corporation GA102GL [RTX A5000] (rev a1)
01:01.5 3D controller: NVIDIA Corporation GA102GL [RTX A5000] (rev a1)
01:01.6 3D controller: NVIDIA Corporation GA102GL [RTX A5000] (rev a1)
01:01.7 3D controller: NVIDIA Corporation GA102GL [RTX A5000] (rev a1)
01:02.0 3D controller: NVIDIA Corporation GA102GL [RTX A5000] (rev a1)
01:02.1 3D controller: NVIDIA Corporation GA102GL [RTX A5000] (rev a1)
01:02.2 3D controller: NVIDIA Corporation GA102GL [RTX A5000] (rev a1)
01:02.3 3D controller: NVIDIA Corporation GA102GL [RTX A5000] (rev a1)
01:02.4 3D controller: NVIDIA Corporation GA102GL [RTX A5000] (rev a1)
01:02.5 3D controller: NVIDIA Corporation GA102GL [RTX A5000] (rev a1)
01:02.6 3D controller: NVIDIA Corporation GA102GL [RTX A5000] (rev a1)
01:02.7 3D controller: NVIDIA Corporation GA102GL [RTX A5000] (rev a1)
01:03.0 3D controller: NVIDIA Corporation GA102GL [RTX A5000] (rev a1)
01:03.1 3D controller: NVIDIA Corporation GA102GL [RTX A5000] (rev a1)
01:03.2 3D controller: NVIDIA Corporation GA102GL [RTX A5000] (rev a1)
01:03.3 3D controller: NVIDIA Corporation GA102GL [RTX A5000] (rev a1)
```

You may want to passthrough one of these virtual GPU partitions, also called vGPU, in a virtual machine to run Hyprland with hardware acceleration.

> [!NOTE]
> The following procedures **do not concern paravirtualized drivers like Virtio-GPU**.
> 
> Virtio-GPU is not a virtual partition of your hardware device, but an entirely software-emulated device that forwards its duty to your host GPU. 
> Having been developed for this purpose, it provides an emulated screen output. You can therefore, and as many have already, use Hyprland normally with it.

## Running Hyprland on vGPU

Hyprland requires by default that your graphics card has **at least one display output**. 

However, for all vendors, vGPUs are render-only cards and has no emulated output on Linux. That is because they are targeting VDI infrastructures, 3D rendering, encoding and compute use cases that are all remote. 
This is also suggested by their prefix "3D controller", instead of "VGA compatible controller".

**To allow Hyprland to run** on a graphics card **with no output, you must enable the** `AQ_NO_KMS_REQUIREMENT` environment flag when running Hyprland:
```lua
hl.env("AQ_NO_KMS_REQUIREMENT", "1")
```

### Usage of both a GPU and vGPU

> [!WARN]
> Users of QEMU hypervisor that are both doing a vGPU passthrough and exposing a Virtio-GPU device in their virtual machine are concerned by this section.

Most hardware and paravirtualized drivers will expose the same graphics card twice under the `/dev/dri` directory. One node will be globally accessible and provide render capabilities, while
the other will be privileged and expose one or more display outputs.

```plain
$ ls -lh /dev/dri/
total 0
drwxr-xr-x  2 root root         80 Apr 20 07:01 by-path/
crw-rw----+ 1 root video  226,   1 Apr 20 07:01 card1           # KMS card with outputs
crw-rw-rw-  1 root render 226, 128 Apr 20 07:01 renderD128      # DRM card, render-only
```

Hyprland will, by default, only select nodes on the system with display outputs and ignore the `render` node. But with `AQ_NO_KMS_REQUIREMENT` lifting this need, the `render` node becomes a suitable candidate.

If you happen to be using both a virtual GPU and a hardware GPU on the same virtual machine, **you must set the** `AQ_DRM_DEVICES` **flag**. This flag is described and explained in [Multi-GPU](../Multi-GPU):
```lua
hl.env("AQ_NO_KMS_REQUIREMENT", "1")
hl.env("AQ_DRM_DEVICES", "/dev/dri/card0:/dev/dri/card1")
```

In practice, there is no guaranteed order of which node will be used as the primary renderer in a virtual machine. It is important that you manually decide the priority.

> [!WARN]
> Some hypervisors can expose PCI topologies that can be understood differently at each start. To be sure of setting the correct node, refer to [Multi-GPU section on consistent device paths](../Multi-GPU/#creating-consistent-device-paths-for-specific-cards) for renaming the nodes and making your configuration consistent across reboots. 

## Accessing the virtual display

When Hyprland starts without any display output, it will initialize a headless output called `HEADLESS-0` with a `1920x1080@60Hz` resolution and framerate, that you can alter in your usual `hyprland.conf` file.

You have to use a remote desktop server, supporting the wlroots capture protocol, for accessing the display and interacting with Hyprland.

The following servers are known to be supported:
- [Sunshine/Moonlight](https://app.lizardbyte.dev/Sunshine/)
- [Apollo/Artemis(Moonlight Noir)](https://github.com/ClassicOldSong/Apollo)
- [Wayvnc](https://github.com/any1/wayvnc)

Once you start Hyprland, you can start your server remotely using `hyprctl` on the guest (See [Using hyprctl](../Configuring/Using-hyprctl))
```bash
hyprctl --instance 0 dispatch 'exec_raw("Sunshine")'
```

The remote display server should be running below the Hyprland process to inherit all its environment variables. Otherwise it will not find your headless display.

If everything is configured and working correctly, you can set your server in your `hyprland.conf` file to be autostarted. (See the [FAQ](../Basics/Autostart.md)):
```lua
hl.on("hyprland.start", function ()
    hl.exec_cmd("Sunshine")
end)
```

Congratulations on obtaining your very own virtual Hyprland desktop.
