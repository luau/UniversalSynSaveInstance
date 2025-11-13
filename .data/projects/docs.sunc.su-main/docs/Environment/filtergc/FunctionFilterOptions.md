# Function filter options

Function filters let you refine what types of Luau functions should be returned when using [`#!luau filtergc`](./README.md) with `#!luau "function"` as the filter type.

Each key in the filter table specifies a criterion that must be matched by the function for it to be returned. You can use one or multiple fields together to narrow your results.

---

## Available options

| Key                     | Type              | Description                                                                                             | Default       |
| ----------------------- | ----------------- | ------------------------------------------------------------------------------------------------------- | ------------- |
| `#!luau Name`           | `#!luau string?`  | If provided, filters out functions which don't match this name.                                         | `#!luau nil`  |
| `#!luau IgnoreExecutor` | `#!luau boolean?` | If `true`, filters out functions that were created inside the executor.                                 | `#!luau true` |
| `#!luau Hash`           | `#!luau string?`  | Filters by the hash of the function. See [`#!luau getfunctionhash`](../../Closures/getfunctionhash.md). | `#!luau nil`  |
| `#!luau Constants`      | `#!luau { any }?` | Also includes functions that contain the matching constants in the provided list.                       | `#!luau nil`  |
| `#!luau Upvalues`       | `#!luau { any }?` | Also includes functions that contain the matching upvalues in the provided list.                        | `#!luau nil`  |

---

## Notes

- These filters work based on narrowing - the more information you provide in the filters, the more accurate the final result.
- If `#!luau IgnoreExecutor` is not explicitly set to `#!luau false`, executor-created functions are skipped by default.
- Filters like `#!luau Constants`, `#!luau Upvalues`, and `#!luau Hash` do not apply to C closures.

---

## Examples

!!! info "False negatives may occur"

    Executing these examples multiple times in a short period of time may result in false negatives.

### Using `#!luau Name` (returns a `#!luau table` by default)

```luau title="Matching a function by name" linenums="1"
local function dummy_function() end

local retrieved = filtergc("function", {
    Name = "dummy_function", 
    IgnoreExecutor = false
})

print(typeof(retrieved)) -- Output: table
print(retrieved[1] == dummy_function) -- Output: true
```

---

### Using `#!luau Name` with `#!luau returnOne = true`

```luau title="Single match using returnOne" linenums="1"
local function dummy_function() 
end

local retrieved = filtergc("function", {
    Name = "dummy_function", 
    IgnoreExecutor = false
}, true)

print(typeof(retrieved)) -- Output: function
print(retrieved == dummy_function) -- Output: true
```

---

### Using `#!luau Hash`

```luau title="Matching a function by hash" linenums="1"
local function dummy_function()
    return "Hello"
end

local dummy_function_hash = getfunctionhash(dummy_function)

local retrieved = filtergc("function", {
    Hash = dummy_function_hash,
    IgnoreExecutor = false
}, true)

print(getfunctionhash(retrieved) == dummy_function_hash) -- Output: true
print(retrieved == dummy_function) -- Output: true
```

### Matching by `#!luau Constants` and `#!luau Upvalues`

```luau title="Matching by function constants and upvalues" linenums="1"
local upvalue = 5

local function dummy_function()
    upvalue += 1
    print(game.Players.LocalPlayer)
end

local retrieved = filtergc("function", {
    Constants = { "print", "game", "Players", "LocalPlayer", 1 },
    Upvalues = { 5 },
    IgnoreExecutor = false
}, true)

print(retrieved == dummy_function) -- Output: true
```

### Type signature for `FunctionFilterOptions`

```luau title="" linenums="1"
type FunctionFilterOptions = {
    Name: string?,
    IgnoreExecutor: boolean?,
    Hash: string?,
    Constants: { string }?,
    Upvalues: { any }?
}
```
