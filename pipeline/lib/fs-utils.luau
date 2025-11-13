--!strict
--[=[
	@class FsUtils
	Filesystem utilities for the build pipeline.

	Provides enhanced filesystem operations with error handling, validation,
	and build-specific helpers like basename extraction, directory creation,
	and file timestamp comparison for incremental builds.

	@usage
	```lua
	local FsUtils = require("./lib/fs-utils")
	local basename = FsUtils.getBaseName("/path/to/file.luau")
	local needsUpdate = FsUtils.needsRebuild(sources, outputPath)
	```
]=]

-- Imports
local fs = require("@lune/fs")

-- Module
local FsUtils = {}

--[=[
	Extracts the base filename from a file path.

	Handles both forward and back slashes for cross-platform compatibility.

	@param path File path with optional directory components
	@return Base filename without directory prefix
]=]
function FsUtils.getBaseName(path: string): string
	return path:match("^.+[\\/](.+)$") or path
end

--[=[
	Gets the directory portion of a file path.

	@param path File path
	@return Directory path, or "." if no directory component exists
]=]
function FsUtils.getDirName(path: string): string
	return path:match("^(.+)[\\/][^\\/]+$") or "."
end

--[=[
	Ensures a directory exists, creating it if necessary.

	@param path Directory path to create
	@return True if directory exists or was created
	@error Throws if directory creation fails
]=]
function FsUtils.ensureDir(path: string): boolean
	if fs.isDir(path) then
		return true
	end

	fs.writeDir(path)
	return fs.isDir(path)
end

--[=[
	Ensures the parent directory of a file path exists.

	Extracts directory from file path and creates it if needed.

	@param filePath File path whose parent should exist
	@return True if parent directory exists or was created
]=]
function FsUtils.ensureParentDir(filePath: string): boolean
	return FsUtils.ensureDir(FsUtils.getDirName(filePath))
end

--[=[
	Checks if a file needs rebuilding based on source timestamps.

	Returns true if target doesn't exist or any source is newer than target.

	@param sources List of source file paths to check
	@param target Target output file path
	@return True if rebuild needed, false if target is current
	@error Throws if any source file doesn't exist
]=]
function FsUtils.needsRebuild(sources: { string }, target: string): boolean
	local targetMeta = fs.metadata(target)
	if not targetMeta.exists then
		return true
	end

	local targetTime: number = targetMeta.modifiedAt.unixTimestamp

	for _, source in sources do
		local sourceMeta = fs.metadata(source)
		if not sourceMeta.exists then
			error(`Source missing: {source}`)
		end

		if sourceMeta.modifiedAt.unixTimestamp > targetTime then
			return true
		end
	end

	return false
end

--[=[
	Gets the size of a file in bytes.

	@param path File path to measure
	@return File size in bytes, or nil if not a file
]=]
function FsUtils.getFileSize(path: string): number?
	local meta = fs.metadata(path)
	if not meta.exists or meta.kind ~= "file" then
		return nil
	end
	return meta.size
end

--[=[
	Checks if a file exists and is readable.

	Tests actual readability by attempting to read the file.

	@param path File path to check
	@return True if file exists and can be read
]=]
function FsUtils.isReadableFile(path: string): boolean
	if not fs.isFile(path) then
		return false
	end

	return pcall(fs.readFile, path)
end

--[=[
	Reads a file with error handling.

	@param path The file path to read
	@return File contents as string, or nil and error message on failure
]=]
function FsUtils.safeReadFile(path: string): (string?, string?)
	if not fs.isFile(path) then
		return nil, `File does not exist: {path}`
	end

	local success: boolean, result: string = pcall(fs.readFile, path)
	if not success then
		return nil, `Failed to read file: {result}`
	end

	return result, nil
end

--[=[
	Writes a file with error handling and automatic parent directory creation.

	@param path The file path to write
	@param contents The contents to write
	@return True on success, or false and error message on failure
]=]
function FsUtils.safeWriteFile(path: string, contents: string): (boolean, string?)
	local success: boolean, err: string? = pcall(function()
		FsUtils.ensureParentDir(path)
		fs.writeFile(path, contents)
	end)

	if not success then
		return false, `Failed to write file: {err}`
	end

	return true, nil
end

--[=[
	Copies a file from source to destination with error handling.

	@param source The source file path
	@param destination The destination file path
	@param overwrite Whether to overwrite existing files (default: true)
	@return True on success, or false and error message on failure
]=]
function FsUtils.safeCopyFile(source: string, destination: string, overwrite: boolean?): (boolean, string?)
	if not fs.isFile(source) then
		return false, `Source file does not exist: {source}`
	end

	local shouldOverwrite: boolean = if overwrite ~= nil then overwrite else true

	local success: boolean, err: string? = pcall(function()
		FsUtils.ensureParentDir(destination)
		fs.copy(source, destination, { overwrite = shouldOverwrite })
	end)

	if not success then
		return false, `Failed to copy file: {err}`
	end

	return true, nil
end

--[=[
	Removes a file with error handling.

	@param path The file path to remove
	@return True on success, or false and error message on failure
]=]
function FsUtils.safeRemoveFile(path: string): (boolean, string?)
	if not fs.isFile(path) then
		return true, nil -- Already doesn't exist
	end

	local success: boolean, err: string? = pcall(fs.removeFile, path)
	if not success then
		return false, `Failed to remove file: {err}`
	end

	return true, nil
end

--[=[
	Lists all files in a directory recursively.

	@param path The directory path
	@param pattern Optional pattern to filter files (Lua pattern)
	@return List of file paths relative to the input directory
]=]
function FsUtils.listFilesRecursive(path: string, pattern: string?): { string }
	local files: { string } = {}

	local function scan(dir: string, prefix: string)
		if not fs.isDir(dir) then
			return
		end

		for _, entry in fs.readDir(dir) do
			local fullPath: string = `{dir}/{entry}`
			local relativePath: string = if prefix == "" then entry else `{prefix}/{entry}`

			if fs.isDir(fullPath) then
				scan(fullPath, relativePath)
			elseif fs.isFile(fullPath) then
				if pattern then
					if relativePath:match(pattern) then
						table.insert(files, relativePath)
					end
				else
					table.insert(files, relativePath)
				end
			end
		end
	end

	scan(path, "")
	return files
end

return FsUtils
