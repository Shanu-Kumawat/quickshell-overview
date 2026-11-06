---
weight: 1
title: Getting started
---

This page documents the basics of making your own Hyprland plugin from scratch.

## How do plugins work?

Plugins are basically dynamic objects loaded by Hyprland. They have (almost)
full access to every part of Hyprland's internal process, and as such, can
modify and change way more than a script.

## Prerequisites

In order to write a Hyprland plugin, you will need:

- Knowledge of C++
- The ability to read
- A rough understanding of the Hyprland internals (you _can_ learn this
  alongside your development work)

## Making your first plugin

Open your favorite code editor.

Make a new directory, in this example we will use `MyPlugin`.

_**→ If you have the Hyprland headers**_

If you install with `make install`, you should have the headers. In that case,
no further action is required.

_**→ If you don't have the Hyprland source cloned**_

Clone the Hyprland source code to a subdirectory, in our example
`MyPlugin/Hyprland`. Run
`cd Hyprland && make debug && sudo make installheaders && cd ..`.

Now that you have the Hyprland sources set up, you can either start from scratch
if you know how, or take a look at some simple plugins in the
[official plugins repo](https://github.com/hyprwm/hyprland-plugins) like for
example `csgo-vulkan-fix` or `hyprwinwrap`.

### The basic parts of the plugin

Starting from the top, you will have to include the plugin API:

```cpp
#include <hyprland/src/plugins/PluginAPI.hpp>
```

Feel free to take a look at the header. It contains a bunch of useful comments.

We also create a global pointer for our handle:

```cpp
inline HANDLE PHANDLE = nullptr;
```

We will initialize it in our plugin init function later. It serves as an
internal "ID" of our plugin.

Then, there is the API version method:

```cpp
// Do NOT change this function.
APICALL EXPORT std::string PLUGIN_API_VERSION() {
    return HYPRLAND_API_VERSION;
}
```

This method will tell Hyprland what API version was used to compile this plugin.
Do NOT change it. It will be set to the correct value when compiling.

Skipping over some example handlers, we have two important functions:

```cpp
APICALL EXPORT PLUGIN_DESCRIPTION_INFO PLUGIN_INIT(HANDLE handle) {
    PHANDLE = handle;

    const std::string COMPOSITOR_HASH = __hyprland_api_get_hash();
    const std::string CLIENT_HASH = __hyprland_api_get_client_hash();

    // ALWAYS add this to your plugins. It will prevent random crashes coming from
    // mismatched header versions.
    if (COMPOSITOR_HASH != CLIENT_HASH) {
        HyprlandAPI::addNotification(PHANDLE, "[MyPlugin] Mismatched headers! Can't proceed.",
                                     CHyprColor{1.0, 0.2, 0.2, 1.0}, 5000);
        throw std::runtime_error("[MyPlugin] Version mismatch");
    }

    // ...

    return {"MyPlugin", "An amazing plugin that is going to change the world!", "Me", "1.0"};
}

APICALL EXPORT void PLUGIN_EXIT() {
    // ...
}
```

The first method will be called when your plugin gets initialized (loaded).

You can, and probably should, initialize everything you may want to use in
there.

It's worth noting that adding config variables is _only_ allowed in this
function.

The plugin init function is _required_.

The return value should be the `PLUGIN_DESCRIPTION_INFO` struct which lets
Hyprland know about your plugin's name, description, author and version.

Make sure to store your `HANDLE` as it's going to be required for API calls.

The second method is not required, and will be called when your plugin is being
unloaded by the user.

If your plugin is being unloaded because it committed a fault, this function
will _not_ be called.

You do not have to unload layouts, remove config options, remove dispatchers,
window decorations or unregister hooks in the exit method. Hyprland will do that
for you.

### Setting up a development environment

In order to make your life easier, it's a good idea to work on a nested debug
Hyprland session. Unless you need to test some things that require real hardware
(e.g. trackpad gestures), you definitely should use a nest.

See
[the Contributing Section](../../../Contributing-and-Debugging/#development-environment)
for instructions on setting up a development environment.

### Loading / reloading plugins

Build your plugin, and you can load it in your nest with
```sh
hyprctl plugin load /absolute/path/to/plugin.so
```
and unload with
```sh
hyprctl plugin unload /absolute/path/to/plugin.so
```

The normal development cycle would usually mean loading the plugin, checking your changes,
building the plugin with new changes, unload + load, and repeat.

You can have a one-liner like so:
```sh
hyprctl plugin unload /absolute/path/to/plugin.so ; hyprctl plugin load /absolute/path/to/plugin.so
```
as a "reload" of the plugin.

### More advanced stuff

Take a look at the `src/plugins/PluginAPI.hpp` header. It has comments to every
method to let you know what it is.

For more explanation on a few concepts, see [Advanced](../Advanced) and
[Plugin Guidelines](../Plugin-Guidelines)
