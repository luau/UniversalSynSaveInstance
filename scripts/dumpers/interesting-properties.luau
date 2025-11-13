--!strict

--[=[
	@class InterestingProperties

	Identifies properties with unusual serialization behaviors.

	Detects:
	- Asymmetric serialization (CanLoad only, CanSave only)
	- Deprecated but saveable properties
	- NotCreatable classes with non-placeholder defaults

	Output: Array with type="asymmetric" or type="notCreatableDefault".
]=]

-- Imports
local Process = require("@lune/process")
local lib = require("../lib")

-- Type Definitions

--[=[
	@class PropertyData
	Property serialization data for internal processing.
]=]
type PropertyData = {
	serialization: lib.Serialization,
	tags: { [string]: any },
	default: string?,
}

--[=[
	@class AsymmetricProperty
	Property with asymmetric serialization.
]=]
type AsymmetricProperty = {
	type: "asymmetric",
	class: string,
	property: string,
	reason: string,
	canSave: boolean?,
	canLoad: boolean?,
	deprecated: boolean?,
}

--[=[
	@class NotCreatableDefault
	NotCreatable class with non-placeholder default value.
]=]
type NotCreatableDefault = {
	type: "notCreatableDefault",
	class: string,
	property: string,
	default: string,
}

-- Type union for combined output
type Property = AsymmetricProperty | NotCreatableDefault

-- Module State

-- Sentinel patterns that indicate placeholder/unavailable defaults
local PLACEHOLDER_PATTERNS = {
	"__api_dump_class_not_creatable__",
	"__api_dump_",
}

-- Module Table
local InterestingProperties = {}

-- Private Helpers

--[=[
	@private
	Checks if default value is a placeholder sentinel.

	@param value -- Default value
	@return boolean -- True if placeholder
]=]
local function isPlaceholder(value: string?): boolean
	if not value then
		return true
	end

	for _, pattern in PLACEHOLDER_PATTERNS do
		if string.find(value, pattern, 1, true) then
			return true
		end
	end

	return false
end

--[=[
	@private
	Initializes class data map with tags and property storage.

	@param api -- API dump
	@return { [string]: { tags: any, props: { [string]: PropertyData } } } -- Class data map
]=]
local function initClassData(api: lib.ApiDump)
	local data: any

	data = {}
	for _, class in api.Classes do
		data[class.Name] = {
			tags = lib.tags(class.Tags),
			props = {},
		}
	end
	return data
end

--[=[
	@private
	Builds reason string for asymmetric serialization.

	@param ser -- Serialization info
	@param tags -- Property tags
	@return string? -- Reason if interesting, nil otherwise
]=]
local function buildReason(ser: lib.Serialization, tags: { [string]: any }): string?
	if ser.CanLoad and not ser.CanSave then
		return "CanLoad only"
	elseif ser.CanSave and not ser.CanLoad then
		return "CanSave only"
	elseif tags.Deprecated and ser.CanSave then
		return "Deprecated but saveable"
	end
	return nil
end

--[=[
	@private
	Processes property for asymmetric serialization.

	@param className -- Class name
	@param member -- Member to process
	@param classData -- Class data storage
	@param props -- Properties list
]=]
local function processMember(
	className: string,
	member: lib.Member,
	classData: any,
	props: { AsymmetricProperty }
)
	local tags: { [string]: any }
	local ser: lib.Serialization
	local reason: string?

	if member.MemberType ~= "Property" or not member.Serialization then
		return
	end

	tags = lib.tags(member.Tags)
	ser = member.Serialization

	-- Store property data for default checking
	classData.props[member.Name] = {
		serialization = ser,
		tags = tags,
		default = member.Default,
	}

	-- Check if property has interesting serialization
	if not ser.CanLoad and not ser.CanSave then
		return
	end

	reason = buildReason(ser, tags)
	if reason then
		table.insert(props, {
			type = "asymmetric",
			class = className,
			property = member.Name,
			reason = reason,
			canSave = ser.CanSave,
			canLoad = ser.CanLoad,
			deprecated = tags.Deprecated or nil,
		})
	end
end

--[=[
	@private
	Checks NotCreatable class for non-placeholder defaults.

	@param className -- Class name
	@param classData -- Class data
	@param defaults -- Defaults list
]=]
local function checkDefaults(className: string, classData: any, defaults: { NotCreatableDefault })
	if not classData.tags.NotCreatable then
		return
	end

	for propName, propData in classData.props do
		if not isPlaceholder(propData.default) then
			table.insert(defaults, {
				type = "notCreatableDefault",
				class = className,
				property = propName,
				default = propData.default,
			})
		end
	end
end

--[=[
	@private
	Collects interesting properties from API dump.

	@param api -- API dump
	@return { AsymmetricProperty } -- Asymmetric properties
	@return { NotCreatableDefault } -- NotCreatable defaults
]=]
local function collectProperties(api: lib.ApiDump): ({ AsymmetricProperty }, { NotCreatableDefault })
	local classData: any
	local asymmetric: { AsymmetricProperty }
	local defaults: { NotCreatableDefault }
	local ok: boolean
	local err: any

	classData = initClassData(api)
	asymmetric = {}
	defaults = {}

	for _, class in api.Classes do
		for _, member in class.Members do
			ok, err = pcall(processMember, class.Name, member, classData[class.Name], asymmetric)
			if not ok then
				lib.warn(`Error processing {class.Name}.{member.Name}: {err}`)
			end
		end

		checkDefaults(class.Name, classData[class.Name], defaults)
	end

	return asymmetric, defaults
end

--[=[
	@private
	Combines and sorts properties into unified output.

	@param asymmetric -- Asymmetric properties
	@param defaults -- NotCreatable defaults
	@return { Property } -- Combined sorted properties
]=]
local function buildOutput(asymmetric: { AsymmetricProperty }, defaults: { NotCreatableDefault }): { Property }
	local combined: { Property }

	combined = {}

	for _, prop in asymmetric do
		table.insert(combined, prop)
	end

	for _, prop in defaults do
		table.insert(combined, prop)
	end

	-- Sort for deterministic output
	table.sort(combined, function(a, b)
		if a.class == b.class then
			return a.property < b.property
		end
		return a.class < b.class
	end)

	return combined
end

-- Public API

--[=[
	Runs interesting properties analysis on API dump.

	@param hash -- Optional version hash
	@error Throws if analysis fails
]=]
function InterestingProperties.run(hash: string?)
	local api: lib.ApiDump
	local asymmetric: { AsymmetricProperty }
	local defaults: { NotCreatableDefault }
	local combined: { Property }

	api = lib.fetch(hash)
	asymmetric, defaults = collectProperties(api)
	combined = buildOutput(asymmetric, defaults)

	lib.json("interesting-properties", lib.output(hash, combined, {
		asymmetric = #asymmetric,
		notCreatableDefault = #defaults,
	}))

	lib.success(#combined, "interesting properties", `{#asymmetric} asymmetric, {#defaults} NotCreatable defaults`)
end

-- Entry Point
lib.runCli(InterestingProperties.run, Process.args)
