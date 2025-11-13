# `debug.getupvalues`

!!! warning "C closures are not supported"

    This function will throw an error if called on a C closure, such as [`#!luau print`](https://create.roblox.com/docs/reference/engine/globals/LuaGlobals#print), for security reasons.

`#!luau debug.getupvalues` returns a list of upvalues captured by a Luau function. These are the external variables that a function closes over from its surrounding scope.

If the function has no upvalues, the result will be an empty table.

```luau
function debug.getupvalues(func: (...any) -> (...any) | number): { any }
```

## Parameters

| Parameter        | Description                                                        |
|------------------|--------------------------------------------------------------------|
| `#!luau func`     | The Luau function (or stack level) to retrieve upvalues from.       |

---

## Examples

### Example 1

```luau title="Retrieving upvalues from a closure" linenums="1"
local var1 = false
local var2 = "Hi"

local function dummy_function()
    var1 = true
    var2 ..= ", hello"
end

for index, value in pairs(debug.getupvalues(dummy_function)) do
    print(index, value)
end

-- Output:
-- 1 false
-- 2 Hi
```

### Example 2

```luau title="Calling with a function that has no upvalues" linenums="1"
local function dummy_function()
    return 123
end

print(next(debug.getupvalues(dummy_function))) -- Output: nil
```

### Example 3

```luau title="Calling on a C closure should error" linenums="1"
print(debug.getupvalues(print)) -- Should error due to being a C closure
```
