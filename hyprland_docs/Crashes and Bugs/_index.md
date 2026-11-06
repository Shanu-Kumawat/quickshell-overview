---
weight: 10
title: Crashes and Bugs
---

## Getting the log

Firstly, make sure you have enabled logs in the Hyprland config. Set `debug.disable_logs` to `false`.
then to make OpenGL produce error messages set `debug.gl_debugging` to `true`.

dont forget to disable these when done logging as they cause a performance hit.

If you are in a TTY, and the Hyprland session that crashed was the last one you
launched, the log can be printed with

```sh
cat $XDG_RUNTIME_DIR/hypr/$(ls -t $XDG_RUNTIME_DIR/hypr/ | head -n 1)/hyprland.log
```

if you are in a Hyprland session, and you want the log of the last session, use

```sh
cat $XDG_RUNTIME_DIR/hypr/$(ls -t $XDG_RUNTIME_DIR/hypr/ | head -n 2 | tail -n 1)/hyprland.log
```

## Obtaining the Hyprland Crash Report

If you have `$XDG_CACHE_HOME` set, the crash report directory is
`$XDG_CACHE_HOME/hyprland`. If not, it's `$HOME/.cache/hyprland`.

Go to the crash report directory and you should find a file named
`hyprlandCrashReport[XXXX].txt` where `[XXXX]` is the PID of the process that
crashed.

Attach that file to your issue.

## Crashes at launch

Diagnose the issue by what is in the log:

- `backend failed to start` -> launch in the TTY and refer to the logs in RED.
- `Monitor X has NO PREFERRED MODE, and an INVALID one was requested` -> your
  monitor is bork.
- Other -> see the coredump. Use `coredumpctl`, find the latest one's PID and do
  `coredumpctl info PID`.
- failing on a driver (e.g. `radeon`) -> report an issue.
- failing on `Hyprland` -> report an issue.

## Crashes not at launch

Report an issue on GitHub or on the Discord server.

## Obtaining a debug stacktrace

> Systemd-only.

1. Build Hyprland in debug (`make debug`).
2. Start Hyprland and get it to crash.
3. In a tty or terminal, do `coredumpctl debug Hyprland`.
   - If gdb asks you for symbols, say `y`.
   - If it asks about paging, say `c`.
4. Once you get to `(gdb)`, start file logging with `set logging enabled`.
   - For a specific file, use `set logging file output.log`.
5. Run `bt -full`, then `exit` once finished, and attach the output.

## Obtaining a trace log

Launch Hyprland with `HYPRLAND_TRACE=1 AQ_TRACE=1` environment variables set.

These variables will enable _very_ verbose logging and it's not recommended to enable them unless debugging, as they
might cause slowdowns and _massive_ log files.

Try to reproduce your issue as fast as possible so we don't have to sift through 1 million lines of logs.

## Bugs

First of all, **_READ THE [FAQ PAGE](../FAQ)_**

If your bug is not listed there, you can ask on the Discord server or open a
[discussion on GitHub](https://github.com/hyprwm/Hyprland/discussions).

## Bisecting an issue

"Bisecting" is finding the first _git_ commit that introduced a specific bug or
regression using binary search. This is done in `git` using the `git bisect` command.

First, clone the Hyprland repo if you haven't already:

```sh
git clone --recursive https://github.com/hyprwm/Hyprland
cd Hyprland
```

Start the bisect process:

```sh
git bisect start
```

Enter the first known good commit hash that did not contain the issue:

```sh
git bisect good [good commit]
```

Then, enter the known bad commit hash that does contain the issue. You can simply use HEAD:

```sh
git bisect bad HEAD
```

_git_ will now checkout a commit in the middle of the specified range.
Now, reset and build Hyprland:

```sh
git reset --hard --recurse-submodules
make all
```

...and run the built executable from the TTY `./build/Hyprland`.

Try to reproduce your issue. If you can't (i.e. the bug is not present), go back to the
Hyprland repo and run `git bisect good`. If you can reproduce it, run `git bisect bad`.
_git_ will then checkout another commit and continue the binary search.
If there's a build error, run `git bisect skip`.

Reset, build and install Hyprland again and repeat this step until _git_ identifies the
commit that introduced the bug:

```
[commit hash] is the first bad commit
```

## Building the Wayland stack with ASan

If requested, this is the deepest level of memory issue debugging possible.

_Do this in the tty, with no Hyprland instances running._

Clone hyprland: `git clone --recursive https://github.com/hyprwm/Hyprland`

`make asan`

Reproduce your crash. Hyprland will exit back to the tty.

Now, in either `cwd`, `~` or `./build`, search for file(s) named
`asan.log.XXXXX` where XXXXX is a number.

Zip all of them up and attach to your issue.

## Debugging DRM issues

DRM (Direct Rendering Manager) is the underlying kernel architecture to take a gpu buffer (something
we can render to) and put it on your screen (via the gpu) instead of a window.

Freezes, glitches, and others, can be caused by issues with Hyprland's communication with DRM, the driver
or kernel. In those cases, a DRM log is helpful.

> [!WARNING]
> Please note, these logs are EXTREMELY verbose. Please reproduce your bug(s) ASAP to avoid getting a 1GB log.

```sh
echo 0x19F | sudo tee /sys/module/drm/parameters/debug  # enables verbose drm logging
sudo dmesg -C                                           # clears kernel debug logs
dmesg -w > ~/dmesg.log &                                # writes kernel logs in the background to a file at ~/dmesg.log
Hyprland

# ... repro the issue, then quit hyprland


fg # after this, use CTRL+C to stop writing the logs
echo 0 | sudo tee /sys/module/drm/parameters/debug # disables drm logging, don't forget this to avoid slowdowns
```

After this, _attach_ the `dmesg.log` file.
