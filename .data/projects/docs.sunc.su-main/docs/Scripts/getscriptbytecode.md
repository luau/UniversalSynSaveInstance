# `getscriptbytecode`

!!! info "Notes on `#!luau getscriptbytecode`"

    This function should return `#!luau nil` if the script has no bytecode. This makes it easier to check for absence consistently across executors.

`#!luau getscriptbytecode` retrieves the bytecode of a [`#!luau LocalScript`](https://create.roblox.com/docs/reference/engine/classes/LocalScript), [`#!luau ModuleScript`](https://create.roblox.com/docs/reference/engine/classes/ModuleScript), and [`#!luau Script`](https://create.roblox.com/docs/reference/engine/classes/Script).

```luau
function getscriptbytecode(script: BaseScript | ModuleScript): string | nil
```

## Parameters

| Parameter      | Description                                              |
|----------------|----------------------------------------------------------|
| `#!luau script` | The script instance to retrieve the bytecode from.       |

---

## Example

```luau title="Reading the bytecode of a running script" linenums="1"
local animate = game.Players.LocalPlayer.Character:FindFirstChild("Animate")

print(getscriptbytecode(animate)) -- Returns bytecode as a string

print(getscriptbytecode(Instance.new("LocalScript"))) -- Output: nil
```
