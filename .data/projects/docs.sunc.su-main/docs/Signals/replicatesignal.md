# `replicatesignal`

!!! warning "Signal arguments must match"

    Some signals require specific argument structures. If incorrect arguments are passed, an error must be thrown.

!!! info "Notes on `#!luau replicatesignal`"

    For an accurate result from the examples, test the function in [our game](https://www.roblox.com/games/133609342474444/ROBLOCKS-STOP-PMOING-ME).

`#!luau replicatesignal` replicates a signal to the server with the provided arguments, if possible. The arguments must also match accordingly to the signal itself. To know a signal's arguments, visit [this](https://robloxapi.github.io/ref/).

```luau
function replicatesignal(signal: RBXScriptSignal, ...: any?)
```

## Parameters

| Parameter         | Description                                            |
|------------------|--------------------------------------------------------|
| `#!luau signal`    | The signal to replicate to the server.                |
| `#!luau ...?`       | Arguments to pass to the signal. |

---

## Examples

### Example 1

```luau title="Replicating a ClickDetector interaction" linenums="1"
local detector = workspace.replicatesigmal.ClickDetector
replicatesignal(detector.MouseActionReplicated, game.Players.LocalPlayer, 0)
task.wait(0.1)

print(game.Players.LocalPlayer:GetAttribute("MouseClickReplicated")) -- Output: true
```

### Example 2

```luau title="Incorrect argument usage" linenums="1"
local ui_frame = game.Players.LocalPlayer.PlayerGui.ScreenGui.Frame

-- These will throw an error.
replicatesignal(ui_frame.MouseWheelForward)
replicatesignal(ui_frame.MouseWheelForward, 121)

-- This succeeds
replicatesignal(ui_frame.MouseWheelForward, 121, 214)
task.wait(0.1)

print(game.Players.LocalPlayer:GetAttribute("MouseWheelForwardReplicated")) -- Output: true
```
