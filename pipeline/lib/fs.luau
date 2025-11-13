--!strict
--[=[
	@class Fs
	Filesystem operations.
]=]

local fs = require("@lune/fs")

local Fs = {}

function Fs.basename(path: string): string
	return path:match("^.+[\\/](.+)$") or path
end

function Fs.dirname(path: string): string
	return path:match("^(.+)[\\/][^\\/]+$") or "."
end

function Fs.ensureDir(path: string)
	if not fs.isDir(path) then
		fs.writeDir(path)
	end
end

function Fs.ensureParent(path: string)
	Fs.ensureDir(Fs.dirname(path))
end

function Fs.exists(path: string): boolean
	return fs.isFile(path) and pcall(fs.readFile, path)
end

function Fs.size(path: string): number?
	local meta = fs.metadata(path)
	return if meta.exists and meta.kind == "file" then meta.size else nil
end

function Fs.read(path: string): (string?, string?)
	if not fs.isFile(path) then
		return nil, `Not found: {path}`
	end

	local ok: boolean, result: string = pcall(fs.readFile, path)
	return if ok then result else nil, result
end

function Fs.write(path: string, content: string): (boolean, string?)
	local ok, err = pcall(function()
		Fs.ensureParent(path)
		fs.writeFile(path, content)
	end)
	return if ok then true else false, err
end

function Fs.remove(path: string): (boolean, string?)
	if not fs.isFile(path) then
		return true
	end

	local ok, err = pcall(fs.removeFile, path)
	return if ok then true else false, err
end

return Fs
