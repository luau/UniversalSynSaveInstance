# `isfile`

`#!luau isfile` checks whether a given path exists and refers to a file.

This function is useful when validating input, confirming file existence before reading, or filtering entries returned by [`#!luau listfiles`](./listfiles.md).

```luau
function isfile(path: string): boolean
```

## Parameters

| Parameter       | Description                      |
|------------------|----------------------------------|
| `#!luau path`    | The path to check.               |

---

## Example

```luau title="Checking file existence" linenums="1"
print(isfile("nonexistent.txt")) -- Output: false
writefile("file3.txt", "")
print(isfile("file3.txt")) -- Output: true
```
