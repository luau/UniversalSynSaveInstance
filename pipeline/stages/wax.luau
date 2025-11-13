--!strict
--[=[
	@class Wax
	Wax bundling stage for Roblox model and Rojo project bundling.

	Executes wax to bundle Roblox models (.rbxm/.rbxmx) or Rojo projects
	(.project.json) into standalone Lua/Luau scripts with virtual Roblox DOM
	support. Optionally integrates darklua for post-bundle minification.

	@usage
	```lua
	local Wax = require("./stages/wax")
	local result = Wax.bundle(input, output, waxConfig)
	```
]=]

-- Imports
local Process = require("@lune/process")
local DateTime = require("@lune/datetime")
local Logger = require("../lib/logger")
local Fs = require("../lib/fs")
local Config = require("../lib/config")

-- Types
export type BundleResult = {
	success: boolean,
	output: string?,
	error: string?,
	duration: number,
}

-- Module
local Wax = {}

-- Helper functions

--[=[
	Builds wax command-line arguments from configuration.

	Constructs key=value pairs for wax bundle command with optional minify,
	env-name, and darklua-config-path parameters.

	@param input Input file path (.rbxm/.rbxmx/.project.json)
	@param output Output file path
	@param config Wax configuration
	@return Array of command-line argument strings
]=]
local function buildWaxArgs(input: string, output: string, config: Config.WaxConfig): { string }
	local args: { string } = {
		"bundle",
		`input={input}`,
		`output={output}`,
	}

	if config.minify then
		table.insert(args, "minify=true")
	end

	if config.envName then
		table.insert(args, `env-name={config.envName}`)
	end

	if config.darklua and config.darklua.config then
		table.insert(args, `darklua-config-path={config.darklua.config}`)
	end

	table.insert(args, "ci-mode=true")
	table.insert(args, "verbose=true")

	return args
end

--[=[
	Bundles a Roblox model or Rojo project using wax.

	Validates input file type, executes wax via lune, and verifies output creation.

	@param input Input file path (.rbxm, .rbxmx, or .project.json)
	@param output Output Luau file path
	@param config Wax configuration
	@return BundleResult with success, output, duration
]=]
function Wax.bundle(input: string, output: string, config: Config.WaxConfig): BundleResult
	local startTime: number = DateTime.now().unixTimestampMillis

	if not Fs.exists(input) then
		return {
			success = false,
			output = nil,
			error = `Input not found: {input}`,
			duration = 0,
		}
	end

	-- Supported Roblox file extensions for wax bundling
	local validExtensions: { string } = { ".rbxm", ".rbxmx", ".project.json" }
	local hasValidExtension: boolean = false

	for _, ext: string in validExtensions do
		if input:match(ext .. "$") then
			hasValidExtension = true
			break
		end
	end

	if not hasValidExtension then
		return {
			success = false,
			output = nil,
			error = "Invalid input type (expected .rbxm, .rbxmx, or .project.json)",
			duration = 0,
		}
	end

	Fs.ensureParent(output)

	local args: { string } = buildWaxArgs(input, output, config)

	Logger.verbose(`Executing: lune run wax {table.concat(args, " ")}`)

	local result = Process.exec("lune", { "run", "wax", table.unpack(args) })

	if not result.ok then
		return {
			success = false,
			output = nil,
			error = `Bundle failed: {result.stderr}`,
			duration = DateTime.now().unixTimestampMillis - startTime,
		}
	end

	if not Fs.exists(output) then
		return {
			success = false,
			output = nil,
			error = `Output not created: {output}`,
			duration = DateTime.now().unixTimestampMillis - startTime,
		}
	end

	return {
		success = true,
		output = output,
		error = nil,
		duration = DateTime.now().unixTimestampMillis - startTime,
	}
end

--[=[
	Checks if wax is available via lune.

	@return True if wax command exists
]=]
function Wax.isAvailable(): boolean
	return Process.exec("lune", { "run", "wax", "version" }).ok
end

--[=[
	Gets the installed wax version.

	@return Version like "0.4.2", or nil if unavailable
]=]
function Wax.getVersion(): string?
	local result = Process.exec("lune", { "run", "wax", "version" })
	if not result.ok then
		return nil
	end

	return result.stdout:match("wax v([%d%.]+)")
end

return Wax
