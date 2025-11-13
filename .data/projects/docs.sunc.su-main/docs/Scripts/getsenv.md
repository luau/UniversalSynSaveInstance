# `getsenv`

!!! warning "Only works on active scripts"

    This function will throw an error if the script isn't currently running. If the script is running but on a different Lua State (such as on an [Actor](https://create.roblox.com/docs/reference/engine/classes/Actor)), the function will return nil instead.

`#!luau getsenv` returns the **global environment table** of a given [`#!luau Script`](https://create.roblox.com/docs/reference/engine/classes/Script), [`#!luau LocalScript`](https://create.roblox.com/docs/reference/engine/classes/LocalScript), or [`#!luau ModuleScript`](https://create.roblox.com/docs/reference/engine/classes/ModuleScript).

This environment contains **all global variables and functions** available to the target script, such as custom-defined functions or state values.

```luau
function getsenv(script: BaseScript | ModuleScript): { [any]: any } | nil
```

## Parameters

| Parameter      | Description                                                                 |
|----------------|-----------------------------------------------------------------------------|
| `#!luau script` | The script instance whose environment should be retrieved.                 |

---

## Example

```luau title="Accessing a script's internal environment" linenums="1"
local animate = game.Players.LocalPlayer.Character:FindFirstChild("Animate")

local env = getsenv(animate)

print(typeof(env.onSwimming)) -- Output: function
```
