-- MIT License | Copyright (c) 2023-2025 Latte Softworks <https://latte.to>

local fs = require("@lune/fs")

--[[
    This kinda looks like a strange function, because of the format a "FileTree" accepts:

    ```lua
    EnsureFileTree({
        ["test"] = {
            ["test.txt"] = "hi",
            ["test.json"] = "[\"hi again\"]",
            ["another-sub-dir"] = {
                ["bye.txt"] = "bye"
            },
        },
        ["another-test"] = {
            ["another-example.txt"] = "real",
        },
    })
    ```
]]
local function EnsureFileTree(fileTree: { [string]: any }, _currentPath: string?)
	for FileName, Entry in fileTree do
		local RealPath = if _currentPath then `{_currentPath}/{FileName}` else FileName
		local EntryType = type(Entry)

		if EntryType == "table" then -- This is to be a directory
			if not fs.isDir(RealPath) then
				fs.writeDir(RealPath)
			end

			-- Recursively continue creating the file tree..
			EnsureFileTree(Entry, RealPath)
		elseif EntryType == "string" and not fs.isFile(RealPath) then -- This is to be a file
			fs.writeFile(RealPath, Entry)
		end
	end
end

return EnsureFileTree
