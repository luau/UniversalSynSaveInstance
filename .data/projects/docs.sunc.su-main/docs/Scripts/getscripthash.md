# `getscripthash`

!!! info "Do not decrypt or decompress the bytecode"

    The hash must be computed **on the encrypted, compressed bytecode** - not after any modification.  
    This function should also return `#!luau nil` if the script has no bytecode.

`#!luau getscripthash` returns a [SHA-384 hash](https://en.wikipedia.org/wiki/SHA-3) in ***hexadecimal format*** of the raw bytecode for a given [`#!luau Script`](https://create.roblox.com/docs/reference/engine/classes/Script), [`#!luau LocalScript`](https://create.roblox.com/docs/reference/engine/classes/LocalScript), or [`#!luau ModuleScript`](https://create.roblox.com/docs/reference/engine/classes/ModuleScript).

This is useful for **identifying scripts** by their content, especially when checking for known modules or verifying integrity.

```luau
function getscripthash(script: BaseScript | ModuleScript): string | nil
```

## Parameters

| Parameter      | Description                                            |
|----------------|--------------------------------------------------------|
| `#!luau script` | The [BaseScript](https://create.roblox.com/docs/reference/engine/classes/BaseScript) or [ModuleScript](https://create.roblox.com/docs/reference/engine/classes/ModuleScript) instance to hash.                           |

---

## Example

```luau title="Hashing a live script" linenums="1"
local Animate = game.Players.LocalPlayer.Character:FindFirstChild("Animate")

print(getscripthash(Animate)) -- Output: 384-bit hash string

print(getscripthash(Instance.new("LocalScript"))) -- Output: nil
```
