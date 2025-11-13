# `lz4compress`

`#!luau lz4compress` compresses a string with the [LZ4](https://en.wikipedia.org/wiki/LZ4_(compression_algorithm)) compression algorithm.

```luau
function lz4compress(data: string): string
```

## Parameters

| Parameter     | Description             |
| ------------- | ----------------------- |
| `#!luau data` | The string to compress. |

---

## Example

```luau title="Compressing a string with the LZ4 compression algorithm" linenums="1"
local text = "Hello, world! Hello, world! Goodbye, world!"
print(#text) -- 43
print(#lz4compress(text)) -- 34
```
