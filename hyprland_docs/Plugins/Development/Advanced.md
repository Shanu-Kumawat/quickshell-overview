---
weight: 4
title: Advanced
---

This page documents a few advanced things about the Hyprland Plugin API.

## Accessing private members

If you need access to a private member of a Hyprland class, you can surround includes with a macro which will change the visibility to public. Note that some Hyprland files include the STL which may end up breaking if you attempt this. If you encounter this issue, make sure to include the offending STL import before the section where you include the Hyprland file.

```cpp
#define private public
#include <hyprland/src/plugins/PluginAPI.hpp>
#include <hyprland/src/render/OpenGL.hpp>
#include <hyprland/src/desktop/Window.hpp>
#include <hyprland/src/layout/IHyprLayout.hpp>
#undef private
```

## Using Function Hooks

> [!WARNING]
> Function hooks are only available on `AMD64` (`x86_64`). Attempting to hook on
> any other arch will make Hyprland simply ignore your hooking attempt.

Function hooks are intimidating at first, but when used properly can be
_extremely_ powerful.

Function hooks allow you to intercept any call to the function you hook.

Let's look at a simple example:

```cpp
void Events::listener_monitorFrame(void* owner, void* data)
```

This will be the function we want to hook. `Events::` is a namespace, not a class, so
this is just a plain function.

```cpp
// make a global instance of a hook class for this hook
inline CFunctionHook* g_pMonitorFrameHook = nullptr;
// create a pointer typedef for the function we are hooking.
typedef void (*origMonitorFrame)(void*, void*);

// our hook
void hkMonitorFrame(void* owner, void* data) {
    (*(origMonitorFrame)g_pMonitorFrameHook->m_pOriginal)(owner, data);
}

APICALL EXPORT PLUGIN_DESCRIPTION_INFO PLUGIN_INIT(HANDLE handle) {
    // stuff...

    // create the hook
    static const auto METHODS = HyprlandAPI::findFunctionsByName(PHANDLE, "listener_monitorFrame");
    g_pMonitorFrameHook = HyprlandAPI::createFunctionHook(handle, METHODS[0].address, (void*)&hkMonitorFrame);

    // init the hook
    g_pMonitorFrameHook->hook();

    // further stuff...
}
```

We have just made a hook. Now, whenever Hyprland calls
`Events::listener_monitorFrame`, our hook will be called instead!

This way, you can run code before / after the function, modify the inputs or
results, or even block the function from executing.

`CFunctionHook` can also be unhooked whenever you please. Just run `unhook()`.
It can be rehooked later by calling `hook()` again.

### Member functions

For members, e.g. `CCompositor::focusWindow(CWindow*, wlr_surface*)` you will
also need to add the thisptr argument to your hook:

```cpp
typedef void (*origFocusWindow)(void*, CWindow*, wlr_surface*);

void hkFocusWindow(void* thisptr, CWindow* pWindow, wlr_surface* pSurface) {
    // stuff...

    // and if you want to call the original...
    (*(origFocusWindow)g_pFocusWindowHook->m_pOriginal)(thisptr, pWindow, pSurface);
}

APICALL EXPORT PLUGIN_DESCRIPTION_INFO PLUGIN_INIT(HANDLE handle) {
    // stuff...

    static const auto METHODS = HyprlandAPI::findFunctionsByName(PHANDLE, "focusWindow");
    g_pFocusWindowHook = HyprlandAPI::createFunctionHook(handle, METHODS[0].address, (void*)&hkFocusWindow);
    g_pFocusWindowHook->hook();

    // further stuff...
}
```

> [!WARNING]
> Please note method lookups are slow and should not be used often. The entries
> _will not_ change during runtime, so it's a good idea to make the lookups
> `static`.

### Why use findFunctionsByName?

Why use that instead of e.g. `&CCompositor::focusWindow`? Two reasons:

1. Less breakage. Whenever someone updates Hyprland, that address might become
invalid. findFunctionsByName is more resilient. As long as the function exists,
it will be found.

2. Error handling. The method array contains, besides the address, the
signatures. You can verify those to make 100% sure you got the right function,
or throw an error if it was not found.

## Using the config

You can register config values in the `PLUGIN_INIT` function:

```cpp
APICALL EXPORT PLUGIN_DESCRIPTION_INFO PLUGIN_INIT(HANDLE handle) {
    // stuff...
    
    HyprlandAPI::addConfigValue(PHANDLE, "plugin:example:exampleInt", SConfigValue{.intValue = 1});

    // further stuff...
}
```

Plugin variables _**must**_ be in the `plugins:` category. Further categories
are up to you. It's generally a good idea to group all variables from your
plugin in a subcategory with the plugin name, e.g. `plugins:myPlugin:variable1`.

For retrieving the values, call `HyprlandAPI::getConfigValue`.

Please remember that the pointer to your config value will never change after
`PLUGIN_INIT`, so to greatly optimize performance, make it static:

```cpp
static auto* const MYVAR = &HyprlandAPI::getConfigValue(PHANDLE, "plugin:myPlugin:variable1")->intValue;
```

## Further

Read the API at `src/plugins/PluginAPI.hpp`, check out the
[official plugins](https://github.com/hyprwm/hyprland-plugins).

And, most importantly, have fun!
