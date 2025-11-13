# `getnamecallmethod`

!!! info "This function must be called from within a `#!luau __namecall` metatable hook, otherwise it will return `#!luau nil`."

`#!luau getnamecallmethod` returns the name of the method that invoked the [`#!luau __namecall`](https://devforum.roblox.com/t/how-do-i-get-namecall-method/2848439/5) metamethod.

When used **inside** a [`#!luau hookmetamethod`](../Closures/hookmetamethod.md) hook targeting `#!luau __namecall`, it will attempt to retrieve the method being called (e.g. `#!luau InvokeServer`).

When used **outside** of said hook, this function will safely return `#!luau nil`.

```luau
function getnamecallmethod(): string?
```

## Parameters

| Parameter | Description                        |
| --------- | ---------------------------------- |
| *(none)*  | This function takes no parameters. |

---

## Example

```luau title="Disallowing the usage of game:service()" linenums="1"
local refs = {}

refs.__namecall = hookmetamethod(game, "__namecall", function(...)
    local self = ...
    local method = getnamecallmethod()

    if self == game and method == "service" then
        error("Using game:service() is not allowed.")
    end

    return refs.__namecall(...)
end)
```
