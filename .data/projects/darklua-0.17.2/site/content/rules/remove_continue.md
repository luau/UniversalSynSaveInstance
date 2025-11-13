---
description: Remove continue statements
added_in: "0.14.1"
parameters: []
examples:
  - content: |
      for i = 1, 10 do
          if i == 1 then
              continue
          end
          print(i)
      end
---

This rule removes all `continue` statements and replaces them with code that only use `break` statements.

**Note:** this rule is useful if you are converting Luau code into regular Lua code.
