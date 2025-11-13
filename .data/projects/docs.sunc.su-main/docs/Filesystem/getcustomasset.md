# `getcustomasset`

`#!luau getcustomasset` returns a content ID (e.g. `rbxasset://`) that can be used in Roblox APIs for loading audio, meshes, UI images, and other asset types.

Internally, the file at the given path is copied to the game's content directory and then exposed with a usable asset URL.

```luau
function getcustomasset(path: string): string
```

## Parameters

| Parameter       | Description                                |
|------------------|--------------------------------------------|
| `#!luau path`    | The file path to convert into an asset ID. |

---

## Example

```luau title="Using getcustomasset to load and play a sound in-game" linenums="1"
local encoded = game:HttpGet("https://gitlab.com/sens3/nebunu/-/raw/main/encodedBytecode.txt")
writefile("ExampleSound.mp3", base64decode(encoded))

local asset_id = getcustomasset("ExampleSound.mp3")

local sound = Instance.new("Sound")
sound.Parent = workspace
sound.SoundId = asset_id
sound.Volume = 0.35
sound:Play()
```
