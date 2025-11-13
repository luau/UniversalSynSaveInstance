# `getthreadidentity`

`#!luau getthreadidentity` retrieves the thread's identity of the running [Luau thread](https://create.roblox.com/docs/reference/engine/libraries/coroutine#running).

```luau
function getthreadidentity(): number
```

## Parameters

| Parameter  | Description                        |
|------------|------------------------------------|
| *(none)*   | This function takes no parameters. |

---

## Example

```luau title="Checking thread identity across defer" linenums="1"
task.defer(function()
    setthreadidentity(2)
    print(getthreadidentity()) -- Output: 2
end)

setthreadidentity(3)
print(getthreadidentity())     -- Output: 3
```
