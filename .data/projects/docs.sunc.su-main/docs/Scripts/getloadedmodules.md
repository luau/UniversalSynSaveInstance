# `getloadedmodules`

!!! warning "Returns only loaded modules"

    This function **only** returns [`ModuleScript`](https://create.roblox.com/docs/reference/engine/classes/ModuleScript) instances that have already been loaded using [`#!luau require`](https://create.roblox.com/docs/reference/engine/globals/LuaGlobals#require).  
    It does **not** return all [`ModuleScript`](https://create.roblox.com/docs/reference/engine/classes/ModuleScript) objects in the game - for that, use [`#!luau getscripts`](./getscripts.md).

`#!luau getloadedmodules` returns a list of all [`#!luau ModuleScript`](https://create.roblox.com/docs/reference/engine/classes/ModuleScript) instances that have been **loaded** (e.g. [`#!luau require`'d](https://create.roblox.com/docs/reference/engine/globals/LuaGlobals#require)).

This includes only modules with completed executions, and **excludes** any modules that errored or haven't been required yet.

```luau
function getloadedmodules(): { ModuleScript }
```

## Parameters

| Parameter | Description                      |
|-----------|----------------------------------|
| *(none)*  | This function takes no parameters. |

---

## Example

```luau title="Checking if a module has been loaded" linenums="1"
local loaded = Instance.new("ModuleScript")
local not_loaded = Instance.new("ModuleScript")

pcall(require, loaded)

for _, module in pairs(getloadedmodules()) do
    if module == loaded then
        -- The first modulescript was found because it was required in line 4
        print("Found loaded module!")
    elseif module == notLoaded then
        -- The second modulescript should NOT be found because it was never required
        print("This should never appear.")
    end
end
```
