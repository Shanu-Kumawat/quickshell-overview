---
weight: 50
title: Development
---

Hyprtoolkit is a pure C++ toolkit. It relies on modern C++ in the Hyprland style (with
hyprutils, etc).

It's recommended you are familiar with C++ before developing an app.

## Getting Started

_If you prefer living off of examples, see the `tests/` directory in the hyprtoolkit repo._

Start by creating a backend and opening a window:
```cpp
// in this example we are doing this to skip Hyprtoolkit::
using namespace Hyprtoolkit;

auto backend = CBackend::create();
auto window = CWindowBuilder::begin()->appTitle("Hello")->appClass("hyprtoolkit")->commence();
```

this will create (but not yet open) a window handle for you.

Hyprtoolkit is a retained mode toolkit, so you can define your layout with C++ and forget about it.

First thing we need is a background rectangle, by doing this:
```cpp
window->m_rootElement->addChild(CRectangleBuilder::begin()->color([] { return backend->getPalette()->m_colors.background; })->commence());
```

> [!NOTE]
> Remember to always use the palette when possible for your app to adhere to the user's theme.

All elements are under `hyprtoolkit/elements/`, you can browse through them. Let's add a simple layout with
some buttons:

```cpp
auto layout = CColumnLayoutBuilder::begin()->size({CDynamicSize::HT_SIZE_PERCENT, CDynamicSize::HT_SIZE_PERCENT, {1.F, 1.F}})->commence();
layout->setMargin(3);

window->m_rootElement->addChild(layout);

layout->addChild(CButtonBuilder::begin()
                       ->label("Do something")
                       ->onMainClick([](SP<CButtonElement> el) { std::println("Did something!"); })
                       ->size({CDynamicSize::HT_SIZE_AUTO, CDynamicSize::HT_SIZE_AUTO, {1, 1}})
                       ->commence()
                );
layout->addChild(CButtonBuilder::begin()
                       ->label("Do something else")
                       ->onMainClick([](SP<CButtonElement> el) { std::println("Did something else!"); })
                       ->size({CDynamicSize::HT_SIZE_AUTO, CDynamicSize::HT_SIZE_AUTO, {1, 1}})
                       ->commence()
                );
```

This adds a column layout (elements are stacked on top of each other) with two buttons. These buttons have automatic sizing, so will fit their contents.

Once you are done, add a close callback, open the window and enter the main loop:
```cpp
window->m_events.closeRequest.listenStatic([w = WP<IWindow>{window}] {
    w->close();
    backend->destroy();
});

window->open();

backend->enterLoop();
```

## Layout System

The layout system relies on absolute and layout positioning modes. Let's zoom into both:

### Absolute Mode

This happens when the parent of your element is anything but a `ColumnLayout` or a `RowLayout`. Children are positioned within their parent, according to their
position mode. You can set it with `setPositionMode` and add offsets with `setAbsolutePosition`.

For example:
- `setPositionMode` with `CENTER` will center the child inside the parent.
- `setPositionMode` with `ABSOLUTE` will make it be in the top left corner.
- Adding `setAbsolutePosition` to the above with `{200, 200}` will move it 200 layout px down and right from the top left corner of the parent.

### Layout Mode

This happens when the parent of your element is a layout. These will attempt to position your child elements. They work similarly to CSS's `flex` and qt's `RowLayout` and `ColumnLayout`,
but will not wrap. If elements overflow and cannot shrink, they will disappear.

RowLayout positions elements next to each other side-by-side, while ColumnLayout does it top-bottom.

### Size

All elements carry a `SizeType`. This tells the layout system how to size the element.
- `ABSOLUTE` takes layout px as size and makes the element rigid.
- `PERCENT` takes a percentage in the form of `(0, 0) - (1, 1)` and will be the size of the parent multiplied by the percentage.
- `AUTO` ignores the passed vector (leave it empty) and instead will always attempt to contain the children\*

> [!NOTE]
> Some elements will force their own sizing, e.g. `Text`.  
Leave them `AUTO` to avoid confusion.

## Elements

Most elements are self-explanatory. You can explore their builder functions to see what styling / behavior options they support.

Each element is created with a `Builder` which is there to maintain ABI stability. After you call `->commence()`, you
will get a `SP` to the newly created object.

You can rebuild the object at any time by calling `->rebuild()` and you'll get a builder again.
**Remember to call `commence()` after you are done to apply the changes!**

You do not need to keep the `SP` after adding the element to the tree with `addChild`.

## Other

Other, miscellaneous stuff

### System Icons

Use the `CBackend::systemIcons()` function to obtain a reference to `ISystemIconFactory` which allows
you to query system icons by name.  
You can check the obtained result object to see if the icon was found.  
Then, you can take that object and slap it into an `ImageElement` to add it to your layout.

### Additional FDs

If you have an app that depends on some other loop, e.g. pipewire, dbus, etc. you need to remember
that hyprtoolkit is strictly single-threaded for layout and rendering.  
You cannot edit the layout from another thread.

For this, use `CBackend::addFd()` to add a FD to the loop alongside a function that will be called once the fd
is readable.  
This function will be called from the main thread, so you can do whatever you want in there.


