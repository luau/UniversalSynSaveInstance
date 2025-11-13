# `lz4decompress`

`#!luau lz4decompress` decompresses a string that was encoded using the [LZ4](https://en.wikipedia.org/wiki/LZ4_(compression_algorithm)) compression algorithm back to regular data.

```luau
function lz4decompress(data: string): string
```

## Parameters

| Parameter     | Description               |
| ------------- | ------------------------- |
| `#!luau data` | The string to decompress. |

---

## Example

```luau title="Decompressing an LZ4 encoded string back to regular data" linenums="1"
local text = "Hello, world! Hello, world!"
local compressed = lz4compress(text)
print(lz4decompress(compressed, #text)) -- "Hello, world! Hello, world!"
```
