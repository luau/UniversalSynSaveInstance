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
	Escapes special pattern characters for use in Lua pattern matching.

	@param str The string to escape
	@return Escaped string safe for pattern matching
]=]
local function escapePattern(str: string): string
	return str:gsub("([%%%+%-%*%?%[%]%^%$%(%)%%])", "%%%1")
end

--[=[
	Resolves a marker value to a string.

	If the value is a function, calls it and returns the result.
	If the value is a string, returns it directly.

	@param value The marker value (string or function)
	@return Resolved string value
]=]
local function resolveMarkerValue(value: MarkerValue): string
	if type(value) == "function" then
		return (value :: () -> string)()
	else
		return value :: string
	end
end

--[=[
	Composes a template by replacing markers with values.

	Markers in the template should follow the pattern: __COMPOSER.Insert(__COMPOSER.{key})
	For example: __COMPOSER.Insert(__COMPOSER.build)

	@param template The template string
	@param markers Dictionary of marker names to replacement values
	@return Composed string with all markers replaced
]=]
function Composer.compose(template: string, markers: Markers): ComposeResult
	local output: string = template
	local replacementCount: number = 0

	for key: string, value: MarkerValue in markers do
		local markerPattern: string = `__COMPOSER.Insert(__COMPOSER.{key})`
		local escapedPattern: string = escapePattern(markerPattern)

		-- Count occurrences before replacement
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
					error = `Failed to resolve marker '{key}': {result}`,
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

	@param templatePath The path to the template file
	@param markers Dictionary of marker names to replacement values
	@return ComposeResult with success status and output or error
]=]
function Composer.composeFromFile(templatePath: string, markers: Markers): ComposeResult
	local template: string?, err: string? = FsUtils.safeReadFile(templatePath)
	if not template then
		return {
			success = false,
			output = nil,
			error = `Failed to load template: {err}`,
			replacements = 0,
		}
	end

	return Composer.compose(template, markers)
end

--[=[
	Validates that all expected markers in a template are provided.

	@param template The template string
	@param markers Dictionary of provided markers
	@return True if all markers are provided, or false and list of missing markers
]=]
function Composer.validateMarkers(template: string, markers: Markers): (boolean, { string }?)
	local missing: { string } = {}

	-- Find all markers in the template
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
	Extracts all marker names from a template.

	@param template The template string
	@return List of marker names found in the template
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

	@param buildCode The compiled build code
	@param version The build version string
	@param configName The build configuration name
	@return Markers dictionary with standard build markers
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
