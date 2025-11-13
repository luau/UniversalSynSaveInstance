---
description: Removes call to debug.profilebegin and debug.profileend
added_in: "0.12.0"
parameters:
  - name: preserve_arguments_side_effects
    type: boolean
    description: Defines how darklua handle arguments passed to the functions. If true, darklua will inspect each argument and preserve any potential side effects. When false, darklua will not perform any verification and simply erase any arguments passed.
    default: "true"
examples:
  - content: |
      debug.profilebegin('function name')
      performUpdate()
      debug.profileend()
---

This rule removes all function calls to [`debug.profilebegin`](https://create.roblox.com/docs/reference/engine/libraries/debug#profilebegin) and [`debug.profileend`](https://create.roblox.com/docs/reference/engine/libraries/debug#profileend).
