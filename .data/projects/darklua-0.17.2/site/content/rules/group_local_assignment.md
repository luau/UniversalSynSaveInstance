---
description: Groups local assignments into a single statement
added_in: "0.3.2"
parameters: []
examples:
  - content: |
      local foo = 1
      local bar = 2
---

This rule will merge consecutive local assignments.

The rule will not merge assignments if one assignment temporally depends on the previous one, since it would break the code or change the behavior. The following code would not be changed:

```lua
local foo = 1
local bar = foo
```

Since functions can return multiple values, assignments that extract more than one value will not get merged.

```lua
local foo, bar = multiple_return_values()
local baz = 0
```
