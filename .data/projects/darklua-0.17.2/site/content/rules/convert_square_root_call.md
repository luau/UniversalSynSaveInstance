---
description: "Convert calls to `math.sqrt(value)` into an exponent form (`value ^ 0.5`)"
added_in: "0.17.0"
parameters: []
examples:
  - content: "local result = math.sqrt(16)"
  - content: "local result = math.sqrt(x + y)"
  - content: "local result = math.sqrt(calculate_value())"
---

This rule converts calls to `math.sqrt(value)` into the equivalent expression `value ^ 0.5`. This transformation can be useful in some Lua runtime as a performance optimization.
