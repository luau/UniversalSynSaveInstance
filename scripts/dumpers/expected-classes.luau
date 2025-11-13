--!strict

--[=[
	@class ExpectedClasses

	Identifies properties expecting specific class types.

	Finds serializable properties with ValueType.Category == "Class"
	and ValueType.Name != "Instance". These properties expect specific
	class types during serialization.

	Output: Array of properties with class, property name, and expected type.
]=]

-- Imports
local Process = require("@lune/process")
local lib = require("../lib")

-- Type Definitions

--[=[
	@class Property
	Class-typed property information.
]=]
type Property = {
	class: string,
	property: string,
	expected: string,
}

-- Module Table
local ExpectedClasses = {}

-- Private Helpers

--[=[
	@private
	Checks if property expects a specific class type.

	Returns true for properties that:
	- Can be saved and loaded
	- Have Category "Class"
	- Expect something more specific than "Instance"

	@param valueType -- Value type info
	@param serialization -- Serialization info
	@return boolean -- True if expects specific class
]=]
local function expectsSpecificClass(valueType: lib.ValueType, serialization: lib.Serialization): boolean
	return serialization.CanLoad and serialization.CanSave and valueType.Category == "Class" and valueType.Name ~= "Instance"
end

--[=[
	@private
	Processes member for class type expectations.

	@param className -- Class name
	@param member -- Member to process
	@param props -- Properties list
]=]
local function processMember(className: string, member: lib.Member, props: { Property })
	-- Only process properties with value type and serialization info
	if member.MemberType ~= "Property" or not member.ValueType or not member.Serialization then
		return
	end

	if not expectsSpecificClass(member.ValueType, member.Serialization) then
		return
	end

	table.insert(props, {
		class = className,
		property = member.Name,
		expected = member.ValueType.Name,
	})
end

--[=[
	@private
	Collects class-typed properties from API dump.

	@param api -- API dump
	@return { Property } -- Property list sorted by class then property
]=]
local function collectProperties(api: lib.ApiDump): { Property }

	local props: { Property }
	local ok: boolean
	local err: any

	props = {}

	for _, class in api.Classes do
		for _, member in class.Members do
			ok, err = pcall(processMember, class.Name, member, props)
			if not ok then
				lib.warn(`Error processing {class.Name}.{member.Name}: {err}`)
			end
		end
	end

	-- Sort for deterministic output
	table.sort(props, function(a, b)
		if a.class == b.class then
			return a.property < b.property
		end
		return a.class < b.class
	end)

	return props
end

-- Public API

--[=[
	Runs expected classes analysis on API dump.

	@param hash -- Optional version hash
	@error Throws if analysis fails
]=]
function ExpectedClasses.run(hash: string?)

	local api: lib.ApiDump
	local props: { Property }

	api = lib.fetch(hash)
	props = collectProperties(api)

	lib.json("expected-classes", lib.output(hash, props))

	lib.success(#props, "class-typed properties")
end

-- Entry Point
lib.runCli(ExpectedClasses.run, Process.args)
