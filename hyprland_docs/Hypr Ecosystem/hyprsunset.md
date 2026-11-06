---
weight: 10
title: hyprsunset
---

[hyprsunset](https://github.com/hyprwm/hyprsunset) is a small utility to provide a blue light filter
for your system.

This method is preferred to screen shaders as it will _not_ be captured via recording / screenshots.

hyprsunset also provides a gamma filter, which can be used to
adjust perceived display brightness on monitors that do not
support software control, or to reduce perceived brightness
below the monitor's minimum.

> [!WARNING]
> `hyprsunset` is supported since Hyprland 0.45.0.

## Installation

{{< tabs items="Arch Linux" >}}

{{< tab "Arch Linux" >}}

```sh
pacman -S hyprsunset
```

{{< /tab >}}

{{< /tabs >}}


## Configuration

Configuration is done via the config file at `~/.config/hypr/hyprsunset.conf`.  
This file is not required for running hyprsunset, though recommended.

Hyprsunset uses profiles to determine when to change temperature and gamma.  
You can define as many profiles as you like.  
Each Profile is activated at it's specified time and resets all options set by other profiles.

On startup, hyprsunset will apply the current profile.  
For example, when launching hyprsunset with the following example config at 20:00, it will activate the first profile, essentially changing nothing.  
Once the clock strikes 21:00, hyprsunset will automatically apply the new profile.

**Example Configuration**
```ini
max-gamma = 150

profile {
    time = 7:30
    identity = true
}

profile {
    time = 21:00
    temperature = 5500
    gamma = 0.8
}
```

| Variable | Description | Type | Default |
| -- | -- | -- | -- |
| `max-gamma` | The maximum the gamma value can be. <br> Absolute maximum is `200`%. <br> Mostly useful when controlling hyprsunset via IPC. | int | `100` |

### Profile

| Variable | Description | Type | Default |
| -- | -- | -- | -- |
| `time` | The time at which the profile should be activated. <br> Must be in the format {hours}:{minutes} | string | `00:00` |
| `temperature` | The screen temperature. Lower means warmer. | int | `6000` |
| `gamma` | The perceived brightness of the screen. <br> This will allow you to lower the brightness beyond your screen's minimum. | float | `1.0` |
| `identity` | When set, the value of temperature is ignored and the only effect of hyprsunset is the change in apparent brightness by gamma. | bool | `false` |


## Usage

To autostart hyprsunset, add: `hyprsunset` to your `hyprland.lua`'s autostart.
Alternatively, use `systemctl --user enable --now hyprsunset.service` in order to use hyprsunset as a systemd user service.

Hyprsunset can also be controlled by supplying arguments to the command.  
By specifying `hyprsunset --temperature 5000` you will override the current active config's temperature setting.  This however, will be overridden once a new profile is activated.

For more information on cli arguments, run `hyprsunset --help`

## IPC

`hyprsunset` supports IPC via hyprctl.  
Both color temperature and the gamma filter are adjustable:

```sh
# Enable blue-light filter
hyprctl hyprsunset temperature 2500
# Disable blue-light filter
hyprctl hyprsunset identity

# Set gamma to 50%
hyprctl hyprsunset gamma 50
# Increase gamma by 10%
hyprctl hyprsunset gamma +10

# Reset config to current profile
hyprctl hyprsunset reset
# Reset value to current profile
hyprctl hyprsunset reset temperature
hyprctl hyprsunset reset gamma
hyprctl hyprsunset reset identity

# Print current profile
hyprctl hyprsunset profile
```

This can be used by other software to change the temperature throughout the day, or to adjust perceieved
monitor brightness, such as with the following Hyprland keybinds:
```ini
bindel = ,XF86MonBrightnessDown, exec, hyprctl hyprsunset gamma -10
bindel = ,XF86MonBrightnessUp, exec, hyprctl hyprsunset gamma +10
```

> [!WARNING]
> Using the gamma control will degrade color accuracy. If your monitor does support software control, it is highly recommended to use that instead.
