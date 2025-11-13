# `getrenderproperty`

`#!luau getrenderproperty` retrieves the value of a property from a [`#!luau Drawing`](./README.md) object. This behaves identically to using `#!luau object[property]`, but is useful when working with dynamic property names or for reflection-like access.

```luau
function getrenderproperty(drawing: Drawing, property: string): any
```

## Parameters

| Parameter       | Description                                                  |
|------------------|--------------------------------------------------------------|
| `#!luau drawing`   | A valid [`#!luau Drawing`](./README.md) object.              |
| `#!luau property`  | The name of the property to retrieve.                        |

---

## Example

```luau title="Reading drawing properties" linenums="1"
local circle = Drawing.new("Circle")
circle.Radius = 50
circle.Visible = true

print(getrenderproperty(circle, "Radius"))    -- Output: 50
print(getrenderproperty(circle, "Visible"))   -- Output: true
```
