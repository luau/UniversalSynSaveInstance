---
title: Overview
description: How the configuration file works
group: Configuration
order: 1
---

When transforming Lua using the `darklua process` command, darklua can read a configuration file to customize how the code is transformed.

## Rules

Rules are what transform Lua code. When processing code with darklua, it is essentially going through a given list of rules one by one, each one transforming code and feeding it to the next rule.

**Important note:** one thing to understand is that the ordering of these rules sometimes have importance! For example, you should inject a value before trying to compute expressions statically or optimize if branches out.

More information is available in the section specific to [rule configuration](/docs/rules).

## Location

From the directory where you run `darklua process`, darklua will attempt to read the following files automatically:

- `.darklua.json`
- `.darklua.json5`

To provide a different configuration file, this subcommand also accept a specific path to a configuration file with `--config <path>`.

## Quick Reference

Any missing field will be replaced with its default value.

```json5
{
  // Output code in different ways depending on the given generator
  generator: "retain_lines", // default value

  bundle: {
    // Identifier used by darklua to store the bundled modules
    modules_identifier: "__DARKLUA_BUNDLE_MODULES",

    // To avoid bundling certain paths, insert patterns into the list to exclude
    // them (see https://github.com/olson-sean-k/wax/blob/master/README.md#patterns
    // for details about the syntax)
    excludes: [],

    // Configure how requires are interpreted
    require_mode: {
      // Currently, the only supported require mode is `path`
      name: "path",

      // When requiring folders, require the file named like this value inside of it
      module_folder_name: "init",

      // Provide paths that can be required with a specific prefix
      sources: {
        // Map strings to paths relative to the configuration files itself
        // for example, to support requires of Wally packages as `pkg/PackageName`,
        // map `pkg` to a path to the `Packages` folder created by Wally:
        pkg: "./Packages",
      },

      // Enable or disable finding `.luaurc` files to load source aliases
      use_luau_configuration: true, // default value
    },
  },

  // Define the rules that will transform the Lua code.
  // If you do not provide this field, the default list of rules is
  // going to be executed.
  rules: [
    "remove_comments",
    "remove_spaces",
    // For rules with parameters, use the object notation to specify
    // the values to override
    {
      rule: "inject_global_value",
      identifier: "DEBUG",
      value: false,
    },
    "remove_nil_declaration",
    "compute_expression",
    "remove_unused_if_branch",
    "filter_after_early_return",
    "remove_empty_do",
  ],
}
```
