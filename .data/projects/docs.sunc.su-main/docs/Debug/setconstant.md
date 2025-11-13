# `debug.setconstant`

!!! warning "C closures are not supported"

    This function will throw an error if called on a C closure, such as [`#!luau print`](https://create.roblox.com/docs/reference/engine/globals/LuaGlobals#print), since C closures have no accessible constants.

!!! info "Mutable globals"

    If `game`is a mutable global, the constant indexes will be different.

`#!luau debug.setconstant` modifies a constant at the specified index in a Luau function bytecode.

This can be used to change hardcoded behavior within functions without modifying their source code - although it requires knowing the correct constant index beforehand.

```luau
function debug.setconstant(func: (...any) -> (...any) | number, index: number, value: number | string | boolean | nil): ()
```

## Parameters

| Parameter        | Description                                                  |
|------------------|--------------------------------------------------------------|
| `#!luau func`     | The Luau function (or stack level) whose constant to modify. |
| `#!luau index`    | The position of the constant to change.                     |
| `#!luau value`    | The new constant value to set.                              |

---

## Example

```luau title="Overwriting a constant string in a function" linenums="1"
local function dummy_function()
    print(game.Name)
end

debug.setconstant(dummy_function, 4, "Players")

dummy_function() -- Output: Players
```
