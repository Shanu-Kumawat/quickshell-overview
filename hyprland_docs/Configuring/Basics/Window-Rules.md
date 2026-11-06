---
weight: 7
title: Window Rules
---

> [!NOTE]
> Looking for the old hyprlang syntax? Check the [0.54 wiki pages](https://wiki.hypr.land/0.54.0/).
> Since Hyprland 0.55, hyprlang is deprecated in favor of lua.

> [!WARNING]
> Rules are evaluated top to bottom, so the order they're written in does matter!
> More info in [Notes](#notes)

## Window Rules

You can set window rules to achieve different window behaviors based
on their properties.

### Syntax

Basic named rule syntax:

```lua
hl.window_rule({
  name = "apply-something",
  match = {
    class = "my-window"
  },
  border_size = 10
})
```

Basic anonymous rule syntax:

```lua
hl.window_rule({ match = { class = "my-window" }, border_size = 10 })
```

Rules are split into two categories of parameters: _props_ and _effects_. Props
are the fields inside the `match` table, which are used to determine if a window
should get the rule. Effects are what is applied.

_All_ props must match for a rule to be applied.

You can have as many props and effects per rule as you please, in any order as
you please, as long as:
- there is only one of one type (e.g. specifying `match.class` twice is invalid)
- there is at least one _prop_

### Props

The supported fields for the `match` table are:

| Field | Argument | Description |
| -------------- | --------------- | --- |
| class | \[RegEx\] | Windows with `class` matching `RegEx`. |
| title | \[RegEx\] | Windows with `title` matching `RegEx`. |
| initial_class | \[RegEx\] | Windows with `initialClass` matching `RegEx`. |
| initial_title | \[RegEx\] | Windows with `initialTitle` matching `RegEx`. |
| tag | \[name\] | Windows with matching `tag`. |
| xwayland | \[bool\] | Xwayland windows. |
| float | \[bool\] | Floating windows. |
| fullscreen | \[bool\] | Fullscreen windows. |
| pin | \[bool\] | Pinned windows. |
| focus | \[bool\] | Currently focused window. |
| group | \[bool\] | Grouped windows. |
| modal | \[bool\] | Modal windows (e.g. "Are you sure" popups) |
| fullscreen_state_client | \[int\] | Windows with matching `fullscreenstate`. `0` - none, `1` - maximize, `2` - fullscreen, `3` - maximize and fullscreen. |
| fullscreen_state_internal | \[int\] | Windows with matching `fullscreenstate`. `0` - none, `1` - maximize, `2` - fullscreen, `3` - maximize and fullscreen. |
| workspace | \[workspace\] | Windows on matching workspace. Can be `id`, `"name:string"` or a workspace selector. |
| content | \[string\] | Windows with specified content type (none, photo, video, game). |
| xdg_tag | \[RegEx\] | Match a window by its xdgTag (see `hyprctl clients` to check if it has one). |

Keep in mind that you _have_ to declare at least one field, but not all.

> [!NOTE]
> To get more information about a window's class, title, XWayland status or its
> size, you can use `hyprctl clients`.

> [!NOTE]
> In the output of the `hyprctl clients` command:
> `fullscreen` refers to `fullscreen_state_internal` and
> `fullscreenClient` refers to `fullscreen_state_client`

### RegEx writing

Please note Hyprland uses [Google's RE2](https://github.com/google/re2) for
parsing RegEx. This means that all operations requiring polynomial time to
compute will not work. See the [RE2 wiki](https://github.com/google/re2/wiki/Syntax)
for supported extensions.

If you want to _negate_ a RegEx, as in pass only when the RegEx _fails_, you
can prefix it with `negative:`, e.g.: `"negative:kitty"`.

## Effects

### Static effects

Static effects are evaluated once when the window is opened and never again.
This essentially means that it is always the `initialTitle` and `initialClass`
which will be found when matching on `title` and `class`, respectively.

> [!WARNING]
> It is not possible to `float` (or any other static rule) a window based on a
> change in the `title` after the window has been created. This applies to all
> static effects listed here.

| Effect | Argument | Description |
| ---- | ----------- | --- |
| float | boolean | Floats a window. |
| tile | boolean | Tiles a window. |
| fullscreen | boolean | Fullscreens a window. |
| maximize | boolean | Maximizes a window. |
| fullscreen_state | string | Sets the fullscreen mode, e.g. `"1 2"` (internal client). Values: `0` none, `1` maximize, `2` fullscreen, `3` maximize and fullscreen. |
| move | string | Moves a floating window to a given coordinate, monitor-local. E.g. `{100, 200}` or `{"cursor_x-(window_w*0.5))", "(cursor_y-(window_h*0.5))"}`. |
| size | string | Resizes a floating window. E.g. `{800, 600}` or `{"(monitor_w*0.5)", "(monitor_h*0.5)"}`. |
| center | boolean | If the window is floating, will center it on the monitor. |
| pseudo | boolean | Pseudotiles a window. |
| monitor | string | Sets the monitor on which a window should open. E.g. `"1"` or `"DP-1"`. Can be suffixed with `" silent"` |
| workspace | string | Sets the workspace on which a window should open. Can also be `"unset"` or suffixed with `" silent"`. |
| no_initial_focus | boolean | Disables the initial focus to the window. |
| pin | boolean | Pins the window (i.e. show it on all workspaces). _Note: floating only_. |
| group | string | Sets window group properties. See [group options](#group-window-rule-options) below. |
| suppress_event | string | Ignores specific events. Space-separated: `"fullscreen"`, `"maximize"`, `"activate"`, `"activatefocus"`, `"fullscreenoutput"`. |
| content | string | Sets content type: `"none"`, `"photo"`, `"video"`, or `"game"`. |
| no_close_for | integer | Makes the window uncloseable with `killactive` for a given number of ms on open. |
| scrolling_width | number | Set column width for window when starting on a workspace with the scrolling layout. |

#### Expressions

Expressions are used with `move` and `size`. They are space-separated (no
spaces within each expression). All position variables are monitor-local.

- `monitor_w` and `monitor_h` for monitor size
- `window_x` and `window_y` for window position
- `window_w` and `window_h` for window size
- `cursor_x` and `cursor_y` for cursor position

Example expressions:

```lua
move = {"window_w * 0.5", "(monitor_h / 2) + 17"}
size = {"monitor_w * 0.5", "monitor_h * 0.5"}
```

### Dynamic effects

Dynamic effects are re-evaluated every time a property changes.

| Effect | Argument | Description |
| ---- | ----------- | --- |
| persistent_size | boolean | For floating windows, internally store their size. When a new floating window opens with the same class and title, restore the saved size. |
| no_max_size | boolean | Removes max size limitations. |
| stay_focused | boolean | Forces focus on the window as long as it's visible. |
| animation | string | Forces an animation onto a window with an optional style. E.g. `"popin"` or `"popin 80%"`. |
| border_color | gradient | Force the border color. Accepts a color, gradient, or two gradients (active/inactive). E.g. `"rgb(FF0000)"` or `{ colors = {"rgba(33ccffee)", "rgba(00ff99ee)"}, angle = 45 }`. |
| idle_inhibit | string | Sets an idle inhibit rule. Modes: `"none"`, `"always"`, `"focus"`, `"fullscreen"`. |
| opacity | string | Additional opacity multiplier. E.g. `"0.8"` (overall), `"0.9 0.7"` (active/inactive), `"1.0 0.8 0.9"` (active/inactive/fullscreen). Append `" override"` after each value to set absolute instead of multiplied. |
| tag | string | Applies a tag. Use prefix `+`/`-` to set/unset, or no prefix to toggle. E.g. `"+myTag"`. |
| max_size | vec2 | Sets the maximum size for floating windows. E.g. `{ 800, 600 }`. |
| min_size | vec2 | Sets the minimum size for floating windows. E.g. `{ 200, 150 }`. |
| border_size | integer | Sets the border size. |
| rounding | integer | Forces X pixels of rounding, ignoring the default. |
| rounding_power | number | Overrides the rounding power for the window. |
| allows_input | boolean | Forces an XWayland window to receive input even if it requests not to. |
| dim_around | boolean | Dims everything around the window. Meant for floating windows. |
| decorate | boolean | Whether to draw window decorations. (default: `true`) |
| focus_on_activate | boolean | Whether Hyprland should focus an app that requests to be focused. |
| keep_aspect_ratio | boolean | Forces aspect ratio when resizing with the mouse. |
| nearest_neighbor | boolean | Forces nearest-neighbor filtering. |
| no_anim | boolean | Disables animations for the window. |
| no_blur | boolean | Disables blur for the window. |
| no_dim | boolean | Disables window dimming for the window. |
| no_focus | boolean | Disables focus to the window. |
| no_follow_mouse | boolean | Prevents the window from being focused when the mouse moves over it when `input.follow_mouse=1` is set. |
| no_shadow | boolean | Disables shadows for the window. |
| no_shortcuts_inhibit | boolean | Disallows the app from inhibiting your shortcuts. |
| no_screen_share | boolean | Hides the window and its popups from screen sharing by drawing black rectangles in their place. |
| no_vrr | boolean | Disables VRR for the window. Only works when `misc.vrr` is set to `2` or `3`. |
| opaque | boolean | Forces the window to be opaque. |
| force_rgbx | boolean | Forces Hyprland to ignore the alpha channel entirely. |
| sync_fullscreen | boolean | Whether the fullscreen mode should always be the same as the one sent to the window. |
| immediate | boolean | Forces the window to allow tearing. |
| xray | boolean | Sets blur xray mode for the window. |
| render_unfocused | boolean | Forces the window to think it's being rendered when it's not visible. |
| scroll_mouse | number | Forces the window to override `input.scroll_factor`. |
| scroll_touchpad | number | Forces the window to override `input.touchpad.scroll_factor`. |
| confine_pointer | boolean | Locks the mouse cursor to the window. Mostly useful for keeping your mouse cursor locked to one monitor during gaming.

All dynamic effects can be set with `setprop`.

### `group` window rule options

The `group` effect takes a string with space-separated options:

- `"set"` \[`"always"`\] - Open window as a group.
- `"new"` - Shorthand for `"barred set"`.
- `"lock"` \[`"always"`\] - Lock the group. Combine with `"set"` or `"new"`.
- `"barred"` - Do not automatically group into the focused unlocked group.
- `"deny"` - Do not allow the window to be toggled as or added to a group.
- `"invade"` - Force open window in the locked group.
- `"override"` \[other options\] - Override other `group` rules.
- `"unset"` - Clear all `group` rules.

> [!NOTE]
> `group` with no options is a shorthand for `group = "set"`.
>
> By default, `set` and `lock` only affect new windows once. The `always`
> qualifier makes them always effective.

### Tags

Window tags can be static or dynamic. Dynamic tags have a suffix of `*`.
Check window tags with `hyprctl clients`.

Use the `tagwindow` dispatcher to add a static tag to a window:

```bash
hyprctl dispatch 'hl.dsp.window.tag({ tag = "+code" })'     # Add tag to current window.
hyprctl dispatch 'hl.dsp.window.tag({ tag = "-code" })'     # Remove tag from current window.
hyprctl dispatch 'hl.dsp.window.tag({ tag = "code" })'      # Toggle the tag of current window.

# Or target windows:
hyprctl dispatch 'hl.dsp.window.tag({ tag = "+music", window = "class:Celluloid" })'
```

Use the `tag` effect to add a dynamic tag to a window:

```lua
hl.window_rule({ match = { class = "footclient" }, tag = "+term" })   -- Add dynamic tag `term*`
hl.window_rule({ match = { class = "footclient" }, tag = "term" })    -- Toggle dynamic tag `term*`
hl.window_rule({ match = { tag = "cpp" },          tag = "+code" })   -- Add `code*` to windows tagged `cpp`
hl.window_rule({ match = { tag = "code" },         opacity = "0.8" }) -- Set opacity for tag `code` or `code*`
hl.window_rule({ match = { tag = "cpp" },          opacity = "0.7" }) -- `cpp`-tagged windows match both; last wins
hl.window_rule({ match = { tag = "term*" },        opacity = "0.6" }) -- Match `term*` only, not bare `term`
hl.window_rule({ match = { tag = "term" },         tag = "-code" })   -- Remove dynamic tag `code*` from `term`/`term*`
```

Or with a keybind for convenience:

```lua
hl.bind("SUPER + CTRL + 2", hl.dsp.window.tag({ tag = "alpha_0.2" }))
hl.bind("SUPER + CTRL + 4", hl.dsp.window.tag({ tag = "alpha_0.4" }))
hl.window_rule({ match = { tag = "alpha_0.2" }, opacity = "0.2 override" })
hl.window_rule({ match = { tag = "alpha_0.4" }, opacity = "0.4 override" })
```

The `tag` effect can only manipulate dynamic tags, and the `tagwindow`
dispatcher only works with static tags (dynamic tags are cleared when the
dispatcher is called).

### Example Rules

```lua
-- Move kitty to 100 100 and add an anim style (named rule)
hl.window_rule({
  name      = "move-kitty",
  match     = { class = "kitty" },
  move      = {100, 100},
  animation = "popin",
})

-- Disable blur for firefox
hl.window_rule({ match = { class = "firefox" }, no_blur = true })

-- Move kitty to the center of the cursor
hl.window_rule({
  match = { class = "kitty" },
  move  = {"cursor_x-(window_w*0.5)", "cursor_y-(window_h*0.5)"},
})

-- Set border color to red if window is fullscreen
hl.window_rule({
  match        = { fullscreen = true },
  border_color = "rgb(FF0000) rgb(880808)",
})

-- Set border color to yellow when title contains Hyprland
hl.window_rule({
  match        = { title = ".*Hyprland.*" },
  border_color = "rgb(FFFF00)",
})

-- Set opacity to 1.0 active, 0.5 inactive and 0.8 fullscreen for kitty
hl.window_rule({
  match   = { class = "kitty" },
  opacity = "1.0 override 0.5 override 0.8 override",
})

-- Set rounding to 10 for kitty
hl.window_rule({ match = { class = "kitty" }, rounding = 10 })

-- Fix pinentry losing focus
hl.window_rule({
  match       = { class = "(pinentry-)(.*)" },
  stay_focused = true,
})
```

### Notes

Effects marked as _Dynamic_ are reevaluated whenever the matching property
of the window changes. For instance, if a rule changes the `border_color`
when a window is floating, the color reverts to default when it's tiled again.

Effects are processed top to bottom - the _last_ match takes precedence:

```lua
hl.window_rule({ match = { class = "kitty" },        opacity = "0.8 0.8" })
hl.window_rule({ match = { float = true },           opacity = "0.5 0.5" })
```

Here, all non-fullscreen kitty windows have `opacity 0.8`, except when
floating - those get `0.5`. All other floating windows get `0.5`.

```lua
hl.window_rule({ match = { float = true },           opacity = "0.5 0.5" })
hl.window_rule({ match = { class = "kitty" },        opacity = "0.8 0.8" })
```

Here, all kitty windows get `opacity 0.8`, even if floating. Other floating
windows get `0.5`.

> [!IMPORTANT]
> Named rules take precedence over anonymous ones. Rules are evaluated top
> to bottom, but all named rules are evaluated first, then all anonymous ones.

> [!NOTE]
> Opacity is a PRODUCT of all opacities by default. For example, setting
> `active_opacity` to `0.5` and `opacity` to `0.5` results in a total of
> `0.25`. Opacities over `1.0` are allowed, but any product over `1.0` will
> cause graphical glitches.
>
> Use `" override"` after an opacity value to set it as an exact value rather
> than a multiplier:
>
> ```lua
> -- Active 0.8, inactive 0.8, fullscreen 1.0 regardless of other rules:
> hl.window_rule({
>   match   = { class = "kitty" },
>   opacity = "0.8 override 0.8 override 1.0 override",
> })
> ```

### Dynamically enabling / disabling / changing rules

Only named rules can be dynamically changed, enabled, or disabled.
`hl.window_rule()` returns a handle object:

```lua
local myRule = hl.window_rule({
  name  = "my-rule",
  match = { class = "kitty" },
  border_size = 5,
})

myRule:set_enabled(false)  -- disable
myRule:set_enabled(true)   -- re-enable
myRule:is_enabled()        -- query status
```

## Layer Rules

Some things in Wayland are not windows, but layers - app launchers, status
bars, wallpapers, etc. These have separate rules using `hl.layer_rule()`.
The syntax is the same as `hl.window_rule()`.

### Props

| Field | Argument | Description |
| -------------- | --------------- | --- |
| namespace | \[RegEx\] | Namespace of the layer. Check `hyprctl layers`. |

### Effects

| Effect | Argument | Description |
| ---- | ----------- | --- |
| no_anim | boolean | Disables animations. |
| blur | boolean | Enables blur for the layer. |
| blur_popups | boolean | Enables blur for popups. |
| ignore_alpha | number | Makes blur ignore pixels with opacity of `a` or lower. Float from `0` to `1`. |
| dim_around | boolean | Dims everything behind the layer. |
| xray | boolean | Sets the blur xray mode for the layer. |
| animation | string | Sets a specific animation style for this layer. |
| order | integer | Sets the order relative to other layers. Higher `n` = closer to edge of monitor. Can be negative. |
| above_lock | integer | If non-zero, renders the layer above the lockscreen. `2` = interactive on lockscreen. |
| no_screen_share | boolean | Hides the layer from screen sharing. |

### Examples

```lua
-- Enable blur for waybar
hl.layer_rule({ match = { namespace = "waybar" }, blur = true })

-- Named layer rule
local selectionRule = hl.layer_rule({
  name      = "no-anim-for-selection",
  match     = { namespace = "selection" },
  no_anim   = true,
})

-- Enable blur and ignore_alpha for rofi
hl.layer_rule({
  match        = { namespace = "rofi" },
  blur         = true,
  ignore_alpha = 0.5,
})
```

Layer rules also return a handle with `set_enabled()` / `is_enabled()`:

```lua
local myLayerRule = hl.layer_rule({
  name  = "my-layer-rule",
  match = { namespace = "waybar" },
  blur  = true,
})
myLayerRule:set_enabled(false)
```
