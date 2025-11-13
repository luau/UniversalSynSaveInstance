---
description: Convert require calls from one environment to another
added_in: "0.10.0"
parameters:
  - name: current
    required: true
    type: require mode
    description: The require mode used in the input code
  - name: target
    required: true
    type: require mode
    description: The require mode used to generate the new require calls
examples: []
---

This rule is particularly useful if you are writing Lua code that needs to be portable to Roblox, as you can automatically convert requires using file paths (like "./src/mod.lua") to different path system (like the luau module paths used by [Lune](https://lune-org.github.io/docs/)) Roblox instances.

Right now, the current and target require modes have certain restrictions:

<table-container aria-label="require mode support matrix">
  <table-head>
    <table-row>
      <table-cell>Mode</table-cell>
      <table-cell align="center">path</table-cell>
      <table-cell align="center">luau</table-cell>
      <table-cell align="center">roblox</table-cell>
    </table-row>
  </table-head>
  <table-body>
    <table-row>
      <table-cell>current</table-cell>
      <table-cell align="center">✅</table-cell>
      <table-cell align="center">✅</table-cell>
      <table-cell align="center">❌</table-cell>
    </table-row>
    <table-row>
      <table-cell>target</table-cell>
      <table-cell align="center">✅</table-cell>
      <table-cell align="center">✅</table-cell>
      <table-cell align="center">✅</table-cell>
    </table-row>
  </table-body>
</table-container>

## Configuration Overview

Here is an overview of the rule configuration format:

```json5
{
  rule: "convert_require",
  current: {
    name: "path",

    // optional (defaults to 'init')
    module_folder_name: "init",

    // optional
    sources: {
      "@pkg": "./Packages",
    },
  },
  target: {
    name: "roblox",

    // optional
    rojo_sourcemap: "./path-to/sourcemap.json",

    // optional (defaults to 'find_first_child')
    indexing_style: "find_first_child", // 'wait_for_child' or 'property'
  },
}
```

For more information about how to configure each of require mode, visit:

- [path require mode documentation](/docs/path-require-mode/)

- [luau require mode documentation](/docs/path-require-mode/)

- [roblox require mode documentation](/docs/roblox-require-mode/)
