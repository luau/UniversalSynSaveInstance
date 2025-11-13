# `hookfunction`

!!! info "Notes on `#!luau hookfunction`"

    The hook should not have more upvalues than the function you want to hook. There are ways to bypass the upvalue restriction, such as using `#!luau newlclosure` or [`#!luau newcclosure`](./newcclosure.md) to wrap the `#!luau hook`

    All possible hooking closure pairs should be supported throughout L, NC, C (where NC = [`#!luau newcclosure`](./newcclosure.md))

`#!luau hookfunction` allows you to hook a function with another wanted function, returning the original unhooked function.

```luau
function hookfunction<A1..., R1..., A2..., R2...>(functionToHook: (A1...) -> R1..., hook: (A2...) -> R2...): (A1...) -> R1...
```

## Parameters

| Parameter | Description |
|-----------|-------------|
| `#!luau functionToHook` | The function that will be hooked |
| `#!luau hook` | The function that will be used as a hook |

---

## Example

```luau title="Hooking functions with hookfunction" linenums="1"
local function dummy_func()
    print("I am not hooked!")
end

local function dummy_hook()
    print("I am hooked!")
end

dummy_func() -- Output: I am not hooked!

local old_func = hookfunction(dummy_func, dummy_hook)

dummy_func() -- Output: I am hooked!
old_func() -- Output: I am not hooked!
```
