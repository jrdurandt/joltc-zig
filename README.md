# joltc zig

[![License](https://img.shields.io/github/license/jrdurandt/joltc-zig.svg)](https://github.com/jrdurandt/joltc-zig/blob/master/LICENSE)
[![Build status](https://img.shields.io/github/actions/workflow/status/jrdurandt/joltc-zig/ci.yaml)](https://github.com/jrdurandt/joltc-zig/blob/master/.github/workflows/ci.yaml)

Zig build for [joltc](https://github.com/amerkoleci/joltc)

## Linux:
`zig build -Dtarget=x86_64-linux -Doptimize=ReleaseFast`

Output: `zig-out/lib/linux/libjoltc.so`

## Windows:
`zig build -Dtarget=x86_64-windows -Doptimize=ReleaseFast`

Output: `zig-out/lib/windows/joltc.dll`

## MacOs:
`zig build -Dtarget=x86_64-macos -Doptimize=ReleaseFast`

Output: `zig-out/lib/macos_x86_64/libjoltc.dylib`

`zig build -Dtarget=aarch64-macos -Doptimize=ReleaseFast`

Output: `zig-out/lib/macos_arm/libjoltc.dylib`

---

# joltc

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://github.com/amerkoleci/joltc/blob/main/LICENSE)
[![Build status](https://github.com/amerkoleci/joltc/workflows/Build/badge.svg)](https://github.com/amerkoleci/joltc/actions)

[JoltPhysics](https://github.com/jrouwe/JoltPhysics) C interface.

## Sponsors
Please consider [SPONSOR](https://github.com/sponsors/amerkoleci) me (amerkoleci) to further help development and to allow faster issue triaging and new features to be implemented.
**_NOTE:_** **any feature request** would require a [sponsor](https://github.com/sponsors/amerkoleci) in order to allow faster implementation and allow this project to continue.
