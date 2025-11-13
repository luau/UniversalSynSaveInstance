# `iscclosure`

`#!luau iscclosure` checks whether a given function is a C closure or not.

```luau
function iscclosure(func: (...any) -> (...any)): boolean
```

## Parameters

| Parameter | Description |
|-----------|-------------|
| `#!luau func` | The function to check. |

---

## Example

```luau title="Checking whether functions are C closures with iscclosure" linenums="1"
local function dummy_lua_function()
    print("This is an executor Luau closure")
end

local dummy_cfunction = newcclosure(function()
    print("This is an Executor C Closure")
end)

local dummy_standard_function = print
local dummy_global_cfunction = getgc

print(iscclosure(dummy_cfunction)) -- Output: true
print(iscclosure(dummy_global_cfunction)) -- Output: true
print(iscclosure(dummy_standard_function)) -- Output: true
print(iscclosure(dummy_lua_function)) -- Output: false
```
