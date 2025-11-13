# `debug.getconstants`

!!! warning "C closures are not supported"

    This function will throw an error if called on a C closure, such as [`#!luau print`](https://create.roblox.com/docs/reference/engine/globals/LuaGlobals#print), since C closures have no accessible constants.

`#!luau debug.getconstants` returns a list of all constants used within a Luau function's bytecode. This includes literal values like numbers, strings, booleans, and `#!luau nil`.

```luau
function debug.getconstants(func: (...any) -> (...any) | number): { number | string | boolean | nil }
```

## Parameters

| Parameter       | Description                                                        |
|------------------|--------------------------------------------------------------------|
| `#!luau func`    | The Luau function (or stack level) whose constants will be returned.|

---

## Examples

### Example 1

```luau title="Retrieving constants from a Luau function" linenums="1"
local function dummy_function()
    local dummy_string = "foo bar"
    string.split(dummy_string, " ")
end

local constants = debug.getconstants(dummy_function)
for constant_index, constant in constants do
    print(`[{constant_index}]: {constant}`)
end

-- Output:
-- [1]: "string"
-- [2]: "split"
-- [4]: "foo bar"
-- [5]: " "
```

### Example 2

```luau title="Calling on a C closure should error" linenums="1"
print(debug.getconstants(print)) -- Should error due to being a C closure
```
