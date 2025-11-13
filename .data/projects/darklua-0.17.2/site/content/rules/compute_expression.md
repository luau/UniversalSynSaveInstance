---
description: Computes expressions statically
added_in: "0.3.6"
parameters: []
examples:
  - content: "return 1 + 1"
  - content: "return 10 * 10"
  - content: "return true and 'true' or 'not true'"
  - content: "return 'Hello' .. ' friend!'"
---

This rule computes expressions (that are determined to be static) and replaces them with their result. An expression will not be replaced if it has any side-effects. This can make code smaller, but also make code slightly faster since the computation is now done ahead of time. This rule is influenced by the evaluation system of darklua. As its capacity increases, the rule will be able to compute more complex expressions.
