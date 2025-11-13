--!strict
--[=[
	@class Stylua
	Stylua code formatting stage.

	Formats Lua/Luau code using stylua with configurable style settings.
	Supports both in-place formatting and output to new files. Validates
	stylua availability and configuration before execution.

	@usage
	```lua
	local StyluaFormatter = require("./stages/stylua-formatter")
	local result = StyluaFormatter.format(filePath, config)
	```
]=]

-- Imports
local Process = require("@lune/process")
local DateTime = require("@lune/datetime")
local Logger = require("../lib/logger")
local FsUtils = require("../lib/fs-utils")
local Config = require("../lib/config")

-- Constants
local DEFAULT_CONFIG_PATH: string = "stylua.toml"

-- Types
export type FormatResult = {
	success: boolean,
	output: string?,
	error: string?,
	duration: number,
	formatted: boolean,
}

-- Module
local Stylua = {}

--[=[
	Formats a file using stylua.

	@param filePath Path to file to format (formatted in-place)
	@param config Optional stylua configuration
	@return FormatResult with success status and timing
]=]
function Stylua.format(filePath: string, config: Config.StyluaConfig?): FormatResult
	local startTime: number = DateTime.now().unixTimestampMillis

	-- Validate file exists
	if not FsUtils.isReadableFile(filePath) then
		return {
			success = false,
			output = nil,
			error = `File not found or unreadable: {filePath}`,
			duration = 0,
			formatted = false,
		}
	end

	-- Build stylua arguments
	local args: { string } = {}

	-- Add config path if specified
	if config and config.configPath then
		if not FsUtils.isReadableFile(config.configPath) then
			return {
				success = false,
				output = nil,
				error = `Stylua config not found: {config.configPath}`,
				duration = 0,
				formatted = false,
			}
		end
		table.insert(args, "--config-path")
		table.insert(args, config.configPath)
	elseif FsUtils.isReadableFile(DEFAULT_CONFIG_PATH) then
		-- Use default config if it exists
		table.insert(args, "--config-path")
		table.insert(args, DEFAULT_CONFIG_PATH)
	end

	-- Add file to format
	table.insert(args, filePath)

	Logger.verbose(`Executing: stylua {table.concat(args, " ")}`)

	-- Execute stylua
	local result = Process.exec("stylua", args)

	local duration: number = DateTime.now().unixTimestampMillis - startTime

	if not result.ok then
		return {
			success = false,
			output = nil,
			error = `Stylua formatting failed: {result.stderr}`,
			duration = duration,
			formatted = false,
		}
	end

	return {
		success = true,
		output = filePath,
		error = nil,
		duration = duration,
		formatted = true,
	}
end

--[=[
	Formats multiple files using stylua.

	@param filePaths List of file paths to format
	@param config Optional stylua configuration
	@return List of FormatResults for each file
]=]
function Stylua.formatMultiple(filePaths: { string }, config: Config.StyluaConfig?): { FormatResult }
	local results: { FormatResult } = {}

	for _, filePath: string in filePaths do
		local result: FormatResult = StyluaFormatter.format(filePath, config)
		table.insert(results, result)
	end

	return results
end

--[=[
	Checks if stylua is available in the system PATH.

	@return True if stylua command is available
]=]
function Stylua.isAvailable(): boolean
	local result = Process.exec("stylua", { "--version" })
	return result.ok
end

--[=[
	Gets the installed stylua version.

	@return Version string, or nil if stylua is not available
]=]
function Stylua.getVersion(): string?
	local result = Process.exec("stylua", { "--version" })
	if not result.ok then
		return nil
	end

	-- Extract version from output (format: "stylua 0.20.0")
	local version: string? = result.stdout:match("stylua ([%d%.]+)")
	return version
end

--[=[
	Validates a stylua configuration file.

	@param configPath Path to stylua configuration file
	@return True if valid, or false and error message
]=]
function Stylua.validateConfig(configPath: string): (boolean, string?)
	if not FsUtils.isReadableFile(configPath) then
		return false, `Config file not found: {configPath}`
	end

	-- Try to run stylua with the config to validate it
	local result = Process.exec("stylua", {
		"--config-path",
		configPath,
		"--check",
		configPath, -- Check the config file itself
	})

	-- If it fails with a config error, we'll see it in stderr
	if not result.ok and result.stderr:find("config") then
		return false, `Invalid config: {result.stderr}`
	end

	return true, nil
end

--[=[
	Checks if a file needs formatting without modifying it.

	@param filePath Path to file to check
	@param config Optional stylua configuration
	@return True if file needs formatting, false if already formatted
]=]
function Stylua.needsFormatting(filePath: string, config: Config.StyluaConfig?): (boolean, string?)
	if not FsUtils.isReadableFile(filePath) then
		return false, `File not found: {filePath}`
	end

	local args: { string } = { "--check" }

	if config and config.configPath then
		table.insert(args, "--config-path")
		table.insert(args, config.configPath)
	elseif FsUtils.isReadableFile(DEFAULT_CONFIG_PATH) then
		table.insert(args, "--config-path")
		table.insert(args, DEFAULT_CONFIG_PATH)
	end

	table.insert(args, filePath)

	local result = Process.exec("stylua", args)

	-- Exit code 1 means file needs formatting, 0 means already formatted
	return not result.ok, nil
end

return Stylua
