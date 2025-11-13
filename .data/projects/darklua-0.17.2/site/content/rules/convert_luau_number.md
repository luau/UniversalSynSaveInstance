---
description: Convert Luau numbers into Lua compatible numbers
added_in: "0.17.0"
parameters: []
examples:
  - content: "print(0b1000_0001)"
  - content: "return 0xA000_FFFF"
---

This rule transforms Luau-specific number literals into Lua compatible number literals. It converts binary literals (prefixed with `0b` or `0B`) to their hexadecimal equivalents. It also removes underscores used as digit separators in numbers.
