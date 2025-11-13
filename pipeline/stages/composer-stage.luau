--!strict
--[=[
	@class ComposerStage
	Template composition stage for build output framing.

	Wraps compiled build output in a template frame, injecting metadata like
	build date, version, configuration name, and the compiled code itself.
	Validates that all required markers are present before composition.

	@usage
	```lua
	local ComposerStage = require("./stages/composer-stage")
	local result = ComposerStage.compose(buildCode, templatePath, markers)
	```
]=]

-- Imports
local DateTime = require("@lune/datetime")
local Logger = require("../lib/logger")
local Composer = require("../lib/composer")
local FsUtils = require("../lib/fs-utils")
local Config = require("../lib/config")

-- Types
export type ComposeStageResult = {
	success: boolean,
	output: string?,
	error: string?,
	duration: number,
	replacements: number,
}

-- Module
local ComposerStage = {}

--[=[
	Composes a build output with a template frame.

	Reads the current build output, loads the template, replaces all markers,
	and writes the composed result back to the output file.

	@param outputPath Path to the build output file (will be read and overwritten)
	@param templateConfig Template configuration
	@param version Build version string
	@param configName Build configuration name
	@return ComposeStageResult with success status and timing
]=]
function ComposerStage.compose(
	outputPath: string,
	templateConfig: Config.TemplateConfig,
	version: string,
	configName: string
): ComposeStageResult
	local startTime: number = DateTime.now().unixTimestampMillis

	-- Read the current build output (compiled code)
	local buildCode: string?, readErr: string? = FsUtils.safeReadFile(outputPath)
	if not buildCode then
		return {
			success = false,
			output = nil,
			error = `Failed to read build output: {readErr}`,
			duration = 0,
			replacements = 0,
		}
	end

	-- Create default markers
	local markers: Composer.Markers = Composer.createDefaultMarkers(buildCode, version, configName)

	-- Add any custom markers from config
	if templateConfig.markers then
		for key: string, value: string in templateConfig.markers do
			markers[key] = value
		end
	end

	-- Load and compose template
	local composeResult: Composer.ComposeResult = Composer.composeFromFile(templateConfig.source, markers)

	if not composeResult.success then
		return {
			success = false,
			output = nil,
			error = composeResult.error,
			duration = DateTime.now().unixTimestampMillis - startTime,
			replacements = 0,
		}
	end

	-- Write composed output back to file
	local writeSuccess: boolean, writeErr: string? = FsUtils.safeWriteFile(outputPath, composeResult.output :: string)
	if not writeSuccess then
		return {
			success = false,
			output = nil,
			error = `Failed to write composed output: {writeErr}`,
			duration = DateTime.now().unixTimestampMillis - startTime,
			replacements = composeResult.replacements,
		}
	end

	local duration: number = DateTime.now().unixTimestampMillis - startTime

	return {
		success = true,
		output = outputPath,
		error = nil,
		duration = duration,
		replacements = composeResult.replacements,
	}
end

--[=[
	Validates that a template file exists and contains expected markers.

	@param templatePath Path to template file
	@return True if valid, or false and error message
]=]
function ComposerStage.validateTemplate(templatePath: string): (boolean, string?)
	if not FsUtils.isReadableFile(templatePath) then
		return false, `Template file not found or unreadable: {templatePath}`
	end

	local template: string?, err: string? = FsUtils.safeReadFile(templatePath)
	if not template then
		return false, `Failed to read template: {err}`
	end

	-- Extract markers from template
	local foundMarkers: { string } = Composer.extractMarkers(template)

	if #foundMarkers == 0 then
		return false, "Template contains no composer markers"
	end

	Logger.verbose(`Template contains {#foundMarkers} markers: {table.concat(foundMarkers, ", ")}`)

	return true, nil
end

--[=[
	Gets the default template path for standard builds.

	@return Default template path
]=]
function ComposerStage.getDefaultTemplatePath(): string
	return "pipeline/templates/frame.luau"
end

return ComposerStage
