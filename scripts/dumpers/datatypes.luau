--!strict

--[=[
	@class Datatypes

	Analyzes data type serialization capabilities.

	Identifies types with custom descriptors via asymmetric serialization
	(CanSave but not CanLoad, or vice versa). Excludes Enum and Class categories.

	Output: Array of types with serialization flags and hasDescriptor indicator.
]=]

-- Imports
local Process = require("@lune/process")
local lib = require("../lib")

-- Type Definitions

-- Maps type names to their serialization capability (true/false)
type SerializationFlags = { [string]: boolean }

--[=[
	@class TypeInfo
	Serialization capabilities for a data type.
]=]
type TypeInfo = {
	name: string,
	canSave: boolean,
	canLoad: boolean,
	hasDescriptor: boolean,
}

-- Module Table
local Datatypes = {}

-- Private Helpers

--[=[
	@private
	Checks if value type category should be excluded from analysis.

	@param category -- Value type category
	@return boolean -- True if excluded
]=]
local function shouldExclude(category: string): boolean
	return category == "Enum" or category == "Class"
end

--[=[
	@private
	Tracks serialization capability for a type.

	Updates the save/load flag maps. If a type has any member that
	can save, the type is marked as saveable. Same for load.

	@param typeName -- Type name
	@param serialization -- Serialization info
	@param save -- Save flags tracker
	@param load -- Load flags tracker
]=]
local function trackCapability(
	typeName: string,
	serialization: lib.Serialization,
	save: SerializationFlags,
	load: SerializationFlags
)
	if serialization.CanSave then
		save[typeName] = true
	elseif save[typeName] == nil then
		save[typeName] = false
	end

	if serialization.CanLoad then
		load[typeName] = true
	elseif load[typeName] == nil then
		load[typeName] = false
	end
end

--[=[
	@private
	Processes member to extract type serialization info.

	@param member -- Member to process
	@param save -- Save flags tracker
	@param load -- Load flags tracker
	@param seen -- Seen types tracker
	@param types -- Types list
]=]
local function processMember(
	member: lib.Member,
	save: SerializationFlags,
	load: SerializationFlags,
	seen: { [string]: true },
	types: { string }
)
	local valueType: lib.ValueType
	local typeName: string

	-- Only process properties with serialization info
	if member.MemberType ~= "Property" or not member.ValueType or not member.Serialization then
		return
	end

	valueType = member.ValueType
	if shouldExclude(valueType.Category) then
		return
	end

	typeName = valueType.Name
	trackCapability(typeName, member.Serialization, save, load)

	-- Track unique types
	if not seen[typeName] then
		seen[typeName] = true
		table.insert(types, typeName)
	end
end

--[=[
	@private
	Collects all data types from API dump.

	@param api -- API dump
	@return { string } -- Type names
	@return SerializationFlags -- Save flags
	@return SerializationFlags -- Load flags
]=]
local function collectTypes(api: lib.ApiDump): ({ string }, SerializationFlags, SerializationFlags)
	local types: { string }
	local seen: { [string]: true }
	local save: SerializationFlags
	local load: SerializationFlags
	local ok: boolean
	local err: any

	types = {}
	seen = {}
	save = {}
	load = {}

	for _, class in api.Classes do
		for _, member in class.Members do
			ok, err = pcall(processMember, member, save, load, seen, types)
			if not ok then
				lib.warn(`Error processing {class.Name}.{member.Name}: {err}`)
			end
		end
	end

	return types, save, load
end

--[=[
	@private
	Builds structured type info list from collected data.

	@param types -- Type names
	@param save -- Save flags
	@param load -- Load flags
	@return { TypeInfo } -- Structured type info
]=]
local function buildTypeInfo(types: { string }, save: SerializationFlags, load: SerializationFlags): { TypeInfo }
	local result: { TypeInfo }
	local hasSave: boolean
	local hasLoad: boolean

	-- Sort for deterministic output
	table.sort(types)

	result = {}
	for _, typeName in types do
		hasSave = save[typeName] == true
		hasLoad = load[typeName] == true

		table.insert(result, {
			name = typeName,
			canSave = hasSave,
			canLoad = hasLoad,
			hasDescriptor = hasSave ~= hasLoad,
		})
	end

	return result
end

-- Public API

--[=[
	Runs datatype analysis on API dump.

	@param hash -- Optional version hash
	@error Throws if analysis fails
]=]
function Datatypes.run(hash: string?)
	local api: lib.ApiDump
	local types: { string }
	local save: SerializationFlags
	local load: SerializationFlags
	local data: { TypeInfo }

	api = lib.fetch(hash)
	types, save, load = collectTypes(api)
	data = buildTypeInfo(types, save, load)

	lib.json("datatypes", lib.output(hash, data))

	lib.success(#data, "data types")
end

-- Entry Point
lib.runCli(Datatypes.run, Process.args)
