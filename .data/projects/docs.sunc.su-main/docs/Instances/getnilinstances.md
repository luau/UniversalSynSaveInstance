# `getnilinstances`

`#!luau getnilinstances` returns a list of [`#!luau Instance`](https://create.roblox.com/docs/reference/engine/classes/Instance) objects that are **currently unparented**. These instances exist in memory but are no longer part of the [`#!luau DataModel`](https://create.roblox.com/docs/reference/engine/classes/DataModel) hierarchy.

```luau
function getnilinstances(): { Instance }
```

## Parameters

| Parameter | Description                      |
|-----------|----------------------------------|
| *(none)*  | This function takes no parameters. |

---

## Example

```luau title="Detecting a detached part" linenums="1"
local part = Instance.new("Part")
for _, instance in pairs(getnilinstances()) do
    if instance == part then
        print("Found our unattached part!")
    end
end
```
