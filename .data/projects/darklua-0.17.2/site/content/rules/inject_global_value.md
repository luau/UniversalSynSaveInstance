---
description: Inject a global variable
added_in: "0.3.5"
parameters:
  - name: identifier
    required: true
    type: string
    description: The name of the global variable
  - name: value
    type: any
    description: The value to inject
    default: nil
  - name: env
    added_in: "0.7.0"
    type: string
    description: An environment variable to read the value from
  - name: env_json
    added_in: "0.17.0"
    type: string
    description: An environment variable to read the json-encoded value from
  - name: default_value
    added_in: "0.17.0"
    type: any
    description: The default value when using an environment variable that is not defined
examples:
  - rules: "[{ rule: 'inject_global_value', identifier: 'CONSTANT', value: 'Hello' }, { rule: 'inject_global_value', identifier: 'AMOUNT', value: 11 }]"
    content: |
      if _G.AMOUNT > 10 or _G.CONSTANT ~= nil then
        --[[ ... ]]
      end
  - rules: "[{ rule: 'inject_global_value', identifier: 'DEBUG', value: true }]"
    content: |
      if _G.DEBUG then
        print('Debug information')
      end
---

This rule will find a global variable and replace it with a given value. The value can be defined in the rule configuration or taken from an environment variable.

To inject a static value, use the `value` property.

```json5
{
  rule: "inject_global_value",
  identifier: "GLOBAL",
  value: true,
}
```

If `value` is not specified, the `env` property can be defined to read an environment variable that will be read into a string.

```json5
{
  rule: "inject_global_value",
  identifier: "GLOBAL",
  env: "SOME_VARIABLE",
}
```

Alternatively, the `env_json` property allows you to read a JSON-encoded value (`json5` is supported) from an environment variable. This is useful for injecting any data like booleans or structured data like arrays or objects.

```json5
{
  rule: "inject_global_value",
  identifier: "SETTINGS",
  env_json: "APP_SETTINGS",
}
```

When using the `env` or `env_json` property, the `default_value` property can be used to provide a fallback value when the environment variable is not defined. This prevents the rule from using `nil` as the default value.

```json5
{
  rule: "inject_global_value",
  identifier: "FEATURE_FLAG",
  env: "ENABLE_FEATURE",
  default_value: false,
}
```

This rule can be used in combination with the `remove_unused_if_branch`, `compute_expression`, and other rules, to eliminate dead branches. In addition to making your code smaller, it should make it faster (depending on how hot the code path is) since it is eliminating branch condition evaluations at client-side runtime.
