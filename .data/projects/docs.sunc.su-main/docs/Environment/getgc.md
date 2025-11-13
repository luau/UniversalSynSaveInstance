# `getgc`

`#!luau getgc` returns a list of **non-dead garbage-collectable values**. These include functions, userdatas, and optionally tables.

```luau
export type AnyFunction = (...any) -> (...any)
export type AnyTable = { [any]: any }

export type userdata = typeof(newproxy()) -- (1)

declare getgc:
    ((includeTables: true) -> { { AnyTable } | AnyFunction | userdata }) &
    ((includeTables: false?) -> { AnyFunction })
```

1. Note that `#!luau userdata` is not an official Luau type, but we define it here for clarity - because `#!luau getgc` can return them as part of its results.

## Parameters

| Parameter           | Description                                               |
|---------------------|-----------------------------------------------------------|
| `#!luau includeTables?` | If `#!luau true`, also includes tables in the returned list. Defaults to `#!luau false`. |

---

## Examples

### Example 1

```luau title="Function-only GC scan" linenums="1"
local dummy_table = {}
local function dummy_function() end
task.wait(0.05) -- Step a bit

for _, value in pairs(getgc()) do
    if value == dummy_function then
        print(`Found function: {dummy_function}`)
    elseif value == dummy_table then
        print(`Found table?: {dummy_table}`) -- This shouldn't print
    end
end
```

### Example 2

```luau title="Full GC scan including tables" linenums="1"
local dummy_table = {}
local function dummy_function() end
task.wait(0.05) -- Step a bit

for _, value in pairs(getgc(true)) do
    if value == dummy_function then
        print(`Found function: {dummy_function}`) -- Should print
    elseif value == dummy_table then
        print(`Found table: {dummy_table}`) -- Should also print
    end
end
```
