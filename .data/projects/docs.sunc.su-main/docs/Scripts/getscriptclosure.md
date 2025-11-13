# `getscriptclosure`

!!! info "Closure is compiled from the script's bytecode, not an active one"

    The function returned by `#!luau getscriptclosure` is a **new closure** compiled from the script's bytecode. It is not the function used by the game script, but has identical metadata. This function is usually used to retrieve constants from a script.

!!! info "Not all scripts have bytecode"

    If the script has no compiled bytecode, this function will return `#!luau nil`.

`#!luau getscriptclosure` creates and returns a Luau **function closure** from the compiled bytecode of a [`#!luau Script`](https://create.roblox.com/docs/reference/engine/classes/Script), [`#!luau LocalScript`](https://create.roblox.com/docs/reference/engine/classes/LocalScript), or [`#!luau ModuleScript`](https://create.roblox.com/docs/reference/engine/classes/ModuleScript).

This function is often used to **extract constants or behaviour** from scripts without needing to run them inside the game.

```luau
function getscriptclosure(script: BaseScript | ModuleScript): (...any) -> (...any) | nil
```

## Parameters

| Parameter      | Description                                        |
|----------------|----------------------------------------------------|
| `#!luau script` | The script instance to convert into a function.    |

---

## Example

```luau title="Retrieving a script's closure" linenums="1"
local animate = game.Players.LocalPlayer.Character:FindFirstChild("Animate")

local closure = getscriptclosure(animate)

print(typeof(closure)) -- Output: function 0x....

print(getscriptclosure(Instance.new("LocalScript"))) -- Output: nil
```
