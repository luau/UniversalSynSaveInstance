# `cleardrawcache`

`#!luau cleardrawcache` removes **all active drawing objects** created with [`#!luau Drawing.new`](./README.md#constructor).

```luau
function cleardrawcache(): ()
```

## Parameters

| Parameter | Description                      |
|-----------|----------------------------------|
| *(none)*  | This function takes no parameters. |

---

## Example

```luau title="Clearing all drawing objects at once" linenums="1"
local camera = game.Workspace.CurrentCamera
local viewport = camera.ViewportSize
local pos = Vector2.new(viewport.X / 2, viewport.Y / 2)

local circle = Drawing.new("Circle")
circle.Radius = 50
circle.Color = Color3.fromRGB(255, 0, 0)
circle.Filled = true
circle.NumSides = 60
circle.Position = pos
circle.Transparency = 1
circle.Visible = true

task.defer(cleardrawcache)

print(circle.__OBJECT_EXISTS) -- Output: true
task.wait()
print(circle.__OBJECT_EXISTS) -- Output: false
```
