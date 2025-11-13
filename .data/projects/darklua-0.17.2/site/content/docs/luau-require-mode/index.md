---
title: Luau Require Mode
description: How darklua understands Luau specific require calls
group: Configuration
order: 5
---

This require mode is meant to be used for resolving content using Luau _module paths_. It is the require mode used by the [Lune runtime](https://lune-org.github.io/docs/).

**_Warning!_** The _path_ require mode should not be confused with the _luau_ require mode. Both require modes are used with strings looking like file paths, but they resolve to actual files differently.

The Luau require mode follows the Luau RFCs for require resolution (see [Amended Require Resolution](https://rfcs.luau.org/amended-require-resolution.html) and [Abstract Module Paths](https://rfcs.luau.org/abstract-module-paths-and-init-dot-luau.html) documents). Once enabled, darklua will find all require calls made with strings (single or double quotes) and resolve them.

## Bundling Support

It can be configured in the **bundle** part of the configuration file. For a quick overview of the bundling configuration, see [the documentation page](../bundle/).

## Configuration Overview

The Luau require mode can be defined as the string 'luau' to use all the default values, or with its object format:

```json5
{
  name: "luau",

  // optional
  aliases: {
    "@pkg": "./Packages",
  },

  // optional (defaults to true)
  use_luau_configuration: true,
}
```

## Aliases

When a path do not start with `.`, `..` or `/`, their first component is used to find its associated source location. These locations can be configured with the `aliases` parameter of the path require mode configuration.

To provide flexibility, aliases are not restricted to start with `@`, unlike the aliases from the Luau configuration file (`.luaurc`).

Relative paths in `aliases` are resolved based on the configuration file location.

### Example

Given this configuration file for bundling:

```json5
{
  bundle: {
    require_mode: {
      name: "luau",
      aliases: {
        "@pkg": "./Packages",
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

Luau configuration files are named `.luaurc` and they can contain an `aliases` parameter which acts like the `aliases` parameter in darklua.

The value of `use_luau_configuration` will change how darklua finds new aliases. Before looking at the `aliases` value, darklua will attempt to find the nearest `.luaurc` configuration file to each file it processes. If it finds one, it will load the aliases.

This behavior is enabled by default. It can be disabled by setting `use_luau_configuration` to `false`.
