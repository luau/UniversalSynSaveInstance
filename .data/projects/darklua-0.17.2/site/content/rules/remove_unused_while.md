---
description: Removes unused while statement
added_in: "0.2.3"
parameters: []
examples:
  - content: |
      while 'foo' == 'bar' do
          -- ...
      end
---

When a condition from a while statement can be evaluated to false and has no side effects, this rule will remove the statement. For example, the following while statement would be removed.

This rule is influenced by the evaluation system of darklua. The more darklua can evaluate code, the better this rule can be applied.
