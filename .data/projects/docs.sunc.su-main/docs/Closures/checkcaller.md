# `checkcaller`

`#!luau checkcaller` returns a boolean indicating whether the **current function was invoked from the executor's own thread**. This is useful for differentiating between your own calls and those made by the game.

It is often used in [`#!luau hookfunction`](../Closures/hookfunction.md) and/or [`#!luau hookmetamethod`](../Closures/hookmetamethod.md).

```luau
function checkcaller(): boolean
```

## Parameters

| Parameter | Description        |
|-----------|--------------------|
| *(none)*  | This function takes no parameters. |

---

## Example

```luau title="Identifying the source of a __namecall" linenums="1"
local from_caller

local original; original = hookmetamethod(game, "__namecall", function(...)
    if not from_caller then
        from_caller = checkcaller()
    end

    return original(...)
end)

task.wait(0.1) -- Step a bit
hookmetamethod(game, "__namecall", original)

print(from_caller)       -- Output: false
print(checkcaller())    -- Output: true (current thread)
```
