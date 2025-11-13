---
title: Rules
description: Define which rules are used for processing
group: Configuration
order: 2
---

Rules are what transform Lua code. When processing code with darklua, it is essentially going through a given list of rules one by one, each one transforming code and feeding it to the next rule.

**Important note:** one thing to understand is that the ordering of these rules sometimes have importance! For example, you should inject a value before trying to compute expressions statically, or optimize if branches out.

## Rule Format

Rules can be written in two different formats: the shortest format consists of simply providing the rule name. When using this format, any parameters the rule have will use its default value.

For example, the `remove_empty_do` rule does not have any parameters, so it can be specified in the configuration file as:

```json5
{
  rules: ["remove_empty_do"],
}
```

If a rule can be configured, the object format can be used to override each parameter. The rule name **must** be specified with a field named `rule`. Then, simply enumerate the property name associated with its value.

For example, the `rename_variables` rule can optionally rename the function names. To do that, the rule must be written using the object format and by defining the `include_functions` field.

```json5
{
  rule: "rename_variables",
  include_functions: true,
}
```

Information on the built-in rules and their configuration properties can be found [here](/docs/rules-reference).
