---
description: Removes types
added_in: "0.11.0"
parameters: []
examples:
  - content: "local var: number? = nil"
  - content: |
      type Array<T> = { T }
      local test: Array<string> = {}
  - content: "return value :: string"
  - content: |
      local function getAverage(array: { string }): number
          local sum: number = 0
          for _, element: number in array do
              sum += tonumber(element) :: number
          end
          return sum / #array
      end
---

This rule removes all Luau type declarations and annotations.
