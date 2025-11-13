---
description: Converts function defined using `:` to use a `.`
added_in: "0.2.2"
parameters: []
examples:
  - content: |
      local Car = {}

      function Car:move(distance)
          self.position = self.position + distance
      end
---

Functions defined using the method syntax (with a `:`) will be replaced with their field like syntax.

This rule can be useful when obfuscating code, since it, along with the `rename_variables` rule, makes it less clear that a given function is an instance (or method) function. This obfuscation can result in smaller code when when used with `rename_variables` rule, since darklua can then rename repeated references to `self` with a single-letter variable name, saving thousands of bytes across a large Lua program.
