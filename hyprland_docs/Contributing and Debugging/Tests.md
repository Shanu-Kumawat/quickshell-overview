---
title: Tests
---

Hyprland and some other projects under the hypr* umbrella have _tests_ that
try to catch bugs and regressions before code is merged.

Building in Debug will by default build tests.

## Running tests

### GTests

GTests are GoogleTests that are _unit tests_. These tests simply check how
some elements behave when they can run on their own.

In all hypr* projects, GTests are ran by ctest. Run:

```sh
ctest -j$(nproc) -C Debug --test-dir=build
```

And make sure your tests pass.

### Hyprland's hyprtester

A lot of hyprland's code cannot be unit tested, thus we have our own Hyprtester
binary which runs hyprland and issues commands and expects results.

To run Hyprtester, execute the following in a debug build:

```sh
./build/hyprtester/hyprtester -c hyprtester/test.lua -b ./build/Hyprland -p hyprtester/plugin/hyprtestplugin.so
```

*This will run for a while!* At the end, it will print summary results
of how many tests passed, and how many failed.

The goal of failed tests is to be **0**.

## Submitting new tests

New tests have to either be a GTest, if the thing tested is possible to be unit tested,
or a part of hyprtester.

For both test types, you can check the test directories in the project. GTests live in `tests/`,
while hyprtester tests live in `hyprtester/`.

### What to test

If you're submitting a new feature, it's obviously your feature. For a fix, try to write a test
case that would fail before your fix.

For new tests, you can inspect the coverage report.

First, run _both_ ctest and hyprtester. Then, run (from the repo root):

```sh
gcovr -r . build --html --html-details -o build/coverage.html --gcov-ignore-parse-errors="negative_hits.warn" && xdg-open ./build/coverage.html
```

this will run for a while, then open a report in your browser. You can see which files have been tested in
what amount, and click on the files to see a line-by-line breakdown.

If there are paths untested, we'd be very happy to receive tests for them.
