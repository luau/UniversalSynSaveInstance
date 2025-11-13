---
description: Removes call to the assert function
added_in: "0.12.0"
parameters:
  - name: preserve_arguments_side_effects
    type: boolean
    description: Defines how darklua handle arguments passed to the function. If true, darklua will inspect each argument and preserve any potential side effects. When false, darklua will not perform any verification and simply erase any arguments passed.
    default: "true"
examples:
  - content: assert(condition, 'condition is incorrect!')
---

This rule removes all function calls to `assert`.
