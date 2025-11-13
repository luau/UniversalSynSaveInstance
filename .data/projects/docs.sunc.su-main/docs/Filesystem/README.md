# Filesystem

The **Filesystem** library provides access to an executor's virtual file system. It enables reading, writing, creating, and deleting files and folders, as well as utility functions for interacting with content assets.

This library is especially useful when storing persistent data, managing resources across sessions, or loading runtime content dynamically.

---

## What can you do?

With the Filesystem library, you can:

- **Write** data to a file using [`#!luau writefile`](./writefile.md)
- **Read** file contents with [`#!luau readfile`](./readfile.md)
- **Append** content using [`#!luau appendfile`](./appendfile.md)
- **List** files and folders via [`#!luau listfiles`](./listfiles.md)
- **Delete** files with [`#!luau delfile`](./delfile.md) and folders using [`#!luau delfolder`](./delfolder.md)
- **Check** if a path is a file or folder using [`#!luau isfile`](./isfile.md) or [`#!luau isfolder`](./isfolder.md)
- **Create** folders with [`#!luau makefolder`](./makefolder.md)
- **Dynamically load** code from a file via [`#!luau loadfile`](./loadfile.md)
- **Use** local assets in Roblox via [`#!luau getcustomasset`](./getcustomasset.md), as if it were an uploaded asset

---

## What can't you do?

- You cannot access files outside the executor's workspace/sandboxed storage
- You cannot use file IO to interact with the real disk (e.g. `C:/` (Windows), `/Library` (macOS), etc.)
- You cannot escape the executor's `workspace` folder at all.
