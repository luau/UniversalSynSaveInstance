# `isrenderobj`

`#!luau isrenderobj` checks whether a given value is a valid [`#!luau Drawing`](./README.md) object.

This is useful for validation in functions or modules that work with custom render systems.

```luau
function isrenderobj(object: any): boolean
```

## Parameters

| Parameter       | Description                            |
|------------------|----------------------------------------|
| `#!luau object`   | The value to check for Drawing validity. |

---

## Example

```luau title="Checking if an object is a render object" linenums="1"
local square = Drawing.new("Square")

print(isrenderobj(square))       -- Output: true
print(isrenderobj(workspace))    -- Output: false
print(isrenderobj("not a draw")) -- Output: false
```
