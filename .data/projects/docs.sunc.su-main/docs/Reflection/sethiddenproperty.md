# `sethiddenproperty`

!!! warning "Avoid relying on [`#!luau setscriptable`](./setscriptable.md) to implement this function"

    Some executors implement this function using [`#!luau setscriptable`](./setscriptable.md), which is limited and/or detectable.

`#!luau sethiddenproperty` assigns a value to a hidden or non-scriptable property of an [`Instance`](https://create.roblox.com/docs/reference/engine/classes/Instance), even if that property is normally read-only or inaccessible.

It returns `#!luau true` if the property is hidden and was successfully written to, or `#!luau false` if the property wasn't hidden but was still updated.

```luau
function sethiddenproperty(instance: Instance, property_name: string, property_value: any): boolean
```

## Parameters

| Parameter             | Description                                                  |
|-----------------------|--------------------------------------------------------------|
| `#!luau instance`       | The [instance](https://create.roblox.com/docs/reference/engine/classes/Instance) that owns the target property.                  |
| `#!luau property_name`  | The name of the property to update.                          |
| `#!luau property_value` | The new value to assign to the property.                     |

---

## Example

```luau title="Setting a hidden property value" linenums="1"
local part = Instance.new("Part")

print(gethiddenproperty(part, "DataCost")) -- Output: 20, true

sethiddenproperty(part, "DataCost", 100)

print(gethiddenproperty(part, "DataCost")) -- Output: 100, true
```
