# `cloneref`

!!! info "Creates a safe reference to protected instances"

    `#!luau cloneref` returns a reference to an [`#!luau Instance`](https://create.roblox.com/docs/reference/engine/classes/Instance). This can help avoid weak table styled detections. 

`#!luau cloneref` returns a **reference clone** of an [`#!luau Instance`](https://create.roblox.com/docs/reference/engine/classes/Instance). The returned object behaves identically to the original but is not strictly equal (`==`) to it.

This is commonly used to safely interact with services such as [`#!luau game.CoreGui`](https://create.roblox.com/docs/reference/engine/classes/Players#LocalPlayer), making weak-table style attacks fail.

```luau
function cloneref<T>(object: T & Instance): T
```

## Parameters

| Parameter     | Description                                       |
|---------------|---------------------------------------------------|
| `#!luau object` | The [`#!luau Instance`](https://create.roblox.com/docs/reference/engine/classes/Instance) to clone a safe reference from. |

---

## Example

```luau title="Cloning a safe reference to LocalPlayer" linenums="1"
local players = game:GetService("Players")

local original = players.LocalPlayer
local clone = cloneref(original)

print(original == clone) -- Output: false
print(clone.Name)        -- Output: Player's name (same as original)
```
