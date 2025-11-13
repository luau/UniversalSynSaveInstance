# `getcallingscript`

!!! info "Notes on `#!luau getcallingscript`"

    If a game script is executing, and `#!luau getcallingscript` is called, it must return the proper [`Script`](https://create.roblox.com/docs/reference/engine/classes/Script), [`LocalScript`](https://create.roblox.com/docs/reference/engine/classes/LocalScript), or [`ModuleScript`](https://create.roblox.com/docs/reference/engine/classes/ModuleScript) - even if the [`#!luau script`](https://create.roblox.com/docs/reference/engine/globals/RobloxGlobals#script) global for said script is set to `#!luau nil`.

`#!luau getcallingscript` returns the [`#!luau Script`](https://create.roblox.com/docs/reference/engine/classes/Script), [`#!luau LocalScript`](https://create.roblox.com/docs/reference/engine/classes/LocalScript), or [`#!luau ModuleScript`](https://create.roblox.com/docs/reference/engine/classes/ModuleScript) that **triggered the current code execution**.

```luau
function getcallingscript(): BaseScript | ModuleScript | nil
```

## Parameters

| Parameter | Description                      |
|-----------|----------------------------------|
| *(none)*  | This function takes no parameters. |

---

## Example

```luau title="Detecting the calling script in a hook" linenums="1"
local old; old = hookmetamethod(game, "__index", function(self, key)
    if not checkcaller() then
        local caller = getcallingscript()
        warn("__index access from script:", caller and caller:GetFullName() or "Unknown")

        hookmetamethod(game, "__index", old) -- Restore the original
        return old(self, key)
    end

    return old(self, key)
end)

print(getcallingscript()) -- Output: nil, since we called from an executor thread

```
