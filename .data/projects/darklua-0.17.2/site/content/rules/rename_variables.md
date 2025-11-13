---
description: Renames variables and function parameters
added_in: "0.2.1"
parameters:
  - name: globals
    type: array
    default: "['$default']"
    description: What identifier should be avoided when generating new names
  - name: include_functions
    added_in: "0.7.0"
    type: boolean
    default: "false"
    description: Controls if function names get renamed
---

To configure this rule to avoid using Roblox globals, add `$roblox` to the

```json5
{
  rule: "rename_variables",
  globals: ["$default", "$roblox"],
}
```

A configuration to avoid all identifiers from the default group and the identifier `a` and `b`.

```json5
{
  rule: "rename_variables",
  globals: ["$default", "a", "b"],
}
```

## Globals

The `globals` property have special values that can be use to group multiple values together. They start with an `$` character.

### $default

The default standard globals in Lua

```
arg, assert, collectgarbage, coroutine, debug, dofile, error, gcinfo, getfenv, getmetatable, io, ipairs, load, loadfile, loadstring, math, module, newproxy, next, os, package, pairs, pcall, print, rawequal, rawget, rawset, require, select, setfenv, setmetatable, string, table, tonumber, tostring, type, unpack, xpcall, _G, _VERSION
```

### $roblox

The globals from Roblox Lua

```
Axes, bit32, BrickColor, CellId, ColorSequence, ColorSequenceKeypoint, Color3, CFrame, DateTime, DebuggerManager, delay, DockWidgetPluginGuiInfo, elapsedTime, Enum, Faces, Instance, LoadLibrary, game, NumberRange, NumberSequence, NumberSequenceKeypoint, PathWaypoint, PhysicalProperties, plugin, PluginDrag, PluginManager, printidentity, Random, Ray, RaycastParams, Rect, Region3, Region3int16, script, settings, shared, stats, spawn, tick, time, TweenInfo, typeof, UDim, UDim2, UserSettings, utf8, Vector2, Vector2int16, Vector3, Vector3int16, version, wait, warn, workspace, ypcall
```

Note that Lua language key words such as `return` and `do` are automatically excluded and not configurable.
