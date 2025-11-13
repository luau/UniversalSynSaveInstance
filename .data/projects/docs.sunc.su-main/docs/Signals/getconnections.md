# `getconnections`

!!! warning "A `Connection`, in the context of `RBXScriptSignal`, refers to **a subscription between the signal (event) and the function to execute when it fires** - not the social 'connections' of a user."

!!! warning "Your game may crash if C connections are not properly supported."

`#!luau getconnections` retrieves a list of [`Connection`](./Connection.md) objects currently attached to a given [`RBXScriptSignal`](https://create.roblox.com/docs/reference/engine/datatypes/RBXScriptSignal).

```luau
function getconnections(signal: RBXScriptSignal): {Connection}
```

## Parameters

| Parameter         | Description                                   |
|-------------------|-----------------------------------------------|
| `#!luau signal`     | The signal to inspect for active connections. |

---

## Examples

### Example 1

```luau title="Inspecting and invoking a Luau connection" linenums="1"
local folder = Instance.new("Folder")
folder.ChildAdded:Connect(function()
    return "Triggered"
end)

local connection = getconnections(folder.ChildAdded)[1] -- First connection in the list
print(connection.Function())     -- Output: Triggered
print(connection:Fire()) -- Same as above, Output: Triggered
print(typeof(connection.Thread)) -- Output: thread
```

### Example 2

```luau title="Accessing a foreign/C connection" linenums="1"
local cconnection = getconnections(game.Players.LocalPlayer.Idled)[1]
print(cconnection.Function)  -- Output: nil
print(cconnection.Thread)    -- Output: nil
```
