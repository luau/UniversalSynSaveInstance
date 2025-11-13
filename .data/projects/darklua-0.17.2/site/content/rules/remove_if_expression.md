---
description: Remove if expressions
added_in: "0.14.1"
parameters: []
examples:
  - content: |
      local variable = if condition() then { option = true } else { option = false }
---

This rule removes all `if` expressions (not if statements!) and replaces them with an equivalent expression.

**Note:** this rule is useful if you are converting Luau code into regular Lua code.
