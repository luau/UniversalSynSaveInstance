--!strict

--[=[
	@class Lib

	Shared utilities for API dump analysis.

	Provides:
	- API dump fetching and caching from Roblox CDN
	- Tag normalization for consistent access
	- File I/O with error handling
	- Standardized output formatting
	- Logging and CLI utilities
	- Class inheritance checking
]=]

-- Imports
local fs = require("@lune/fs")
local net = require("@lune/net")
local serde = require("@lune/serde")
local stdio = require("@lune/stdio")

-- Type Definitions

--[=[
	@class Class
	Represents a class from the API dump.
]=]
export type Class = {
	Name: string,
	Superclass: string?,
	Tags: { [string]: any }?,
	Members: { Member },
}

--[=[
	@class ClassMap
	Dictionary of classes by name for O(1) lookup.
]=]
export type ClassMap = { [string]: Class }

--[=[
	@class Member
	Represents a class member (property, method, event, etc.).
]=]
export type Member = {
	Name: string,
	MemberType: string,
	ValueType: ValueType?,
	Serialization: Serialization?,
	Tags: { [string]: any }?,
	Default: string?,
}

--[=[
	@class ValueType
	Describes property value type.
]=]
export type ValueType = {
	Name: string,
	Category: "Primitive" | "DataType" | "Enum" | "Class",
}

--[=[
	@class Serialization
	Describes serialization capabilities.
]=]
export type Serialization = {
	CanLoad: boolean,
	CanSave: boolean,
}

--[=[
	@class ApiDump
	Root structure of API dump from Roblox CDN.
]=]
export type ApiDump = {
	Classes: { Class },
}

--[=[
	@class StandardOutput
	Standard dumper output format.

	Consistent schema across all dumpers:
	- count: Total number of items in data array
	- metadata: { version: string, timestamp: string }
	- data: Array of result items (always an array, never nested objects)
	- breakdown: Optional categorization counts (when data has 'type' field)

	Benefits:
	- Uniform iteration: consumers can always loop over data[]
	- Type discrimination: use 'type' field when mixing categories
	- Deterministic: data is always sorted for stable diffs
	- Simple: no nested groupings or multiple top-level keys
]=]
export type StandardOutput = {
	count: number,
	metadata: {
		version: string,
		timestamp: string,
	},
	data: { any },
	breakdown: { [string]: number }?,
}

-- Module State

-- Cache for fetched API dumps by hash to avoid redundant network requests
local fetchCache: { [string]: ApiDump } = {}

local Lib = {}

-- Private Helpers

--[=[
	@private
	Prints dimmed text to stdout.

	@param text -- Text to print
]=]
local function dim(text: string)
	stdio.write(stdio.style("dim"))
	print(text)
	stdio.write(stdio.style("reset"))
end

--[=[
	@private
	Fetches specific API dump version from Roblox CDN.

	@param hash -- Version hash
	@return ApiDump? -- API dump if successful
	@return boolean -- Success status
]=]
local function tryVersion(hash: string): (ApiDump?, boolean)
	local url = `https://setup.rbxcdn.com/{hash}-Full-API-Dump.json`

	local ok, response = pcall(net.request, url)
	if not ok then
		return nil, false
	end

	if not response.ok then
		return nil, false
	end

	local decodeOk, decoded = pcall(serde.decode, "json", response.body)
	if not decodeOk then
		return nil, false
	end

	dim(`Fetched {hash}`)
	return decoded, true
end

--[=[
	@private
	Finds latest API dump version from deployment history.

	@return ApiDump -- Latest API dump
	@error Throws if no valid dump found
]=]
local function findLatest(): ApiDump
	local ok, response = pcall(net.request, "https://setup.rbxcdn.com/DeployHistory.txt")
	if not ok then
		error("Failed to fetch deployment history")
	end

	local history = response.body

	for line in string.gmatch(history, "[^\r\n]+") do
		local hash = string.match(line, "(version%-[^%s]+)")
		if hash then
			local api, success = tryVersion(hash)
			if success and api then
				return api
			end
		end
	end

	error("Failed to fetch any valid API dump")
end

-- Public API

--[=[
	Fetches API dump from Roblox CDN.
	Results are memoized to avoid redundant downloads within a single run.

	@param hash -- Optional version hash (defaults to latest)
	@return ApiDump -- Parsed API dump
	@error Throws if fetch fails
]=]
function Lib.fetch(hash: string?): ApiDump
	local cacheKey = hash or "latest"

	-- Return cached result if available
	if fetchCache[cacheKey] then
		return fetchCache[cacheKey]
	end

	local api: ApiDump
	if hash then
		local ok
		api, ok = tryVersion(hash)
		if not ok or not api then
			error(`Failed to fetch version {hash}`)
		end
	else
		api = findLatest()
	end

	-- Cache the result
	fetchCache[cacheKey] = api
	return api
end

--[=[
	Normalizes tags into consistent dictionary format.

	Tags from API dumps can be arrays of strings or objects.
	This converts them to dictionaries for easy lookup.

	@param raw -- Raw tags from API dump
	@return { [string]: any } -- Normalized tag dictionary
]=]
function Lib.tags(raw: { any }?): { [string]: any }
	if not raw then
		return {}
	end

	local result = {}

	for key, value in raw do
		if type(key) == "number" then
			-- Array-style tag
			if type(value) == "string" then
				result[value] = true
			elseif type(value) == "table" then
				-- Nested table of tags
				for k, v in value do
					result[k] = v
				end
			end
		else
			-- Object-style tag
			result[key] = value
		end
	end

	return result
end

--[=[
	Writes output file to dumps directory.

	Creates the directory if it doesn't exist.

	@param name -- Filename (including extension)
	@param content -- File content
	@error Throws if write fails
]=]
function Lib.write(name: string, content: string)
	local dir = "scripts/dumps"

	local ok, err = pcall(function()
		if not fs.isDir(dir) then
			fs.writeDir(dir)
		end
	end)

	if not ok then
		error(`Failed to create directory {dir}: {err}`)
	end

	local path = `{dir}/{name}`
	local writeOk, writeErr = pcall(fs.writeFile, path, content)

	if not writeOk then
		error(`Failed to write file {path}: {writeErr}`)
	end

	stdio.write(stdio.color("green"))
	stdio.write("+ ")
	stdio.write(stdio.color("reset"))
	print(path)
end

--[=[
	Creates standardized metadata for output files.

	@param hash -- Optional version hash (defaults to "latest")
	@return { version: string, timestamp: string } -- Metadata object
]=]
function Lib.metadata(hash: string?): { version: string, timestamp: string }
	return {
		version = hash or "latest",
		timestamp = os.date("%Y-%m-%dT%H:%M:%S"),
	}
end

--[=[
	Creates a StandardOutput structure.

	@param hash -- Optional version hash
	@param data -- Data array (must be pre-sorted)
	@param breakdown -- Optional breakdown counts by type
	@return StandardOutput -- Standardized output object
]=]
function Lib.output(hash: string?, data: { any }, breakdown: { [string]: number }?): StandardOutput
	return {
		count = #data,
		metadata = Lib.metadata(hash),
		data = data,
		breakdown = breakdown,
	}
end

--[=[
	Prints success message with count.

	@param count -- Primary count
	@param label -- Count label
	@param secondary -- Optional secondary info
]=]
function Lib.success(count: number, label: string, secondary: string?)
	stdio.write(stdio.color("green"))
	stdio.write("> ")
	stdio.write(stdio.color("reset"))

	if secondary then
		print(`{count} {label} ({secondary})`)
	else
		print(`{count} {label}`)
	end
end

--[=[
	Serializes data to JSON and writes to dumps directory.

	If hash is present in data.metadata.version and not "latest",
	it's included in the filename to prevent overwriting.

	@param name -- Base filename without extension
	@param data -- Data to serialize (should be StandardOutput)
	@error Throws if serialization or write fails
]=]
function Lib.json(name: string, data: any)
	local encoded = serde.encode("json", data, true)

	-- Include hash in filename if available
	local filename = name
	if data.metadata and data.metadata.version and data.metadata.version ~= "latest" then
		filename = `{name}-{data.metadata.version}`
	end

	Lib.write(`{filename}.json`, encoded)
end

--[=[
	Logs an error message with consistent formatting.

	@param message -- Error message
]=]
function Lib.error(message: string)
	stdio.write(stdio.color("red"))
	stdio.write("x ")
	stdio.write(stdio.color("reset"))
	stdio.ewrite(`{message}\n`)
end

--[=[
	Logs a warning message with consistent formatting.

	@param message -- Warning message
]=]
function Lib.warn(message: string)
	stdio.write(stdio.color("yellow"))
	stdio.write("! ")
	stdio.write(stdio.color("reset"))
	print(message)
end

--[=[
	Logs an info message with consistent formatting.

	@param message -- Info message
]=]
function Lib.info(message: string)
	stdio.write(stdio.color("blue"))
	stdio.write("i ")
	stdio.write(stdio.color("reset"))
	print(message)
end

--[=[
	Checks if class inherits from base class.

	Walks the inheritance chain to determine relationship.

	@param name -- Class name to check
	@param base -- Base class name
	@param map -- Class lookup map
	@return boolean -- True if class inherits from base
]=]
function Lib.inherits(name: string, base: string, map: ClassMap): boolean
	local current = map[name]

	while current do
		if current.Name == base then
			return true
		end

		if not current.Superclass then
			return false
		end

		current = map[current.Superclass]
	end

	return false
end

--[=[
	Builds class name lookup map from array.

	Converts array to dictionary for O(1) lookups.

	@param list -- Array of classes
	@return ClassMap -- Class lookup map
]=]
function Lib.classes(list: { Class }): ClassMap
	local result = {}
	for _, class in list do
		result[class.Name] = class
	end
	return result
end

--[=[
	Runs a dumper script with standardized error handling.

	Provides consistent CLI entrypoint behavior:
	- Parses Process.args for optional hash
	- Catches errors and formats as red "Fatal" message
	- Exits with code 1 on failure

	@param fn -- Function to run (receives hash parameter)
	@param args -- Process arguments array
	@error Exits with code 1 on failure
]=]
function Lib.runCli(fn: (string?) -> (), args: { string })
	local hash = args[1]

	local ok, err = pcall(fn, hash)
	if not ok then
		Lib.error(`Fatal: {err}`)
		local Process = require("@lune/process")
		Process.exit(1)
	end
end

return Lib
