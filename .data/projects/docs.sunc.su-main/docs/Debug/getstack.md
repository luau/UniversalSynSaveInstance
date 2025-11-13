# `debug.getstack`

!!! warning "C closures are not supported"

    This function will throw an error if the stack level points to a C closure, such as `#!luau getstack(0)`.

`#!luau debug.getstack` retrieves values from the stack at the specified call level.

This function is useful for inspecting local variables or arguments at different layers of the stack frame. If no index is given, all values at that stack level are returned as a list.

```luau
function debug.getstack(level: number, index: number?): any | { any }
```

## Parameters

| Parameter         | Description                                                       |
|-------------------|-------------------------------------------------------------------|
| `#!luau level`     | The stack level to inspect. `1` is the current function.          |
| `#!luau index?`    | The specific slot/index at that stack level to read.   |

---

## Examples

### Example 1

```luau title="Retrieving multiple values from the stack" linenums="1"
local count = 0

local function recursive_function()
    count += 1
    if count > 6 then return end

    local a = 29
    local b = true
    local c = "Example"
    a += 1
    b = false
    c ..= "s"

    print(debug.getstack(1, count))
    recursive_function()
end

recursive_function()
-- Output (varies depending on Count):
-- 30
-- false
-- Examples
-- function: 0x... (print)
-- function: 0x... (getstack)
-- etc.
```

### Example 2

```luau title="Retrieving values from the caller's stack" linenums="1"
local function dummy_function()
    return "Hello"
end

local var = 5
var += 1

(function()
    print(debug.getstack(2)[1]()) -- Output: Hello
    print(debug.getstack(2)[2])   -- Output: 6
end)()
```
