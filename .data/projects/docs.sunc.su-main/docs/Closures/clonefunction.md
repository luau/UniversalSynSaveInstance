# `clonefunction`

!!! info "Notes on `#!luau clonefunction`"

    The new (cloned) function returned by `#!luau clonefunction` should have the same environment as the original function.

    Any sort of modification to the original function **should not** affect the clone. This means that stuff like hooking the original function will leave the clone **unaffected**.

`#!luau clonefunction` creates and returns a new function that has the exact same behaviour as the passed function.

```luau
function clonefunction<A..., R...>(functionToClone: (A...) -> R...): (A...) -> R...
```

## Parameters

| Parameter | Description |
|-----------|-------------|
| `#!luau functionToClone` | The function to clone. |

---

## Example

```luau title="Cloning functions with clonefunction" linenums="1"
local function dummy_function()
    print("Hello")
end

local cloned_function = clonefunction(dummy_function)

print(debug.info(cloned_function, "l")) -- Output: 1
print(debug.info(cloned_function, "n")) -- Output: dummy_function
print(cloned_function == dummy_function) -- Output: false
print(getfenv(cloned_function) == getfenv(dummy_function)) -- Output: true

```
