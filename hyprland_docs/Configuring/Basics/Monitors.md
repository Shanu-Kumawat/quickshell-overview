---
weight: 4
title: Monitors
---

> [!NOTE]
> Looking for the old hyprlang syntax? Check the [0.54 wiki pages](https://wiki.hypr.land/0.54.0/).
> Since Hyprland 0.55, hyprlang is deprecated in favor of lua.

## General

The general config of a monitor looks like this:

```lua
hl.monitor({
  output = "...",
  mode = "...",
  position = "...",
  scale = ...,
})
```

A common example:

```lua
hl.monitor({
  output = "DP-1",
  mode = "1920x1080@144",
  position = "0x0",
  scale = 1,
})
```

This will make the monitor on `DP-1` a `1920x1080` display, at
144Hz, `0x0` off from the top left corner, with a scale of 1 (unscaled).

To list all available monitors (active and inactive):

```bash
hyprctl monitors all
```

Monitors are positioned on a virtual "layout". The `position` is the position,
in pixels, of said display in the layout. (calculated from the top-left corner)

For example:

```lua
hl.monitor({ output = "DP-1", mode = "1920x1080", position = "0x0", scale = 1 })
hl.monitor({ output = "DP-2", mode = "1920x1080", position = "1920x0", scale = 1 })
```

will tell Hyprland to put DP-1 on the _left_ of DP-2, while

```lua
hl.monitor({ output = "DP-1", mode = "1920x1080", position = "1920x0", scale = 1 })
hl.monitor({ output = "DP-2", mode = "1920x1080", position = "0x0", scale = 1 })
```

will tell Hyprland to put DP-1 on the _right_.

The `position` may contain _negative_ values, so the above example could also be
written as

```lua
hl.monitor({ output = "DP-1", mode = "1920x1080", position = "0x0", scale = 1 })
hl.monitor({ output = "DP-2", mode = "1920x1080", position = "-1920x0", scale = 1 })
```

Hyprland uses an inverse Y cartesian system. Thus, a negative y coordinate
places a monitor higher, and a positive y coordinate will place it lower.

For example:

```lua
hl.monitor({ output = "DP-1", mode = "1920x1080", position = "0x0", scale = 1 })
hl.monitor({ output = "DP-2", mode = "1920x1080", position = "0x-1080", scale = 1 })
```

will tell Hyprland to put DP-2 _above_ DP-1, while

```lua
hl.monitor({ output = "DP-1", mode = "1920x1080", position = "0x0", scale = 1 })
hl.monitor({ output = "DP-2", mode = "1920x1080", position = "0x1080", scale = 1 })
```

will tell Hyprland to put DP-2 _below_.

> [!NOTE]
> The position is calculated with the scaled (and transformed) resolution, meaning
> if you want your 4K monitor with scale 2 to the left of your 1080p one, you'd
> use the position `1920x0` for the second screen (3840 / 2). If the monitor is
> also rotated 90 degrees (vertical), you'd use `1080x0`.

> [!WARNING]
> No monitors can overlap. This means that if your set positions make any monitors
> overlap, you will get a warning.

> [!NOTE]
> "Invalid scale" warnings will pop up if your scale does not create valid
> logical pixels. A valid scale must divide your resolution cleanly (without
> decimals). For example 1920x1080 / 1.5 = 1280x720 -> OK, but
> when / 1.4 -> 1371.4286x771.42857 -> not ok.

Leaving the `output` empty will define a fallback rule to use when no other rules
match.

There are a few special values for the `mode` field:

- `preferred` - use the display's preferred size and refresh rate.
- `highres` - use the highest supported resolution.
- `highrr` - use the highest supported refresh rate.
- `maxwidth` - use the widest supported resolution.

`position` also has a few special values:

- `auto` - let Hyprland decide on a position. By default, it places each new monitor to the right of existing ones,
  using the monitor's top left corner as the root point.
- `auto-right/left/up/down` - place the monitor to the right/left, above or below other monitors,
  also based on each monitor's top left corner as the root.
- `auto-center-right/left/up/down` - place the monitor to the right/left, above or below other monitors,
  but calculate placement from each monitor's center rather than its top left corner.

_**Please Note:**_ While specifying a monitor direction for your first monitor is allowed, this does nothing and it will
be positioned at (0,0). Also, the direction is always from the center out, so you can specify `auto-up` then `auto-left`,
but the left monitors will just be left of the origin and above the origin. You can also specify duplicate directions and
monitors will continue to go in that direction.

You can also use `auto` as a scale to let Hyprland decide on a scale for you.
These depend on the PPI of the monitor.

Recommended rule for quickly plugging in random monitors:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
```

This will make any monitor that was not specified with an explicit rule
automatically placed on the right of the other(s), with its preferred
resolution.

For more specific rules, you can also use the output's description (see
`hyprctl monitors` for more details). If the output of `hyprctl monitors` looks
like the following:

```yaml
Monitor eDP-1 (ID 0):
        1920x1080@60.00100 at 0x0
        description: Chimei Innolux Corporation 0x150C (eDP-1)
        make: Chimei Innolux Corporation
        model: 0x150C
        [...]
```

then the `description` value up to, but not including the portname `(eDP-1)` can
be used as the `output` field with a `desc:` prefix:

```lua
hl.monitor({ output = "desc:Chimei Innolux Corporation 0x150C", mode = "preferred", position = "auto", scale = 1.5 })
```

Remember to remove the `(portname)`!

### Custom modelines

You can set up a custom modeline by passing a modeline string as the `mode` field:

```lua
hl.monitor({
  output = "DP-1",
  mode = "modeline 1071.101 3840 3848 3880 3920 2160 2263 2271 2277 +hsync -vsync",
  position = "0x0",
  scale = 1,
})
```

### Disabling a monitor

To disable a monitor, set `disabled = true`:

```lua
hl.monitor({ output = "name", disabled = true })
```

> [!WARNING]
> Disabling a monitor will literally remove it from the layout, moving all windows
> and workspaces to any remaining ones. If you want to disable your monitor in a
> screensaver style (just turn off the monitor) use the `dpms`
> [dispatcher](../Dispatchers).

## Custom reserved area

A reserved area is an area that remains unoccupied by tiled windows.
If your workflow requires a custom reserved area, you can add it with the `reserved_area` field.
It accepts either a single integer (all sides) or a table with individual sides:

```lua
-- all sides
hl.monitor({ output = "name", reserved_area = 10 })

-- individual sides
hl.monitor({ output = "name", reserved_area = { top = 10, bottom = 10, left = 0, right = 0 } })
```

This stacks on top of the calculated reserved area (e.g. bars), but you may only use one of these rules per monitor in the config.

## Fields

All fields beyond `output` are optional and fall back to sensible defaults.

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| output | string | required | Output name or `desc:...` description prefix |
| mode | string | preferred | Resolution and refresh rate, e.g. `1920x1080@144` |
| position | string | auto | Position in the virtual layout, e.g. `1920x0` |
| scale | string / float | auto | Scale factor, e.g. `1.5` |
| disabled | boolean | false | Removes the monitor from the layout |
| transform | integer | 0 | Rotation/flip transform (0–7) |
| mirror | string | | Output name to mirror |
| bitdepth | integer | 8 | Bit depth (8 or 10) |
| cm | string | srgb | Color management preset |
| sdr_eotf | string | default | SDR transfer function (default, gamma22, srgb) |
| sdrbrightness | float | 1.0 | SDR brightness in HDR mode |
| sdrsaturation | float | 1.0 | SDR saturation in HDR mode |
| vrr | integer | 0 | VRR mode |
| icc | string | | Absolute path to an ICC profile |
| reserved_area | integer or table | 0 | Reserved area - integer for all sides, or table with top/right/bottom/left |
| supports_wide_color | integer | 0 | Force wide color gamut (-1 = off, 0 = auto, 1 = on) |
| supports_hdr | integer | 0 | Force HDR support (-1 = off, 0 = auto, 1 = on) |
| sdr_min_luminance | float | 0.2 | SDR minimum luminance for SDR→HDR mapping |
| sdr_max_luminance | integer | 80 | SDR maximum luminance |
| min_luminance | float | -1 | Monitor minimum luminance |
| max_luminance | integer | -1 | Monitor maximum possible luminance |
| max_avg_luminance | integer | -1 | Monitor maximum average luminance |

### Mirrored displays

If you want to mirror a display, use the `mirror` field:

```lua
hl.monitor({ output = "DP-3", mode = "1920x1080@60", position = "0x0", scale = 1, mirror = "DP-2" })
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1, mirror = "DP-1" })
```

Please remember that mirroring displays will not "re-render" everything for your
second monitor, so if mirroring a 1080p screen onto a 4K one, the resolution
will still be 1080p on the 4K display. This also means squishing and stretching
will occur on aspect ratios that differ (e.g 16:9 and 16:10).

### 10 bit support

If you want to enable 10 bit support for your display, set `bitdepth = 10`:

```lua
hl.monitor({ output = "eDP-1", mode = "2880x1800@90", position = "0x0", scale = 1, bitdepth = 10 })
```

> [!WARNING]
> Colors registered in Hyprland (e.g. the border color) do _not_ support
> 10 bit.  
> Some applications do _not_ support screen capture with 10 bit enabled.

### Color management presets

Use the `cm` field to change the default sRGB output preset:

```lua
hl.monitor({ output = "eDP-1", mode = "2880x1800@90", position = "0x0", scale = 1, bitdepth = 10, cm = "wide" })
```

```plain
auto    - srgb for 8bpc, wide for 10bpc if supported (recommended)
srgb    - sRGB primaries (default)
dcip3   - DCI P3 primaries
dp3     - Apple P3 primaries
adobe   - Adobe RGB primaries
wide    - wide color gamut, BT2020 primaries
edid    - primaries from edid (known to be inaccurate)
hdr     - wide color gamut and HDR PQ transfer function (experimental)
hdredid - same as hdr with edid primaries (experimental)
```

Fullscreen HDR is possible without the `hdr` cm setting if `render:cm_auto_hdr` is enabled.

Use `sdrbrightness` and `sdrsaturation` to control SDR brightness and saturation in HDR mode.
The default for both values is `1.0`. Typical brightness value should be in the `1.0 ... 2.0` range.

```lua
hl.monitor({
  output = "eDP-1",
  mode = "2880x1800@90",
  position = "0x0",
  scale = 1,
  bitdepth = 10,
  cm = "hdr",
  sdrbrightness = 1.2,
  sdrsaturation = 0.98,
})
```

The default transfer function assumed to be in use on an SDR display for sRGB content is defined by `sdr_eotf`.
The default (`"default"`) follows `render:cm_sdr_eotf`. This can be changed to piecewise sRGB with `"srgb"`,
or Gamma 2.2 with `"gamma22"`.

### ICC Profiles

You can load an ICC profile via the `icc` field (path must be absolute):

```lua
hl.monitor({ output = "eDP-1", icc = "/path/to/icc.icm" })
```

Please note:
- Path needs to be absolute.
- Having an ICC applied will automatically force `sdr_eotf` to `sRGB` for that monitor (for color accuracy).
- Having an ICC applied overrides the CM preset.
- ICCs are fundamentally incompatible with HDR gaming. Funky stuff may happen.

### VRR

Per-display VRR can be configured with the `vrr` field, where the value is the mode from the
[variables page](../Variables).

## Rotating

If you want to rotate a monitor, use the `transform` field:

```lua
hl.monitor({ output = "eDP-1", mode = "2880x1800@90", position = "0x0", scale = 1, transform = 1 })
```

Transform list:

```plain
0 -> normal (no transforms)
1 -> 90 degrees
2 -> 180 degrees
3 -> 270 degrees
4 -> flipped
5 -> flipped + 90 degrees
6 -> flipped + 180 degrees
7 -> flipped + 270 degrees
```

## Default workspace

See [Workspace Rules](../Workspace-Rules).

### Binding workspaces to a monitor

See [Workspace Rules](../Workspace-Rules).
