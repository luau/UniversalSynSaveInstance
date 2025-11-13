---
description: Removes unused variable declarations
added_in: "0.13.0"
parameters: []
examples:
  - content: "local var"
  - content: |
      local var1 = true
      local var2 = var1
  - content: "local var = call()"
  - content: "local function fn() print('unused') end"
  - content: |
      local a, b, c = 1, 2, 3
      return a
---

This rule removes unused variables from code. It also removes unused local function definitions.
