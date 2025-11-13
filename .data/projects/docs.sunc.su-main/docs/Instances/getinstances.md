# `getinstances`

!!! info "Includes all memory-tracked instances"

    `#!luau getinstances` should be able to return [instances](https://create.roblox.com/docs/reference/engine/classes/Instance) outside of [`game`](https://create.roblox.com/docs/reference/engine/classes/DataModel).

`#!luau getinstances` retrieves **every [`#!luau Instance`](https://create.roblox.com/docs/reference/engine/classes/Instance)** from the registry. Which means that instances that are/were parented to `#!luau nil` will also be returned.

```luau
function getinstances(): { Instance }
```

## Parameters

| Parameter | Description                      |
|-----------|----------------------------------|
| *(none)*  | This function takes no parameters. |

---

## Example

```luau title="Finding a nil-parented instance" linenums="1"
local dummy_part = Instance.new("Part")
dummy_part.Parent = nil

for _, instance in pairs(getinstances()) do
    if instance == dummy_part then
        print("Found the dummy part!")
    end
end
```
