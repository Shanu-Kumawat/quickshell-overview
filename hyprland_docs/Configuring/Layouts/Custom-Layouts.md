---
weight: 40
title: Custom Layouts
---

> [!NOTE]
> Looking for the old hyprlang syntax? Check the [0.54 wiki pages](https://wiki.hypr.land/0.54.0/).
> Since Hyprland 0.55, hyprlang is deprecated in favor of lua.

You can create custom layouts in the lua config directly. For this,
define your layout with `hl.layout.register(name, { recalculate, layout_msg? })` then use it as `lua:name`.

A simple example layout:

```lua
hl.layout.register("columns", {
    recalculate = function(ctx)
        local n = #ctx.targets
        if n == 0 then
            return
        end

        for i, target in ipairs(ctx.targets) do
            target:place(ctx:column(i, n))
        end
    end,
})
```

Which can be used as `lua:columns`.

There are some example layouts in the hyprland repo [here](https://github.com/hyprwm/Hyprland/tree/main/example/layouts).

`ctx` has some convenience functions for you, like `grid_cell`, `column`, `row` and `split`.
It also provides `area` and `targets`, for the work area and target list respectively.

You can get the window from a target by accessing its `.window` field, but please
do note that it doesn't always have to be there, and that some layout targets might
have multiple, and only expose the "main" one. (e.g. group)

> [!NOTE]
> Please prefer :place over :set_box unless necessary. :place will calculate the gaps,
> pseudotiling, reserved space, and more, for you. set_box is only to be used if
> full manual positioning is absolutely necessary.


