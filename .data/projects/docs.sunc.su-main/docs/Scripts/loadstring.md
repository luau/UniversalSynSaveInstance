# `loadstring`

!!! warning "Unsafe by design"

    Compiles the given string, and returns it runnable in a function. The environment must become unsafe after this function is called due to it allowing the modification of globals uncontrollably (see [`#!luau setfenv`](https://create.roblox.com/docs/reference/engine/globals/LuaGlobals#setfenv)/[`#!luau getfenv`](https://create.roblox.com/docs/reference/engine/globals/LuaGlobals#getfenv) documentation).

!!! info "Should error when compilation fails"

    This function should return `#!luau nil` and an error message if the provided code fails to compile.

`#!luau loadstring` compiles a string of Luau code and returns it as a runnable function. If the code has errors, `#!luau nil` is returned and an error message is output.

```luau
function loadstring<A...>(source: string, chunkname: string?): (((A...) -> any) | nil, string?)
```

## Parameters

| Parameter           | Description                        |
|---------------------|------------------------------------|
| `#!luau source`     | The source code string to compile. |
| `#!luau chunkname?` | Custom chunk name.                 |

---

## Examples

### Example 1

```luau title="Compiling and running source code successfully" linenums="1"
loadstring([[
    placeholder = {"Example"}
]])()

print(placeholder[1]) -- Output: Example
```

---

### Example 2

```luau title="Using a custom chunk name while also getting an error" linenums="1"
local func, err = loadstring("Example = ", "CustomChunk")

print(func) -- Output: nil
print(err)  -- Output: [string "CustomChunk"]:1: Expected identifier when parsing expression, got <eof>
```
