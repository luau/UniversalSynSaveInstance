---
description: Convert index expression into field expressions
added_in: "0.7.0"
parameters: []
examples:
  - content: "return var['field']"
  - content: "return { ['field'] = true }"
---

When an index expression is using a static string (or an expression that can be statically evaluated into a string), this rule replaces it with a field expression. This rule also applies for table declarations: an entry that uses the bracket syntax (e.g. `{ ["key"] = value }`) will get converted into a field-like entry when possible.
