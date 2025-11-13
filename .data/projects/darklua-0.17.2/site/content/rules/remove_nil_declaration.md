---
description: Removes explicit declaration to `nil`
added_in: "0.8.0"
parameters: []
examples:
  - content: "local var = nil"
  - content: "local a, b, c = 1, nil, nil"
  - content: "local a, b = nil, call()"
  - content: "local var = call(), otherValue, true"
---

This rule removes trailing `nil` values in local assignments. Additionally, it will trim unnecessary expressions in assignments when they do not cause any side-effects.
