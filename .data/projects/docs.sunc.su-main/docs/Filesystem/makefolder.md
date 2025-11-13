# `makefolder`

`#!luau makefolder` creates a folder at the specified path if one does not already exist.

This is useful for organising files into separate directories.

```luau
function makefolder(path: string): ()
```

## Parameters

| Parameter       | Description                          |
|------------------|--------------------------------------|
| `#!luau path`    | The folder path to create.           |

---

## Example

```luau title="Creating a new folder" linenums="1"
makefolder("test_folder")
print(isfolder("test_folder")) -- Output: true
```
