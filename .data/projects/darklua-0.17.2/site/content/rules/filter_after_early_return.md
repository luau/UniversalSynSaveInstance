---
description: Removes unreachable statements following return statements
added_in: "0.8.0"
parameters: []
---

When this rule encounters a `return` statement at the end of a `do` statement block, it will clear out the next statements of the outer block.

This rule is effective when applied after rules that may produce do statements with return statements, like <RuleLink rule="remove_unused_if_branch" />.

For example, given the following code:

```lua
do
    local function process()
        -- ...
    end

    return process
end

local function otherImplementation()
    -- ...
end

return otherImplementation
```

The rule will clear the `otherImplementation` since `process` will always be returned first. It will produce the following code:

```lua
do
    local function process()
        -- ...
    end

    return process
end
```
