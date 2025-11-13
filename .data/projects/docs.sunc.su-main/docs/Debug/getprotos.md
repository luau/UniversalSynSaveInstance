# `debug.getprotos`

!!! warning "C closures are not supported"

    This function will throw an error if called on a C closure, such as [`#!luau print`](https://create.roblox.com/docs/reference/engine/globals/LuaGlobals#print), since C closures do not contain function prototypes.

!!! info "Inactive protos"

    Protos retrieved without the `activated` should not be callable; this leads to vulnerabilities.
    The usage of inactive protos is to retrieve information off of them.

`#!luau debug.getprotos` returns all function prototypes defined within the specified Luau function.

These are internal function definitions (e.g. nested functions) that exist as part of the compiled bytecode, even if they aren't assigned or called.

```luau
function debug.getprotos(func: (...any) -> (...any) | number): { (...any) -> (...any) }
```

## Parameters

| Parameter        | Description                                                   |
|------------------|---------------------------------------------------------------|
| `#!luau func`     | The Luau function (or stack level) to extract protos from.     |

---

## Example

```luau title="Getting nested function prototypes" linenums="1"
local function DummyFunction0()
    local function DummyFunction1() end
    local function DummyFunction2() end
end

for index, proto in pairs(debug.getprotos(DummyFunction0)) do
    print(index, debug.info(proto, "n"))
end

-- Output:
-- 1 DummyFunction1
-- 2 DummyFunction2
```
