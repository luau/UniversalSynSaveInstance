---
description: Convert local function definitions to variable declarations
added_in: "0.3.3"
parameters: []
examples:
  - content: |
      local function foo(a, b)
          return a + b
      end
---

Local functions that are not recursive will be transformed to a local assignment statement.

Note that, depending on your Lua runtime implementation, you may no longer be able to use reflection-like APIs (eg `debug.info`) to acquire the name of the function, or the function name may be missing from stack traces of `error` invocations.
