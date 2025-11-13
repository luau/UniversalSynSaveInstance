---
description: Removes usages of the method syntax (`:`) in function calls
added_in: "0.17.0"
parameters: []
examples:
  - content: "obj:method()"
  - content: "game:GetService('RunService')"
  - content: "return player:LoadCharacter()"
---

This rule converts function calls that use the colon syntax (`:`) to function calls using dot notation (`.`).

This rule only transforms method calls where the prefix is an identifier. Other method calls using field access, index access or function call prefixes are left unchanged.
