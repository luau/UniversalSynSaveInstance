# `debug.setupvalue`

!!! warning "C closures not supported"

    This function will throw an error if called on a C closure, such as [`#!luau print`](https://create.roblox.com/docs/reference/engine/globals/LuaGlobals#print), for security reasons.

`#!luau debug.setupvalue` replaces an upvalue at the specified index in a Luau function, with a new value.

This allows for controlled modification of function state, often used in hooking or testing environments.

```luau
function debug.setupvalue(func: (...any) -> (...any) | number, index: number, value: any): ()
```

## Parameters

| Parameter        | Description                                                    |
|------------------|----------------------------------------------------------------|
| `#!luau func`     | The function (or stack level) whose upvalue to replace.   |
| `#!luau index`    | The index of the upvalue to be replaced.                      |
| `#!luau value`    | The new value to assign to the upvalue.                       |

---

## Example

```luau title="Replacing a numeric upvalue" linenums="1"
local upvalue = 90

local function dummy_function()
    upvalue += 1
    print(upvalue)
end

dummy_function() -- Output: 91

debug.setupvalue(dummy_function, 1, 99)
dummy_function() -- Output: 100
```
