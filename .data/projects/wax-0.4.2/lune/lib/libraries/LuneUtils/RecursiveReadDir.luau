-- MIT License | Copyright (c) 2023-2025 Latte Softworks <https://latte.to>

local fs = require("@lune/fs")

local function RecursiveReadDir(directory: string, _existingFileList: { string }?): { string }
	if not string.match(directory, "[/\\]$") then
		directory ..= "/"
	end

	local FileList = _existingFileList or {}
	for _, EntryName in fs.readDir(directory) do
		if fs.isFile(EntryName) then
			table.insert(FileList, directory .. EntryName)
		else -- Is dir
			RecursiveReadDir(directory .. EntryName .. "/", FileList)
		end
	end

	return FileList
end

return RecursiveReadDir
