# `listfiles`

!!! info "Relative Paths"

    Please note that paths returned by `#!luau listfiles` are relative to the workspace folder of the executor.

`#!luau listfiles` returns an array of strings representing all files and folders within the specified directory.

This can be used to dynamically check which files exist in a folder, etc.

```luau
function listfiles(path: string): { string }
```

## Parameters

| Parameter       | Description                          |
|------------------|--------------------------------------|
| `#!luau path`    | The path to the directory to scan.   |

---

## Example

```luau title="Listing files in the root directory" linenums="1"
writefile("file1.txt", "")
writefile("file2.lua", "")
task.wait()

for _, file in listfiles("") do
    if file == "file1.txt" then
        print(`Found: {file}`) -- Output: Found: file1.txt
    end
    if file == "file2.lua" then
        print(`Found: {file}`) -- Output: Found: file2.lua
    end
end
```
