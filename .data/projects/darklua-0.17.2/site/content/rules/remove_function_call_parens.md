---
description: Removes functions call parentheses
added_in: "0.3.4"
parameters: []
examples:
  - content: "print('hello')"
  - content: "create({ ... })"
---

This rule will remove parentheses in a function call when there is only one string or one table as arguments. In large Lua programs, this can save several thousand bytes.
