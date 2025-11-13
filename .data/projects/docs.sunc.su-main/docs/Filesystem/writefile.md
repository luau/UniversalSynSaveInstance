# `writefile`

`#!luau writefile` writes data to a file at the specified path. If the file already exists, its contents will be overwritten.

This is one of the primary ways to persist string data within the executor's file sandbox.

```luau
function writefile(path: string, data: string): ()
```

## Parameters

| Parameter        | Description                            |
|------------------|----------------------------------------|
| `#!luau path`    | The file path to write to.             |
| `#!luau data`    | The string data to write into the file.|

---

## Example

```luau title="Basic file writing example" linenums="1"
writefile("file.txt", "Hello world")
print(readfile("file.txt")) -- Output: Hello world
```
