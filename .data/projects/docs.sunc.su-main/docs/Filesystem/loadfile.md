# `loadfile`

`#!luau loadfile` compiles the Luau source code from a file and returns the resulting function (chunk). This chunk runs in the global environment.

If the file contains syntax errors, an error is thrown - just like [`#!luau loadstring`](https://create.roblox.com/docs/reference/engine/globals/LuaGlobals#loadstring). The error will appear in the  console.

```luau
function loadfile<A...>(path: string): ((A...) -> any | nil, string?)
```

## Parameters

| Parameter       | Description                         |
|------------------|-------------------------------------|
| `#!luau path`    | The path to the file to be loaded.  |

---

## Examples

### Example 1

```luau title="Loading and executing a valid file" linenums="1"
writefile("file6.lua", "return 10 + ...")
local chunk = loadfile("file6.lua")
print(chunk(1)) -- Output: 11
```

### Example 2

```luau title="Triggering a syntax error" linenums="1"
writefile("file6.lua", "retrn 10 + ...")
loadfile("file6.lua") -- This will throw an error in the console
```
