---
weight: 22
title: Scrolling Layout
---

> [!NOTE]
> Looking for the old hyprlang syntax? Check the [0.54 wiki pages](https://wiki.hypr.land/0.54.0/).
> Since Hyprland 0.55, hyprlang is deprecated in favor of lua.

Scrolling is a layout where windows get positioned on an infinitely growing tape.

<video width="1024" height="566" autoplay muted>
  <source src="https://dl.hypr.land/wiki/demo_scrolling.mp4" type="video/mp4">
</video>

## Config

category name: `scrolling` (`hl.config({ scrolling = {...} })`)

| name | description | type | default |
| --- | --- | --- | --- |
|fullscreen_on_one_column|when enabled, a single column on a workspace will always span the entire screen. | bool | `true` |
| column_width | the default width of a column, [0.1 - 1.0]. | float | `0.5` |
| focus_fit_method | When a column is focused, what method should be used to bring it into view. 0 = center, 1 = fit | int | `1` |
| follow_focus | when a window is focused, should the layout move to bring it into view automatically | bool | `true` |
| follow_min_visible | when a window is focused, require that at least a given fraction of it is visible for focus to follow. Hard input (e.g. binds, clicks) will always follow. [0.0 - 1.0] | float | `0.4` |
| explicit_column_widths | A comma-separated list of preconfigured widths for colresize +conf/-conf | str | `"0.333, 0.5, 0.667, 1.0"` |
| wrap_focus | When enabled, causes `hl.dsp.layoutmsg("focus l/r")` to wrap around at the beginning and end. | bool | `true` |
| wrap_swapcol | When enabled, causes `hl.dsp.layoutmsg("swapcol l/r")` to wrap around at the beginning and end. | bool | `true` |
| direction | Direction in which new windows appear and the layout scrolls. `"left"`/`"right"`/`"down"`/`"up"` | str | `"right"` |

## Workspace rules

| name | description | type |
| --- | --- | --- |
| direction | Same as hl.config({ scrolling{ direction } }) | str |

e.g.

```lua
hl.workspace_rule({ workspace = "2", layout_opts = { direction = "right" } })
```

## Layout messages

Dispatcher `hl.dsp.layout(msg)` params:

| name | description | params |
| --- | --- | --- |
| move | move the layout horizontally, by either a relative logical px (`-200`, `+200`) or columns (`+col`, `-col`) | move data |
| colresize | resize the current column, to either a value or by a relative value e.g. `0.5`, `+0.2`, `-0.2` or cycle the preconfigured ones with `+conf` or `-conf`. Can also be `all (number)` for resizing all columns to a specific width | relative float / relative conf |
| fit | executes a fit operation based on the argument. Available: `active`, `visible`, `all`, `toend`, `tobeg` | fit mode |
| focus | moves the focus and centers the layout, while also wrapping instead of moving to neighbring monitors. | direction |
| promote | moves a window to its own new column | none |
| swapcol | Swaps the current column with its neighbor to the left (`l`) or right (`r`). The swap wraps around (e.g., swapping the first column left moves it to the end). | `l` or `r` |
| inhibit_scroll | Prevents the scrolling view from moving for the currently active workspace. The switch is independent for each workspace | left empty for toggle, or `bool` for explicitly enabling/disabling
| expel | moves the current window to a dedicated column | none |
| consume | moves the current window into the previous column | none |
| consume_or_expel | expel if not alone, consume if alone in a column | `prev` or `next` |

Example key bindings for your Hyprland config:

```lua
hl.bind(mainMod .. " + period", hl.dsp.layout("move +col"))
hl.bind(mainMod .. " + comma", hl.dsp.layout("swapcol l"))
```

## Window rules

With the static rule scrolling_width you can set a starting column width for a window.

```lua
hl.window_rule({ name = "kitty_starting_width", match = { class = "kitty" }, scrolling_width = 0.5})
```
