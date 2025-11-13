--!strict
--[=[
	@class ComposerStage
	Template composition stage for build output framing.

	Wraps compiled build output in a template frame, injecting metadata like
	build date, version, configuration name, and the compiled code itself.
	Validates that all required markers are present before composition.

	@usage
	```lua
	local ComposerStage = require("./stages/composer")
	local result = ComposerStage.compose(outputPath, templateConfig, version, configName)
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

	Reads compiled code, injects it into template with metadata markers, and
	writes result back to output file.

	@param outputPath Path to build output (read and overwritten)
	@param templateConfig Template configuration with source path
	@param version Build version string
	@param configName Build configuration name
	@return ComposeStageResult with success, timing, replacement count
]=]
function ComposerStage.compose(
	outputPath: string,
	templateConfig: Config.TemplateConfig,
	version: string,
	configName: string
): ComposeStageResult
	local startTime: number = DateTime.now().unixTimestampMillis

	local buildCode: string?, readErr: string? = FsUtils.safeReadFile(outputPath)
	if not buildCode then
		return {
			success = false,
			output = nil,
			error = `Read failed: {readErr}`,
			duration = 0,
			replacements = 0,
		}
	end

	local markers: Composer.Markers = Composer.createDefaultMarkers(buildCode, version, configName)

	if templateConfig.markers then
		for key: string, value: string in templateConfig.markers do
			markers[key] = value
		end
	end

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

	local writeSuccess: boolean, writeErr: string? = FsUtils.safeWriteFile(outputPath, composeResult.output :: string)
	if not writeSuccess then
		return {
			success = false,
			output = nil,
			error = `Write failed: {writeErr}`,
			duration = DateTime.now().unixTimestampMillis - startTime,
			replacements = composeResult.replacements,
		}
	end

	return {
		success = true,
		output = outputPath,
		error = nil,
		duration = DateTime.now().unixTimestampMillis - startTime,
		replacements = composeResult.replacements,
	}
end

--[=[
	Validates that a template file exists and contains markers.

	Checks file readability and scans for at least one composer marker.

	@param templatePath Path to template file
	@return True if valid, false and error message otherwise
]=]
function ComposerStage.validateTemplate(templatePath: string): (boolean, string?)
	if not FsUtils.isReadableFile(templatePath) then
		return false, `Template not found: {templatePath}`
	end

	local template: string?, err: string? = FsUtils.safeReadFile(templatePath)
	if not template then
		return false, `Read failed: {err}`
	end

	local foundMarkers: { string } = Composer.extractMarkers(template)

	if #foundMarkers == 0 then
		return false, "Template has no composer markers"
	end

	Logger.verbose(`Template has {#foundMarkers} markers: {table.concat(foundMarkers, ", ")}`)

	return true, nil
end

--[=[
	Gets the default template path for standard builds.

	@return Default template file path
]=]
function ComposerStage.getDefaultTemplatePath(): string
	return "pipeline/templates/frame.luau"
end

return ComposerStage
