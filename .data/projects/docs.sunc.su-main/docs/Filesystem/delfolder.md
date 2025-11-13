# `delfolder`

`#!luau delfolder` deletes the folder at the specified path if it exists.

```luau
function delfolder(path: string): ()
```

## Parameters

| Parameter       | Description                         |
|------------------|-------------------------------------|
| `#!luau path`    | The path of the folder to delete.   |

---

## Example

```luau title="Deleting a folder" linenums="1"
makefolder("folder3")
print(isfolder("folder3")) -- Output: true
delfolder("folder3")
print(isfolder("folder3")) -- Output: false
```
