# `newcclosure`

!!! failure "Do not implement this with coroutines"

    Many executors seem to be implementing this function using [`#!luau coroutine`](https://create.roblox.com/docs/reference/engine/libraries/coroutine) functions in Luau. Such functions **will not pass sUNC checks**.

    The wrapped function **must** be yieldable, meaning that the function should be able to call [`#!luau task.wait`](https://create.roblox.com/docs/reference/engine/libraries/task#wait), for example.

!!! failure "Error spoofing"

    Luau and C errors are different. You must ensure that errors from functions wrapped with `#!luau newcclosure` appear as C closure errors!

!!! info "Upvalues"

    The function returned by `#!luau newcclosure` must have no upvalues.

`#!luau newcclosure` takes any Luau function and wraps it into a C closure.
When the returned function is called, it invokes the original Luau closure with the provided arguments, then passes the closure's returned values back to the caller.

```luau
function newcclosure<A..., R...>(functionToWrap: (A...) -> R...): (A...) -> R...
```

## Parameters

| Parameter               | Description               |
|-------------------------|---------------------------|
| `#!luau functionToWrap` | A function to be wrapped. |

---

## Examples

### Example 1

```luau title="Basic C closure wrapping example with newcclosure" linenums="1"
local dummy_function = function(...)
    return ...
end

print(iscclosure(dummy_function)) -- Output: false

local wrapped_function = newcclosure(dummy_function)

print(iscclosure(wrapped_function)) -- Output: true

local function_results = wrapped_function("Hello")
print(function_results) -- Output: Hello
```

### Example 2

This example illustrates how Luau functions wrapped as a C closure should also be yieldable, therefore also showcasing how coroutine implementations of `#!luau newcclosure` would not work.

```luau title="Yieldable C functions made with newcclosure" linenums="1"
local dummy_yielding_function = newcclosure(function()
    print("Before")
    task.wait(1.5)
    print("After")
end)

dummy_yielding_function()
-- Output:
-- Before
-- yield for 1.5 seconds
-- After
```
