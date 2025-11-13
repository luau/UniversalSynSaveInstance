--!strict
--[=[
	@class Fs
	Filesystem operations for the build pipeline.

	Provides safe, pcall-wrapped file operations with consistent error handling.
	All write operations automatically create parent directories. Functions
	return tuples (value?, error?) for operations that can fail.
]=]

-- Imports
local fs = require("@lune/fs")

-- Module
local Fs = {}

--[=[
	Extracts the filename from a path.

	@param path File path
	@return Filename with extension
]=]
function Fs.basename(path: string): string
	return path:match("^.+[\\/](.+)$") or path
end

--[=[
	Extracts the directory from a path.

	@param path File path
	@return Directory path, or "." if no directory
]=]
function Fs.dirname(path: string): string
	return path:match("^(.+)[\\/][^\\/]+$") or "."
end

--[=[
	Creates a directory if it doesn't exist.

	@param path Directory path to create
]=]
function Fs.ensureDir(path: string)
	if not fs.isDir(path) then
		fs.writeDir(path)
	end
end

--[=[
	Creates parent directory for a file path.

	@param path File path whose parent should be created
]=]
function Fs.ensureParent(path: string)
	Fs.ensureDir(Fs.dirname(path))
end

--[=[
	Checks if a file exists and is readable.

	@param path File path to check
	@return True if file exists and can be read
]=]
function Fs.exists(path: string): boolean
	return fs.isFile(path) and pcall(fs.readFile, path)
end

--[=[
	Gets file size in bytes.

	@param path File path
	@return Size in bytes, or nil if not a file
]=]
function Fs.size(path: string): number?
	local meta = fs.metadata(path)
	return if meta.exists and meta.kind == "file" then meta.size else nil
end

--[=[
	Reads file contents safely.

	@param path File path to read
	@return Contents and nil, or nil and error message
]=]
function Fs.read(path: string): (string?, string?)
	if not fs.isFile(path) then
		return nil, `Not found: {path}`
	end

	local ok: boolean, result: string = pcall(fs.readFile, path)
	return if ok then result else nil, result
end

--[=[
	Writes content to a file safely.

	Creates parent directories automatically.

	@param path File path to write
	@param content Content to write
	@return True and nil on success, or false and error message
]=]
function Fs.write(path: string, content: string): (boolean, string?)
	local ok, err = pcall(function()
		Fs.ensureParent(path)
		fs.writeFile(path, content)
	end)
	return if ok then true else false, err
end

--[=[
	Removes a file safely.

	Returns success if file doesn't exist.

	@param path File path to remove
	@return True and nil on success, or false and error message
]=]
function Fs.remove(path: string): (boolean, string?)
	if not fs.isFile(path) then
		return true
	end

	local ok, err = pcall(fs.removeFile, path)
	return if ok then true else false, err
end

return Fs
