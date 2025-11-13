# `restorefunction`

!!! warning "This will throw an error if the requested function is not already hooked"

`#!luau restorefunction` restores a hooked function back to the very first original function, even if it has been hooked multiple times.

```luau
function restorefunction(functionToRestore: (...any) -> (...any)): ()
```

## Parameters

| Parameter        | Description                                              |
|------------------|----------------------------------------------------------|
| `#!luau functionToRestore`   | The hooked function that you want to restore     |

---

## Examples

### Example 1

```luau title="Restoring a hooked function" linenums="1"
function dummy_func()
    print("I am not hooked!")
end

hookfunction(dummy_func, function()
    print("I am hooked!")
end)

dummy_func() -- Output: I am hooked!
restorefunction(dummy_func)
dummy_func() -- Output: I am not hooked!

```

### Example 2

```luau title="Restoring a unhooked function" linenums="1"
function dummy_func()
    print("I am not hooked!")
end

dummy_func() -- Output: I am not hooked!
restorefunction(dummy_func) -- Error: restorefunction: function is not hooked

```
