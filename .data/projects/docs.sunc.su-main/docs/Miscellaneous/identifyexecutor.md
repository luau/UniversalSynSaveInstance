# `identifyexecutor`

`#!luau identifyexecutor` returns the name and version of the currently running executor.

This function is quite self-explanatory, you use it for logging/debugging purposes, idk - its quite basic.

The function returns a tuple of:

1. `#!luau string` - The name/identifier of the executor.
2. `#!luau string` - The version string of the executor.

```luau
function identifyexecutor(): (string, string)
```

## Parameters

| Parameter | Description                        |
| --------- | ---------------------------------- |
| *(none)*  | This function takes no parameters. |

---

## Example

```luau title="Getting the current executor and version" linenums="1"
local exec_name, exec_version = identifyexecutor()
print(exec_name, exec_version) -- Output: "YourExploitName 0.0.1"
```
