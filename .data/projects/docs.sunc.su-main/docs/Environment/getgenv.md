# `getgenv`

!!! warning "Pollution of getgenv results"

    Modifications to a thread's global environment should not affect the results returned by `#!luau getgenv`.

`#!luau getgenv` returns the **executor's global environment table**, which is shared across all executor-made threads.

This environment is writable and persistent during the session, making it useful for sharing state or functions across different scripts.

```luau
function getgenv(): { any }
```

## Parameters

| Parameter | Description                      |
|-----------|----------------------------------|
| *(none)*  | This function takes no parameters. |

---

## Example

```luau title="getgenv should not be affected by the global table/getfenv" linenums="1"
getgenv().dummy_val = "value"
getfenv().dummy_val_2 = 1

print(dummy_val, getgenv().dummy_val_2) -- Output: value, 1

getgenv().dummy_val = "value2"
dummy_val = nil
print(dummy_val) -- Output: value2
```
