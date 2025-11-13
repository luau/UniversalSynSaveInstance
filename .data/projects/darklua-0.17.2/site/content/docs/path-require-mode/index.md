---
title: Path Require Mode
description: How darklua understands filesystem require calls
group: Configuration
order: 4
---

This require mode is meant to be used for resolving content using regular file paths.

**_Warning!_** The _path_ require mode should not be confused with the _luau_ require mode. Both require modes are used with strings looking like file paths, but they resolve to actual files differently.

Once enabled, darklua will find all require calls made with strings (single or double quotes) and resolve them.

## Bundling Support

It can be configured in the **bundle** part of the configuration file. For a quick overview of the bundling configuration, see [the documentation page](../bundle/).

## Configuration Overview

The path require mode can be defined as the string 'path' to use all the default values, or with its object format:

```json5
{
  name: "path",

  // optional (defaults to 'init')
  module_folder_name: "init",

  // optional
  sources: {
    pkg: "./Packages",
  },

  // optional (defaults to true)
  use_luau_configuration: true,
}
```

## Path Resolution

The first step consist of figuring out the head of the path or where to start looking for the resource:

- **if the path starts with `.` or `..`:** the path is considered relative to the file where the require call is made

- **if the path starts with `/`:** the path is considered like a regular absolute path

- **else:** the first component of the path is used to find a matching [source](#sources)

The next step is to resolve the tail of the path. Darklua will find the first available file based on the given path:

1. the given path

1. the given path with a `luau` extension

1. the given path with a `lua` extension

1. the given path joined with the module folder name

1. (if the module folder name does not have an extension) the given path joined with the module folder name and a `luau` extension

1. (if the module folder name does not have an extension) the given path joined with the module folder name and a `lua` extension

Here is a concrete example of these steps with a require to `./example`. darklua will try the following paths and find the first file:

1. `./example`

1. `./example.luau`

1. `./example.lua`

1. `./example/init`

1. `./example/init.luau`

1. `./example/init.lua`

## Module Folder Name

When requiring a folder, this mode will look into the folder for a file named by the given value of the `module_folder_name` parameter. The default value is `init`.

For example, to configure darklua to use `index.lua` (or `index.luau`) similar to what is used in JavaScript, set the parameter to `index`.

To bundle with `index` files, provide this configuration:

```json5
{
  bundle: {
    require_mode: {
      name: "path",
      // folders with a `index.lua` or `index.luau` file
      // can be required
      module_folder_name: "index",
    },
  },
}
```

Or when using the `convert_require` rule, provide this configuration:

```json5
{
  rules: [
    {
      rule: "convert_require",
      current: {
        name: "path",
        // folders with a `index.lua` or `index.luau` file
        // can be required
        module_folder_name: "index",
      },
      target: "roblox",
    },
  ],
}
```

## Sources

When a path do not start with `.`, `..` or `/`, their first component is used to find its associated source location. These locations can be configured with the `sources` parameter of the path require mode configuration.

Relative paths are resolved based on the configuration file location.

### Example

Given this configuration file for bundling:

```json5
{
  bundle: {
    require_mode: {
      name: "path",
      sources: {
        @pkg: "./Packages",
        // you can also map directly to a file (Lua or
        // any supported data file)
        images: "./assets/image-links.json",
      },
    },
  },
}
```

It is possible to make these require call in any file:

```lua
local Promise = require("@pkg/Promise")
local images = require("images")
```

## Luau Configuration Files

Luau configuration files are named `.luaurc` and they can contain an `aliases` parameter which acts like the [sources](#sources) parameter in darklua.

The value of `use_luau_configuration` will change how darklua finds new sources. Before looking at the [sources](#sources) value, darklua will attempt to find the nearest `.luaurc` configuration file to each file it processes. If it finds one, it will load the aliases.

This behavior is enabled by default. It can be disabled by setting `use_luau_configuration` to `false`.
