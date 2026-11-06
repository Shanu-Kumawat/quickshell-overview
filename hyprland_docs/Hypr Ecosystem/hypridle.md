---
weight: 4
title: hypridle
---

[hypridle](https://github.com/hyprwm/hypridle) is Hyprland's idle management daemon.

## Configuration

Configuration is done via the config file at `~/.config/hypr/hypridle.conf`.  
A config file is required; hypridle won't run without one.  
To run hypridle at startup, add `hypridle` to your autostart commands in your hyprland config.
If Hyprland is started with [uwsm](../../Useful-Utilities/Systemd-start), you can use `systemctl --user enable --now hypridle.service`.

### General

Variables in the `general` category:

| Variable | Description | Type | Default |
| --- | --- | --- | --- |
| `lock_cmd` | command to run when receiving a dbus lock event (e.g. `loginctl lock-session`) | string | empty |
| `unlock_cmd` | command to run when receiving a dbus unlock event (e.g. `loginctl unlock-session`) | string | empty |
| `on_lock_cmd` | command to run when the session gets locked by a lock screen app | string | empty |
| `on_unlock_cmd` | command to run when the session gets unlocked by a lock screen app | string | empty |
| `before_sleep_cmd` | command to run when receiving a dbus prepare_sleep event | string | empty |
| `after_sleep_cmd` | command to run when receiving a dbus post prepare_sleep event | string | empty |
| `ignore_dbus_inhibit` | whether to ignore dbus-sent idle inhibit events (e.g. from firefox) | bool | `false` |
| `ignore_systemd_inhibit` | whether to ignore `systemd-inhibit --what=idle` inhibitors | bool | `false` |
| `ignore_wayland_inhibit` | whether to ignore Wayland protocol idle inhibitors | bool | `false` |
| `inhibit_sleep` | sleep inhibition mode: <br> `0`: disable <br> `1`: normal <br> `2`: auto <br> `3`: lock notify | int | `2` |

> [!NOTE]
> The `general:inhibit_sleep` option is used to make sure hypridle can perform certain tasks before the system goes to sleep.
> 
> Options:
> - `0` disables sleep inhibition.
> - `1` makes the system wait until hypridle launched `general:before_sleep_cmd`.
> - `2` (auto) selects either `3` or `1` depending on whether hypridle detects if you want to launch hyprlock before sleep.
> - `3` makes your system wait until the session gets locked by a lock screen app. This works with all wayland session-lock apps.

### Listeners

Hypridle uses listeners to define actions on idleness.

Every listener has a _timeout_ (in seconds). After idling for _timeout_ seconds,
`on-timeout` will fire.  
When action is resumed after idle, `on-resume` will fire.

Example listener:

```ini
listener {
    timeout = 500                            # in seconds.
    on-timeout = notify-send "You are idle!" # command to run when timeout has passed.
    on-resume = notify-send "Welcome back!"  # command to run when activity is detected after timeout has fired.
}
```

You can define as many listeners as you want.

Variables in the `listener` category:

| variable | description | type | default |
| --- | --- | --- | --- |
| `timeout` | Idle time in seconds. | int | none, value must be specified |
| `on-timeout` | Command to run when timeout has passed. | string | empty |
| `on-resume` | Command to run when activity is detected after timeout has fired. | string | empty |
| `ignore_inhibit` | Ignore idle inhibitors (of all types) for this rule. | bool | `false` |

### Examples

Full hypridle example with hyprlock:

```ini
general {
    lock_cmd = pidof hyprlock || hyprlock                                     # avoid starting multiple hyprlock instances.
    before_sleep_cmd = loginctl lock-session                                  # lock before suspend.
    after_sleep_cmd = hyprctl dispatch 'hl.disp.dpms({ action = "enable" })'  # to avoid having to press a key twice to turn on the display.
}

listener {
    timeout = 150                                # 2.5min.
    on-timeout = brightnessctl -s set 10         # set monitor backlight to minimum, avoid 0 on OLED monitor.
    on-resume = brightnessctl -r                 # monitor backlight restore.
}

# turn off keyboard backlight, comment out this section if you dont have a keyboard backlight.
listener { 
    timeout = 150                                          # 2.5min.
    on-timeout = brightnessctl -sd rgb:kbd_backlight set 0 # turn off keyboard backlight.
    on-resume = brightnessctl -rd rgb:kbd_backlight        # turn on keyboard backlight.
}

listener {
    timeout = 300                                 # 5min
    on-timeout = loginctl lock-session            # lock screen when timeout has passed
}

listener {
    timeout = 330                                                                                  # 5.5min
    on-timeout = hyprctl dispatch 'hl.dsp.dpms({ action = "disable" })'                            # screen off when timeout has passed
    on-resume = hyprctl dispatch 'hl.dsp.dpms({ action = "enable" })' && brightnessctl -r          # screen on when activity is detected after timeout has fired.
}

listener {
    timeout = 1800                                # 30min
    on-timeout = systemctl suspend                # suspend pc
}
```
