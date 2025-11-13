# `getrenv`

!!! warning "Adding `#!luau _G` and `#!luau shared`"
    Make sure to properly implement `#!luau _G` and `#!luau shared` into the Roblox environment, as poor implementations will result in detection vectors!

`#!luau getrenv` returns the **Roblox global environment**, which is used by the entire game. Changes to this environment will affect your executor environment as well.

```luau
function getrenv(): { any }
```

## Parameters

| Parameter | Description                      |
|-----------|----------------------------------|
| *(none)*  | This function takes no parameters. |

---

## Example

```luau title="Overriding Roblox environment functions" linenums="1"
getrenv().warn = "Hello!"
print(type(warn)) -- Output: string

getrenv().game = nil
print(game) -- Output: nil
```
