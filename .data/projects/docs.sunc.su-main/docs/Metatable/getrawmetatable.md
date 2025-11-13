# `getrawmetatable`

`#!luau getrawmetatable` returns the raw metatable of an object, even if that object has a `#!luau __metatable` field set.

```luau
function getrawmetatable(object: { any } | userdata): { [any]: any } | nil
```

## Parameters

| Parameter        | Description                              |
|------------------|------------------------------------------|
| `#!luau object`  | The object whose metatable to retrieve.  |

---

## Examples

### Example 1

```luau title="Retrieving the metatable of the DataModel" linenums="1"
local mt = getrawmetatable(game)
print(type(mt)) -- Output: table
print(mt.__index(game, "Workspace")) -- Output: Workspace
```

### Example 2

```luau title="Obtaining nil when object has no metatable set" linenums="1"
print(getrawmetatable(newproxy(false)))
```
