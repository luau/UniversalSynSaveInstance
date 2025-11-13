--!strict
--[=[
	@class Composer
	Template composition engine for the build pipeline.

	Replaces composer markers in template files with dynamic values. Supports
	both string replacements and function-based dynamic value generation.

	@usage
	```lua
	local Composer = require("./lib/composer")
	local markers = {
		build = buildCode,
		version = "v1.0.0",
		date = function() return os.date() end
	}
	local result = Composer.compose(template, markers)
	```
]=]

-- Imports
local fs = require("@lune/fs")
local FsUtils = require("./fs-utils")

-- Types
export type MarkerValue = string | () -> string

export type Markers = {
	[string]: MarkerValue,
}

export type ComposeResult = {
	success: boolean,
	output: string?,
	error: string?,
	replacements: number,
}

-- Module
local Composer = {}

--[=[
	Escapes special pattern characters for safe Lua pattern matching.

	Converts characters like %, +, -, *, ?, [, ], ^, $, (, ) to their escaped
	forms so they can be matched literally in string.gsub patterns.

	@param str String to escape
	@return Escaped string safe for use in Lua patterns
]=]
local function escapePattern(str: string): string
	return str:gsub("([%%%+%-%*%?%[%]%^%$%(%)%%])", "%%%1")
end

--[=[
	Resolves a marker value to a string.

	If value is a function, invokes it and returns the result. If value is
	already a string, returns it directly.

	@param value Marker value (string literal or generator function)
	@return Resolved string value
]=]
local function resolveMarkerValue(value: MarkerValue): string
	if type(value) == "function" then
		return (value :: () -> string)()
	end
	return value :: string
end

--[=[
	Composes a template by replacing markers with values.

	Searches for patterns like __COMPOSER.Insert(__COMPOSER.{key}) and replaces
	them with the corresponding marker value. Supports both static strings and
	dynamic function-based values.

	@param template Template string containing composer markers
	@param markers Dictionary mapping marker names to values or generators
	@return ComposeResult with success status, output, and replacement count
]=]
function Composer.compose(template: string, markers: Markers): ComposeResult
	local output: string = template
	local replacementCount: number = 0

	for key: string, value: MarkerValue in markers do
		local markerPattern: string = `__COMPOSER.Insert(__COMPOSER.{key})`
		local escapedPattern: string = escapePattern(markerPattern)

		local count: number = 0
		for _ in output:gmatch(escapedPattern) do
			count += 1
		end

		if count > 0 then
			local success: boolean, result: string = pcall(function()
				local resolvedValue: string = resolveMarkerValue(value)
				return output:gsub(escapedPattern, function()
					return resolvedValue
				end)
			end)

			if not success then
				return {
					success = false,
					output = nil,
					error = `Marker '{key}' resolution failed: {result}`,
					replacements = replacementCount,
				}
			end

			output = result
			replacementCount += count
		end
	end

	return {
		success = true,
		output = output,
		error = nil,
		replacements = replacementCount,
	}
end

--[=[
	Loads a template from a file and composes it with markers.

	Reads template file and replaces all markers in a single operation.

	@param templatePath Path to template file
	@param markers Dictionary of marker names to replacement values
	@return ComposeResult with success status, output, and replacement count
]=]
function Composer.composeFromFile(templatePath: string, markers: Markers): ComposeResult
	local template: string?, err: string? = Fs.read(templatePath)
	if not template then
		return {
			success = false,
			output = nil,
			error = `Template load failed: {err}`,
			replacements = 0,
		}
	end

	return Composer.compose(template, markers)
end

--[=[
	Validates that all markers in template are provided.

	Extracts all __COMPOSER.Insert(__COMPOSER.{key}) patterns from template
	and checks if corresponding values exist in the markers dictionary.

	@param template Template string to check
	@param markers Dictionary of available markers
	@return True if valid, or false and list of missing marker names
]=]
function Composer.validateMarkers(template: string, markers: Markers): (boolean, { string }?)
	local missing: { string } = {}

	for markerKey in template:gmatch("__COMPOSER%.Insert%(__COMPOSER%.([%w_]+)%)") do
		if not markers[markerKey] then
			table.insert(missing, markerKey)
		end
	end

	if #missing > 0 then
		return false, missing
	end

	return true, nil
end

--[=[
	Extracts all unique marker names from a template.

	Returns each marker name only once even if it appears multiple times.

	@param template Template string to scan
	@return List of unique marker names found
]=]
function Composer.extractMarkers(template: string): { string }
	local found: { string } = {}
	local seen: { [string]: boolean } = {}

	for markerKey in template:gmatch("__COMPOSER%.Insert%(__COMPOSER%.([%w_]+)%)") do
		if not seen[markerKey] then
			table.insert(found, markerKey)
			seen[markerKey] = true
		end
	end

	return found
end

--[=[
	Creates default marker generators for common build metadata.

	Generates markers for: build code, generation date, config name, and version.
	Date/config/version markers use string.format %q for proper Lua string escaping.

	@param buildCode Compiled build code to inject
	@param version Build version string
	@param configName Build configuration name
	@return Markers dictionary with standard build metadata
]=]
function Composer.createDefaultMarkers(buildCode: string, version: string, configName: string): Markers
	local DateTime = require("@lune/datetime")

	return {
		build = buildCode,
		genDate = function()
			return string.format("%q", DateTime.now():toIsoDate())
		end,
		cfg = function()
			return string.format("%q", configName)
		end,
		vers = function()
			return string.format("%q", version)
		end,
	}
end

return Composer
