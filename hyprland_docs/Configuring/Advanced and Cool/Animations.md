---
weight: 9
title: Animations
---

> [!NOTE]
> Looking for the old hyprlang syntax? Check the [0.54 wiki pages](https://wiki.hypr.land/0.54.0/).
> Since Hyprland 0.55, hyprlang is deprecated in favor of lua.

## General

Animations are declared with the `hl.animation()` method.

Example:
```lua
hl.animation({ leaf = STRING, enabled = BOOLEAN, speed = FLOAT, curve = STRING[, style = STRING] })
```
`leaf` is scope of the animation. See [Animation tree](#animation-tree)

`enabled` use `true` to enable, `false` to disable. _Note:_ if it's `false`, you
can omit further args.

`speed` is the amount of ds (1ds = 100ms) the animation will take. For example `speed = 1` = 100ms

`bezier` / `spring` is the curve name, see [curves](#curves).

`style` (optional) is the animation style. See [Animation tree](#animation-tree)

### Examples

```lua
hl.animation({ leaf = "workspaces", enabled = true, speed = 8, bezier = "my_epic_bezier" })
hl.animation({ leaf = "window", enabled = true, speed = 10, spring = "my_epic_spring", style = "slide"})
hl.animation({ leaf = "fade", enabled = 0 })
```

### Animation tree
The animations are a tree. If an animation is unset, it will inherit its
parent's values.

```txt
global
  ↳ windows - styles: slide, popin, gnomed
    ↳ windowsIn - window open - styles: same as windows
    ↳ windowsOut - window close - styles: same as windows
    ↳ windowsMove - everything in between, moving, dragging, resizing.
  ↳ layers - styles: slide, popin, fade
    ↳ layersIn - layer open
    ↳ layersOut - layer close
  ↳ fade
    ↳ fadeIn - fade in for window open
    ↳ fadeOut - fade out for window close
    ↳ fadeSwitch - fade on changing activewindow and its opacity
    ↳ fadeShadow - fade on changing activewindow for shadows
    ↳ fadeDim - the easing of the dimming of inactive windows
    ↳ fadeLayers - for controlling fade on layers
      ↳ fadeLayersIn - fade in for layer open
      ↳ fadeLayersOut - fade out for layer close
    ↳ fadePopups - for controlling fade on wayland popups
      ↳ fadePopupsIn - fade in for wayland popup open
      ↳ fadePopupsOut - fade out for wayland popup close
    ↳ fadeDpms - for controlling fade when dpms is toggled
  ↳ border - for animating the border's color switch speed
  ↳ borderangle - for animating the border's gradient angle - styles: once (default), loop
  ↳ workspaces - styles: slide, slidevert, fade, slidefade, slidefadevert
    ↳ workspacesIn - styles: same as workspaces
    ↳ workspacesOut - styles: same as workspaces
    ↳ specialWorkspace - styles: same as workspaces
      ↳ specialWorkspaceIn - styles: same as workspaces
      ↳ specialWorkspaceOut - styles: same as workspaces
  ↳ zoomFactor - animates the screen zoom
  ↳ monitorAdded - monitor added zoom animation
```

> [!WARNING]
> Using the `loop` style for `borderangle` requires Hyprland to _constantly_ render new frames at a frequency equal to your screen's refresh rate (e.g. 60 times per second for a 60hz monitor), which might stress your CPU/GPU and will impact battery life. <br>
> This will apply even if animations are disabled or borders are not visible.

## Curves

### Bezier

A cubic [Bézier curve](https://en.wikipedia.org/wiki/B%C3%A9zier_curve) is a simple spline defined by 4 points,
two of which (the middle ones) are configurable.

```lua
hl.curve( NAME, { type = "bezier", points = { {X0, Y0}, {X1, Y1} } })
```

A good website to design your own Bézier can be [cssportal.com](https://www.cssportal.com/css-cubic-bezier-generator/). <br>
If you want to instead choose from a list of pre-made Béziers, you can check out [easings.net](https://easings.net).

### Spring

A spring curve is one commonly found on Apple's systems, and is defined by mass, stiffness
and dampening. It's generally recommended to keep mass at 1, and adjust stiffness and dampening alone.

```lua
hl.curve( NAME, { type = "spring", mass = MASS, stiffness = STIFF, dampening = DAMP })
```

The more "stiffness", the more speed, and the more "dampening", the less bounce.

### Examples

```lua
hl.curve( "overshoot", { type = "bezier", points = { {0.5, 0.9}, {0.1, 1.1} } } )
hl.curve( "rubber", { type = "spring", mass = 1, stiffness = 70, dampening = 10 } )
```

### Extras

For animation style `popin` in `windows`, you can specify a minimum percentage
to start from. For example, the following will make the animation 80% -> 100% of
the size:

```lua
hl.animation({ leaf = "windows", enabled = true, speed = 8, curve = "default", style = "popin 80%" })
```

For animation styles `slide`, `slidevert`, `slidefade` and `slidefadevert` in `workspaces`, you can
specify a movement percentage. For example, the following will make windows move
20% of the screen width:

```lua
hl.animation({ leaf = "workspaces", enabled = true, speed = 8, curve = "default", style = "slidefade 20%" })
```

For animation style `slide` in `windows` and `layers` you can specify a forced side. <br>
You can choose between `top`, `bottom`, `left` or `right`.

```lua
hl.animation({ leaf = "windows", enabled = true, speed = 8, curve = "default", style = "slide left" })
```
