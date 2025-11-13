# `getreg`

`#!luau getreg` returns the **Luau registry table**. The registry is a special table which is used internally to store references like threads, functions, and data shared between C and Luau (userdata).

```luau
function getreg(): { [any]: any }
```

## Parameters

| Parameter | Description                      |
|-----------|----------------------------------|
| *(none)*  | This function takes no parameters. |

---

## Example

```luau title="Closing a thread via getreg" linenums="1"
local loop_thread = task.spawn(function()
    while task.wait(1) do
        print("I am still running...")
    end
end)

task.wait(0.2) -- Let the loop run for a bit

for _, value in pairs(getreg()) do
    if value ~= loop_thread then continue end
    
    print(`Found loop thread: {loop_thread}`) -- Should print
    coroutine.close(loop_thread) -- Should close the thread

    break
end
```
