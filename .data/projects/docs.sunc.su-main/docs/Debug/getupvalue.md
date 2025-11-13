# `debug.getupvalue`

!!! warning "C closures are not supported"

    This function will throw an error if called on a C closure, such as [`#!luau print`](https://create.roblox.com/docs/reference/engine/globals/LuaGlobals#print), for security reasons.

`#!luau debug.getupvalue` returns the upvalue at the specified index from a Luau function's closure. If the index is invalid or out of bounds, an error will occur.

```luau
function debug.getupvalue(func: (...any) -> (...any) | number, index: number): any
```

## Parameters

| Parameter        | Description                                                        |
|------------------|--------------------------------------------------------------------|
| `#!luau func`     | The Luau function (or stack level) to retrieve an upvalue from.     |
| `#!luau index`    | The position of the upvalue.                                       |

---

## Examples

### Example 1

```luau title="Retrieving a function upvalue" linenums="1"
local UpFunction = function()
    print("Hello from up")
end

local function DummyFunction()
    UpFunction()
end

local Retrieved = debug.getupvalue(DummyFunction, 1)
Retrieved() -- Output: Hello from up
```

### Example 2

```luau title="Invalid index on a function with no upvalues" linenums="1"
local function DummyFunction() end

debug.getupvalue(DummyFunction, 0) -- Should error
```

### Example 3

```luau title="Calling on a C closure should error" linenums="1"
debug.getupvalue(print, 1) -- Should error due to C closure
```
