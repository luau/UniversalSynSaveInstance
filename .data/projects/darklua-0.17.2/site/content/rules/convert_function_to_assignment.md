---
description: Convert global function definitions to assignment statements
added_in: "0.17.2"
parameters: []
examples:
  - content: |
      function foo(a, b)
          return a + b
      end
  - content: |
      function obj:method(value)
          return self.field + value
      end
---

Global function declarations will be transformed into assignment statements. This rule handles simple global functions, functions with field access (`module.function`), and method definitions (`object:method`).

When converting method syntax (`:method`), the rule automatically adds `self` as the first parameter to maintain the same behavior.

Note that, depending on your Lua runtime implementation, you may no longer be able to use reflection-like APIs (eg `debug.info`) to acquire the name of the function, or the function name may be missing from stack traces of `error` invocations.
