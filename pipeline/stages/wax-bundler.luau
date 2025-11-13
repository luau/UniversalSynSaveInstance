--!strict
--[=[
	@class WaxBundler
	Wax bundling stage for Roblox model and Rojo project bundling.

	Executes wax to bundle Roblox models (.rbxm/.rbxmx) or Rojo projects
	(.project.json) into standalone Lua/Luau scripts with virtual Roblox DOM
	support. Optionally integrates darklua for post-bundle minification.

	@usage
	```lua
	local WaxBundler = require("./stages/wax-bundler")
	local result = WaxBundler.bundle(input, output, waxConfig)
	```
]=]

-- Imports
local Process = require("@lune/process")
local DateTime = require("@lune/datetime")
local Logger = require("../lib/logger")
local FsUtils = require("../lib/fs-utils")
local Config = require("../lib/config")

-- Types
export type BundleResult = {
	success: boolean,
	output: string?,
	error: string?,
	duration: number,
}

-- Module
local WaxBundler = {}

--[=[
	Builds wax command-line arguments from configuration.

	@param input Input file path (.rbxm/.rbxmx/.project.json)
	@param output Output file path
	@param config Wax configuration
	@return Array of command-line arguments
]=]
local function buildWaxArgs(input: string, output: string, config: Config.WaxConfig): { string }
	local args: { string } = {
		"bundle",
		`input={input}`,
		`output={output}`,
	}

	-- Add optional parameters
	if config.minify then
		table.insert(args, "minify=true")
	end

	if config.envName then
		table.insert(args, `env-name={config.envName}`)
	end

	if config.darklua and config.darklua.config then
		table.insert(args, `darklua-config-path={config.darklua.config}`)
	end

	-- Always use CI mode for automated builds
	table.insert(args, "ci-mode=true")
	table.insert(args, "verbose=true")

	return args
end

--[=[
	Bundles a Roblox model or Rojo project using wax.

	@param input Input file path (.rbxm, .rbxmx, or .project.json)
	@param output Output file path
	@param config Wax configuration
	@return BundleResult with success status, output path, and timing
]=]
function WaxBundler.bundle(input: string, output: string, config: Config.WaxConfig): BundleResult
	local startTime: number = DateTime.now().unixTimestampMillis

	-- Validate input file exists
	if not FsUtils.isReadableFile(input) then
		return {
			success = false,
			output = nil,
			error = `Input file not found or unreadable: {input}`,
			duration = 0,
		}
	end

	-- Validate input file type
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
			error = `Invalid input file type. Expected .rbxm, .rbxmx, or .project.json`,
			duration = 0,
		}
	end

	-- Ensure output directory exists
	FsUtils.ensureParentDir(output)

	-- Build wax arguments
	local args: { string } = buildWaxArgs(input, output, config)

	Logger.verbose(`Executing: lune run wax {table.concat(args, " ")}`)

	-- Execute wax via lune
	local result = Process.exec("lune", { "run", "wax", table.unpack(args) })

	local duration: number = DateTime.now().unixTimestampMillis - startTime

	if not result.ok then
		return {
			success = false,
			output = nil,
			error = `Wax bundling failed: {result.stderr}`,
			duration = duration,
		}
	end

	-- Verify output was created
	if not FsUtils.isReadableFile(output) then
		return {
			success = false,
			output = nil,
			error = `Wax completed but output file was not created: {output}`,
			duration = duration,
		}
	end

	return {
		success = true,
		output = output,
		error = nil,
		duration = duration,
	}
end

--[=[
	Checks if wax is available via lune.

	@return True if wax can be executed
]=]
function WaxBundler.isAvailable(): boolean
	local result = Process.exec("lune", { "run", "wax", "version" })
	return result.ok
end

--[=[
	Gets the installed wax version.

	@return Version string, or nil if wax is not available
]=]
function WaxBundler.getVersion(): string?
	local result = Process.exec("lune", { "run", "wax", "version" })
	if not result.ok then
		return nil
	end

	-- Extract version from output (format: "wax v0.4.2")
	local version: string? = result.stdout:match("wax v([%d%.]+)")
	return version
end

--[=[
	Detects if the input file is a Rojo project.

	@param input Input file path
	@return True if input is a Rojo project file
]=]
function WaxBundler.isRojoProject(input: string): boolean
	return input:match("%.project%.json$") ~= nil
end

--[=[
	Detects if the input file is a Roblox model.

	@param input Input file path
	@return True if input is a Roblox model file
]=]
function WaxBundler.isRobloxModel(input: string): boolean
	return input:match("%.rbxmx?$") ~= nil
end

return WaxBundler
