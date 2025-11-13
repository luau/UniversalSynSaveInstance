# `isfolder`

`#!luau isfolder` checks whether a given path exists and refers to a folder.

This is useful when verifying that a directory exists before writing files into it or listing its contents.

```luau
function isfolder(path: string): boolean
```

## Parameters

| Parameter       | Description                      |
|------------------|----------------------------------|
| `#!luau path`    | The path to check.               |

---

## Example

```luau title="Checking folder existence" linenums="1"
writefile("file7.txt", "")
makefolder("folder2")
print(isfolder("file7.txt")) -- Output: false
print(isfolder("folder2"))   -- Output: true
```
