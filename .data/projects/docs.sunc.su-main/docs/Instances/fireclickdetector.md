# `fireclickdetector`

!!! warning "Avoid implementing in Luau"

    This function should **not be implemented** in Luau. Doing so exposes you to easy detection vectors.

`#!luau fireclickdetector` triggers a [`#!luau ClickDetector`](https://create.roblox.com/docs/reference/engine/classes/ClickDetector) event. By default, it fires the [`#!luau MouseClick`](https://create.roblox.com/docs/reference/engine/classes/ClickDetector#MouseClick) event.

```luau
function fireclickdetector(detector: ClickDetector, distance: number?, event: string?): ()
```

## Parameters

| Parameter          | Description                                                                                                     |
| ------------------ | --------------------------------------------------------------------------------------------------------------- |
| `#!luau detector`  | The [`#!luau ClickDetector`](https://create.roblox.com/docs/reference/engine/classes/ClickDetector) to trigger. |
| `#!luau distance?` | Distance from which the click is simulated. Defaults to infinite.                                               |
| `#!luau event?`    | The event to trigger.                                                                                           |

---

## Example

```luau title="Firing different ClickDetector events" linenums="1"
local click_detector = Instance.new("ClickDetector")

click_detector.MouseClick:Connect(function(player)
    print(`{player.Name} Fired M1`)
end)

click_detector.RightMouseClick:Connect(function(player)
    print(`{player.Name} Fired M2`)
end)

click_detector.MouseHoverEnter:Connect(function(player)
    print(`{player.Name} Fired HoverEnter`)
end)

click_detector.MouseHoverLeave:Connect(function(player)
    print(`{player} Fired HoverLeave`)
end)

fireclickdetector(click_detector, 0, "MouseClick") -- Output: Player Fired M1
fireclickdetector(click_detector, 0, "RightMouseClick") -- Output: Player Fired M2
fireclickdetector(click_detector, 0, "MouseHoverEnter") -- Output: Player Fired HoverEnter
fireclickdetector(click_detector, 0, "MouseHoverLeave") -- Output: Player Fired HoverLeave
```
