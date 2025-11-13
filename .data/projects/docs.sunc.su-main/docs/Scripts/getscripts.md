# `getscripts`

`#!luau getscripts` returns a list of **all [`#!luau Script`](https://create.roblox.com/docs/reference/engine/classes/Script), [`#!luau LocalScript`](https://create.roblox.com/docs/reference/engine/classes/LocalScript), and [`#!luau ModuleScript`](https://create.roblox.com/docs/reference/engine/classes/ModuleScript) instances** present.

This function excludes [`#!luau CoreScripts`](https://robloxapi.github.io/ref/class/CoreScript.html) by default.

```luau
function getscripts(): { BaseScript | ModuleScript }
```

## Parameters

| Parameter | Description                      |
|-----------|----------------------------------|
| *(none)*  | This function takes no parameters. |

---

## Example

```luau title="Locating a known script instance" linenums="1"
local dummy_script = Instance.new("LocalScript")
dummy_script.Name = "TestScript"

for _, script in pairs(getscripts()) do
    if script == dummy_script then
        print("Found the dummy script!")
    end
end
```
