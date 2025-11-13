---
title: Roblox Require Mode
description: How darklua understands Roblox require calls
group: Configuration
order: 6
---

This require mode is specific to Roblox, as it will interpret require calls to Roblox instances. Right now, it is only available to use as the target require mode when using the [`convert_require` rule](../rules/convert_require).

The Roblox require mode can be defined as the string 'roblox' to use all the default values, or with its object format:

```json5
{
  name: "roblox",

  // optional
  rojo_sourcemap: "./path-to/sourcemap.json",

  // optional (defaults to "find_first_child")
  indexing_style: "find_first_child", // "wait_for_child" or "property"
}
```

## With a Rojo Sourcemap

A Rojo sourcemap file can be provided to darklua to directly get a file location in the DataModel.

```json5
{
  rules: [
    {
      rule: "convert_require",
      current: "path",
      target: {
        name: "roblox",
        rojo_sourcemap: "./path-to/sourcemap.json",
      },
    },
  ],
}
```

## Without a Rojo sourcemap

When a sourcemap is not provided, darklua will assume that all paths are relative to the file you are requiring from and that the files are laid out in the same structure in the Roblox DataModel.

For example, if a module is requiring another module as:

- `"./MyClass"`: then it will convert to `script.Parent:FindFirstChild("MyClass")`
- `"../MyClass"`: then it will convert to `script.Parent.Parent:FindFirstChild("MyClass")`

If the module converts to a ModuleScript instance (because it is called `init.lua` in Rojo),

- `"./MyClass"`: will convert to `script:FindFirstChild("MyClass")`
- `"../MyClass"`: will convert to `script.Parent:FindFirstChild("MyClass")`

## Indexing Style

This parameter controls how instance paths should be generated.

There are 3 different indexing style available:

- `find_first_child`: uses the [`FindFirstChild`](https://create.roblox.com/docs/reference/engine/classes/Instance#FindFirstChild) method for getting instances (default value)
- `wait_for_child`: uses the [`WaitForChild`](https://create.roblox.com/docs/reference/engine/classes/Instance#WaitForChild) method for getting instances
- `property`: uses property-like way of getting child instances, using a period "." (note that this kind of indexing may collide with Instance properties!)

Here is an example of how to configure the `convert_require` rule to use the `wait_for_child` indexing style:

```json5
{
  rules: [
    {
      rule: "convert_require",
      current: "path",
      target: {
        name: "roblox",
        // indexing_style can be "find_first_child", "wait_for_child" or "property"
        indexing_style: "wait_for_child",
      },
    },
  ],
}
```
