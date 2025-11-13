# `delfile`

`#!luau delfile` deletes the file at the specified path if it exists.

This is useful for cleaning up temporary data or removing no-longer-needed files at runtime.

```luau
function delfile(path: string): ()
```

## Parameters

| Parameter       | Description                |
|------------------|----------------------------|
| `#!luau path`    | The path of the file to delete. |

---

## Example

```luau title="Deleting a file" linenums="1"
writefile("file5.txt", "Hello")
print(isfile("file5.txt")) -- Output: true
delfile("file5.txt")
print(isfile("file5.txt")) -- Output: false
```
