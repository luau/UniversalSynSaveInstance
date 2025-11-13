# Table filter options

Table filters define what types of Luau tables should be returned when using [`#!luau filtergc`](./README.md) with `#!luau "table"` as the filter type.

Each key in the filter table specifies a condition the table must meet in order to be returned. You can use one or multiple fields together to narrow your results.

---

## Available Options

| Key                    | Type                     | Description                                                                           | Default      |
| ---------------------- | ------------------------ | ------------------------------------------------------------------------------------- | ------------ |
| `#!luau Keys`          | `#!luau { any }?`        | If provided, also includes tables that contain **all** the specified keys.            | `#!luau nil` |
| `#!luau Values`        | `#!luau { any }?`        | If provided, only includes tables that contain **all** the specified values.          | `#!luau nil` |
| `#!luau KeyValuePairs` | `#!luau { [any]: any }?` | If provided, only includes tables that contain **all** key-value pairs in this table. | `#!luau nil` |
| `#!luau Metatable`     | `#!luau table?`          | If provided, only includes tables whose metatable matches the given one.              | `#!luau nil` |

---

## Notes

- These filters work based on narrowing - the more information you provide in the filters, the more accurate the result.
- If `#!luau Metatable` is used, a raw metatable comparison is performed.

## Examples

!!! info "False negatives may occur"

    Executing these examples multiple times in a short period of time may result in false negatives.

### Matching by `#!luau Keys`

```luau title="Matching a table by key" linenums="1"
local dummy_table = { ["dummy_key"] = "" }

local retrieved = filtergc("table", {
    Keys = { "dummy_key" },
}, true)

print(retrieved == dummy_table) -- Output: true
```

### Matching by `#!luau KeyValuePairs`

```luau title="Matching a table by key-value pairs" linenums="1"
local dummy_table = { ["dummy_key"] = "dummy_value" }

local retrieved = filtergc("table", {
    KeyValuePairs = { ["dummy_key"] = "dummy_value" },
}, true)

print(retrieved == dummy_table) -- Output: true
```

### Matching by `#!luau Metatable`

```luau title="Matching a table by metatable" linenums="1"
local dummy_table = setmetatable({}, { __index = getgenv() })

local retrieved = filtergc("table", { 
    Metatable = getmetatable(dummy_table) 
}, true)

print(retrieved == dummy_table) -- Output: true
```

### Type signature for `TableFilterOptions`

```luau title="" linenums="1"
type TableFilterOptions = {
    Keys: { [any]: any }?,
    Values: { [any]: any }?,
    KeyValuePairs: { [any]: any }?,
    Metatable: { [any]: any }?,
}
```
