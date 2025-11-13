# `firesignal`

!!! info "Firing mode"

    This function will invoke all the connections of the signal **immediately**, ignoring the [`#!luau Workspace.SignalBehaviour`](https://create.roblox.com/docs/reference/engine/classes/Workspace#SignalBehavior) property.

`#!luau firesignal` Invokes all Luau [connections](https://create.roblox.com/docs/reference/engine/datatypes/RBXScriptConnection) connected to a given [`#!luau RBXScriptSignal`](https://create.roblox.com/docs/reference/engine/datatypes/RBXScriptSignal).

```luau
function firesignal(signal: RBXScriptSignal, ...: any?)
```

## Parameters

| Parameter         | Description                                            |
|------------------|--------------------------------------------------------|
| `#!luau signal`    | The signal whose connections you want to manually fire. |
| `#!luau ...?`       | The arguments to pass to the connected functions.       |

---

## Example

```luau title="Manually firing a signal with and without arguments" linenums="1"
local part = Instance.new("Part")

part.ChildAdded:Connect(function(arg1)
    print(typeof(arg1))
end)

firesignal(part.ChildAdded)            -- Output: nil
firesignal(part.ChildAdded, workspace) -- Output: Instance
```
