# `setscriptable`

!!! warning "Detection risks"

    `#!luau setscriptable` can expose detection vectors. Games may check whether certain properties are unexpectedly accessible, which can lead to detections.

!!! info "Limited property support"

    Not all hidden properties can be obtained using this function.

`#!luau setscriptable` toggles the scriptability of a hidden or non-scriptable property on an [`Instance`](https://create.roblox.com/docs/reference/engine/classes/Instance). When a property is made scriptable, it can be accessed or assigned through standard indexing.

```luau
function setscriptable(instance: Instance, property_name: string, state: boolean): boolean | nil
```

## Parameters

| Parameter              | Description                                                                                                     |
| ---------------------- | --------------------------------------------------------------------------------------------------------------- |
| `#!luau instance`      | The [Instance](https://create.roblox.com/docs/reference/engine/classes/Instance) that owns the target property. |
| `#!luau property_name` | The name of the property to make scriptable or un-scriptable.                                                   |
| `#!luau state`         | Whether to enable (`#!luau true`) or disable (`#!luau false`) scriptability.                                    |

---

## Example

```luau title="Temporarily enabling scriptability of a property" linenums="1"
local part = Instance.new("Part")

setscriptable(part, "BottomParamA", true)
print(part.BottomParamA) -- Output: -0.5

setscriptable(part, "BottomParamA", false)
print(part.BottomParamA) -- Throws an error
```
