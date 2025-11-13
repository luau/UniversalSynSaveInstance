--!strict

--[=[
	@class NotCreatable

	Identifies classes marked NotCreatable.

	Filters out Services, Base classes, and common abstract patterns.
	These classes cannot be instantiated via Instance.new() but may appear
	in serialized data.

	Output: Array of classes with name, isService flag, and tags.
]=]

-- Imports
local Process = require("@lune/process")
local lib = require("../lib")

-- Type Definitions

--[=[
	@class ClassInfo
	NotCreatable class information.
]=]
type ClassInfo = {
	name: string,
	isService: boolean,
	tags: { string },
}

-- Module State

-- Exclusion patterns: common abstract/base class names to ignore
local EXCLUDE_PATTERNS = { "Base", "Page", "Plugin", "Setting" }

-- Module Table
local NotCreatable = {}

-- Private Helpers

--[=[
	@private
	Checks if class name contains an exclusion pattern.

	@param name -- Class name
	@return boolean -- True if excluded
]=]
local function matchesExclusionPattern(name: string): boolean
	for _, pattern in EXCLUDE_PATTERNS do
		if string.find(name, pattern) then
			return true
		end
	end
	return false
end

--[=[
	@private
	Checks if class should be included in output.

	@param tags -- Normalized class tags
	@param name -- Class name
	@return boolean -- True if should be included
]=]
local function shouldInclude(tags: { [string]: any }, name: string): boolean
	return tags.NotCreatable and not tags.Service and not matchesExclusionPattern(name)
end

--[=[
	@private
	Extracts tag names from normalized tag map.

	@param tags -- Normalized tag map
	@return { string } -- Sorted array of tag names
]=]
local function extractTagNames(tags: { [string]: any }): { string }
	local result = {}
	for tag, value in tags do
		if value == true then
			table.insert(result, tag)
		end
	end
	table.sort(result)
	return result
end

--[=[
	@private
	Collects NotCreatable classes from API dump.

	@param api -- API dump
	@return { ClassInfo } -- Class info list sorted by name
]=]
local function collectClasses(api: lib.ApiDump): { ClassInfo }
	local result: { ClassInfo } = {}

	for _, class in api.Classes do
		local ok, tags = pcall(lib.tags, class.Tags)
		if not ok then
			lib.warn(`Error processing {class.Name}: {tags}`)
			continue
		end

		if shouldInclude(tags, class.Name) then
			table.insert(result, {
				name = class.Name,
				isService = tags.Service == true,
				tags = extractTagNames(tags),
			})
		end
	end

	-- Sort for deterministic output
	table.sort(result, function(a, b)
		return a.name < b.name
	end)

	return result
end

-- Public API

--[=[
	Runs NotCreatable analysis on API dump.

	@param hash -- Optional version hash
	@error Throws if analysis fails
]=]
function NotCreatable.run(hash: string?)
	local api = lib.fetch(hash)
	local classes = collectClasses(api)

	lib.json("not-creatable", lib.output(hash, classes))

	lib.success(#classes, "NotCreatable classes")
end

-- Entry Point
lib.runCli(NotCreatable.run, Process.args)
