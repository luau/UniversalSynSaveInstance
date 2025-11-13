# `appendfile`

`#!luau appendfile` appends string content to the end of a file at the specified path. If the file does not exist, it will be created.

This is useful for logging, accumulating data over time, or extending file contents without overwriting them.

```luau
function appendfile(path: string, contents: string): ()
```

## Parameters

| Parameter          | Description                             |
|--------------------|-----------------------------------------|
| `#!luau path`      | The file path to append to.             |
| `#!luau contents`  | The string content to add to the file.  |

---

## Example

```luau title="Appending to a file" linenums="1"
writefile("file4.txt", "print(")
appendfile("file4.txt", "'Hello')")
print(readfile("file4.txt")) -- Output: print('Hello')
```
