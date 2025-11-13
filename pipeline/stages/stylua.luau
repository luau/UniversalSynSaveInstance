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
local Fs = require("../lib/fs")
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

	Formats file in-place using specified or default configuration.

	@param filePath Path to file to format
	@param config Optional stylua configuration
	@return FormatResult with success status and timing
]=]
function Stylua.format(filePath: string, config: Config.StyluaConfig?): FormatResult
	local startTime: number = DateTime.now().unixTimestampMillis

	if not Fs.exists(filePath) then
		return {
			success = false,
			output = nil,
			error = `File not found: {filePath}`,
			duration = 0,
			formatted = false,
		}
	end

	local args: { string } = {}

	if config and config.configPath then
		if not Fs.exists(config.configPath) then
			return {
				success = false,
				output = nil,
				error = `Config not found: {config.configPath}`,
				duration = 0,
				formatted = false,
			}
		end
		table.insert(args, "--config-path")
		table.insert(args, config.configPath)
	elseif Fs.exists(DEFAULT_CONFIG_PATH) then
		table.insert(args, "--config-path")
		table.insert(args, DEFAULT_CONFIG_PATH)
	end

	table.insert(args, filePath)

	Logger.verbose(`Executing: stylua {table.concat(args, " ")}`)

	local result = Process.exec("stylua", args)
	local duration: number = DateTime.now().unixTimestampMillis - startTime

	if not result.ok then
		return {
			success = false,
			output = nil,
			error = `Format failed: {result.stderr}`,
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
	Checks if stylua is available in the system PATH.

	@return True if stylua command is available
]=]
function Stylua.isAvailable(): boolean
	local result = Process.exec("stylua", { "--version" })
	return result.ok
end

--[=[
	Gets the installed stylua version.

	@return Version string like "0.20.0", or nil if unavailable
]=]
function Stylua.getVersion(): string?
	local result = Process.exec("stylua", { "--version" })
	if not result.ok then
		return nil
	end

	return result.stdout:match("stylua ([%d%.]+)")
end

return Stylua
