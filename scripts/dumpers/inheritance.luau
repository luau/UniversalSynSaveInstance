--!strict

--[=[
	@class Inheritance

	Identifies classes outside Instance hierarchy.

	Finds special engine types that do not inherit from Instance.
	These are typically low-level engine classes or abstract base types.

	Output: Array of classes with name and optional superclass.
]=]

-- Imports
local Process = require("@lune/process")
local lib = require("../lib")

-- Type Definitions

--[=[
	@class ClassInfo
	Information about non-Instance class.
]=]
type ClassInfo = {
	name: string,
	superclass: string?,
}

-- Module Table
local Inheritance = {}

-- Private Helpers

--[=[
	@private
	Checks if class inherits from Instance.

	@param name -- Class name
	@param map -- Class lookup map
	@return boolean -- True if inherits from Instance
]=]
local function inheritsFromInstance(name: string, map: lib.ClassMap): boolean
	return lib.inherits(name, "Instance", map)
end

--[=[
	@private
	Collects non-Instance classes from API dump.

	@param api -- API dump
	@return { ClassInfo } -- Non-Instance classes sorted by name
]=]
local function collectClasses(api: lib.ApiDump): { ClassInfo }

	local map: lib.ClassMap
	local result: { ClassInfo }
	local ok: boolean
	local doesInherit: any

	map = lib.classes(api.Classes)
	result = {}

	for _, class in api.Classes do
		ok, doesInherit = pcall(inheritsFromInstance, class.Name, map)
		if not ok then
			lib.warn(`Error checking {class.Name}: {doesInherit}`)
			continue
		end

		if not doesInherit then
			table.insert(result, {
				name = class.Name,
				superclass = class.Superclass,
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
	Runs inheritance analysis on API dump.

	@param hash -- Optional version hash
	@error Throws if analysis fails
]=]
function Inheritance.run(hash: string?)

	local api: lib.ApiDump
	local classes: { ClassInfo }

	api = lib.fetch(hash)
	classes = collectClasses(api)

	lib.json("inheritance", lib.output(hash, classes))

	lib.success(#classes, "non-Instance classes")
end

-- Entry Point
lib.runCli(Inheritance.run, Process.args)
