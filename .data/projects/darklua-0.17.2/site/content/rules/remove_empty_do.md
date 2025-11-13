---
description: Removes empty do statements
added_in: "0.2.0"
parameters: []
examples:
  - content: |
      do
      end
      do
          do
          end
      end
      return {}
---

This simple rule removes all empty do blocks found.
