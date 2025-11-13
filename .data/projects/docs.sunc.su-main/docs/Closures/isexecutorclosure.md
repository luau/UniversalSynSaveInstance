# `isexecutorclosure`

`#!luau isexecutorclosure` checks whether a given function is a closure of the executor. This also includes closures retrieved using [`#!luau getscriptclosure`](../Scripts/getloadedmodules.md) or [`#!luau loadstring`](../Scripts/loadstring.md)

```luau
function isexecutorclosure(func: (...any) -> (...any)): boolean
```

## Parameters

| Parameter | Description |
|-----------|-------------|
| `#!luau func` | The function to check. |

---

## Example

```luau title="Identifying executor closures with isexecutorclosure" linenums="1"
local function dummy_lua_function()
    print("This is an executor Luau closure")
end

local dummy_cfunction = newcclosure(function()
    print("This is an executor C closure")
end)

local dummy_standard_cfunction = print
local dummy_global_cfunction = getgc

print(isexecutorclosure(dummy_lua_function)) -- Output: true
print(isexecutorclosure(dummy_cfunction)) -- Output: true
print(isexecutorclosure(dummy_global_cfunction)) -- Output: true
print(isexecutorclosure(dummy_standard_cfunction)) -- Output: false
```
