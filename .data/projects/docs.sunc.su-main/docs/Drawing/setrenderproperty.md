# `setrenderproperty`

`#!luau setrenderproperty` assigns a value to a property of a [`#!luau Drawing`](./README.md) object. This behaves identically to `#!luau object[property] = value`, but is useful for dynamic or abstracted property access.

```luau
function setrenderproperty(drawing: Drawing, property: string, value: any): ()
```

## Parameters

| Parameter        | Description                                                  |
|------------------|--------------------------------------------------------------|
| `#!luau drawing`   | A valid [`#!luau Drawing`](./README.md) object.              |
| `#!luau property`  | The name of the property to assign.                          |
| `#!luau value`     | The value to assign to the specified property.               |

---

## Example

```luau title="Setting drawing properties" linenums="1"
local circle = Drawing.new("Circle")

setrenderproperty(circle, "Radius", 50)
setrenderproperty(circle, "Visible", true)

print(circle.Radius)   -- Output: 50
print(circle.Visible)  -- Output: true
```
