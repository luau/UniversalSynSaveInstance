# `debug.getproto`

!!! warning "C closures are not supported"

    This function will throw an error if called on a C closure, such as [`#!luau print`](https://create.roblox.com/docs/reference/engine/globals/LuaGlobals#print), since C closures do not contain function prototypes.

!!! info "Inactive protos"

    Protos retrieved without the `activated` should not be callable; this leads to vulnerabilities.
    The usage of inactive protos is to retrieve information off of them.

`#!luau debug.getproto` returns a specific function prototype from a Luau function by index. Optionally, it can search for **active functions** of the proto, if the `#!luau activated` parameter is set to `true`.

These are internal function definitions (e.g. nested functions) that exist as part of the compiled bytecode, even if they aren't assigned or called.

```luau
function debug.getproto(func: (...any) -> (...any) | number, index: number, activated: boolean?): (...any) -> (...any) | { (...any) -> (...any) }
```

## Parameters

| Parameter           | Description                                                                 |
|---------------------|-----------------------------------------------------------------------------|
| `#!luau func`        | The Luau function (or stack level) to extract a proto from.                  |
| `#!luau index`       | The index of the prototype to return.                                       |
| `#!luau activated?`  | If `true`, returns a table of currently active functions based on the proto. |

---

## Examples

### Example 1

```luau title="Retrieving nested prototypes" linenums="1"
local function dummy_function()
    local function dummy_proto_1()
        print("Hello")
    end
    local function dummy_proto_2()
        print("Hello2")
    end
end

debug.getproto(dummy_function, 1)() -- Uncallable
debug.getproto(dummy_function, 2)() -- Uncallable
```

### Example 2

```luau title="Retrieving an active function from a proto" linenums="1"
local function dummy_function()
    local function dummy_proto()
        return "hi"
    end
    return dummy_proto
end

local real_proto = dummy_function()
local retrieved_proto = debug.getproto(dummy_function, 1, true)[1]

print(real_proto == retrieved_proto) -- Output: true
print(retrieved_proto()) -- Output: hi
```
