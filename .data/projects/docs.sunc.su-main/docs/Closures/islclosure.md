# `islclosure`

`#!luau islclosure` checks whether a given function is a Luau closure or not.

```luau
function islclosure(func: (...any) -> (...any)): boolean
```

## Parameters

| Parameter | Description |
|-----------|-------------|
| `#!luau func` | The function to check. |

---

## Example

```luau title="Verifying Luau closures with islclosure" linenums="1"
local function dummy_lua_function()
    print("This is an executor Luau closure")
end

local dummy_cfunction = newcclosure(function()
    print("This is an executor C closure")
end)

local dummy_standard_cfunction = print

print(islclosure(dummy_lua_function)) -- Output: true
print(islclosure(dummy_standard_cfunction)) -- Output: false
print(islclosure(dummy_cfunction)) -- Output: false
```
