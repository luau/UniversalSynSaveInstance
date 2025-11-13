# `hookmetamethod`

!!! info "Notes on `#!luau hookmetamethod`"

    `#!luau hookmetamethod` can be safely implemented from within Luau, **as long as [`#!luau hookfunction`](./hookfunction.md) is already properly implemented in C++**.

`#!luau hookmetamethod` takes any Luau object that can have a metatable, and attempts to hook the specified metamethod of the object. Internally, it essentially uses [`#!luau hookfunction`](./hookfunction.md) to hook specific metamethods.

```luau
function hookmetamethod(object: { [any]: any } | Instance | userdata, metamethodName: string, hook: (...any) -> (...any)): (...any) -> (...any)
```

## Parameters

| Parameter | Description |
|-----------|-------------|
| `#!luau object` | The object which has a metatable. |
| `#!luau metamethodName` | The name of the metamethod to hook. |
| `#!luau hook` | The function that will be used as a hook. |

---

## Example

```luau title="Easily hooking metamethods with hookmetamethod" linenums="1"
local original; original = hookmetamethod(game, "__index", function(...)
    local key = select(2, ...)
    print(key)
    return original(...)
end)

local _ = game.PlaceId -- Output: "PlaceId"

hookmetamethod(game, "__index", original) -- Restores game's __index
```
