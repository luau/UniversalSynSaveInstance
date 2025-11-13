# `readfile`

`#!luau readfile` retrieves the contents of a file at the specified path and returns it as a string.

If the file does not exist or cannot be accessed, the function will **error**.

```luau
function readfile(path: string): string
```

## Parameters

| Parameter       | Description                          |
|------------------|--------------------------------------|
| `#!luau path`    | The file path to read from.          |

---

## Example

```luau title="Reading a file" linenums="1"
writefile("file0.txt", "Hello")
print(readfile("file0.txt")) -- Output: Hello
```
