---
description: Removes spaces
added_in: "0.7.0"
parameters: []
examples:
  - content: |
      local function getAverage(array)
          local sum = 0
          for _, element in ipairs(array) do
              sum = sum + element
          end
          return sum / #array
      end
---

It is important to note that when generating code with the `dense` or `readable` generator (e.g. `darklua process src --format dense`), all the spacing (whitespaces, tabs, new lines) will not be considered. The only way to retain the spacing information is to use the `retain_lines` format and avoid this rule.
